import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localjobs/data/localjobs_repository.dart';
import '../../localjobs/models/localjobs_requests.dart';
import '../../auth/models/user_model.dart';
import '../models/profile_model.dart';

final profileApiServiceProvider = Provider<ProfileApiService>(
  (ref) => ProfileApiServiceImpl(ref.watch(localJobsRepositoryProvider)),
);

abstract class ProfileApiService {
  Future<ProfileModel?> getProfile(UserModel user);
  Future<ProfileModel> updateProfile(ProfileModel profile);
}

class ProfileApiServiceImpl implements ProfileApiService {
  final LocalJobsRepository _repository;
  ProfileApiServiceImpl(this._repository);

  @override
  Future<ProfileModel?> getProfile(UserModel user) async {
    if (user.id.isEmpty) return null;
    if (user.role.toLowerCase().contains('employer')) {
      return ProfileModel.fromUser(user);
    }
    final profile = await _repository.getMyWorkerProfile();
    return profile == null
        ? ProfileModel.fromUser(user)
        : ProfileModel.fromWorker(user, profile);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    if (profile.isEmployer) return profile;
    if (profile.categoryId == null || profile.cityId == null) {
      throw const FormatException('Choose a work category and city.');
    }
    final worker = await _repository.saveMyWorkerProfile(
      WorkerProfileWriteRequest(
        categoryId: profile.categoryId!,
        cityId: profile.cityId!,
        isFresher: profile.isFresher,
        experienceYears: profile.isFresher ? null : profile.experienceYears,
        experienceDetails: profile.experience,
        skills: profile.skills.join(', '),
        interests: profile.interests.join(', '),
        availability: profile.availability,
        about: profile.bio,
        area: profile.area,
        profileImageUrl: profile.profileImageUrl,
      ),
    );
    return ProfileModel.fromWorker(
      UserModel(
        id: profile.id,
        email: profile.email,
        fullName: profile.fullName,
        phone: profile.phone,
        role: profile.role,
        createdAt: profile.createdAt,
      ),
      worker,
    );
  }
}
