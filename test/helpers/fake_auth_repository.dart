import 'package:local_jobs_mobile/core/network/api_exceptions.dart';
import 'package:local_jobs_mobile/features/auth/data/auth_repository.dart';
import 'package:local_jobs_mobile/features/auth/models/login_request.dart';
import 'package:local_jobs_mobile/features/auth/models/register_request.dart';
import 'package:local_jobs_mobile/features/auth/models/user_model.dart';

class FakeAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  @override
  Future<UserModel> login(LoginRequest request) async {
    if (request.email == 'invalid@example.test') {
      throw ApiException('Invalid email or password.', 401);
    }

    final accountType = request.email.startsWith('employer')
        ? 'Employer'
        : 'JobSeeker';
    _currentUser = _user(
      id: 'test-',
      email: request.email,
      name: accountType == 'Employer' ? 'Test Employer' : 'Test Job Seeker',
      accountType: accountType,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    _currentUser = _user(
      id: 'test-',
      email: request.email,
      name: request.name,
      accountType: request.accountType,
    );
    return _currentUser!;
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<UserModel?> restoreSession() async => _currentUser;

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  UserModel _user({
    required String id,
    required String email,
    required String name,
    required String accountType,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: name,
      phone: '',
      role: accountType,
      createdAt: DateTime.now().toUtc(),
    );
  }
}
