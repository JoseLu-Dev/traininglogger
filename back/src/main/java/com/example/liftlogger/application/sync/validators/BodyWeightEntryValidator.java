package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.BodyWeightEntry;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class BodyWeightEntryValidator extends BaseValidator implements EntityValidator<BodyWeightEntry> {

    private final UserRepository userRepository;

    @Override
    public ValidationResult validate(BodyWeightEntry entry, ValidationContext context) {
        clearErrors();

        requiredUUID(entry.getId(), "id");
        requiredUUID(entry.getAthleteId(), "athleteId");
        required(entry.getMeasurementDate(), "measurementDate");

        // Weight validation
        if (entry.getWeight() != null) {
            min(entry.getWeight(), 20.0, "weight");
            max(entry.getWeight(), 500.0, "weight");
        }

        // Ownership validation
        if (entry.getAthleteId() != null && context.currentUserId() != null
            && !entry.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create body weight entries for yourself"));
        }

        // Cross-entity validation
        if (entry.getAthleteId() != null && !userRepository.existsById(entry.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        return buildResult();
    }
}
