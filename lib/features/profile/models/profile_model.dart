import 'package:equatable/equatable.dart';

import '../../auth/models/user_model.dart';

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
  });

  factory ProfileModel.fromUser(UserModel user) => ProfileModel(
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    phone: user.phone,
    role: user.role,
    workCategory: user.role.toLowerCase().contains('employer')
        ? ''
        : 'Local work',
    experience: user.role.toLowerCase().contains('employer') ? '' : 'Fresher',
    availability: user.role.toLowerCase().contains('employer')
        ? ''
        : 'Available now',
    contactCount: user.role.toLowerCase().contains('employer') ? 0 : 24,
    createdAt: user.createdAt,
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
  ];
}
