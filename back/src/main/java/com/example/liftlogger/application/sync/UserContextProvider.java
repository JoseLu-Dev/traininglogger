package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.validation.ValidationContext;

import java.util.UUID;

/**
 * Provider interface for getting user context.
 * Implementation will be in infrastructure layer (e.g., from Spring Security).
 */
public interface UserContextProvider {

    /**
     * Get validation context for user
     *
     * @param userId The user ID
     * @return Validation context with user role
     */
    ValidationContext getValidationContext(UUID userId);
}
