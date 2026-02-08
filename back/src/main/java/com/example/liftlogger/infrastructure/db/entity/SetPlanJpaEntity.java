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
@Table(name = "set_plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SetPlanJpaEntity extends BaseJpaEntity {

    @Column(name = "athlete_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID athleteId;

    @Column(name = "exercise_plan_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID exercisePlanId;

    @Column
    private Integer reps;

    @Column
    private Double weight;

    @Column(name = "order_index")
    private Integer orderIndex;
}
