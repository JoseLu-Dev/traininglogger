# Step 03: Network Layer

## Goal
Implement network detection, secure storage, and API client infrastructure.

## Tasks

### 1. Create NetworkInfo interface and implementation
Create `lib/src/core/network/network_info.dart`:
```dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectivityStream;
}
```

Create `lib/src/core/network/network_info_impl.dart`:
```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
```

### 2. Create SecureStorageService
Create `lib/src/data/local/secure_storage/secure_storage_service.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Token management removed - backend uses cookie-based authentication
  // Session cookies are automatically handled by Dio

  // Password hash for offline auth
  Future<void> savePasswordHash(String hash) async {
    await _storage.write(key: 'password_hash', value: hash);
  }

  Future<String?> getPasswordHash() async {
    return await _storage.read(key: 'password_hash');
  }

  // User info
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: 'user_id', value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: 'user_role', value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### 3. Create ApiClient with token refresh
Create `lib/src/data/remote/api_client.dart`:
```dart
import 'package:dio/dio.dart';
import '../local/secure_storage/secure_storage_service.dart';
import '../../core/api_constants.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // No authorization interceptor needed - cookies handled automatically by Dio
    // Session cookie (SESSION) is automatically sent with each request
  }

  Dio get dio => _dio;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
```

### 4. Create network providers
Create `lib/src/providers/network_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/network_info.dart';
import '../core/network/network_info_impl.dart';
import '../data/local/secure_storage/secure_storage_service.dart';
import '../data/remote/api_client.dart';

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  return SecureStorageService(storage);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureStorageProvider));
});
```

**Note on Cookie Management**: Dio automatically manages cookies via its default cookie jar. The backend sets a `SESSION` cookie on login, which Dio will automatically include in subsequent requests. No manual cookie handling is required.

## Success Criteria
- ✅ NetworkInfo interface and implementation created
- ✅ SecureStorageService with token/hash management implemented
- ✅ ApiClient with token refresh interceptor created
- ✅ Network providers defined
- ✅ No compilation errors

## Estimated Time
1.5 hours

## Next Step
04-sync-dtos.md - Create sync API DTOs and service
