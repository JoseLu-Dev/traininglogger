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
@Table(name = "training_sessions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrainingSessionJpaEntity extends BaseJpaEntity {

    @Column(name = "athlete_id", nullable = false)
    private UUID athleteId;

    @Column(name = "training_plan_id")
    private UUID trainingPlanId;

    @Column(name = "session_date")
    private LocalDateTime sessionDate;

    @Column
    private String notes;
}
