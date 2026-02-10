# Entity Generator - Quick Start

## Generate a New Entity (5 Steps)

### 1. Create YAML Schema
```bash
# Create entities/{entity_name}.yaml in front_shared/entities/
# See entities/training_plan.yaml for example
```

### 2. Generate Code
```bash
# From front_shared directory
cd front_shared
fvm dart run tool/generate_entity.dart entities/{entity_name}.yaml
```

### 3. Update Database
Edit `front_shared/lib/src/data/local/database/app_database.dart`:
```dart
// Add imports at the top:
import 'generated/data/local/database/tables/{new_table}_table.dart';
import 'generated/data/local/database/daos/{new_entity}_dao.dart';

@DriftDatabase(
  tables: [
    // ... existing tables ...
    {NewTable},  // Add this
  ],
  daos: [
    // ... existing DAOs ...
    {NewDao},    // Add this
  ],
)
```

### 4. Register Entity
Edit `front_shared/lib/src/sync/core/entity_registry_setup.dart`:
```dart
registry.register(
  entityType: '{EntityName}',
  dao: db.{entityName}Dao,
  fromJson: (json) => {EntityName}Data.fromJson(json),
  toJson: (data) => (data as {EntityName}Data).toJson(),
  toDomain: (data) => db.{entityName}Dao.toDomain(data as {EntityName}Data),
);
```

### 5. Build & Test
```bash
cd front_shared
dart run build_runner build --delete-conflicting-outputs
flutter test test/generated/{entity_name}_dao_test.dart
```

## Generate All 11 Entities

```bash
# From front_shared directory
cd front_shared
for entity in user exercise variant exercise_plan set_plan training_session exercise_session set_session body_weight_entry exercise_plan_variant exercise_session_variant; do
  fvm dart run tool/generate_entity.dart entities/${entity}.yaml
done
```

Then update `app_database.dart` and `entity_registry_setup.dart` for all entities.

## Files Generated Per Entity

All generated under `lib/src/generated/`:

✅ Domain model: `lib/src/generated/domain/models/{entity}.dart`
✅ Table: `lib/src/generated/data/local/database/tables/{table}_table.dart`
✅ DAO: `lib/src/generated/data/local/database/daos/{entity}_dao.dart`
✅ Repository interface: `lib/src/generated/domain/repositories/{entity}_repository.dart`
✅ Repository impl: `lib/src/generated/data/repositories/{entity}_repository_impl.dart`
✅ Tests: `test/generated/{entity}_dao_test.dart`

## Time Per Entity

- Manual: 1-2 hours
- Generator: 15-20 minutes
- **Savings: 70-80%**

## Full Documentation

- `GENERATOR_GUIDE.md` - Complete usage guide
- `IMPLEMENTATION_SUMMARY.md` - Detailed implementation info
- `.md/plans/sync/front/steps/07-first-entity-training-plan-NEW.md` - Step-by-step example
- `.md/plans/sync/front/steps/12-remaining-entities-NEW.md` - Batch generation guide
