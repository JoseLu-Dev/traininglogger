package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.validators.BodyWeightEntryValidator;
import com.example.liftlogger.application.sync.validators.ExercisePlanValidator;
import com.example.liftlogger.application.sync.validators.ExerciseSessionValidator;
import com.example.liftlogger.application.sync.validators.ExerciseValidator;
import com.example.liftlogger.application.sync.validators.SetPlanValidator;
import com.example.liftlogger.application.sync.validators.SetSessionValidator;
import com.example.liftlogger.application.sync.validators.TrainingPlanValidator;
import com.example.liftlogger.application.sync.validators.TrainingSessionValidator;
import com.example.liftlogger.application.sync.validators.UserValidator;
import com.example.liftlogger.application.sync.validators.VariantValidator;
import com.example.liftlogger.domain.model.BodyWeightEntry;
import com.example.liftlogger.domain.model.Exercise;
import com.example.liftlogger.domain.model.ExercisePlan;
import com.example.liftlogger.domain.model.ExerciseSession;
import com.example.liftlogger.domain.model.SetPlan;
import com.example.liftlogger.domain.model.SetSession;
import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.domain.model.TrainingSession;
import com.example.liftlogger.domain.model.User;
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
        // Format: .register(EntityClass.class, "ownerField", validator)

        registry.register(User.class, "id", userValidator);
        registry.register(Exercise.class, "coachId", exerciseValidator);
        registry.register(Variant.class, "coachId", variantValidator);
        registry.register(TrainingPlan.class, "athleteId", trainingPlanValidator);
        registry.register(ExercisePlan.class, "athleteId", exercisePlanValidator);
        registry.register(SetPlan.class, "athleteId", setPlanValidator);
        registry.register(TrainingSession.class, "athleteId", trainingSessionValidator);
        registry.register(ExerciseSession.class, "athleteId", exerciseSessionValidator);
        registry.register(SetSession.class, "athleteId", setSessionValidator);
        registry.register(BodyWeightEntry.class, "athleteId", bodyWeightEntryValidator);

        return registry;
    }
}
