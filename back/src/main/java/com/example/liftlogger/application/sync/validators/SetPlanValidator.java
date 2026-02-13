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

        // Target reps validation (1-1000)
        if (plan.getTargetReps() != null) {
            min(plan.getTargetReps(), 1, "targetReps");
            max(plan.getTargetReps(), 1000, "targetReps");
        }

        // Target weight validation (0-1000)
        if (plan.getTargetWeight() != null) {
            min(plan.getTargetWeight(), 0.0, "targetWeight");
            max(plan.getTargetWeight(), 1000.0, "targetWeight");
        }

        // Target RPE validation (0-10)
        if (plan.getTargetRpe() != null) {
            min(plan.getTargetRpe(), 0.0, "targetRpe");
            max(plan.getTargetRpe(), 10.0, "targetRpe");
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
