import 'package:drift/drift.dart';
import 'package:front_shared/src/data/local/database/tables/base_table.dart';
import 'exercise_sessions_table.dart';
import 'variants_table.dart';

@TableIndex(name: 'idx_exercise_session_variants_session', columns: { #exerciseSessionId,  })
@TableIndex(name: 'idx_exercise_session_variants_variant', columns: { #variantId,  })
@TableIndex(name: 'idx_exercise_session_variants_unique', columns: { #exerciseSessionId, #variantId,  })
@DataClassName('ExerciseSessionVariantData')
class ExerciseSessionVariants extends Table with SyncableTable {
  TextColumn get exerciseSessionId => text().references(ExerciseSessions, #id)();
  TextColumn get variantId => text().references(Variants, #id)();
}
