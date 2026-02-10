import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/generated/domain/models/body_weight_entry.dart';
import '../helpers/database_helper.dart';

void main() {
  late AppDatabase db;
  late BodyWeightEntryDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.bodyWeightEntryDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('BodyWeightEntryDao', () {
    test('create and find by id', () async {
      final entity = BodyWeightEntry.create(
        athleteId: 'test-athleteId',
        weight: 70.5,
        measurementDate: DateTime(2025, 1, 15),
        notes: 'test-notes',
      );

      await dao.create(entity);
      final found = await dao.findById(entity.id);

      expect(found, isNotNull);
      expect(found!.id, equals(entity.id));
      expect(found.isDirty, isTrue);
    });

    test('mark dirty sets isDirty flag', () async {
      final entity = BodyWeightEntry.create(
        athleteId: 'test-athleteId',
        weight: 70.5,
        measurementDate: DateTime(2025, 1, 15),
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
      final entity = BodyWeightEntry.create(
        athleteId: 'test-athleteId',
        weight: 70.5,
        measurementDate: DateTime(2025, 1, 15),
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
