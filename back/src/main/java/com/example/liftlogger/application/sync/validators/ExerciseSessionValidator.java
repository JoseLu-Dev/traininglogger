package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.ExerciseSession;
import com.example.liftlogger.domain.outbound.repository.ExerciseRepository;
import com.example.liftlogger.domain.outbound.repository.TrainingSessionRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ExerciseSessionValidator extends BaseValidator implements EntityValidator<ExerciseSession> {

    private final UserRepository userRepository;
    private final TrainingSessionRepository trainingSessionRepository;
    private final ExerciseRepository exerciseRepository;

    @Override
    public ValidationResult validate(ExerciseSession session, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(session.getId(), "id");
        requiredUUID(session.getAthleteId(), "athleteId");
        requiredUUID(session.getTrainingSessionId(), "trainingSessionId");
        requiredUUID(session.getExerciseId(), "exerciseId");

        // Ownership validation
        if (session.getAthleteId() != null && context.currentUserId() != null
            && !session.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create exercise sessions for yourself"));
        }

        // Cross-entity validation
        if (session.getAthleteId() != null && !userRepository.existsById(session.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        if (session.getTrainingSessionId() != null
            && !trainingSessionRepository.existsById(session.getTrainingSessionId())) {
            errors.add(ValidationError.notFound("trainingSessionId", "TrainingSession"));
        }

        if (session.getExerciseId() != null && !exerciseRepository.existsById(session.getExerciseId())) {
            errors.add(ValidationError.notFound("exerciseId", "Exercise"));
        }

        return buildResult();
    }
}
