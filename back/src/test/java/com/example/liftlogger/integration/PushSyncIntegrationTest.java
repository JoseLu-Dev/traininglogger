package com.example.liftlogger.integration;

import com.example.liftlogger.infrastructure.rest.dto.sync.PushSyncRequestDto;
import com.example.liftlogger.infrastructure.security.CurrentUser;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import java.time.Instant;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.empty;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Integration tests for push sync endpoint.
 * Uses BodyWeightEntry which has minimal dependencies (only athleteId).
 */
class PushSyncIntegrationTest extends SyncIntegrationTestBase {

    @Test
    void pushSync_validEntity_savesSuccessfully() throws Exception {
        UUID userId = UUID.randomUUID();
        CurrentUser currentUser = createTestUser(userId);

        Map<String, Object> entry = buildBodyWeightEntry(UUID.randomUUID(), userId, 75.0);

        PushSyncRequestDto request = new PushSyncRequestDto(
                Map.of("BodyWeightEntry", List.of(entry))
        );

        mockMvc.perform(post("/api/v1/sync/push")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(user(currentUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.successCount", is(1)))
                .andExpect(jsonPath("$.failureCount", is(0)))
                .andExpect(jsonPath("$.failures", hasSize(0)));
    }

    @Test
    void pushSync_invalidEntity_returnsFailures() throws Exception {
        UUID userId = UUID.randomUUID();
        CurrentUser currentUser = createTestUser(userId);

        // Invalid: null date (required field)
        Map<String, Object> invalidEntry = buildBodyWeightEntryNullDate(UUID.randomUUID(), userId, 75.0);

        PushSyncRequestDto request = new PushSyncRequestDto(
                Map.of("BodyWeightEntry", List.of(invalidEntry))
        );

        mockMvc.perform(post("/api/v1/sync/push")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(user(currentUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.successCount", is(0)))
                .andExpect(jsonPath("$.failureCount", is(1)))
                .andExpect(jsonPath("$.failures[0].entityType", is("BodyWeightEntry")))
                .andExpect(jsonPath("$.failures[0].errors", not(empty())));
    }

    @Test
    void pushSync_mixedValidation_returnsPartialSuccess() throws Exception {
        UUID userId = UUID.randomUUID();
        CurrentUser currentUser = createTestUser(userId);

        Map<String, Object> validEntry = buildBodyWeightEntry(UUID.randomUUID(), userId, 80.0);
        Map<String, Object> invalidEntry = buildBodyWeightEntryNullDate(UUID.randomUUID(), userId, 80.0);

        PushSyncRequestDto request = new PushSyncRequestDto(
                Map.of("BodyWeightEntry", List.of(validEntry, invalidEntry))
        );

        mockMvc.perform(post("/api/v1/sync/push")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(user(currentUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.successCount", is(1)))
                .andExpect(jsonPath("$.failureCount", is(1)));
    }

    private Map<String, Object> buildBodyWeightEntry(UUID id, UUID athleteId, Double weight) {
        Map<String, Object> entry = new LinkedHashMap<>();
        entry.put("id", id.toString());
        entry.put("athleteId", athleteId.toString());
        entry.put("date", LocalDate.now().toString());
        entry.put("weight", weight);
        entry.put("notes", "Test entry");
        entry.put("createdAt", Instant.now().toString());
        entry.put("updatedAt", Instant.now().toString());
        entry.put("createdBy", athleteId.toString());
        entry.put("updatedBy", athleteId.toString());
        return entry;
    }

    private Map<String, Object> buildBodyWeightEntryNullDate(UUID id, UUID athleteId, Double weight) {
        Map<String, Object> entry = new LinkedHashMap<>();
        entry.put("id", id.toString());
        entry.put("athleteId", athleteId.toString());
        entry.put("date", null);
        entry.put("weight", weight);
        entry.put("notes", "Test entry");
        entry.put("createdAt", Instant.now().toString());
        entry.put("updatedAt", Instant.now().toString());
        entry.put("createdBy", athleteId.toString());
        entry.put("updatedBy", athleteId.toString());
        return entry;
    }
}
