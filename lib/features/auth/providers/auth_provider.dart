import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/services/logger_service.dart';
import '../data/auth_repository.dart';
import '../models/auth_state.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(checkAuthStatus);
    return const AuthInitial();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    try {
      final user = await ref.read(authRepositoryProvider).restoreSession();
      state = user == null ? const Unauthenticated() : Authenticated(user);
    } catch (error, stackTrace) {
      LoggerService.e(
        'Session restoration failed',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      try {
        await ref.read(authRepositoryProvider).logout();
      } finally {
        state = const Unauthenticated();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(LoginRequest(email: email, password: password));
      state = Authenticated(user);
    } catch (error, stackTrace) {
      LoggerService.e(
        'Login failed (${error.runtimeType})',
        stackTrace: stackTrace,
      );
      state = AuthError(_userMessage(error));
    }
  }

  Future<void> register(
    String name,
    String email,
    String phoneNumber,
    String password,
    String accountType,
  ) async {
    state = const AuthLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .register(
            RegisterRequest(
              name: name,
              email: email,
              phoneNumber: phoneNumber,
              password: password,
              accountType: accountType,
            ),
          );
      state = Authenticated(user);
    } catch (error, stackTrace) {
      LoggerService.e(
        'Registration failed (${error.runtimeType})',
        stackTrace: stackTrace,
      );
      state = AuthError(_userMessage(error));
    }
  }

  Future<void> forgotPassword(String email) =>
      ref.read(authRepositoryProvider).forgotPassword(email);

  Future<void> handleUnauthorized() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      state = const Unauthenticated();
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      state = const Unauthenticated();
    }
  }

  Future<void> updateAuthenticatedUser(UserModel user) async {
    final current = state;
    if (current is! Authenticated || current.user.id != user.id) return;
    await ref.read(authRepositoryProvider).updateCachedUser(user);
    state = Authenticated(user);
  }

  String _userMessage(Object error) {
    if (error is ApiException) return error.message;
    if (error is FormatException) {
      return 'The server returned an unexpected response. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
