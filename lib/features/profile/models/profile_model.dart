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
    required this.createdAt,
  });

  factory ProfileModel.fromUser(UserModel user) => ProfileModel(
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    phone: user.phone,
    role: user.role,
    createdAt: user.createdAt,
  );

  ProfileModel copyWith({
    String? fullName,
    String? phone,
    String? bio,
    String? location,
    String? companyName,
    String? profileImageUrl,
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
    createdAt,
  ];
}
