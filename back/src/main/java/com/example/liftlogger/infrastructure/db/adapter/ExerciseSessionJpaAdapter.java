package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.ExerciseSession;
import com.example.liftlogger.domain.outbound.repository.ExerciseSessionRepository;
import com.example.liftlogger.infrastructure.db.entity.ExerciseSessionJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.ExerciseSessionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ExerciseSessionJpaAdapter extends GenericJpaSyncAdapter<ExerciseSession, ExerciseSessionJpaEntity>
    implements ExerciseSessionRepository {

    private final ExerciseSessionMapper mapper;

    @Override
    protected Class<ExerciseSessionJpaEntity> getJpaEntityClass() {
        return ExerciseSessionJpaEntity.class;
    }

    @Override
    public Class<ExerciseSession> getDomainEntityClass() {
        return ExerciseSession.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected ExerciseSession toDomain(ExerciseSessionJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected ExerciseSessionJpaEntity toJpa(ExerciseSession domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<ExerciseSession> toDomainList(List<ExerciseSessionJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
