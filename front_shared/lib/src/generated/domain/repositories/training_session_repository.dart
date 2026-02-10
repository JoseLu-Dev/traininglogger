import '../models/training_session.dart';

abstract class TrainingSessionRepository {
  Future<TrainingSession?> findById(String id);
  Future<List<TrainingSession>> findAllActive();
  Future<List<TrainingSession>> findByTrainingPlanId(String trainingPlanId);
  Future<List<TrainingSession>> findByAthleteId(String athleteId);
  Future<String> create(TrainingSession entity);
  Future<void> update(TrainingSession entity);
  Future<void> delete(String id);
}
