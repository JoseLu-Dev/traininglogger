package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.SetPlan;
import com.example.liftlogger.domain.outbound.repository.ExercisePlanRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SetPlanValidator extends BaseValidator implements EntityValidator<SetPlan> {

    private final UserRepository userRepository;
    private final ExercisePlanRepository exercisePlanRepository;

    @Override
    public ValidationResult validate(SetPlan plan, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(plan.getId(), "id");
        requiredUUID(plan.getAthleteId(), "athleteId");
        requiredUUID(plan.getExercisePlanId(), "exercisePlanId");

        // Reps validation (1-1000)
        if (plan.getReps() != null) {
            min(plan.getReps(), 1, "reps");
            max(plan.getReps(), 1000, "reps");
        }

        // Weight validation (0-1000)
        if (plan.getWeight() != null) {
            min(plan.getWeight(), 0.0, "weight");
            max(plan.getWeight(), 1000.0, "weight");
        }

        // Ownership validation
        if (plan.getAthleteId() != null && context.currentUserId() != null
            && !plan.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create set plans for yourself"));
        }

        // Cross-entity validation
        if (plan.getAthleteId() != null && !userRepository.existsById(plan.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        if (plan.getExercisePlanId() != null && !exercisePlanRepository.existsById(plan.getExercisePlanId())) {
            errors.add(ValidationError.notFound("exercisePlanId", "ExercisePlan"));
        }

        return buildResult();
    }
}
