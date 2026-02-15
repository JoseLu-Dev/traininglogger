import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/exercise_plans_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/exercise_plan.dart';

part 'exercise_plan_dao.g.dart';

@DriftAccessor(tables: [ExercisePlans])
class ExercisePlanDao extends BaseDao<ExercisePlans, ExercisePlanData>
    with _$ExercisePlanDaoMixin {
  ExercisePlanDao(AppDatabase db) : super(db);

  @override
  TableInfo<ExercisePlans, ExercisePlanData> get table => exercisePlans;

  @override
  Future<ExercisePlanData?> findById(String id) {
    return (select(exercisePlans)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<ExercisePlanData>> findAllActive() {
    return (select(exercisePlans)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<ExercisePlanData>> findAllDirty() {
    return (select(exercisePlans)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(exercisePlans)..where((t) => t.id.equals(id))).write(
      ExercisePlansCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(exercisePlans)..where((t) => t.id.equals(id))).write(
      ExercisePlansCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(ExercisePlanData entity) async {
    await into(exercisePlans).insertOnConflictUpdate(
      entity.copyWith(
        lastSyncedAt: Value(DateTime.now()),
        isDirty: const Value(false),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(exercisePlans)..where((t) => t.id.equals(id))).write(
      ExercisePlansCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ExercisePlanData>> findByTrainingPlanId(String trainingPlanId) {
    return (select(table)
          ..where((t) => t.trainingPlanId.equals(trainingPlanId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }


  Future<String> create(ExercisePlan entity) async {
    await into(exercisePlans).insert(
      ExercisePlansCompanion.insert(
        id: Value(entity.id),
        athleteId: entity.athleteId,
        trainingPlanId: entity.trainingPlanId,
        exerciseId: entity.exerciseId,
        orderIndex: entity.orderIndex,
        notes: Value(entity.notes),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  ExercisePlan toDomain(ExercisePlanData data) {
    return ExercisePlan(
      id: data.id,
      athleteId: data.athleteId,
      trainingPlanId: data.trainingPlanId,
      exerciseId: data.exerciseId,
      orderIndex: data.orderIndex,
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
