import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../local/secure_storage/secure_storage_service.dart';
import '../../core/api_constants.dart';

class ApiClient {
  late final Dio _dio;
  // ignore: unused_field
  final SecureStorageService _storage;
  late final CookieJar _cookieJar;

  ApiClient(this._storage) {
    _cookieJar = CookieJar();

    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add cookie manager interceptor to handle session cookies
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Dio get dio => _dio;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
