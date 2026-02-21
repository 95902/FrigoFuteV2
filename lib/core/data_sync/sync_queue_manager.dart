import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import 'conflict_resolver.dart';
import 'models/sync_queue_item.dart';
import 'models/sync_queue_metrics.dart';
import 'sync_retry_manager.dart';

/// Sync Queue Manager
/// Story 0.9: Implement Offline-First Sync Architecture Foundation - Phase 2
///
/// Manages the sync queue with FIFO processing and dead-letter queue for failed items.
/// Handles retry logic with exponential backoff and conflict resolution.
///
/// Example:
/// ```dart
/// final manager = SyncQueueManager(
///   firestore: FirebaseFirestore.instance,
///   conflictResolver: ConflictResolver(),
///   retryManager: SyncRetryManager(),
/// );
/// await manager.init();
/// await manager.enqueue(
///   operation: SyncOperation.create,
///   collection: 'inventory_items',
///   documentId: 'item-123',
///   data: {'name': 'Milk', 'quantity': 1},
/// );
/// ```
class SyncQueueManager {
  final FirebaseFirestore _firestore;
  final ConflictResolver _conflictResolver;
  final SyncRetryManager _retryManager;

  late Box<SyncQueueItem> _syncQueueBox;
  late Box<SyncQueueItem> _deadLetterBox;

  SyncQueueManager({
    required FirebaseFirestore firestore,
    required ConflictResolver conflictResolver,
    required SyncRetryManager retryManager,
  })  : _firestore = firestore,
        _conflictResolver = conflictResolver,
        _retryManager = retryManager;

  /// Initialize sync queue boxes
  ///
  /// Opens sync_queue_box and dead_letter_queue_box from Hive.
  /// Must be called before using other methods.
  Future<void> init() async {
    _syncQueueBox = Hive.box<SyncQueueItem>('sync_queue_box');

    // Dead-letter queue for items that exceed max retries
    if (!Hive.isBoxOpen('dead_letter_queue_box')) {
      await Hive.openBox<SyncQueueItem>('dead_letter_queue_box');
    }
    _deadLetterBox = Hive.box<SyncQueueItem>('dead_letter_queue_box');

    if (kDebugMode) {
      debugPrint('✅ SyncQueueManager initialized');
      debugPrint('   Queue size: ${_syncQueueBox.length}');
      debugPrint('   Dead-letter queue size: ${_deadLetterBox.length}');
    }
  }

