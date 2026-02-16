import 'dart:async';
import '../strategies/pull_strategy.dart';
import '../strategies/push_strategy.dart';
import 'sync_queue.dart';
import 'sync_state.dart';
import '../../core/network/network_info.dart';
import '../../data/local/secure_storage/secure_storage_service.dart';
import '../../core/logging/app_logger.dart';

class SyncManager {
  final PullStrategy _pullStrategy;
  final PushStrategy _pushStrategy;
  final SyncQueue _syncQueue;
  final NetworkInfo _networkInfo;
  final SecureStorageService _storage;
  final _log = AppLogger.forClass(SyncManager);

  final _stateController = StreamController<SyncState>.broadcast();
  Timer? _retryTimer;
  bool _isSyncing = false;

  SyncManager(
    this._pullStrategy,
    this._pushStrategy,
    this._syncQueue,
    this._networkInfo,
    this._storage,
  );

  /// Stream of sync state changes
  Stream<SyncState> get state => _stateController.stream;

  /// Get current sync state
  SyncState get currentState => _currentState;
  SyncState _currentState = const SyncState.idle();

  /// Execute full sync: PULL → PUSH → RETRY
  Future<SyncResult> sync({
    String? athleteId,
    DateTime? since,
    List<String>? entityTypes,
  }) async {
    if (_isSyncing) {
      _log.warning('Sync already in progress, ignoring concurrent sync request');
      return SyncResult.failure(
        message: 'Sync already in progress',
        error: null,
        timestamp: DateTime.now(),
      );
    }

    _isSyncing = true;
    _updateState(const SyncState.syncing(phase: 'Starting'));

    _log.debug('sync() called - athleteId: $athleteId, since: $since, entityTypes: $entityTypes');

    try {
      // Get athleteId from storage if not provided
      final effectiveAthleteId = athleteId ?? await _getCurrentAthleteId();
      _log.debug('Syncing for athlete: $effectiveAthleteId');

      // Get last sync time from storage if not provided
      final effectiveSince = since ?? await _storage.getLastSyncTime();
      _log.debug('Syncing changes since: $effectiveSince');

      // Phase 1: PULL - Get changes from server
      _updateState(const SyncState.syncing(phase: 'Pulling changes from server'));
      final pullCount = await _pullStrategy.execute(
        athleteId: effectiveAthleteId,
        since: effectiveSince,
        entityTypes: entityTypes,
      );
      _log.info('PULL phase completed - $pullCount entities pulled from server');

      // Phase 2: PUSH - Send local changes to server
      _updateState(const SyncState.syncing(phase: 'Pushing local changes'));
      final pushResult = await _pushStrategy.execute();
      pushResult.when(
        success: (_, count, __) => _log.info('PUSH phase completed - $count entities pushed successfully'),
        partialSuccess: (_, successCount, failureCount, __, ___) =>
          _log.info('PUSH phase partial success - $successCount succeeded, $failureCount failed'),
        failure: (msg, __, ___) => _log.warning('PUSH phase failed - $msg'),
      );

      // Phase 3: RETRY - Process retry queue
      _updateState(const SyncState.syncing(phase: 'Retrying failed syncs'));
      final retryCount = await _pushStrategy.retryQueuedSyncs();
      if (retryCount > 0) {
        _log.info('RETRY phase completed - $retryCount entities retried successfully');
      } else {
        _log.debug('RETRY phase completed - no entities in retry queue');
      }

      // Build final result
      final finalResult = _buildFinalResult(pushResult, pullCount, retryCount);

      // Save current timestamp as last sync time on success (in UTC)
      final syncTimestamp = DateTime.now().toUtc();
      _log.debug('Saving last sync time: $syncTimestamp');
      await _storage.saveLastSyncTime(syncTimestamp);

      final pushCount = finalResult.when(
        success: (_, count, __) => count,
        partialSuccess: (_, successCount, __, ___, ____) => successCount,
        failure: (_, __, ___) => 0,
      );
      _log.info('Sync completed successfully - Pull: $pullCount, Push: $pushCount, Retry: $retryCount');

      _updateState(SyncState.completed(finalResult));
      return finalResult;
    } catch (e, stackTrace) {
      _log.error('Sync error', e, stackTrace);
      final errorResult = SyncResult.failure(
        message: e.toString(),
        error: e,
        timestamp: DateTime.now(),
      );
      _updateState(SyncState.error(e.toString()));
      return errorResult;
    } finally {
      _isSyncing = false;
    }
  }

  /// Start automatic retry timer (checks every 60 seconds)
  void startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      if (!_isSyncing && await _networkInfo.isConnected) {
        await _processRetryQueue();
      }
    });
    _log.debug('Retry timer started - checking every 60 seconds');
  }

  /// Stop automatic retry timer
  void stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _log.debug('Retry timer stopped');
  }

  /// Process retry queue manually
  Future<void> _processRetryQueue() async {
    if (_syncQueue.length == 0) {
      _log.debug('Retry queue empty, skipping processing');
      return;
    }

    final queueBefore = _syncQueue.length;
    _log.debug('Processing retry queue - $queueBefore entities pending');

    try {
      _updateState(const SyncState.syncing(phase: 'Processing retry queue'));
      final retryCount = await _pushStrategy.retryQueuedSyncs();
      if (retryCount > 0) {
        _log.info('Successfully retried $retryCount of $queueBefore entities, ${_syncQueue.length} remaining in queue');
      }
      _updateState(const SyncState.idle());
    } catch (e) {
      _log.error('Error processing retry queue', e);
      _updateState(const SyncState.idle());
    }
  }

  /// Get current athlete ID from storage
  Future<String> _getCurrentAthleteId() async {
    final userId = await _storage.getUserId();
    if (userId == null) {
      _log.error('No authenticated user found', null, StackTrace.current);
      throw Exception('No authenticated user found');
    }
    return userId;
  }

  /// Build final sync result
  SyncResult _buildFinalResult(
    SyncResult pushResult,
    int pullCount,
    int retryCount,
  ) {
    return pushResult.when(
      success: (_, pushCount, timestamp) {
        return SyncResult.success(
          pullCount: pullCount,
          pushCount: pushCount + retryCount,
          timestamp: timestamp,
        );
      },
      partialSuccess: (_, pushSuccessCount, pushFailureCount, failures, timestamp) {
        return SyncResult.partialSuccess(
          pullCount: pullCount,
          pushSuccessCount: pushSuccessCount + retryCount,
          pushFailureCount: pushFailureCount,
          failures: failures,
          timestamp: timestamp,
        );
      },
      failure: (message, error, timestamp) {
        return SyncResult.failure(
          message: message,
          error: error,
          timestamp: timestamp,
        );
      },
    );
  }

  /// Update state and notify listeners
  void _updateState(SyncState state) {
    _currentState = state;
    _stateController.add(state);
  }

  /// Get sync queue length
  int get queueLength => _syncQueue.length;

  /// Clear sync queue (for testing/debugging)
  void clearQueue() => _syncQueue.clear();

  /// Dispose resources
  void dispose() {
    stopRetryTimer();
    _stateController.close();
    _log.debug('SyncManager disposed');
  }
}
