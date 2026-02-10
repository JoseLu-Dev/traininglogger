import '../models/body_weight_entry.dart';

abstract class BodyWeightEntryRepository {
  Future<BodyWeightEntry?> findById(String id);
  Future<List<BodyWeightEntry>> findAllActive();
  Future<List<BodyWeightEntry>> findByAthleteId(String athleteId);
  Future<List<BodyWeightEntry>> findByAthleteBetweenDates(String athleteId, DateTime start, DateTime end);
  Future<String> create(BodyWeightEntry entity);
  Future<void> update(BodyWeightEntry entity);
  Future<void> delete(String id);
}
