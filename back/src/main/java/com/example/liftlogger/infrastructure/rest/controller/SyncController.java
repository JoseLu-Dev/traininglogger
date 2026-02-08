package com.example.liftlogger.infrastructure.rest.controller;

import com.example.liftlogger.application.sync.PullSyncUseCase;
import com.example.liftlogger.application.sync.PushSyncUseCase;
import com.example.liftlogger.application.sync.dto.PullSyncRequest;
import com.example.liftlogger.application.sync.dto.PullSyncResponse;
import com.example.liftlogger.application.sync.dto.PushSyncRequest;
import com.example.liftlogger.application.sync.dto.PushSyncResponse;
import com.example.liftlogger.infrastructure.rest.dto.sync.PullSyncRequestDto;
import com.example.liftlogger.infrastructure.rest.dto.sync.PullSyncResponseDto;
import com.example.liftlogger.infrastructure.rest.dto.sync.PushSyncRequestDto;
import com.example.liftlogger.infrastructure.rest.dto.sync.PushSyncResponseDto;
import com.example.liftlogger.infrastructure.rest.mapper.SyncDtoConverter;
import com.example.liftlogger.infrastructure.security.CurrentUser;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * REST controller for sync operations
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/sync")
@RequiredArgsConstructor
public class SyncController {

    private final PullSyncUseCase pullSyncUseCase;
    private final PushSyncUseCase pushSyncUseCase;
    private final SyncDtoConverter syncDtoConverter;

    @PostMapping("/pull")
    public ResponseEntity<PullSyncResponseDto> pullSync(
            @AuthenticationPrincipal CurrentUser currentUser,
            @Valid @RequestBody PullSyncRequestDto requestDto
    ) {
        UUID userId = currentUser.getId();
        log.info("Pull sync requested by user {} for entity types: {}", userId, requestDto.entityTypes());

        PullSyncRequest request = new PullSyncRequest(
                requestDto.entityTypes(),
                requestDto.lastSyncTime()
        );

        PullSyncResponse response = pullSyncUseCase.pullEntities(userId, request);

        PullSyncResponseDto responseDto = syncDtoConverter.toPullResponseDto(response);

        log.info("Pull sync completed for user {}: {} entities", userId, responseDto.totalEntities());

        return ResponseEntity.ok(responseDto);
    }

    @PostMapping("/push")
    public ResponseEntity<PushSyncResponseDto> pushSync(
            @AuthenticationPrincipal CurrentUser currentUser,
            @Valid @RequestBody PushSyncRequestDto requestDto
    ) {
        UUID userId = currentUser.getId();
        log.info("Push sync requested by user {} with {} entity types", userId, requestDto.entities().size());

        var domainEntities = syncDtoConverter.toDomainEntities(requestDto.entities());

        PushSyncRequest request = new PushSyncRequest(domainEntities);

        PushSyncResponse response = pushSyncUseCase.pushEntities(userId, request);

        PushSyncResponseDto responseDto = new PushSyncResponseDto(
                response.successCount(),
                response.failureCount(),
                response.failures(),
                response.syncTimestamp()
        );

        log.info("Push sync completed for user {}: {} succeeded, {} failed",
                userId, response.successCount(), response.failureCount());

        return ResponseEntity.ok(responseDto);
    }
}
