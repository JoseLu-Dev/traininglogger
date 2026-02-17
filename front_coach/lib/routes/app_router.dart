import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import 'package:go_router/go_router.dart';

import '../features/athletes/presentation/screens/athletes_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/library/presentation/screens/exercise_list_screen.dart';
import '../features/library/presentation/screens/exercise_form_screen.dart';
import '../features/library/presentation/screens/variant_list_screen.dart';
import '../features/library/presentation/screens/variant_form_screen.dart';

/// Notifier that listens to auth state changes and notifies GoRouter
class GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription _subscription;

  GoRouterNotifier(this._ref) {
    _subscription = _ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }

  bool get isAuthenticated {
    final authState = _ref.read(authNotifierProvider);
    return authState.maybeWhen(
      authenticated: (_, __, ___, ____, _____) => true,
      orElse: () => false,
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Riverpod provider for GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = GoRouterNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isAuthenticated = notifier.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      // If not authenticated and not going to login, redirect to login
      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      // If authenticated and going to login, redirect to home
      if (isAuthenticated && isGoingToLogin) {
        return '/athletes';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/athletes',
        name: 'athletes',
        builder: (context, state) => const AthletesScreen(),
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        builder: (context, state) => const ExerciseListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'exercise-create',
            builder: (context, state) => const ExerciseFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'exercise-edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ExerciseFormScreen(exerciseId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/variants',
        name: 'variants',
        builder: (context, state) => const VariantListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'variant-create',
            builder: (context, state) => const VariantFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'variant-edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return VariantFormScreen(variantId: id);
            },
          ),
        ],
      ),
    ],
  );
});
