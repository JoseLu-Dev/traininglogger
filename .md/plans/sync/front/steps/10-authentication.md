# Step 10: Authentication

## Goal
Implement offline-first authentication that caches credentials securely and allows offline login.

## Tasks

### 1. Create AuthState
Create `lib/src/auth/auth_state.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required String id,
    required String email,
    required String role, // 'COACH' or 'ATHLETE' (uppercase)
    String? coachId,
    @Default(false) bool isOffline,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

### 2. Create AuthApiService
Create `lib/src/data/remote/auth_api_service.dart`:
```dart
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'dto/auth_dtos.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  /// Login with email and password
  Future<LoginResponseDto> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login',
        data: {
          'email': email,  // Changed from 'username'
          'password': password,
        },
      );

      return LoginResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout (invalidate session)
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/api/v1/auth/logout');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return AuthenticationException('Invalid credentials');
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException('Connection error');
    }
    return Exception('Authentication failed: ${e.message}');
  }
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
```

### 3. Create Auth DTOs
Create `lib/src/data/remote/dto/auth_dtos.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

@freezed
class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    required String email,  // Changed from username
    required String password,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
}

@freezed
class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required String id,        // Changed from userId
    required String email,     // Changed from username
    required String role,      // Changed from userType, values: 'COACH' or 'ATHLETE'
    String? coachId,          // Added optional coachId
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}
```

### 4. Create AuthService
Create `lib/src/auth/auth_service.dart`:
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../data/remote/auth_api_service.dart';
import '../data/local/secure_storage/secure_storage_service.dart';
import '../core/network/network_info.dart';
import 'auth_state.dart';

class AuthService {
  final AuthApiService _authApi;
  final SecureStorageService _secureStorage;
  final NetworkInfo _networkInfo;

  AuthService(
    this._authApi,
    this._secureStorage,
    this._networkInfo,
  );

  /// Login with email and password
  /// If online: authenticates with server and caches credentials
  /// If offline: validates against cached password hash
  Future<AuthState> login(String email, String password) async {
    try {
      if (await _networkInfo.isConnected) {
        // Online login
        final response = await _authApi.login(email, password);

        // Cache credentials for offline use
        await _secureStorage.savePasswordHash(_hashPassword(password));
        await _secureStorage.saveUserId(response.id);
        await _secureStorage.saveUserRole(response.role);
        if (response.coachId != null) {
          await _secureStorage.write(key: 'coach_id', value: response.coachId!);
        }

        return AuthState.authenticated(
          id: response.id,
          email: response.email,
          role: response.role,
          coachId: response.coachId,
          isOffline: false,
        );
      } else {
        // Offline login - validate against cached hash
        final cachedHash = await _secureStorage.getPasswordHash();
        if (cachedHash == null) {
          return const AuthState.error(
            'Cannot login offline without a previous online login',
          );
        }

        final passwordHash = _hashPassword(password);
        if (passwordHash != cachedHash) {
          return const AuthState.error('Invalid credentials');
        }

        // Load cached user info
        final userId = await _secureStorage.getUserId();
        final userRole = await _secureStorage.getUserRole();
        final coachId = await _secureStorage.read(key: 'coach_id');

        if (userId == null || userRole == null) {
          return const AuthState.error('Cached credentials incomplete');
        }

        return AuthState.authenticated(
          id: userId,
          email: email,  // Use the email provided during offline login
          role: userRole,
          coachId: coachId,
          isOffline: true,
        );
      }
    } on AuthenticationException catch (e) {
      return AuthState.error(e.message);
    } catch (e) {
      return AuthState.error('Login failed: ${e.toString()}');
    }
  }

  /// Logout - clear all cached credentials
  Future<void> logout() async {
    try {
      if (await _networkInfo.isConnected) {
        await _authApi.logout();
      }
    } catch (e) {
      // Ignore errors during logout
      print('Error during logout: $e');
    } finally {
      // Always clear local credentials
      await _secureStorage.clearAll();
    }
  }

  /// Check if user is authenticated
  Future<AuthState> checkAuthStatus() async {
    final userId = await _secureStorage.getUserId();
    final userRole = await _secureStorage.getUserRole();

    if (userId == null || userRole == null) {
      return const AuthState.unauthenticated();
    }

    final coachId = await _secureStorage.read(key: 'coach_id');
    final isOffline = !await _networkInfo.isConnected;

    // Note: email is not cached for offline login, only verified via password hash
    // For a full implementation, consider caching email as well
    return AuthState.authenticated(
      id: userId,
      email: '', // TODO: Cache email during login for offline status checks
      role: userRole,
      coachId: coachId,
      isOffline: isOffline,
    );
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
```

### 5. Create Auth providers
Create `lib/src/providers/auth_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_service.dart';
import '../auth/auth_state.dart';
import '../data/remote/auth_api_service.dart';
import 'network_providers.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(apiClientProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(authApiServiceProvider),
    ref.watch(secureStorageProvider),
    ref.watch(networkInfoProvider),
  );
});

/// Auth state notifier for reactive auth state management
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();
    state = await _authService.checkAuthStatus();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    state = await _authService.login(email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState.unauthenticated();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
```

### 6. Run code generation
```bash
cd front_shared
dart run build_runner build --delete-conflicting-outputs
```

### 7. Create Auth tests
Create `test/auth/auth_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/auth/auth_service.dart';
import 'package:front_shared/src/auth/auth_state.dart';
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
      when(mockStorage.read(key: 'coach_id')).thenAnswer((_) async => null);

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

      await authService.logout();

      verify(mockAuthApi.logout()).called(1);
      verify(mockStorage.clearAll()).called(1);
    });
  });
}
```

## Success Criteria
- ✅ AuthState freezed model created
- ✅ AuthApiService with login/logout endpoints
- ✅ AuthService with offline login using password hash
- ✅ Auth DTOs created
- ✅ Auth providers with StateNotifier
- ✅ Code generation successful
- ✅ All tests pass

## Estimated Time
2 hours

## Next Step
11-integration-testing.md - Create end-to-end integration tests
