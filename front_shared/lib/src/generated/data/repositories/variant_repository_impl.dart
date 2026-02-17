import '../../domain/models/variant.dart';
import '../../domain/repositories/variant_repository.dart';
import '../local/database/daos/variant_dao.dart';
import 'package:front_shared/src/core/logging/app_logger.dart';

class VariantRepositoryImpl implements VariantRepository {
  final VariantDao _dao;
  final _log = AppLogger.forClass(VariantRepositoryImpl);

  VariantRepositoryImpl(this._dao);

  @override
  Future<Variant?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<Variant>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<Variant?> findByName(String name) async {
    final data = await _dao.findByName(name);
    return data != null ? _dao.toDomain(data) : null;
  }


  @override
  Future<String> create(Variant entity) async {
    final result = await _dao.create(entity);
    _log.info('Created entity: ${entity.toString()}');
    return result;
  }

  @override
  Future<void> update(Variant entity) async {
    await _dao.updateEntity(entity);
    _log.info('Updated entity: ${entity.toString()}');
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
    _log.info('Deleted entity with id: $id');
  }
}
