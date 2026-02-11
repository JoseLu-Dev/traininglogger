import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_service.dart';
import '../auth/auth_state.dart';
import '../data/remote/auth_api_service.dart';
import 'network_providers.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(apiClientProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(authApiServiceProvider),
    ref.watch(secureStorageProvider),
    ref.watch(networkInfoProvider),
  );
});

/// Auth state notifier for reactive auth state management
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();
    state = await _authService.checkAuthStatus();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    state = await _authService.login(email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState.unauthenticated();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
