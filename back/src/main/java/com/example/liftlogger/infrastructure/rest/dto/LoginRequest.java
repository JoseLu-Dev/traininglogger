package com.example.liftlogger.infrastructure.rest.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

public record LoginRequest(

        @Schema(description = "Account email", example = "coach@example.com")
        @NotBlank
        String email,

        @Schema(description = "Account password", example = "password123")
        @NotBlank
        String password
) {
}
