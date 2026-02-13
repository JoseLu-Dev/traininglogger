import '../core/entity_registry.dart';
import '../../data/remote/sync_api_service.dart';
import '../../core/network/network_info.dart';
import '../../data/remote/api_client.dart';
import '../../core/logging/app_logger.dart';

class PullStrategy {
  final SyncApiService _syncApi;
  final NetworkInfo _networkInfo;
  final EntityRegistry _registry;
  final _log = AppLogger.forClass(PullStrategy);

  PullStrategy(
    this._syncApi,
    this._networkInfo,
    this._registry,
  );

  /// Execute pull: fetch changes from server and merge into local DB
  /// Returns the number of entities merged
  Future<int> execute({
    required String athleteId,
    DateTime? since,
    List<String>? entityTypes,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }

    // Default to all registered entity types if not specified
    final typesToSync = entityTypes ?? _registry.registeredEntityTypes;

    // Pull changes from server
    final response = await _syncApi.pull(
      entityTypes: typesToSync,
      lastSyncTime: since,
    );

    int mergedCount = 0;

    // Process each entity type
    for (final entry in response.entities.entries) {
      final entityType = entry.key;
      final entities = entry.value;

      // Get DAO for this entity type
      final dao = _registry.getDao(entityType);
      if (dao == null) {
        // Unknown entity type, skip it
        _log.warning('Unknown entity type $entityType, skipping');
        continue;
      }

      // Process each entity
      for (final entityData in entities) {
        try {
          final entityId = entityData['id'] as String;

          // Deserialize to Drift data class
          final deserialized = _registry.deserialize(entityType, entityData);
          if (deserialized == null) {
            _log.warning('Failed to deserialize $entityType:$entityId');
            continue;
          }

          // Check if we have a local version
          final local = await dao.findById(entityId);

          // Conflict resolution: client wins
          // Only update if local doesn't exist or local is not dirty
          if (local == null || !(local as dynamic).isDirty) {
            await dao.upsertFromServer(deserialized);
            mergedCount++;
          } else {
            // Local is dirty, skip server version (client wins)
            _log.debug('Skipping server version of $entityType:$entityId (local is dirty)');
          }
        } catch (e) {
          _log.error('Error processing entity $entityType', e);
          // Continue with next entity
        }
      }
    }

    return mergedCount;
  }

  /// Get the last sync timestamp for an athlete
  /// This can be used to optimize pull requests by only fetching changes since last sync
  Future<DateTime?> getLastSyncTimestamp(String athleteId) async {
    DateTime? lastSync;

    // Check all entity types for the most recent sync
    for (final entityType in _registry.registeredEntityTypes) {
      final dao = _registry.getDao(entityType);
      if (dao == null) continue;

      // This would require a new method on BaseDao to get last sync time
      // For now, we'll return null to always do a full sync
    }

    return lastSync;
  }
}
