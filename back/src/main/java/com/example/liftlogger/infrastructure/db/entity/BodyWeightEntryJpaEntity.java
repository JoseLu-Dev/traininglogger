package com.example.liftlogger.infrastructure.db.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "body_weight_entries")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BodyWeightEntryJpaEntity extends BaseJpaEntity {

    @Column(name = "athlete_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID athleteId;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private Double weight;

    @Column
    private String notes;
}
