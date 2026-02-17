import '../../domain/models/training_plan.dart';
import '../../domain/repositories/training_plan_repository.dart';
import '../local/database/daos/training_plan_dao.dart';

class TrainingPlanRepositoryImpl implements TrainingPlanRepository {
  final TrainingPlanDao _dao;

  TrainingPlanRepositoryImpl(this._dao);

  @override
  Future<TrainingPlan?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<TrainingPlan>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<TrainingPlan>> findByAthleteId(String athleteId) async {
    final dataList = await _dao.findByAthleteId(athleteId);
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<TrainingPlan>> findByAthleteBetweenDates(String athleteId, String start, String end) async {
    final dataList = await _dao.findByAthleteBetweenDates(athleteId, start, end);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(TrainingPlan entity) async {
    return await _dao.create(entity);
  }

  @override
  Future<void> update(TrainingPlan entity) async {
    await _dao.updateEntity(entity);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
