package com.example.liftlogger.infrastructure.rest.dto.sync;

import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.Map;

public record PushSyncRequestDto(
    @NotNull(message = "Entities map cannot be null")
    Map<String, List<Object>> entities
) {}
