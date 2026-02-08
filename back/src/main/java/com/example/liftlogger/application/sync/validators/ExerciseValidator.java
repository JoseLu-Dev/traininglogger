package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.Exercise;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ExerciseValidator extends BaseValidator implements EntityValidator<Exercise> {

    private final UserRepository userRepository;

    @Override
    public ValidationResult validate(Exercise exercise, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(exercise.getId(), "id");
        requiredUUID(exercise.getCoachId(), "coachId");
        requiredString(exercise.getName(), "name");
        minLength(exercise.getName(), 3, "name");
        maxLength(exercise.getName(), 100, "name");
        maxLength(exercise.getDescription(), 2000, "description");

        // Ownership validation (only coaches can create exercises)
        if (!context.isCoach()) {
            errors.add(ValidationError.invalid("coachId",
                "Only coaches can create exercises"));
        }

        if (exercise.getCoachId() != null && context.currentUserId() != null
            && !exercise.getCoachId().equals(context.currentUserId())) {
            errors.add(ValidationError.invalid("coachId",
                "You can only create exercises for yourself"));
        }

        // Cross-entity validation
        if (exercise.getCoachId() != null && !userRepository.existsById(exercise.getCoachId())) {
            errors.add(ValidationError.notFound("coachId", "User"));
        }

        return buildResult();
    }
}
