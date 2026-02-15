import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'training_sessions_table.dart';
import 'exercise_plans_table.dart';
import 'exercises_table.dart';

@TableIndex(name: 'idx_exercise_sessions_training_session', columns: { #trainingSessionId,  })
@TableIndex(name: 'idx_exercise_sessions_plan', columns: { #exercisePlanId,  })
@TableIndex(name: 'idx_exercise_sessions_exercise', columns: { #exerciseId,  })
@TableIndex(name: 'idx_exercise_sessions_order', columns: { #trainingSessionId, #orderIndex,  })
@DataClassName('ExerciseSessionData')
class ExerciseSessions extends Table with SyncableTable {
  TextColumn get athleteId => text()();
  TextColumn get trainingSessionId => text().references(TrainingSessions, #id)();
  TextColumn get exercisePlanId => text().nullable().references(ExercisePlans, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();
  TextColumn get notes => text().nullable()();
}
