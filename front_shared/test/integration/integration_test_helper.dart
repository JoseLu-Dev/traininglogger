import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';
import 'package:front_shared/src/sync/core/entity_registry_setup.dart';
import 'package:front_shared/src/sync/core/sync_manager.dart';
import 'package:front_shared/src/sync/strategies/pull_strategy.dart';
import 'package:front_shared/src/sync/strategies/push_strategy.dart';
import 'package:front_shared/src/sync/core/sync_queue.dart';
import '../helpers/database_helper.dart';

/// Helper class for integration tests
class IntegrationTestHelper {
  late AppDatabase db;
  late EntityRegistry registry;
  late SyncQueue syncQueue;

  Future<void> setUp() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider for LogService
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });

    db = createTestDatabase();
    registry = EntityRegistry();
    setupEntityRegistry(registry, db);
    syncQueue = SyncQueue();
  }

  Future<void> tearDown() async {
    await db.close();
  }

  /// Create a sync manager with mock API
  SyncManager createSyncManager({
    required dynamic mockApi,
    required dynamic mockNetworkInfo,
    required dynamic mockStorage,
  }) {
    final pullStrategy = PullStrategy(mockApi, mockNetworkInfo, registry);
    final pushStrategy = PushStrategy(mockApi, mockNetworkInfo, syncQueue, registry);

    return SyncManager(
      pullStrategy,
      pushStrategy,
      syncQueue,
      mockNetworkInfo,
      mockStorage,
    );
  }
}
