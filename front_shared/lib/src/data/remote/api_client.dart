import 'package:dio/dio.dart';
import '../local/secure_storage/secure_storage_service.dart';
import '../../core/api_constants.dart';

class ApiClient {
  late final Dio _dio;
  // ignore: unused_field
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // No authorization interceptor needed - cookies handled automatically by Dio
    // Session cookie (SESSION) is automatically sent with each request
  }

  Dio get dio => _dio;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
