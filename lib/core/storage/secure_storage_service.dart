import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'auth_user';

  Future<void> saveSession({
    required String accessToken,
    required String userJson,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _userDataKey, value: userJson);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getStoredUser() => _storage.read(key: _userDataKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> readValue(String key) => _storage.read(key: key);

  Future<void> writeValue({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  Future<void> deleteValue(String key) => _storage.delete(key: key);

  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
  }

  Future<void> clearTokens() => clearSession();
}
