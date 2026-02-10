package com.example.liftlogger.infrastructure.rest.dto;

import com.example.liftlogger.domain.model.UserRole;

import java.util.UUID;

public record AuthResponse(
        UUID id,
        String email,
        UserRole role,
        UUID coachId
) {}
