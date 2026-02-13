import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/set_sessions_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/set_session.dart';

part 'set_session_dao.g.dart';

@DriftAccessor(tables: [SetSessions])
class SetSessionDao extends BaseDao<SetSessions, SetSessionData>
    with _$SetSessionDaoMixin {
  SetSessionDao(AppDatabase db) : super(db);

  @override
  TableInfo<SetSessions, SetSessionData> get table => setSessions;

  @override
  Future<SetSessionData?> findById(String id) {
    return (select(setSessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<SetSessionData>> findAllActive() {
    return (select(setSessions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<SetSessionData>> findAllDirty() {
    return (select(setSessions)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(setSessions)..where((t) => t.id.equals(id))).write(
      SetSessionsCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(setSessions)..where((t) => t.id.equals(id))).write(
      SetSessionsCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(SetSessionData entity) async {
    await into(setSessions).insertOnConflictUpdate(entity);
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(setSessions)..where((t) => t.id.equals(id))).write(
      SetSessionsCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<SetSessionData>> findByExerciseSessionId(String exerciseSessionId) {
    return (select(table)
          ..where((t) => t.exerciseSessionId.equals(exerciseSessionId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
        .get();
  }


  Future<String> create(SetSession entity) async {
    await into(setSessions).insert(
      SetSessionsCompanion.insert(
        id: Value(entity.id),
        exerciseSessionId: entity.exerciseSessionId,
        setPlanId: Value(entity.setPlanId),
        setNumber: Value(entity.setNumber),
        actualReps: entity.actualReps,
        actualWeight: entity.actualWeight,
        actualRpe: Value(entity.actualRpe),
        notes: Value(entity.notes),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  SetSession toDomain(SetSessionData data) {
    return SetSession(
      id: data.id,
      exerciseSessionId: data.exerciseSessionId,
      setPlanId: data.setPlanId,
      setNumber: data.setNumber,
      actualReps: data.actualReps,
      actualWeight: data.actualWeight,
      actualRpe: data.actualRpe,
      notes: data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      version: data.version ?? 0,
      deletedAt: data.deletedAt,
      isDirty: data.isDirty ?? false,
      lastSyncedAt: data.lastSyncedAt ?? DateTime.now(),
    );
  }
}
