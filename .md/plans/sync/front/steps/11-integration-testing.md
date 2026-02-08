# Step 11: Integration Testing

## Goal
Create comprehensive end-to-end integration tests to verify the complete sync flow.

## Tasks

### 1. Create integration test helper
Create `test/integration/integration_test_helper.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';
import 'package:front_shared/src/sync/core/entity_registry_setup.dart';
import 'package:front_shared/src/sync/core/sync_manager.dart';
import 'package:front_shared/src/sync/strategies/pull_strategy.dart';
import 'package:front_shared/src/sync/strategies/push_strategy.dart';
import 'package:front_shared/src/sync/core/sync_queue.dart';
import 'package:drift/native.dart';
import '../helpers/database_helper.dart';

/// Helper class for integration tests
class IntegrationTestHelper {
  late AppDatabase db;
  late EntityRegistry registry;
  late SyncQueue syncQueue;

  Future<void> setUp() async {
    db = createTestDatabase();
    registry = EntityRegistry();
    setupEntityRegistry(registry, db);
    syncQueue = SyncQueue();
  }

  Future<void> tearDown() async {
    await db.close();
  }

  /// Create a sync manager with mock API
  SyncManager createSyncManager({
    required MockSyncApiService mockApi,
    required MockNetworkInfo mockNetworkInfo,
    required MockSecureStorageService mockStorage,
  }) {
    final pullStrategy = PullStrategy(mockApi, mockNetworkInfo, registry);
    final pushStrategy = PushStrategy(mockApi, mockNetworkInfo, syncQueue, registry);

    return SyncManager(
      pullStrategy,
      pushStrategy,
      syncQueue,
      mockNetworkInfo,
      mockStorage,
    );
  }
}
```

### 2. Create end-to-end sync test
Create `test/integration/sync_flow_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/domain/models/training_plan.dart';
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
        since: anyNamed('since'),
        athleteId: anyNamed('athleteId'),
        entityTypes: anyNamed('entityTypes'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => SyncPullResponseDto(
            changesByType: {},
            syncTimestamp: DateTime.now(),
            stats: {},
          ));

      when(mockApi.push(any)).thenAnswer((_) async => SyncPushResponseDto(
            succeeded: [
              SyncSuccessDto(
                entityType: 'TrainingPlan',
                entityId: plan.id,
                entity: {
                  'id': plan.id,
                  'athleteId': plan.athleteId,
                  'name': plan.name,
                  'date': plan.date.toIso8601String(),
                  'isLocked': plan.isLocked,
                  'createdAt': plan.createdAt.toIso8601String(),
                  'updatedAt': plan.updatedAt.toIso8601String(),
                  'version': plan.version,
                  'isDirty': false,
                  'lastSyncedAt': DateTime.now().toIso8601String(),
                },
              ),
            ],
            failed: [],
            summary: const SyncSummary(succeeded: 1, failed: 0),
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
        since: anyNamed('since'),
        athleteId: anyNamed('athleteId'),
        entityTypes: anyNamed('entityTypes'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => SyncPullResponseDto(
            changesByType: {
              'TrainingPlan': [serverPlan],
            },
            syncTimestamp: DateTime.now(),
            stats: {
              'TrainingPlan': const EntityStats(count: 1, hasMore: false),
            },
          ));

      when(mockApi.push(any)).thenAnswer((_) async => SyncPushResponseDto(
            succeeded: [],
            failed: [],
            summary: const SyncSummary(succeeded: 0, failed: 0),
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
        since: anyNamed('since'),
        athleteId: anyNamed('athleteId'),
        entityTypes: anyNamed('entityTypes'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => SyncPullResponseDto(
            changesByType: {
              'TrainingPlan': [serverPlan],
            },
            syncTimestamp: DateTime.now(),
            stats: {},
          ));

      when(mockApi.push(any)).thenAnswer((_) async => SyncPushResponseDto(
            succeeded: [],
            failed: [],
            summary: const SyncSummary(succeeded: 0, failed: 0),
          ));

      // Execute pull
      final syncManager = helper.createSyncManager(
        mockApi: mockApi,
        mockNetworkInfo: mockNetworkInfo,
        mockStorage: mockStorage,
      );

      await syncManager.sync(athleteId: 'athlete-1');

      // Verify local version was kept (client wins)
      final found = await helper.db.trainingPlanDao.findById(fixedId);
      expect(found, isNotNull);
      expect(found!.name, equals('Local Version')); // Local version preserved
      expect(found.isDirty, isTrue); // Still dirty

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
        since: anyNamed('since'),
        athleteId: anyNamed('athleteId'),
        entityTypes: anyNamed('entityTypes'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => SyncPullResponseDto(
            changesByType: {},
            syncTimestamp: DateTime.now(),
            stats: {},
          ));

      when(mockApi.push(any)).thenAnswer((_) async => SyncPushResponseDto(
            succeeded: [
              SyncSuccessDto(
                entityType: 'TrainingPlan',
                entityId: plan1.id,
                entity: {
                  'id': plan1.id,
                  'athleteId': plan1.athleteId,
                  'name': plan1.name,
                  'date': plan1.date.toIso8601String(),
                  'isLocked': plan1.isLocked,
                  'createdAt': plan1.createdAt.toIso8601String(),
                  'updatedAt': plan1.updatedAt.toIso8601String(),
                  'version': plan1.version,
                  'isDirty': false,
                  'lastSyncedAt': DateTime.now().toIso8601String(),
                },
              ),
            ],
            failed: [
              SyncFailureDto(
                entityType: 'TrainingPlan',
                entityId: plan2.id,
                errors: [
                  const ValidationError(field: 'name', message: 'Name too short'),
                ],
              ),
            ],
            summary: const SyncSummary(succeeded: 1, failed: 1),
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
```

