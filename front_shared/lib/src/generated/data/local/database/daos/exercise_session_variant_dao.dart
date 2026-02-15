import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/exercise_session_variants_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/exercise_session_variant.dart';

part 'exercise_session_variant_dao.g.dart';

@DriftAccessor(tables: [ExerciseSessionVariants])
class ExerciseSessionVariantDao extends BaseDao<ExerciseSessionVariants, ExerciseSessionVariantData>
    with _$ExerciseSessionVariantDaoMixin {
  ExerciseSessionVariantDao(AppDatabase db) : super(db);

  @override
  TableInfo<ExerciseSessionVariants, ExerciseSessionVariantData> get table => exerciseSessionVariants;

  @override
  Future<ExerciseSessionVariantData?> findById(String id) {
    return (select(exerciseSessionVariants)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<ExerciseSessionVariantData>> findAllActive() {
    return (select(exerciseSessionVariants)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<ExerciseSessionVariantData>> findAllDirty() {
    return (select(exerciseSessionVariants)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(exerciseSessionVariants)..where((t) => t.id.equals(id))).write(
      ExerciseSessionVariantsCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(exerciseSessionVariants)..where((t) => t.id.equals(id))).write(
      ExerciseSessionVariantsCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(ExerciseSessionVariantData entity) async {
    await into(exerciseSessionVariants).insertOnConflictUpdate(
      entity.copyWith(
        lastSyncedAt: Value(DateTime.now()),
        isDirty: const Value(false),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(exerciseSessionVariants)..where((t) => t.id.equals(id))).write(
      ExerciseSessionVariantsCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ExerciseSessionVariantData>> findByExerciseSessionId(String exerciseSessionId) {
    return (select(table)
          ..where((t) => t.exerciseSessionId.equals(exerciseSessionId) & t.deletedAt.isNull())
          )
        .get();
  }

  Future<List<ExerciseSessionVariantData>> findByVariantId(String variantId) {
    return (select(table)
          ..where((t) => t.variantId.equals(variantId) & t.deletedAt.isNull())
          )
        .get();
  }


  Future<String> create(ExerciseSessionVariant entity) async {
    await into(exerciseSessionVariants).insert(
      ExerciseSessionVariantsCompanion.insert(
        id: Value(entity.id),
        athleteId: entity.athleteId,
        exerciseSessionId: entity.exerciseSessionId,
        variantId: entity.variantId,
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  ExerciseSessionVariant toDomain(ExerciseSessionVariantData data) {
    return ExerciseSessionVariant(
      id: data.id,
      athleteId: data.athleteId,
      exerciseSessionId: data.exerciseSessionId,
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
