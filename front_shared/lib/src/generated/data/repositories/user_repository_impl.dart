import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../local/database/daos/user_dao.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _dao;

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
    return await _dao.create(entity);
  }

  @override
  Future<void> update(User entity) async {
    await _dao.updateEntity(entity);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
