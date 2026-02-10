package com.example.liftlogger.domain.exception;

import java.util.UUID;

public class CoachNotFoundException extends RuntimeException {
    public CoachNotFoundException(UUID coachId) {
        super("Coach not found with id: " + coachId);
    }
}
