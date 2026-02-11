import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/generated/domain/models/training_plan.dart';
import '../integration/integration_test_helper.dart';

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
