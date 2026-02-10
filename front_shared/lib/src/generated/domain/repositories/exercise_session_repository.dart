import '../models/exercise_session.dart';

abstract class ExerciseSessionRepository {
  Future<ExerciseSession?> findById(String id);
  Future<List<ExerciseSession>> findAllActive();
  Future<List<ExerciseSession>> findByTrainingSessionId(String trainingSessionId);
  Future<String> create(ExerciseSession entity);
  Future<void> update(ExerciseSession entity);
  Future<void> delete(String id);
}
