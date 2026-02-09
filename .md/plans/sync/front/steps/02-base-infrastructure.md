# Step 02: Base Infrastructure

## Goal
Create the foundational base classes and interfaces that all entities will extend/implement.

## Tasks

### 1. Create SyncableEntity interface
Create `lib/src/domain/models/syncable_entity.dart`:
```dart
abstract class SyncableEntity {
  String get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  int get version;
  DateTime? get deletedAt;
  bool get isDirty;
  DateTime? get lastSyncedAt;
}
```

### 2. Create SyncableTable mixin
Create `lib/src/data/local/database/tables/base_table.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

mixin SyncableTable on Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 3. Create BaseDao abstract class
Create `lib/src/data/local/database/daos/base_dao.dart`:
```dart
import 'package:drift/drift.dart';
import '../app_database.dart';

abstract class BaseDao<T extends Table, D> extends DatabaseAccessor<AppDatabase> {
  BaseDao(AppDatabase db) : super(db);

  TableInfo<T, D> get table;

  Future<D?> findById(String id);
  Future<List<D>> findAllActive();
  Future<List<D>> findAllDirty();
  Future<void> markDirty(String id);
  Future<void> clearDirty(String id, DateTime syncedAt);
  Future<void> upsertFromServer(D entity);
  Future<void> softDelete(String id);
}
```

### 4. Create sync state models
Create `lib/src/sync/core/sync_state.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState.idle() = _Idle;
  const factory SyncState.syncing({required String phase}) = _Syncing;
  const factory SyncState.completed(SyncResult result) = _Completed;
  const factory SyncState.error(String message) = _Error;
}

@freezed
class SyncResult with _$SyncResult {
  const factory SyncResult.success({
    required int pullCount,
    required int pushCount,
    required DateTime timestamp,
  }) = _Success;

  const factory SyncResult.partialSuccess({
    required int pullCount,
    required int pushSuccessCount,
    required int pushFailureCount,
    required List<EntityFailure> failures,
    required DateTime timestamp,
  }) = _PartialSuccess;

  const factory SyncResult.failure({
    required String message,
    required Object? error,
    required DateTime timestamp,
  }) = _Failure;
}

@freezed
class EntityFailure with _$EntityFailure {
  const factory EntityFailure({
    required String entityType,
    required String entityId,
    required List<ValidationError> errors,  // Changed from List<String>
  }) = _EntityFailure;
}

@freezed
class ValidationError with _$ValidationError {
  const factory ValidationError({
    required String field,
    required String code,
    required String message,
  }) = _ValidationError;
}
```

### 5. Create sync queue model
Create `lib/src/sync/core/sync_queue.dart`:
```dart
import 'dart:collection';
import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_queue.freezed.dart';

@freezed
class QueuedSync with _$QueuedSync {
  const factory QueuedSync({
    required String id,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    required DateTime queuedAt,
    required int retryCount,
    required DateTime nextRetryAt,
  }) = _QueuedSync;

  const QueuedSync._();

  bool get canRetry => retryCount < 5;

  QueuedSync incrementRetry() => copyWith(
    retryCount: retryCount + 1,
    nextRetryAt: DateTime.now().add(
      Duration(seconds: (pow(2, retryCount) * 30).toInt())
    ),
  );
}

class SyncQueue {
  final Queue<QueuedSync> _queue = Queue();

  void enqueue(QueuedSync sync) {
    if (sync.canRetry) {
      _queue.add(sync);
    }
  }

  List<QueuedSync> getDueRetries() {
    return _queue.where((s) => s.nextRetryAt.isBefore(DateTime.now())).toList();
  }

  void remove(String syncId) {
    _queue.removeWhere((s) => s.id == syncId);
  }

  int get length => _queue.length;

  void clear() => _queue.clear();
}
```

### 6. Setup Entity Generator

Install code generation dependencies:
```bash
cd front_shared
flutter pub add drift freezed_annotation json_annotation uuid
flutter pub add dev:build_runner dev:drift_dev dev:freezed dev:json_serializable dev:mustache_template dev:yaml dev:recase
```

Create the entity generator tool and templates as documented in `/GENERATOR_GUIDE.md`. This generator will be used to create all entity boilerplate from simple YAML schemas, reducing code duplication by 70-80%.

The generator includes:
- `front_shared/tool/generate_entity.dart` - Main CLI script
- `front_shared/tool/templates/*.mustache` - 6 template files for generating entity code
- `front_shared/entities/*.yaml` - Entity schema definitions

**Benefits:**
- Reduces ~470 lines per entity to ~40 lines of YAML
- Saves 1-2 hours per entity (down to 15-20 minutes)
- Single source of truth for entity structure
- Consistent code across all entities

### 7. Run code generation
```bash
cd front_shared
dart run build_runner build --delete-conflicting-outputs
```

## Success Criteria
- ✅ SyncableEntity interface created
- ✅ SyncableTable mixin created with all sync fields
- ✅ BaseDao abstract class defined
- ✅ SyncState freezed models created
- ✅ SyncQueue with exponential backoff implemented
- ✅ Entity generator tool and templates created
- ✅ Code generation runs successfully

## Estimated Time
2-3 hours (includes 1-2 hours for generator setup)

## Next Step
03-network-layer.md - Implement network detection and API client
