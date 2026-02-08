package com.example.liftlogger.infrastructure.db.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "exercise_sessions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExerciseSessionJpaEntity extends BaseJpaEntity {

    @Column(name = "athlete_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID athleteId;

    @Column(name = "training_session_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID trainingSessionId;

    @Column(name = "exercise_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID exerciseId;

    @Column(name = "variant_id", columnDefinition = "BINARY(16)")
    private UUID variantId;

    @Column(name = "order_index")
    private Integer orderIndex;
}
