package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.application.sync.dto.UserSyncDto;
import com.example.liftlogger.application.sync.mapper.UserSyncMapper;
import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.domain.outbound.repository.GenericSyncRepository;
import com.example.liftlogger.infrastructure.db.entity.UserJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.UserJpaMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Sync-specific adapter for User entities.
 * Returns UserSyncDto instead of User domain entities to exclude sensitive fields.
 *
 * Note: UserJpaAdapter handles regular CRUD operations, while this adapter
 * handles sync-specific queries that return safe DTOs.
 */
@Repository
@RequiredArgsConstructor
public class UserSyncAdapter extends GenericJpaSyncAdapter<UserSyncDto, UserJpaEntity>
    implements GenericSyncRepository<UserSyncDto> {

    private final UserJpaMapper userJpaMapper;
    private final UserSyncMapper userSyncMapper;

    @Override
    protected Class<UserJpaEntity> getJpaEntityClass() {
        return UserJpaEntity.class;
    }

    @Override
    public Class<UserSyncDto> getDomainEntityClass() {
        return UserSyncDto.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "id";  // Users query by their own ID
    }

    @Override
    protected UserSyncDto toDomain(UserJpaEntity jpaEntity) {
        // Convert JPA -> User -> UserSyncDto (excludes password)
        User user = userJpaMapper.toDomain(jpaEntity);
        return userSyncMapper.toSyncDto(user);
    }

    @Override
    protected UserJpaEntity toJpa(UserSyncDto domainEntity) {
        // Note: Push sync should use UserJpaAdapter, not this sync adapter
        throw new UnsupportedOperationException(
            "UserSyncAdapter is read-only. Use UserJpaAdapter for write operations."
        );
    }

    @Override
    protected List<UserSyncDto> toDomainList(List<UserJpaEntity> jpaEntities) {
        return jpaEntities.stream()
            .map(userJpaMapper::toDomain)
            .map(userSyncMapper::toSyncDto)
            .toList();
    }
}
