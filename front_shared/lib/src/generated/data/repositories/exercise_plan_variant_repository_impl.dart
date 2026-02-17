import '../../domain/models/exercise_plan_variant.dart';
import '../../domain/repositories/exercise_plan_variant_repository.dart';
import '../local/database/daos/exercise_plan_variant_dao.dart';

class ExercisePlanVariantRepositoryImpl implements ExercisePlanVariantRepository {
  final ExercisePlanVariantDao _dao;

  ExercisePlanVariantRepositoryImpl(this._dao);

  @override
  Future<ExercisePlanVariant?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<ExercisePlanVariant>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<ExercisePlanVariant>> findByExercisePlanId(String exercisePlanId) async {
    final dataList = await _dao.findByExercisePlanId(exercisePlanId);
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<ExercisePlanVariant>> findByVariantId(String variantId) async {
    final dataList = await _dao.findByVariantId(variantId);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(ExercisePlanVariant entity) async {
    return await _dao.create(entity);
  }

  @override
  Future<void> update(ExercisePlanVariant entity) async {
    await _dao.updateEntity(entity);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
