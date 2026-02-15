package com.example.liftlogger.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private UUID id;
    private String email;
    private String name;
    private String passwordHash;
    private UserRole role;
    private UUID coachId;
    private Instant createdAt;
    private Instant updatedAt;
    private Integer version;
    private Instant deletedAt;
}
