import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:front_shared/src/data/local/secure_storage/secure_storage_service.dart';

import 'secure_storage_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(mockStorage);
  });

  group('SecureStorageService', () {
    group('Password Hash', () {
      test('should save password hash', () async {
        // arrange
        const hash = 'test_hash_123';
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => {});

        // act
        await service.savePasswordHash(hash);

        // assert
        verify(mockStorage.write(key: 'password_hash', value: hash));
      });

      test('should get password hash', () async {
        // arrange
        const hash = 'test_hash_123';
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => hash);

        // act
        final result = await service.getPasswordHash();

        // assert
        expect(result, hash);
        verify(mockStorage.read(key: 'password_hash'));
      });

      test('should return null when password hash does not exist', () async {
        // arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        // act
        final result = await service.getPasswordHash();

        // assert
        expect(result, null);
        verify(mockStorage.read(key: 'password_hash'));
      });
    });

    group('User ID', () {
      test('should save user id', () async {
        // arrange
        const userId = 'user123';
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => {});

        // act
        await service.saveUserId(userId);

        // assert
        verify(mockStorage.write(key: 'user_id', value: userId));
      });

      test('should get user id', () async {
        // arrange
        const userId = 'user123';
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => userId);

        // act
        final result = await service.getUserId();

        // assert
        expect(result, userId);
        verify(mockStorage.read(key: 'user_id'));
      });

      test('should return null when user id does not exist', () async {
        // arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        // act
        final result = await service.getUserId();

        // assert
        expect(result, null);
        verify(mockStorage.read(key: 'user_id'));
      });
    });

    group('User Role', () {
      test('should save user role', () async {
        // arrange
        const role = 'ATHLETE';
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => {});

        // act
        await service.saveUserRole(role);

        // assert
        verify(mockStorage.write(key: 'user_role', value: role));
      });

      test('should get user role', () async {
        // arrange
        const role = 'ATHLETE';
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => role);

        // act
        final result = await service.getUserRole();

        // assert
        expect(result, role);
        verify(mockStorage.read(key: 'user_role'));
      });

      test('should return null when user role does not exist', () async {
        // arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        // act
        final result = await service.getUserRole();

        // assert
        expect(result, null);
        verify(mockStorage.read(key: 'user_role'));
      });
    });

    group('Clear All', () {
      test('should clear all stored data', () async {
        // arrange
        when(mockStorage.deleteAll()).thenAnswer((_) async => {});

        // act
        await service.clearAll();

        // assert
        verify(mockStorage.deleteAll());
      });
    });

    group('Integration', () {
      test('should handle multiple operations in sequence', () async {
        // arrange
        const hash = 'hash123';
        const userId = 'user456';
        const role = 'COACH';

        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => {});
        when(mockStorage.read(key: 'password_hash'))
            .thenAnswer((_) async => hash);
        when(mockStorage.read(key: 'user_id'))
            .thenAnswer((_) async => userId);
        when(mockStorage.read(key: 'user_role'))
            .thenAnswer((_) async => role);

        // act
        await service.savePasswordHash(hash);
        await service.saveUserId(userId);
        await service.saveUserRole(role);

        final savedHash = await service.getPasswordHash();
        final savedUserId = await service.getUserId();
        final savedRole = await service.getUserRole();

        // assert
        expect(savedHash, hash);
        expect(savedUserId, userId);
        expect(savedRole, role);
      });

      test('should handle clear after saving data', () async {
        // arrange
        const hash = 'hash123';
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => {});
        when(mockStorage.deleteAll()).thenAnswer((_) async => {});

        // act
        await service.savePasswordHash(hash);
        await service.clearAll();

        // assert
        verify(mockStorage.write(key: 'password_hash', value: hash));
        verify(mockStorage.deleteAll());
      });
    });
  });
}
