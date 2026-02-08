# Step 07: First Entity - TrainingPlan

## Goal
Implement complete TrainingPlan entity (domain model, table, DAO, repository) as a pattern for the other 11 entities.

## Tasks

### 1. Create TrainingPlan domain model
Create `lib/src/domain/models/training_plan.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'syncable_entity.dart';

part 'training_plan.freezed.dart';
part 'training_plan.g.dart';

@freezed
class TrainingPlan with _$TrainingPlan implements SyncableEntity {
  const factory TrainingPlan({
    required String id,
    required String athleteId,
    required String name,
    required DateTime date,
    @Default(false) bool isLocked,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _TrainingPlan;

  factory TrainingPlan.fromJson(Map<String, dynamic> json) =>
      _$TrainingPlanFromJson(json);

  const TrainingPlan._();

  /// Factory for creating a new training plan
  factory TrainingPlan.create({
    required String athleteId,
    required String name,
    required DateTime date,
    bool isLocked = false,
  }) {
    final now = DateTime.now();
    return TrainingPlan(
      id: const Uuid().v4(),
      athleteId: athleteId,
      name: name,
      date: date,
      isLocked: isLocked,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  TrainingPlan markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  TrainingPlan softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
```

### 2. Create TrainingPlans table
Create `lib/src/data/local/database/tables/training_plans_table.dart`:
```dart
import 'package:drift/drift.dart';
import 'base_table.dart';
import 'athletes_table.dart'; // Will be created in future step

@DataClassName('TrainingPlanData')
class TrainingPlans extends Table with SyncableTable {
  TextColumn get athleteId => text()(); // Will add .references(Athletes, #id) later
  TextColumn get name => text().withLength(min: 1, max: 255)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
}

// Indexes for performance
@TableIndex(name: 'idx_training_plans_athlete', columns: {#athleteId})
@TableIndex(name: 'idx_training_plans_dirty', columns: {#isDirty, #athleteId})
@TableIndex(name: 'idx_training_plans_date', columns: {#date})
class TrainingPlansIndex extends TableIndex {
  @override
  final TrainingPlans table = TrainingPlans();
}
```

### 3. Create TrainingPlanDao
Create `lib/src/data/local/database/daos/training_plan_dao.dart`:
```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/training_plans_table.dart';
import 'base_dao.dart';
import '../../../domain/models/training_plan.dart';

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
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
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
    await into(trainingPlans).insertOnConflictUpdate(entity);
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

  // Domain-specific queries
  Future<List<TrainingPlanData>> findByAthleteId(String athleteId) {
    return (select(trainingPlans)
          ..where((t) => t.athleteId.equals(athleteId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TrainingPlanData>> findByAthleteBetweenDates(
    String athleteId,
    DateTime start,
    DateTime end,
  ) {
    return (select(trainingPlans)
          ..where((t) =>
              t.athleteId.equals(athleteId) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<String> create(TrainingPlan plan) async {
    await into(trainingPlans).insert(
      TrainingPlansCompanion.insert(
        id: Value(plan.id),
        athleteId: plan.athleteId,
        name: plan.name,
        date: plan.date,
        isLocked: Value(plan.isLocked),
        isDirty: const Value(true),
      ),
    );
    return plan.id;
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
      version: data.version,
      deletedAt: data.deletedAt,
      isDirty: data.isDirty,
      lastSyncedAt: data.lastSyncedAt,
    );
  }
}
```

### 4. Create TrainingPlanRepository interface
Create `lib/src/domain/repositories/training_plan_repository.dart`:
```dart
import '../models/training_plan.dart';

abstract class TrainingPlanRepository {
  Future<TrainingPlan?> findById(String id);
  Future<List<TrainingPlan>> findAllActive();
  Future<List<TrainingPlan>> findByAthleteId(String athleteId);
  Future<List<TrainingPlan>> findByAthleteBetweenDates(
    String athleteId,
    DateTime start,
    DateTime end,
  );
  Future<String> create(TrainingPlan plan);
  Future<void> update(TrainingPlan plan);
  Future<void> delete(String id);
}
```

