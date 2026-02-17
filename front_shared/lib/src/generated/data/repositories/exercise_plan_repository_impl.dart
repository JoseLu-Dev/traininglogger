import '../../domain/models/exercise_plan.dart';
import '../../domain/repositories/exercise_plan_repository.dart';
import '../local/database/daos/exercise_plan_dao.dart';
import 'package:front_shared/src/core/logging/app_logger.dart';

class ExercisePlanRepositoryImpl implements ExercisePlanRepository {
  final ExercisePlanDao _dao;
  final _log = AppLogger.forClass(ExercisePlanRepositoryImpl);

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
    final result = await _dao.create(entity);
    _log.info('Created entity: ${entity.toString()}');
    return result;
  }

  @override
  Future<void> update(ExercisePlan entity) async {
    await _dao.updateEntity(entity);
    _log.info('Updated entity: ${entity.toString()}');
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
    _log.info('Deleted entity with id: $id');
  }
}
