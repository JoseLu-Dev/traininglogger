package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.infrastructure.rest.dto.AuthResponse;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface AuthResponseMapper {
    AuthResponse toResponse(User user);
}
