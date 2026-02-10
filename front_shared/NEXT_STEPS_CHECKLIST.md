# Next Steps Checklist

## ✅ Completed

- [x] Created entity generator tool (`tool/generate_entity.dart`)
- [x] Created 6 Mustache templates (`tool/templates/`)
- [x] Created YAML schemas for all 11 entities (`entities/`)
- [x] Set up base infrastructure (SyncableEntity, SyncableTable, BaseDao)
- [x] Added all necessary dependencies to `front_shared/pubspec.yaml`
- [x] Created comprehensive documentation

## 🔲 To Do (In Order)

### Phase 1: Test the Generator (30 min)

- [ ] **Test with TrainingPlan entity**
  ```bash
  cd front_shared
  fvm dart run tool/generate_entity.dart entities/training_plan.yaml
  ```

- [ ] **Verify files were generated**
  - Check `lib/src/generated/domain/models/training_plan.dart`
  - Check `lib/src/generated/data/local/database/tables/training_plans_table.dart`
  - Check `lib/src/generated/data/local/database/daos/training_plan_dao.dart`
  - Check `lib/src/generated/domain/repositories/training_plan_repository.dart`
  - Check `lib/src/generated/data/repositories/training_plan_repository_impl.dart`
  - Check `test/generated/training_plan_dao_test.dart`

- [ ] **Update AppDatabase** (`front_shared/lib/src/data/local/database/app_database.dart`)
  - Add imports:
    ```dart
    import 'generated/data/local/database/tables/training_plans_table.dart';
    import 'generated/data/local/database/daos/training_plan_dao.dart';
    ```
  - Add `TrainingPlans` to tables list
  - Add `TrainingPlanDao` to daos list

- [ ] **Run build_runner**
  ```bash
  cd front_shared
  dart run build_runner build --delete-conflicting-outputs
  ```

- [ ] **Fix any compilation errors**

- [ ] **Run tests**
  ```bash
  flutter test test/generated/training_plan_dao_test.dart
  ```

### Phase 2: Generate All Entities (1-2 hours)

- [ ] **Option A: Generate all at once (Windows)**
  ```bash
  cd front_shared
  tool\generate_all_entities.bat
  ```

- [ ] **Option B: Generate all at once (Unix/Mac)**
  ```bash
  cd front_shared
  chmod +x tool/generate_all_entities.sh
  ./tool/generate_all_entities.sh
  ```

- [ ] **Option C: Generate one by one**
  ```bash
  cd front_shared
  fvm dart run tool/generate_entity.dart entities/user.yaml
  fvm dart run tool/generate_entity.dart entities/exercise.yaml
  fvm dart run tool/generate_entity.dart entities/variant.yaml
  fvm dart run tool/generate_entity.dart entities/exercise_plan.yaml
  fvm dart run tool/generate_entity.dart entities/set_plan.yaml
  fvm dart run tool/generate_entity.dart entities/training_session.yaml
  fvm dart run tool/generate_entity.dart entities/exercise_session.yaml
  fvm dart run tool/generate_entity.dart entities/set_session.yaml
  fvm dart run tool/generate_entity.dart entities/body_weight_entry.yaml
  fvm dart run tool/generate_entity.dart entities/exercise_plan_variant.yaml
  fvm dart run tool/generate_entity.dart entities/exercise_session_variant.yaml
  ```

### Phase 3: Wire Everything Together (1 hour)

- [ ] **Update AppDatabase with all 11 entities**
  - Edit `front_shared/lib/src/data/local/database/app_database.dart`
  - Add all tables to `@DriftDatabase(tables: [...])`
  - Add all DAOs to `@DriftDatabase(daos: [...])`

- [ ] **Create EntityRegistry setup**
  - Create `front_shared/lib/src/sync/core/entity_registry.dart` (if not exists)
  - Create `front_shared/lib/src/sync/core/entity_registry_setup.dart`
  - Register all 11 entities

- [ ] **Create providers (optional but recommended)**
  - Create `front_shared/lib/src/providers/database_providers.dart`
  - Create `front_shared/lib/src/providers/repository_providers.dart`
  - Add providers for all 11 entities

- [ ] **Run build_runner for all entities**
  ```bash
  cd front_shared
  dart run build_runner build --delete-conflicting-outputs
  ```

### Phase 4: Testing (30 min)

- [ ] **Run all DAO tests**
  ```bash
  cd front_shared
  flutter test test/generated/
  ```

- [ ] **Fix any failing tests**

- [ ] **Run full test suite**
  ```bash
  flutter test
  ```

### Phase 5: Continue Sync Implementation

Follow the updated plan files:

- [ ] **Step 08**: Implement sync strategies (pull/push)
  - See `.md/plans/sync/front/steps/08-sync-strategies.md`

- [ ] **Step 09**: Implement sync manager
  - See `.md/plans/sync/front/steps/09-sync-manager.md`

- [ ] **Step 10**: Add authentication
  - See `.md/plans/sync/front/steps/10-authentication.md`

- [ ] **Step 11**: Integration testing
  - See `.md/plans/sync/front/steps/11-integration-testing.md`

- [ ] **Step 13**: Final integration & UI
  - See `.md/plans/sync/front/steps/13-final-integration.md`

## 📚 Reference Documents

Quick access to documentation:

- **Quick Start**: `QUICK_START.md` - 5-step guide
- **Generator Guide**: `GENERATOR_GUIDE.md` - Complete usage
- **Implementation Summary**: `IMPLEMENTATION_SUMMARY.md` - Technical details
- **Main README**: `ENTITY_GENERATOR_README.md` - Project overview

## ⚠️ Important Notes

1. **Don't modify generated files directly** - Instead, update the YAML schema and regenerate
2. **Run build_runner after each generation** - Required for Freezed and Drift code
3. **Update app_database.dart manually** - The generator doesn't modify this file
4. **Register entities in EntityRegistry** - Required for sync to work
5. **Keep YAML schemas as source of truth** - They're easier to review and maintain

## 🎯 Success Criteria

You'll know everything is working when:

- ✅ All 11 entities generate without errors
- ✅ Build runner completes successfully
- ✅ All DAO tests pass
- ✅ No compilation errors in front_shared
- ✅ AppDatabase includes all 11 tables and DAOs
- ✅ EntityRegistry has all 11 entities registered

## 💡 Tips

- **Start with TrainingPlan** - It's the most complete example
- **Generate one entity at a time initially** - Easier to debug issues
- **Check generated code quality** - Review the first few files to ensure they're correct
- **Use batch scripts for the rest** - Once you're confident the generator works
- **Keep documentation handy** - Refer to GENERATOR_GUIDE.md when needed

## 🐛 Troubleshooting

If you encounter issues:

1. Check YAML syntax (proper indentation, no tabs)
2. Verify dependencies are installed (`flutter pub get`)
3. Ensure tool/ and entities/ directories exist
4. Review error messages carefully
5. Compare your YAML to `training_plan.yaml` example
6. Check that all imports in generated files are correct

## 📊 Time Estimates

- Phase 1 (Test): ~30 minutes
- Phase 2 (Generate All): ~1-2 hours
- Phase 3 (Wire Together): ~1 hour
- Phase 4 (Testing): ~30 minutes
- **Total: ~3-4 hours** (vs. 11-22 hours manually)

Good luck! 🚀
