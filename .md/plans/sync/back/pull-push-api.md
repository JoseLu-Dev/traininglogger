## API Design

```
GET /api/v1/sync/pull?since={timestamp}&athleteId={uuid}&entityTypes={csv}&limit={int}
```

### Query Parameters

- **`since`** (required): `Instant` - Timestamp of last sync. Returns entities updated after this time.
- **`athleteId`** (required): `UUID` - ID of athlete whose data to pull.
- **`entityTypes`** (optional): `List<String>` - Comma-separated entity types (e.g., `TrainingPlan,SetSession`). If omitted, pulls all 12 entity types.
- **`limit`** (optional): `int` - Max entities per type. Default: 100, Max: 500.

### Response Format

```json
{
  "changesByType": {
    "TrainingPlan": [
      {
        "id": "uuid-1",
        "athleteId": "uuid-athlete",
        "name": "Strength Program",
        "startDate": "2026-01-01",
        "endDate": "2026-03-01",
        "updatedAt": "2026-02-06T10:00:00Z",
        "version": 1
      }
    ],
    "SetSession": [
      {
        "id": "uuid-2",
        "trainingPlanId": "uuid-1",
        "athleteId": "uuid-athlete",
        "reps": 10,
        "updatedAt": "2026-02-06T11:00:00Z",
        "version": 1
      }
    ],
    "Exercise": []
  },
  "syncTimestamp": "2026-02-06T15:30:00Z",
  "stats": {
    "TrainingPlan": { "fetched": 1, "hasMore": false },
    "SetSession": { "fetched": 1, "hasMore": false },
    "Exercise": { "fetched": 0, "hasMore": false }
  }
}
```

```
POST /api/v1/sync/push
```

### Request Format (Frontend-Grouped)

Frontend groups entities by type before sending:

```json
{
  "TrainingPlan": [
    {
      "id": "uuid-1",
      "athleteId": "uuid-athlete",
      "name": "Updated Strength Program",
      "startDate": "2026-01-01",
      "endDate": "2026-03-01",
      "version": 1
    },
    {
      "id": "uuid-2",
      "athleteId": "uuid-athlete",
      "name": "Invalid Program",
      "startDate": "2026-03-01",
      "endDate": "2026-01-01",
      "version": 1
    }
  ],
  "SetSession": [
    {
      "id": "uuid-3",
      "trainingPlanId": "uuid-1",
      "athleteId": "uuid-athlete",
      "reps": 10,
      "version": 1
    }
  ]
}
```

**Why Frontend Grouping?**

- ✅ No server-side re-grouping overhead
- ✅ Cleaner API contract
- ✅ Frontend controls batch size per entity type
- ✅ More efficient JSON structure

### Response Format (Partial Failures)

Server validates each entity and returns successes/failures:

```json
{
  "succeeded": [
    {
      "entityType": "TrainingPlan",
      "entityId": "uuid-1",
      "entity": {
        "id": "uuid-1",
        "name": "Updated Strength Program",
        "updatedAt": "2026-02-06T15:30:00Z",
        "version": 2
      }
    },
    {
      "entityType": "SetSession",
      "entityId": "uuid-3",
      "entity": {
        "id": "uuid-3",
        "updatedAt": "2026-02-06T15:30:00Z",
        "version": 2
      }
    }
  ],
  "failed": [
    {
      "entityType": "TrainingPlan",
      "entityId": "uuid-2",
      "errors": [
        {
          "field": "endDate",
          "code": "INVALID_RANGE",
          "message": "End date must be after start date"
        }
      ]
    }
  ],
  "summary": {
    "totalReceived": 3,
    "succeeded": 2,
    "failed": 1
  }
}
```
