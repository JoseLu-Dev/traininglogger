import 'dart:async';
import '../../core/network/network_info.dart';
import 'sync_manager.dart';

/// Service that automatically triggers sync when connectivity is restored
class AutoSyncService {
  final SyncManager _syncManager;
  final NetworkInfo _networkInfo;
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline = false;

  AutoSyncService(this._syncManager, this._networkInfo);

  /// Start listening to connectivity changes
  void start() {
    _connectivitySubscription = _networkInfo.connectivityStream.listen((isConnected) {
      if (isConnected && _wasOffline) {
        // Connection restored, trigger sync
        print('Connection restored, triggering auto-sync');
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
