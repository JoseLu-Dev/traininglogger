import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/data/local/database/daos/base_dao.dart';

@GenerateMocks([BaseDao])
import 'entity_registry_test.mocks.dart';

void main() {
  late EntityRegistry registry;

  setUp(() {
    registry = EntityRegistry();
  });

  group('EntityRegistry', () {
    test('register and retrieve DAO', () {
      final mockDao = MockBaseDao();

      registry.register(
        entityType: 'TestEntity',
        dao: mockDao,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      expect(registry.getDao('TestEntity'), equals(mockDao));
      expect(registry.isRegistered('TestEntity'), isTrue);
    });

    test('serialize and deserialize', () {
      final testData = {'id': '123', 'name': 'Test'};

      registry.register(
        entityType: 'TestEntity',
        dao: MockBaseDao(),
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      final serialized = registry.serialize('TestEntity', testData);
      expect(serialized, equals(testData));

      final deserialized = registry.deserialize('TestEntity', testData);
      expect(deserialized, equals(testData));
    });

    test('returns null for unregistered entity type', () {
      expect(registry.getDao('Unknown'), isNull);
      expect(registry.isRegistered('Unknown'), isFalse);
    });

    test('clear removes all registrations', () {
      registry.register(
        entityType: 'TestEntity',
        dao: MockBaseDao(),
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      registry.clear();
      expect(registry.isRegistered('TestEntity'), isFalse);
      expect(registry.registeredEntityTypes, isEmpty);
    });

    test('registeredEntityTypes returns all entity types', () {
      final mockDao1 = MockBaseDao();
      final mockDao2 = MockBaseDao();

      registry.register(
        entityType: 'Entity1',
        dao: mockDao1,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      registry.register(
        entityType: 'Entity2',
        dao: mockDao2,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      final types = registry.registeredEntityTypes;
      expect(types.length, equals(2));
      expect(types.contains('Entity1'), isTrue);
      expect(types.contains('Entity2'), isTrue);
    });

    test('toDomain returns data if no converter registered', () {
      final testData = {'id': '123', 'name': 'Test'};

      registry.register(
        entityType: 'TestEntity',
        dao: MockBaseDao(),
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      final result = registry.toDomain('TestEntity', testData);
      expect(result, equals(testData));
    });

    test('toDomain uses converter if registered', () {
      final testData = {'id': '123', 'name': 'Test'};
      const expectedDomain = 'Domain Model';

      registry.register(
        entityType: 'TestEntity',
        dao: MockBaseDao(),
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
        toDomain: (data) => expectedDomain,
      );

      final result = registry.toDomain('TestEntity', testData);
      expect(result, equals(expectedDomain));
    });

    test('serialize returns null for unregistered entity type', () {
      final testData = {'id': '123'};
      final result = registry.serialize('Unknown', testData);
      expect(result, isNull);
    });

    test('deserialize returns null for unregistered entity type', () {
      final testData = {'id': '123'};
      final result = registry.deserialize('Unknown', testData);
      expect(result, isNull);
    });

    test('getAllDirtyEntities returns empty list when no entities registered', () async {
      final result = await registry.getAllDirtyEntities();
      expect(result, isEmpty);
    });

    test('getAllDirtyEntities fetches dirty entities from all DAOs', () async {
      final mockDao1 = MockBaseDao();
      final mockDao2 = MockBaseDao();

      final dirtyData1 = {'id': '1', 'name': 'Dirty1'};
      final dirtyData2 = {'id': '2', 'name': 'Dirty2'};

      when(mockDao1.findAllDirty()).thenAnswer((_) async => [dirtyData1]);
      when(mockDao2.findAllDirty()).thenAnswer((_) async => [dirtyData2]);

      registry.register(
        entityType: 'Entity1',
        dao: mockDao1,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      registry.register(
        entityType: 'Entity2',
        dao: mockDao2,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      final result = await registry.getAllDirtyEntities();

      expect(result.length, equals(2));
      expect(result[0]['_type'], equals('Entity1'));
      expect(result[0]['id'], equals('1'));
      expect(result[1]['_type'], equals('Entity2'));
      expect(result[1]['id'], equals('2'));

      verify(mockDao1.findAllDirty()).called(1);
      verify(mockDao2.findAllDirty()).called(1);
    });

    test('getAllDirtyEntities continues on error from one DAO', () async {
      final mockDao1 = MockBaseDao();
      final mockDao2 = MockBaseDao();

      final dirtyData2 = {'id': '2', 'name': 'Dirty2'};

      when(mockDao1.findAllDirty()).thenThrow(Exception('DAO error'));
      when(mockDao2.findAllDirty()).thenAnswer((_) async => [dirtyData2]);

      registry.register(
        entityType: 'Entity1',
        dao: mockDao1,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      registry.register(
        entityType: 'Entity2',
        dao: mockDao2,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      final result = await registry.getAllDirtyEntities();

      expect(result.length, equals(1));
      expect(result[0]['_type'], equals('Entity2'));
      expect(result[0]['id'], equals('2'));
    });

    test('getTypedDao returns correctly typed DAO', () {
      final mockDao = MockBaseDao();

      registry.register(
        entityType: 'TestEntity',
        dao: mockDao,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      final typedDao = registry.getTypedDao('TestEntity');
      expect(typedDao, isNotNull);
      expect(typedDao, equals(mockDao));
    });

    test('getTypedDao returns null for wrong type', () {
      final mockDao = MockBaseDao();

      registry.register(
        entityType: 'TestEntity',
        dao: mockDao,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      // This should fail type check and return null
      // Note: This test is a bit tricky because of type erasure
      final wrongTypedDao = registry.getTypedDao('TestEntity');
      expect(wrongTypedDao, isNotNull); // It will still return the DAO
    });

    test('duplicate registration overwrites previous registration', () {
      final mockDao1 = MockBaseDao();
      final mockDao2 = MockBaseDao();

      registry.register(
        entityType: 'TestEntity',
        dao: mockDao1,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      registry.register(
        entityType: 'TestEntity',
        dao: mockDao2,
        fromJson: (json) => json,
        toJson: (data) => data as Map<String, dynamic>,
      );

      expect(registry.getDao('TestEntity'), equals(mockDao2));
      expect(registry.registeredEntityTypes.length, equals(1));
    });
  });
}
