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

  // Generic read method
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  // Generic write method
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
