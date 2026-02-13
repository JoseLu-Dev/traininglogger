import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/set_plans_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/set_plan.dart';

part 'set_plan_dao.g.dart';

@DriftAccessor(tables: [SetPlans])
class SetPlanDao extends BaseDao<SetPlans, SetPlanData>
    with _$SetPlanDaoMixin {
  SetPlanDao(AppDatabase db) : super(db);

  @override
  TableInfo<SetPlans, SetPlanData> get table => setPlans;

  @override
  Future<SetPlanData?> findById(String id) {
    return (select(setPlans)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<SetPlanData>> findAllActive() {
    return (select(setPlans)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<SetPlanData>> findAllDirty() {
    return (select(setPlans)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(setPlans)..where((t) => t.id.equals(id))).write(
      SetPlansCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(setPlans)..where((t) => t.id.equals(id))).write(
      SetPlansCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(SetPlanData entity) async {
    await into(setPlans).insertOnConflictUpdate(entity);
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(setPlans)..where((t) => t.id.equals(id))).write(
      SetPlansCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<SetPlanData>> findByExercisePlanId(String exercisePlanId) {
    return (select(table)
          ..where((t) => t.exercisePlanId.equals(exercisePlanId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
        .get();
  }


  Future<String> create(SetPlan entity) async {
    await into(setPlans).insert(
      SetPlansCompanion.insert(
        id: Value(entity.id),
        exercisePlanId: entity.exercisePlanId,
        setNumber: Value(entity.setNumber),
        targetReps: Value(entity.targetReps),
        targetWeight: Value(entity.targetWeight),
        targetRpe: Value(entity.targetRpe),
        notes: Value(entity.notes),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  SetPlan toDomain(SetPlanData data) {
    return SetPlan(
      id: data.id,
      exercisePlanId: data.exercisePlanId,
      setNumber: data.setNumber,
      targetReps: data.targetReps,
      targetWeight: data.targetWeight,
      targetRpe: data.targetRpe,
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
