import '../models/variant.dart';

abstract class VariantRepository {
  Future<Variant?> findById(String id);
  Future<List<Variant>> findAllActive();
  Future<Variant?> findByName(String name);
  Future<String> create(Variant entity);
  Future<void> update(Variant entity);
  Future<void> delete(String id);
}
