import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_queue_item.freezed.dart';
part 'sync_queue_item.g.dart';

/// Sync Queue Item Model
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Represents a queued operation that needs to be synced to Firestore.
/// Used for offline-first architecture with background sync.
///
/// Example:
/// ```dart
/// final item = SyncQueueItem(
///   id: 'sync-123',
///   operation: SyncOperation.create,
///   collection: 'inventory_items',
///   documentId: 'item-456',
///   data: {'name': 'Milk', 'quantity': 1},
///   queuedAt: DateTime.now(),
/// );
/// ```
@freezed
abstract class SyncQueueItem with _$SyncQueueItem {
  const factory SyncQueueItem({
    required String id, // UUID v4
    required SyncOperation operation, // CREATE, UPDATE, DELETE
    required String collection, // 'inventory_items', 'nutrition_tracking', etc.
    required String documentId, // Firestore document ID
    required Map<String, dynamic> data, // Payload to sync
    required DateTime queuedAt, // When queued (local time)
    @Default(0) int retryCount, // Current retry attempt (0-3)
    DateTime? lastAttemptAt, // Last sync attempt timestamp
    String? errorMessage, // Last error message (for debugging)
  }) = _SyncQueueItem;

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueItemFromJson(json);
}

/// Sync operation types for queue items
enum SyncOperation {
  /// Add new document to Firestore
  create,

  /// Update existing document in Firestore
  update,

  /// Delete document from Firestore
  delete,
}
