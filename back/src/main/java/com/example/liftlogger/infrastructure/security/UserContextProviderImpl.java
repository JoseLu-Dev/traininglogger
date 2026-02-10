package com.example.liftlogger.infrastructure.security;

import com.example.liftlogger.application.sync.UserContextProvider;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.domain.exception.EntityNotFoundException;
import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Spring Security-based implementation of UserContextProvider.
 * Looks up the user from the repository to provide role information
 * for validation context.
 */
@Component
@RequiredArgsConstructor
public class UserContextProviderImpl implements UserContextProvider {

    private final UserRepository userRepository;

    @Override
    public ValidationContext getValidationContext(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User", userId));

        String role = user.getRole().name();
        return new ValidationContext(userId, role);
    }
}
