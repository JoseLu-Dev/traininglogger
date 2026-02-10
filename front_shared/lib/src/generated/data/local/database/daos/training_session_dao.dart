import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/training_sessions_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/training_session.dart';

part 'training_session_dao.g.dart';

@DriftAccessor(tables: [TrainingSessions])
class TrainingSessionDao extends BaseDao<TrainingSessions, TrainingSessionData>
    with _$TrainingSessionDaoMixin {
  TrainingSessionDao(AppDatabase db) : super(db);

  @override
  TableInfo<TrainingSessions, TrainingSessionData> get table => trainingSessions;

  @override
  Future<TrainingSessionData?> findById(String id) {
    return (select(trainingSessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<TrainingSessionData>> findAllActive() {
    return (select(trainingSessions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<TrainingSessionData>> findAllDirty() {
    return (select(trainingSessions)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(trainingSessions)..where((t) => t.id.equals(id))).write(
      TrainingSessionsCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(trainingSessions)..where((t) => t.id.equals(id))).write(
      TrainingSessionsCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(TrainingSessionData entity) async {
    await into(trainingSessions).insertOnConflictUpdate(entity);
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(trainingSessions)..where((t) => t.id.equals(id))).write(
      TrainingSessionsCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<TrainingSessionData>> findByTrainingPlanId(String trainingPlanId) {
    return (select(table)
          ..where((t) => t.trainingPlanId.equals(trainingPlanId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  Future<List<TrainingSessionData>> findByAthleteId(String athleteId) {
    return (select(table)
          ..where((t) => t.athleteId.equals(athleteId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }


  Future<String> create(TrainingSession entity) async {
    await into(trainingSessions).insert(
      TrainingSessionsCompanion.insert(
        id: Value(entity.id),
        trainingPlanId: entity.trainingPlanId,
        athleteId: entity.athleteId,
        startTime: entity.startTime,
        endTime: Value(entity.endTime),
        notes: Value(entity.notes),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  TrainingSession toDomain(TrainingSessionData data) {
    return TrainingSession(
      id: data.id,
      trainingPlanId: data.trainingPlanId,
      athleteId: data.athleteId,
      startTime: data.startTime,
      endTime: data.endTime,
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
