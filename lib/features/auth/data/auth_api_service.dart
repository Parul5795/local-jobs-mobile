import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApiServiceImpl(apiClient);
});

abstract class AuthApiService {
  Future<ApiResponse<AuthResponse>> login(LoginRequest request);
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request);
  Future<ApiResponse<void>> forgotPassword(String email);
  Future<ApiResponse<UserModel>> me();
}

class AuthApiServiceImpl implements AuthApiService {
  // ignore: unused_field
  final ApiClient _apiClient;

  AuthApiServiceImpl(this._apiClient);

  @override
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    // Stub implementation
    await Future.delayed(const Duration(seconds: 1));
    if (request.email == 'test@test.com' && request.password == '123456') {
      return ApiResponse.success(
        AuthResponse(
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
          user: UserModel(
            id: '1',
            email: request.email,
            fullName: 'Test User',
            phone: '1234567890',
            role: 'JobSeeker',
            createdAt: DateTime.now(),
          ),
        ),
      );
    }
    return ApiResponse.error('Invalid email or password');
  }

  @override
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    // Stub implementation
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse.success(
      AuthResponse(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        user: UserModel(
          id: '2',
          email: request.email,
          fullName: request.fullName,
          phone: request.phone,
          role: request.role,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Future<ApiResponse<void>> forgotPassword(String email) async {
    // Stub implementation
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse.success(null, 'Password reset instructions sent.');
  }

  @override
  Future<ApiResponse<UserModel>> me() async {
    // Stub implementation
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse.success(
      UserModel(
        id: '1',
        email: 'test@test.com',
        fullName: 'Test User',
        phone: '1234567890',
        role: 'JobSeeker',
        createdAt: DateTime.now(),
      ),
    );
  }
}
