import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['userId'] ?? json['id'];
    final name = json['name'] ?? json['fullName'];
    final accountType = json['accountType'] ?? json['role'];
    final email = json['email'];

    if (id is! String ||
        name is! String ||
        email is! String ||
        accountType is! String ||
        !const {'JobSeeker', 'Employer'}.contains(accountType)) {
      throw const FormatException('The authentication response is invalid.');
    }

    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt)
        : null;
    final phone = json['phoneNumber'] ?? json['phone'];

    return UserModel(
      id: id,
      email: email,
      fullName: name,
      phone: phone is String ? phone : '',
      role: accountType,
      createdAt: createdAt ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': id,
    'name': fullName,
    'email': email,
    'phoneNumber': phone,
    'accountType': role,
  };

  @override
  List<Object?> get props => [id, email, fullName, phone, role, createdAt];
}
