import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/auth_state.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/user_account_repository.dart';
import '../models/update_user_request.dart';

final userAccountProvider =
    AsyncNotifierProvider<UserAccountNotifier, UserModel?>(
      UserAccountNotifier.new,
    );

class UserAccountNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final auth = ref.watch(authStateProvider);
    if (auth is! Authenticated) return null;
    return ref.read(userAccountRepositoryProvider).getMe();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = ref.read(authStateProvider);
      if (auth is! Authenticated) return null;
      return ref.read(userAccountRepositoryProvider).getMe();
    });
  }

  Future<UserModel> save(UpdateUserRequest request) async {
    final user = await ref
        .read(userAccountRepositoryProvider)
        .updateMe(request);
    await ref.read(authStateProvider.notifier).updateAuthenticatedUser(user);
    state = AsyncData(user);
    return user;
  }
}
