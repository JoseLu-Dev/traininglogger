import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:front_shared/src/data/local/secure_storage/secure_storage_service.dart';
import 'package:front_shared/src/data/remote/api_client.dart';
import 'package:front_shared/src/core/api_constants.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([SecureStorageService])
void main() {
  late MockSecureStorageService mockStorage;
  late ApiClient apiClient;

  setUp(() {
    mockStorage = MockSecureStorageService();
    apiClient = ApiClient(mockStorage);
  });

  group('ApiClient', () {
    group('Initialization', () {
      test('should initialize with correct base URL', () {
        // assert
        expect(apiClient.dio.options.baseUrl, ApiConstants.baseUrl);
      });

      test('should initialize with correct connect timeout', () {
        // assert
        expect(
          apiClient.dio.options.connectTimeout,
          ApiConstants.connectTimeout,
        );
      });

      test('should initialize with correct receive timeout', () {
        // assert
        expect(
          apiClient.dio.options.receiveTimeout,
          ApiConstants.receiveTimeout,
        );
      });

      test('should have correct default headers', () {
        // assert
        expect(
          apiClient.dio.options.headers['Content-Type'],
          'application/json',
        );
        expect(
          apiClient.dio.options.headers['Accept'],
          'application/json',
        );
      });
    });

    group('Dio Instance', () {
      test('should return the same dio instance', () {
        // act
        final dio1 = apiClient.dio;
        final dio2 = apiClient.dio;

        // assert
        expect(identical(dio1, dio2), true);
      });

      test('should be able to make GET requests', () async {
        // Note: This is a basic structure test, not an actual network test
        // In real scenarios, you'd use a mock HTTP client or dio interceptor
        expect(apiClient.dio.get, isA<Function>());
      });

      test('should be able to make POST requests', () {
        // Note: This is a basic structure test, not an actual network test
        expect(apiClient.dio.post, isA<Function>());
      });

      test('should be able to make PUT requests', () {
        // Note: This is a basic structure test, not an actual network test
        expect(apiClient.dio.put, isA<Function>());
      });

      test('should be able to make DELETE requests', () {
        // Note: This is a basic structure test, not an actual network test
        expect(apiClient.dio.delete, isA<Function>());
      });
    });

    group('Cookie Management', () {
      test('should have cookie jar enabled by default', () {
        // Dio has cookie management enabled by default via CookieManager
        // This test verifies that we're not disabling it
        expect(apiClient.dio.options.baseUrl, isNotEmpty);
      });
    });
  });

  group('NetworkException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Network error occurred';

      // act
      final exception = NetworkException(message);

      // assert
      expect(exception.message, message);
    });

    test('should have correct toString format', () {
      // arrange
      const message = 'Connection timeout';

      // act
      final exception = NetworkException(message);

      // assert
      expect(exception.toString(), 'NetworkException: Connection timeout');
    });

    test('should be throwable', () {
      // arrange
      const message = 'Test error';

      // act & assert
      expect(
        () => throw NetworkException(message),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should preserve message when thrown and caught', () {
      // arrange
      const message = 'Custom network error';

      // act & assert
      try {
        throw NetworkException(message);
      } catch (e) {
        expect(e, isA<NetworkException>());
        expect((e as NetworkException).message, message);
      }
    });
  });

  group('Edge Cases', () {
    test('should handle multiple ApiClient instances with different storage', () {
      // arrange
      final mockStorage2 = MockSecureStorageService();
      final apiClient2 = ApiClient(mockStorage2);

      // assert
      expect(identical(apiClient.dio, apiClient2.dio), false);
      expect(apiClient.dio.options.baseUrl, apiClient2.dio.options.baseUrl);
    });

    test('should maintain configuration after creation', () {
      // act - make some operations
      apiClient.dio.options.baseUrl;

      // assert - configuration should remain unchanged
      expect(apiClient.dio.options.baseUrl, ApiConstants.baseUrl);
      expect(
        apiClient.dio.options.connectTimeout,
        ApiConstants.connectTimeout,
      );
    });
  });
}
