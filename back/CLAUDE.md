# Hexagonal Architecture - Quick Reference

## Project Structure

```
domain/
  ├── model/           → Domain entities (POJOs with Lombok) | [Entity]
  ├── rule/            → Domain rules (static method) | [RuleName]Rule
  ├── exception/       → Domain exceptions | [Name]Exception
  └── outbound/repository/ → Output ports (interfaces) | [Entity]Repository

application/
  ├── inbound/         → Input ports (use case interfaces) | [Verb][Entity]UseCase
  └── service/         → Use case implementations | [Verb][Entity]Service

infrastructure/
  ├── db/
  │   ├── adapter/     → Implements domain repository port | [Entity]JpaAdapter
  │   ├── entity/      → JPA entities (@Entity) | [Entity]JpaEntity
  │   ├── mapper/      → JPA Entity ↔ Domain (MapStruct) | [Entity]JpaMapper
  │   ├── repository/  → Spring Data JPA interfaces | [Entity]JpaRepository
  │   └── specification/ → JPA Criteria queries | [Entity]JpaSpecification
  └── rest/
      ├── controller/  → REST endpoints (inbound adapter) | [Resource]Controller
      ├── dto/         → Request/Response DTOs | [Resource]Request | [Resource]Response
      ├── mapper/      → Domain ↔ DTO (MapStruct) | [Resource]Mapper | [Resource][Request|Response]Mapper
      └── exception/   → @RestControllerAdvice handler | [Scope]ExceptionHandler
```

## Dependency Flow

- **Inward only**: Infrastructure → Application → Domain
- **Domain has zero external dependencies**
- Controllers depend on **input ports** (use case interfaces)
- Adapters implement **output ports** (repository interfaces)

## Key Patterns

- **Ports**: Interfaces in domain/application layers
- **Adapters**: Infrastructure implementations of ports
- **MapStruct mappers**: Entity↔Domain, Domain↔DTO
- **JPA Specifications**: Composable query predicates
- **Global exception handler**: Domain exceptions → HTTP responses

## Key Implementation Details

- **Domain model**: Pure Java, no framework annotations
- **Controller**: Returns DTO, uses input port, never exposes domain directly. Swagger annotations for API docs
- **Jpa adapter**: Implements domain repository interface, handles mapping. Throws domain exceptions to translate JPA exceptions
- **Mappers**: Interface-based with `@Mapper(componentModel = "spring")`
- **DTOs**: Java records for immutability. Swagger annotations for API docs
- **Exceptions**: Domain generic exceptions with message → Global handler converts to HTTP responses

## Config Highlights

- UTC timezone
- Composite index on lookup

## Logging Guidelines

Make use of a custom class LoggerService that adds MDC (userId, traceId)

**Log Levels:**

- **ERROR:** Unexpected exceptions, system failures
- **WARN:** Recoverable issues, deprecated features
- **INFO:** State-changing operations ONLY (INSERT, UPDATE, DELETE)
- **DEBUG:** Read operations (SELECT queries), detailed flow
