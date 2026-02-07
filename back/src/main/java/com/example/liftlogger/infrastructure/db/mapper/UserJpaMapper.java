package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.infrastructure.db.entity.UserJpaEntity;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserJpaMapper {
    User toDomain(UserJpaEntity entity);
    UserJpaEntity toEntity(User domain);
}
