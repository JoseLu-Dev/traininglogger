import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/core/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('should have correct base URL', () {
      expect(ApiConstants.baseUrl, 'http://localhost:3000');
    });

    test('should have correct timeout durations', () {
      expect(ApiConstants.connectTimeout, const Duration(seconds: 30));
      expect(ApiConstants.receiveTimeout, const Duration(seconds: 30));
    });

    test('should have correct auth endpoints', () {
      expect(ApiConstants.authBasePath, '/api/v1/auth');
      expect(ApiConstants.loginPath, '/api/v1/auth/login');
      expect(ApiConstants.logoutPath, '/api/v1/auth/logout');
      expect(ApiConstants.registerPath, '/api/v1/auth/register');
    });

    test('should have correct sync endpoints', () {
      expect(ApiConstants.syncBasePath, '/api/v1/sync');
      expect(ApiConstants.pullPath, '/api/v1/sync/pull');
      expect(ApiConstants.pushPath, '/api/v1/sync/push');
    });
  });
}
