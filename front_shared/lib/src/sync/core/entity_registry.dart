import '../../data/local/database/daos/base_dao.dart';
import 'package:drift/drift.dart';
import '../../core/logging/app_logger.dart';

/// Generic registry that maps entity types to their DAOs and serialization functions
/// This allows sync strategies to work with any entity without switch statements
class EntityRegistry {
  final Map<String, BaseDao> _daoMap = {};
  final Map<String, Function(Map<String, dynamic>)> _deserializers = {};
  final Map<String, Function(dynamic)> _serializers = {};
  final Map<String, Function(dynamic)> _toDomainConverters = {};
  final _log = AppLogger.forClass(EntityRegistry);

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
    _serializers[entityType] = (data) => toJson(data as D);
    if (toDomain != null) {
      _toDomainConverters[entityType] = (data) => toDomain(data as D);
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
        _log.error('Error fetching dirty entities for $entityType', e);
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
