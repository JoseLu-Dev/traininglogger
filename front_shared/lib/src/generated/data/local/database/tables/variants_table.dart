import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';

@TableIndex(name: 'idx_variants_name', columns: { #name,  })
@DataClassName('VariantData')
class Variants extends Table with SyncableTable {
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
}
