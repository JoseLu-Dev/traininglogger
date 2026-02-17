import '../../domain/models/variant.dart';
import '../../domain/repositories/variant_repository.dart';
import '../local/database/daos/variant_dao.dart';

class VariantRepositoryImpl implements VariantRepository {
  final VariantDao _dao;

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
    return await _dao.create(entity);
  }

  @override
  Future<void> update(Variant entity) async {
    await _dao.updateEntity(entity);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
  }
}
