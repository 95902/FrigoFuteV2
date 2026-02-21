import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/models/network_info.dart';
import '../network/network_monitor_service.dart';
import 'models/sync_status.dart';
import 'sync_queue_manager.dart';

/// Sync Service - High-Level Orchestrator
/// Story 0.9: Implement Offline-First Sync Architecture Foundation - Phase 4
///
/// Orchestrates the entire sync system by:
/// - Listening to network connectivity changes
/// - Automatically triggering sync when network becomes available
/// - Emitting SyncStatus updates for UI
/// - Managing SyncQueueManager initialization
///
/// Example:
/// ```dart
/// // Watch sync status in UI
/// final syncStatus = ref.watch(syncStatusProvider);
/// syncStatus.when(
///   data: (status) => SyncStatusIndicator(status: status),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => ErrorWidget(e),
/// );
///
/// // Manually trigger sync
/// ref.read(syncServiceProvider).triggerSync();
/// ```
class SyncService {
  final SyncQueueManager _queueManager;
  final Ref _ref;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  SyncStatus _currentStatus = SyncStatus.synced;
  bool _isProcessing = false;
  bool _isInitialized = false;

  /// Stream of sync status changes
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Current sync status (cached)
  SyncStatus get currentStatus => _currentStatus;

  SyncService({required SyncQueueManager queueManager, required Ref ref})
    : _queueManager = queueManager,
      _ref = ref {
    _initialize();
  }

  /// Initialize sync service
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize queue manager
      await _queueManager.init();
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ SyncService initialized');
      }

      // Start listening to network changes
      _listenToNetworkChanges();

      // Emit initial status
      _updateStatus(_determineCurrentStatus());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SyncService initialization failed: $e');
      }
      _updateStatus(SyncStatus.error);
    }
  }

  /// Listen to network connectivity changes and trigger sync
  void _listenToNetworkChanges() {
    _ref.listen<AsyncValue<NetworkInfo>>(networkMonitorProvider, (prev, next) {
      next.when(
        data: (networkInfo) async {
          if (kDebugMode) {
            debugPrint(
              '🔄 SyncService: Network changed - ${networkInfo.isConnected ? "Online" : "Offline"}',
            );
          }

          if (networkInfo.isConnected) {
            final queueSize = _queueManager.getQueueSize();
            if (queueSize > 0) {
              await _processQueue();
            } else {
              _updateStatus(SyncStatus.synced);
            }
          } else {
            final queueSize = _queueManager.getQueueSize();
            if (queueSize > 0) {
              _updateStatus(SyncStatus.offline);
            } else {
              _updateStatus(SyncStatus.synced);
            }
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          if (kDebugMode) {
            debugPrint('⚠️ SyncService: Network stream error');
          }
          _updateStatus(SyncStatus.error);
        },
      );
    });
  }

  /// Process sync queue
  Future<void> _processQueue() async {
    if (_isProcessing) {
      if (kDebugMode) {
        debugPrint('ℹ️ SyncService: Already processing queue, skipping...');
      }
      return;
    }

    _isProcessing = true;
    _updateStatus(SyncStatus.syncing);

    try {
      await _queueManager.processSyncQueue();

      // Check if queue is now empty
      final queueSize = _queueManager.getQueueSize();
      if (queueSize == 0) {
        _updateStatus(SyncStatus.synced);
      } else {
        // Still items in queue (partial sync or new items added)
        _updateStatus(SyncStatus.syncing);
      }

      if (kDebugMode) {
        debugPrint('✅ SyncService: Queue processing completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SyncService: Queue processing failed: $e');
      }
      _updateStatus(SyncStatus.error);
    } finally {
      _isProcessing = false;
    }
  }

  /// Manually trigger sync (user-initiated)
  ///
  /// Useful for pull-to-refresh or manual sync button.
  ///
  /// Example:
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () => ref.read(syncServiceProvider).triggerSync(),
  ///   child: Text('Sync Now'),
  /// )
  /// ```
  Future<void> triggerSync() async {
    if (kDebugMode) {
      debugPrint('🔄 SyncService: Manual sync triggered');
    }

    // Check network connectivity
    final networkInfo = _ref.read(networkMonitorProvider).value;
    if (networkInfo == null || !networkInfo.isConnected) {
      if (kDebugMode) {
        debugPrint('⚠️ SyncService: Cannot sync - offline');
      }
      _updateStatus(SyncStatus.offline);
      throw Exception('Cannot sync while offline');
    }

    await _processQueue();
  }

  /// Determine current status based on queue state and network
  SyncStatus _determineCurrentStatus() {
    final queueSize = _queueManager.getQueueSize();
    final networkInfo = _ref.read(networkMonitorProvider).value;

    if (queueSize == 0) {
      return SyncStatus.synced;
    }

    if (networkInfo == null || !networkInfo.isConnected) {
      return SyncStatus.offline;
    }

    return SyncStatus.syncing;
  }

  /// Update status and emit to stream
  void _updateStatus(SyncStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);

      if (kDebugMode) {
        debugPrint('📊 SyncService: Status changed to ${newStatus.name}');
      }
    }
  }

  /// Get sync queue metrics
  ///
  /// Returns metrics about current queue state.
  ///
  /// Example:
  /// ```dart
  /// final metrics = ref.read(syncServiceProvider).getMetrics();
  /// print('Pending: ${metrics.queueSize}');
  /// ```
  dynamic getMetrics() {
    return _queueManager.getMetrics();
  }

  /// Manually retry dead-letter queue items
  ///
  /// Moves all failed items back to main queue for retry.
  ///
  /// Example:
  /// ```dart
  /// await ref.read(syncServiceProvider).retryFailedItems();
  /// ```
  Future<void> retryFailedItems() async {
    if (kDebugMode) {
      debugPrint('🔄 SyncService: Retrying failed items');
    }

    await _queueManager.retryDeadLetterQueue();

    // Trigger sync if online
    final networkInfo = _ref.read(networkMonitorProvider).value;
    if (networkInfo != null && networkInfo.isConnected) {
      await _processQueue();
    }
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();

    if (kDebugMode) {
      debugPrint('🔄 SyncService disposed');
    }
  }
}
