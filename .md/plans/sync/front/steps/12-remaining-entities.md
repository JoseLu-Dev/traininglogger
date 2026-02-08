# Step 12: Remaining Entities

## Goal
Extend the TrainingPlan pattern to the 10 remaining entities using the established pattern.

## Entities to Implement

1. **User** - User profiles for both athletes and coaches (with role field)
2. **Exercise** - Exercise definitions (e.g., "Squat", "Bench Press")
3. **Variant** - Exercise variants (e.g., "Low Bar", "High Bar")
4. **ExercisePlan** - Planned exercises in a training plan
5. **SetPlan** - Planned sets for an exercise
6. **TrainingSession** - Actual training session record
7. **ExerciseSession** - Actual exercise performed in a session
8. **SetSession** - Actual set performed
9. **BodyWeightEntry** - Body weight measurements
10. **ExercisePlanVariant** (join) - Links variants to exercise plans
11. **ExerciseSessionVariant** (join) - Links variants to exercise sessions

## Pattern for Each Entity

Follow this checklist for each entity (1-2 hours each):

### 1. Domain Model
- [ ] Create `lib/src/domain/models/{entity_name}.dart`
- [ ] Implement `SyncableEntity` interface
- [ ] Use `@freezed` annotation
- [ ] Add `.create()` factory
- [ ] Add `markDirty()` and `softDelete()` methods
- [ ] Add `fromJson` and `toJson` for serialization

### 2. Table Definition
- [ ] Create `lib/src/data/local/database/tables/{entity_name}_table.dart`
- [ ] Extend `Table` with `SyncableTable` mixin
- [ ] Add entity-specific columns
- [ ] Add foreign key references where needed
- [ ] Define indexes for performance (`@TableIndex`)

### 3. DAO Implementation
- [ ] Create `lib/src/data/local/database/daos/{entity_name}_dao.dart`
- [ ] Extend `BaseDao<Table, Data>`
- [ ] Implement all required methods
- [ ] Add `toDomain()` converter
- [ ] Add entity-specific query methods
- [ ] Use `@DriftAccessor` annotation

### 4. Repository
- [ ] Create `lib/src/domain/repositories/{entity_name}_repository.dart` interface
- [ ] Create `lib/src/data/repositories/{entity_name}_repository_impl.dart`
- [ ] Implement CRUD operations
- [ ] Add domain-specific query methods

### 5. Registry Registration
- [ ] Update `lib/src/sync/core/entity_registry_setup.dart`
- [ ] Register entity type, DAO, and serialization functions

### 6. Database & Providers
- [ ] Add table to `AppDatabase` tables list
- [ ] Add DAO to `AppDatabase` daos list
- [ ] Create DAO provider in `database_providers.dart`
- [ ] Create repository provider in `repository_providers.dart`

### 7. Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 8. Testing
- [ ] Create unit tests for DAO
- [ ] Create tests for repository
- [ ] Test sync integration

## Implementation Order (by Priority)

### Phase 1: Core User Entities (Start Here)
1. **User** - Required for both athlete and coach profiles (includes role field)
2. **Exercise** - Core exercise definitions
3. **Variant** - Exercise variations

### Phase 2: Planning Entities
5. **ExercisePlan** - Links to TrainingPlan
6. **SetPlan** - Details for exercise plans
7. **ExercisePlanVariant** - Join table for variants

### Phase 3: Execution Entities
8. **TrainingSession** - Actual workout sessions
9. **ExerciseSession** - Exercises performed
10. **SetSession** - Sets performed
11. **ExerciseSessionVariant** - Join table

### Phase 4: Supplementary
12. **BodyWeightEntry** - Weight tracking

## Example: User Entity

Here's a complete example for the User entity:

### Domain Model
```dart
// lib/src/domain/models/user.dart
enum UserRole { athlete, coach }

@freezed
class User with _$User implements SyncableEntity {
  const factory User({
    required String id,
    required String email,
    required String name,
    required UserRole role, // ATHLETE or COACH
    String? coachId, // Only for athletes - references their coach
    required DateTime createdAt,
    required DateTime updatedAt,
    required int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  const User._();

  factory User.create({
    required String email,
    required String name,
    required UserRole role,
    String? coachId,
  }) {
    final now = DateTime.now();
    return User(
      id: const Uuid().v4(),
      email: email,
      name: name,
      role: role,
      coachId: coachId,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  User markDirty() => copyWith(isDirty: true, updatedAt: DateTime.now());
  User softDelete() => copyWith(deletedAt: DateTime.now(), isDirty: true, updatedAt: DateTime.now());
}
```

