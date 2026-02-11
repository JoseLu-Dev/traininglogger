import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/generated/domain/models/training_plan.dart';
import 'package:front_shared/src/data/remote/sync_api_service.dart';
import 'package:front_shared/src/data/remote/dto/sync_dtos.dart';
import 'package:front_shared/src/core/network/network_info.dart';
import 'package:front_shared/src/data/local/secure_storage/secure_storage_service.dart';
import 'integration_test_helper.dart';

@GenerateMocks([SyncApiService, NetworkInfo, SecureStorageService])
import 'sync_flow_test.mocks.dart';

void main() {
  late IntegrationTestHelper helper;
  late MockSyncApiService mockApi;
  late MockNetworkInfo mockNetworkInfo;
  late MockSecureStorageService mockStorage;

  setUp(() async {
    helper = IntegrationTestHelper();
    await helper.setUp();

    mockApi = MockSyncApiService();
    mockNetworkInfo = MockNetworkInfo();
    mockStorage = MockSecureStorageService();

    when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(mockStorage.getUserId()).thenAnswer((_) async => 'athlete-1');
  });

  tearDown(() async {
    await helper.tearDown();
  });

  group('End-to-End Sync Flow', () {
    test('create → sync → verify clean state', () async {
      // Create a training plan
      final plan = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15),
      );

      await helper.db.trainingPlanDao.create(plan);

      // Verify it's dirty
      var found = await helper.db.trainingPlanDao.findById(plan.id);
      expect(found, isNotNull);
      expect(found!.isDirty, isTrue);

      // Mock API responses
      when(mockApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => SyncPullResponseDto(
            entities: {},
            syncTimestamp: DateTime.now(),
            totalEntities: 0,
          ));

      when(mockApi.push(any)).thenAnswer((_) async => SyncPushResponseDto(
            successCount: 1,
            failureCount: 0,
            failures: [],
            syncTimestamp: DateTime.now(),
          ));

      // Execute sync
      final syncManager = helper.createSyncManager(
        mockApi: mockApi,
        mockNetworkInfo: mockNetworkInfo,
        mockStorage: mockStorage,
      );

      final result = await syncManager.sync(athleteId: 'athlete-1');

      // Verify result
      result.when(
        success: (pullCount, pushCount, timestamp) {
          expect(pushCount, equals(1));
        },
        partialSuccess: (_, __, ___, ____, _____) => fail('Expected success'),
        failure: (_, __, ___) => fail('Expected success'),
      );

      // Verify entity is no longer dirty
      found = await helper.db.trainingPlanDao.findById(plan.id);
      expect(found!.isDirty, isFalse);
      expect(found.lastSyncedAt, isNotNull);

      syncManager.dispose();
    });

    test('pull merges server changes into local DB', () async {
      // Mock server returning an entity
      final serverPlan = {
        'id': 'server-plan-1',
        'athleteId': 'athlete-1',
        'name': 'Server Plan',
        'date': DateTime(2025, 1, 20).toIso8601String(),
        'isLocked': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'version': 1,
        'isDirty': false,
        'lastSyncedAt': DateTime.now().toIso8601String(),
      };

      when(mockApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => SyncPullResponseDto(
            entities: {
              'TrainingPlan': [serverPlan],
            },
            syncTimestamp: DateTime.now(),
            totalEntities: 1,
          ));

      when(mockApi.push(any)).thenAnswer((_) async => SyncPushResponseDto(
            successCount: 0,
            failureCount: 0,
            failures: [],
            syncTimestamp: DateTime.now(),
          ));

      // Execute sync
      final syncManager = helper.createSyncManager(
        mockApi: mockApi,
        mockNetworkInfo: mockNetworkInfo,
        mockStorage: mockStorage,
      );

      await syncManager.sync(athleteId: 'athlete-1');

      // Verify entity was merged into local DB
      final found = await helper.db.trainingPlanDao.findById('server-plan-1');
      expect(found, isNotNull);
      expect(found!.name, equals('Server Plan'));
      expect(found.isDirty, isFalse);

      syncManager.dispose();
    });

    test('conflict resolution: client wins when local is dirty', () async {
      // Create a local dirty entity
      final localPlan = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Local Version',
        date: DateTime(2025, 1, 15),
      );
      final fixedId = 'conflict-plan-1';
      final planWithId = localPlan.copyWith(id: fixedId);

      await helper.db.trainingPlanDao.create(planWithId);

      // Mock server returning same entity with different data
      final serverPlan = {
        'id': fixedId,
        'athleteId': 'athlete-1',
        'name': 'Server Version',
        'date': DateTime(2025, 1, 15).toIso8601String(),
        'isLocked': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'version': 1,
        'isDirty': false,
        'lastSyncedAt': DateTime.now().toIso8601String(),
      };

      when(mockApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => SyncPullResponseDto(
            entities: {
              'TrainingPlan': [serverPlan],
            },
            syncTimestamp: DateTime.now(),
            totalEntities: 1,
          ));

      when(mockApi.push(any)).thenAnswer((_) async => SyncPushResponseDto(
            successCount: 1,
            failureCount: 0,
            failures: [],
            syncTimestamp: DateTime.now(),
          ));

      // Execute sync (pull then push)
      final syncManager = helper.createSyncManager(
        mockApi: mockApi,
        mockNetworkInfo: mockNetworkInfo,
        mockStorage: mockStorage,
      );

      await syncManager.sync(athleteId: 'athlete-1');

      // Verify local version was kept (client wins) and pushed successfully
      final found = await helper.db.trainingPlanDao.findById(fixedId);
      expect(found, isNotNull);
      expect(found!.name, equals('Local Version')); // Local version preserved
      expect(found.isDirty, isFalse); // Now clean after successful push

      syncManager.dispose();
    });

    test('partial sync failure queues entities for retry', () async {
      // Create two plans
      final plan1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15),
      );
      final plan2 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 2',
        date: DateTime(2025, 1, 16),
      );

      await helper.db.trainingPlanDao.create(plan1);
      await helper.db.trainingPlanDao.create(plan2);

      // Mock API: one succeeds, one fails
      when(mockApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => SyncPullResponseDto(
            entities: {},
            syncTimestamp: DateTime.now(),
            totalEntities: 0,
          ));

      when(mockApi.push(any)).thenAnswer((_) async => SyncPushResponseDto(
            successCount: 1,
            failureCount: 1,
            failures: [
              EntityFailure(
                entityType: 'TrainingPlan',
                entityId: plan2.id,
                errors: [
                  const ValidationError(field: 'name', code: 'TOO_SHORT', message: 'Name too short'),
                ],
              ),
            ],
            syncTimestamp: DateTime.now(),
          ));

      // Execute sync
      final syncManager = helper.createSyncManager(
        mockApi: mockApi,
        mockNetworkInfo: mockNetworkInfo,
        mockStorage: mockStorage,
      );

      final result = await syncManager.sync(athleteId: 'athlete-1');

      // Verify partial success
      result.when(
        success: (_, __, ___) => fail('Expected partial success'),
        partialSuccess: (pullCount, pushSuccessCount, pushFailureCount, failures, timestamp) {
          expect(pushSuccessCount, equals(1));
          expect(pushFailureCount, equals(1));
          expect(failures.length, equals(1));
          expect(failures.first.entityId, equals(plan2.id));
        },
        failure: (_, __, ___) => fail('Expected partial success'),
      );

      // Verify plan1 is clean, plan2 is still dirty
      final found1 = await helper.db.trainingPlanDao.findById(plan1.id);
      expect(found1!.isDirty, isFalse);

      final found2 = await helper.db.trainingPlanDao.findById(plan2.id);
      expect(found2!.isDirty, isTrue);

      // Verify plan2 is in retry queue
      expect(syncManager.queueLength, equals(1));

      syncManager.dispose();
    });
  });
}
