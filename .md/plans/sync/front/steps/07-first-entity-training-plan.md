# Step 07: First Entity - TrainingPlan

## Goal
Implement complete TrainingPlan entity using the entity generator as a pattern for the other 10 entities.

## Tasks

### 1. Create TrainingPlan YAML schema

The YAML schema is already created at `entities/training_plan.yaml`. Review it to understand the entity structure:

- 4 entity-specific fields (athleteId, name, date, isLocked)
- 3 indexes for performance
- 2 custom queries (findByAthleteId, findByAthleteBetweenDates)
- Create factory with 4 parameters

### 2. Generate TrainingPlan files

Run the entity generator:
```bash
cd front_shared
fvm dart run tool/generate_entity.dart entities/training_plan.yaml
```

This automatically generates 6 files (~470 lines of boilerplate):
- `lib/src/domain/models/training_plan.dart` - Freezed domain model
- `lib/src/data/local/database/tables/training_plans_table.dart` - Drift table
- `lib/src/data/local/database/daos/training_plan_dao.dart` - DAO with CRUD + custom queries
- `lib/src/domain/repositories/training_plan_repository.dart` - Repository interface
- `lib/src/data/repositories/training_plan_repository_impl.dart` - Repository implementation
- `test/data/training_plan_dao_test.dart` - Basic DAO tests

**Time saved: 1-2 hours → 2 minutes**

### 3. Update AppDatabase

Update `lib/src/data/local/database/app_database.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'tables/training_plans_table.dart';
import 'daos/training_plan_dao.dart';

part 'app_database.g.dart';

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
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
```

### 4. Register TrainingPlan in EntityRegistry

Create or update `lib/src/sync/core/entity_registry_setup.dart`:
```dart
import '../data/local/database/app_database.dart';
import '../data/local/database/tables/training_plans_table.dart';
import 'entity_registry.dart';

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

### 5. Create providers

Create `lib/src/providers/database_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database/app_database.dart';
import 'package:drift/native.dart';

final databaseProvider = Provider((ref) {
  return AppDatabase(NativeDatabase.memory());
});

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

### 6. Run code generation

```bash
cd front_shared
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `training_plan.freezed.dart` - Freezed code
- `training_plan.g.dart` - JSON serialization
- `training_plan_dao.g.dart` - Drift DAO code
- `app_database.g.dart` - Drift database code

### 7. Run tests

```bash
cd front_shared
flutter test test/data/training_plan_dao_test.dart
```

The generated tests cover:
- Create and find by ID
- Mark dirty flag
- Soft delete
- Find all dirty entities

## Success Criteria
- ✅ TrainingPlan YAML schema created
- ✅ 6 files generated automatically
- ✅ AppDatabase updated with TrainingPlan table and DAO
- ✅ Entity registered in EntityRegistry
- ✅ Providers created
- ✅ Code generation successful (Freezed + Drift)
- ✅ All tests pass

## Estimated Time
30-45 minutes (down from 2-3 hours with manual implementation)

## Next Step
08-sync-strategies.md - Implement pull and push strategies using the registry
