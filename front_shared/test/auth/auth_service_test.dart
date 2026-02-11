import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/auth/auth_service.dart';
import 'package:front_shared/src/data/remote/auth_api_service.dart';
import 'package:front_shared/src/data/local/secure_storage/secure_storage_service.dart';
import 'package:front_shared/src/core/network/network_info.dart';
import 'package:front_shared/src/data/remote/dto/auth_dtos.dart';

@GenerateMocks([AuthApiService, SecureStorageService, NetworkInfo])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockAuthApiService mockAuthApi;
  late MockSecureStorageService mockStorage;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockAuthApi = MockAuthApiService();
    mockStorage = MockSecureStorageService();
    mockNetworkInfo = MockNetworkInfo();
    authService = AuthService(mockAuthApi, mockStorage, mockNetworkInfo);
  });

  group('AuthService', () {
    test('online login saves credentials', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockAuthApi.login(any, any)).thenAnswer((_) async =>
          const LoginResponseDto(
            id: 'user-1',
            email: 'test@example.com',
            role: 'ATHLETE',
            coachId: null,
          ));
      when(mockStorage.savePasswordHash(any)).thenAnswer((_) async => {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async => {});
      when(mockStorage.saveUserRole(any)).thenAnswer((_) async => {});

      final result = await authService.login('test@example.com', 'password');

      verify(mockStorage.saveUserId('user-1')).called(1);
      verify(mockStorage.saveUserRole('ATHLETE')).called(1);
      verify(mockStorage.savePasswordHash(any)).called(1);

      result.when(
        initial: () => fail('Expected authenticated'),
        loading: () => fail('Expected authenticated'),
        authenticated: (id, email, role, coachId, isOffline) {
          expect(id, equals('user-1'));
          expect(email, equals('test@example.com'));
          expect(role, equals('ATHLETE'));
          expect(isOffline, isFalse);
        },
        unauthenticated: () => fail('Expected authenticated'),
        error: (_) => fail('Expected authenticated'),
      );
    });

    test('offline login validates password hash', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockStorage.getPasswordHash()).thenAnswer((_) async =>
          '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'); // 'password'
      when(mockStorage.getUserId()).thenAnswer((_) async => 'user-1');
      when(mockStorage.getUserRole()).thenAnswer((_) async => 'ATHLETE');
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);

      final result = await authService.login('test@example.com', 'password');

      verifyNever(mockAuthApi.login(any, any));

      result.when(
        initial: () => fail('Expected authenticated'),
        loading: () => fail('Expected authenticated'),
        authenticated: (id, email, role, coachId, isOffline) {
          expect(id, equals('user-1'));
          expect(email, equals('test@example.com'));
          expect(isOffline, isTrue);
        },
        unauthenticated: () => fail('Expected authenticated'),
        error: (_) => fail('Expected authenticated'),
      );
    });

    test('offline login fails with wrong password', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockStorage.getPasswordHash()).thenAnswer((_) async =>
          '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'); // 'password'

      final result = await authService.login('test@example.com', 'wrongpassword');

      result.when(
        initial: () => fail('Expected error'),
        loading: () => fail('Expected error'),
        authenticated: (_, __, ___, ____, _____) => fail('Expected error'),
        unauthenticated: () => fail('Expected error'),
        error: (message) {
          expect(message, contains('Invalid credentials'));
        },
      );
    });

    test('offline login fails without cached credentials', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockStorage.getPasswordHash()).thenAnswer((_) async => null);

      final result = await authService.login('test@example.com', 'password');

      result.when(
        initial: () => fail('Expected error'),
        loading: () => fail('Expected error'),
        authenticated: (_, __, ___, ____, _____) => fail('Expected error'),
        unauthenticated: () => fail('Expected error'),
        error: (message) {
          expect(message, contains('previous online login'));
        },
      );
    });

    test('logout clears all credentials', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockAuthApi.logout()).thenAnswer((_) async => {});
      when(mockStorage.clearAll()).thenAnswer((_) async => {});

      await authService.logout();

      verify(mockAuthApi.logout()).called(1);
      verify(mockStorage.clearAll()).called(1);
    });

    test('online login with coachId saves coachId', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockAuthApi.login(any, any)).thenAnswer((_) async =>
          const LoginResponseDto(
            id: 'user-2',
            email: 'athlete@example.com',
            role: 'ATHLETE',
            coachId: 'coach-1',
          ));
      when(mockStorage.savePasswordHash(any)).thenAnswer((_) async => {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async => {});
      when(mockStorage.saveUserRole(any)).thenAnswer((_) async => {});
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async => {});

      final result = await authService.login('athlete@example.com', 'password');

      verify(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).called(1);

      result.when(
        initial: () => fail('Expected authenticated'),
        loading: () => fail('Expected authenticated'),
        authenticated: (id, email, role, coachId, isOffline) {
          expect(id, equals('user-2'));
          expect(coachId, equals('coach-1'));
        },
        unauthenticated: () => fail('Expected authenticated'),
        error: (_) => fail('Expected authenticated'),
      );
    });

    test('checkAuthStatus returns authenticated when user is cached', () async {
      when(mockStorage.getUserId()).thenAnswer((_) async => 'user-1');
      when(mockStorage.getUserRole()).thenAnswer((_) async => 'COACH');
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      final result = await authService.checkAuthStatus();

      result.when(
        initial: () => fail('Expected authenticated'),
        loading: () => fail('Expected authenticated'),
        authenticated: (id, email, role, coachId, isOffline) {
          expect(id, equals('user-1'));
          expect(role, equals('COACH'));
          expect(isOffline, isFalse);
        },
        unauthenticated: () => fail('Expected authenticated'),
        error: (_) => fail('Expected authenticated'),
      );
    });

    test('checkAuthStatus returns unauthenticated when no user cached', () async {
      when(mockStorage.getUserId()).thenAnswer((_) async => null);
      when(mockStorage.getUserRole()).thenAnswer((_) async => null);

      final result = await authService.checkAuthStatus();

      result.when(
        initial: () => fail('Expected unauthenticated'),
        loading: () => fail('Expected unauthenticated'),
        authenticated: (_, __, ___, ____, _____) => fail('Expected unauthenticated'),
        unauthenticated: () {
          // Success
        },
        error: (_) => fail('Expected unauthenticated'),
      );
    });

    test('logout clears credentials even when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockStorage.clearAll()).thenAnswer((_) async => {});

      await authService.logout();

      verifyNever(mockAuthApi.logout());
      verify(mockStorage.clearAll()).called(1);
    });

    test('online login handles authentication exception', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockAuthApi.login(any, any))
          .thenThrow(AuthenticationException('Invalid credentials'));

      final result = await authService.login('test@example.com', 'wrongpassword');

      result.when(
        initial: () => fail('Expected error'),
        loading: () => fail('Expected error'),
        authenticated: (_, __, ___, ____, _____) => fail('Expected error'),
        unauthenticated: () => fail('Expected error'),
        error: (message) {
          expect(message, equals('Invalid credentials'));
        },
      );
    });

    test('password hashing is consistent', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockAuthApi.login(any, any)).thenAnswer((_) async =>
          const LoginResponseDto(
            id: 'user-1',
            email: 'test@example.com',
            role: 'ATHLETE',
            coachId: null,
          ));
      when(mockStorage.savePasswordHash(any)).thenAnswer((_) async => {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async => {});
      when(mockStorage.saveUserRole(any)).thenAnswer((_) async => {});

      await authService.login('test@example.com', 'password');

      // Verify that the password hash is SHA-256 of 'password'
      final capturedHash = verify(mockStorage.savePasswordHash(captureAny)).captured.single;
      expect(capturedHash, equals('5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'));
    });
  });
}
