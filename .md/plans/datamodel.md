# 📦 MODELO DE DATOS – TrainingLog (MVP)

---

## 👤 Coach

- id
- name

### Relaciones

- 1 Coach → N Athlete
- 1 Coach → N Exercise
- 1 Coach → N Variant

---

## 🧍 Athlete

- id
- coachId
- name

### Relaciones

- 1 Athlete → 1 Coach
- 1 Athlete → N TrainingPlan
- 1 Athlete → N TrainingSession
- 1 Athlete → N BodyWeightEntry

---

## 🏋️ Exercise

- id
- coachId
- name
- description

### Relaciones

- 1 Exercise → 1 Coach
- 1 Exercise → N ExercisePlan
- 1 Exercise → N ExerciseSession

---

## 🔁 Variant

- id
- coachId
- name
- description

### Relaciones

- 1 Variant → 1 Coach
- N Variant ↔ N ExercisePlan
- N Variant ↔ N ExerciseSession

---

## 📅 TrainingPlan

- id
- athleteId
- date
- name
- isLocked

### Relaciones

- 1 TrainingPlan → 1 Athlete
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
- athleteId
- trainingPlanId
- date
- name

### Relaciones

- 1 TrainingSession → 1 Athlete
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
- athleteId
- date
- weight

### Relaciones

- 1 BodyWeightEntry → 1 Athlete
