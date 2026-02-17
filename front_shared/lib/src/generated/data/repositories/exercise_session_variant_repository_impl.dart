import '../../domain/models/exercise_session_variant.dart';
import '../../domain/repositories/exercise_session_variant_repository.dart';
import '../local/database/daos/exercise_session_variant_dao.dart';

class ExerciseSessionVariantRepositoryImpl implements ExerciseSessionVariantRepository {
  final ExerciseSessionVariantDao _dao;

  ExerciseSessionVariantRepositoryImpl(this._dao);

  @override
  Future<ExerciseSessionVariant?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<ExerciseSessionVariant>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<ExerciseSessionVariant>> findByExerciseSessionId(String exerciseSessionId) async {
    final dataList = await _dao.findByExerciseSessionId(exerciseSessionId);
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<ExerciseSessionVariant>> findByVariantId(String variantId) async {
    final dataList = await _dao.findByVariantId(variantId);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(ExerciseSessionVariant entity) async {
    return await _dao.create(entity);
  }

  @override
  Future<void> update(ExerciseSessionVariant entity) async {
    await _dao.updateEntity(entity);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
