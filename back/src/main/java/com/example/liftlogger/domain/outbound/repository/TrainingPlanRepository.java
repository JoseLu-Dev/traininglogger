package com.example.liftlogger.domain.outbound.repository;

import com.example.liftlogger.domain.model.TrainingPlan;

import java.time.LocalDate;
import java.util.UUID;

public interface TrainingPlanRepository extends GenericSyncRepository<TrainingPlan> {

    /**
     * Check if there's an overlapping training plan for the athlete
     */
    boolean existsOverlappingPlan(UUID athleteId, LocalDate startDate, LocalDate endDate, UUID excludePlanId);
}
