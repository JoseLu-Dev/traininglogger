import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/generated/domain/models/set_plan.dart';
import '../helpers/database_helper.dart';

void main() {
  late AppDatabase db;
  late SetPlanDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.setPlanDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('SetPlanDao', () {
    test('create and find by id', () async {
      final entity = SetPlan.create(
        athleteId: 'test-athleteId',
        exercisePlanId: 'test-exercisePlanId',
        setNumber: 1,
        targetReps: 1,
        targetWeight: 70.5,
        targetRpe: 70.5,
        notes: 'test-notes',
      );

      await dao.create(entity);
      final found = await dao.findById(entity.id);

      expect(found, isNotNull);
      expect(found!.id, equals(entity.id));
      expect(found.isDirty, isTrue);
    });

    test('mark dirty sets isDirty flag', () async {
      final entity = SetPlan.create(
        athleteId: 'test-athleteId',
        exercisePlanId: 'test-exercisePlanId',
        setNumber: 1,
        targetReps: 1,
        targetWeight: 70.5,
        targetRpe: 70.5,
        notes: 'test-notes',
      );

      await dao.create(entity);
      await dao.clearDirty(entity.id, DateTime.now());

      var found = await dao.findById(entity.id);
      expect(found!.isDirty, isFalse);

      await dao.markDirty(entity.id);
      found = await dao.findById(entity.id);
      expect(found!.isDirty, isTrue);
    });

    test('soft delete sets deletedAt', () async {
      final entity = SetPlan.create(
        athleteId: 'test-athleteId',
        exercisePlanId: 'test-exercisePlanId',
        setNumber: 1,
        targetReps: 1,
        targetWeight: 70.5,
        targetRpe: 70.5,
        notes: 'test-notes',
      );

      await dao.create(entity);
      await dao.softDelete(entity.id);

      final found = await dao.findById(entity.id);
      expect(found!.deletedAt, isNotNull);
      expect(found.isDirty, isTrue);
    });
  });
}
