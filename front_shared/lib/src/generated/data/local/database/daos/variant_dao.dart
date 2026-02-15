import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/variants_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/variant.dart';

part 'variant_dao.g.dart';

@DriftAccessor(tables: [Variants])
class VariantDao extends BaseDao<Variants, VariantData>
    with _$VariantDaoMixin {
  VariantDao(AppDatabase db) : super(db);

  @override
  TableInfo<Variants, VariantData> get table => variants;

  @override
  Future<VariantData?> findById(String id) {
    return (select(variants)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<VariantData>> findAllActive() {
    return (select(variants)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<VariantData>> findAllDirty() {
    return (select(variants)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(variants)..where((t) => t.id.equals(id))).write(
      VariantsCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(variants)..where((t) => t.id.equals(id))).write(
      VariantsCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(VariantData entity) async {
    await into(variants).insertOnConflictUpdate(
      entity.copyWith(
        lastSyncedAt: Value(DateTime.now()),
        isDirty: const Value(false),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(variants)..where((t) => t.id.equals(id))).write(
      VariantsCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<VariantData?> findByName(String name) {
    return (select(table)
          ..where((t) => t.name.equals(name) & t.deletedAt.isNull())
          )
        .getSingleOrNull();
  }


  Future<String> create(Variant entity) async {
    await into(variants).insert(
      VariantsCompanion.insert(
        id: Value(entity.id),
        coachId: entity.coachId,
        name: entity.name,
        description: Value(entity.description),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  Variant toDomain(VariantData data) {
    return Variant(
      id: data.id,
      coachId: data.coachId,
      name: data.name,
      description: data.description,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      version: data.version ?? 0,
      deletedAt: data.deletedAt,
      isDirty: data.isDirty ?? false,
      lastSyncedAt: data.lastSyncedAt ?? DateTime.now(),
    );
  }
}
