import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../data/remote/auth_api_service.dart';
import '../data/local/secure_storage/secure_storage_service.dart';
import '../core/network/network_info.dart';
import '../core/logging/app_logger.dart';
import 'auth_state.dart';

class AuthService {
  final AuthApiService _authApi;
  final SecureStorageService _secureStorage;
  final NetworkInfo _networkInfo;
  final _log = AppLogger.forClass(AuthService);

  AuthService(
    this._authApi,
    this._secureStorage,
    this._networkInfo,
  );

  /// Login with email and password
  /// If online: authenticates with server and caches credentials
  /// If offline: validates against cached password hash
  Future<AuthState> login(String email, String password) async {
    _log.info('Login attempt for email: $email');
    try {
      if (await _networkInfo.isConnected) {
        // Online login
        final response = await _authApi.login(email, password);
        _log.info('Online login successful for user ${response.id} with role ${response.role}');

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
        _log.info('Attempting offline login for email: $email');
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

        _log.info('Offline login successful for user $userId');
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
    _log.info('Logout initiated');
    try {
      if (await _networkInfo.isConnected) {
        await _authApi.logout();
      }
    } catch (e) {
      // Ignore errors during logout
      _log.warning('Error during logout', e);
    } finally {
      // Always clear local credentials
      await _secureStorage.clearAll();
      _log.info('Logout completed and credentials cleared');
    }
  }

  /// Check if user is authenticated
  Future<AuthState> checkAuthStatus() async {
    final userId = await _secureStorage.getUserId();
    final userRole = await _secureStorage.getUserRole();

    if (userId == null || userRole == null) {
      _log.debug('Auth status check: user not authenticated');
      return const AuthState.unauthenticated();
    }

    final coachId = await _secureStorage.read(key: 'coach_id');
    final isOffline = !await _networkInfo.isConnected;

    // Note: email is not cached for offline login, only verified via password hash
    // For a full implementation, consider caching email as well
    _log.debug('Auth status check: user $userId authenticated (offline: $isOffline)');
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
