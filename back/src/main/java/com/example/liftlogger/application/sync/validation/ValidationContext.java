package com.example.liftlogger.application.sync.validation;

import java.util.UUID;

/**
 * Context passed to validators containing user information
 */
public record ValidationContext(
    UUID currentUserId,
    String currentUserRole  // ATHLETE, COACH, ADMIN
) {
    public boolean isCoach() {
        return "COACH".equals(currentUserRole);
    }

    public boolean isAthlete() {
        return "ATHLETE".equals(currentUserRole);
    }

    public boolean isAdmin() {
        return "ADMIN".equals(currentUserRole);
    }
}
