import '../../domain/models/set_session.dart';
import '../../domain/repositories/set_session_repository.dart';
import '../local/database/daos/set_session_dao.dart';
import 'package:front_shared/src/core/logging/app_logger.dart';

class SetSessionRepositoryImpl implements SetSessionRepository {
  final SetSessionDao _dao;
  final _log = AppLogger.forClass(SetSessionRepositoryImpl);

  SetSessionRepositoryImpl(this._dao);

  @override
  Future<SetSession?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<SetSession>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<SetSession>> findByExerciseSessionId(String exerciseSessionId) async {
    final dataList = await _dao.findByExerciseSessionId(exerciseSessionId);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(SetSession entity) async {
    final result = await _dao.create(entity);
    _log.info('Created entity: ${entity.toString()}');
    return result;
  }

  @override
  Future<void> update(SetSession entity) async {
    await _dao.updateEntity(entity);
    _log.info('Updated entity: ${entity.toString()}');
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
    _log.info('Deleted entity with id: $id');
  }
}
