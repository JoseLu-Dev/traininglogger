import '../models/exercise_session_variant.dart';

abstract class ExerciseSessionVariantRepository {
  Future<ExerciseSessionVariant?> findById(String id);
  Future<List<ExerciseSessionVariant>> findAllActive();
  Future<List<ExerciseSessionVariant>> findByExerciseSessionId(String exerciseSessionId);
  Future<List<ExerciseSessionVariant>> findByVariantId(String variantId);
  Future<String> create(ExerciseSessionVariant entity);
  Future<void> update(ExerciseSessionVariant entity);
  Future<void> delete(String id);
}
