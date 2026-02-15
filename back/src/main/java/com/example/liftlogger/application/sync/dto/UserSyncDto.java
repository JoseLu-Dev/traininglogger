package com.example.liftlogger.application.sync.dto;

import com.example.liftlogger.domain.model.UserRole;

import java.time.Instant;
import java.util.UUID;

/**
 * Sync-safe representation of User entity.
 * Excludes sensitive fields (passwordHash, version, deletedAt) that should never be synchronized.
 * Includes email for coach-athlete communication purposes.
 */
public record UserSyncDto(
    UUID id,
    String email,
    String name,
    UserRole role,
    UUID coachId,
    Instant createdAt,
    Instant updatedAt,
    Instant deletedAt
) {}
