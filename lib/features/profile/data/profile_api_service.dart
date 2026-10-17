import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/models/user_model.dart';
import '../models/profile_model.dart';

final profileApiServiceProvider = Provider<ProfileApiService>(
  (ref) => ProfileApiServiceImpl(ref.watch(apiClientProvider)),
);

abstract class ProfileApiService {
  Future<ProfileModel?> getProfile(UserModel user);
  Future<ProfileModel> updateProfile(ProfileModel profile);
}

class ProfileApiServiceImpl implements ProfileApiService {
  // Kept as the transport boundary for replacing mock responses with API calls.
  // ignore: unused_field
  final ApiClient _apiClient;
  ProfileApiServiceImpl(this._apiClient);

  @override
  Future<ProfileModel?> getProfile(UserModel user) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (user.id.isEmpty) return null;
    return ProfileModel.fromUser(user);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return profile;
  }
}
