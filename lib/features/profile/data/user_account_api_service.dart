import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../auth/models/user_model.dart';
import '../models/update_user_request.dart';

final userAccountApiServiceProvider = Provider<UserAccountApiService>(
  (ref) => UserAccountApiService(ref.watch(apiClientProvider).dio),
);

class UserAccountApiService {
  final Dio _dio;
  const UserAccountApiService(this._dio);

  Future<UserModel> getMe() async {
    try {
      return UserModel.fromJson(
        _map((await _dio.get<dynamic>('/api/users/me')).data),
      );
    } on DioException catch (error) {
      _rethrow(error);
    }
  }

  Future<UserModel> updateMe(UpdateUserRequest request) async {
    try {
      return UserModel.fromJson(
        _map(
          (await _dio.put<dynamic>(
            '/api/users/me',
            data: request.toJson(),
          )).data,
        ),
      );
    } on DioException catch (error) {
      _rethrow(error);
    }
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is! Map) {
      throw const FormatException(
        'The server returned an invalid user response.',
      );
    }
    return Map<String, dynamic>.from(data);
  }

  Never _rethrow(DioException error) {
    if (error.error is ApiException) throw error.error! as ApiException;
    throw ApiException(
      'The request could not be completed. Please try again.',
      error.response?.statusCode,
    );
  }
}
