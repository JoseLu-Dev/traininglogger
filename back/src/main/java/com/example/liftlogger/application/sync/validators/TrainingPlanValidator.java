package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.domain.outbound.repository.TrainingPlanRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class TrainingPlanValidator extends BaseValidator implements EntityValidator<TrainingPlan> {

    private final TrainingPlanRepository repository;
    private final UserRepository userRepository;

    @Override
    public ValidationResult validate(TrainingPlan plan, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(plan.getId(), "id");
        requiredUUID(plan.getAthleteId(), "athleteId");
        requiredString(plan.getName(), "name");
        minLength(plan.getName(), 3, "name");
        maxLength(plan.getName(), 100, "name");
        required(plan.getStartDate(), "startDate");
        required(plan.getEndDate(), "endDate");
        dateRange(plan.getStartDate(), plan.getEndDate(), "dateRange");

        // Status validation
        if (plan.getStatus() != null &&
            !List.of("DRAFT", "ACTIVE", "COMPLETED", "ARCHIVED").contains(plan.getStatus())) {
            errors.add(ValidationError.invalid("status",
                "Status must be one of: DRAFT, ACTIVE, COMPLETED, ARCHIVED"));
        }

        // Ownership validation
        if (plan.getAthleteId() != null && context.currentUserId() != null
            && !plan.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create training plans for yourself"));
        }

        // Cross-entity validation
        if (plan.getAthleteId() != null && !userRepository.existsById(plan.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        // Business rule: No overlapping plans
        if (plan.getStartDate() != null && plan.getEndDate() != null) {
            boolean hasOverlap = repository.existsOverlappingPlan(
                plan.getAthleteId(),
                plan.getStartDate(),
                plan.getEndDate(),
                plan.getId()
            );
            if (hasOverlap) {
                errors.add(ValidationError.conflict("dateRange",
                    "Another training plan exists in this date range"));
            }
        }

        return buildResult();
    }
}
