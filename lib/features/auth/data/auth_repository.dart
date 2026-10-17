import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exceptions.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';
import 'auth_api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApiService = ref.watch(authApiServiceProvider);
  return AuthRepositoryImpl(authApiService);
});

abstract class AuthRepository {
  Future<UserModel> login(LoginRequest request);
  Future<UserModel> register(RegisterRequest request);
  Future<void> forgotPassword(String email);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
  Future<bool> hasSession();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  UserModel? _currentUser;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<UserModel> login(LoginRequest request) async {
    try {
      final response = await _apiService.login(request);
      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        return _currentUser!;
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
        _currentUser = response.data!.user;
        return _currentUser!;
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
    final user = _currentUser;
    if (user == null) throw UnauthorizedException('No active mock session');
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<bool> hasSession() async => _currentUser != null;
}
