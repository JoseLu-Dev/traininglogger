import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/exercises_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/exercise.dart';

part 'exercise_dao.g.dart';

@DriftAccessor(tables: [Exercises])
class ExerciseDao extends BaseDao<Exercises, ExerciseData>
    with _$ExerciseDaoMixin {
  ExerciseDao(AppDatabase db) : super(db);

  @override
  TableInfo<Exercises, ExerciseData> get table => exercises;

  @override
  Future<ExerciseData?> findById(String id) {
    return (select(exercises)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<ExerciseData>> findAllActive() {
    return (select(exercises)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<ExerciseData>> findAllDirty() {
    return (select(exercises)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(ExerciseData entity) async {
    await into(exercises).insertOnConflictUpdate(
      entity.copyWith(
        lastSyncedAt: Value(DateTime.now()),
        isDirty: const Value(false),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<ExerciseData?> findByName(String name) {
    return (select(table)
          ..where((t) => t.name.equals(name) & t.deletedAt.isNull())
          )
        .getSingleOrNull();
  }

  Future<List<ExerciseData>> findByCategory(String category) {
    return (select(table)
          ..where((t) => t.category.equals(category) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }


  Future<String> create(Exercise entity) async {
    await into(exercises).insert(
      ExercisesCompanion.insert(
        id: Value(entity.id),
        coachId: entity.coachId,
        name: entity.name,
        description: Value(entity.description),
        category: Value(entity.category),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  Exercise toDomain(ExerciseData data) {
    return Exercise(
      id: data.id,
      coachId: data.coachId,
      name: data.name,
      description: data.description,
      category: data.category,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      version: data.version ?? 0,
      deletedAt: data.deletedAt,
      isDirty: data.isDirty ?? false,
      lastSyncedAt: data.lastSyncedAt ?? DateTime.now(),
    );
  }
}
