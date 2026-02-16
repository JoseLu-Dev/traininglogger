import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sync/core/entity_registry.dart';
import '../sync/core/entity_registry_setup.dart';
import '../data/local/database/app_database.dart';

final appIdentifierProvider = Provider<String>((ref) {
  throw UnimplementedError('appIdentifierProvider must be overridden in ProviderScope');
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final appIdentifier = ref.watch(appIdentifierProvider);
  final db = AppDatabase(appIdentifier);
  ref.onDispose(() => db.close());
  return db;
});

final entityRegistryProvider = Provider<EntityRegistry>((ref) {
  final registry = EntityRegistry();
  final db = ref.watch(databaseProvider);
  setupEntityRegistry(registry, db);
  return registry;
});

// DAO providers
final trainingPlanDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).trainingPlanDao;
});

final bodyWeightEntryDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).bodyWeightEntryDao;
});

final exerciseDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).exerciseDao;
});

final exercisePlanDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).exercisePlanDao;
});

final exercisePlanVariantDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).exercisePlanVariantDao;
});

final exerciseSessionDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).exerciseSessionDao;
});

final exerciseSessionVariantDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).exerciseSessionVariantDao;
});

final setPlanDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).setPlanDao;
});

final setSessionDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).setSessionDao;
});

final trainingSessionDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).trainingSessionDao;
});

final userDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).userDao;
});

final variantDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).variantDao;
});
