package com.example.liftlogger.infrastructure.rest.dto.sync;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;

import java.time.LocalDateTime;
import java.util.List;

public record PullSyncRequestDto(

        @Schema(description = "List of entity types to pull during synchronization", example = "[\"Exercise\", \"BodyWeightEntry\", \"TrainingPlan\"]")
        @NotEmpty(message = "Entity types list cannot be empty")
        List<@NotBlank(message = "Entity type cannot be blank") String> entityTypes,

        @Schema(description = "Timestamp of the last synchronization", example = "2023-02-12T12:03:35", format = "date-time")
        @NotNull(message = "Last synchronization time cannot be null")
        @Past(message = "Time must be past")
        LocalDateTime lastSyncTime
) {
}
