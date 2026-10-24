import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../constants/api_constants.dart';
import '../services/logger_service.dart';
import '../storage/secure_storage_service.dart';
import 'api_exceptions.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return ApiClient(
    secureStorage,
    onUnauthorized: () =>
        ref.read(authStateProvider.notifier).handleUnauthorized(),
  );
});

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;
  final Future<void> Function()? _onUnauthorized;

  ApiClient(this._secureStorage, {this._onUnauthorized, Dio? dio}) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(
              milliseconds: ApiConstants.connectTimeout,
            ),
            receiveTimeout: const Duration(
              milliseconds: ApiConstants.receiveTimeout,
            ),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isAuthRequest =
              options.path.endsWith(ApiConstants.login) ||
              options.path.endsWith(ApiConstants.register);

          if (!isAuthRequest) {
            final token = await _secureStorage.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              options.extra['authenticatedRequest'] = true;
            }
          }

          LoggerService.d("REQ: ${options.method} ${options.uri}");
          handler.next(options);
        },
        onResponse: (response, handler) {
          LoggerService.d(
            "RES: ${response.statusCode} ${response.requestOptions.uri}",
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          final isAuthenticatedRequest =
              error.requestOptions.extra['authenticatedRequest'] == true;
          if (error.response?.statusCode == 401 && isAuthenticatedRequest) {
            try {
              await _onUnauthorized?.call();
            } catch (callbackError) {
              LoggerService.e(
                'Could not clear the expired authentication session',
                error: callbackError,
              );
            }
          }

          LoggerService.e(
            "ERR: ${error.response?.statusCode ?? 'network'} ${error.requestOptions.uri}",
          );
          handler.next(_normalizeError(error));
        },
      ),
    );
  }

  Dio get dio => _dio;

  DioException _normalizeError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: NetworkException(
          'Network connection error. Please check your connection and try again.',
        ),
      );
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      final message = _serverMessage(
        error.response?.data,
        statusCode,
        error.requestOptions.extra['authenticatedRequest'] == true,
      );
      final apiError = statusCode == 401
          ? UnauthorizedException(message)
          : ServerException(message, statusCode);
      return DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: apiError,
      );
    }

    if (error.error is ApiException) return error;
    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: ApiException('An unexpected error occurred.'),
    );
  }

  String _serverMessage(dynamic data, int statusCode, bool authenticated) {
    if (statusCode == 401 && authenticated) {
      return 'Your session has expired. Please log in again.';
    }
    if (statusCode >= 500) {
      return 'The service is temporarily unavailable. Please try again later.';
    }

    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;

      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value is String && value.trim().isNotEmpty) return value;
        }
      }

      final title = data['title'] ?? data['message'];
      if (title is String && title.trim().isNotEmpty) return title;
    }

    if (data is String && data.trim().isNotEmpty) return data;

    return switch (statusCode) {
      400 => 'Please check the information and try again.',
      401 => 'Invalid email or password.',
      409 => 'This account already exists.',
      _ => 'The request could not be completed. Please try again.',
    };
  }
}
