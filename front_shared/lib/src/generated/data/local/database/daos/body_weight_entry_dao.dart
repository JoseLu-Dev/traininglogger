import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/body_weight_entries_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/body_weight_entry.dart';

part 'body_weight_entry_dao.g.dart';

@DriftAccessor(tables: [BodyWeightEntries])
class BodyWeightEntryDao extends BaseDao<BodyWeightEntries, BodyWeightEntryData>
    with _$BodyWeightEntryDaoMixin {
  BodyWeightEntryDao(AppDatabase db) : super(db);

  @override
  TableInfo<BodyWeightEntries, BodyWeightEntryData> get table => bodyWeightEntries;

  @override
  Future<BodyWeightEntryData?> findById(String id) {
    return (select(bodyWeightEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<BodyWeightEntryData>> findAllActive() {
    return (select(bodyWeightEntries)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<BodyWeightEntryData>> findAllDirty() {
    return (select(bodyWeightEntries)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(bodyWeightEntries)..where((t) => t.id.equals(id))).write(
      BodyWeightEntriesCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(bodyWeightEntries)..where((t) => t.id.equals(id))).write(
      BodyWeightEntriesCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(BodyWeightEntryData entity) async {
    await into(bodyWeightEntries).insertOnConflictUpdate(entity);
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(bodyWeightEntries)..where((t) => t.id.equals(id))).write(
      BodyWeightEntriesCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<BodyWeightEntryData>> findByAthleteId(String athleteId) {
    return (select(table)
          ..where((t) => t.athleteId.equals(athleteId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.measurementDate)]))
        .get();
  }

  Future<List<BodyWeightEntryData>> findByAthleteBetweenDates(String athleteId, DateTime start, DateTime end) {
    return (select(table)
          ..where((t) => t.athleteId.equals(athleteId) & t.measurementDate.isBiggerOrEqualValue(start) & t.measurementDate.isSmallerOrEqualValue(end) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.measurementDate)]))
        .get();
  }


  Future<String> create(BodyWeightEntry entity) async {
    await into(bodyWeightEntries).insert(
      BodyWeightEntriesCompanion.insert(
        id: Value(entity.id),
        athleteId: entity.athleteId,
        weight: entity.weight,
        measurementDate: entity.measurementDate,
        notes: Value(entity.notes),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  BodyWeightEntry toDomain(BodyWeightEntryData data) {
    return BodyWeightEntry(
      id: data.id,
      athleteId: data.athleteId,
      weight: data.weight,
      measurementDate: data.measurementDate,
      notes: data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      version: data.version,
      deletedAt: data.deletedAt,
      isDirty: data.isDirty,
      lastSyncedAt: data.lastSyncedAt,
    );
  }
}
