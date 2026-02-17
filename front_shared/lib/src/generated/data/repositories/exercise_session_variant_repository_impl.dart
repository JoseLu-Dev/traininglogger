import '../../domain/models/exercise_session_variant.dart';
import '../../domain/repositories/exercise_session_variant_repository.dart';
import '../local/database/daos/exercise_session_variant_dao.dart';
import 'package:front_shared/src/core/logging/app_logger.dart';

class ExerciseSessionVariantRepositoryImpl implements ExerciseSessionVariantRepository {
  final ExerciseSessionVariantDao _dao;
  final _log = AppLogger.forClass(ExerciseSessionVariantRepositoryImpl);

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
    final result = await _dao.create(entity);
    _log.info('Created entity: ${entity.toString()}');
    return result;
  }

  @override
  Future<void> update(ExerciseSessionVariant entity) async {
    await _dao.updateEntity(entity);
    _log.info('Updated entity: ${entity.toString()}');
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
    _log.info('Deleted entity with id: $id');
  }
}
