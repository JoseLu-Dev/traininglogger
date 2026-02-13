import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/src/providers/network_providers.dart';
import '../providers/sync_providers.dart';
import '../sync/core/sync_state.dart';

/// Widget that shows sync status
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return syncState.when(
      data: (state) {
        return state.when(
          idle: () => const SizedBox.shrink(),
          syncing: (phase) => _buildSyncingIndicator(phase),
          completed: (result) => _buildCompletedIndicator(result),
          error: (message) => _buildErrorIndicator(message),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => _buildErrorIndicator(error.toString()),
    );
  }

  Widget _buildSyncingIndicator(String phase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            phase,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedIndicator(SyncResult result) {
    return result.when(
      success: (pullCount, pushCount, _) {
        if (pullCount == 0 && pushCount == 0) {
          return const SizedBox.shrink();
        }
        return _buildMessage(
          'Synced: ↓$pullCount ↑$pushCount',
          Colors.green.shade100,
          Icons.check_circle,
        );
      },
      partialSuccess: (pullCount, pushSuccess, pushFail, _, __) {
        return _buildMessage(
          'Partial sync: ↑$pushSuccess succeeded, $pushFail failed',
          Colors.orange.shade100,
          Icons.warning,
        );
      },
      failure: (message, _, __) {
        return _buildMessage(
          'Sync failed',
          Colors.red.shade100,
          Icons.error,
        );
      },
    );
  }

  Widget _buildErrorIndicator(String message) {
    return _buildMessage(
      'Sync error',
      Colors.red.shade100,
      Icons.error,
    );
  }

  Widget _buildMessage(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Button to manually trigger sync
class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncManager = ref.watch(syncManagerProvider);

    return IconButton(
      icon: const Icon(Icons.sync),
      onPressed: () async {
        await syncManager.sync();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sync completed')),
          );
        }
      },
    );
  }
}

/// Offline indicator
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkInfo = ref.watch(networkInfoProvider);

    return FutureBuilder<bool>(
      future: networkInfo.isConnected,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 14),
                SizedBox(width: 6),
                Text(
                  'Offline',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
