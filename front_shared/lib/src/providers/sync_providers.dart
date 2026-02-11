import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sync/core/sync_manager.dart';
import '../sync/core/sync_queue.dart';
import '../sync/core/sync_state.dart';
import '../sync/core/auto_sync_service.dart';
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

final syncManagerProvider = Provider<SyncManager>((ref) {
  final manager = SyncManager(
    ref.watch(pullStrategyProvider),
    ref.watch(pushStrategyProvider),
    ref.watch(syncQueueProvider),
    ref.watch(networkInfoProvider),
    ref.watch(secureStorageProvider),
  );

  // Start retry timer
  manager.startRetryTimer();

  // Dispose on cleanup
  ref.onDispose(() => manager.dispose());

  return manager;
});

final syncStateProvider = StreamProvider<SyncState>((ref) {
  final manager = ref.watch(syncManagerProvider);
  return manager.state;
});

final autoSyncServiceProvider = Provider<AutoSyncService>((ref) {
  final service = AutoSyncService(
    ref.watch(syncManagerProvider),
    ref.watch(networkInfoProvider),
  );

  // Start auto-sync
  service.start();

  // Stop on cleanup
  ref.onDispose(() => service.stop());

  return service;
});
