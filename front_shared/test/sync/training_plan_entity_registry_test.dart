import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';
import 'package:front_shared/src/sync/core/entity_registry_setup.dart';
import 'package:front_shared/src/generated/domain/models/training_plan.dart';
import 'package:front_shared/src/generated/data/local/database/tables/training_plans_table.dart';
import '../helpers/database_helper.dart';

void main() {
  late AppDatabase db;
  late EntityRegistry registry;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    db = createTestDatabase();
    registry = EntityRegistry();
    setupEntityRegistry(registry, db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TrainingPlan Entity Registry Integration', () {
    test('TrainingPlan is registered in registry', () {
      expect(registry.isRegistered('TrainingPlan'), isTrue);
    });

    test('can get TrainingPlan DAO from registry', () {
      final dao = registry.getDao('TrainingPlan');
      expect(dao, isNotNull);
    });

    test('serialize converts TrainingPlanData to JSON', () async {
      final entity = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15).toIso8601String(),
      );

      await db.trainingPlanDao.create(entity);
      final data = await db.trainingPlanDao.findById(entity.id);

      final json = registry.serialize('TrainingPlan', data!);

      expect(json, isNotNull);
      expect(json!['id'], equals(entity.id));
      expect(json['name'], equals('Test Plan'));
      expect(json['athleteId'], equals('athlete-1'));
      expect(json['isDirty'], isTrue);
    });

    test('deserialize converts JSON to TrainingPlanData', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'athleteId': 'athlete-1',
        'name': 'Test Plan',
        'date': DateTime(2025, 1, 15).toIso8601String(),
        'isLocked': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'version': 1,
        'deletedAt': null,
        'isDirty': true,
        'lastSyncedAt': null,
      };

      final data = registry.deserialize<TrainingPlanData>('TrainingPlan', json);

      expect(data, isNotNull);
      expect(data!.id, equals('test-id'));
      expect(data.name, equals('Test Plan'));
      expect(data.athleteId, equals('athlete-1'));
      expect(data.isDirty, isTrue);
    });

    test('getAllDirtyEntities returns TrainingPlan entities', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15).toIso8601String(),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 2',
        date: DateTime(2025, 1, 16).toIso8601String(),
      );

      await db.trainingPlanDao.create(entity1);
      await db.trainingPlanDao.create(entity2);
      await db.trainingPlanDao.clearDirty(entity1.id, DateTime.now());

      final allDirty = await registry.getAllDirtyEntities();

      expect(allDirty.length, equals(1));
      expect(allDirty[0]['_type'], equals('TrainingPlan'));
      expect(allDirty[0]['id'], equals(entity2.id));
    });

    test('can access DAO methods directly', () async {
      final entity = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15).toIso8601String(),
      );

      final dao = registry.getDao('TrainingPlan');
      expect(dao, isNotNull);

      await db.trainingPlanDao.create(entity);
      await db.trainingPlanDao.clearDirty(entity.id, DateTime.now());

      var found = await db.trainingPlanDao.findById(entity.id);
      expect(found!.isDirty, isFalse);

      await dao!.markDirty(entity.id);

      found = await db.trainingPlanDao.findById(entity.id);
      expect(found!.isDirty, isTrue);
    });

    test('toDomain converts data to domain model via registry', () async {
      final entity = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15).toIso8601String(),
        isLocked: true,
      );

      await db.trainingPlanDao.create(entity);
      final data = await db.trainingPlanDao.findById(entity.id);

      final domain = registry.toDomain('TrainingPlan', data!);

      expect(domain, isA<TrainingPlan>());
      final plan = domain as TrainingPlan;
      expect(plan.id, equals(entity.id));
      expect(plan.name, equals('Test Plan'));
      expect(plan.isLocked, isTrue);
    });
  });

  group('EntityRegistry - API Coverage', () {
    test('registeredEntityTypes returns list of registered entities', () {
      final types = registry.registeredEntityTypes;
      expect(types, contains('TrainingPlan'));
      expect(types.length, equals(12)); // Now we have 12 entities registered
    });

    test('can check if entity type is registered', () {
      expect(registry.isRegistered('TrainingPlan'), isTrue);
      expect(registry.isRegistered('Exercise'), isTrue); // Exercise is now registered
      expect(registry.isRegistered('NonExistent'), isFalse);
    });

    test('getTypedDao returns correctly typed DAO', () {
      final dao = registry.getTypedDao<TrainingPlans, TrainingPlanData>('TrainingPlan');
      expect(dao, isNotNull);
      expect(dao, equals(db.trainingPlanDao));
    });

    test('getAllDirtyEntities handles multiple dirty entities', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15).toIso8601String(),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-2',
        name: 'Plan 2',
        date: DateTime(2025, 1, 16).toIso8601String(),
      );
      final entity3 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 3',
        date: DateTime(2025, 1, 17).toIso8601String(),
      );

      await db.trainingPlanDao.create(entity1);
      await db.trainingPlanDao.create(entity2);
      await db.trainingPlanDao.create(entity3);
      await db.trainingPlanDao.clearDirty(entity1.id, DateTime.now());

      final allDirty = await registry.getAllDirtyEntities();

      expect(allDirty.length, equals(2));
      expect(allDirty.every((e) => e['_type'] == 'TrainingPlan'), isTrue);

      final dirtyIds = allDirty.map((e) => e['id']).toList();
      expect(dirtyIds, contains(entity2.id));
      expect(dirtyIds, contains(entity3.id));
      expect(dirtyIds, isNot(contains(entity1.id)));
    });
  });
}