### 3. Create performance test
Create `test/integration/performance_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:front_shared/src/domain/models/training_plan.dart';
import '../integration/integration_test_helper.dart';
import '../integration/sync_flow_test.mocks.dart';

void main() {
  late IntegrationTestHelper helper;

  setUp(() async {
    helper = IntegrationTestHelper();
    await helper.setUp();
  });

  tearDown(() async {
    await helper.tearDown();
  });

  group('Performance Tests', () {
    test('create 100 entities in under 5 seconds', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        final plan = TrainingPlan.create(
          athleteId: 'athlete-1',
          name: 'Plan $i',
          date: DateTime(2025, 1, i % 28 + 1),
        );
        await helper.db.trainingPlanDao.create(plan);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      print('Created 100 entities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('find all dirty entities in under 1 second', () async {
      // Create 100 entities
      for (int i = 0; i < 100; i++) {
        final plan = TrainingPlan.create(
          athleteId: 'athlete-1',
          name: 'Plan $i',
          date: DateTime(2025, 1, i % 28 + 1),
        );
        await helper.db.trainingPlanDao.create(plan);
      }

      final stopwatch = Stopwatch()..start();

      final dirty = await helper.registry.getAllDirtyEntities();

      stopwatch.stop();

      expect(dirty.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      print('Found ${dirty.length} dirty entities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('query by athlete and date range in under 100ms', () async {
      // Create 100 entities
      for (int i = 0; i < 100; i++) {
        final plan = TrainingPlan.create(
          athleteId: i % 5 == 0 ? 'athlete-1' : 'athlete-2',
          name: 'Plan $i',
          date: DateTime(2025, 1, i % 28 + 1),
        );
        await helper.db.trainingPlanDao.create(plan);
      }

      final stopwatch = Stopwatch()..start();

      final results = await helper.db.trainingPlanDao.findByAthleteBetweenDates(
        'athlete-1',
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31),
      );

      stopwatch.stop();

      expect(results.isNotEmpty, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      print('Queried ${results.length} entities in ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
```

### 4. Run all tests
```bash
cd front_shared
flutter test
```

## Success Criteria
- ✅ Integration test helper created
- ✅ End-to-end sync flow tests pass
- ✅ Conflict resolution tests pass
- ✅ Partial sync failure tests pass
- ✅ Performance tests meet requirements:
  - 100 entities created in <5s
  - Find all dirty in <1s
  - Query by athlete in <100ms

## Estimated Time
2-3 hours

## Next Step
12-remaining-entities.md - Extend pattern to 11 remaining entities
