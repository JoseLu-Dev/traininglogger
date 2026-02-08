package com.example.liftlogger.infrastructure.db.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "exercises")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExerciseJpaEntity extends BaseJpaEntity {

    @Column(name = "coach_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID coachId;

    @Column(nullable = false)
    private String name;

    @Column
    private String description;
}
