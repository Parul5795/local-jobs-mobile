import 'package:equatable/equatable.dart';

class RegisterRequest extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String role; // 'JobSeeker' or 'Employer'

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    };
  }

  @override
  List<Object?> get props => [fullName, email, phone, password, role];
}
