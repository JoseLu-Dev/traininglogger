import '../models/training_plan.dart';

abstract class TrainingPlanRepository {
  Future<TrainingPlan?> findById(String id);
  Future<List<TrainingPlan>> findAllActive();
  Future<List<TrainingPlan>> findByAthleteId(String athleteId);
  Future<List<TrainingPlan>> findByAthleteBetweenDates(String athleteId, String start, String end);
  Future<String> create(TrainingPlan entity);
  Future<void> update(TrainingPlan entity);
  Future<void> delete(String id);
}
