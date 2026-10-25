import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';
import 'auth_api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authApiServiceProvider),
    ref.watch(secureStorageServiceProvider),
  );
});

abstract class AuthRepository {
  Future<UserModel> login(LoginRequest request);
  Future<UserModel> register(RegisterRequest request);
  Future<void> forgotPassword(String email);
  Future<UserModel?> restoreSession();
  Future<void> updateCachedUser(UserModel user);
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _secureStorage;
  UserModel? _currentUser;

  AuthRepositoryImpl(this._apiService, this._secureStorage);

  @override
  Future<UserModel> login(LoginRequest request) async {
    final response = await _apiService.login(request);
    return _saveSession(response);
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    final response = await _apiService.register(request);
    return _saveSession(response);
  }

  Future<UserModel> _saveSession(AuthResponse response) async {
    final user = response.user;
    try {
      await _secureStorage.saveSession(
        accessToken: response.token,
        userJson: jsonEncode(user.toJson()),
      );
    } catch (_) {
      await _secureStorage.clearSession();
      rethrow;
    }

    _currentUser = user;
    return user;
  }

  @override
  Future<void> forgotPassword(String email) async {
    final response = await _apiService.forgotPassword(email);
    if (!response.success) {
      throw ApiException(
        response.message ?? 'Password recovery could not be completed.',
      );
    }
    if (response.message == 'Password recovery is not available yet.') {
      throw ApiException(response.message!);
    }
  }

  @override
  Future<UserModel?> restoreSession() async {
    final token = await _secureStorage.getAccessToken();
    final userJson = await _secureStorage.getStoredUser();
    if (token == null ||
        token.isEmpty ||
        userJson == null ||
        !_tokenHasValidExpiry(token)) {
      await logout();
      return null;
    }

    try {
      final decoded = jsonDecode(userJson);
      if (decoded is! Map) throw const FormatException();
      _currentUser = UserModel.fromJson(Map<String, dynamic>.from(decoded));
      return _currentUser;
    } catch (_) {
      await logout();
      return null;
    }
  }

  @override
  Future<void> updateCachedUser(UserModel user) async {
    await _secureStorage.writeValue(
      key: 'auth_user',
      value: jsonEncode(user.toJson()),
    );
    _currentUser = user;
  }

  bool _tokenHasValidExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map || payload['exp'] is! num) return false;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        (payload['exp'] as num).toInt() * 1000,
        isUtc: true,
      );
      return expiresAt.isAfter(DateTime.now().toUtc());
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _secureStorage.clearSession();
  }
}
