/// Sync Queue Metrics
/// Story 0.9: Implement Offline-First Sync Architecture Foundation - Phase 2
///
/// Provides metrics about the sync queue for monitoring and debugging.
///
/// Example:
/// ```dart
/// final metrics = SyncQueueMetrics(
///   queueSize: 5,
///   deadLetterQueueSize: 2,
///   oldestItemTimestamp: DateTime.now().subtract(Duration(hours: 1)),
/// );
/// print('Queue has ${metrics.queueSize} pending items');
/// ```
class SyncQueueMetrics {
  /// Number of items in sync queue
  final int queueSize;

  /// Number of items in dead-letter queue
  final int deadLetterQueueSize;

  /// Timestamp of oldest item in queue (null if queue empty)
  final DateTime? oldestItemTimestamp;

  const SyncQueueMetrics({
    required this.queueSize,
    required this.deadLetterQueueSize,
    this.oldestItemTimestamp,
  });

  /// Check if queue is empty
  bool get isEmpty => queueSize == 0;

  /// Check if there are items waiting to sync
  bool get hasPendingItems => queueSize > 0;

  /// Check if there are failed items in dead-letter queue
  bool get hasFailedItems => deadLetterQueueSize > 0;

  /// Calculate queue age (how long oldest item has been waiting)
  Duration? get queueAge {
    if (oldestItemTimestamp == null) return null;
    return DateTime.now().difference(oldestItemTimestamp!);
  }

  /// Check if queue is stale (oldest item older than threshold)
  bool isStale({Duration threshold = const Duration(hours: 24)}) {
    final age = queueAge;
    if (age == null) return false;
    return age > threshold;
  }

  @override
  String toString() {
    return 'SyncQueueMetrics(queue: $queueSize, deadLetter: $deadLetterQueueSize, age: ${queueAge?.inMinutes}min)';
  }
}
