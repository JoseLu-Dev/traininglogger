import '../../domain/models/set_plan.dart';
import '../../domain/repositories/set_plan_repository.dart';
import '../local/database/daos/set_plan_dao.dart';

class SetPlanRepositoryImpl implements SetPlanRepository {
  final SetPlanDao _dao;

  SetPlanRepositoryImpl(this._dao);

  @override
  Future<SetPlan?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<SetPlan>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<SetPlan>> findByExercisePlanId(String exercisePlanId) async {
    final dataList = await _dao.findByExercisePlanId(exercisePlanId);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(SetPlan entity) async {
    return await _dao.create(entity);
  }

  @override
  Future<void> update(SetPlan entity) async {
    await _dao.markDirty(entity.id);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
