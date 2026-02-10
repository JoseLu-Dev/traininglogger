import 'package:drift/native.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';

export 'package:front_shared/src/data/local/database/app_database.dart';
export 'package:front_shared/src/generated/data/local/database/daos/body_weight_entry_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/exercise_plan_variant_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/exercise_plan_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/exercise_session_variant_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/exercise_session_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/exercise_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/set_plan_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/set_session_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/training_plan_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/training_session_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/user_dao.dart';
export 'package:front_shared/src/generated/data/local/database/daos/variant_dao.dart';

AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}
