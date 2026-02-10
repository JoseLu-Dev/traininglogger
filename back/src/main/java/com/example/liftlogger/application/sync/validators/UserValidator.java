package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.BaseValidator;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class UserValidator extends BaseValidator implements EntityValidator<User> {

    @Override
    public ValidationResult validate(User user, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(user.getId(), "id");
        requiredString(user.getEmail(), "email");
        requiredString(user.getPasswordHash(), "passwordHash");
        required(user.getRole(), "role");

        return buildResult();
    }
}
