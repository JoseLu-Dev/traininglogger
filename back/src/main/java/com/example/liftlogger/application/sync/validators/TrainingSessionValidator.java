package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.TrainingSession;
import com.example.liftlogger.domain.outbound.repository.TrainingPlanRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class TrainingSessionValidator extends BaseValidator implements EntityValidator<TrainingSession> {

    private final UserRepository userRepository;
    private final TrainingPlanRepository trainingPlanRepository;

    @Override
    public ValidationResult validate(TrainingSession session, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(session.getId(), "id");
        requiredUUID(session.getAthleteId(), "athleteId");
        required(session.getSessionDate(), "sessionDate");

        // Ownership validation
        if (session.getAthleteId() != null && context.currentUserId() != null
            && !session.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create training sessions for yourself"));
        }

        // Cross-entity validation
        if (session.getAthleteId() != null && !userRepository.existsById(session.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        if (session.getTrainingPlanId() != null
            && !trainingPlanRepository.existsById(session.getTrainingPlanId())) {
            errors.add(ValidationError.notFound("trainingPlanId", "TrainingPlan"));
        }

        return buildResult();
    }
}
