import '../models/set_plan.dart';

abstract class SetPlanRepository {
  Future<SetPlan?> findById(String id);
  Future<List<SetPlan>> findAllActive();
  Future<List<SetPlan>> findByExercisePlanId(String exercisePlanId);
  Future<String> create(SetPlan entity);
  Future<void> update(SetPlan entity);
  Future<void> delete(String id);
}
