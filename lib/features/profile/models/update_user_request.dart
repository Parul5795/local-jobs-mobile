class UpdateUserRequest {
  final String name;
  final String email;
  final String phoneNumber;

  const UpdateUserRequest({
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'email': email.trim(),
    'phoneNumber': phoneNumber.trim(),
  };
}
