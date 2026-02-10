# Step 12: Remaining Entities (Using Generator)

## Goal
Implement the remaining 10 entities using the entity generator for maximum efficiency.

## Entities to Implement

All YAML schemas have been pre-created in the `entities/` directory:

1. **User** (`user.yaml`) - User profiles for athletes and coaches with role field
2. **Exercise** (`exercise.yaml`) - Exercise definitions
3. **Variant** (`variant.yaml`) - Exercise variants
4. **ExercisePlan** (`exercise_plan.yaml`) - Planned exercises in training plans
5. **SetPlan** (`set_plan.yaml`) - Planned sets for exercises
6. **TrainingSession** (`training_session.yaml`) - Actual training session records
7. **ExerciseSession** (`exercise_session.yaml`) - Actual exercises performed
8. **SetSession** (`set_session.yaml`) - Actual sets performed
9. **BodyWeightEntry** (`body_weight_entry.yaml`) - Body weight measurements
10. **ExercisePlanVariant** (`exercise_plan_variant.yaml`) - Join table for plan variants
11. **ExerciseSessionVariant** (`exercise_session_variant.yaml`) - Join table for session variants

## Implementation Process

For each entity, follow this streamlined process:

### 1. Review YAML Schema (5 min)
```bash
cat entities/{entity_name}.yaml
```

Verify the schema includes:
- All required fields
- Appropriate indexes
- Custom queries if needed
- createFactory parameters

### 2. Generate Files (1 min)
```bash
cd front_shared
fvm dart run tool/generate_entity.dart entities/{entity_name}.yaml
```

This creates all 6 files automatically.

### 3. Update AppDatabase (2 min)

Add to `lib/src/data/local/database/app_database.dart`:
```dart
import 'tables/{table_name}_table.dart';
import 'daos/{entity_name}_dao.dart';

@DriftDatabase(
  tables: [
    TrainingPlans,
    {NewTable},  // Add new table
    // ...
  ],
  daos: [
    TrainingPlanDao,
    {NewDao},    // Add new DAO
    // ...
  ],
)
```

### 4. Register in EntityRegistry (3 min)

Add to `lib/src/sync/core/entity_registry_setup.dart`:
```dart
registry.register(
  entityType: '{EntityName}',
  dao: db.{entityName}Dao,
  fromJson: (json) => {EntityName}Data.fromJson(json),
  toJson: (data) => (data as {EntityName}Data).toJson(),
  toDomain: (data) => db.{entityName}Dao.toDomain(data as {EntityName}Data),
);
```

### 5. Create Providers (3 min)

Add to `database_providers.dart`:
```dart
final {entityName}DaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).{entityName}Dao;
});
```

Add to `repository_providers.dart`:
```dart
final {entityName}RepositoryProvider = Provider<{EntityName}Repository>((ref) {
  return {EntityName}RepositoryImpl(ref.watch({entityName}DaoProvider));
});
```

### 6. Run Build Runner (2 min)
```bash
cd front_shared
dart run build_runner build --delete-conflicting-outputs
```

### 7. Run Tests (2 min)
```bash
flutter test test/data/{entity_name}_dao_test.dart
```

**Total time per entity: ~15-20 minutes** (vs. 1-2 hours manual)

## Implementation Order (Recommended)

Follow dependency order for smoother implementation:

### Phase 1: Core Entities (1 hour)
```bash
cd front_shared
fvm dart run tool/generate_entity.dart entities/user.yaml
fvm dart run tool/generate_entity.dart entities/exercise.yaml
fvm dart run tool/generate_entity.dart entities/variant.yaml
```

### Phase 2: Planning Entities (1 hour)
```bash
cd front_shared
fvm dart run tool/generate_entity.dart entities/exercise_plan.yaml
fvm dart run tool/generate_entity.dart entities/set_plan.yaml
fvm dart run tool/generate_entity.dart entities/exercise_plan_variant.yaml
```

### Phase 3: Session Entities (1.5 hours)
```bash
cd front_shared
fvm dart run tool/generate_entity.dart entities/training_session.yaml
fvm dart run tool/generate_entity.dart entities/exercise_session.yaml
fvm dart run tool/generate_entity.dart entities/set_session.yaml
fvm dart run tool/generate_entity.dart entities/exercise_session_variant.yaml
```

### Phase 4: Supplementary (20 min)
```bash
cd front_shared
fvm dart run tool/generate_entity.dart entities/body_weight_entry.yaml
```

## Batch Script (Optional)

Use the existing `front_shared/tool/generate_all_entities.sh`:
```bash
cd front_shared
chmod +x tool/generate_all_entities.sh
./tool/generate_all_entities.sh
```

Or on Windows:
```bash
cd front_shared
tool\generate_all_entities.bat
```

Run with:
```bash
chmod +x tool/generate_all_entities.sh
./tool/generate_all_entities.sh
```

## Final Integration

After generating all entities:

### 1. Update AppDatabase

Ensure all 11 entities are registered:
```dart
@DriftDatabase(
  tables: [
    TrainingPlans,
    Users,
    Exercises,
    Variants,
    ExercisePlans,
    SetPlans,
    TrainingSessions,
    ExerciseSessions,
    SetSessions,
    BodyWeightEntries,
    ExercisePlanVariants,
    ExerciseSessionVariants,
  ],
  daos: [
    TrainingPlanDao,
    UserDao,
    ExerciseDao,
    // ... all 11 DAOs
  ],
)
```

### 2. Run Full Build
```bash
cd front_shared
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run All Tests
```bash
flutter test
```

### 4. Verify EntityRegistry

Ensure all 11 entities are registered in `entity_registry_setup.dart`.

## Success Criteria
- ✅ All 11 entities generated from YAML schemas
- ✅ All entities registered in AppDatabase
- ✅ All entities registered in EntityRegistry
- ✅ All providers created
- ✅ Code generation successful for all entities
- ✅ All DAO tests pass
- ✅ No compilation errors

## Time Savings

**Manual implementation:**
- 11 entities × 1.5 hours = ~16.5 hours

**With generator:**
- 11 entities × 20 minutes = ~3.5 hours

**Total time saved: ~13 hours** (78% reduction)

## Next Step
13-final-integration.md - Wire everything together and run end-to-end tests
