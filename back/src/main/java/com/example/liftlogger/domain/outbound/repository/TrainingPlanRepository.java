package com.example.liftlogger.domain.outbound.repository;

import com.example.liftlogger.domain.model.TrainingPlan;

public interface TrainingPlanRepository extends GenericSyncRepository<TrainingPlan> {
    // No additional methods needed - date overlap check removed since TrainingPlan now has single date field
}
