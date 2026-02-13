import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'exercise_plans_table.dart';

@TableIndex(name: 'idx_set_plans_exercise_plan', columns: { #exercisePlanId,  })
@TableIndex(name: 'idx_set_plans_order', columns: { #exercisePlanId, #setNumber,  })
@DataClassName('SetPlanData')
class SetPlans extends Table with SyncableTable {
  TextColumn get exercisePlanId => text().references(ExercisePlans, #id)();
  IntColumn get setNumber => integer().nullable()();
  IntColumn get targetReps => integer().nullable()();
  RealColumn get targetWeight => real().nullable()();
  RealColumn get targetRpe => real().nullable()();
  TextColumn get notes => text().nullable()();
}
