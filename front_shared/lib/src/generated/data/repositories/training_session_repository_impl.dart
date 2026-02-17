import '../../domain/models/training_session.dart';
import '../../domain/repositories/training_session_repository.dart';
import '../local/database/daos/training_session_dao.dart';

class TrainingSessionRepositoryImpl implements TrainingSessionRepository {
  final TrainingSessionDao _dao;

  TrainingSessionRepositoryImpl(this._dao);

  @override
  Future<TrainingSession?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<TrainingSession>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<TrainingSession>> findByTrainingPlanId(String trainingPlanId) async {
    final dataList = await _dao.findByTrainingPlanId(trainingPlanId);
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<TrainingSession>> findByAthleteId(String athleteId) async {
    final dataList = await _dao.findByAthleteId(athleteId);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(TrainingSession entity) async {
    return await _dao.create(entity);
  }

  @override
  Future<void> update(TrainingSession entity) async {
    await _dao.updateEntity(entity);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
