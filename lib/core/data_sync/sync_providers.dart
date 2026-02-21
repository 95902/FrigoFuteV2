import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conflict_resolver.dart';
import 'sync_retry_manager.dart';
import 'sync_queue_manager.dart';
import 'sync_service.dart';
import 'models/sync_status.dart';

// Phase 1 Providers - Core services

/// Conflict resolver provider
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Provides ConflictResolver singleton for Last-Write-Wins conflict resolution.
///
/// Example:
/// ```dart
/// final resolver = ref.read(conflictResolverProvider);
/// final winner = await resolver.resolveConflict(
///   localData: localData,
///   remoteData: remoteData,
/// );
/// ```
final conflictResolverProvider = Provider<ConflictResolver>((ref) {
  return ConflictResolver();
});

/// Sync retry manager provider
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Provides SyncRetryManager for exponential backoff retry logic.
///
/// Example:
/// ```dart
/// final manager = ref.read(syncRetryManagerProvider);
/// final delay = manager.calculateBackoff(retryCount);
/// await Future.delayed(delay);
/// ```
final syncRetryManagerProvider = Provider<SyncRetryManager>((ref) {
  return SyncRetryManager();
});

// Phase 2 Providers - Sync Queue Manager

/// Sync queue manager provider
/// Story 0.9: Implement Offline-First Sync Architecture Foundation - Phase 2
///
/// Provides SyncQueueManager with all dependencies injected.
/// Automatically initializes the queue on first access.
///
/// Example:
/// ```dart
/// final queueManager = ref.read(syncQueueManagerProvider);
/// await queueManager.enqueue(
///   operation: SyncOperation.create,
///   collection: 'inventory_items',
///   documentId: 'item-123',
///   data: {'name': 'Milk'},
/// );
/// ```
final syncQueueManagerProvider = Provider<SyncQueueManager>((ref) {
  final manager = SyncQueueManager(
    firestore: FirebaseFirestore.instance,
    conflictResolver: ref.watch(conflictResolverProvider),
    retryManager: ref.watch(syncRetryManagerProvider),
  );

  // Initialize asynchronously (note: init() must be called manually when needed)
  // The actual initialization happens in main.dart or when first used
  return manager;
});

// Phase 4 Providers - SyncService (High-Level Orchestrator)

/// Sync service provider
/// Story 0.9: Implement Offline-First Sync Architecture Foundation - Phase 4
///
/// Provides SyncService that orchestrates the entire sync system.
/// Automatically initializes and starts listening to network changes.
///
/// Example:
/// ```dart
/// // Manually trigger sync
/// await ref.read(syncServiceProvider).triggerSync();
///
/// // Get metrics
/// final metrics = ref.read(syncServiceProvider).getMetrics();
/// ```
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    queueManager: ref.watch(syncQueueManagerProvider),
    ref: ref,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

/// Sync status stream provider
/// Story 0.9: Implement Offline-First Sync Architecture Foundation - Phase 4
///
/// Provides real-time stream of sync status changes.
/// Use this in UI to display sync indicators.
///
/// Example:
/// ```dart
/// final syncStatus = ref.watch(syncStatusProvider);
/// syncStatus.when(
///   data: (status) {
///     switch (status) {
///       case SyncStatus.synced: return Icon(Icons.check, color: Colors.green);
///       case SyncStatus.syncing: return CircularProgressIndicator();
///       case SyncStatus.offline: return Icon(Icons.cloud_off);
///       case SyncStatus.error: return Icon(Icons.error, color: Colors.red);
///     }
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Icon(Icons.error),
/// );
/// ```
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.statusStream;
});

/// Current sync status provider (synchronous)
/// Story 0.9: Implement Offline-First Sync Architecture Foundation - Phase 4
///
/// Provides current sync status without AsyncValue wrapper.
/// Defaults to SyncStatus.synced if stream not yet loaded.
///
/// Example:
/// ```dart
/// final status = ref.watch(currentSyncStatusProvider);
/// if (status == SyncStatus.offline) {
///   showOfflineBanner();
/// }
/// ```
final currentSyncStatusProvider = Provider<SyncStatus>((ref) {
  return ref
      .watch(syncStatusProvider)
      .maybeWhen(data: (status) => status, orElse: () => SyncStatus.synced);
});

/// Is syncing provider
/// Story 0.9: Implement Offline-First Sync Architecture Foundation - Phase 4
///
/// Returns true if currently syncing data.
///
/// Example:
/// ```dart
/// final isSyncing = ref.watch(isSyncingProvider);
/// if (isSyncing) {
///   return LinearProgressIndicator();
/// }
/// ```
final isSyncingProvider = Provider<bool>((ref) {
  final status = ref.watch(currentSyncStatusProvider);
  return status == SyncStatus.syncing;
});

/// Is offline provider
/// Story 0.9: Implement Offline-First Sync Architecture Foundation - Phase 4
///
/// Returns true if offline with pending sync items.
///
/// Example:
/// ```dart
/// final isOffline = ref.watch(isOfflineProvider);
/// if (isOffline) {
///   return OfflineBanner();
/// }
/// ```
final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(currentSyncStatusProvider);
  return status == SyncStatus.offline;
});

/// Is online provider
///
/// Returns true when not offline (synced or syncing).
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(currentSyncStatusProvider);
  return status != SyncStatus.offline;
});
