package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.ExerciseSessionVariant;
import com.example.liftlogger.domain.outbound.repository.ExerciseSessionRepository;
import com.example.liftlogger.domain.outbound.repository.VariantRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ExerciseSessionVariantValidator extends BaseValidator implements EntityValidator<ExerciseSessionVariant> {

    private final UserRepository userRepository;
    private final ExerciseSessionRepository exerciseSessionRepository;
    private final VariantRepository variantRepository;

    @Override
    public ValidationResult validate(ExerciseSessionVariant sessionVariant, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(sessionVariant.getId(), "id");
        requiredUUID(sessionVariant.getAthleteId(), "athleteId");
        requiredUUID(sessionVariant.getExerciseSessionId(), "exerciseSessionId");
        requiredUUID(sessionVariant.getVariantId(), "variantId");

        // Ownership validation
        if (sessionVariant.getAthleteId() != null && context.currentUserId() != null
            && !sessionVariant.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create exercise session variants for yourself"));
        }

        // Cross-entity validation
        if (sessionVariant.getAthleteId() != null && !userRepository.existsById(sessionVariant.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        if (sessionVariant.getExerciseSessionId() != null && !exerciseSessionRepository.existsById(sessionVariant.getExerciseSessionId())) {
            errors.add(ValidationError.notFound("exerciseSessionId", "ExerciseSession"));
        }

        if (sessionVariant.getVariantId() != null && !variantRepository.existsById(sessionVariant.getVariantId())) {
            errors.add(ValidationError.notFound("variantId", "Variant"));
        }

        return buildResult();
    }
}
