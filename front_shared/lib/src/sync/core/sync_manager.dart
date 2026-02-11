import 'dart:async';
import '../strategies/pull_strategy.dart';
import '../strategies/push_strategy.dart';
import 'sync_queue.dart';
import 'sync_state.dart';
import '../../core/network/network_info.dart';
import '../../data/local/secure_storage/secure_storage_service.dart';

class SyncManager {
  final PullStrategy _pullStrategy;
  final PushStrategy _pushStrategy;
  final SyncQueue _syncQueue;
  final NetworkInfo _networkInfo;
  final SecureStorageService _storage;

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
      return SyncResult.failure(
        message: 'Sync already in progress',
        error: null,
        timestamp: DateTime.now(),
      );
    }

    _isSyncing = true;
    _updateState(const SyncState.syncing(phase: 'Starting'));

    try {
      // Get athleteId from storage if not provided
      final effectiveAthleteId = athleteId ?? await _getCurrentAthleteId();

      // Phase 1: PULL - Get changes from server
      _updateState(const SyncState.syncing(phase: 'Pulling changes from server'));
      final pullCount = await _pullStrategy.execute(
        athleteId: effectiveAthleteId,
        since: since,
        entityTypes: entityTypes,
      );

      // Phase 2: PUSH - Send local changes to server
      _updateState(const SyncState.syncing(phase: 'Pushing local changes'));
      final pushResult = await _pushStrategy.execute();

      // Phase 3: RETRY - Process retry queue
      _updateState(const SyncState.syncing(phase: 'Retrying failed syncs'));
      final retryCount = await _pushStrategy.retryQueuedSyncs();

      // Build final result
      final finalResult = _buildFinalResult(pushResult, pullCount, retryCount);

      _updateState(SyncState.completed(finalResult));
      return finalResult;
    } catch (e, stackTrace) {
      print('Sync error: $e\n$stackTrace');
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
  }

  /// Stop automatic retry timer
  void stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Process retry queue manually
  Future<void> _processRetryQueue() async {
    if (_syncQueue.length == 0) return;

    try {
      _updateState(const SyncState.syncing(phase: 'Processing retry queue'));
      final retryCount = await _pushStrategy.retryQueuedSyncs();
      if (retryCount > 0) {
        print('Successfully retried $retryCount entities');
      }
      _updateState(const SyncState.idle());
    } catch (e) {
      print('Error processing retry queue: $e');
      _updateState(const SyncState.idle());
    }
  }

  /// Get current athlete ID from storage
  Future<String> _getCurrentAthleteId() async {
    final userId = await _storage.getUserId();
    if (userId == null) {
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
  }
}
