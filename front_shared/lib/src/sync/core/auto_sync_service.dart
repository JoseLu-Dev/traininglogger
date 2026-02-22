import 'dart:async';
import '../../core/network/network_info.dart';
import '../../core/logging/app_logger.dart';
import 'sync_manager.dart';

/// Service that automatically triggers sync when connectivity is restored
class AutoSyncService {
  final SyncManager _syncManager;
  final NetworkInfo _networkInfo;
  final _log = AppLogger.forClass(AutoSyncService);
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline =
      true; //TODO check this and ensure is logged in, syncs after login

  AutoSyncService(this._syncManager, this._networkInfo);

  /// Start listening to connectivity changes
  void start() {
    _connectivitySubscription = _networkInfo.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected && _wasOffline) {
        // Connection restored, trigger sync
        _log.info('Connection restored, triggering auto-sync');
        _syncManager.sync();
      }
      _wasOffline = !isConnected;
    });
  }

  /// Stop listening to connectivity changes
  void stop() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
