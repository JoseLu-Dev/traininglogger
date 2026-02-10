# Step 06: Database Setup

## Goal
Set up Drift database infrastructure with AppDatabase class and database provider.

## Tasks

### 1. Create AppDatabase placeholder
Create `lib/src/data/local/database/app_database.dart`:
```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import tables (will be added as we implement entities)
// import 'tables/training_plans_table.dart';
// import 'tables/athletes_table.dart';
// etc.

// Import DAOs (will be added as we implement entities)
// import 'daos/training_plan_dao.dart';
// import 'daos/athlete_dao.dart';
// etc.

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    // Tables will be added here as they are implemented
    // TrainingPlans,
    // Athletes,
    // Coaches,
    // Exercises,
    // Variants,
    // ExercisePlans,
    // SetPlans,
    // TrainingSessions,
    // ExerciseSessions,
    // SetSessions,
    // BodyWeightEntries,
    // ExercisePlanVariants,
    // ExerciseSessionVariants,
  ],
  daos: [
    // DAOs will be added here as they are implemented
    // TrainingPlanDao,
    // AthleteDao,
    // CoachDao,
    // etc.
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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
    final file = File(p.join(dbFolder.path, 'liftlogger.db'));
    return NativeDatabase(file);
  });
}
```

### 2. Complete database provider
Update `lib/src/providers/database_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sync/core/entity_registry.dart';
import '../sync/core/entity_registry_setup.dart';
import '../data/local/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final entityRegistryProvider = Provider<EntityRegistry>((ref) {
  final registry = EntityRegistry();
  final db = ref.watch(databaseProvider);
  setupEntityRegistry(registry, db);
  return registry;
});

// DAO providers will be added as entities are implemented
// Example:
// final trainingPlanDaoProvider = Provider((ref) {
//   return ref.watch(databaseProvider).trainingPlanDao;
// });
```

### 3. Create database test helper
Create `test/helpers/database_helper.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';

/// Create an in-memory database for testing
AppDatabase createTestDatabase() {
  return AppDatabase.withConnection(
    NativeDatabase.memory(),
  );
}
```

Update `AppDatabase` to support test constructor:
```dart
// Add this constructor to AppDatabase class
AppDatabase.withConnection(QueryExecutor connection) : super(connection);
```

### 4. Create initial database test
Create `test/data/database_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/database_helper.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase', () {
    test('database can be created', () {
      expect(db, isNotNull);
    });

    test('database has correct schema version', () {
      expect(db.schemaVersion, equals(1));
    });

    // More tests will be added as tables are implemented
  });
}
```

### 5. Try code generation (will fail until first table is added)
```bash
cd front_shared
# This will fail because we have no tables yet - that's expected
# We'll run it successfully in step 07
# dart run build_runner build --delete-conflicting-outputs
```

## Success Criteria
- ✅ AppDatabase class structure created
- ✅ Database provider implemented with proper disposal
- ✅ Test database helper created
- ✅ Database connection setup with path_provider
- ✅ Migration strategy defined
- ✅ No compilation errors (except build_runner, which is expected)

## Estimated Time
45 minutes

## Next Step
07-first-entity-training-plan.md - Implement complete TrainingPlan entity as a pattern
