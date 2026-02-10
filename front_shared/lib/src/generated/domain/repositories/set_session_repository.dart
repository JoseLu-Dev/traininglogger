import '../models/set_session.dart';

abstract class SetSessionRepository {
  Future<SetSession?> findById(String id);
  Future<List<SetSession>> findAllActive();
  Future<List<SetSession>> findByExerciseSessionId(String exerciseSessionId);
  Future<String> create(SetSession entity);
  Future<void> update(SetSession entity);
  Future<void> delete(String id);
}
