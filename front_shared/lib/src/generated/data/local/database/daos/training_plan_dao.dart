import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/training_plans_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/training_plan.dart';

part 'training_plan_dao.g.dart';

@DriftAccessor(tables: [TrainingPlans])
class TrainingPlanDao extends BaseDao<TrainingPlans, TrainingPlanData>
    with _$TrainingPlanDaoMixin {
  TrainingPlanDao(AppDatabase db) : super(db);

  @override
  TableInfo<TrainingPlans, TrainingPlanData> get table => trainingPlans;

  @override
  Future<TrainingPlanData?> findById(String id) {
    return (select(trainingPlans)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<TrainingPlanData>> findAllActive() {
    return (select(trainingPlans)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<TrainingPlanData>> findAllDirty() {
    return (select(trainingPlans)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(trainingPlans)..where((t) => t.id.equals(id))).write(
      TrainingPlansCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(trainingPlans)..where((t) => t.id.equals(id))).write(
      TrainingPlansCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(TrainingPlanData entity) async {
    await into(trainingPlans).insertOnConflictUpdate(
      entity.copyWith(
        lastSyncedAt: Value(DateTime.now()),
        isDirty: const Value(false),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(trainingPlans)..where((t) => t.id.equals(id))).write(
      TrainingPlansCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<TrainingPlanData>> findByAthleteId(String athleteId) {
    return (select(table)
          ..where((t) => t.athleteId.equals(athleteId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TrainingPlanData>> findByAthleteBetweenDates(String athleteId, String start, String end) {
    return (select(table)
          ..where((t) => t.athleteId.equals(athleteId) & t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }


  Future<String> create(TrainingPlan entity) async {
    await into(trainingPlans).insert(
      TrainingPlansCompanion.insert(
        id: Value(entity.id),
        athleteId: entity.athleteId,
        name: entity.name,
        date: entity.date,
        isLocked: Value(entity.isLocked),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  TrainingPlan toDomain(TrainingPlanData data) {
    return TrainingPlan(
      id: data.id,
      athleteId: data.athleteId,
      name: data.name,
      date: data.date,
      isLocked: data.isLocked,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      version: data.version ?? 0,
      deletedAt: data.deletedAt,
      isDirty: data.isDirty ?? false,
      lastSyncedAt: data.lastSyncedAt ?? DateTime.now(),
    );
  }
}
