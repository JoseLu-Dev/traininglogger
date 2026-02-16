import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'routes/app_router.dart';

void main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  LogService.configure('coach');

  runApp(
    ProviderScope(
      overrides: [
        appIdentifierProvider.overrideWithValue('coach'),
      ],
      child: const CoachApp(),
    ),
  );
}

class CoachApp extends ConsumerWidget {
  const CoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(autoSyncServiceProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'LiftLogger Coach',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
