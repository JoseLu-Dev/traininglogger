import 'entity_registry.dart';
import '../../data/local/database/app_database.dart';

/// Setup function to register all entities in the registry
/// This is called once during app initialization
void setupEntityRegistry(EntityRegistry registry, AppDatabase db) {
  // Register TrainingPlan entity
  registry.register(
    entityType: 'TrainingPlan',
    dao: db.trainingPlanDao,
    fromJson: (json) => TrainingPlanData.fromJson(json),
    toJson: (data) => (data as TrainingPlanData).toJson(),
    toDomain: (data) => db.trainingPlanDao.toDomain(data as TrainingPlanData),
  );

  // Register BodyWeightEntry entity
  registry.register(
    entityType: 'BodyWeightEntry',
    dao: db.bodyWeightEntryDao,
    fromJson: (json) => BodyWeightEntryData.fromJson(json),
    toJson: (data) => (data as BodyWeightEntryData).toJson(),
    toDomain: (data) => db.bodyWeightEntryDao.toDomain(data as BodyWeightEntryData),
  );

  // Register Exercise entity
  registry.register(
    entityType: 'Exercise',
    dao: db.exerciseDao,
    fromJson: (json) => ExerciseData.fromJson(json),
    toJson: (data) => (data as ExerciseData).toJson(),
    toDomain: (data) => db.exerciseDao.toDomain(data as ExerciseData),
  );

  // Register ExercisePlan entity
  registry.register(
    entityType: 'ExercisePlan',
    dao: db.exercisePlanDao,
    fromJson: (json) => ExercisePlanData.fromJson(json),
    toJson: (data) => (data as ExercisePlanData).toJson(),
    toDomain: (data) => db.exercisePlanDao.toDomain(data as ExercisePlanData),
  );

  // Register ExercisePlanVariant entity
  registry.register(
    entityType: 'ExercisePlanVariant',
    dao: db.exercisePlanVariantDao,
    fromJson: (json) => ExercisePlanVariantData.fromJson(json),
    toJson: (data) => (data as ExercisePlanVariantData).toJson(),
    toDomain: (data) => db.exercisePlanVariantDao.toDomain(data as ExercisePlanVariantData),
  );

  // Register ExerciseSession entity
  registry.register(
    entityType: 'ExerciseSession',
    dao: db.exerciseSessionDao,
    fromJson: (json) => ExerciseSessionData.fromJson(json),
    toJson: (data) => (data as ExerciseSessionData).toJson(),
    toDomain: (data) => db.exerciseSessionDao.toDomain(data as ExerciseSessionData),
  );

  // Register ExerciseSessionVariant entity
  registry.register(
    entityType: 'ExerciseSessionVariant',
    dao: db.exerciseSessionVariantDao,
    fromJson: (json) => ExerciseSessionVariantData.fromJson(json),
    toJson: (data) => (data as ExerciseSessionVariantData).toJson(),
    toDomain: (data) => db.exerciseSessionVariantDao.toDomain(data as ExerciseSessionVariantData),
  );

  // Register SetPlan entity
  registry.register(
    entityType: 'SetPlan',
    dao: db.setPlanDao,
    fromJson: (json) => SetPlanData.fromJson(json),
    toJson: (data) => (data as SetPlanData).toJson(),
    toDomain: (data) => db.setPlanDao.toDomain(data as SetPlanData),
  );

  // Register SetSession entity
  registry.register(
    entityType: 'SetSession',
    dao: db.setSessionDao,
    fromJson: (json) => SetSessionData.fromJson(json),
    toJson: (data) => (data as SetSessionData).toJson(),
    toDomain: (data) => db.setSessionDao.toDomain(data as SetSessionData),
  );

  // Register TrainingSession entity
  registry.register(
    entityType: 'TrainingSession',
    dao: db.trainingSessionDao,
    fromJson: (json) => TrainingSessionData.fromJson(json),
    toJson: (data) => (data as TrainingSessionData).toJson(),
    toDomain: (data) => db.trainingSessionDao.toDomain(data as TrainingSessionData),
  );

  // Register User entity
  registry.register(
    entityType: 'User',
    dao: db.userDao,
    fromJson: (json) => UserData.fromJson(json),
    toJson: (data) => (data as UserData).toJson(),
    toDomain: (data) => db.userDao.toDomain(data as UserData),
  );

  // Register Variant entity
  registry.register(
    entityType: 'Variant',
    dao: db.variantDao,
    fromJson: (json) => VariantData.fromJson(json),
    toJson: (data) => (data as VariantData).toJson(),
    toDomain: (data) => db.variantDao.toDomain(data as VariantData),
  );
}
