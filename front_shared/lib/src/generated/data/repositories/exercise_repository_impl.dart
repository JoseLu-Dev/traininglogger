import '../../domain/models/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../local/database/daos/exercise_dao.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseDao _dao;

  ExerciseRepositoryImpl(this._dao);

  @override
  Future<Exercise?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<Exercise>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<Exercise?> findByName(String name) async {
    final data = await _dao.findByName(name);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<Exercise>> findByCategory(String category) async {
    final dataList = await _dao.findByCategory(category);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(Exercise entity) async {
    return await _dao.create(entity);
  }

  @override
  Future<void> update(Exercise entity) async {
    await _dao.updateEntity(entity);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
