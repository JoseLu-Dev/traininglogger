import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';

@TableIndex(name: 'idx_exercises_name', columns: { #name,  })
@TableIndex(name: 'idx_exercises_category', columns: { #category,  })
@DataClassName('ExerciseData')
class Exercises extends Table with SyncableTable {
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().withLength(max: 100).nullable()();
}
