# 📦 MODELO DE DATOS – TrainingLog (MVP)

---

## 👤 User (Coach/Athlete)

- id (UUID)
- email (String, unique)
- passwordHash (String)
- role (UserRole: COACH | ATHLETE)
- coachId (UUID, null for coaches)
- name (String)
- createdAt (LocalDateTime)
- updatedAt (LocalDateTime)
- version (Integer)
- deletedAt (LocalDateTime, soft delete)

### Relaciones

- 1 User(COACH) → N User(ATHLETE) (coach-athlete relationship)
- 1 User(COACH) → N Exercise
- 1 User(COACH) → N Variant
- 1 User(ATHLETE) → N TrainingPlan
- 1 User(ATHLETE) → N TrainingSession
- 1 User(ATHLETE) → N BodyWeightEntry

---

## 🏋️ Exercise

- id
- coachId (references User with role COACH)
- name
- description

### Relaciones

- 1 Exercise → 1 User(COACH)
- 1 Exercise → N ExercisePlan
- 1 Exercise → N ExerciseSession

---

## 🔁 Variant

- id
- coachId (references User with role COACH)
- name
- description

### Relaciones

- 1 Variant → 1 User(COACH)
- N Variant ↔ N ExercisePlan
- N Variant ↔ N ExerciseSession

---

## 📅 TrainingPlan

- id
- athleteId (references User with role ATHLETE)
- date
- name
- isLocked

### Relaciones

- 1 TrainingPlan → 1 User(ATHLETE)
- 1 TrainingPlan → N ExercisePlan

---

## 🧱 ExercisePlan

- id
- athleteId
- trainingPlanId
- exerciseId
- order
- comment

### Relaciones

- 1 ExercisePlan → 1 TrainingPlan
- 1 ExercisePlan → 1 Exercise
- 1 ExercisePlan → N SetPlan
- 1 ExercisePlan ↔ N Variant

---

## 🔢 SetPlan

- id
- athleteId
- exercisePlanId
- order
- weightTarget
- repsTarget
- rpeTarget

### Relaciones

- 1 SetPlan → 1 ExercisePlan

---

## 📅 TrainingSession

- id
- athleteId (references User with role ATHLETE)
- trainingPlanId
- date
- name

### Relaciones

- 1 TrainingSession → 1 User(ATHLETE)
- 1 TrainingSession → N ExerciseSession

---

## 🧱 ExerciseSession

- id
- athleteId
- trainingSessionId
- exercisePlanId
- exerciseNameSnapshot
- comment

### Relaciones

- 1 ExerciseSession → 1 TrainingSession
- 1 ExerciseSession → N SetSession
- 1 ExerciseSession ↔ N Variant

---

## 🔢 SetSession

- id
- athleteId
- exerciseSessionId
- order
- weightTarget
- repsTarget
- rpeTarget
- weightActual
- repsActual
- rpeActual

### Relaciones

- 1 SetSession → 1 ExerciseSession

---

## ⚖️ BodyWeightEntry

- id
- athleteId (references User with role ATHLETE)
- date
- weight

### Relaciones

- 1 BodyWeightEntry → 1 User(ATHLETE)
