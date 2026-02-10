package com.example.liftlogger.infrastructure.rest.dto;

import com.example.liftlogger.domain.model.UserRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record RegisterRequest(
        @NotBlank String email,
        @NotBlank String password,
        @NotNull UserRole role,
        UUID coachId
) {}
