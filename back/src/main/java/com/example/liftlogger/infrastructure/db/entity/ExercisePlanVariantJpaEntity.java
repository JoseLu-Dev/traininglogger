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
@Table(name = "exercise_plan_variants")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExercisePlanVariantJpaEntity extends BaseJpaEntity {

    @Column(name = "athlete_id", nullable = false)
    private UUID athleteId;

    @Column(name = "exercise_plan_id", nullable = false)
    private UUID exercisePlanId;

    @Column(name = "variant_id", nullable = false)
    private UUID variantId;
}
