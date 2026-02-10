import '../models/exercise.dart';

abstract class ExerciseRepository {
  Future<Exercise?> findById(String id);
  Future<List<Exercise>> findAllActive();
  Future<Exercise?> findByName(String name);
  Future<List<Exercise>> findByCategory(String category);
  Future<String> create(Exercise entity);
  Future<void> update(Exercise entity);
  Future<void> delete(String id);
}
