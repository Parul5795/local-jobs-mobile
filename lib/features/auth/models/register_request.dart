import 'package:equatable/equatable.dart';

class RegisterRequest extends Equatable {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String accountType;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.accountType,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'password': password,
    'accountType': accountType,
  };

  @override
  List<Object?> get props => [name, email, phoneNumber, password, accountType];
}
