import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/generated/domain/models/training_plan.dart';
import '../helpers/database_helper.dart';

void main() {
  late AppDatabase db;
  late TrainingPlanDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.trainingPlanDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('TrainingPlanDao - Basic CRUD', () {
    test('create and find by id', () async {
      final entity = TrainingPlan.create(
        athleteId: 'test-athleteId',
        name: 'test-name',
        date: DateTime(2025, 1, 15),
        isLocked: true,
      );

      await dao.create(entity);
      final found = await dao.findById(entity.id);

      expect(found, isNotNull);
      expect(found!.id, equals(entity.id));
      expect(found.athleteId, equals('test-athleteId'));
      expect(found.name, equals('test-name'));
      expect(found.isLocked, isTrue);
      expect(found.isDirty, isTrue);
    });

    test('create with default isLocked=false', () async {
      final entity = TrainingPlan.create(
        athleteId: 'test-athleteId',
        name: 'test-name',
        date: DateTime(2025, 1, 15),
      );

      await dao.create(entity);
      final found = await dao.findById(entity.id);

      expect(found, isNotNull);
      expect(found!.isLocked, isFalse);
    });

    test('findById returns null for non-existent id', () async {
      final found = await dao.findById('non-existent');
      expect(found, isNull);
    });

    test('findAllActive returns only non-deleted entities', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 2',
        date: DateTime(2025, 1, 16),
      );

      await dao.create(entity1);
      await dao.create(entity2);
      await dao.softDelete(entity1.id);

      final active = await dao.findAllActive();
      expect(active.length, equals(1));
      expect(active[0].id, equals(entity2.id));
    });
  });

  group('TrainingPlanDao - Sync Operations', () {
    test('mark dirty sets isDirty flag', () async {
      final entity = TrainingPlan.create(
        athleteId: 'test-athleteId',
        name: 'test-name',
        date: DateTime(2025, 1, 15),
        isLocked: true,
      );

      await dao.create(entity);
      await dao.clearDirty(entity.id, DateTime.now());

      var found = await dao.findById(entity.id);
      expect(found!.isDirty, isFalse);

      await dao.markDirty(entity.id);
      found = await dao.findById(entity.id);
      expect(found!.isDirty, isTrue);
    });

    test('clearDirty clears flag and sets lastSyncedAt', () async {
      final entity = TrainingPlan.create(
        athleteId: 'test-athleteId',
        name: 'test-name',
        date: DateTime(2025, 1, 15),
      );

      await dao.create(entity);
      final syncTime = DateTime.now();
      await dao.clearDirty(entity.id, syncTime);

      final found = await dao.findById(entity.id);
      expect(found!.isDirty, isFalse);
      expect(found.lastSyncedAt, isNotNull);
    });

    test('findAllDirty returns only dirty entities', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 2',
        date: DateTime(2025, 1, 16),
      );

      await dao.create(entity1);
      await dao.create(entity2);
      await dao.clearDirty(entity1.id, DateTime.now());

      final dirty = await dao.findAllDirty();
      expect(dirty.length, equals(1));
      expect(dirty[0].id, equals(entity2.id));
    });

    test('soft delete sets deletedAt and marks dirty', () async {
      final entity = TrainingPlan.create(
        athleteId: 'test-athleteId',
        name: 'test-name',
        date: DateTime(2025, 1, 15),
        isLocked: true,
      );

      await dao.create(entity);
      await dao.clearDirty(entity.id, DateTime.now());

      var found = await dao.findById(entity.id);
      expect(found!.isDirty, isFalse);

      await dao.softDelete(entity.id);

      found = await dao.findById(entity.id);
      expect(found!.deletedAt, isNotNull);
      expect(found.isDirty, isTrue);
    });

    test('upsertFromServer inserts new entity', () async {
      final now = DateTime.now();
      final data = TrainingPlanData(
        id: 'server-id',
        athleteId: 'athlete-1',
        name: 'Server Plan',
        date: DateTime(2025, 1, 15),
        isLocked: false,
        createdAt: now,
        updatedAt: now,
        version: 1,
        deletedAt: null,
        isDirty: false,
        lastSyncedAt: now,
      );

      await dao.upsertFromServer(data);
      final found = await dao.findById('server-id');

      expect(found, isNotNull);
      expect(found!.name, equals('Server Plan'));
      expect(found.isDirty, isFalse);
    });

    test('upsertFromServer updates existing entity', () async {
      final entity = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Original Name',
        date: DateTime(2025, 1, 15),
      );

      await dao.create(entity);

      final now = DateTime.now();
      final updated = TrainingPlanData(
        id: entity.id,
        athleteId: entity.athleteId,
        name: 'Updated Name',
        date: entity.date,
        isLocked: true,
        createdAt: entity.createdAt,
        updatedAt: now,
        version: 2,
        deletedAt: null,
        isDirty: false,
        lastSyncedAt: now,
      );

      await dao.upsertFromServer(updated);
      final found = await dao.findById(entity.id);

      expect(found, isNotNull);
      expect(found!.name, equals('Updated Name'));
      expect(found.isLocked, isTrue);
      expect(found.version, equals(2));
      expect(found.isDirty, isFalse);
    });
  });

  group('TrainingPlanDao - Custom Queries', () {
    test('findByAthleteId returns only entities for specific athlete', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-2',
        name: 'Plan 2',
        date: DateTime(2025, 1, 16),
      );
      final entity3 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 3',
        date: DateTime(2025, 1, 17),
      );

      await dao.create(entity1);
      await dao.create(entity2);
      await dao.create(entity3);

      final plans = await dao.findByAthleteId('athlete-1');
      expect(plans.length, equals(2));
      expect(plans.every((p) => p.athleteId == 'athlete-1'), isTrue);
    });

    test('findByAthleteId orders by date descending', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Old Plan',
        date: DateTime(2025, 1, 10),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'New Plan',
        date: DateTime(2025, 1, 20),
      );

      await dao.create(entity1);
      await dao.create(entity2);

      final plans = await dao.findByAthleteId('athlete-1');
      expect(plans.length, equals(2));
      expect(plans[0].name, equals('New Plan'));
      expect(plans[1].name, equals('Old Plan'));
    });

    test('findByAthleteId excludes deleted entities', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 2',
        date: DateTime(2025, 1, 16),
      );

      await dao.create(entity1);
      await dao.create(entity2);
      await dao.softDelete(entity1.id);

      final plans = await dao.findByAthleteId('athlete-1');
      expect(plans.length, equals(1));
      expect(plans[0].id, equals(entity2.id));
    });

    test('findByAthleteBetweenDates returns entities in date range', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Before',
        date: DateTime(2025, 1, 5),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'In Range 1',
        date: DateTime(2025, 1, 10),
      );
      final entity3 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'In Range 2',
        date: DateTime(2025, 1, 15),
      );
      final entity4 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'After',
        date: DateTime(2025, 1, 25),
      );

      await dao.create(entity1);
      await dao.create(entity2);
      await dao.create(entity3);
      await dao.create(entity4);

      final plans = await dao.findByAthleteBetweenDates(
        'athlete-1',
        DateTime(2025, 1, 10),
        DateTime(2025, 1, 20),
      );

      expect(plans.length, equals(2));
      expect(plans.any((p) => p.name == 'In Range 1'), isTrue);
      expect(plans.any((p) => p.name == 'In Range 2'), isTrue);
    });

    test('findByAthleteBetweenDates filters by athlete', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-2',
        name: 'Plan 2',
        date: DateTime(2025, 1, 15),
      );

      await dao.create(entity1);
      await dao.create(entity2);

      final plans = await dao.findByAthleteBetweenDates(
        'athlete-1',
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31),
      );

      expect(plans.length, equals(1));
      expect(plans[0].athleteId, equals('athlete-1'));
    });

    test('findByAthleteBetweenDates excludes deleted entities', () async {
      final entity1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15),
      );
      final entity2 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 2',
        date: DateTime(2025, 1, 16),
      );

      await dao.create(entity1);
      await dao.create(entity2);
      await dao.softDelete(entity1.id);

      final plans = await dao.findByAthleteBetweenDates(
        'athlete-1',
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31),
      );

      expect(plans.length, equals(1));
      expect(plans[0].id, equals(entity2.id));
    });
  });

  group('TrainingPlanDao - Domain Conversion', () {
    test('toDomain converts data class to domain model', () async {
      final entity = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15),
        isLocked: true,
      );

      await dao.create(entity);
      final data = await dao.findById(entity.id);

      final domain = dao.toDomain(data!);

      expect(domain.id, equals(entity.id));
      expect(domain.athleteId, equals('athlete-1'));
      expect(domain.name, equals('Test Plan'));
      expect(domain.isLocked, isTrue);
      expect(domain.isDirty, isTrue);
    });
  });

  group('TrainingPlan Domain Model', () {
    test('create factory initializes all fields', () {
      final plan = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15),
        isLocked: true,
      );

      expect(plan.id, isNotEmpty);
      expect(plan.athleteId, equals('athlete-1'));
      expect(plan.name, equals('Test Plan'));
      expect(plan.isLocked, isTrue);
      expect(plan.version, equals(1));
      expect(plan.isDirty, isTrue);
      expect(plan.deletedAt, isNull);
    });

    test('markDirty sets isDirty to true', () {
      final plan = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15),
      );

      final clean = plan.copyWith(isDirty: false);
      expect(clean.isDirty, isFalse);

      final dirty = clean.markDirty();
      expect(dirty.isDirty, isTrue);
    });

    test('softDelete sets deletedAt and marks dirty', () {
      final plan = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15),
      );

      final clean = plan.copyWith(isDirty: false);
      final deleted = clean.softDelete();

      expect(deleted.deletedAt, isNotNull);
      expect(deleted.isDirty, isTrue);
    });
  });
}
