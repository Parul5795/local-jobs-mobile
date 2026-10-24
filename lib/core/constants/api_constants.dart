class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String forgotPassword = '/api/auth/forgot-password';

  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
}
