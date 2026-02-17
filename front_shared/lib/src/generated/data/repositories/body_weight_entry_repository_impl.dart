import '../../domain/models/body_weight_entry.dart';
import '../../domain/repositories/body_weight_entry_repository.dart';
import '../local/database/daos/body_weight_entry_dao.dart';
import 'package:front_shared/src/core/logging/app_logger.dart';

class BodyWeightEntryRepositoryImpl implements BodyWeightEntryRepository {
  final BodyWeightEntryDao _dao;
  final _log = AppLogger.forClass(BodyWeightEntryRepositoryImpl);

  BodyWeightEntryRepositoryImpl(this._dao);

  @override
  Future<BodyWeightEntry?> findById(String id) async {
    final data = await _dao.findById(id);
    return data != null ? _dao.toDomain(data) : null;
  }

  @override
  Future<List<BodyWeightEntry>> findAllActive() async {
    final dataList = await _dao.findAllActive();
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<BodyWeightEntry>> findByAthleteId(String athleteId) async {
    final dataList = await _dao.findByAthleteId(athleteId);
    return dataList.map(_dao.toDomain).toList();
  }

  @override
  Future<List<BodyWeightEntry>> findByAthleteBetweenDates(String athleteId, String start, String end) async {
    final dataList = await _dao.findByAthleteBetweenDates(athleteId, start, end);
    return dataList.map(_dao.toDomain).toList();
  }


  @override
  Future<String> create(BodyWeightEntry entity) async {
    final result = await _dao.create(entity);
    _log.info('Created entity: ${entity.toString()}');
    return result;
  }

  @override
  Future<void> update(BodyWeightEntry entity) async {
    await _dao.updateEntity(entity);
    _log.info('Updated entity: ${entity.toString()}');
  }

  @override
  Future<void> delete(String id) async {
    await _dao.softDelete(id);
    _log.info('Deleted entity with id: $id');
  }
}
