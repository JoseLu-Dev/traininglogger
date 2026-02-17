import '../../domain/models/exercise_session.dart';
import '../../domain/repositories/exercise_session_repository.dart';
import '../local/database/daos/exercise_session_dao.dart';
import 'package:front_shared/src/core/logging/app_logger.dart';

class ExerciseSessionRepositoryImpl implements ExerciseSessionRepository {
  final ExerciseSessionDao _dao;
  final _log = AppLogger.forClass(ExerciseSessionRepositoryImpl);

  ExerciseSessionRepositoryImpl(this._dao);

  @override
  Future<ExerciseSession?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<ExerciseSession>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<ExerciseSession>> findByTrainingSessionId(String trainingSessionId) async {
    final dataList = await _dao.findByTrainingSessionId(trainingSessionId);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(ExerciseSession entity) async {
    final result = await _dao.create(entity);
    _log.info('Created entity: ${entity.toString()}');
    return result;
  }

  @override
  Future<void> update(ExerciseSession entity) async {
    await _dao.updateEntity(entity);
    _log.info('Updated entity: ${entity.toString()}');
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
    _log.info('Deleted entity with id: $id');
  }
}
