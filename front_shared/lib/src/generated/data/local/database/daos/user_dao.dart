import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import '../tables/users_table.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import '../../../../domain/models/user.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends BaseDao<Users, UserData>
    with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  @override
  TableInfo<Users, UserData> get table => users;

  @override
  Future<UserData?> findById(String id) {
    return (select(users)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<UserData>> findAllActive() {
    return (select(users)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<List<UserData>> findAllDirty() {
    return (select(users)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  @override
  Future<void> upsertFromServer(UserData entity) async {
    await into(users).insertOnConflictUpdate(
      entity.copyWith(
        lastSyncedAt: Value(DateTime.now()),
        isDirty: const Value(false),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    await (update(users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(
        deletedAt: Value(DateTime.now()),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<UserData?> findByEmail(String email) {
    return (select(table)
          ..where((t) => t.email.equals(email) & t.deletedAt.isNull())
          )
        .getSingleOrNull();
  }


  Future<String> create(User entity) async {
    await into(users).insert(
      UsersCompanion.insert(
        id: Value(entity.id),
        email: entity.email,
        name: entity.name,
        role: entity.role,
        coachId: Value(entity.coachId),
        isDirty: const Value(true),
      ),
    );
    return entity.id;
  }

  /// Convert Drift data class to domain model
  User toDomain(UserData data) {
    return User(
      id: data.id,
      email: data.email,
      name: data.name,
      role: data.role,
      coachId: data.coachId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      version: data.version ?? 0,
      deletedAt: data.deletedAt,
      isDirty: data.isDirty ?? false,
      lastSyncedAt: data.lastSyncedAt ?? DateTime.now(),
    );
  }
}
