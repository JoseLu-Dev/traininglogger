import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/exercise_plan_variants_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/exercise_plan_variant.dart';

part 'exercise_plan_variant_dao.g.dart';

@DriftAccessor(tables: [ExercisePlanVariants])
class ExercisePlanVariantDao extends BaseDao<ExercisePlanVariants, ExercisePlanVariantData>
    with _$ExercisePlanVariantDaoMixin {
  ExercisePlanVariantDao(AppDatabase db) : super(db);

  @override
  TableInfo<ExercisePlanVariants, ExercisePlanVariantData> get table => exercisePlanVariants;

  @override
  Future<ExercisePlanVariantData?> findById(String id) {
    return (select(exercisePlanVariants)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<ExercisePlanVariantData>> findAllActive() {
    return (select(exercisePlanVariants)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<ExercisePlanVariantData>> findAllDirty() {
    return (select(exercisePlanVariants)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(exercisePlanVariants)..where((t) => t.id.equals(id))).write(
      ExercisePlanVariantsCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(exercisePlanVariants)..where((t) => t.id.equals(id))).write(
      ExercisePlanVariantsCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(ExercisePlanVariantData entity) async {
    await into(exercisePlanVariants).insertOnConflictUpdate(
      entity.copyWith(
        lastSyncedAt: Value(DateTime.now()),
        isDirty: const Value(false),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(exercisePlanVariants)..where((t) => t.id.equals(id))).write(
      ExercisePlanVariantsCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ExercisePlanVariantData>> findByExercisePlanId(String exercisePlanId) {
    return (select(table)
          ..where((t) => t.exercisePlanId.equals(exercisePlanId) & t.deletedAt.isNull())
          )
        .get();
  }

  Future<List<ExercisePlanVariantData>> findByVariantId(String variantId) {
    return (select(table)
          ..where((t) => t.variantId.equals(variantId) & t.deletedAt.isNull())
          )
        .get();
  }


  Future<String> create(ExercisePlanVariant entity) async {
    await into(exercisePlanVariants).insert(
      ExercisePlanVariantsCompanion.insert(
        id: Value(entity.id),
        athleteId: entity.athleteId,
        exercisePlanId: entity.exercisePlanId,
        variantId: entity.variantId,
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  ExercisePlanVariant toDomain(ExercisePlanVariantData data) {
    return ExercisePlanVariant(
      id: data.id,
      athleteId: data.athleteId,
      exercisePlanId: data.exercisePlanId,
      variantId: data.variantId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      version: data.version ?? 0,
      deletedAt: data.deletedAt,
      isDirty: data.isDirty ?? false,
      lastSyncedAt: data.lastSyncedAt ?? DateTime.now(),
    );
  }
}
