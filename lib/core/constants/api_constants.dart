class ApiConstants {
  static const String baseUrl = 'https://api.localjobs.example.com';
  
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String me = '/api/auth/me';

  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
}
