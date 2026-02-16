import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'users_table.dart';

@TableIndex(name: 'idx_training_plans_athlete', columns: { #athleteId,  })
@TableIndex(name: 'idx_training_plans_dirty', columns: { #isDirty, #athleteId,  })
@TableIndex(name: 'idx_training_plans_date', columns: { #date,  })
@DataClassName('TrainingPlanData')
class TrainingPlans extends Table with SyncableTable {
  TextColumn get athleteId => text().references(Users, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get date => text()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
}
