package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.ExercisePlanVariant;
import com.example.liftlogger.domain.outbound.repository.ExercisePlanRepository;
import com.example.liftlogger.domain.outbound.repository.VariantRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ExercisePlanVariantValidator extends BaseValidator implements EntityValidator<ExercisePlanVariant> {

    private final UserRepository userRepository;
    private final ExercisePlanRepository exercisePlanRepository;
    private final VariantRepository variantRepository;

    @Override
    public ValidationResult validate(ExercisePlanVariant planVariant, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(planVariant.getId(), "id");
        requiredUUID(planVariant.getAthleteId(), "athleteId");
        requiredUUID(planVariant.getExercisePlanId(), "exercisePlanId");
        requiredUUID(planVariant.getVariantId(), "variantId");

        // Ownership validation
        if (planVariant.getAthleteId() != null && context.currentUserId() != null
            && !planVariant.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create exercise plan variants for yourself"));
        }

        // Cross-entity validation
        if (planVariant.getAthleteId() != null && !userRepository.existsById(planVariant.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        if (planVariant.getExercisePlanId() != null && !exercisePlanRepository.existsById(planVariant.getExercisePlanId())) {
            errors.add(ValidationError.notFound("exercisePlanId", "ExercisePlan"));
        }

        if (planVariant.getVariantId() != null && !variantRepository.existsById(planVariant.getVariantId())) {
            errors.add(ValidationError.notFound("variantId", "Variant"));
        }

        return buildResult();
    }
}
