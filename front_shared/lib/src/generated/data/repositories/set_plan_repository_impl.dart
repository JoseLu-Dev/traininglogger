import '../../domain/models/set_plan.dart';
import '../../domain/repositories/set_plan_repository.dart';
import '../local/database/daos/set_plan_dao.dart';
import 'package:front_shared/src/core/logging/app_logger.dart';

class SetPlanRepositoryImpl implements SetPlanRepository {
  final SetPlanDao _dao;
  final _log = AppLogger.forClass(SetPlanRepositoryImpl);

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
    final result = await _dao.create(entity);
    _log.info('Created entity: ${entity.toString()}');
    return result;
  }

  @override
  Future<void> update(SetPlan entity) async {
    await _dao.updateEntity(entity);
    _log.info('Updated entity: ${entity.toString()}');
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
    _log.info('Deleted entity with id: $id');
  }
}
