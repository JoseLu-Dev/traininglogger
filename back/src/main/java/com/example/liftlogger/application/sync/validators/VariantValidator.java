package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.Variant;
import com.example.liftlogger.domain.outbound.repository.ExerciseRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class VariantValidator extends BaseValidator implements EntityValidator<Variant> {

    private final UserRepository userRepository;
    private final ExerciseRepository exerciseRepository;

    @Override
    public ValidationResult validate(Variant variant, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(variant.getId(), "id");
        requiredUUID(variant.getCoachId(), "coachId");
        requiredString(variant.getName(), "name");
        minLength(variant.getName(), 2, "name");
        maxLength(variant.getName(), 100, "name");
        maxLength(variant.getDescription(), 1000, "description");
        requiredUUID(variant.getExerciseId(), "exerciseId");

        // Ownership validation (only coaches can create variants)
        if (!context.isCoach()) {
            errors.add(ValidationError.invalid("coachId",
                "Only coaches can create variants"));
        }

        if (variant.getCoachId() != null && context.currentUserId() != null
            && !variant.getCoachId().equals(context.currentUserId())) {
            errors.add(ValidationError.invalid("coachId",
                "You can only create variants for yourself"));
        }

        // Cross-entity validation
        if (variant.getCoachId() != null && !userRepository.existsById(variant.getCoachId())) {
            errors.add(ValidationError.notFound("coachId", "User"));
        }

        if (variant.getExerciseId() != null && !exerciseRepository.existsById(variant.getExerciseId())) {
            errors.add(ValidationError.notFound("exerciseId", "Exercise"));
        }

        return buildResult();
    }
}
