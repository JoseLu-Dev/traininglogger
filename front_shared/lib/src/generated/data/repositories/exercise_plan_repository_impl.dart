import '../../domain/models/exercise_plan.dart';
import '../../domain/repositories/exercise_plan_repository.dart';
import '../local/database/daos/exercise_plan_dao.dart';

class ExercisePlanRepositoryImpl implements ExercisePlanRepository {
  final ExercisePlanDao _dao;

  ExercisePlanRepositoryImpl(this._dao);

  @override
  Future<ExercisePlan?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<ExercisePlan>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<ExercisePlan>> findByTrainingPlanId(String trainingPlanId) async {
    final dataList = await _dao.findByTrainingPlanId(trainingPlanId);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(ExercisePlan entity) async {
    return await _dao.create(entity);
  }

  @override
  Future<void> update(ExercisePlan entity) async {
    await _dao.markDirty(entity.id);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
