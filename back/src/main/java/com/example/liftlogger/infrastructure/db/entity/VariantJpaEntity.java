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
@Table(name = "variants")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VariantJpaEntity extends BaseJpaEntity {

    @Column(name = "coach_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID coachId;

    @Column(name = "exercise_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID exerciseId;

    @Column(nullable = false)
    private String name;

    @Column
    private String description;
}
