# Flutter Logging Reference (logger)

## Log Levels

Follow consistent log levels across frontend and backend:

- **ERROR**: Unexpected exceptions, system failures, crashes
- **WARN**: Recoverable issues, deprecated features, validation failures
- **INFO**: State-changing operations ONLY (create, update, delete data)
- **DEBUG**: Read operations, detailed flow, navigation events

## Setup

```yaml
dependencies:
  logger: ^2.0.0
  path_provider: ^2.1.0
  intl: ^0.19.0
```

## Implementation (already in front_shared)

The logging infrastructure is provided by front_shared package:

```dart
import 'package:front_shared/front_shared.dart';

// Use AppLogger with class context
final _log = AppLogger.forClass(MyClass);

_log.debug('Fetching data');        // DEBUG
_log.info('Creating entity');       // INFO
_log.warning('Validation failed');  // WARN
_log.error('Failed to save', e, stackTrace);  // ERROR
```

## Initialize in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging (optional - logger is lazy-loaded)
  await LogService.init();

  // Set up error boundary
  final errorLog = AppLogger.forClass(Object);

  FlutterError.onError = (details) {
    errorLog.error(
      'Flutter framework error: ${details.summary}',
      details.exception,
      details.stack,
    );
  };

  runZonedGuarded(
    () => runApp(const MyApp()),
    (error, stackTrace) {
      errorLog.error('Uncaught async error', error, stackTrace);
    },
  );
}
```

## Usage Examples

```dart
class WorkoutRepository {
  final _log = AppLogger.forClass(WorkoutRepository);

  Future<Workout> createWorkout(Workout workout) async {
    _log.info('Creating workout: ${workout.id}'); // State change = INFO

    try {
      final result = await _api.createWorkout(workout);
      _log.info('Workout created successfully');
      return result;
    } catch (e, stack) {
      _log.error('Failed to create workout', e, stack); // Failure = ERROR
      rethrow;
    }
  }

  Future<List<Workout>> getWorkouts() async {
    _log.debug('Fetching workouts'); // Read operation = DEBUG
    return await _api.getWorkouts();
  }

  Future<void> updateWorkout(Workout workout) async {
    _log.info('Updating workout: ${workout.id}'); // State change = INFO

    if (!workout.isValid) {
      _log.warning('Invalid workout data, using defaults'); // Recoverable = WARN
    }

    await _api.updateWorkout(workout);
  }
}
```

## Riverpod Integration

```dart
class WorkoutNotifier extends AutoDisposeAsyncNotifier<List<Workout>> {
  final _log = AppLogger.forClass(WorkoutNotifier);

  @override
  Future<List<Workout>> build() async {
    _log.debug('WorkoutNotifier initialized');
    return _loadWorkouts();
  }

  Future<void> addWorkout(Workout workout) async {
    _log.info('Adding workout: ${workout.id}');
    // ... implementation
  }
}
```

## Export Logs

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Get all log files
Future<List<File>> getLogFiles() async {
  final dir = await getApplicationDocumentsDirectory();
  final logsDir = Directory('${dir.path}/logs');

  if (!await logsDir.exists()) return [];

  return logsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.log'))
      .toList();
}

// Share logs with user
Future<void> shareLogs() async {
  final logFiles = await getLogFiles();
  if (logFiles.isNotEmpty) {
    await Share.shareXFiles(
      logFiles.map((f) => XFile(f.path)).toList(),
      subject: 'LiftLogger Logs',
    );
  }
}
```

## Best Practices

### Do's
- ✅ Always include class name: `AppLogger.forClass(MyClass)`
- ✅ Use INFO for state changes (create/update/delete)
- ✅ Use DEBUG for read operations and detailed flow
- ✅ Include error and stack trace in ERROR logs
- ✅ Logs are automatically written to daily files

### Don'ts
- ❌ Don't log sensitive data (passwords, tokens, emails)
- ❌ Don't use INFO for read operations
- ❌ Don't use DEBUG for state-changing operations
- ❌ Don't log in hot paths (60fps loops, paint methods)

## Log File Location

Logs are stored with automatic daily rotation:

- **Android**: `/Android/data/com.liftlogger.app/files/logs/app_YYYY-MM-DD.log`
- **iOS**: `Application Support/logs/app_YYYY-MM-DD.log`
- **Windows**: `%APPDATA%\LiftLogger\logs\app_YYYY-MM-DD.log`
- **macOS**: `~/Library/Application Support/com.liftlogger.app/logs/app_YYYY-MM-DD.log`
- **Linux**: `~/.local/share/liftlogger/logs/app_YYYY-MM-DD.log`

New log file created automatically each day.
