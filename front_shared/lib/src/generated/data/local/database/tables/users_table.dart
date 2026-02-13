import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'users_table.dart';
import 'package:front_shared/src/generated/domain/models/user.dart';

@TableIndex(name: 'idx_users_email', columns: { #email,  })
@TableIndex(name: 'idx_users_role', columns: { #role,  })
@TableIndex(name: 'idx_users_coach', columns: { #coachId,  })
@DataClassName('UserData')
class Users extends Table with SyncableTable {
  TextColumn get email => text().withLength(min: 1, max: 255).unique()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  Column get role => textEnum<UserRole>()();
  TextColumn get coachId => text().nullable().references(Users, #id)();
}
