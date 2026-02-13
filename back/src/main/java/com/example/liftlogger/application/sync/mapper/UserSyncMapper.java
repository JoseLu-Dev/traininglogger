package com.example.liftlogger.application.sync.mapper;

import com.example.liftlogger.application.sync.dto.UserSyncDto;
import com.example.liftlogger.domain.model.User;
import org.mapstruct.Mapper;

import java.util.List;

/**
 * Mapper for converting User domain entities to sync-safe DTOs.
 * Automatically excludes password field by not mapping it.
 */
@Mapper(componentModel = "spring")
public interface UserSyncMapper {

    /**
     * Convert User to UserSyncDto (excludes password)
     */
    UserSyncDto toSyncDto(User user);

    /**
     * Convert list of Users to UserSyncDtos
     */
    List<UserSyncDto> toSyncDtos(List<User> users);
}
