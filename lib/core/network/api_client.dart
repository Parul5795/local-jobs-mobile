import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../services/logger_service.dart';
import 'api_exceptions.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return ApiClient(secureStorage);
});

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          LoggerService.d('REQ: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          LoggerService.d('RES: ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          LoggerService.e('ERR: ${e.response?.statusCode} ${e.requestOptions.uri}', error: e, stackTrace: e.stackTrace);
          return handler.next(_handleError(e));
        },
      ),
    );
  }

  Dio get dio => _dio;

  DioException _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout || 
        e.type == DioExceptionType.connectionError) {
      return DioException(
        requestOptions: e.requestOptions,
        error: NetworkException('Network connection error. Please check your internet.'),
      );
    }
    
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      if (statusCode == 401) {
         return DioException(
          requestOptions: e.requestOptions,
          error: UnauthorizedException('Unauthorized access. Please login again.'),
        );
      }
      
      final message = e.response?.data?['message'] ?? 'An unexpected server error occurred.';
      return DioException(
          requestOptions: e.requestOptions,
          error: ServerException(message, statusCode),
        );
    }
    
    return DioException(
      requestOptions: e.requestOptions,
      error: ApiException('An unexpected error occurred.'),
    );
  }
}
