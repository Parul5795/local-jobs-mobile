import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiServiceImpl(),
);

abstract class AuthApiService {
  Future<ApiResponse<AuthResponse>> login(LoginRequest request);
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request);
  Future<ApiResponse<void>> forgotPassword(String email);
  Future<ApiResponse<UserModel>> me();
}

class AuthApiServiceImpl implements AuthApiService {
  AuthApiServiceImpl();

  @override
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    // Stub implementation
    await Future.delayed(const Duration(seconds: 1));
    final role = request.role.toLowerCase().contains('employer')
        ? 'Employer'
        : 'JobSeeker';
    final expectedEmail = role == 'Employer'
        ? 'employer@test.com'
        : 'jobseeker@test.com';
    final expectedId = role == 'Employer' ? 'employer' : 'jobseeker';
    final loginId = request.email.trim().toLowerCase();
    if ((loginId == expectedEmail || loginId == expectedId) &&
        request.password == 'password') {
      return ApiResponse.success(
        AuthResponse(
          accessToken: '',
          refreshToken: '',
          user: UserModel(
            id: role == 'Employer' ? 'mock-employer' : 'mock-job-seeker',
            email: expectedEmail,
            fullName: role == 'Employer' ? 'Demo Employer' : 'Demo Job Seeker',
            phone: '1234567890',
            role: role,
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
    final role = request.role.toLowerCase().contains('employer')
        ? 'Employer'
        : 'JobSeeker';
    return ApiResponse.success(
      AuthResponse(
        accessToken: '',
        refreshToken: '',
        user: UserModel(
          id: '2',
          email: request.email,
          fullName: request.fullName,
          phone: request.phone,
          role: role,
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
        id: 'mock-job-seeker',
        email: 'jobseeker@test.com',
        fullName: 'Demo Job Seeker',
        phone: '1234567890',
        role: 'JobSeeker',
        createdAt: DateTime.now(),
      ),
    );
  }
}
