import 'package:uuid/uuid.dart';
import '../core/entity_registry.dart';
import '../core/sync_queue.dart';
import '../core/sync_state.dart' as sync_state;
import '../../data/remote/sync_api_service.dart';
import '../../data/remote/dto/sync_dtos.dart' as dto;
import '../../core/network/network_info.dart';
import '../../data/remote/api_client.dart';

class PushStrategy {
  final SyncApiService _syncApi;
  final NetworkInfo _networkInfo;
  final SyncQueue _syncQueue;
  final EntityRegistry _registry;

  PushStrategy(
    this._syncApi,
    this._networkInfo,
    this._syncQueue,
    this._registry,
  );

  /// Execute push: send all dirty entities to server
  Future<sync_state.SyncResult> execute() async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }

    // Get all dirty entities from registry
    final dirtyEntities = await _registry.getAllDirtyEntities();

    if (dirtyEntities.isEmpty) {
      return sync_state.SyncResult.success(
        pullCount: 0,
        pushCount: 0,
        timestamp: DateTime.now(),
      );
    }

    // Group entities by type for the API
    final groupedByType = <String, List<Map<String, dynamic>>>{};
    for (final entity in dirtyEntities) {
      final entityType = entity['_type'] as String;
      groupedByType.putIfAbsent(entityType, () => []);

      // Remove metadata fields before sending to server
      final cleanedEntity = Map<String, dynamic>.from(entity)
        ..remove('_type')
        ..remove('isDirty')
        ..remove('lastSyncedAt');

      groupedByType[entityType]!.add(cleanedEntity);
    }

    // Push to server
    final response = await _syncApi.push(
      dto.SyncPushRequestDto(entities: groupedByType),
    );

    // Handle failures - add to retry queue
    final failures = <sync_state.EntityFailure>[];
    for (final failure in response.failures) {
      // Convert DTO EntityFailure to sync_state EntityFailure
      failures.add(sync_state.EntityFailure(
        entityType: failure.entityType,
        entityId: failure.entityId,
        errors: failure.errors.map((e) => sync_state.ValidationError(
          field: e.field,
          code: e.code,
          message: e.message,
        )).toList(),
      ));

      // Find the original entity data to queue for retry
      final entityData = dirtyEntities.firstWhere(
        (e) => e['id'] == failure.entityId,
        orElse: () => <String, dynamic>{},
      );

      if (entityData.isNotEmpty) {
        _syncQueue.enqueue(QueuedSync(
          id: const Uuid().v4(),
          entityType: failure.entityType,
          entityId: failure.entityId,
          data: entityData,
          queuedAt: DateTime.now(),
          retryCount: 0,
          nextRetryAt: DateTime.now().add(const Duration(seconds: 30)),
        ));
      }
    }

    // Handle successful pushes
    // For successful entities, we need to infer which ones succeeded
    // by checking which ones are not in the failures list
    final failedIds = response.failures.map((f) => f.entityId).toSet();
    for (final entity in dirtyEntities) {
      final entityId = entity['id'] as String;
      final entityType = entity['_type'] as String;

      if (!failedIds.contains(entityId)) {
        // This entity succeeded
        final dao = _registry.getDao(entityType);
        if (dao != null) {
          // Clear dirty flag
          await dao.clearDirty(entityId, DateTime.now());
        }
      }
    }

    // Return result
    if (failures.isEmpty) {
      return sync_state.SyncResult.success(
        pullCount: 0,
        pushCount: response.successCount,
        timestamp: DateTime.now(),
      );
    } else {
      return sync_state.SyncResult.partialSuccess(
        pullCount: 0,
        pushSuccessCount: response.successCount,
        pushFailureCount: response.failureCount,
        failures: failures,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Retry failed syncs from the queue
  Future<int> retryQueuedSyncs() async {
    if (!await _networkInfo.isConnected) {
      return 0;
    }

    final dueRetries = _syncQueue.getDueRetries();
    if (dueRetries.isEmpty) {
      return 0;
    }

    int successCount = 0;

    // Group retries by entity type
    final groupedByType = <String, List<Map<String, dynamic>>>{};
    final retryMap = <String, QueuedSync>{}; // Map entityId -> QueuedSync

    for (final retry in dueRetries) {
      groupedByType.putIfAbsent(retry.entityType, () => []);

      final cleanedEntity = Map<String, dynamic>.from(retry.data)
        ..remove('_type')
        ..remove('isDirty')
        ..remove('lastSyncedAt');

      groupedByType[retry.entityType]!.add(cleanedEntity);
      retryMap[retry.entityId] = retry;
    }

    try {
      final response = await _syncApi.push(
        dto.SyncPushRequestDto(entities: groupedByType),
      );

      // Handle successes - entities not in failures list
      final failedIds = response.failures.map((f) => f.entityId).toSet();
      for (final retry in dueRetries) {
        if (!failedIds.contains(retry.entityId)) {
          // Success
          final dao = _registry.getDao(retry.entityType);
          if (dao != null) {
            await dao.clearDirty(retry.entityId, DateTime.now());
          }

          // Remove from queue
          _syncQueue.remove(retry.id);
          successCount++;
        }
      }

      // Handle failures - increment retry count or remove if max retries reached
      for (final failure in response.failures) {
        final queued = retryMap[failure.entityId];
        if (queued != null) {
          if (queued.canRetry) {
            _syncQueue.remove(queued.id);
            _syncQueue.enqueue(queued.incrementRetry());
          } else {
            // Max retries reached, remove from queue
            _syncQueue.remove(queued.id);
            print('Max retries reached for ${failure.entityType}:${failure.entityId}');
          }
        }
      }
    } catch (e) {
      print('Error during retry: $e');
      // Don't remove from queue, will retry later
    }

    return successCount;
  }
}
