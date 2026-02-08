package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.ExercisePlan;
import com.example.liftlogger.domain.outbound.repository.ExerciseRepository;
import com.example.liftlogger.domain.outbound.repository.TrainingPlanRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ExercisePlanValidator extends BaseValidator implements EntityValidator<ExercisePlan> {

    private final UserRepository userRepository;
    private final TrainingPlanRepository trainingPlanRepository;
    private final ExerciseRepository exerciseRepository;

    @Override
    public ValidationResult validate(ExercisePlan plan, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(plan.getId(), "id");
        requiredUUID(plan.getAthleteId(), "athleteId");
        requiredUUID(plan.getTrainingPlanId(), "trainingPlanId");
        requiredUUID(plan.getExerciseId(), "exerciseId");

        // Ownership validation
        if (plan.getAthleteId() != null && context.currentUserId() != null
            && !plan.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create exercise plans for yourself"));
        }

        // Cross-entity validation
        if (plan.getAthleteId() != null && !userRepository.existsById(plan.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        if (plan.getTrainingPlanId() != null && !trainingPlanRepository.existsById(plan.getTrainingPlanId())) {
            errors.add(ValidationError.notFound("trainingPlanId", "TrainingPlan"));
        }

        if (plan.getExerciseId() != null && !exerciseRepository.existsById(plan.getExerciseId())) {
            errors.add(ValidationError.notFound("exerciseId", "Exercise"));
        }

        return buildResult();
    }
}
