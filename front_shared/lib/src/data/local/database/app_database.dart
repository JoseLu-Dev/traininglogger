import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/generated/domain/models/user.dart';
import 'package:front_shared/src/generated/data/local/database/tables/body_weight_entries_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/exercise_plan_variants_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/exercise_plans_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/exercise_session_variants_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/exercise_sessions_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/exercises_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/set_plans_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/set_sessions_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/training_plans_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/training_sessions_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/users_table.dart';
import 'package:front_shared/src/generated/data/local/database/tables/variants_table.dart';
import 'package:front_shared/src/generated/data/local/database/daos/body_weight_entry_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/exercise_plan_variant_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/exercise_plan_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/exercise_session_variant_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/exercise_session_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/exercise_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/set_plan_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/set_session_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/training_plan_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/training_session_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/user_dao.dart';
import 'package:front_shared/src/generated/data/local/database/daos/variant_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    BodyWeightEntries,
    ExercisePlanVariants,
    ExercisePlans,
    ExerciseSessionVariants,
    ExerciseSessions,
    Exercises,
    SetPlans,
    SetSessions,
    TrainingPlans,
    TrainingSessions,
    Users,
    Variants,
  ],
  daos: [
    BodyWeightEntryDao,
    ExercisePlanVariantDao,
    ExercisePlanDao,
    ExerciseSessionVariantDao,
    ExerciseSessionDao,
    ExerciseDao,
    SetPlanDao,
    SetSessionDao,
    TrainingPlanDao,
    TrainingSessionDao,
    UserDao,
    VariantDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Test constructor for in-memory database
  AppDatabase.withConnection(QueryExecutor connection) : super(connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations will go here
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'liftlogger', 'liftlogger.db')); //TODO make this parametrizable as has to be different for each front
    return NativeDatabase(file);
  });
}
