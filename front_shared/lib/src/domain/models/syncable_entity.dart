abstract class SyncableEntity {
  String get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  int get version;
  DateTime? get deletedAt;
  bool get isDirty;
  DateTime? get lastSyncedAt;
}
