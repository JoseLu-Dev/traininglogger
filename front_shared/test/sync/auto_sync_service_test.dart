import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/sync/core/auto_sync_service.dart';
import 'package:front_shared/src/sync/core/sync_manager.dart';
import 'package:front_shared/src/sync/core/sync_state.dart';
import 'package:front_shared/src/core/network/network_info.dart';
import 'package:front_shared/src/core/logging/log_service.dart';

@GenerateMocks([
  SyncManager,
  NetworkInfo,
])
import 'auto_sync_service_test.mocks.dart';

void main() {
  late AutoSyncService autoSyncService;
  late MockSyncManager mockSyncManager;
  late MockNetworkInfo mockNetworkInfo;
  late StreamController<bool> connectivityController;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider for LogService
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });

    // Configure LogService for tests
    LogService.configure('test');

    mockSyncManager = MockSyncManager();
    mockNetworkInfo = MockNetworkInfo();
    connectivityController = StreamController<bool>.broadcast();

    when(mockNetworkInfo.connectivityStream).thenAnswer((_) => connectivityController.stream);
    when(mockSyncManager.sync(
      athleteId: anyNamed('athleteId'),
      since: anyNamed('since'),
      entityTypes: anyNamed('entityTypes'),
    )).thenAnswer((_) async => SyncResult.success(
      pullCount: 0,
      pushCount: 0,
      timestamp: DateTime.now(),
    ));

    autoSyncService = AutoSyncService(mockSyncManager, mockNetworkInfo);
  });

  tearDown(() {
    autoSyncService.stop();
    connectivityController.close();
  });

  group('AutoSyncService', () {
    test('triggers sync when connectivity is restored', () async {
      autoSyncService.start();

      // Simulate going offline
      connectivityController.add(false);
      await Future.delayed(const Duration(milliseconds: 50));

      // Then coming back online
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should have triggered sync
      verify(mockSyncManager.sync()).called(1);
    });

    test('does not trigger sync when staying online', () async {
      autoSyncService.start();

      // Stay online
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should not have triggered sync (no transition from offline to online)
      verifyNever(mockSyncManager.sync());
    });

    test('does not trigger sync when going offline', () async {
      autoSyncService.start();

      // Start online
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Go offline
      connectivityController.add(false);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should not have triggered sync
      verifyNever(mockSyncManager.sync());
    });

    test('triggers sync only on transition from offline to online', () async {
      autoSyncService.start();

      // Go offline
      connectivityController.add(false);
      await Future.delayed(const Duration(milliseconds: 50));

      // Come back online
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Go offline again
      connectivityController.add(false);
      await Future.delayed(const Duration(milliseconds: 50));

      // Come back online again
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should have triggered sync twice (each time we went from offline to online)
      verify(mockSyncManager.sync()).called(2);
    });

    test('stop cancels connectivity subscription', () async {
      autoSyncService.start();

      // Stop listening
      autoSyncService.stop();

      // Simulate connectivity change
      connectivityController.add(false);
      await Future.delayed(const Duration(milliseconds: 50));
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should not have triggered sync (not listening anymore)
      verifyNever(mockSyncManager.sync());
    });

    test('can restart after stopping', () async {
      autoSyncService.start();
      autoSyncService.stop();
      autoSyncService.start();

      // Go offline then online
      connectivityController.add(false);
      await Future.delayed(const Duration(milliseconds: 50));
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should have triggered sync
      verify(mockSyncManager.sync()).called(1);
    });

    test('handles multiple offline/online cycles correctly', () async {
      autoSyncService.start();

      // Cycle 1: offline -> online
      connectivityController.add(false);
      await Future.delayed(const Duration(milliseconds: 50));
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Cycle 2: stay online (no sync)
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Cycle 3: offline -> online
      connectivityController.add(false);
      await Future.delayed(const Duration(milliseconds: 50));
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should have triggered sync exactly 2 times
      verify(mockSyncManager.sync()).called(2);
    });
  });
}
