import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/network/api_exceptions.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';
import 'auth_api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApiService = ref.watch(authApiServiceProvider);
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  return AuthRepositoryImpl(authApiService, secureStorageService);
});

abstract class AuthRepository {
  Future<UserModel> login(LoginRequest request);
  Future<UserModel> register(RegisterRequest request);
  Future<void> forgotPassword(String email);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
  Future<bool> hasToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._apiService, this._secureStorage);

  @override
  Future<UserModel> login(LoginRequest request) async {
    try {
      final response = await _apiService.login(request);
      if (response.success && response.data != null) {
        await _saveTokens(response.data!);
        return response.data!.user;
      } else {
        throw ApiException(response.message ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    try {
      final response = await _apiService.register(request);
      if (response.success && response.data != null) {
        await _saveTokens(response.data!);
        return response.data!.user;
      } else {
        throw ApiException(response.message ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiService.forgotPassword(email);
      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to send reset email');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        throw UnauthorizedException('No token found');
      }
      final response = await _apiService.me();
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw UnauthorizedException(response.message ?? 'Failed to fetch user');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearTokens();
  }

  @override
  Future<bool> hasToken() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveTokens(AuthResponse response) async {
    await _secureStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }
}
