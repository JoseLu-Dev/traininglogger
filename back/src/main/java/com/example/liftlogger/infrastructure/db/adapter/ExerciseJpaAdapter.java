package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.Exercise;
import com.example.liftlogger.domain.outbound.repository.ExerciseRepository;
import com.example.liftlogger.infrastructure.db.entity.ExerciseJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.ExerciseMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ExerciseJpaAdapter extends GenericJpaSyncAdapter<Exercise, ExerciseJpaEntity>
    implements ExerciseRepository {

    private final ExerciseMapper mapper;

    @Override
    protected Class<ExerciseJpaEntity> getJpaEntityClass() {
        return ExerciseJpaEntity.class;
    }

    @Override
    public Class<Exercise> getDomainEntityClass() {
        return Exercise.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "coachId";
    }

    @Override
    protected Exercise toDomain(ExerciseJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected ExerciseJpaEntity toJpa(Exercise domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<Exercise> toDomainList(List<ExerciseJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
