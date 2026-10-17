import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user_model.dart';
import '../models/profile_model.dart';
import 'profile_api_service.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(profileApiServiceProvider)),
);

abstract class ProfileRepository {
  Future<ProfileModel?> getProfile(UserModel user);
  Future<ProfileModel> updateProfile(ProfileModel profile);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiService _service;
  const ProfileRepositoryImpl(this._service);

  @override
  Future<ProfileModel?> getProfile(UserModel user) => _service.getProfile(user);

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) =>
      _service.updateProfile(profile);
}
