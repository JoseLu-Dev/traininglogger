package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.SetPlan;
import com.example.liftlogger.domain.outbound.repository.SetPlanRepository;
import com.example.liftlogger.infrastructure.db.entity.SetPlanJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.SetPlanMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class SetPlanJpaAdapter extends GenericJpaSyncAdapter<SetPlan, SetPlanJpaEntity>
    implements SetPlanRepository {

    private final SetPlanMapper mapper;

    @Override
    protected Class<SetPlanJpaEntity> getJpaEntityClass() {
        return SetPlanJpaEntity.class;
    }

    @Override
    public Class<SetPlan> getDomainEntityClass() {
        return SetPlan.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected SetPlan toDomain(SetPlanJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected SetPlanJpaEntity toJpa(SetPlan domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<SetPlan> toDomainList(List<SetPlanJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
