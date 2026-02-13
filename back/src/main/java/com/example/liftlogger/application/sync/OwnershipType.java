package com.example.liftlogger.application.sync;

/**
 * Defines ownership types for entity visibility in the sync system.
 * Determines which users can see which entities based on their role and relationships.
 */
public enum OwnershipType {
    /**
     * User entity - users see only their own record
     * Ensures user data privacy (password hashes, etc.)
     */
    SELF,

    /**
     * Coach-owned entities (Exercise, Variant)
     * - Coaches see their own entities
     * - Athletes see their coach's entities
     */
    COACH,

    /**
     * Athlete-owned entities (TrainingPlan, Sessions, BodyWeightEntry, etc.)
     * - Athletes see their own entities
     * - Coaches see all their athletes' entities
     */
    ATHLETE
}
