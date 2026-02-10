# Step 09: Sync Manager

## Goal
Implement SyncManager to orchestrate the complete sync flow: PULL → PUSH → RETRY.

## Tasks

### 1. Create SyncManager
Create `lib/src/sync/core/sync_manager.dart`:
```dart
import 'dart:async';
import '../strategies/pull_strategy.dart';
import '../strategies/push_strategy.dart';
import 'sync_queue.dart';
import 'sync_state.dart';
import '../../core/network/network_info.dart';
import '../../data/local/secure_storage/secure_storage_service.dart';

class SyncManager {
  final PullStrategy _pullStrategy;
  final PushStrategy _pushStrategy;
  final SyncQueue _syncQueue;
  final NetworkInfo _networkInfo;
  final SecureStorageService _storage;

  final _stateController = StreamController<SyncState>.broadcast();
  Timer? _retryTimer;
  bool _isSyncing = false;

  SyncManager(
    this._pullStrategy,
    this._pushStrategy,
    this._syncQueue,
    this._networkInfo,
    this._storage,
  );

  /// Stream of sync state changes
  Stream<SyncState> get state => _stateController.stream;

  /// Get current sync state
  SyncState get currentState => _currentState;
  SyncState _currentState = const SyncState.idle();

  /// Execute full sync: PULL → PUSH → RETRY
  Future<SyncResult> sync({
    String? athleteId,
    DateTime? since,
    List<String>? entityTypes,
  }) async {
    if (_isSyncing) {
      return SyncResult.failure(
        message: 'Sync already in progress',
        error: null,
        timestamp: DateTime.now(),
      );
    }

    _isSyncing = true;
    _updateState(const SyncState.syncing(phase: 'Starting'));

    try {
      // Get athleteId from storage if not provided
      final effectiveAthleteId = athleteId ?? await _getCurrentAthleteId();

      // Phase 1: PULL - Get changes from server
      _updateState(const SyncState.syncing(phase: 'Pulling changes from server'));
      final pullCount = await _pullStrategy.execute(
        athleteId: effectiveAthleteId,
        since: since,
        entityTypes: entityTypes,
      );

      // Phase 2: PUSH - Send local changes to server
      _updateState(const SyncState.syncing(phase: 'Pushing local changes'));
      final pushResult = await _pushStrategy.execute();

      // Phase 3: RETRY - Process retry queue
      _updateState(const SyncState.syncing(phase: 'Retrying failed syncs'));
      final retryCount = await _pushStrategy.retryQueuedSyncs();

      // Build final result
      final finalResult = _buildFinalResult(pushResult, pullCount, retryCount);

      _updateState(SyncState.completed(finalResult));
      return finalResult;
    } catch (e, stackTrace) {
      print('Sync error: $e\n$stackTrace');
      final errorResult = SyncResult.failure(
        message: e.toString(),
        error: e,
        timestamp: DateTime.now(),
      );
      _updateState(SyncState.error(e.toString()));
      return errorResult;
    } finally {
      _isSyncing = false;
    }
  }

  /// Start automatic retry timer (checks every 60 seconds)
  void startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      if (!_isSyncing && await _networkInfo.isConnected) {
        await _processRetryQueue();
      }
    });
  }

  /// Stop automatic retry timer
  void stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Process retry queue manually
  Future<void> _processRetryQueue() async {
    if (_syncQueue.length == 0) return;

    try {
      _updateState(const SyncState.syncing(phase: 'Processing retry queue'));
      final retryCount = await _pushStrategy.retryQueuedSyncs();
      if (retryCount > 0) {
        print('Successfully retried $retryCount entities');
      }
      _updateState(const SyncState.idle());
    } catch (e) {
      print('Error processing retry queue: $e');
      _updateState(const SyncState.idle());
    }
  }

  /// Get current athlete ID from storage
  Future<String> _getCurrentAthleteId() async {
    final userId = await _storage.getUserId();
    if (userId == null) {
      throw Exception('No authenticated user found');
    }
    return userId;
  }

  /// Build final sync result
  SyncResult _buildFinalResult(
    SyncResult pushResult,
    int pullCount,
    int retryCount,
  ) {
    return pushResult.when(
      success: (_, pushCount, timestamp) {
        return SyncResult.success(
          pullCount: pullCount,
          pushCount: pushCount + retryCount,
          timestamp: timestamp,
        );
      },
      partialSuccess: (_, pushSuccessCount, pushFailureCount, failures, timestamp) {
        return SyncResult.partialSuccess(
          pullCount: pullCount,
          pushSuccessCount: pushSuccessCount + retryCount,
          pushFailureCount: pushFailureCount,
          failures: failures,
          timestamp: timestamp,
        );
      },
      failure: (message, error, timestamp) {
        return SyncResult.failure(
          message: message,
          error: error,
          timestamp: timestamp,
        );
      },
    );
  }

  /// Update state and notify listeners
  void _updateState(SyncState state) {
    _currentState = state;
    _stateController.add(state);
  }

  /// Get sync queue length
  int get queueLength => _syncQueue.length;

  /// Clear sync queue (for testing/debugging)
  void clearQueue() => _syncQueue.clear();

  /// Dispose resources
  void dispose() {
    stopRetryTimer();
    _stateController.close();
  }
}
```

