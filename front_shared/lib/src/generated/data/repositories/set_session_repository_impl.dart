import '../../domain/models/set_session.dart';
import '../../domain/repositories/set_session_repository.dart';
import '../local/database/daos/set_session_dao.dart';

class SetSessionRepositoryImpl implements SetSessionRepository {
  final SetSessionDao _dao;

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
    return await _dao.create(entity);
  }

  @override
  Future<void> update(SetSession entity) async {
    await _dao.markDirty(entity.id);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
