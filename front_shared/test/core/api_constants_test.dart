import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/core/api_constants.dart';

void main() {
  group('ApiConstants', () {
    group('Base Configuration', () {
      test('should have correct base URL', () {
        expect(ApiConstants.baseUrl, 'http://localhost:8080');
      });

      test('should have valid timeout durations', () {
        expect(ApiConstants.connectTimeout, const Duration(seconds: 30));
        expect(ApiConstants.receiveTimeout, const Duration(seconds: 30));
      });

      test('timeout durations should be positive', () {
        expect(ApiConstants.connectTimeout.inSeconds, greaterThan(0));
        expect(ApiConstants.receiveTimeout.inSeconds, greaterThan(0));
      });
    });

    group('Auth Endpoints', () {
      test('should have correct auth base path', () {
        expect(ApiConstants.authBasePath, '/api/v1/auth');
      });

      test('should have correct login endpoint', () {
        expect(ApiConstants.loginPath, '/api/v1/auth/login');
        expect(ApiConstants.loginPath, startsWith(ApiConstants.authBasePath));
      });

      test('should have correct logout endpoint', () {
        expect(ApiConstants.logoutPath, '/api/v1/auth/logout');
        expect(ApiConstants.logoutPath, startsWith(ApiConstants.authBasePath));
      });

      test('should have correct register endpoint', () {
        expect(ApiConstants.registerPath, '/api/v1/auth/register');
        expect(
            ApiConstants.registerPath, startsWith(ApiConstants.authBasePath));
      });

      test('all auth endpoints should start with auth base path', () {
        final authEndpoints = [
          ApiConstants.loginPath,
          ApiConstants.logoutPath,
          ApiConstants.registerPath,
        ];

        for (final endpoint in authEndpoints) {
          expect(endpoint, startsWith(ApiConstants.authBasePath));
        }
      });
    });

    group('Sync Endpoints', () {
      test('should have correct sync base path', () {
        expect(ApiConstants.syncBasePath, '/api/v1/sync');
      });

      test('should have correct pull endpoint', () {
        expect(ApiConstants.pullPath, '/api/v1/sync/pull');
        expect(ApiConstants.pullPath, startsWith(ApiConstants.syncBasePath));
      });

      test('should have correct push endpoint', () {
        expect(ApiConstants.pushPath, '/api/v1/sync/push');
        expect(ApiConstants.pushPath, startsWith(ApiConstants.syncBasePath));
      });

      test('all sync endpoints should start with sync base path', () {
        final syncEndpoints = [
          ApiConstants.pullPath,
          ApiConstants.pushPath,
        ];

        for (final endpoint in syncEndpoints) {
          expect(endpoint, startsWith(ApiConstants.syncBasePath));
        }
      });
    });

    group('Path Formatting', () {
      test('all paths should start with forward slash', () {
        final allPaths = [
          ApiConstants.authBasePath,
          ApiConstants.loginPath,
          ApiConstants.logoutPath,
          ApiConstants.registerPath,
          ApiConstants.syncBasePath,
          ApiConstants.pullPath,
          ApiConstants.pushPath,
        ];

        for (final path in allPaths) {
          expect(path, startsWith('/'));
        }
      });

      test('all paths should follow REST API versioning pattern', () {
        final allPaths = [
          ApiConstants.authBasePath,
          ApiConstants.loginPath,
          ApiConstants.logoutPath,
          ApiConstants.registerPath,
          ApiConstants.syncBasePath,
          ApiConstants.pullPath,
          ApiConstants.pushPath,
        ];

        for (final path in allPaths) {
          expect(path, contains('/api/v1/'));
        }
      });

      test('paths should not end with forward slash', () {
        final allPaths = [
          ApiConstants.authBasePath,
          ApiConstants.loginPath,
          ApiConstants.logoutPath,
          ApiConstants.registerPath,
          ApiConstants.syncBasePath,
          ApiConstants.pullPath,
          ApiConstants.pushPath,
        ];

        for (final path in allPaths) {
          expect(path, isNot(endsWith('/')));
        }
      });
    });

    group('Full URL Construction', () {
      test('should be able to construct full URLs', () {
        final fullLoginUrl =
            '${ApiConstants.baseUrl}${ApiConstants.loginPath}';
        expect(fullLoginUrl, 'http://localhost:8080/api/v1/auth/login');
      });

      test('should be able to construct all auth URLs', () {
        final loginUrl = '${ApiConstants.baseUrl}${ApiConstants.loginPath}';
        final logoutUrl = '${ApiConstants.baseUrl}${ApiConstants.logoutPath}';
        final registerUrl =
            '${ApiConstants.baseUrl}${ApiConstants.registerPath}';

        expect(loginUrl, 'http://localhost:8080/api/v1/auth/login');
        expect(logoutUrl, 'http://localhost:8080/api/v1/auth/logout');
        expect(registerUrl, 'http://localhost:8080/api/v1/auth/register');
      });

      test('should be able to construct all sync URLs', () {
        final pullUrl = '${ApiConstants.baseUrl}${ApiConstants.pullPath}';
        final pushUrl = '${ApiConstants.baseUrl}${ApiConstants.pushPath}';

        expect(pullUrl, 'http://localhost:8080/api/v1/sync/pull');
        expect(pushUrl, 'http://localhost:8080/api/v1/sync/push');
      });
    });
  });
}
