import 'dart:collection';
import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_queue.freezed.dart';

@freezed
class QueuedSync with _$QueuedSync {
  const factory QueuedSync({
    required String id,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    required DateTime queuedAt,
    required int retryCount,
    required DateTime nextRetryAt,
  }) = _QueuedSync;

  const QueuedSync._();

  bool get canRetry => retryCount < 5;

  QueuedSync incrementRetry() => copyWith(
    retryCount: retryCount + 1,
    nextRetryAt: DateTime.now().add(
      Duration(seconds: (pow(2, retryCount) * 30).toInt())
    ),
  );
}

class SyncQueue {
  final Queue<QueuedSync> _queue = Queue();

  void enqueue(QueuedSync sync) {
    if (sync.canRetry) {
      _queue.add(sync);
    }
  }

  List<QueuedSync> getDueRetries() {
    return _queue.where((s) => s.nextRetryAt.isBefore(DateTime.now())).toList();
  }

  void remove(String syncId) {
    _queue.removeWhere((s) => s.id == syncId);
  }

  int get length => _queue.length;

  void clear() => _queue.clear();
}
