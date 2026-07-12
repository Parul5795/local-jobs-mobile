import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../data/auth_repository.dart';
import '../models/auth_state.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Run the check after the build phase completes
    Future.microtask(() => checkAuthStatus());
    return const AuthInitial();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final hasToken = await repository.hasToken();
      if (hasToken) {
        final user = await repository.getCurrentUser();
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
    } catch (e, stackTrace) {
      LoggerService.e('Check auth status failed', error: e, stackTrace: stackTrace);
      await ref.read(authRepositoryProvider).logout();
      state = const Unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await ref.read(authRepositoryProvider).login(LoginRequest(email: email, password: password));
      state = Authenticated(user);
    } catch (e, stackTrace) {
      LoggerService.e('Login failed', error: e, stackTrace: stackTrace);
      state = AuthError(e.toString().replaceAll('ApiException: ', ''));
      // Reset state to unauthenticated after showing error to allow retry without staying in error state forever
      Future.delayed(const Duration(seconds: 3), () {
         if (state is AuthError) {
             state = const Unauthenticated();
         }
      });
    }
  }

  Future<void> register(String fullName, String email, String phone, String password, String role) async {
    state = const AuthLoading();
    try {
      final user = await ref.read(authRepositoryProvider).register(RegisterRequest(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      ));
      state = Authenticated(user);
    } catch (e, stackTrace) {
      LoggerService.e('Registration failed', error: e, stackTrace: stackTrace);
      state = AuthError(e.toString().replaceAll('ApiException: ', ''));
      Future.delayed(const Duration(seconds: 3), () {
         if (state is AuthError) {
             state = const Unauthenticated();
         }
      });
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
    } catch (e) {
      rethrow; 
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const Unauthenticated();
  }
}
