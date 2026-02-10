package com.example.liftlogger.domain.exception;

import java.util.UUID;

public class EntityNotFoundException extends DomainException {
    public EntityNotFoundException(String entityType, UUID id) {
        super(String.format("%s with id %s not found", entityType, id));
    }
}
