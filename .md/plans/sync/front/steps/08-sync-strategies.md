# Step 08: Sync Strategies

## Goal
Implement generic pull and push strategies that use the EntityRegistry to work with any entity type.

## Tasks

### 1. Create PullStrategy
Create `lib/src/sync/strategies/pull_strategy.dart`:
```dart
import '../core/entity_registry.dart';
import '../../data/remote/sync_api_service.dart';
import '../../core/network/network_info.dart';
import '../../data/remote/api_client.dart';

class PullStrategy {
  final SyncApiService _syncApi;
  final NetworkInfo _networkInfo;
  final EntityRegistry _registry;

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

    // Default to beginning of time if no since parameter
    final sinceDatetime = since ?? DateTime.fromMillisecondsSinceEpoch(0);

    // Pull changes from server
    final response = await _syncApi.pull(
      since: sinceDatetime,
      athleteId: athleteId,
      entityTypes: entityTypes,
    );

    int mergedCount = 0;

    // Process each entity type
    for (final entry in response.changesByType.entries) {
      final entityType = entry.key;
      final entities = entry.value;

      // Get DAO for this entity type
      final dao = _registry.getDao(entityType);
      if (dao == null) {
        // Unknown entity type, skip it
        print('Warning: Unknown entity type $entityType, skipping');
        continue;
      }

      // Process each entity
      for (final entityData in entities) {
        try {
          final entityId = entityData['id'] as String;

          // Deserialize to Drift data class
          final deserialized = _registry.deserialize(entityType, entityData);
          if (deserialized == null) {
            print('Warning: Failed to deserialize $entityType:$entityId');
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
            print('Skipping server version of $entityType:$entityId (local is dirty)');
          }
        } catch (e) {
          print('Error processing entity $entityType: $e');
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
```

### 2. Create PushStrategy
Create `lib/src/sync/strategies/push_strategy.dart`:
```dart
import 'package:uuid/uuid.dart';
import '../core/entity_registry.dart';
import '../core/sync_queue.dart';
import '../core/sync_state.dart';
import '../../data/remote/sync_api_service.dart';
import '../../data/remote/dto/sync_dtos.dart';
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
  Future<SyncResult> execute() async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }

    // Get all dirty entities from registry
    final dirtyEntities = await _registry.getAllDirtyEntities();

    if (dirtyEntities.isEmpty) {
      return SyncResult.success(
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
      SyncPushRequestDto(changes: groupedByType),
    );

    // Handle successful pushes
    for (final success in response.succeeded) {
      final dao = _registry.getDao(success.entityType);
      if (dao != null) {
        // Update local entity with server version (may have updated timestamps, etc.)
        final updated = _registry.deserialize(success.entityType, success.entity);
        if (updated != null) {
          await dao.upsertFromServer(updated);
        }

        // Clear dirty flag
        await dao.clearDirty(success.entityId, DateTime.now());
      }
    }

    // Handle failures - add to retry queue
    final failures = <EntityFailure>[];
    for (final failure in response.failed) {
      failures.add(EntityFailure(
        entityType: failure.entityType,
        entityId: failure.entityId,
        errors: failure.errors.map((e) => e.message).toList(),
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

    // Return result
    if (failures.isEmpty) {
      return SyncResult.success(
        pullCount: 0,
        pushCount: response.summary.succeeded,
        timestamp: DateTime.now(),
      );
    } else {
      return SyncResult.partialSuccess(
        pullCount: 0,
        pushSuccessCount: response.summary.succeeded,
        pushFailureCount: response.summary.failed,
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
        SyncPushRequestDto(changes: groupedByType),
      );

      // Handle successes
      for (final success in response.succeeded) {
        final dao = _registry.getDao(success.entityType);
        if (dao != null) {
          final updated = _registry.deserialize(success.entityType, success.entity);
          if (updated != null) {
            await dao.upsertFromServer(updated);
          }
          await dao.clearDirty(success.entityId, DateTime.now());
        }

        // Remove from queue
        final queued = retryMap[success.entityId];
        if (queued != null) {
          _syncQueue.remove(queued.id);
          successCount++;
        }
      }

      // Handle failures - increment retry count or remove if max retries reached
      for (final failure in response.failed) {
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
```

