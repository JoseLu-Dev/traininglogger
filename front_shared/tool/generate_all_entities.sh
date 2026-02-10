#!/bin/bash
# Generate all 11 entities for the sync system

set -e

echo "🚀 Generating all entities..."
echo ""

entities=(
  "user"
  "exercise"
  "variant"
  "exercise_plan"
  "set_plan"
  "training_session"
  "exercise_session"
  "set_session"
  "body_weight_entry"
  "exercise_plan_variant"
  "exercise_session_variant"
)

for entity in "${entities[@]}"; do
  echo "📝 Generating $entity..."
  fvm dart run tool/generate_entity.dart "entities/${entity}.yaml"
  echo ""
done

echo "✅ All entities generated successfully!"
echo ""
echo "Next steps:"
echo "1. Update app_database.dart to include all tables and DAOs"
echo "2. Register all entities in entity_registry_setup.dart"
echo "3. Run: cd front_shared && dart run build_runner build --delete-conflicting-outputs"
echo "4. Run: flutter test"
