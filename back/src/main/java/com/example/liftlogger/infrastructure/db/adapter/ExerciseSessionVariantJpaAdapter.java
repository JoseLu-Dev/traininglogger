package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.ExerciseSessionVariant;
import com.example.liftlogger.domain.outbound.repository.ExerciseSessionVariantRepository;
import com.example.liftlogger.infrastructure.db.entity.ExerciseSessionVariantJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.ExerciseSessionVariantJpaMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ExerciseSessionVariantJpaAdapter extends GenericJpaSyncAdapter<ExerciseSessionVariant, ExerciseSessionVariantJpaEntity>
    implements ExerciseSessionVariantRepository {

    private final ExerciseSessionVariantJpaMapper mapper;

    @Override
    protected Class<ExerciseSessionVariantJpaEntity> getJpaEntityClass() {
        return ExerciseSessionVariantJpaEntity.class;
    }

    @Override
    public Class<ExerciseSessionVariant> getDomainEntityClass() {
        return ExerciseSessionVariant.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected ExerciseSessionVariant toDomain(ExerciseSessionVariantJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected ExerciseSessionVariantJpaEntity toJpa(ExerciseSessionVariant domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<ExerciseSessionVariant> toDomainList(List<ExerciseSessionVariantJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
