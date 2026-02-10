# LiftLogger Project Structure

## Folders

- **back** - Backend API service (Spring Boot/Java)
- **front_athlete** - Flutter mobile app for athletes to log workouts
- **front_coach** - Flutter mobile app for coaches to manage athletes and programs
- **front_shared** - Shared Dart code and entities used across both frontend apps

## Execution

### Backend

From the `back` folder, run:

```bash
mvnw spring-boot:run
```

### Frontends (front_athlete, front_coach)

From within each frontend folder, run:

```bash
flutter run
# or
dart <command>
```
