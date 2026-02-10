import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'exercise_sessions_table.dart';
import 'set_plans_table.dart';

@TableIndex(name: 'idx_set_sessions_exercise_session', columns: { #exerciseSessionId,  })
@TableIndex(name: 'idx_set_sessions_plan', columns: { #setPlanId,  })
@TableIndex(name: 'idx_set_sessions_order', columns: { #exerciseSessionId, #setNumber,  })
@DataClassName('SetSessionData')
class SetSessions extends Table with SyncableTable {
  TextColumn get exerciseSessionId => text().references(ExerciseSessions, #id)();
  TextColumn get setPlanId => text().nullable().references(SetPlans, #id)();
  IntColumn get setNumber => integer()();
  IntColumn get actualReps => integer()();
  RealColumn get actualWeight => real()();
  RealColumn get actualRpe => real().nullable()();
  TextColumn get notes => text().nullable()();
}
