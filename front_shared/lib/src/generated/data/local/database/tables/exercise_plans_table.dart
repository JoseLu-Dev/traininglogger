import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'training_plans_table.dart';
import 'exercises_table.dart';

@TableIndex(name: 'idx_exercise_plans_training_plan', columns: { #trainingPlanId,  })
@TableIndex(name: 'idx_exercise_plans_exercise', columns: { #exerciseId,  })
@TableIndex(name: 'idx_exercise_plans_order', columns: { #trainingPlanId, #orderIndex,  })
@DataClassName('ExercisePlanData')
class ExercisePlans extends Table with SyncableTable {
  TextColumn get athleteId => text()();
  TextColumn get trainingPlanId => text().references(TrainingPlans, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();
  TextColumn get notes => text().nullable()();
}
