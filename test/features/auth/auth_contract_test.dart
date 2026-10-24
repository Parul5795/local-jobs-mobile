import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/core/network/api_response.dart';
import 'package:local_jobs_mobile/core/storage/secure_storage_service.dart';
import 'package:local_jobs_mobile/features/auth/data/auth_api_service.dart';
import 'package:local_jobs_mobile/features/auth/data/auth_repository.dart';
import 'package:local_jobs_mobile/features/auth/models/auth_response.dart';
import 'package:local_jobs_mobile/features/auth/models/login_request.dart';
import 'package:local_jobs_mobile/features/auth/models/register_request.dart';

void main() {
  test('login request matches the backend contract exactly', () {
    const request = LoginRequest(
      email: 'worker@example.test',
      password: 'safe-password',
    );

    expect(request.toJson(), {
      'email': 'worker@example.test',
      'password': 'safe-password',
    });
  });

  test('registration request uses backend field and account type names', () {
    const request = RegisterRequest(
      name: 'Jordan Worker',
      email: 'worker@example.test',
      phoneNumber: '9876543210',
      password: 'safe-password',
      accountType: 'JobSeeker',
    );

    expect(request.toJson(), {
      'name': 'Jordan Worker',
      'email': 'worker@example.test',
      'phoneNumber': '9876543210',
      'password': 'safe-password',
      'accountType': 'JobSeeker',
    });
  });

  test('authentication response maps the backend account type', () {
    final response = AuthResponse.fromJson({
      'token': _tokenWithExpiry(),
      'userId': 'worker-id',
      'name': 'Jordan Worker',
      'email': 'worker@example.test',
      'accountType': 'JobSeeker',
    });

    expect(response.user.id, 'worker-id');
    expect(response.user.fullName, 'Jordan Worker');
    expect(response.user.role, 'JobSeeker');
  });

  test(
    'repository securely persists and restores the backend session',
    () async {
      final token = _tokenWithExpiry();
      final response = AuthResponse.fromJson({
        'token': token,
        'userId': 'employer-id',
        'name': 'Jordan Employer',
        'email': 'employer@example.test',
        'accountType': 'Employer',
      });
      final storage = _MemorySecureStorage();
      final repository = AuthRepositoryImpl(
        _FakeAuthApiService(response),
        storage,
      );

      final user = await repository.login(
        const LoginRequest(
          email: 'employer@example.test',
          password: 'safe-password',
        ),
      );

      expect(user.role, 'Employer');
      expect(await storage.getAccessToken(), token);
      expect(storage.userJson, isNot(contains('safe-password')));

      final restartedRepository = AuthRepositoryImpl(
        _FakeAuthApiService(response),
        storage,
      );
      final restoredUser = await restartedRepository.restoreSession();

      expect(restoredUser?.id, 'employer-id');
      expect(restoredUser?.role, 'Employer');
    },
  );

  test('expired stored token clears the session', () async {
    final response = AuthResponse.fromJson({
      'token': _tokenWithExpiry(expired: true),
      'userId': 'worker-id',
      'name': 'Jordan Worker',
      'email': 'worker@example.test',
      'accountType': 'JobSeeker',
    });
    final storage = _MemorySecureStorage()
      ..accessToken = _tokenWithExpiry(expired: true)
      ..userJson = jsonEncode(response.user.toJson());
    final repository = AuthRepositoryImpl(
      _FakeAuthApiService(response),
      storage,
    );

    expect(await repository.restoreSession(), isNull);
    expect(storage.accessToken, isNull);
    expect(storage.userJson, isNull);
  });
}

String _tokenWithExpiry({bool expired = false}) {
  final expiry =
      DateTime.now()
          .toUtc()
          .add(expired ? const Duration(minutes: -1) : const Duration(hours: 1))
          .millisecondsSinceEpoch ~/
      1000;
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({'exp': expiry})))
      .replaceAll('=', '');
  return 'header.$payload.signature';
}

class _FakeAuthApiService implements AuthApiService {
  final AuthResponse response;

  const _FakeAuthApiService(this.response);

  @override
  Future<AuthResponse> login(LoginRequest request) async => response;

  @override
  Future<AuthResponse> register(RegisterRequest request) async => response;

  @override
  Future<ApiResponse<void>> forgotPassword(String email) async =>
      ApiResponse.success(null);
}

class _MemorySecureStorage extends SecureStorageService {
  String? accessToken;
  String? userJson;

  @override
  Future<void> saveSession({
    required String accessToken,
    required String userJson,
  }) async {
    this.accessToken = accessToken;
    this.userJson = userJson;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getStoredUser() async => userJson;

  @override
  Future<void> clearSession() async {
    accessToken = null;
    userJson = null;
  }
}