### Table
```dart
// lib/src/data/local/database/tables/users_table.dart
@DataClassName('UserData')
class Users extends Table with SyncableTable {
  TextColumn get email => text().withLength(min: 1, max: 255).unique()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  IntColumn get role => intEnum<UserRole>()(); // ATHLETE or COACH
  TextColumn get coachId => text().nullable()(); // Only for athletes
}

@TableIndex(name: 'idx_users_email', columns: {#email})
@TableIndex(name: 'idx_users_role', columns: {#role})
@TableIndex(name: 'idx_users_coach', columns: {#coachId})
class UsersIndex extends TableIndex {
  @override
  final Users table = Users();
}
```

### DAO
```dart
// lib/src/data/local/database/daos/user_dao.dart
@DriftAccessor(tables: [Users])
class UserDao extends BaseDao<Users, UserData> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  @override
  TableInfo<Users, UserData> get table => users;

  @override
  Future<UserData?> findById(String id) {
    return (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<List<UserData>> findAllActive() {
    return (select(users)..where((t) => t.deletedAt.isNull())).get();
  }

  @override
  Future<List<UserData>> findAllDirty() {
    return (select(users)..where((t) => t.isDirty.equals(true))).get();
  }

  @override
  Future<void> markDirty(String id) async {
    await (update(users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(isDirty: const Value(true), updatedAt: Value(DateTime.now())),
    );
  }

  @override
  Future<void> clearDirty(String id, DateTime syncedAt) async {
    await (update(users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(isDirty: const Value(false), lastSyncedAt: Value(syncedAt)),
    );
  }

  @override
  Future<void> upsertFromServer(UserData entity) async {
    await into(users).insertOnConflictUpdate(entity);
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
    return (select(users)..where((t) => t.email.equals(email) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<String> create(User user) async {
    await into(users).insert(UsersCompanion.insert(
      id: Value(user.id),
      email: user.email,
      name: user.name,
      role: user.role,
      coachId: Value(user.coachId),
      isDirty: const Value(true),
    ));
    return user.id;
  }

  User toDomain(UserData data) {
    return User(
      id: data.id,
      email: data.email,
      name: data.name,
      role: data.role,
      coachId: data.coachId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      version: data.version,
      deletedAt: data.deletedAt,
      isDirty: data.isDirty,
      lastSyncedAt: data.lastSyncedAt,
    );
  }
}
```

### Repository
```dart
// lib/src/domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<User?> findById(String id);
  Future<User?> findByEmail(String email);
  Future<String> create(User user);
  Future<void> update(User user);
  Future<void> delete(String id);
}

// lib/src/data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserDao _dao;

  UserRepositoryImpl(this._dao);

  @override
  Future<User?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<User?> findByEmail(String email) async {
    final data = await _dao.findByEmail(email);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<String> create(User user) => _dao.create(user);

  @override
  Future<void> update(User user) => _dao.markDirty(user.id);

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
```

### Register in Entity Registry
```dart
// Update lib/src/sync/core/entity_registry_setup.dart
void setupEntityRegistry(EntityRegistry registry, AppDatabase db) {
  // TrainingPlan (already registered)
  registry.register(
    entityType: 'TrainingPlan',
    dao: db.trainingPlanDao,
    fromJson: (json) => TrainingPlanData.fromJson(json),
    toJson: (data) => (data as TrainingPlanData).toJson(),
    toDomain: (data) => db.trainingPlanDao.toDomain(data as TrainingPlanData),
  );

  // User
  registry.register(
    entityType: 'User',
    dao: db.userDao,
    fromJson: (json) => UserData.fromJson(json),
    toJson: (data) => (data as UserData).toJson(),
    toDomain: (data) => db.userDao.toDomain(data as UserData),
  );

  // Continue for other 9 entities...
}
```

## Tracking Progress

Create a checklist file to track progress:

Create `.md/plans/sync/front/steps/entity-implementation-checklist.md`:
```markdown
# Entity Implementation Checklist

## Phase 1: Core User Entities
- [ ] User (includes both ATHLETE and COACH roles)
- [ ] Exercise
- [ ] Variant

## Phase 2: Planning Entities
- [ ] ExercisePlan
- [ ] SetPlan
- [ ] ExercisePlanVariant

## Phase 3: Execution Entities
- [ ] TrainingSession
- [ ] ExerciseSession
- [ ] SetSession
- [ ] ExerciseSessionVariant

## Phase 4: Supplementary
- [ ] BodyWeightEntry
```

## Success Criteria
- ✅ All 11 entities implemented following the pattern
- ✅ All entities registered in EntityRegistry
- ✅ Code generation successful for all entities
- ✅ Basic CRUD tests pass for each entity
- ✅ Sync integration works for all entities

## Estimated Time
11-22 hours (1-2 hours per entity, User entity may take slightly longer due to role handling)

## Next Step
13-ui-indicators.md - Add UI components for sync status and offline indicators
