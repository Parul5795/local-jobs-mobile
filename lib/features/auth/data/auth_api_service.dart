import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/api_response.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiServiceImpl(ref.watch(apiClientProvider)),
);

abstract class AuthApiService {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<ApiResponse<void>> forgotPassword(String email);
}

class AuthApiServiceImpl implements AuthApiService {
  final ApiClient _apiClient;

  const AuthApiServiceImpl(this._apiClient);

  @override
  Future<AuthResponse> login(LoginRequest request) =>
      _post(ApiConstants.login, request.toJson());

  @override
  Future<AuthResponse> register(RegisterRequest request) =>
      _post(ApiConstants.register, request.toJson());

  Future<AuthResponse> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.dio.post<dynamic>(path, data: body);
      final data = response.data;
      if (data is! Map) {
        throw const FormatException(
          'The server returned an invalid authentication response.',
        );
      }
      return AuthResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      if (error.error is ApiException) {
        throw error.error! as ApiException;
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<void>> forgotPassword(String email) async {
    // The current backend contract does not include password recovery.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(null, 'Password recovery is not available yet.');
  }
}