  /// Enqueues a sync operation
  ///
  /// Called when offline or to queue operations for background sync.
  ///
  /// Example:
  /// ```dart
  /// await manager.enqueue(
  ///   operation: SyncOperation.update,
  ///   collection: 'inventory_items',
  ///   documentId: 'item-456',
  ///   data: {'quantity': 2, 'updatedAt': DateTime.now().toIso8601String()},
  /// );
  /// ```
  Future<void> enqueue({
    required SyncOperation operation,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final item = SyncQueueItem(
      id: _generateUniqueId(),
      operation: operation,
      collection: collection,
      documentId: documentId,
      data: data,
      queuedAt: DateTime.now(),
    );

    await _syncQueueBox.add(item);

    if (kDebugMode) {
      debugPrint('📥 Enqueued sync item: ${item.id} (${item.operation.name})');
    }
  }

  /// Processes the entire sync queue in FIFO order
  ///
  /// Called automatically when network is restored.
  /// Processes all items sequentially with retry logic.
  ///
  /// Example:
  /// ```dart
  /// await manager.processSyncQueue();
  /// ```
  Future<void> processSyncQueue() async {
    final items = _syncQueueBox.values.toList();

    if (items.isEmpty) {
      if (kDebugMode) {
        debugPrint('ℹ️ Sync queue is empty, nothing to process');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('🔄 Processing ${items.length} items in sync queue...');
    }

    for (final item in items) {
      await _processSingleItem(item);
    }

    if (kDebugMode) {
      debugPrint('✅ Sync queue processing completed');
    }
  }

  /// Processes a single sync queue item with retry logic
  Future<void> _processSingleItem(SyncQueueItem item) async {
    try {
      // Execute sync operation
      await _syncToFirestore(item);

      // Success: remove from queue
      final key = _findItemKey(item.id);
      if (key != null) {
        await _syncQueueBox.delete(key);
      }

      if (kDebugMode) {
        debugPrint('✅ Sync successful: ${item.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Sync failed: ${item.id}');
        debugPrint('   Error: $e');
      }

      // Update retry count
      final updated = SyncQueueItem(
        id: item.id,
        operation: item.operation,
        collection: item.collection,
        documentId: item.documentId,
        data: item.data,
        queuedAt: item.queuedAt,
        retryCount: item.retryCount + 1,
        lastAttemptAt: DateTime.now(),
        errorMessage: e.toString(),
      );

      if (_retryManager.shouldRetry(updated.retryCount)) {
        // Retry with exponential backoff
        final delay = _retryManager.calculateBackoff(updated.retryCount);

        if (kDebugMode) {
          debugPrint(
              '⏳ Retrying ${item.id} in ${delay.inSeconds}s (attempt ${updated.retryCount})');
        }

        await Future.delayed(delay);

        // Update item in queue
        final key = _findItemKey(item.id);
        if (key != null) {
          await _syncQueueBox.put(key, updated);
        }

        // Retry immediately after delay
        await _processSingleItem(updated);
      } else {
        // Max retries exceeded: move to dead-letter queue
        if (kDebugMode) {
          debugPrint(
              '☠️ Max retries exceeded for ${item.id}, moving to dead-letter queue');
        }

        await _deadLetterBox.add(updated);

        final key = _findItemKey(item.id);
        if (key != null) {
          await _syncQueueBox.delete(key);
        }

        // TODO: Notify user of permanent sync failure (Story 0.9 Phase 6)
      }
    }
  }

  /// Syncs a single item to Firestore based on operation type
  Future<void> _syncToFirestore(SyncQueueItem item) async {
    final docRef = _firestore.doc('${item.collection}/${item.documentId}');

    switch (item.operation) {
      case SyncOperation.create:
        final dataWithVersion = _conflictResolver.incrementVersion(item.data);
        await docRef.set(dataWithVersion);
        break;

      case SyncOperation.update:
        // Check for conflicts before updating
        final remoteDoc = await docRef.get();

        if (!remoteDoc.exists) {
          // Document deleted remotely → skip update
          if (kDebugMode) {
            debugPrint(
                '⚠️ Document ${item.documentId} deleted remotely, skipping update');
          }
          return;
        }

        final remoteData = remoteDoc.data()!;
        final resolvedData = await _conflictResolver.resolveConflict(
          localData: item.data,
          remoteData: remoteData,
        );

        final dataWithVersion =
            _conflictResolver.incrementVersion(resolvedData);
        await docRef.update(dataWithVersion);
        break;

      case SyncOperation.delete:
        await docRef.delete();
        break;
    }
  }

  /// Finds the Hive key for a sync queue item by its ID
  dynamic _findItemKey(String itemId) {
    for (final key in _syncQueueBox.keys) {
      final item = _syncQueueBox.get(key);
      if (item?.id == itemId) {
        return key;
      }
    }
    return null;
  }

  /// Returns current queue size (for monitoring/debugging)
  int getQueueSize() {
    return _syncQueueBox.length;
  }

  /// Returns dead-letter queue size (for monitoring/debugging)
  int getDeadLetterQueueSize() {
    return _deadLetterBox.length;
  }

  /// Returns oldest item timestamp in queue (for metrics)
  DateTime? getOldestItemTimestamp() {
    final items = _syncQueueBox.values.toList();
    if (items.isEmpty) return null;

    return items
        .map((item) => item.queuedAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Returns comprehensive queue metrics
  SyncQueueMetrics getMetrics() {
    return SyncQueueMetrics(
      queueSize: getQueueSize(),
      deadLetterQueueSize: getDeadLetterQueueSize(),
      oldestItemTimestamp: getOldestItemTimestamp(),
    );
  }

  /// Returns all items in queue (for debugging/monitoring)
  List<SyncQueueItem> getAllQueueItems() {
    return _syncQueueBox.values.toList();
  }

  /// Returns all items in dead-letter queue
  List<SyncQueueItem> getAllDeadLetterItems() {
    return _deadLetterBox.values.toList();
  }

  /// Clears the entire sync queue (use with caution!)
  Future<void> clearQueue() async {
    await _syncQueueBox.clear();
    if (kDebugMode) {
      debugPrint('⚠️ Sync queue cleared manually');
    }
  }

  /// Clears the dead-letter queue
  Future<void> clearDeadLetterQueue() async {
    await _deadLetterBox.clear();
    if (kDebugMode) {
      debugPrint('ℹ️ Dead-letter queue cleared');
    }
  }

  /// Retries all items in dead-letter queue (manual recovery)
  Future<void> retryDeadLetterQueue() async {
    final items = _deadLetterBox.values.toList();

    if (items.isEmpty) {
      if (kDebugMode) {
        debugPrint('ℹ️ Dead-letter queue is empty');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('🔄 Retrying ${items.length} items from dead-letter queue...');
    }

    // Move all dead-letter items back to main queue with reset retry count
    for (final item in items) {
      final resetItem = SyncQueueItem(
        id: item.id,
        operation: item.operation,
        collection: item.collection,
        documentId: item.documentId,
        data: item.data,
        queuedAt: DateTime.now(), // New timestamp
        retryCount: 0, // Reset retry count
      );

      await _syncQueueBox.add(resetItem);
    }

    await _deadLetterBox.clear();

    if (kDebugMode) {
      debugPrint('✅ Dead-letter items moved back to queue');
    }
  }

  /// Generates a unique ID for sync queue items
  ///
  /// Format: sync-{timestamp}-{random}
  /// Example: sync-1708006845123-a3b4c5
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toRadixString(16);
    return 'sync-$timestamp-$random';
  }
}
