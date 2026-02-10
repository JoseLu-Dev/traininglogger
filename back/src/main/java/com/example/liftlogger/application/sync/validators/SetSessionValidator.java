package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.SetSession;
import com.example.liftlogger.domain.outbound.repository.ExerciseRepository;
import com.example.liftlogger.domain.outbound.repository.ExerciseSessionRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SetSessionValidator extends BaseValidator implements EntityValidator<SetSession> {

    private final UserRepository userRepository;
    private final ExerciseRepository exerciseRepository;
    private final ExerciseSessionRepository exerciseSessionRepository;

    @Override
    public ValidationResult validate(SetSession session, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(session.getId(), "id");
        requiredUUID(session.getAthleteId(), "athleteId");
        requiredUUID(session.getExerciseId(), "exerciseId");
        required(session.getSessionDate(), "sessionDate");

        // Reps validation
        if (session.getReps() != null) {
            min(session.getReps(), 0, "reps");
            max(session.getReps(), 1000, "reps");
        }

        // Weight validation
        if (session.getWeight() != null) {
            min(session.getWeight(), 0.0, "weight");
            max(session.getWeight(), 1000.0, "weight");
        }

        // Notes length
        maxLength(session.getNotes(), 1000, "notes");

        // Ownership validation
        if (session.getAthleteId() != null && context.currentUserId() != null
            && !session.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create set sessions for yourself"));
        }

        // Cross-entity validation
        if (session.getAthleteId() != null && !userRepository.existsById(session.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        if (session.getExerciseId() != null && !exerciseRepository.existsById(session.getExerciseId())) {
            errors.add(ValidationError.notFound("exerciseId", "Exercise"));
        }

        if (session.getExerciseSessionId() != null
            && !exerciseSessionRepository.existsById(session.getExerciseSessionId())) {
            errors.add(ValidationError.notFound("exerciseSessionId", "ExerciseSession"));
        }

        return buildResult();
    }
}
