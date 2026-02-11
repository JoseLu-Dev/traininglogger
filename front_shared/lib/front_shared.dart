library front_shared;

// Domain Models - Base
export 'src/domain/models/syncable_entity.dart';

// Domain Models - Generated Entities
export 'src/generated/domain/models/training_plan.dart';
export 'src/generated/domain/models/training_session.dart';
export 'src/generated/domain/models/exercise.dart';
export 'src/generated/domain/models/variant.dart';
export 'src/generated/domain/models/exercise_plan.dart';
export 'src/generated/domain/models/exercise_plan_variant.dart';
export 'src/generated/domain/models/exercise_session.dart';
export 'src/generated/domain/models/exercise_session_variant.dart';
export 'src/generated/domain/models/set_plan.dart';
export 'src/generated/domain/models/set_session.dart';
export 'src/generated/domain/models/body_weight_entry.dart';
export 'src/generated/domain/models/user.dart';

// Repositories
export 'src/generated/domain/repositories/training_plan_repository.dart';
export 'src/generated/domain/repositories/training_session_repository.dart';
export 'src/generated/domain/repositories/exercise_repository.dart';
export 'src/generated/domain/repositories/variant_repository.dart';
export 'src/generated/domain/repositories/exercise_plan_repository.dart';
export 'src/generated/domain/repositories/exercise_plan_variant_repository.dart';
export 'src/generated/domain/repositories/exercise_session_repository.dart';
export 'src/generated/domain/repositories/exercise_session_variant_repository.dart';
export 'src/generated/domain/repositories/set_plan_repository.dart';
export 'src/generated/domain/repositories/set_session_repository.dart';
export 'src/generated/domain/repositories/body_weight_entry_repository.dart';
export 'src/generated/domain/repositories/user_repository.dart';

// Sync
export 'src/sync/core/sync_manager.dart';
export 'src/sync/core/sync_state.dart';
export 'src/sync/core/sync_queue.dart';

// Auth
export 'src/auth/auth_service.dart';
export 'src/auth/auth_state.dart';

// Providers
export 'src/providers/database_providers.dart';
export 'src/providers/network_providers.dart';
export 'src/providers/sync_providers.dart';
export 'src/providers/repository_providers.dart';
export 'src/providers/auth_providers.dart';

// Core
export 'src/core/api_constants.dart';

// UI Components
export 'src/ui/sync_indicator.dart';
