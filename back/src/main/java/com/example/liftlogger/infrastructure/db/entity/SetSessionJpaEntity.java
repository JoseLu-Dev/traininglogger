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

    @Column(name = "athlete_id", nullable = false)
    private UUID athleteId;

    @Column(name = "exercise_session_id", nullable = false)
    private UUID exerciseSessionId;

    @Column(name = "set_plan_id")
    private UUID setPlanId;

    @Column(name = "set_number")
    private Integer setNumber;

    @Column(name = "actual_reps")
    private Integer actualReps;

    @Column(name = "actual_weight")
    private Double actualWeight;

    @Column(name = "actual_rpe")
    private Double actualRpe;

    @Column(columnDefinition = "TEXT")
    private String notes;
}
