import 'package:flutter_test/flutter_test.dart';
import '../../helpers/database_helper.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase', () {
    test('database can be created', () {
      expect(db, isNotNull);
    });

    test('database has correct schema version', () {
      expect(db.schemaVersion, equals(1));
    });

    test('database migration strategy is configured', () {
      expect(db.migration, isNotNull);
      expect(db.migration.onCreate, isNotNull);
      expect(db.migration.onUpgrade, isNotNull);
    });

    test('all tables are accessible', () {
      // Verify that all expected tables exist in the database
      expect(db.bodyWeightEntries, isNotNull);
      expect(db.exercisePlanVariants, isNotNull);
      expect(db.exercisePlans, isNotNull);
      expect(db.exerciseSessionVariants, isNotNull);
      expect(db.exerciseSessions, isNotNull);
      expect(db.exercises, isNotNull);
      expect(db.setPlans, isNotNull);
      expect(db.setSessions, isNotNull);
      expect(db.trainingPlans, isNotNull);
      expect(db.trainingSessions, isNotNull);
      expect(db.users, isNotNull);
      expect(db.variants, isNotNull);
    });

    test('all DAOs are accessible', () {
      // Verify that all expected DAOs exist
      expect(db.bodyWeightEntryDao, isNotNull);
      expect(db.exercisePlanVariantDao, isNotNull);
      expect(db.exercisePlanDao, isNotNull);
      expect(db.exerciseSessionVariantDao, isNotNull);
      expect(db.exerciseSessionDao, isNotNull);
      expect(db.exerciseDao, isNotNull);
      expect(db.setPlanDao, isNotNull);
      expect(db.setSessionDao, isNotNull);
      expect(db.trainingPlanDao, isNotNull);
      expect(db.trainingSessionDao, isNotNull);
      expect(db.userDao, isNotNull);
      expect(db.variantDao, isNotNull);
    });

    test('database can be closed and reopened', () async {
      final firstDb = createTestDatabase();
      expect(firstDb, isNotNull);
      await firstDb.close();

      final secondDb = createTestDatabase();
      expect(secondDb, isNotNull);
      await secondDb.close();
    });

    test('multiple database instances can coexist', () {
      final db1 = createTestDatabase();
      final db2 = createTestDatabase();

      expect(db1, isNotNull);
      expect(db2, isNotNull);
      expect(db1, isNot(equals(db2)));

      db1.close();
      db2.close();
    });
  });

  group('AppDatabase tables', () {
    test('bodyWeightEntries table exists', () async {
      final query = db.select(db.bodyWeightEntries);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('exercisePlanVariants table exists', () async {
      final query = db.select(db.exercisePlanVariants);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('exercisePlans table exists', () async {
      final query = db.select(db.exercisePlans);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('exerciseSessionVariants table exists', () async {
      final query = db.select(db.exerciseSessionVariants);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('exerciseSessions table exists', () async {
      final query = db.select(db.exerciseSessions);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('exercises table exists', () async {
      final query = db.select(db.exercises);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('setPlans table exists', () async {
      final query = db.select(db.setPlans);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('setSessions table exists', () async {
      final query = db.select(db.setSessions);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('trainingPlans table exists', () async {
      final query = db.select(db.trainingPlans);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('trainingSessions table exists', () async {
      final query = db.select(db.trainingSessions);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('users table exists', () async {
      final query = db.select(db.users);
      final results = await query.get();
      expect(results, isEmpty);
    });

    test('variants table exists', () async {
      final query = db.select(db.variants);
      final results = await query.get();
      expect(results, isEmpty);
    });
  });
}
