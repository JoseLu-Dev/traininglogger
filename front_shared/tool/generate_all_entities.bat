@echo off
REM Generate all 12 entities for the sync system

echo Generating all entities...
echo.

call dart run tool/generate_entity.dart entities/user.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/exercise.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/variant.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/training_plan.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/exercise_plan.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/exercise_plan_variant.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/set_plan.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/training_session.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/exercise_session.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/exercise_session_variant.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/set_session.yaml
if errorlevel 1 goto :error

call dart run tool/generate_entity.dart entities/body_weight_entry.yaml
if errorlevel 1 goto :error

echo.
echo All entities generated successfully!
echo.
echo Next steps:
echo 1. Update app_database.dart to include all tables and DAOs
echo 2. Register all entities in entity_registry_setup.dart
echo 3. Run: dart run build_runner build --delete-conflicting-outputs
echo 4. Run: flutter test
goto :end

:error
echo.
echo ERROR: Entity generation failed!
exit /b 1

:end
