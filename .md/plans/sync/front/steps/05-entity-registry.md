# Step 05: Entity Registry

## Goal
Create a generic entity registry that maps entity types to DAOs and serialization functions, eliminating switch statements in sync strategies.

## Tasks

### 1. Create EntityRegistry
Create `lib/src/sync/core/entity_registry.dart`:
```dart
import '../../data/local/database/daos/base_dao.dart';
import 'package:drift/drift.dart';

/// Generic registry that maps entity types to their DAOs and serialization functions
/// This allows sync strategies to work with any entity without switch statements
class EntityRegistry {
  final Map<String, BaseDao> _daoMap = {};
  final Map<String, Function(Map<String, dynamic>)> _deserializers = {};
  final Map<String, Function(dynamic)> _serializers = {};
  final Map<String, Function(dynamic)> _toDomainConverters = {};

  /// Register an entity type with its DAO and serialization functions
  void register<T extends Table, D>({
    required String entityType,
    required BaseDao<T, D> dao,
    required D Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(D) toJson,
    Function(D)? toDomain,
  }) {
    _daoMap[entityType] = dao;
    _deserializers[entityType] = fromJson;
    _serializers[entityType] = toJson;
    if (toDomain != null) {
      _toDomainConverters[entityType] = toDomain;
    }
  }

  /// Get DAO for an entity type
  BaseDao? getDao(String entityType) => _daoMap[entityType];

  /// Get typed DAO for an entity type
  BaseDao<T, D>? getTypedDao<T extends Table, D>(String entityType) {
    final dao = _daoMap[entityType];
    return dao is BaseDao<T, D> ? dao : null;
  }

  /// Deserialize JSON to Drift data class
  D? deserialize<D>(String entityType, Map<String, dynamic> json) {
    final deserializer = _deserializers[entityType];
    if (deserializer == null) return null;
    return deserializer(json) as D?;
  }

  /// Serialize Drift data class to JSON
  Map<String, dynamic>? serialize(String entityType, dynamic data) {
    final serializer = _serializers[entityType];
    if (serializer == null) return null;
    return serializer(data);
  }

  /// Convert Drift data class to domain model (if registered)
  dynamic toDomain(String entityType, dynamic data) {
    final converter = _toDomainConverters[entityType];
    if (converter == null) return data;
    return converter(data);
  }

  /// Get all dirty entities from all registered DAOs
  Future<List<Map<String, dynamic>>> getAllDirtyEntities() async {
    final dirtyEntities = <Map<String, dynamic>>[];

    for (final entry in _daoMap.entries) {
      final entityType = entry.key;
      final dao = entry.value;

      try {
        final dirty = await dao.findAllDirty();
        for (final data in dirty) {
          final json = serialize(entityType, data);
          if (json != null) {
            // Add entity type as metadata for server
            dirtyEntities.add({'_type': entityType, ...json});
          }
        }
      } catch (e) {
        // Log error but continue with other entities
        print('Error fetching dirty entities for $entityType: $e');
      }
    }

    return dirtyEntities;
  }

  /// Get list of all registered entity types
  List<String> get registeredEntityTypes => _daoMap.keys.toList();

  /// Check if an entity type is registered
  bool isRegistered(String entityType) => _daoMap.containsKey(entityType);

  /// Clear all registrations (for testing)
  void clear() {
    _daoMap.clear();
    _deserializers.clear();
    _serializers.clear();
    _toDomainConverters.clear();
  }
}
```

### 2. Create registry setup function
Create `lib/src/sync/core/entity_registry_setup.dart`:
```dart
import 'entity_registry.dart';
import '../../data/local/database/app_database.dart';

/// Setup function to register all entities in the registry
/// This is called once during app initialization
void setupEntityRegistry(EntityRegistry registry, AppDatabase db) {
  // TODO: Register entities as they are implemented
  // Example:
  // registry.register(
  //   entityType: 'TrainingPlan',
  //   dao: db.trainingPlanDao,
  //   fromJson: (json) => TrainingPlanData.fromJson(json),
  //   toJson: (data) => (data as TrainingPlanData).toJson(),
  //   toDomain: (data) => db.trainingPlanDao.toDomain(data as TrainingPlanData),
  // );

  // Will be populated in step 07 when we implement the first entity
}
```

### 3. Create entity registry provider
Create `lib/src/providers/database_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sync/core/entity_registry.dart';
import '../sync/core/entity_registry_setup.dart';
import '../data/local/database/app_database.dart';

// Will be implemented in step 06
// final databaseProvider = Provider<AppDatabase>((ref) { ... });

final entityRegistryProvider = Provider<EntityRegistry>((ref) {
  final registry = EntityRegistry();
  final db = ref.watch(databaseProvider);
  setupEntityRegistry(registry, db);
  return registry;
});
```

### 4. Create tests for EntityRegistry
Create `test/sync/entity_registry_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';

@GenerateMocks([BaseDao])
import 'entity_registry_test.mocks.dart';

void main() {
  late EntityRegistry registry;

  setUp(() {
    registry = EntityRegistry();
  });

  group('EntityRegistry', () {
    test('register and retrieve DAO', () {
      final mockDao = MockBaseDao();

      registry.register(
        entityType: 'TestEntity',
        dao: mockDao,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      expect(registry.getDao('TestEntity'), equals(mockDao));
      expect(registry.isRegistered('TestEntity'), isTrue);
    });

    test('serialize and deserialize', () {
      final testData = {'id': '123', 'name': 'Test'};

      registry.register(
        entityType: 'TestEntity',
        dao: MockBaseDao(),
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      final serialized = registry.serialize('TestEntity', testData);
      expect(serialized, equals(testData));

      final deserialized = registry.deserialize('TestEntity', testData);
      expect(deserialized, equals(testData));
    });

    test('returns null for unregistered entity type', () {
      expect(registry.getDao('Unknown'), isNull);
      expect(registry.isRegistered('Unknown'), isFalse);
    });

    test('clear removes all registrations', () {
      registry.register(
        entityType: 'TestEntity',
        dao: MockBaseDao(),
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      registry.clear();
      expect(registry.isRegistered('TestEntity'), isFalse);
      expect(registry.registeredEntityTypes, isEmpty);
    });
  });
}
```

## Success Criteria
- ✅ EntityRegistry class created with generic DAO/mapper management
- ✅ Registration methods for entities implemented
- ✅ getAllDirtyEntities method works across all DAOs
- ✅ Entity registry provider defined
- ✅ Unit tests pass
- ✅ No compilation errors

## Estimated Time
1.5 hours

## Next Step
06-database-setup.md - Create AppDatabase and initial table structure
