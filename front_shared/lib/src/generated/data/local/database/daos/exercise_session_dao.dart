import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/exercise_sessions_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/exercise_session.dart';

part 'exercise_session_dao.g.dart';

@DriftAccessor(tables: [ExerciseSessions])
class ExerciseSessionDao extends BaseDao<ExerciseSessions, ExerciseSessionData>
    with _$ExerciseSessionDaoMixin {
  ExerciseSessionDao(AppDatabase db) : super(db);

  @override
  TableInfo<ExerciseSessions, ExerciseSessionData> get table => exerciseSessions;

  @override
  Future<ExerciseSessionData?> findById(String id) {
    return (select(exerciseSessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<ExerciseSessionData>> findAllActive() {
    return (select(exerciseSessions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<ExerciseSessionData>> findAllDirty() {
    return (select(exerciseSessions)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(exerciseSessions)..where((t) => t.id.equals(id))).write(
      ExerciseSessionsCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(exerciseSessions)..where((t) => t.id.equals(id))).write(
      ExerciseSessionsCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(ExerciseSessionData entity) async {
    await into(exerciseSessions).insertOnConflictUpdate(entity);
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(exerciseSessions)..where((t) => t.id.equals(id))).write(
      ExerciseSessionsCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ExerciseSessionData>> findByTrainingSessionId(String trainingSessionId) {
    return (select(table)
          ..where((t) => t.trainingSessionId.equals(trainingSessionId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }


  Future<String> create(ExerciseSession entity) async {
    await into(exerciseSessions).insert(
      ExerciseSessionsCompanion.insert(
        id: Value(entity.id),
        trainingSessionId: entity.trainingSessionId,
        exercisePlanId: Value(entity.exercisePlanId),
        exerciseId: entity.exerciseId,
        orderIndex: entity.orderIndex,
        notes: Value(entity.notes),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  ExerciseSession toDomain(ExerciseSessionData data) {
    return ExerciseSession(
      id: data.id,
      trainingSessionId: data.trainingSessionId,
      exercisePlanId: data.exercisePlanId,
      exerciseId: data.exerciseId,
      orderIndex: data.orderIndex,
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
