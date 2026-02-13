package com.example.liftlogger.application.sync.dto;

import com.example.liftlogger.domain.model.UserRole;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Sync-safe representation of User entity.
 * Excludes sensitive fields (passwordHash, version, deletedAt) that should never be synchronized.
 * Includes email for coach-athlete communication purposes.
 */
public record UserSyncDto(
    UUID id,
    String email,
    UserRole role,
    UUID coachId,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime createdAt,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime updatedAt
) {}
