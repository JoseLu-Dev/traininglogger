import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'users_table.dart';

@TableIndex(name: 'idx_body_weight_entries_athlete', columns: { #athleteId,  })
@TableIndex(name: 'idx_body_weight_entries_date', columns: { #measurementDate,  })
@TableIndex(name: 'idx_body_weight_entries_athlete_date', columns: { #athleteId, #measurementDate,  })
@DataClassName('BodyWeightEntryData')
class BodyWeightEntries extends Table with SyncableTable {
  TextColumn get athleteId => text().references(Users, #id)();
  RealColumn get weight => real()();
  DateTimeColumn get measurementDate => dateTime()();
  TextColumn get notes => text().nullable()();
}
