package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.ExercisePlan;
import com.example.liftlogger.domain.outbound.repository.ExercisePlanRepository;
import com.example.liftlogger.infrastructure.db.entity.ExercisePlanJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.ExercisePlanMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ExercisePlanJpaAdapter extends GenericJpaSyncAdapter<ExercisePlan, ExercisePlanJpaEntity>
    implements ExercisePlanRepository {

    private final ExercisePlanMapper mapper;

    @Override
    protected Class<ExercisePlanJpaEntity> getJpaEntityClass() {
        return ExercisePlanJpaEntity.class;
    }

    @Override
    public Class<ExercisePlan> getDomainEntityClass() {
        return ExercisePlan.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected ExercisePlan toDomain(ExercisePlanJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected ExercisePlanJpaEntity toJpa(ExercisePlan domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<ExercisePlan> toDomainList(List<ExercisePlanJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
