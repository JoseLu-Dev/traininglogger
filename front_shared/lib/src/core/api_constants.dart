class ApiConstants {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String authBasePath = '/api/v1/auth';
  static const String loginPath = '$authBasePath/login';
  static const String logoutPath = '$authBasePath/logout';
  static const String registerPath = '$authBasePath/register';

  // Sync endpoints
  static const String syncBasePath = '/api/v1/sync';
  static const String pullPath = '$syncBasePath/pull';
  static const String pushPath = '$syncBasePath/push';
}
