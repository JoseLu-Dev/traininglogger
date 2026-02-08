package com.example.liftlogger.infrastructure.db.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "set_sessions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SetSessionJpaEntity extends BaseJpaEntity {

    @Column(name = "athlete_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID athleteId;

    @Column(name = "exercise_session_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID exerciseSessionId;

    @Column(name = "exercise_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID exerciseId;

    @Column
    private Integer reps;

    @Column
    private Double weight;

    @Column
    private String notes;

    @Column(name = "session_date")
    private LocalDateTime sessionDate;
}
