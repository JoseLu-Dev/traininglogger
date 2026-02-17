import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../local/database/daos/user_dao.dart';
import 'package:front_shared/src/core/logging/app_logger.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _dao;
  final _log = AppLogger.forClass(UserRepositoryImpl);

  UserRepositoryImpl(this._dao);

  @override
  Future<User?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<User>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<User?> findByEmail(String email) async {
    final data = await _dao.findByEmail(email);
    return data != null ? _dao.toDomain(data) : null;
  }


  @override
  Future<String> create(User entity) async {
    final result = await _dao.create(entity);
    _log.info('Created entity: ${entity.toString()}');
    return result;
  }

  @override
  Future<void> update(User entity) async {
    await _dao.updateEntity(entity);
    _log.info('Updated entity: ${entity.toString()}');
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
    _log.info('Deleted entity with id: $id');
  }
}
