import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'exercise_plans_table.dart';
import 'variants_table.dart';

@TableIndex(name: 'idx_exercise_plan_variants_plan', columns: { #exercisePlanId,  })
@TableIndex(name: 'idx_exercise_plan_variants_variant', columns: { #variantId,  })
@TableIndex(name: 'idx_exercise_plan_variants_unique', columns: { #exercisePlanId, #variantId,  })
@DataClassName('ExercisePlanVariantData')
class ExercisePlanVariants extends Table with SyncableTable {
  TextColumn get athleteId => text()();
  TextColumn get exercisePlanId => text().references(ExercisePlans, #id)();
  TextColumn get variantId => text().references(Variants, #id)();
}
