# Entity Generator Path Update Summary

## Change Overview

Updated entity generator to output all generated code to `lib/src/generated/` subdirectory.

**Date**: 2026-02-09
**Status**: ✅ Complete

## What Changed

### 1. Generator Output Paths (`tool/generate_entity.dart`)

Changed all 6 output paths:
- ❌ `lib/src/domain/models/` → ✅ `lib/src/generated/domain/models/`
- ❌ `lib/src/data/local/database/tables/` → ✅ `lib/src/generated/data/local/database/tables/`
- ❌ `lib/src/data/local/database/daos/` → ✅ `lib/src/generated/data/local/database/daos/`
- ❌ `lib/src/domain/repositories/` → ✅ `lib/src/generated/domain/repositories/`
- ❌ `lib/src/data/repositories/` → ✅ `lib/src/generated/data/repositories/`
- ❌ `test/data/` → ✅ `test/generated/`

### 2. Template Imports Updated

All templates now use package imports to reference base infrastructure in `lib/src/`:

**domain_model.dart.mustache**:
```dart
import 'package:front_shared/src/domain/models/syncable_entity.dart';
```

**table.dart.mustache**:
```dart
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
```

**dao.dart.mustache**:
```dart
import 'package:front_shared/src/data/local/database/app_database.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
```

**dao_test.dart.mustache**:
```dart
import 'package:front_shared/src/generated/domain/models/{{snakeName}}.dart';
import '../../helpers/database_helper.dart';  // Updated path (2 levels up)
```

### 3. Documentation Updated

All 5 documentation files updated with new paths:
- ✅ `ENTITY_GENERATOR_README.md`
- ✅ `GENERATOR_GUIDE.md`
- ✅ `IMPLEMENTATION_SUMMARY.md`
- ✅ `QUICK_START.md`
- ✅ `NEXT_STEPS_CHECKLIST.md`

## Directory Structure

### New Structure

```
front_shared/
├── lib/
│   ├── src/                           # Base infrastructure (hand-written)
│   │   ├── domain/models/
│   │   │   └── syncable_entity.dart   # Base interface
│   │   └── data/local/database/
│   │       ├── tables/
│   │       │   └── base_table.dart    # Base table mixin
│   │       ├── daos/
│   │       │   └── base_dao.dart      # Base DAO class
│   │       └── app_database.dart      # Database definition
│   │
│   └── generated/                     # All generated code
│       ├── domain/
│       │   ├── models/                # Generated domain models
│       │   └── repositories/          # Generated repository interfaces
│       └── data/
│           ├── local/database/
│           │   ├── tables/            # Generated Drift tables
│           │   └── daos/              # Generated DAOs
│           └── repositories/          # Generated repository implementations
│
└── test/
    ├── helpers/                       # Test utilities (hand-written)
    │   └── database_helper.dart
    └── generated/                     # Generated tests
```

## Benefits

1. **Clear Separation**: Generated code is clearly separated from hand-written base infrastructure
2. **Easy Cleanup**: Can delete entire `lib/src/generated/` and `test/generated/` to regenerate all entities
3. **Better Organization**: Mirrors subdirectory structure while consolidating generated files
4. **No Conflicts**: Generated code never overwrites hand-written infrastructure

## Verification

Tested with training_plan entity:

```bash
cd front_shared
fvm dart run tool/generate_entity.dart entities/training_plan.yaml
```

**Result**: ✅ All 6 files generated in correct locations with proper imports

### Generated Files
- ✅ `lib/src/generated/domain/models/training_plan.dart`
- ✅ `lib/src/generated/data/local/database/tables/training_plans_table.dart`
- ✅ `lib/src/generated/data/local/database/daos/training_plan_dao.dart`
- ✅ `lib/src/generated/domain/repositories/training_plan_repository.dart`
- ✅ `lib/src/generated/data/repositories/training_plan_repository_impl.dart`
- ✅ `test/generated/training_plan_dao_test.dart`

## Impact on Future Work

### When Adding Generated Entities to AppDatabase

Update imports in `lib/src/data/local/database/app_database.dart`:

```dart
// Old pattern (would have been):
// import 'tables/training_plans_table.dart';
// import 'daos/training_plan_dao.dart';

// New pattern (use this):
import 'generated/data/local/database/tables/training_plans_table.dart';
import 'generated/data/local/database/daos/training_plan_dao.dart';
```

### When Running Build Runner

No changes needed - works the same way:
```bash
cd front_shared
dart run build_runner build --delete-conflicting-outputs
```

### When Running Tests

Use new test path:
```bash
# Single entity test
flutter test test/generated/training_plan_dao_test.dart

# All generated tests
flutter test test/generated/
```

## Next Steps

1. ✅ Generator updated
2. ✅ Templates updated
3. ✅ Documentation updated
4. ✅ Verified with test generation
5. ⏭️ Ready to generate all 12 entities when needed

## Files Modified

### Code Changes (5 files)
1. `tool/generate_entity.dart` - Updated 6 output paths
2. `tool/templates/domain_model.dart.mustache` - Updated syncable_entity import
3. `tool/templates/table.dart.mustache` - Updated base_table import
4. `tool/templates/dao.dart.mustache` - Updated app_database and base_dao imports
5. `tool/templates/dao_test.dart.mustache` - Updated domain model import and helper path

### Documentation Changes (5 files)
1. `ENTITY_GENERATOR_README.md`
2. `GENERATOR_GUIDE.md`
3. `IMPLEMENTATION_SUMMARY.md`
4. `QUICK_START.md`
5. `NEXT_STEPS_CHECKLIST.md`

### New Files Created
1. `PATH_UPDATE_SUMMARY.md` - This summary document

## Rollback Instructions

If needed, revert changes to these 10 files using git:
```bash
git checkout HEAD -- tool/generate_entity.dart
git checkout HEAD -- tool/templates/*.mustache
git checkout HEAD -- *.md
```

## Notes

- No existing generated entities were affected (this was done before any entities were generated)
- Base infrastructure in `lib/src/` remains unchanged
- Entity YAML schemas remain unchanged
- All 12 entity YAML files are ready to generate
