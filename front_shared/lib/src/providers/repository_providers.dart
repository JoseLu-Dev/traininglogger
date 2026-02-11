import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/domain/repositories/training_plan_repository.dart';
import '../generated/data/repositories/training_plan_repository_impl.dart';
import '../generated/domain/repositories/body_weight_entry_repository.dart';
import '../generated/data/repositories/body_weight_entry_repository_impl.dart';
import '../generated/domain/repositories/exercise_repository.dart';
import '../generated/data/repositories/exercise_repository_impl.dart';
import '../generated/domain/repositories/exercise_plan_repository.dart';
import '../generated/data/repositories/exercise_plan_repository_impl.dart';
import '../generated/domain/repositories/exercise_plan_variant_repository.dart';
import '../generated/data/repositories/exercise_plan_variant_repository_impl.dart';
import '../generated/domain/repositories/exercise_session_repository.dart';
import '../generated/data/repositories/exercise_session_repository_impl.dart';
import '../generated/domain/repositories/exercise_session_variant_repository.dart';
import '../generated/data/repositories/exercise_session_variant_repository_impl.dart';
import '../generated/domain/repositories/set_plan_repository.dart';
import '../generated/data/repositories/set_plan_repository_impl.dart';
import '../generated/domain/repositories/set_session_repository.dart';
import '../generated/data/repositories/set_session_repository_impl.dart';
import '../generated/domain/repositories/training_session_repository.dart';
import '../generated/data/repositories/training_session_repository_impl.dart';
import '../generated/domain/repositories/user_repository.dart';
import '../generated/data/repositories/user_repository_impl.dart';
import '../generated/domain/repositories/variant_repository.dart';
import '../generated/data/repositories/variant_repository_impl.dart';
import 'database_providers.dart';

final trainingPlanRepositoryProvider = Provider<TrainingPlanRepository>((ref) {
  return TrainingPlanRepositoryImpl(ref.watch(trainingPlanDaoProvider));
});

final bodyWeightEntryRepositoryProvider = Provider<BodyWeightEntryRepository>((ref) {
  return BodyWeightEntryRepositoryImpl(ref.watch(bodyWeightEntryDaoProvider));
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(ref.watch(exerciseDaoProvider));
});

final exercisePlanRepositoryProvider = Provider<ExercisePlanRepository>((ref) {
  return ExercisePlanRepositoryImpl(ref.watch(exercisePlanDaoProvider));
});

final exercisePlanVariantRepositoryProvider = Provider<ExercisePlanVariantRepository>((ref) {
  return ExercisePlanVariantRepositoryImpl(ref.watch(exercisePlanVariantDaoProvider));
});

final exerciseSessionRepositoryProvider = Provider<ExerciseSessionRepository>((ref) {
  return ExerciseSessionRepositoryImpl(ref.watch(exerciseSessionDaoProvider));
});

final exerciseSessionVariantRepositoryProvider = Provider<ExerciseSessionVariantRepository>((ref) {
  return ExerciseSessionVariantRepositoryImpl(ref.watch(exerciseSessionVariantDaoProvider));
});

final setPlanRepositoryProvider = Provider<SetPlanRepository>((ref) {
  return SetPlanRepositoryImpl(ref.watch(setPlanDaoProvider));
});

final setSessionRepositoryProvider = Provider<SetSessionRepository>((ref) {
  return SetSessionRepositoryImpl(ref.watch(setSessionDaoProvider));
});

final trainingSessionRepositoryProvider = Provider<TrainingSessionRepository>((ref) {
  return TrainingSessionRepositoryImpl(ref.watch(trainingSessionDaoProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userDaoProvider));
});

final variantRepositoryProvider = Provider<VariantRepository>((ref) {
  return VariantRepositoryImpl(ref.watch(variantDaoProvider));
});
