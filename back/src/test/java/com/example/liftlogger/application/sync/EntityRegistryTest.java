package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.validation.NoOpValidator;
import com.example.liftlogger.domain.model.SetSession;
import com.example.liftlogger.domain.model.TrainingPlan;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SuppressWarnings({"rawtypes", "unchecked"})
class EntityRegistryTest {

    private EntityRegistry registry;
    private NoOpValidator validator;

    @BeforeEach
    void setUp() {
        registry = new EntityRegistry();
        validator = new NoOpValidator();
    }

    @Test
    void register_storesMetadata() {
        registry.register(TrainingPlan.class, "athleteId", validator);

        assertThat(registry.getEntityCount()).isEqualTo(1);
        assertThat(registry.isRegistered("TrainingPlan")).isTrue();
    }

    @Test
    void getByName_returnsMetadata() {
        registry.register(TrainingPlan.class, "athleteId", validator);

        EntityMetadata<?> metadata = registry.getByName("TrainingPlan");

        assertThat(metadata.entityClass()).isEqualTo(TrainingPlan.class);
        assertThat(metadata.entityName()).isEqualTo("TrainingPlan");
        assertThat(metadata.ownerField()).isEqualTo("athleteId");
        assertThat(metadata.validator()).isEqualTo(validator);
    }

    @Test
    void getByClass_returnsMetadata() {
        registry.register(TrainingPlan.class, "athleteId", validator);

        EntityMetadata<TrainingPlan> metadata = registry.getByClass(TrainingPlan.class);

        assertThat(metadata.entityClass()).isEqualTo(TrainingPlan.class);
        assertThat(metadata.ownerField()).isEqualTo("athleteId");
    }

    @Test
    void getByName_unknownEntity_throwsException() {
        assertThatThrownBy(() -> registry.getByName("UnknownEntity"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Unknown entity type");
    }

    @Test
    void getAllEntityNames_returnsAllNames() {
        registry.register(TrainingPlan.class, "athleteId", validator);
        registry.register(SetSession.class, "athleteId", validator);

        List<String> names = registry.getAllEntityNames();

        assertThat(names).containsExactlyInAnyOrder("TrainingPlan", "SetSession");
    }

    @Test
    void register_supportsChaining() {
        EntityRegistry result = registry
            .register(TrainingPlan.class, "athleteId", validator)
            .register(SetSession.class, "athleteId", validator);

        assertThat(result).isSameAs(registry);
        assertThat(registry.getEntityCount()).isEqualTo(2);
    }
}
