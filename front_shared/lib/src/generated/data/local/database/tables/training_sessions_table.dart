import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'training_plans_table.dart';
import 'users_table.dart';

@TableIndex(name: 'idx_training_sessions_plan', columns: { #trainingPlanId,  })
@TableIndex(name: 'idx_training_sessions_athlete', columns: { #athleteId,  })
@TableIndex(name: 'idx_training_sessions_start_time', columns: { #startTime,  })
@DataClassName('TrainingSessionData')
class TrainingSessions extends Table with SyncableTable {
  TextColumn get trainingPlanId => text().references(TrainingPlans, #id)();
  TextColumn get athleteId => text().references(Users, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
}
