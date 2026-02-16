import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/sync/strategies/pull_strategy.dart';
import 'package:front_shared/src/data/remote/sync_api_service.dart';
import 'package:front_shared/src/core/network/network_info.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';
import 'package:front_shared/src/data/remote/dto/sync_dtos.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';
import 'package:front_shared/src/data/remote/api_client.dart';

@GenerateMocks([SyncApiService, NetworkInfo, EntityRegistry, BaseDao])
import 'pull_strategy_test.mocks.dart';

void main() {
  late PullStrategy pullStrategy;
  late MockSyncApiService mockSyncApi;
  late MockNetworkInfo mockNetworkInfo;
  late MockEntityRegistry mockRegistry;

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

    test('successfully pulls and merges entities when online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRegistry.registeredEntityTypes).thenReturn(['TrainingPlan']);

      final mockDao = MockBaseDao();
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(mockDao);

      final planData = {
        'id': 'plan-1',
        'name': 'Test Plan',
        'description': 'A test plan',
        'athleteId': 'athlete-1',
        'coachId': 'coach-1',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'version': 1,
        'isDirty': false,
        'lastSyncedAt': DateTime.now().toIso8601String(),
      };

      final response = SyncPullResponseDto(
        entities: {
          'TrainingPlan': [planData]
        },
        syncTimestamp: DateTime.now(),
        totalEntities: 1,
      );

      when(mockSyncApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => response);

      // Mock deserialization
      final mockDeserialized = _MockTrainingPlan(
        id: 'plan-1',
        isDirty: false,
      );
      when(mockRegistry.deserialize('TrainingPlan', planData))
          .thenReturn(mockDeserialized);

      // Mock local lookup - entity doesn't exist locally
      when(mockDao.findById('plan-1')).thenAnswer((_) async => null);

      // Mock upsert
      when(mockDao.upsertFromServer(mockDeserialized))
          .thenAnswer((_) async => {});

      // Act
      final result = await pullStrategy.execute(athleteId: 'athlete-1');

      // Assert
      expect(result, 1);
      verify(mockSyncApi.pull(
        entityTypes: ['TrainingPlan'],
        lastSyncTime: null,
      )).called(1);
      verify(mockDao.upsertFromServer(mockDeserialized)).called(1);
    });

    test('skips server version when local entity is dirty', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRegistry.registeredEntityTypes).thenReturn(['TrainingPlan']);

      final mockDao = MockBaseDao();
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(mockDao);

      final planData = {
        'id': 'plan-1',
        'name': 'Test Plan',
        'description': 'A test plan',
        'athleteId': 'athlete-1',
        'coachId': 'coach-1',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'version': 1,
        'isDirty': false,
        'lastSyncedAt': DateTime.now().toIso8601String(),
      };

      final response = SyncPullResponseDto(
        entities: {
          'TrainingPlan': [planData]
        },
        syncTimestamp: DateTime.now(),
        totalEntities: 1,
      );

      when(mockSyncApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => response);

      // Mock deserialization
      final mockServerVersion = _MockTrainingPlan(
        id: 'plan-1',
        isDirty: false,
      );
      when(mockRegistry.deserialize('TrainingPlan', planData))
          .thenReturn(mockServerVersion);

      // Mock local lookup - entity exists and is dirty
      final mockLocalVersion = _MockTrainingPlan(
        id: 'plan-1',
        isDirty: true,
      );
      when(mockDao.findById('plan-1')).thenAnswer((_) async => mockLocalVersion);

      // Act
      final result = await pullStrategy.execute(athleteId: 'athlete-1');

      // Assert
      expect(result, 0); // No entities merged because local is dirty
      verify(mockDao.findById('plan-1')).called(1);
      verifyNever(mockDao.upsertFromServer(any));
    });

    test('skips unknown entity types', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRegistry.registeredEntityTypes).thenReturn([]);

      final planData = {
        'id': 'plan-1',
        'name': 'Test Plan',
      };

      final response = SyncPullResponseDto(
        entities: {
          'UnknownType': [planData]
        },
        syncTimestamp: DateTime.now(),
        totalEntities: 1,
      );

      when(mockSyncApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => response);

      when(mockRegistry.getDao('UnknownType')).thenReturn(null);

      // Act
      final result = await pullStrategy.execute(athleteId: 'athlete-1');

      // Assert
      expect(result, 0); // No entities merged
    });

    test('continues processing after individual entity error', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRegistry.registeredEntityTypes).thenReturn(['TrainingPlan']);

      final mockDao = MockBaseDao();
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(mockDao);

      final plan1Data = {
        'id': 'plan-1',
        'name': 'Test Plan 1',
        'athleteId': 'athlete-1',
        'coachId': 'coach-1',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'version': 1,
      };

      final plan2Data = {
        'id': 'plan-2',
        'name': 'Test Plan 2',
        'athleteId': 'athlete-1',
        'coachId': 'coach-1',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'version': 1,
      };

      final response = SyncPullResponseDto(
        entities: {
          'TrainingPlan': [plan1Data, plan2Data]
        },
        syncTimestamp: DateTime.now(),
        totalEntities: 2,
      );

      when(mockSyncApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => response);

      // First entity fails to deserialize
      when(mockRegistry.deserialize('TrainingPlan', plan1Data))
          .thenReturn(null);

      // Second entity succeeds
      final mockPlan2 = _MockTrainingPlan(id: 'plan-2', isDirty: false);
      when(mockRegistry.deserialize('TrainingPlan', plan2Data))
          .thenReturn(mockPlan2);
      when(mockDao.findById('plan-2')).thenAnswer((_) async => null);
      when(mockDao.upsertFromServer(mockPlan2)).thenAnswer((_) async => {});

      // Act
      final result = await pullStrategy.execute(athleteId: 'athlete-1');

      // Assert
      expect(result, 1); // Only second entity merged
      verify(mockDao.upsertFromServer(mockPlan2)).called(1);
    });

    test('uses specified entity types when provided', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final response = SyncPullResponseDto(
        entities: {},
        syncTimestamp: DateTime.now(),
        totalEntities: 0,
      );

      when(mockSyncApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => response);

      // Act
      await pullStrategy.execute(
        athleteId: 'athlete-1',
        entityTypes: ['TrainingPlan', 'Exercise'],
      );

      // Assert
      verify(mockSyncApi.pull(
        entityTypes: ['TrainingPlan', 'Exercise'],
        lastSyncTime: null,
      )).called(1);
    });

    test('passes since parameter to API when provided', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRegistry.registeredEntityTypes).thenReturn(['TrainingPlan']);

      final since = DateTime(2024, 1, 1);
      final response = SyncPullResponseDto(
        entities: {},
        syncTimestamp: DateTime.now(),
        totalEntities: 0,
      );

      when(mockSyncApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => response);

      // Act
      await pullStrategy.execute(
        athleteId: 'athlete-1',
        since: since,
      );

      // Assert
      verify(mockSyncApi.pull(
        entityTypes: ['TrainingPlan'],
        lastSyncTime: since,
      )).called(1);
    });

    test('updates existing clean entity with server version', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRegistry.registeredEntityTypes).thenReturn(['TrainingPlan']);

      final mockDao = MockBaseDao();
      when(mockRegistry.getDao('TrainingPlan')).thenReturn(mockDao);

      final planData = {
        'id': 'plan-1',
        'name': 'Updated Plan',
        'description': 'Updated description',
        'athleteId': 'athlete-1',
        'coachId': 'coach-1',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'version': 2,
        'isDirty': false,
        'lastSyncedAt': DateTime.now().toIso8601String(),
      };

      final response = SyncPullResponseDto(
        entities: {
          'TrainingPlan': [planData]
        },
        syncTimestamp: DateTime.now(),
        totalEntities: 1,
      );

      when(mockSyncApi.pull(
        entityTypes: anyNamed('entityTypes'),
        lastSyncTime: anyNamed('lastSyncTime'),
      )).thenAnswer((_) async => response);

      // Mock deserialization
      final mockServerVersion = _MockTrainingPlan(
        id: 'plan-1',
        isDirty: false,
      );
      when(mockRegistry.deserialize('TrainingPlan', planData))
          .thenReturn(mockServerVersion);

      // Mock local lookup - entity exists but is NOT dirty
      final mockLocalVersion = _MockTrainingPlan(
        id: 'plan-1',
        isDirty: false,
      );
      when(mockDao.findById('plan-1')).thenAnswer((_) async => mockLocalVersion);
      when(mockDao.upsertFromServer(mockServerVersion))
          .thenAnswer((_) async => {});

      // Act
      final result = await pullStrategy.execute(athleteId: 'athlete-1');

      // Assert
      expect(result, 1);
      verify(mockDao.upsertFromServer(mockServerVersion)).called(1);
    });
  });
}

// Mock training plan for testing
class _MockTrainingPlan {
  final String id;
  final bool isDirty;

  _MockTrainingPlan({
    required this.id,
    required this.isDirty,
  });
}
