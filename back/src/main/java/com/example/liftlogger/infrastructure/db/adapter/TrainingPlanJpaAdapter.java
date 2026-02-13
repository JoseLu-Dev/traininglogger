package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.domain.outbound.repository.TrainingPlanRepository;
import com.example.liftlogger.infrastructure.db.entity.TrainingPlanJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.TrainingPlanMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class TrainingPlanJpaAdapter extends GenericJpaSyncAdapter<TrainingPlan, TrainingPlanJpaEntity>
    implements TrainingPlanRepository {

    private final TrainingPlanMapper mapper;

    @Override
    protected Class<TrainingPlanJpaEntity> getJpaEntityClass() {
        return TrainingPlanJpaEntity.class;
    }

    @Override
    public Class<TrainingPlan> getDomainEntityClass() {
        return TrainingPlan.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected TrainingPlan toDomain(TrainingPlanJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected TrainingPlanJpaEntity toJpa(TrainingPlan domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<TrainingPlan> toDomainList(List<TrainingPlanJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
