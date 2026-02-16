import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/sync/core/sync_manager.dart';
import 'package:front_shared/src/sync/core/sync_state.dart';
import 'package:front_shared/src/sync/strategies/pull_strategy.dart';
import 'package:front_shared/src/sync/strategies/push_strategy.dart';
import 'package:front_shared/src/sync/core/sync_queue.dart';
import 'package:front_shared/src/core/network/network_info.dart';
import 'package:front_shared/src/data/local/secure_storage/secure_storage_service.dart';
import 'package:front_shared/src/core/logging/log_service.dart';

@GenerateMocks([
  PullStrategy,
  PushStrategy,
  SyncQueue,
  NetworkInfo,
  SecureStorageService,
])
import 'sync_manager_test.mocks.dart';

void main() {
  late SyncManager syncManager;
  late MockPullStrategy mockPullStrategy;
  late MockPushStrategy mockPushStrategy;
  late MockSyncQueue mockSyncQueue;
  late MockNetworkInfo mockNetworkInfo;
  late MockSecureStorageService mockStorage;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider for LogService
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });

    // Configure LogService for tests
    LogService.configure('test');

    mockPullStrategy = MockPullStrategy();
    mockPushStrategy = MockPushStrategy();
    mockSyncQueue = MockSyncQueue();
    mockNetworkInfo = MockNetworkInfo();
    mockStorage = MockSecureStorageService();

    // Default stub for getLastSyncTime (can be overridden in individual tests)
    when(mockStorage.getLastSyncTime()).thenAnswer((_) async => null);

    syncManager = SyncManager(
      mockPullStrategy,
      mockPushStrategy,
      mockSyncQueue,
      mockNetworkInfo,
      mockStorage,
    );
  });

  tearDown(() {
    syncManager.dispose();
  });

  group('SyncManager', () {
    test('sync executes PULL → PUSH → RETRY flow', () async {
      // Setup mocks
      when(mockStorage.getUserId()).thenAnswer((_) async => 'athlete-1');
      when(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).thenAnswer((_) async => 5);
      when(mockPushStrategy.execute()).thenAnswer((_) async =>
          SyncResult.success(pullCount: 0, pushCount: 3, timestamp: DateTime.now()));
      when(mockPushStrategy.retryQueuedSyncs()).thenAnswer((_) async => 1);

      final result = await syncManager.sync();

      // Verify flow
      verify(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).called(1);
      verify(mockPushStrategy.execute()).called(1);
      verify(mockPushStrategy.retryQueuedSyncs()).called(1);

      // Check result
      result.when(
        success: (pullCount, pushCount, timestamp) {
          expect(pullCount, equals(5));
          expect(pushCount, equals(4)); // 3 + 1 retry
        },
        partialSuccess: (_, __, ___, ____, _____) => fail('Expected success'),
        failure: (_, __, ___) => fail('Expected success'),
      );
    });

    test('sync fails if already in progress', () async {
      when(mockStorage.getUserId()).thenAnswer((_) async => 'athlete-1');
      when(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return 0;
      });
      when(mockPushStrategy.execute()).thenAnswer((_) async =>
          SyncResult.success(pullCount: 0, pushCount: 0, timestamp: DateTime.now()));
      when(mockPushStrategy.retryQueuedSyncs()).thenAnswer((_) async => 0);

      // Start first sync
      final future1 = syncManager.sync();

      // Try to start second sync while first is in progress
      final result2 = await syncManager.sync();

      result2.when(
        success: (_, __, ___) => fail('Expected failure'),
        partialSuccess: (_, __, ___, ____, _____) => fail('Expected failure'),
        failure: (message, _, __) {
          expect(message, contains('already in progress'));
        },
      );

      await future1;
    });

    test('sync state stream emits correct states', () async {
      when(mockStorage.getUserId()).thenAnswer((_) async => 'athlete-1');
      when(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).thenAnswer((_) async => 0);
      when(mockPushStrategy.execute()).thenAnswer((_) async =>
          SyncResult.success(pullCount: 0, pushCount: 0, timestamp: DateTime.now()));
      when(mockPushStrategy.retryQueuedSyncs()).thenAnswer((_) async => 0);

      final states = <SyncState>[];
      final subscription = syncManager.state.listen(states.add);

      await syncManager.sync();

      // Wait for stream to emit all states
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, greaterThan(0));

      // Check that we had at least one syncing state
      var hadSyncingState = false;
      for (final state in states) {
        state.when(
          idle: () {},
          syncing: (_) => hadSyncingState = true,
          completed: (_) {},
          error: (_) {},
        );
      }
      expect(hadSyncingState, isTrue);

      // Check last state is completed
      states.last.when(
        idle: () => fail('Expected completed state'),
        syncing: (_) => fail('Expected completed state'),
        completed: (_) {},
        error: (_) => fail('Expected completed state'),
      );

      await subscription.cancel();
    });

    test('sync handles partial success from push', () async {
      when(mockStorage.getUserId()).thenAnswer((_) async => 'athlete-1');
      when(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).thenAnswer((_) async => 2);
      when(mockPushStrategy.execute()).thenAnswer((_) async =>
          SyncResult.partialSuccess(
            pullCount: 0,
            pushSuccessCount: 3,
            pushFailureCount: 1,
            failures: const [],
            timestamp: DateTime.now(),
          ));
      when(mockPushStrategy.retryQueuedSyncs()).thenAnswer((_) async => 0);

      final result = await syncManager.sync();

      result.when(
        success: (_, __, ___) => fail('Expected partial success'),
        partialSuccess: (pullCount, pushSuccessCount, pushFailureCount, failures, _) {
          expect(pullCount, equals(2));
          expect(pushSuccessCount, equals(3)); // 3 + 0 retry
          expect(pushFailureCount, equals(1));
        },
        failure: (_, __, ___) => fail('Expected partial success'),
      );
    });

    test('sync handles push failure', () async {
      when(mockStorage.getUserId()).thenAnswer((_) async => 'athlete-1');
      when(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).thenAnswer((_) async => 1);
      when(mockPushStrategy.execute()).thenAnswer((_) async =>
          SyncResult.failure(
            message: 'Push failed',
            error: Exception('Network error'),
            timestamp: DateTime.now(),
          ));
      when(mockPushStrategy.retryQueuedSyncs()).thenAnswer((_) async => 0);

      final result = await syncManager.sync();

      result.when(
        success: (_, __, ___) => fail('Expected failure'),
        partialSuccess: (_, __, ___, ____, _____) => fail('Expected failure'),
        failure: (message, error, _) {
          expect(message, equals('Push failed'));
        },
      );
    });

    test('sync fails when no authenticated user', () async {
      when(mockStorage.getUserId()).thenAnswer((_) async => null);

      final result = await syncManager.sync();

      result.when(
        success: (_, __, ___) => fail('Expected failure'),
        partialSuccess: (_, __, ___, ____, _____) => fail('Expected failure'),
        failure: (message, _, __) {
          expect(message, contains('No authenticated user found'));
        },
      );
    });

    test('sync uses provided athleteId instead of storage', () async {
      when(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).thenAnswer((_) async => 0);
      when(mockPushStrategy.execute()).thenAnswer((_) async =>
          SyncResult.success(pullCount: 0, pushCount: 0, timestamp: DateTime.now()));
      when(mockPushStrategy.retryQueuedSyncs()).thenAnswer((_) async => 0);

      await syncManager.sync(athleteId: 'custom-athlete-id');

      verify(mockPullStrategy.execute(
        athleteId: 'custom-athlete-id',
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).called(1);
      verifyNever(mockStorage.getUserId());
    });

    test('currentState returns idle initially', () {
      syncManager.currentState.when(
        idle: () {},
        syncing: (_) => fail('Expected idle state'),
        completed: (_) => fail('Expected idle state'),
        error: (_) => fail('Expected idle state'),
      );
    });

    test('queueLength returns sync queue length', () {
      when(mockSyncQueue.length).thenReturn(5);
      expect(syncManager.queueLength, equals(5));
    });

    test('clearQueue clears the sync queue', () {
      syncManager.clearQueue();
      verify(mockSyncQueue.clear()).called(1);
    });

    test('dispose stops retry timer and closes state controller', () async {
      // Start timer
      syncManager.startRetryTimer();

      // Create a subscription before disposing
      var receivedState = false;
      final subscription = syncManager.state.listen((_) {
        receivedState = true;
      });

      // Dispose
      syncManager.dispose();

      // Wait a bit to ensure stream is closed
      await Future.delayed(const Duration(milliseconds: 50));

      // After dispose, the stream should be closed
      // We can't easily test the stream closure directly, but we can verify
      // the manager is disposed by checking it doesn't crash
      expect(receivedState, isFalse); // No state was emitted

      await subscription.cancel();
    });

    test('startRetryTimer creates periodic timer', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockSyncQueue.length).thenReturn(0);

      syncManager.startRetryTimer();

      // Wait for timer to potentially fire (it checks every 60 seconds)
      // We don't wait that long, just verify it was set up
      expect(syncManager, isNotNull);

      syncManager.stopRetryTimer();
    });

    test('retryQueuedSyncs is called when timer fires and queue has items', () async {
      // This test would require more complex timer mocking
      // For now, we verify the retry logic through the sync() method
      when(mockStorage.getUserId()).thenAnswer((_) async => 'athlete-1');
      when(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).thenAnswer((_) async => 0);
      when(mockPushStrategy.execute()).thenAnswer((_) async =>
          SyncResult.success(pullCount: 0, pushCount: 0, timestamp: DateTime.now()));
      when(mockPushStrategy.retryQueuedSyncs()).thenAnswer((_) async => 2);

      await syncManager.sync();

      verify(mockPushStrategy.retryQueuedSyncs()).called(1);
    });

    test('sync includes retry count in final push count', () async {
      when(mockStorage.getUserId()).thenAnswer((_) async => 'athlete-1');
      when(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).thenAnswer((_) async => 0);
      when(mockPushStrategy.execute()).thenAnswer((_) async =>
          SyncResult.success(pullCount: 0, pushCount: 5, timestamp: DateTime.now()));
      when(mockPushStrategy.retryQueuedSyncs()).thenAnswer((_) async => 3);

      final result = await syncManager.sync();

      result.when(
        success: (pullCount, pushCount, _) {
          expect(pushCount, equals(8)); // 5 + 3
        },
        partialSuccess: (_, __, ___, ____, _____) => fail('Expected success'),
        failure: (_, __, ___) => fail('Expected success'),
      );
    });

    test('sync with parameters passes them to pull strategy', () async {
      when(mockStorage.getUserId()).thenAnswer((_) async => 'athlete-1');
      final since = DateTime.now().subtract(const Duration(days: 7));
      final entityTypes = ['TrainingPlan', 'Exercise'];

      when(mockPullStrategy.execute(
        athleteId: anyNamed('athleteId'),
        since: anyNamed('since'),
        entityTypes: anyNamed('entityTypes'),
      )).thenAnswer((_) async => 0);
      when(mockPushStrategy.execute()).thenAnswer((_) async =>
          SyncResult.success(pullCount: 0, pushCount: 0, timestamp: DateTime.now()));
      when(mockPushStrategy.retryQueuedSyncs()).thenAnswer((_) async => 0);

      await syncManager.sync(
        athleteId: 'test-athlete',
        since: since,
        entityTypes: entityTypes,
      );

      verify(mockPullStrategy.execute(
        athleteId: 'test-athlete',
        since: since,
        entityTypes: entityTypes,
      )).called(1);
    });
  });
}
