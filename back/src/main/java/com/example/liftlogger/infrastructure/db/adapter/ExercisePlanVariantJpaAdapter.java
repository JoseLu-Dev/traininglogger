package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.ExercisePlanVariant;
import com.example.liftlogger.domain.outbound.repository.ExercisePlanVariantRepository;
import com.example.liftlogger.infrastructure.db.entity.ExercisePlanVariantJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.ExercisePlanVariantJpaMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ExercisePlanVariantJpaAdapter extends GenericJpaSyncAdapter<ExercisePlanVariant, ExercisePlanVariantJpaEntity>
    implements ExercisePlanVariantRepository {

    private final ExercisePlanVariantJpaMapper mapper;

    @Override
    protected Class<ExercisePlanVariantJpaEntity> getJpaEntityClass() {
        return ExercisePlanVariantJpaEntity.class;
    }

    @Override
    public Class<ExercisePlanVariant> getDomainEntityClass() {
        return ExercisePlanVariant.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected ExercisePlanVariant toDomain(ExercisePlanVariantJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected ExercisePlanVariantJpaEntity toJpa(ExercisePlanVariant domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<ExercisePlanVariant> toDomainList(List<ExercisePlanVariantJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