### 3. Create ConflictResolver (for future enhancements)
Create `lib/src/sync/strategies/conflict_resolver.dart`:
```dart
/// Conflict resolution strategy
/// Currently uses client-wins, but can be extended for other strategies
class ConflictResolver {
  /// Resolve conflict between local and server entity
  /// Returns true if local should be kept, false if server should be used
  bool resolveConflict({
    required dynamic local,
    required dynamic server,
    required ConflictResolutionStrategy strategy,
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.clientWins:
        // If local is dirty, it wins
        return (local as dynamic).isDirty;

      case ConflictResolutionStrategy.serverWins:
        // Server always wins
        return false;

      case ConflictResolutionStrategy.latestTimestamp:
        // Compare updatedAt timestamps
        final localTime = (local as dynamic).updatedAt as DateTime;
        final serverTime = (server as dynamic).updatedAt as DateTime;
        return localTime.isAfter(serverTime);

      case ConflictResolutionStrategy.highestVersion:
        // Compare version numbers
        final localVersion = (local as dynamic).version as int;
        final serverVersion = (server as dynamic).version as int;
        return localVersion > serverVersion;
    }
  }
}

enum ConflictResolutionStrategy {
  clientWins,
  serverWins,
  latestTimestamp,
  highestVersion,
}
```

### 4. Create sync providers
Create `lib/src/providers/sync_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sync/core/sync_queue.dart';
import '../sync/strategies/pull_strategy.dart';
import '../sync/strategies/push_strategy.dart';
import 'network_providers.dart';
import 'database_providers.dart';

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue();
});

final pullStrategyProvider = Provider<PullStrategy>((ref) {
  return PullStrategy(
    ref.watch(syncApiServiceProvider),
    ref.watch(networkInfoProvider),
    ref.watch(entityRegistryProvider),
  );
});

final pushStrategyProvider = Provider<PushStrategy>((ref) {
  return PushStrategy(
    ref.watch(syncApiServiceProvider),
    ref.watch(networkInfoProvider),
    ref.watch(syncQueueProvider),
    ref.watch(entityRegistryProvider),
  );
});
```

### 5. Create tests
Create `test/sync/pull_strategy_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/sync/strategies/pull_strategy.dart';
import 'package:front_shared/src/data/remote/sync_api_service.dart';
import 'package:front_shared/src/core/network/network_info.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';

@GenerateMocks([SyncApiService, NetworkInfo, EntityRegistry])
import 'pull_strategy_test.mocks.dart';

void main() {
  late PullStrategy pullStrategy;
  late MockSyncApiService mockSyncApi;
  late MockNetworkInfo mockNetworkInfo;
  late MockEntityRegistry mockRegistry;

  setUp(() {
    mockSyncApi = MockSyncApiService();
    mockNetworkInfo = MockNetworkInfo();
    mockRegistry = MockEntityRegistry();
    pullStrategy = PullStrategy(mockSyncApi, mockNetworkInfo, mockRegistry);
  });

  group('PullStrategy', () {
    test('throws NetworkException when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      expect(
        () => pullStrategy.execute(athleteId: 'athlete-1'),
        throwsA(isA<NetworkException>()),
      );
    });

    // More tests would go here
  });
}
```

Create `test/sync/push_strategy_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/sync/strategies/push_strategy.dart';

@GenerateMocks([SyncApiService, NetworkInfo, SyncQueue, EntityRegistry])
import 'push_strategy_test.mocks.dart';

void main() {
  late PushStrategy pushStrategy;
  late MockSyncApiService mockSyncApi;
  late MockNetworkInfo mockNetworkInfo;
  late MockSyncQueue mockSyncQueue;
  late MockEntityRegistry mockRegistry;

  setUp(() {
    mockSyncApi = MockSyncApiService();
    mockNetworkInfo = MockNetworkInfo();
    mockSyncQueue = MockSyncQueue();
    mockRegistry = MockEntityRegistry();
    pushStrategy = PushStrategy(
      mockSyncApi,
      mockNetworkInfo,
      mockSyncQueue,
      mockRegistry,
    );
  });

  group('PushStrategy', () {
    test('throws NetworkException when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      expect(
        () => pushStrategy.execute(),
        throwsA(isA<NetworkException>()),
      );
    });

    // More tests would go here
  });
}
```

## Success Criteria
- ✅ PullStrategy implemented with generic entity handling
- ✅ PushStrategy implemented with retry queue
- ✅ ConflictResolver created (client-wins strategy)
- ✅ Sync providers defined
- ✅ Unit tests created
- ✅ No compilation errors

## Estimated Time
2-3 hours

## Next Step
09-sync-manager.md - Implement SyncManager to orchestrate PULL→PUSH→RETRY flow
