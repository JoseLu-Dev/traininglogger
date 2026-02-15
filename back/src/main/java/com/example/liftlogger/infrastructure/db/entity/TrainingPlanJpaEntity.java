package com.example.liftlogger.infrastructure.db.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "training_plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrainingPlanJpaEntity extends BaseJpaEntity {

    @Column(name = "athlete_id", nullable = false)
    private UUID athleteId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private Instant date;

    @Column(name = "is_locked", nullable = false)
    private Boolean isLocked;
}
