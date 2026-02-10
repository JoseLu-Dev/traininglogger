import '../models/exercise_plan.dart';

abstract class ExercisePlanRepository {
  Future<ExercisePlan?> findById(String id);
  Future<List<ExercisePlan>> findAllActive();
  Future<List<ExercisePlan>> findByTrainingPlanId(String trainingPlanId);
  Future<String> create(ExercisePlan entity);
  Future<void> update(ExercisePlan entity);
  Future<void> delete(String id);
}
