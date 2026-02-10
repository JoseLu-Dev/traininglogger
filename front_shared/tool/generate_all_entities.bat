@echo off
REM Generate all 11 entities for the sync system

echo Generating all entities...
echo.

fvm dart run tool/generate_entity.dart entities/user.yaml
fvm dart run tool/generate_entity.dart entities/exercise.yaml
fvm dart run tool/generate_entity.dart entities/variant.yaml
fvm dart run tool/generate_entity.dart entities/exercise_plan.yaml
fvm dart run tool/generate_entity.dart entities/set_plan.yaml
fvm dart run tool/generate_entity.dart entities/training_plan.yaml
fvm dart run tool/generate_entity.dart entities/training_session.yaml
fvm dart run tool/generate_entity.dart entities/exercise_session.yaml
fvm dart run tool/generate_entity.dart entities/set_session.yaml
fvm dart run tool/generate_entity.dart entities/body_weight_entry.yaml
fvm dart run tool/generate_entity.dart entities/exercise_plan_variant.yaml
fvm dart run tool/generate_entity.dart entities/exercise_session_variant.yaml

echo.
echo All entities generated successfully!
echo.
echo Next steps:
echo 1. Update app_database.dart to include all tables and DAOs
echo 2. Register all entities in entity_registry_setup.dart
echo 3. Run: fvm dart run build_runner build --delete-conflicting-outputs
echo 4. Run: flutter test
