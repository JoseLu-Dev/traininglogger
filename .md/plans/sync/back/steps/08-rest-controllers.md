# Step 8: REST Controllers

## Objective
Implement REST API controllers for pull and push sync endpoints, connecting the infrastructure layer to the application layer.

## Files to Create

### 1. Sync Request/Response DTOs

**File:** `src/main/java/com/liftlogger/infrastructure/rest/dto/sync/PullSyncRequestDto.java`

```java
package com.liftlogger.infrastructure.rest.dto.sync;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotEmpty;

import java.time.LocalDateTime;
import java.util.List;

public record PullSyncRequestDto(
    @NotEmpty(message = "Entity types list cannot be empty")
    List<String> entityTypes,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime lastSyncTime
) {}
```

**File:** `src/main/java/com/liftlogger/infrastructure/rest/dto/sync/PushSyncRequestDto.java`

```java
package com.liftlogger.infrastructure.rest.dto.sync;

import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.Map;

public record PushSyncRequestDto(
    @NotNull(message = "Entities map cannot be null")
    Map<String, List<Object>> entities
) {}
```

**File:** `src/main/java/com/liftlogger/infrastructure/rest/dto/sync/PushSyncResponseDto.java`

```java
package com.liftlogger.infrastructure.rest.dto.sync;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.liftlogger.application.sync.dto.EntityFailure;

import java.time.LocalDateTime;
import java.util.List;

public record PushSyncResponseDto(
    int successCount,
    int failureCount,
    List<EntityFailure> failures,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime syncTimestamp
) {}
```

### 2. Sync REST Controller

**File:** `src/main/java/com/liftlogger/infrastructure/rest/controller/SyncController.java`

```java
package com.liftlogger.infrastructure.rest.controller;

import com.liftlogger.application.sync.PullSyncUseCase;
import com.liftlogger.application.sync.PushSyncUseCase;
import com.liftlogger.application.sync.dto.PullSyncRequest;
import com.liftlogger.application.sync.dto.PullSyncResponse;
import com.liftlogger.application.sync.dto.PushSyncRequest;
import com.liftlogger.application.sync.dto.PushSyncResponse;
import com.liftlogger.infrastructure.rest.dto.sync.*;
import com.liftlogger.infrastructure.rest.mapper.SyncDtoConverter;
import com.liftlogger.infrastructure.security.CurrentUser;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * REST controller for sync operations
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/sync")
@RequiredArgsConstructor
@Tag(name = "Sync", description = "Data synchronization endpoints")
public class SyncController {

    private final PullSyncUseCase pullSyncUseCase;
    private final PushSyncUseCase pushSyncUseCase;
    private final SyncDtoConverter syncDtoConverter;

    @PostMapping("/pull")
    @Operation(
        summary = "Pull entities from server",
        description = "Fetch entities for the authenticated user. " +
            "Use lastSyncTime for incremental sync or omit for full sync."
    )
    public ResponseEntity<PullSyncResponseDto> pullSync(
        @AuthenticationPrincipal CurrentUser currentUser,
        @Valid @RequestBody PullSyncRequestDto requestDto
    ) {
        UUID userId = currentUser.getId();
        log.info("Pull sync requested by user {} for entity types: {}",
            userId, requestDto.entityTypes());

        // Convert DTO to application request
        PullSyncRequest request = new PullSyncRequest(
            requestDto.entityTypes(),
            requestDto.lastSyncTime()
        );

        // Execute use case
        PullSyncResponse response = pullSyncUseCase.pullEntities(userId, request);

        // Convert to DTO
        PullSyncResponseDto responseDto = syncDtoConverter.toPullResponseDto(response);

        log.info("Pull sync completed for user {}: {} entities",
            userId, responseDto.totalEntities());

        return ResponseEntity.ok(responseDto);
    }

    @PostMapping("/push")
    @Operation(
        summary = "Push entities to server",
        description = "Validate and save entities for the authenticated user. " +
            "Returns partial failures for invalid entities without stopping the sync."
    )
    public ResponseEntity<PushSyncResponseDto> pushSync(
        @AuthenticationPrincipal CurrentUser currentUser,
        @Valid @RequestBody PushSyncRequestDto requestDto
    ) {
        UUID userId = currentUser.getId();
        log.info("Push sync requested by user {} with {} entity types",
            userId, requestDto.entities().size());

        // Convert DTOs to domain entities
        var domainEntities = syncDtoConverter.toDomainEntities(requestDto.entities());

        // Create application request
        PushSyncRequest request = new PushSyncRequest(domainEntities);

        // Execute use case
        PushSyncResponse response = pushSyncUseCase.pushEntities(userId, request);

        // Convert to DTO
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

    @GetMapping("/health")
    @Operation(
        summary = "Check sync service health",
        description = "Health check endpoint for sync service"
    )
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Sync service is healthy");
    }
}
```

### 3. Current User Security Context

**File:** `src/main/java/com/liftlogger/infrastructure/security/CurrentUser.java`

```java
package com.liftlogger.infrastructure.security;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.UUID;

/**
 * Current authenticated user wrapper
 */
@Getter
@RequiredArgsConstructor
public class CurrentUser implements UserDetails {

    private final UUID id;
    private final String username;
    private final String role;  // ATHLETE, COACH, ADMIN
    private final Collection<? extends GrantedAuthority> authorities;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return null;  // Not exposed
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
```

