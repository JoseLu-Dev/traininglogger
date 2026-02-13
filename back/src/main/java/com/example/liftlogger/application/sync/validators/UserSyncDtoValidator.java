package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.dto.UserSyncDto;
import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import org.springframework.stereotype.Component;

/**
 * Validator for UserSyncDto during pull sync.
 * Since UserSyncDto is read-only (pull sync only), validation is minimal.
 * Full validation happens on User entity during push sync.
 */
@Component
public class UserSyncDtoValidator extends BaseValidator implements EntityValidator<UserSyncDto> {

    @Override
    public ValidationResult validate(UserSyncDto entity, ValidationContext context) {
        clearErrors();

        // UserSyncDto is read-only for pull sync
        // Validation happens on User entity during push sync operations
        // No validation needed here

        return buildResult();
    }
}
