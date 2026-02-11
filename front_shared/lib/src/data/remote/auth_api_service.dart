import 'package:dio/dio.dart';
import 'api_client.dart';
import 'dto/auth_dtos.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  /// Login with email and password
  Future<LoginResponseDto> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login',
        data: {
          'email': email,  // Changed from 'username'
          'password': password,
        },
      );

      return LoginResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout (invalidate session)
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/api/v1/auth/logout');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return AuthenticationException('Invalid credentials');
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException('Connection error');
    }
    return Exception('Authentication failed: ${e.message}');
  }
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
