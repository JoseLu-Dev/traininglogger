package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.infrastructure.db.entity.TrainingPlanJpaEntity;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.junit.jupiter.SpringJUnitConfig;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringJUnitConfig(classes = {TrainingPlanMapperImpl.class})
class TrainingPlanMapperTest {

    @Autowired
    private TrainingPlanMapper mapper;

    @Test
    void toDomain_mapsAllFields() {
        UUID id = UUID.randomUUID();
        UUID athleteId = UUID.randomUUID();
        UUID createdBy = UUID.randomUUID();
        UUID updatedBy = UUID.randomUUID();
        LocalDateTime now = LocalDateTime.now();

        TrainingPlanJpaEntity jpaEntity = new TrainingPlanJpaEntity();
        jpaEntity.setId(id);
        jpaEntity.setAthleteId(athleteId);
        jpaEntity.setName("Test Plan");
        jpaEntity.setDescription("Description");
        jpaEntity.setStartDate(LocalDate.of(2024, 1, 1));
        jpaEntity.setEndDate(LocalDate.of(2024, 1, 31));
        jpaEntity.setStatus("ACTIVE");
        jpaEntity.setCreatedAt(now);
        jpaEntity.setUpdatedAt(now);
        jpaEntity.setCreatedBy(createdBy);
        jpaEntity.setUpdatedBy(updatedBy);

        TrainingPlan domain = mapper.toDomain(jpaEntity);

        assertThat(domain.getId()).isEqualTo(id);
        assertThat(domain.getAthleteId()).isEqualTo(athleteId);
        assertThat(domain.getName()).isEqualTo("Test Plan");
        assertThat(domain.getDescription()).isEqualTo("Description");
        assertThat(domain.getStartDate()).isEqualTo(LocalDate.of(2024, 1, 1));
        assertThat(domain.getEndDate()).isEqualTo(LocalDate.of(2024, 1, 31));
        assertThat(domain.getStatus()).isEqualTo("ACTIVE");
        assertThat(domain.getCreatedAt()).isEqualTo(now);
        assertThat(domain.getUpdatedAt()).isEqualTo(now);
        assertThat(domain.getCreatedBy()).isEqualTo(createdBy);
        assertThat(domain.getUpdatedBy()).isEqualTo(updatedBy);
    }

    @Test
    void toJpa_mapsAllFields() {
        UUID id = UUID.randomUUID();
        UUID athleteId = UUID.randomUUID();
        LocalDateTime now = LocalDateTime.now();

        TrainingPlan domain = TrainingPlan.builder()
            .id(id)
            .athleteId(athleteId)
            .name("Test Plan")
            .description("Description")
            .startDate(LocalDate.of(2024, 1, 1))
            .endDate(LocalDate.of(2024, 1, 31))
            .status("ACTIVE")
            .createdAt(now)
            .updatedAt(now)
            .build();

        TrainingPlanJpaEntity jpaEntity = mapper.toJpa(domain);

        assertThat(jpaEntity.getId()).isEqualTo(id);
        assertThat(jpaEntity.getAthleteId()).isEqualTo(athleteId);
        assertThat(jpaEntity.getName()).isEqualTo("Test Plan");
        assertThat(jpaEntity.getStartDate()).isEqualTo(LocalDate.of(2024, 1, 1));
        assertThat(jpaEntity.getEndDate()).isEqualTo(LocalDate.of(2024, 1, 31));
        assertThat(jpaEntity.getStatus()).isEqualTo("ACTIVE");
    }

    @Test
    void roundTrip_preservesData() {
        UUID id = UUID.randomUUID();
        UUID athleteId = UUID.randomUUID();
        UUID createdBy = UUID.randomUUID();
        UUID updatedBy = UUID.randomUUID();
        LocalDateTime now = LocalDateTime.now();

        TrainingPlan original = TrainingPlan.builder()
            .id(id)
            .athleteId(athleteId)
            .name("Test Plan")
            .description("Round Trip Test")
            .startDate(LocalDate.of(2024, 1, 1))
            .endDate(LocalDate.of(2024, 1, 31))
            .status("ACTIVE")
            .createdAt(now)
            .updatedAt(now)
            .createdBy(createdBy)
            .updatedBy(updatedBy)
            .build();

        TrainingPlanJpaEntity jpaEntity = mapper.toJpa(original);
        TrainingPlan roundTrip = mapper.toDomain(jpaEntity);

        assertThat(roundTrip).usingRecursiveComparison().isEqualTo(original);
    }
}
