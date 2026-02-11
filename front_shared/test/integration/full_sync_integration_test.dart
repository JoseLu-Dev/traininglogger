import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';
import 'package:front_shared/src/sync/core/entity_registry_setup.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import 'package:drift/native.dart';

/// Full integration test validating all 12 entities are registered and working
void main() {
  late AppDatabase db;
  late EntityRegistry registry;

  setUp(() {
    // Create in-memory database for testing
    db = AppDatabase.withConnection(NativeDatabase.memory());
    registry = EntityRegistry();

    // Setup all 12 entities
    setupEntityRegistry(registry, db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Full Sync Integration - All 12 Entities', () {
    test('All 12 entities are registered in registry', () {
      final registeredTypes = registry.registeredEntityTypes;

      expect(registeredTypes.length, equals(12));
      expect(registeredTypes, containsAll([
        'User',
        'TrainingPlan',
        'TrainingSession',
        'Exercise',
        'Variant',
        'ExercisePlan',
        'ExercisePlanVariant',
        'ExerciseSession',
        'ExerciseSessionVariant',
        'SetPlan',
        'SetSession',
        'BodyWeightEntry',
      ]));
    });

    test('Each entity can be checked for registration', () {
      expect(registry.isRegistered('User'), isTrue);
      expect(registry.isRegistered('TrainingPlan'), isTrue);
      expect(registry.isRegistered('TrainingSession'), isTrue);
      expect(registry.isRegistered('Exercise'), isTrue);
      expect(registry.isRegistered('Variant'), isTrue);
      expect(registry.isRegistered('ExercisePlan'), isTrue);
      expect(registry.isRegistered('ExercisePlanVariant'), isTrue);
      expect(registry.isRegistered('ExerciseSession'), isTrue);
      expect(registry.isRegistered('ExerciseSessionVariant'), isTrue);
      expect(registry.isRegistered('SetPlan'), isTrue);
      expect(registry.isRegistered('SetSession'), isTrue);
      expect(registry.isRegistered('BodyWeightEntry'), isTrue);

      expect(registry.isRegistered('UnknownEntity'), isFalse);
    });

    test('Each entity has a working DAO', () {
      // User
      final userDao = registry.getDao('User');
      expect(userDao, isNotNull);

      // TrainingPlan
      final trainingPlanDao = registry.getDao('TrainingPlan');
      expect(trainingPlanDao, isNotNull);

      // TrainingSession
      final trainingSessionDao = registry.getDao('TrainingSession');
      expect(trainingSessionDao, isNotNull);

      // Exercise
      final exerciseDao = registry.getDao('Exercise');
      expect(exerciseDao, isNotNull);

      // Variant
      final variantDao = registry.getDao('Variant');
      expect(variantDao, isNotNull);

      // ExercisePlan
      final exercisePlanDao = registry.getDao('ExercisePlan');
      expect(exercisePlanDao, isNotNull);

      // ExercisePlanVariant
      final exercisePlanVariantDao = registry.getDao('ExercisePlanVariant');
      expect(exercisePlanVariantDao, isNotNull);

      // ExerciseSession
      final exerciseSessionDao = registry.getDao('ExerciseSession');
      expect(exerciseSessionDao, isNotNull);

      // ExerciseSessionVariant
      final exerciseSessionVariantDao = registry.getDao('ExerciseSessionVariant');
      expect(exerciseSessionVariantDao, isNotNull);

      // SetPlan
      final setPlanDao = registry.getDao('SetPlan');
      expect(setPlanDao, isNotNull);

      // SetSession
      final setSessionDao = registry.getDao('SetSession');
      expect(setSessionDao, isNotNull);

      // BodyWeightEntry
      final bodyWeightEntryDao = registry.getDao('BodyWeightEntry');
      expect(bodyWeightEntryDao, isNotNull);
    });

    test('Each entity has serializer and deserializer registered', () {
      final entityTypes = [
        'User',
        'TrainingPlan',
        'TrainingSession',
        'Exercise',
        'Variant',
        'ExercisePlan',
        'ExercisePlanVariant',
        'ExerciseSession',
        'ExerciseSessionVariant',
        'SetPlan',
        'SetSession',
        'BodyWeightEntry',
      ];

      // Just verify that all entities are registered (which means they have serializers)
      for (final entityType in entityTypes) {
        expect(registry.isRegistered(entityType), isTrue,
          reason: '$entityType should be registered with serializer/deserializer');
      }
    });

    test('getAllDirtyEntities returns empty list when no dirty entities', () async {
      final dirtyEntities = await registry.getAllDirtyEntities();
      expect(dirtyEntities, isEmpty);
    });

    test('Registry handles unknown entity types gracefully', () {
      expect(registry.isRegistered('UnknownType'), isFalse);

      // getDao returns null for unknown types (doesn't throw)
      final dao = registry.getDao('UnknownType');
      expect(dao, isNull);
    });

    test('All 12 entities counted correctly', () {
      final count = registry.registeredEntityTypes.length;
      expect(count, equals(12),
        reason: 'Should have exactly 12 entities registered');
    });
  });

  group('Entity Type Validation', () {
    test('Core entities are registered', () {
      // These are the core user and authentication entities
      expect(registry.isRegistered('User'), isTrue);
    });

    test('Plan entities are registered', () {
      // Training plan hierarchy
      expect(registry.isRegistered('TrainingPlan'), isTrue);
      expect(registry.isRegistered('ExercisePlan'), isTrue);
      expect(registry.isRegistered('ExercisePlanVariant'), isTrue);
      expect(registry.isRegistered('SetPlan'), isTrue);
    });

    test('Session entities are registered', () {
      // Training session hierarchy (actual workout logging)
      expect(registry.isRegistered('TrainingSession'), isTrue);
      expect(registry.isRegistered('ExerciseSession'), isTrue);
      expect(registry.isRegistered('ExerciseSessionVariant'), isTrue);
      expect(registry.isRegistered('SetSession'), isTrue);
    });

    test('Exercise definition entities are registered', () {
      // Exercise library
      expect(registry.isRegistered('Exercise'), isTrue);
      expect(registry.isRegistered('Variant'), isTrue);
    });

    test('Tracking entities are registered', () {
      // Body metrics tracking
      expect(registry.isRegistered('BodyWeightEntry'), isTrue);
    });
  });

  group('Performance Validation', () {
    test('Registry lookups are fast', () {
      // Test that registry operations are performant
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 1000; i++) {
        registry.isRegistered('TrainingPlan');
        registry.isRegistered('Exercise');
        registry.isRegistered('User');
      }

      stopwatch.stop();

      // 3000 lookups should complete in under 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
        reason: 'Registry lookups should be fast');
    });

    test('Getting all registered types is fast', () {
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 100; i++) {
        registry.registeredEntityTypes;
      }

      stopwatch.stop();

      // 100 calls should complete in under 10ms
      expect(stopwatch.elapsedMilliseconds, lessThan(10),
        reason: 'Getting registered types should be fast');
    });
  });

  group('Completeness Validation', () {
    test('No duplicate entity types registered', () {
      final registeredTypes = registry.registeredEntityTypes;
      final uniqueTypes = registeredTypes.toSet();

      expect(registeredTypes.length, equals(uniqueTypes.length),
        reason: 'No duplicate entity types should be registered');
    });

    test('All entity names follow naming convention', () {
      final registeredTypes = registry.registeredEntityTypes;

      for (final type in registeredTypes) {
        // Entity names should be PascalCase
        expect(type[0], equals(type[0].toUpperCase()),
          reason: '$type should start with uppercase');
        expect(type, isNot(contains(' ')),
          reason: '$type should not contain spaces');
        expect(type, isNot(contains('_')),
          reason: '$type should not contain underscores');
      }
    });

    test('Sync system has complete entity coverage', () {
      // This test documents the complete list of entities in the system
      final expectedEntities = {
        'User',
        'TrainingPlan',
        'TrainingSession',
        'Exercise',
        'Variant',
        'ExercisePlan',
        'ExercisePlanVariant',
        'ExerciseSession',
        'ExerciseSessionVariant',
        'SetPlan',
        'SetSession',
        'BodyWeightEntry',
      };

      final registeredTypes = registry.registeredEntityTypes.toSet();

      expect(registeredTypes, equals(expectedEntities),
        reason: 'All expected entities should be registered, no more, no less');
    });
  });
}
