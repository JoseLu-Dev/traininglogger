import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/sync/strategies/push_strategy.dart';
import 'package:front_shared/src/data/remote/sync_api_service.dart';
import 'package:front_shared/src/core/network/network_info.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';
import 'package:front_shared/src/sync/core/sync_queue.dart';
import 'package:front_shared/src/sync/core/sync_state.dart' as sync_state;
import 'package:front_shared/src/data/remote/dto/sync_dtos.dart' as dto;
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import 'package:front_shared/src/data/remote/api_client.dart';

@GenerateMocks([SyncApiService, NetworkInfo, SyncQueue, EntityRegistry, BaseDao])
import 'push_strategy_test.mocks.dart';

void main() {
  late PushStrategy pushStrategy;
  late MockSyncApiService mockSyncApi;
  late MockNetworkInfo mockNetworkInfo;
  late MockSyncQueue mockSyncQueue;
  late MockEntityRegistry mockRegistry;

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

    mockSyncApi = MockSyncApiService();
    mockNetworkInfo = MockNetworkInfo();
    mockSyncQueue = MockSyncQueue();
    mockRegistry = MockEntityRegistry();
    pushStrategy = PushStrategy(
      mockSyncApi,
      mockNetworkInfo,
      mockSyncQueue,
      mockRegistry,
    );
  });

  group('PushStrategy', () {
    test('throws NetworkException when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      expect(
        () => pushStrategy.execute(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('returns success with zero counts when no dirty entities', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRegistry.getAllDirtyEntities()).thenAnswer((_) async => []);

      // Act
      final result = await pushStrategy.execute();

      // Assert
      expect(result, isA<sync_state.SyncResult>());
      result.when(
        success: (pullCount, pushCount, timestamp) {
          expect(pullCount, 0);
          expect(pushCount, 0);
        },
        partialSuccess: (_, __, ___, ____, _____) {
          fail('Expected success, got partialSuccess');
        },
        failure: (_, __, ___) {
          fail('Expected success, got failure');
        },
      );

      verifyNever(mockSyncApi.push(any));
    });

    test('successfully pushes dirty entities', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final dirtyEntity = {
        '_type': 'TrainingPlan',
        'id': 'plan-1',
        'name': 'Test Plan',
        'athleteId': 'athlete-1',
        'coachId': 'coach-1',
        'isDirty': true,
        'lastSyncedAt': DateTime.now().toIso8601String(),
      };

      when(mockRegistry.getAllDirtyEntities())
          .thenAnswer((_) async => [dirtyEntity]);

      final mockDao = MockBaseDao();
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(mockDao);
      when(mockDao.clearDirty(any, any)).thenAnswer((_) async => {});

      final response = dto.SyncPushResponseDto(
        successCount: 1,
        failureCount: 0,
        failures: [],
        syncTimestamp: DateTime.now(),
      );

      when(mockSyncApi.push(any)).thenAnswer((_) async => response);

      // Act
      final result = await pushStrategy.execute();

      // Assert
      expect(result, isA<sync_state.SyncResult>());
      result.when(
        success: (pullCount, pushCount, timestamp) {
          expect(pullCount, 0);
          expect(pushCount, 1);
        },
        partialSuccess: (_, __, ___, ____, _____) {
          fail('Expected success, got partialSuccess');
        },
        failure: (_, __, ___) {
          fail('Expected success, got failure');
        },
      );

      verify(mockSyncApi.push(any)).called(1);
      verify(mockDao.clearDirty('plan-1', any)).called(1);
    });

    test('removes metadata fields before sending to server', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final dirtyEntity = {
        '_type': 'TrainingPlan',
        'id': 'plan-1',
        'name': 'Test Plan',
        'athleteId': 'athlete-1',
        'coachId': 'coach-1',
        'isDirty': true,
        'lastSyncedAt': DateTime.now().toIso8601String(),
      };

      when(mockRegistry.getAllDirtyEntities())
          .thenAnswer((_) async => [dirtyEntity]);

      final mockDao = MockBaseDao();
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(mockDao);
      when(mockDao.clearDirty(any, any)).thenAnswer((_) async => {});

      final response = dto.SyncPushResponseDto(
        successCount: 1,
        failureCount: 0,
        failures: [],
        syncTimestamp: DateTime.now(),
      );

      when(mockSyncApi.push(any)).thenAnswer((_) async => response);

      // Act
      await pushStrategy.execute();

      // Assert
      final captured = verify(mockSyncApi.push(captureAny)).captured.single
          as dto.SyncPushRequestDto;

      final sentEntity = captured.entities['TrainingPlan']!.first;
      expect(sentEntity.containsKey('_type'), false);
      expect(sentEntity.containsKey('isDirty'), false);
      expect(sentEntity.containsKey('lastSyncedAt'), false);
      expect(sentEntity['id'], 'plan-1');
      expect(sentEntity['name'], 'Test Plan');
    });

    test('handles partial failures by adding to retry queue', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final entity1 = {
        '_type': 'TrainingPlan',
        'id': 'plan-1',
        'name': 'Test Plan 1',
        'athleteId': 'athlete-1',
        'coachId': 'coach-1',
        'isDirty': true,
      };

      final entity2 = {
        '_type': 'TrainingPlan',
        'id': 'plan-2',
        'name': 'Test Plan 2',
        'athleteId': 'athlete-1',
        'coachId': 'coach-1',
        'isDirty': true,
      };

      when(mockRegistry.getAllDirtyEntities())
          .thenAnswer((_) async => [entity1, entity2]);

      final mockDao = MockBaseDao();
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(mockDao);
      when(mockDao.clearDirty(any, any)).thenAnswer((_) async => {});

      final response = dto.SyncPushResponseDto(
        successCount: 1,
        failureCount: 1,
        failures: [
          dto.EntityFailure(
            entityType: 'TrainingPlan',
            entityId: 'plan-2',
            errors: [
              dto.ValidationError(
                field: 'name',
                code: 'TOO_SHORT',
                message: 'Name is too short',
              ),
            ],
          ),
        ],
        syncTimestamp: DateTime.now(),
      );

      when(mockSyncApi.push(any)).thenAnswer((_) async => response);

      // Act
      final result = await pushStrategy.execute();

      // Assert
      expect(result, isA<sync_state.SyncResult>());
      result.when(
        success: (_, __, ___) {
          fail('Expected partialSuccess, got success');
        },
        partialSuccess: (pullCount, pushSuccessCount, pushFailureCount, failures, timestamp) {
          expect(pullCount, 0);
          expect(pushSuccessCount, 1);
          expect(pushFailureCount, 1);
          expect(failures.length, 1);
          expect(failures.first.entityId, 'plan-2');
          expect(failures.first.errors.first.message, 'Name is too short');
        },
        failure: (_, __, ___) {
          fail('Expected partialSuccess, got failure');
        },
      );

      // Verify successful entity was marked clean
      verify(mockDao.clearDirty('plan-1', any)).called(1);

      // Verify failed entity was NOT marked clean
      verifyNever(mockDao.clearDirty('plan-2', any));

      // Verify failed entity was added to retry queue
      verify(mockSyncQueue.enqueue(any)).called(1);
    });

    test('groups entities by type', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final planEntity = {
        '_type': 'TrainingPlan',
        'id': 'plan-1',
        'name': 'Test Plan',
        'isDirty': true,
      };

      final exerciseEntity = {
        '_type': 'Exercise',
        'id': 'exercise-1',
        'name': 'Test Exercise',
        'isDirty': true,
      };

      when(mockRegistry.getAllDirtyEntities())
          .thenAnswer((_) async => [planEntity, exerciseEntity]);

      final mockPlanDao = MockBaseDao();
      final mockExerciseDao = MockBaseDao();
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(mockPlanDao);
      when(mockRegistry.getDao('Exercise')).thenReturn(mockExerciseDao);
      when(mockPlanDao.clearDirty(any, any)).thenAnswer((_) async => {});
      when(mockExerciseDao.clearDirty(any, any)).thenAnswer((_) async => {});

      final response = dto.SyncPushResponseDto(
        successCount: 2,
        failureCount: 0,
        failures: [],
        syncTimestamp: DateTime.now(),
      );

      when(mockSyncApi.push(any)).thenAnswer((_) async => response);

      // Act
      await pushStrategy.execute();

      // Assert
      final captured = verify(mockSyncApi.push(captureAny)).captured.single
          as dto.SyncPushRequestDto;

      expect(captured.entities.containsKey('TrainingPlan'), true);
      expect(captured.entities.containsKey('Exercise'), true);
      expect(captured.entities['TrainingPlan']!.length, 1);
      expect(captured.entities['Exercise']!.length, 1);
    });
  });

  group('PushStrategy - retryQueuedSyncs', () {
    test('returns 0 when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await pushStrategy.retryQueuedSyncs();

      expect(result, 0);
      verifyNever(mockSyncQueue.getDueRetries());
    });

    test('returns 0 when no due retries', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockSyncQueue.getDueRetries()).thenReturn([]);

      final result = await pushStrategy.retryQueuedSyncs();

      expect(result, 0);
      verifyNever(mockSyncApi.push(any));
    });

    test('successfully retries and removes from queue', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final queuedSync = QueuedSync(
        id: 'queued-1',
        entityType: 'TrainingPlan',
        entityId: 'plan-1',
        data: {
          'id': 'plan-1',
          'name': 'Test Plan',
          '_type': 'TrainingPlan',
          'isDirty': true,
        },
        queuedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        retryCount: 1,
        nextRetryAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      when(mockSyncQueue.getDueRetries()).thenReturn([queuedSync]);

      final mockDao = MockBaseDao();
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(mockDao);
      when(mockDao.clearDirty(any, any)).thenAnswer((_) async => {});

      final response = dto.SyncPushResponseDto(
        successCount: 1,
        failureCount: 0,
        failures: [],
        syncTimestamp: DateTime.now(),
      );

      when(mockSyncApi.push(any)).thenAnswer((_) async => response);

      // Act
      final result = await pushStrategy.retryQueuedSyncs();

      // Assert
      expect(result, 1);
      verify(mockSyncQueue.remove('queued-1')).called(1);
      verify(mockDao.clearDirty('plan-1', any)).called(1);
    });

    test('increments retry count on failure if under max retries', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final queuedSync = QueuedSync(
        id: 'queued-1',
        entityType: 'TrainingPlan',
        entityId: 'plan-1',
        data: {
          'id': 'plan-1',
          'name': 'Test Plan',
          '_type': 'TrainingPlan',
        },
        queuedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        retryCount: 2,
        nextRetryAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      when(mockSyncQueue.getDueRetries()).thenReturn([queuedSync]);
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(MockBaseDao());

      final response = dto.SyncPushResponseDto(
        successCount: 0,
        failureCount: 1,
        failures: [
          dto.EntityFailure(
            entityType: 'TrainingPlan',
            entityId: 'plan-1',
            errors: [
              dto.ValidationError(
                field: 'name',
                code: 'INVALID',
                message: 'Invalid name',
              ),
            ],
          ),
        ],
        syncTimestamp: DateTime.now(),
      );

      when(mockSyncApi.push(any)).thenAnswer((_) async => response);

      // Act
      final result = await pushStrategy.retryQueuedSyncs();

      // Assert
      expect(result, 0);
      verify(mockSyncQueue.remove('queued-1')).called(1);

      // Verify the retry count was incremented
      final captured = verify(mockSyncQueue.enqueue(captureAny)).captured.single
          as QueuedSync;
      expect(captured.retryCount, 3);
    });

    test('removes from queue when max retries reached', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final queuedSync = QueuedSync(
        id: 'queued-1',
        entityType: 'TrainingPlan',
        entityId: 'plan-1',
        data: {
          'id': 'plan-1',
          'name': 'Test Plan',
          '_type': 'TrainingPlan',
        },
        queuedAt: DateTime.now().subtract(const Duration(hours: 1)),
        retryCount: 5, // At max retries
        nextRetryAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      when(mockSyncQueue.getDueRetries()).thenReturn([queuedSync]);
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(MockBaseDao());

      final response = dto.SyncPushResponseDto(
        successCount: 0,
        failureCount: 1,
        failures: [
          dto.EntityFailure(
            entityType: 'TrainingPlan',
            entityId: 'plan-1',
            errors: [
              dto.ValidationError(
                field: 'name',
                code: 'INVALID',
                message: 'Invalid name',
              ),
            ],
          ),
        ],
        syncTimestamp: DateTime.now(),
      );

      when(mockSyncApi.push(any)).thenAnswer((_) async => response);

      // Act
      final result = await pushStrategy.retryQueuedSyncs();

      // Assert
      expect(result, 0);
      verify(mockSyncQueue.remove('queued-1')).called(1);
      verifyNever(mockSyncQueue.enqueue(any)); // Should not re-queue
    });

    test('handles network errors gracefully and keeps items in queue', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final queuedSync = QueuedSync(
        id: 'queued-1',
        entityType: 'TrainingPlan',
        entityId: 'plan-1',
        data: {
          'id': 'plan-1',
          'name': 'Test Plan',
          '_type': 'TrainingPlan',
        },
        queuedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        retryCount: 1,
        nextRetryAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      when(mockSyncQueue.getDueRetries()).thenReturn([queuedSync]);
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(MockBaseDao());

      when(mockSyncApi.push(any))
          .thenThrow(NetworkException('Connection failed'));

      // Act
      final result = await pushStrategy.retryQueuedSyncs();

      // Assert
      expect(result, 0);
      verifyNever(mockSyncQueue.remove(any)); // Items stay in queue
    });
  });
}
