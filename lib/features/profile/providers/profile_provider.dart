import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/profile_repository.dart';
import '../models/profile_model.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileModel?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<ProfileModel?> {
  @override
  Future<ProfileModel?> build() async {
    final auth = ref.watch(authStateProvider);
    if (auth is! Authenticated) return null;
    return ref.read(profileRepositoryProvider).getProfile(auth.user);
  }

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = ref.read(authStateProvider);
      if (auth is! Authenticated) return null;
      return ref.read(profileRepositoryProvider).getProfile(auth.user);
    });
  }

  Future<void> save(ProfileModel profile) async {
    final updated = await ref
        .read(profileRepositoryProvider)
        .updateProfile(profile);
    state = AsyncData(updated);
  }

  Future<void> logout() => ref.read(authStateProvider.notifier).logout();
}
