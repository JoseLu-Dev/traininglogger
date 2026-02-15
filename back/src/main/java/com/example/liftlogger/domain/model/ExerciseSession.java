package com.example.liftlogger.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExerciseSession {
    private UUID id;
    private UUID athleteId;
    private UUID trainingSessionId;
    private UUID exercisePlanId;
    private UUID exerciseId;
    private Integer orderIndex;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private UUID createdBy;
    private UUID updatedBy;
    private LocalDateTime deletedAt;
}
