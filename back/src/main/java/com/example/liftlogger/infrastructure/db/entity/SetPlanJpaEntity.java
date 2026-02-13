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

    @Column(name = "athlete_id", nullable = false)
    private UUID athleteId;

    @Column(name = "exercise_plan_id", nullable = false)
    private UUID exercisePlanId;

    @Column(name = "set_number")
    private Integer setNumber;

    @Column(name = "target_reps")
    private Integer targetReps;

    @Column(name = "target_weight")
    private Double targetWeight;

    @Column(name = "target_rpe")
    private Double targetRpe;

    @Column(columnDefinition = "TEXT")
    private String notes;
}
