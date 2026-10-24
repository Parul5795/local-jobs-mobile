import 'package:equatable/equatable.dart';

import 'user_model.dart';

class AuthResponse extends Equatable {
  final String token;
  final UserModel user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('The authentication response is invalid.');
    }

    return AuthResponse(token: token, user: UserModel.fromJson(json));
  }

  @override
  List<Object?> get props => [token, user];
}
