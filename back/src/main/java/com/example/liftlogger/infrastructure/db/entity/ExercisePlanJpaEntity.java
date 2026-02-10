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
@Table(name = "exercise_plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExercisePlanJpaEntity extends BaseJpaEntity {

    @Column(name = "athlete_id", nullable = false)
    private UUID athleteId;

    @Column(name = "training_plan_id", nullable = false)
    private UUID trainingPlanId;

    @Column(name = "exercise_id", nullable = false)
    private UUID exerciseId;

    @Column(name = "variant_id")
    private UUID variantId;

    @Column(name = "order_index")
    private Integer orderIndex;
}
