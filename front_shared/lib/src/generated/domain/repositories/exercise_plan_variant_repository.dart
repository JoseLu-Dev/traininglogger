import '../models/exercise_plan_variant.dart';

abstract class ExercisePlanVariantRepository {
  Future<ExercisePlanVariant?> findById(String id);
  Future<List<ExercisePlanVariant>> findAllActive();
  Future<List<ExercisePlanVariant>> findByExercisePlanId(String exercisePlanId);
  Future<List<ExercisePlanVariant>> findByVariantId(String variantId);
  Future<String> create(ExercisePlanVariant entity);
  Future<void> update(ExercisePlanVariant entity);
  Future<void> delete(String id);
}
