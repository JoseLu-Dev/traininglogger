# LiftLogger Offline-First Sync - Integration Guide

## Overview
This guide shows how to integrate the offline-first sync system into your Flutter app.

## Setup

### 1. Add front_shared dependency
```yaml
dependencies:
  front_shared:
    path: ../front_shared
```

### 2. Initialize providers in main.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 3. Start auto-sync service
```dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auto-sync service
    ref.watch(autoSyncServiceProvider);

    return MaterialApp(
      home: const HomePage(),
    );
  }
}
```

## Authentication

### Login
```dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      initial: () => _buildLoginForm(authNotifier),
      loading: () => const CircularProgressIndicator(),
      authenticated: (id, email, role, coachId, isOffline) {
        // Navigate to home
        return HomePage();
      },
      unauthenticated: () => _buildLoginForm(authNotifier),
      error: (message) => Text('Error: $message'),
    );
  }

  Widget _buildLoginForm(AuthNotifier notifier) {
    return ElevatedButton(
      onPressed: () {
        notifier.login(emailController.text, passwordController.text);
      },
      child: const Text('Login'),
    );
  }
}
```

## Using Repositories

### Read Data
```dart
class TrainingPlansPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(trainingPlanRepositoryProvider);

    return FutureBuilder<List<TrainingPlan>>(
      future: repository.findByAthleteId('athlete-1'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final plan = snapshot.data![index];
              return ListTile(
                title: Text(plan.name),
                subtitle: Text(plan.date.toString()),
                trailing: plan.isDirty
                    ? const Icon(Icons.sync, color: Colors.orange)
                    : null,
              );
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
```

### Create Data
```dart
Future<void> createTrainingPlan(WidgetRef ref) async {
  final repository = ref.read(trainingPlanRepositoryProvider);

  final plan = TrainingPlan.create(
    athleteId: 'athlete-1',
    name: 'Monday Workout',
    date: DateTime.now(),
  );

  await repository.create(plan);

  // Will automatically sync when online
}
```

### Update Data
```dart
Future<void> updateTrainingPlan(WidgetRef ref, String planId) async {
  final repository = ref.read(trainingPlanRepositoryProvider);

  // Just mark as dirty - sync will handle the rest
  await repository.update(
    plan.copyWith(name: 'Updated Name'),
  );
}
```

## Manual Sync

### Trigger sync manually
```dart
Future<void> manualSync(WidgetRef ref) async {
  final syncManager = ref.read(syncManagerProvider);

  final result = await syncManager.sync();

  result.when(
    success: (pullCount, pushCount, _) {
      print('Sync successful: ↓$pullCount ↑$pushCount');
    },
    partialSuccess: (_, __, ___, failures, ____) {
      print('Partial sync: ${failures.length} failures');
    },
    failure: (message, _, __) {
      print('Sync failed: $message');
    },
  );
}
```

## UI Components

### Add sync indicator to AppBar
```dart
AppBar(
  title: const Text('LiftLogger'),
  actions: [
    const OfflineIndicator(),
    const SyncButton(),
    const SyncIndicator(),
  ],
)
```

## Monitoring Sync State

### Listen to sync events
```dart
class SyncMonitor extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return syncState.when(
      data: (state) {
        return state.when(
          idle: () => const Text('Idle'),
          syncing: (phase) => Text('Syncing: $phase'),
          completed: (result) => Text('Completed'),
          error: (message) => Text('Error: $message'),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}
```

## Best Practices

1. **Always use repositories** - Never access DAOs directly from UI
2. **Trust the sync** - Don't manually check network before operations
3. **Show dirty indicators** - Let users know what hasn't synced yet
4. **Handle partial failures** - Some entities may fail while others succeed
5. **Test offline** - Airplane mode is your friend

## Troubleshooting

### Sync not working
- Check network connectivity
- Verify authentication token is valid
- Check server logs for errors

### Data not appearing
- Ensure entity is registered in EntityRegistry
- Check if entity is marked as deleted
- Verify foreign key relationships

### Performance issues
- Check database indexes are created
- Use pagination for large datasets
- Profile with Flutter DevTools
