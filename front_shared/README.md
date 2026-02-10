# front_shared

Shared Flutter package for LiftLogger containing the offline-first sync system, domain models, data layer, and business logic.

## Features

- Offline-first architecture with automatic sync
- Entity generator for rapid development
- Clean architecture with domain/data separation
- Drift-based local database
- Freezed domain models
- Comprehensive testing utilities

## Entity Generator

This package includes a powerful code generator that automates entity boilerplate creation.

### Quick Start

Generate a new entity from a YAML schema:

```bash
cd front_shared
fvm dart run tool/generate_entity.dart entities/training_plan.yaml
```

This generates 6 files:
- Domain model (Freezed)
- Drift table definition
- DAO with CRUD operations
- Repository interface
- Repository implementation
- Basic tests

### Generate All Entities

```bash
cd front_shared
./tool/generate_all_entities.sh  # Unix/Mac
# or
tool\generate_all_entities.bat  # Windows
```

### Documentation

See the following files for complete documentation:
- [QUICK_START.md](QUICK_START.md) - 5-step quick reference
- [ENTITY_GENERATOR_README.md](ENTITY_GENERATOR_README.md) - Complete overview
- [GENERATOR_GUIDE.md](GENERATOR_GUIDE.md) - Detailed usage guide
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Technical implementation

## Development

### Setup

```bash
flutter pub get
```

### Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run Tests

```bash
flutter test
```
