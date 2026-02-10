package com.example.liftlogger.infrastructure.rest.controller;

import com.example.liftlogger.application.sync.PullSyncUseCase;
import com.example.liftlogger.application.sync.PushSyncUseCase;
import com.example.liftlogger.application.sync.dto.PullSyncResponse;
import com.example.liftlogger.application.sync.dto.PushSyncResponse;
import com.example.liftlogger.infrastructure.rest.dto.sync.PullSyncRequestDto;
import com.example.liftlogger.infrastructure.rest.dto.sync.PushSyncRequestDto;
import com.example.liftlogger.infrastructure.rest.mapper.SyncDtoConverter;
import com.example.liftlogger.infrastructure.rest.dto.sync.PullSyncResponseDto;
import com.example.liftlogger.infrastructure.security.CurrentUser;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import tools.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(SyncController.class)
class SyncControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private PullSyncUseCase pullSyncUseCase;

    @MockitoBean
    private PushSyncUseCase pushSyncUseCase;

    @MockitoBean
    private SyncDtoConverter syncDtoConverter;

    private CurrentUser testUser() {
        return new CurrentUser(
                UUID.fromString("00000000-0000-0000-0000-000000000001"),
                "test@example.com",
                "password",
                "ATHLETE",
                List.of(new SimpleGrantedAuthority("ROLE_ATHLETE"))
        );
    }

    @Test
    void pullSync_returnsEntities() throws Exception {
        PullSyncResponseDto mockResponseDto = new PullSyncResponseDto(
                Map.of("TrainingPlan", List.of()),
                LocalDateTime.now(),
                0
        );

        when(pullSyncUseCase.pullEntities(any(), any())).thenReturn(
                new PullSyncResponse(Map.of("TrainingPlan", List.of()), LocalDateTime.now(), 0)
        );
        when(syncDtoConverter.toPullResponseDto(any())).thenReturn(mockResponseDto);

        PullSyncRequestDto request = new PullSyncRequestDto(
                List.of("TrainingPlan"),
                null
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(user(testUser()))
                        .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalEntities").value(0))
                .andExpect(jsonPath("$.syncTimestamp").exists());
    }

    @Test
    void pushSync_returnsSuccessResponse() throws Exception {
        PushSyncResponse mockResponse = new PushSyncResponse(
                5,
                0,
                List.of(),
                LocalDateTime.now()
        );

        when(pushSyncUseCase.pushEntities(any(), any())).thenReturn(mockResponse);
        when(syncDtoConverter.toDomainEntities(any())).thenReturn(Map.of());

        PushSyncRequestDto request = new PushSyncRequestDto(
                Map.of("TrainingPlan", List.of())
        );

        mockMvc.perform(post("/api/v1/sync/push")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(user(testUser()))
                        .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.successCount").value(5))
                .andExpect(jsonPath("$.failureCount").value(0));
    }

    @Test
    void pullSync_missingAuth_returns401() throws Exception {
        PullSyncRequestDto request = new PullSyncRequestDto(
                List.of("TrainingPlan"),
                null
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(csrf()))
                .andExpect(status().isUnauthorized());
    }
}
