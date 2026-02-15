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

  // Last sync timestamp
  Future<void> saveLastSyncTime(DateTime timestamp) async {
    // Always store as UTC to ensure proper ISO 8601 format with 'Z' suffix
    await _storage.write(key: 'last_sync_time', value: timestamp.toUtc().toIso8601String());
  }

  Future<DateTime?> getLastSyncTime() async {
    final timestampStr = await _storage.read(key: 'last_sync_time');
    if (timestampStr == null) return null;
    try {
      // Parse and return as UTC
      return DateTime.parse(timestampStr).toUtc();
    } catch (e) {
      return null;
    }
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
