package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.Variant;
import com.example.liftlogger.domain.outbound.repository.VariantRepository;
import com.example.liftlogger.infrastructure.db.entity.VariantJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.VariantMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class VariantJpaAdapter extends GenericJpaSyncAdapter<Variant, VariantJpaEntity>
    implements VariantRepository {

    private final VariantMapper mapper;

    @Override
    protected Class<VariantJpaEntity> getJpaEntityClass() {
        return VariantJpaEntity.class;
    }

    @Override
    public Class<Variant> getDomainEntityClass() {
        return Variant.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "coachId";
    }

    @Override
    protected Variant toDomain(VariantJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected VariantJpaEntity toJpa(Variant domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<Variant> toDomainList(List<VariantJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
