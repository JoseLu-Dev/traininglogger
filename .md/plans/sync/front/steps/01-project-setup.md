# Step 01: Project Setup & Dependencies

## Goal
Set up the front_shared package structure and install all required dependencies for offline-first sync.

## Tasks

### 1. Create front_shared package structure
```bash
cd front_shared
mkdir -p lib/src/{domain/{models,repositories},data/{local/{database/{tables,daos},secure_storage},remote/{dto},repositories},sync/{core,strategies},auth,providers/{database,network,repository,sync,auth},core/network}
mkdir -p test/{sync,data,domain}
```

### 2. Update pubspec.yaml
Add dependencies to `front_shared/pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.20.0
  dio: ^5.4.0
  flutter_riverpod: ^2.5.1
  flutter_secure_storage: ^9.0.0
  connectivity_plus: ^5.0.2
  uuid: ^4.3.3
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  path_provider: ^2.1.0
  path: ^1.8.0
  crypto: ^3.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  drift_dev: ^2.20.0
  freezed: ^2.4.7
  mockito: ^5.4.4
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0
```

### 3. Install dependencies
```bash
cd front_shared
flutter pub get
```

### 4. Create API constants file
Create `lib/src/core/api_constants.dart`:
```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000'; // TODO: Update for production
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String authBasePath = '/api/v1/auth';
  static const String loginPath = '$authBasePath/login';
  static const String logoutPath = '$authBasePath/logout';
  static const String registerPath = '$authBasePath/register';

  // Sync endpoints
  static const String syncBasePath = '/api/v1/sync';
  static const String pullPath = '$syncBasePath/pull';
  static const String pushPath = '$syncBasePath/push';
}
```

### 5. Create library exports file
Create `lib/front_shared.dart`:
```dart
library front_shared;

// Export domain models
export 'src/domain/models/syncable_entity.dart';

// Export repositories
export 'src/domain/repositories/training_plan_repository.dart';

// Export sync
export 'src/sync/core/sync_manager.dart';
export 'src/sync/core/sync_state.dart';

// Export auth
export 'src/auth/auth_service.dart';
export 'src/auth/auth_state.dart';

// Export providers
export 'src/providers/database_providers.dart';
export 'src/providers/network_providers.dart';
export 'src/providers/sync_providers.dart';
export 'src/providers/repository_providers.dart';
export 'src/providers/auth_providers.dart';
```

## Success Criteria
- ✅ front_shared package structure created
- ✅ All dependencies installed without errors
- ✅ `flutter pub get` runs successfully
- ✅ API constants defined
- ✅ Library exports file created

## Estimated Time
30 minutes

## Next Step
02-base-infrastructure.md - Create base table, DAO, and entity interfaces
