package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.dto.UserSyncDto;
import com.example.liftlogger.application.sync.validators.BodyWeightEntryValidator;
import com.example.liftlogger.application.sync.validators.ExercisePlanValidator;
import com.example.liftlogger.application.sync.validators.ExerciseSessionValidator;
import com.example.liftlogger.application.sync.validators.ExerciseValidator;
import com.example.liftlogger.application.sync.validators.SetPlanValidator;
import com.example.liftlogger.application.sync.validators.SetSessionValidator;
import com.example.liftlogger.application.sync.validators.TrainingPlanValidator;
import com.example.liftlogger.application.sync.validators.TrainingSessionValidator;
import com.example.liftlogger.application.sync.validators.UserValidator;
import com.example.liftlogger.application.sync.validators.UserSyncDtoValidator;
import com.example.liftlogger.application.sync.validators.VariantValidator;
import com.example.liftlogger.domain.model.BodyWeightEntry;
import com.example.liftlogger.domain.model.Exercise;
import com.example.liftlogger.domain.model.ExercisePlan;
import com.example.liftlogger.domain.model.ExerciseSession;
import com.example.liftlogger.domain.model.SetPlan;
import com.example.liftlogger.domain.model.SetSession;
import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.domain.model.TrainingSession;
import com.example.liftlogger.domain.model.Variant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuration for all syncable entities.
 *
 * TO ADD A NEW ENTITY:
 * 1. Create validator (or use NoOpValidator)
 * 2. Add @Autowired field for validator
 * 3. Add .register() line in entityRegistry() method
 */
@Configuration
public class EntitySyncConfiguration {

    @Autowired private UserValidator userValidator;
    @Autowired private UserSyncDtoValidator userSyncDtoValidator;
    @Autowired private ExerciseValidator exerciseValidator;
    @Autowired private VariantValidator variantValidator;
    @Autowired private TrainingPlanValidator trainingPlanValidator;
    @Autowired private ExercisePlanValidator exercisePlanValidator;
    @Autowired private SetPlanValidator setPlanValidator;
    @Autowired private TrainingSessionValidator trainingSessionValidator;
    @Autowired private ExerciseSessionValidator exerciseSessionValidator;
    @Autowired private SetSessionValidator setSessionValidator;
    @Autowired private BodyWeightEntryValidator bodyWeightEntryValidator;

    @Bean
    public EntityRegistry entityRegistry() {
        EntityRegistry registry = new EntityRegistry();

        // Register all 10 entity types
        // Format: .register(EntityClass.class, "ownerField", ownershipType, validator)
        // Note: User uses UserSyncDto to exclude password from sync

        registry.register(UserSyncDto.class, "User", "id", OwnershipType.ATHLETE, userSyncDtoValidator);
        registry.register(Exercise.class, "coachId", OwnershipType.COACH, exerciseValidator);
        registry.register(Variant.class, "coachId", OwnershipType.COACH, variantValidator);
        registry.register(TrainingPlan.class, "athleteId", OwnershipType.ATHLETE, trainingPlanValidator);
        registry.register(ExercisePlan.class, "athleteId", OwnershipType.ATHLETE, exercisePlanValidator);
        registry.register(SetPlan.class, "athleteId", OwnershipType.ATHLETE, setPlanValidator);
        registry.register(TrainingSession.class, "athleteId", OwnershipType.ATHLETE, trainingSessionValidator);
        registry.register(ExerciseSession.class, "athleteId", OwnershipType.ATHLETE, exerciseSessionValidator);
        registry.register(SetSession.class, "athleteId", OwnershipType.ATHLETE, setSessionValidator);
        registry.register(BodyWeightEntry.class, "athleteId", OwnershipType.ATHLETE, bodyWeightEntryValidator);

        return registry;
    }
}
