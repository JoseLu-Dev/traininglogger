# Entity Generator Guide

## Overview

This generator creates all the boilerplate code for sync entities from simple YAML schemas.

## Usage

```bash
# From the front_shared directory
cd front_shared
fvm dart run tool/generate_entity.dart entities/training_plan.yaml
```

This generates 6 files:
1. Domain model (Freezed class)
2. Drift table definition
3. DAO with all CRUD operations
4. Repository interface
5. Repository implementation
6. Basic DAO tests

## After Generation

1. Run build_runner to generate Freezed and Drift code:
   ```bash
   cd front_shared
   dart run build_runner build --delete-conflicting-outputs
   ```

2. Update `app_database.dart` to include the new table and DAO:
   ```dart
   import 'generated/data/local/database/tables/{table_name}_table.dart';
   import 'generated/data/local/database/daos/{entity_name}_dao.dart';
   ```

3. Register the entity in `entity_registry_setup.dart`

4. Create providers in `database_providers.dart` and `repository_providers.dart`

5. Run tests:
   ```bash
   cd front_shared
   flutter test test/generated/{entity_name}_dao_test.dart
   ```

## YAML Schema Format

See `entities/training_plan.yaml` for a complete example.

### Required Fields

```yaml
entity:
  name: EntityName           # PascalCase
  tableName: entity_names    # snake_case plural
  description: Brief description

fields:
  - name: fieldName         # camelCase
    type: String            # Dart type
    tableType: text()       # Drift column type
    nullable: false         # Optional, defaults to false
    constraints: .withLength(min: 1, max: 255)  # Optional Drift constraints
    default: const Constant(false)               # Optional default value
    reference:              # Optional foreign key
      table: OtherTable
      column: id

indexes:                    # Optional
  - name: idx_table_field
    columns: [field1, field2]

queries:                    # Optional custom queries
  - name: findByField
    params:
      - name: field
        type: String
    returns: List<EntityData>  # or EntityData? for single
    where: t.field.equals(field) & t.deletedAt.isNull()
    orderBy: OrderingTerm.desc(t.createdAt)  # Optional

createFactory:             # Factory constructor params
  params:
    - field1
    - field2
```

### Enum Fields

For enum fields, add `enumValues`:

```yaml
fields:
  - name: role
    type: UserRole
    tableType: intEnum<UserRole>()
    enumValues: [athlete, coach]
```

## Time Savings

- Manual implementation: ~470 lines, 1-2 hours per entity
- With generator: ~40 lines YAML, 15-20 minutes per entity
- **Savings: ~70-80% less time, 90%+ less code duplication**

## Generated File Locations

All generated code goes into `lib/src/generated/`:

- `lib/src/generated/domain/models/{entity_name}.dart`
- `lib/src/generated/data/local/database/tables/{table_name}_table.dart`
- `lib/src/generated/data/local/database/daos/{entity_name}_dao.dart`
- `lib/src/generated/domain/repositories/{entity_name}_repository.dart`
- `lib/src/generated/data/repositories/{entity_name}_repository_impl.dart`
- `test/generated/{entity_name}_dao_test.dart`

Base infrastructure remains in `lib/src/`:

- `lib/src/domain/models/syncable_entity.dart`
- `lib/src/data/local/database/tables/base_table.dart`
- `lib/src/data/local/database/daos/base_dao.dart`
- `lib/src/data/local/database/app_database.dart`
