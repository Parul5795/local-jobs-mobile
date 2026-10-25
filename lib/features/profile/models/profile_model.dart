import 'package:equatable/equatable.dart';

import '../../auth/models/user_model.dart';
import '../../localjobs/models/localjobs_models.dart';

class ProfileModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final String bio;
  final String location;
  final String? companyName;
  final String? profileImageUrl;
  final String workCategory;
  final String experience;
  final List<String> skills;
  final List<String> interests;
  final String availability;
  final int contactCount;
  final DateTime createdAt;
  final int? categoryId;
  final int? cityId;
  final bool isFresher;
  final double? experienceYears;
  final String area;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.bio = '',
    this.location = '',
    this.companyName,
    this.profileImageUrl,
    this.workCategory = '',
    this.experience = '',
    this.skills = const [],
    this.interests = const [],
    this.availability = '',
    this.contactCount = 0,
    required this.createdAt,
    this.categoryId,
    this.cityId,
    this.isFresher = true,
    this.experienceYears,
    this.area = '',
  });

  factory ProfileModel.fromUser(UserModel user) => ProfileModel(
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    phone: user.phone,
    role: user.role,
    workCategory: '',
    experience: '',
    availability: '',
    contactCount: 0,
    createdAt: user.createdAt,
  );

  factory ProfileModel.fromWorker(UserModel user, WorkerProfile worker) =>
      ProfileModel(
        id: user.id,
        email: user.email,
        fullName: worker.name,
        phone: user.phone,
        role: user.role,
        bio: worker.about,
        location: worker.location,
        profileImageUrl: worker.profileImageUrl,
        workCategory: worker.categoryName,
        experience: worker.experienceDetails,
        skills: _split(worker.skills),
        interests: _split(worker.interests),
        availability: worker.availability,
        contactCount: worker.contactCount,
        createdAt: worker.createdAt,
        categoryId: worker.categoryId,
        cityId: worker.cityId,
        isFresher: worker.isFresher,
        experienceYears: worker.experienceYears,
        area: worker.area ?? '',
      );

  ProfileModel copyWith({
    String? fullName,
    String? phone,
    String? bio,
    String? location,
    String? companyName,
    String? profileImageUrl,
    String? workCategory,
    String? experience,
    List<String>? skills,
    List<String>? interests,
    String? availability,
    int? categoryId,
    int? cityId,
    bool? isFresher,
    double? experienceYears,
    String? area,
  }) => ProfileModel(
    id: id,
    email: email,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    role: role,
    bio: bio ?? this.bio,
    location: location ?? this.location,
    companyName: companyName ?? this.companyName,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    workCategory: workCategory ?? this.workCategory,
    experience: experience ?? this.experience,
    skills: skills ?? this.skills,
    interests: interests ?? this.interests,
    availability: availability ?? this.availability,
    contactCount: contactCount,
    createdAt: createdAt,
    categoryId: categoryId ?? this.categoryId,
    cityId: cityId ?? this.cityId,
    isFresher: isFresher ?? this.isFresher,
    experienceYears: experienceYears ?? this.experienceYears,
    area: area ?? this.area,
  );

  bool get isEmployer => role.toLowerCase().contains('employer');

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phone,
    role,
    bio,
    location,
    companyName,
    profileImageUrl,
    workCategory,
    experience,
    skills,
    interests,
    availability,
    contactCount,
    createdAt,
    categoryId,
    cityId,
    isFresher,
    experienceYears,
    area,
  ];
}

List<String> _split(String value) => value
    .split(',')
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .toList();
