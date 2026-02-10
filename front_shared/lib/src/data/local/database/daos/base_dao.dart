import 'package:drift/drift.dart';
import '../app_database.dart';

abstract class BaseDao<T extends Table, D> extends DatabaseAccessor<AppDatabase> {
  BaseDao(AppDatabase db) : super(db);

  TableInfo<T, D> get table;

  Future<D?> findById(String id);
  Future<List<D>> findAllActive();
  Future<List<D>> findAllDirty();
  Future<void> markDirty(String id);
  Future<void> clearDirty(String id, DateTime syncedAt);
  Future<void> upsertFromServer(D entity);
  Future<void> softDelete(String id);
}
