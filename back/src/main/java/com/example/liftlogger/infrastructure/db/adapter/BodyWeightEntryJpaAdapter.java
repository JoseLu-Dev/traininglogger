package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.BodyWeightEntry;
import com.example.liftlogger.domain.outbound.repository.BodyWeightEntryRepository;
import com.example.liftlogger.infrastructure.db.entity.BodyWeightEntryJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.BodyWeightEntryMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class BodyWeightEntryJpaAdapter extends GenericJpaSyncAdapter<BodyWeightEntry, BodyWeightEntryJpaEntity>
    implements BodyWeightEntryRepository {

    private final BodyWeightEntryMapper mapper;

    @Override
    protected Class<BodyWeightEntryJpaEntity> getJpaEntityClass() {
        return BodyWeightEntryJpaEntity.class;
    }

    @Override
    public Class<BodyWeightEntry> getDomainEntityClass() {
        return BodyWeightEntry.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected BodyWeightEntry toDomain(BodyWeightEntryJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected BodyWeightEntryJpaEntity toJpa(BodyWeightEntry domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<BodyWeightEntry> toDomainList(List<BodyWeightEntryJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