### 4. User Context Provider Implementation

**File:** `src/main/java/com/liftlogger/infrastructure/security/UserContextProviderImpl.java`

```java
package com.liftlogger.infrastructure.security;

import com.liftlogger.application.sync.UserContextProvider;
import com.liftlogger.application.sync.validation.ValidationContext;
import com.liftlogger.domain.repository.AthleteRepository;
import com.liftlogger.domain.repository.CoachRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Spring Security-based implementation of UserContextProvider
 */
@Component
@RequiredArgsConstructor
public class UserContextProviderImpl implements UserContextProvider {

    private final AthleteRepository athleteRepository;
    private final CoachRepository coachRepository;

    @Override
    public ValidationContext getValidationContext(UUID userId) {
        // Determine user role by checking repositories
        String role = determineUserRole(userId);
        return new ValidationContext(userId, role);
    }

    private String determineUserRole(UUID userId) {
        if (athleteRepository.existsById(userId)) {
            return "ATHLETE";
        } else if (coachRepository.existsById(userId)) {
            return "COACH";
        }
        return "USER";  // Default role
    }
}
```

### 5. Global Exception Handler

**File:** `src/main/java/com/liftlogger/infrastructure/rest/exception/GlobalExceptionHandler.java`

```java
package com.liftlogger.infrastructure.rest.exception;

import com.liftlogger.domain.exception.EntityNotFoundException;
import com.liftlogger.domain.exception.ValidationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleEntityNotFound(EntityNotFoundException ex) {
        log.warn("Entity not found: {}", ex.getMessage());
        ErrorResponse error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage(),
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ValidationErrorResponse> handleValidation(ValidationException ex) {
        log.warn("Validation failed: {}", ex.getMessage());
        ValidationErrorResponse error = new ValidationErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            ex.getErrors(),
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ValidationErrorResponse> handleMethodArgumentNotValid(
        MethodArgumentNotValidException ex
    ) {
        List<String> errors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .toList();

        ValidationErrorResponse error = new ValidationErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Request validation failed",
            errors,
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgument(IllegalArgumentException ex) {
        log.warn("Illegal argument: {}", ex.getMessage());
        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            ex.getMessage(),
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneral(Exception ex) {
        log.error("Unexpected error", ex);
        ErrorResponse error = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "An unexpected error occurred",
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }

    record ErrorResponse(
        int status,
        String message,
        LocalDateTime timestamp
    ) {}

    record ValidationErrorResponse(
        int status,
        String message,
        List<String> errors,
        LocalDateTime timestamp
    ) {}
}
```

## Testing

**File:** `src/test/java/com/liftlogger/infrastructure/rest/controller/SyncControllerTest.java`

```java
package com.liftlogger.infrastructure.rest.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.liftlogger.application.sync.PullSyncUseCase;
import com.liftlogger.application.sync.PushSyncUseCase;
import com.liftlogger.application.sync.dto.PullSyncResponse;
import com.liftlogger.application.sync.dto.PushSyncResponse;
import com.liftlogger.infrastructure.rest.dto.sync.PullSyncRequestDto;
import com.liftlogger.infrastructure.rest.dto.sync.PushSyncRequestDto;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(SyncController.class)
class SyncControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private PullSyncUseCase pullSyncUseCase;

    @MockBean
    private PushSyncUseCase pushSyncUseCase;

    @Test
    @WithMockUser
    void pullSync_returnsEntities() throws Exception {
        PullSyncResponse mockResponse = new PullSyncResponse(
            Map.of("TrainingPlan", List.of()),
            LocalDateTime.now(),
            0
        );

        when(pullSyncUseCase.pullEntities(any(), any())).thenReturn(mockResponse);

        PullSyncRequestDto request = new PullSyncRequestDto(
            List.of("TrainingPlan"),
            null
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.totalEntities").value(0))
            .andExpect(jsonPath("$.syncTimestamp").exists());
    }

    @Test
    @WithMockUser
    void pushSync_returnsSuccessResponse() throws Exception {
        PushSyncResponse mockResponse = new PushSyncResponse(
            5,
            0,
            List.of(),
            LocalDateTime.now()
        );

        when(pushSyncUseCase.pushEntities(any(), any())).thenReturn(mockResponse);

        PushSyncRequestDto request = new PushSyncRequestDto(
            Map.of("TrainingPlan", List.of())
        );

        mockMvc.perform(post("/api/v1/sync/push")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
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
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isUnauthorized());
    }
}
```

## Acceptance Criteria

- ✅ `SyncController` with pull and push endpoints
- ✅ Request/Response DTOs with validation annotations
- ✅ Security integration with @AuthenticationPrincipal
- ✅ `CurrentUser` wrapper for authenticated user
- ✅ `UserContextProviderImpl` implementation
- ✅ `GlobalExceptionHandler` for consistent error responses
- ✅ Swagger/OpenAPI documentation annotations
- ✅ Controller tests pass
- ✅ Proper HTTP status codes (200 OK, 400 Bad Request, 401 Unauthorized, 404 Not Found)

## Next Step

After completing this step, move to **09-entity-validators.md** to implement business validators for all 12 entities.