### 5. Create TrainingPlanRepository implementation
Create `lib/src/data/repositories/training_plan_repository_impl.dart`:
```dart
import '../../domain/models/training_plan.dart';
import '../../domain/repositories/training_plan_repository.dart';
import '../local/database/daos/training_plan_dao.dart';

class TrainingPlanRepositoryImpl implements TrainingPlanRepository {
  final TrainingPlanDao _dao;

  TrainingPlanRepositoryImpl(this._dao);

  @override
  Future<TrainingPlan?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<TrainingPlan>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<TrainingPlan>> findByAthleteId(String athleteId) async {
    final dataList = await _dao.findByAthleteId(athleteId);
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<TrainingPlan>> findByAthleteBetweenDates(
    String athleteId,
    DateTime start,
    DateTime end,
  ) async {
    final dataList = await _dao.findByAthleteBetweenDates(athleteId, start, end);
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<String> create(TrainingPlan plan) async {
    return await _dao.create(plan);
  }

  @override
  Future<void> update(TrainingPlan plan) async {
    // Update marks as dirty
    await _dao.markDirty(plan.id);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
```

### 6. Update AppDatabase to include TrainingPlan
Update `lib/src/data/local/database/app_database.dart`:
```dart
import 'tables/training_plans_table.dart';
import 'daos/training_plan_dao.dart';

@DriftDatabase(
  tables: [
    TrainingPlans,
    // Other tables will be added here
  ],
  daos: [
    TrainingPlanDao,
    // Other DAOs will be added here
  ],
)
class AppDatabase extends _$AppDatabase {
  // ... rest of the code
}
```

### 7. Register TrainingPlan in EntityRegistry
Update `lib/src/sync/core/entity_registry_setup.dart`:
```dart
void setupEntityRegistry(EntityRegistry registry, AppDatabase db) {
  registry.register(
    entityType: 'TrainingPlan',
    dao: db.trainingPlanDao,
    fromJson: (json) => TrainingPlanData.fromJson(json),
    toJson: (data) => (data as TrainingPlanData).toJson(),
    toDomain: (data) => db.trainingPlanDao.toDomain(data as TrainingPlanData),
  );

  // Other entities will be registered here
}
```

### 8. Create providers
Update `lib/src/providers/database_providers.dart`:
```dart
final trainingPlanDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).trainingPlanDao;
});
```

Create `lib/src/providers/repository_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/training_plan_repository.dart';
import '../data/repositories/training_plan_repository_impl.dart';
import 'database_providers.dart';

final trainingPlanRepositoryProvider = Provider<TrainingPlanRepository>((ref) {
  return TrainingPlanRepositoryImpl(ref.watch(trainingPlanDaoProvider));
});
```

### 9. Run code generation
```bash
cd front_shared
dart run build_runner build --delete-conflicting-outputs
```

### 10. Create tests
Create `test/data/training_plan_dao_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/domain/models/training_plan.dart';
import '../helpers/database_helper.dart';

void main() {
  late AppDatabase db;
  late TrainingPlanDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.trainingPlanDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('TrainingPlanDao', () {
    test('create and find by id', () async {
      final plan = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15),
      );

      await dao.create(plan);
      final found = await dao.findById(plan.id);

      expect(found, isNotNull);
      expect(found!.name, equals('Test Plan'));
      expect(found.isDirty, isTrue);
    });

    test('mark dirty sets isDirty flag', () async {
      final plan = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15),
      );

      await dao.create(plan);
      await dao.clearDirty(plan.id, DateTime.now());

      var found = await dao.findById(plan.id);
      expect(found!.isDirty, isFalse);

      await dao.markDirty(plan.id);
      found = await dao.findById(plan.id);
      expect(found!.isDirty, isTrue);
    });

    test('soft delete sets deletedAt', () async {
      final plan = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Test Plan',
        date: DateTime(2025, 1, 15),
      );

      await dao.create(plan);
      await dao.softDelete(plan.id);

      final found = await dao.findById(plan.id);
      expect(found!.deletedAt, isNotNull);
      expect(found.isDirty, isTrue);
    });

    test('findAllDirty returns only dirty entities', () async {
      final plan1 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 1',
        date: DateTime(2025, 1, 15),
      );
      final plan2 = TrainingPlan.create(
        athleteId: 'athlete-1',
        name: 'Plan 2',
        date: DateTime(2025, 1, 16),
      );

      await dao.create(plan1);
      await dao.create(plan2);
      await dao.clearDirty(plan2.id, DateTime.now());

      final dirty = await dao.findAllDirty();
      expect(dirty.length, equals(1));
      expect(dirty.first.id, equals(plan1.id));
    });
  });
}
```

## Success Criteria
- ✅ TrainingPlan domain model with freezed created
- ✅ TrainingPlans table with SyncableTable mixin
- ✅ TrainingPlanDao with all BaseDao methods implemented
- ✅ TrainingPlanRepository interface and implementation
- ✅ Entity registered in EntityRegistry
- ✅ Providers created
- ✅ Code generation successful
- ✅ All tests pass

## Estimated Time
2-3 hours

## Next Step
08-sync-strategies.md - Implement pull and push strategies using the registry