### 2. Update sync providers
Update `lib/src/providers/sync_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sync/core/sync_manager.dart';
import '../sync/core/sync_queue.dart';
import '../sync/core/sync_state.dart';
import '../sync/strategies/pull_strategy.dart';
import '../sync/strategies/push_strategy.dart';
import 'network_providers.dart';
import 'database_providers.dart';

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue();
});

final pullStrategyProvider = Provider<PullStrategy>((ref) {
  return PullStrategy(
    ref.watch(syncApiServiceProvider),
    ref.watch(networkInfoProvider),
    ref.watch(entityRegistryProvider),
  );
});

final pushStrategyProvider = Provider<PushStrategy>((ref) {
  return PushStrategy(
    ref.watch(syncApiServiceProvider),
    ref.watch(networkInfoProvider),
    ref.watch(syncQueueProvider),
    ref.watch(entityRegistryProvider),
  );
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  final manager = SyncManager(
    ref.watch(pullStrategyProvider),
    ref.watch(pushStrategyProvider),
    ref.watch(syncQueueProvider),
    ref.watch(networkInfoProvider),
    ref.watch(secureStorageProvider),
  );

  // Start retry timer
  manager.startRetryTimer();

  // Dispose on cleanup
  ref.onDispose(() => manager.dispose());

  return manager;
});

final syncStateProvider = StreamProvider<SyncState>((ref) {
  final manager = ref.watch(syncManagerProvider);
  return manager.state;
});
```

### 3. Create auto-sync on connectivity change
Create `lib/src/sync/core/auto_sync_service.dart`:
```dart
import 'dart:async';
import '../../core/network/network_info.dart';
import 'sync_manager.dart';

/// Service that automatically triggers sync when connectivity is restored
class AutoSyncService {
  final SyncManager _syncManager;
  final NetworkInfo _networkInfo;
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline = false;

  AutoSyncService(this._syncManager, this._networkInfo);

  /// Start listening to connectivity changes
  void start() {
    _connectivitySubscription = _networkInfo.connectivityStream.listen((isConnected) {
      if (isConnected && _wasOffline) {
        // Connection restored, trigger sync
        print('Connection restored, triggering auto-sync');
        _syncManager.sync();
      }
      _wasOffline = !isConnected;
    });
  }

  /// Stop listening to connectivity changes
  void stop() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
```

### 4. Add auto-sync provider
Add to `lib/src/providers/sync_providers.dart`:
```dart
import '../sync/core/auto_sync_service.dart';

final autoSyncServiceProvider = Provider<AutoSyncService>((ref) {
  final service = AutoSyncService(
    ref.watch(syncManagerProvider),
    ref.watch(networkInfoProvider),
  );

  // Start auto-sync
  service.start();

  // Stop on cleanup
  ref.onDispose(() => service.stop());

  return service;
});
```

### 5. Create SyncManager tests
Create `test/sync/sync_manager_test.dart`:
```dart
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
    mockPullStrategy = MockPullStrategy();
    mockPushStrategy = MockPushStrategy();
    mockSyncQueue = MockSyncQueue();
    mockNetworkInfo = MockNetworkInfo();
    mockStorage = MockSecureStorageService();

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
      expect(states.any((s) => s is _Syncing), isTrue);
      expect(states.last, isA<_Completed>());

      await subscription.cancel();
    });
  });
}
```

## Success Criteria
- ✅ SyncManager orchestrates PULL → PUSH → RETRY flow
- ✅ State management with StreamController
- ✅ Automatic retry timer implemented
- ✅ AutoSyncService for connectivity changes
- ✅ Sync providers with proper disposal
- ✅ Unit tests pass
- ✅ No compilation errors

## Estimated Time
2 hours

## Next Step
10-authentication.md - Implement offline-first authentication with password hash
