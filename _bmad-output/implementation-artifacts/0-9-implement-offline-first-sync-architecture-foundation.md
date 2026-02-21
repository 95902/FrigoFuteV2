# Story 0.9: Implement Offline-First Sync Architecture Foundation

## 📋 Story Metadata

- **Story ID**: 0.9
- **Epic**: Epic 0 - Initial App Setup for First User
- **Title**: Implement Offline-First Sync Architecture Foundation
- **Story Key**: 0-9-implement-offline-first-sync-architecture-foundation
- **Status**: ready-for-dev
- **Complexity**: 13 (XL - Critical architectural foundation)
- **Priority**: P0 (Blocker for all features)
- **Estimated Effort**: 5-8 days
- **Dependencies**:
  - Story 0.1 (Flutter project structure)
  - Story 0.2 (Firebase services)
  - Story 0.3 (Hive local database)
  - Story 0.4 (Riverpod state management)
- **Tags**: `architecture`, `offline-first`, `sync`, `foundation`, `critical-path`

---

## 📖 User Story

**As a** utilisateur,
**I want** my changes to be saved instantly even offline and synchronized automatically when I reconnect,
**So that** I never lose my data and can work without worrying about connectivity.

---

## ✅ Acceptance Criteria

### AC1: Offline-First Pattern Implementation
**Given** the app must support offline-first with bidirectional sync
**When** the sync architecture pattern (Optimistic UI + background sync) is implemented
**Then** users can perform all CRUD operations offline
**And** changes are saved immediately to local Hive storage
**And** UI updates instantly with optimistic state

### AC2: Sync Queue Management
**Given** a user performs mutations while offline
**When** the operation is executed
**Then** the mutation is queued in `sync_queue_box` (Hive)
**And** the queue item contains: operation type, collection, data, timestamp, retry count
**And** the queue is persistent across app restarts

### AC3: Automatic Network Detection & Sync Trigger
**Given** the user has queued operations while offline
**When** network connectivity is restored
**Then** the sync queue processing is triggered automatically within 1 second
**And** queued operations are processed in FIFO order
**And** successful syncs remove items from the queue

### AC4: Conflict Resolution Strategy
**Given** concurrent modifications occur on local and remote
**When** a conflict is detected during sync
**Then** Last-Write-Wins (LWW) conflict resolution is applied
**And** the server timestamp (`updatedAt`) is the authoritative source
**And** the winning version is applied to both Hive and Firestore

### AC5: Sync Status Visibility
**Given** the app is syncing data
**When** the user is viewing any screen
**Then** a sync status indicator is displayed (app bar badge)
**And** the indicator shows: `synced` (green), `syncing` (orange), `offline` (gray), `error` (red)
**And** an offline banner appears when network is unavailable

### AC6: Error Handling & Retry Logic
**Given** a sync operation fails (network error, quota exceeded, validation error)
**When** the failure is detected
**Then** the operation is retried with exponential backoff (1s → 2s → 4s → 8s)
**And** a maximum of 3 retry attempts are performed
**And** after 3 failures, the item is moved to a dead-letter queue
**And** the error is logged to Firebase Crashlytics
**And** the user is notified via toast/snackbar

### AC7: Bidirectional Sync (Hive ↔ Firestore)
**Given** multiple devices share the same user account
**When** Device A makes changes and syncs to Firestore
**Then** Device B detects Firestore changes (Firestore snapshot listeners)
**And** Device B updates its local Hive storage
**And** the UI reflects the changes in real-time

### AC8: Performance Targets
**Given** performance requirements (NFR-P5, NFR-R5)
**When** offline mutations are performed
**Then** local writes to Hive complete in < 100ms
**And** sync queue processing triggers in < 1s after network restoration
**And** single item sync to Firestore completes in < 5s
**And** batch sync of 100 items completes in < 30s
**And** sync processing does not block the UI thread

---

## 🏗️ Technical Specifications

### 1. Sync Architecture Pattern

**Pattern**: Optimistic UI + Background Sync (Bidirectional)

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interaction                       │
│              (Add/Update/Delete Product)                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
           ┌─────────────────────┐
           │  Optimistic Update  │
           │  (Write to Hive)    │◄──── Instant UI feedback
           └──────────┬──────────┘
                      │
                      ▼
           ┌─────────────────────┐
           │  Queue in           │
           │  sync_queue_box     │
           └──────────┬──────────┘
                      │
         ┌────────────┴──────────────┐
         │ Network Available?        │
         └────────┬──────────────────┘
                  │
        ┌─────────┴──────────┐
        │ YES                │ NO
        ▼                    ▼
┌───────────────┐    ┌──────────────────┐
│ Process Queue │    │ Wait for Network │
│ → Firestore   │    │ (Stay in Queue)  │
└───────┬───────┘    └──────────────────┘
        │
        ▼
┌───────────────┐
│ Sync Success? │
└───────┬───────┘
        │
   ┌────┴─────┐
   │ YES      │ NO
   ▼          ▼
┌─────┐  ┌──────────────┐
│Remove│  │Retry (3x max)│
│Queue │  │Exp. Backoff  │
└─────┘  └──────────────┘
```

### 2. Sync Queue Architecture

#### SyncQueueItem Model

**File**: `lib/core/data_sync/models/sync_queue_item.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_queue_item.freezed.dart';
part 'sync_queue_item.g.dart';

@freezed
class SyncQueueItem with _$SyncQueueItem {
  const factory SyncQueueItem({
    required String id,                    // UUID v4
    required SyncOperation operation,      // CREATE, UPDATE, DELETE
    required String collection,            // 'inventory_items', 'nutrition_tracking', etc.
    required String documentId,            // Firestore document ID
    required Map<String, dynamic> data,    // Payload to sync
    required DateTime queuedAt,            // When queued (local time)
    @Default(0) int retryCount,            // Current retry attempt (0-3)
    DateTime? lastAttemptAt,               // Last sync attempt timestamp
    String? errorMessage,                  // Last error message (for debugging)
  }) = _SyncQueueItem;

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueItemFromJson(json);
}

enum SyncOperation {
  create,   // Add new document to Firestore
  update,   // Update existing document
  delete,   // Delete document from Firestore
}
```

#### Hive TypeAdapter for SyncQueueItem

**File**: `lib/core/data_sync/models/sync_queue_item.adapter.dart`

```dart
import 'package:hive/hive.dart';
import 'sync_queue_item.dart';

class SyncQueueItemAdapter extends TypeAdapter<SyncQueueItem> {
  @override
  final int typeId = 8; // Unique typeId for SyncQueueItem

  @override
  SyncQueueItem read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return SyncQueueItem.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, SyncQueueItem obj) {
    writer.writeMap(obj.toJson());
  }
}
```

**Register in HiveService**:

```dart
// lib/core/services/hive_service.dart
static Future<void> init() async {
  await Hive.initFlutter();

  // Existing adapters...
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(RecipeModelAdapter());
  // ...

  // NEW: Register SyncQueueItem adapter
  Hive.registerAdapter(SyncQueueItemAdapter());

  // Open sync_queue_box (non-encrypted for performance)
  await Hive.openBox<SyncQueueItem>('sync_queue_box');
}
```

### 3. Collections to Sync

**Firestore Collections**:

```dart
// lib/core/data_sync/sync_collections.dart

class SyncCollections {
  // User-scoped collections (require userId)
  static const String inventoryItems = 'inventory_items';
  static const String nutritionTracking = 'nutrition_tracking';
  static const String mealPlans = 'meal_plans';
  static const String healthProfiles = 'health_profiles';
  static const String nutritionData = 'nutrition_data';

  // Global read-only collections (synced down to Hive)
  static const String recipes = 'recipes';
  static const String productsCatalog = 'products_catalog';

  // Path helper
  static String userCollection(String userId, String collection) =>
      'users/$userId/$collection';
}
```

**Example Firestore Document Structure** (with versioning):

```json
// users/abc123/inventory_items/item-uuid-001
{
  "id": "item-uuid-001",
  "name": "Milk",
  "category": "dairy",
  "quantity": 1,
  "unit": "L",
  "expirationDate": "2026-02-20T00:00:00Z",
  "storageLocation": "fridge",
  "status": "fresh",
  "version": 3,                    // ← Incremental version (for conflict detection)
  "updatedAt": "2026-02-15T14:23:45Z",  // ← Server timestamp (authoritative)
  "createdAt": "2026-02-10T09:12:30Z"
}
```

### 4. Network Detection & Connectivity Monitoring

#### NetworkInfo Model

**File**: `lib/core/network/models/network_info.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_info.freezed.dart';

@freezed
class NetworkInfo with _$NetworkInfo {
  const factory NetworkInfo({
    required bool isConnected,
    required NetworkType type,
    required DateTime lastChangedAt,
  }) = _NetworkInfo;
}

enum NetworkType {
  wifi,
  mobile,
  ethernet,
  none,
}
```

#### NetworkMonitorService

**File**: `lib/core/network/network_monitor_service.dart`

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'models/network_info.dart';

part 'network_monitor_service.g.dart';

@riverpod
class NetworkMonitor extends _$NetworkMonitor {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  Stream<NetworkInfo> build() async* {
    // Initial check
    final results = await _connectivity.checkConnectivity();
    yield _mapToNetworkInfo(results);

    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      state = AsyncData(_mapToNetworkInfo(results));
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  NetworkInfo _mapToNetworkInfo(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkInfo(
        isConnected: false,
        type: NetworkType.none,
        lastChangedAt: DateTime.now(),
      );
    }

    NetworkType type = NetworkType.mobile;
    if (results.contains(ConnectivityResult.wifi)) {
      type = NetworkType.wifi;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      type = NetworkType.ethernet;
    }

    return NetworkInfo(
      isConnected: true,
      type: type,
      lastChangedAt: DateTime.now(),
    );
  }
}

// Convenience provider for isConnected boolean
@riverpod
bool isNetworkConnected(IsNetworkConnectedRef ref) {
  final networkState = ref.watch(networkMonitorProvider);
  return networkState.maybeWhen(
    data: (info) => info.isConnected,
    orElse: () => false,
  );
}
```

**Add dependency**:

```yaml
# pubspec.yaml
dependencies:
  connectivity_plus: ^6.2.0
```

### 5. Conflict Resolution Strategy

#### ConflictResolver Service

**File**: `lib/core/data_sync/conflict_resolver.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Last-Write-Wins (LWW) conflict resolution strategy.
///
/// The server timestamp (`updatedAt`) is the authoritative source.
/// Whichever version has the latest timestamp wins the conflict.
class ConflictResolver {
  /// Resolves conflict between local and remote document versions.
  ///
  /// Returns the winning version (the one with the latest updatedAt timestamp).
  Future<Map<String, dynamic>> resolveConflict({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) async {
    final localUpdatedAt = _parseTimestamp(localData['updatedAt']);
    final remoteUpdatedAt = _parseTimestamp(remoteData['updatedAt']);

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      // Server version is newer → use remote (will be written to Hive)
      return remoteData;
    } else {
      // Local version is newer → keep local (will be pushed to Firestore)
      return localData;
    }
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      throw ArgumentError('Invalid timestamp format: $timestamp');
    }
  }

  /// Increments version field for optimistic concurrency control.
  Map<String, dynamic> incrementVersion(Map<String, dynamic> data) {
    final currentVersion = data['version'] as int? ?? 0;
    return {
      ...data,
      'version': currentVersion + 1,
      'updatedAt': FieldValue.serverTimestamp(), // Server-generated timestamp
    };
  }
}
```

#### Conflict Scenarios

| Scenario | Local State | Remote State | Resolution | Action |
|----------|-------------|--------------|------------|--------|
| **Concurrent Edit** | Updated 10:00 | Updated 10:05 | Remote wins (LWW) | Overwrite Hive with remote data |
| **Offline Add + Online Add** | New item A (UUID-1) | New item B (UUID-2) | Both kept | No conflict (different IDs) |
| **Offline Update + Online Delete** | Updated item | Deleted item | Delete wins | Remove from Hive |
| **Offline Delete + Online Update** | Deleted item | Updated item | Delete wins | Remove from Firestore |
| **Network Partition** | Multiple updates offline | Remote updated meanwhile | Last-Write-Wins | Use latest `updatedAt` |

### 6. Retry Mechanism & Exponential Backoff

#### SyncRetryManager

**File**: `lib/core/data_sync/sync_retry_manager.dart`

```dart
import 'dart:math';

class SyncRetryManager {
  static const int maxRetries = 3;
  static const int baseDelaySeconds = 1;
  static const int maxDelaySeconds = 8;

  /// Calculates exponential backoff delay for retry attempt.
  ///
  /// Formula: delay = min(baseDelay * 2^retryCount, maxDelay)
  ///
  /// Examples:
  /// - Retry 1: 1s
  /// - Retry 2: 2s
  /// - Retry 3: 4s
  /// - Retry 4+: 8s (capped)
  Duration calculateBackoff(int retryCount) {
    final delaySeconds = min(
      baseDelaySeconds * pow(2, retryCount).toInt(),
      maxDelaySeconds,
    );
    return Duration(seconds: delaySeconds);
  }

  /// Checks if item should be retried.
  bool shouldRetry(int retryCount) {
    return retryCount < maxRetries;
  }

  /// Executes an async operation with retry logic.
  ///
  /// Returns the result if successful, or throws after max retries.
  Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = maxRetries,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxAttempts) {
          rethrow; // Max retries exceeded
        }

        final delay = calculateBackoff(attempt);
        await Future.delayed(delay);
      }
    }
  }
}
```

### 7. SyncQueueManager Service

**File**: `lib/core/data_sync/sync_queue_manager.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../exceptions/sync_exceptions.dart';
import '../logging/logger.dart';
import 'conflict_resolver.dart';
import 'models/sync_queue_item.dart';
import 'sync_retry_manager.dart';

class SyncQueueManager {
  final FirebaseFirestore _firestore;
  final ConflictResolver _conflictResolver;
  final SyncRetryManager _retryManager;
  final Logger _logger;

  late Box<SyncQueueItem> _syncQueueBox;
  late Box<SyncQueueItem> _deadLetterBox;

  SyncQueueManager({
    required FirebaseFirestore firestore,
    required ConflictResolver conflictResolver,
    required SyncRetryManager retryManager,
    required Logger logger,
  })  : _firestore = firestore,
        _conflictResolver = conflictResolver,
        _retryManager = retryManager,
        _logger = logger;

  /// Initialize sync queue boxes.
  Future<void> init() async {
    _syncQueueBox = Hive.box<SyncQueueItem>('sync_queue_box');

    // Dead-letter queue for items that exceed max retries
    if (!Hive.isBoxOpen('dead_letter_queue_box')) {
      await Hive.openBox<SyncQueueItem>('dead_letter_queue_box');
    }
    _deadLetterBox = Hive.box<SyncQueueItem>('dead_letter_queue_box');
  }

  /// Enqueues a sync operation (called when offline or proactively).
  Future<void> enqueue({
    required SyncOperation operation,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final item = SyncQueueItem(
      id: const Uuid().v4(),
      operation: operation,
      collection: collection,
      documentId: documentId,
      data: data,
      queuedAt: DateTime.now(),
    );

    await _syncQueueBox.add(item);
    _logger.info('Enqueued sync item: ${item.id} (${item.operation})');
  }

  /// Processes the entire sync queue (FIFO order).
  ///
  /// Called automatically when network is restored.
  Future<void> processSyncQueue() async {
    final items = _syncQueueBox.values.toList();

    if (items.isEmpty) {
      _logger.info('Sync queue is empty, nothing to process.');
      return;
    }

    _logger.info('Processing ${items.length} items in sync queue...');

    for (final item in items) {
      await _processSingleItem(item);
    }

    _logger.info('Sync queue processing completed.');
  }

  /// Processes a single sync queue item with retry logic.
  Future<void> _processSingleItem(SyncQueueItem item) async {
    try {
      // Execute sync operation
      await _syncToFirestore(item);

      // Success: remove from queue
      final key = _syncQueueBox.keys.firstWhere(
        (k) => (_syncQueueBox.get(k) as SyncQueueItem).id == item.id,
      );
      await _syncQueueBox.delete(key);

      _logger.info('Sync successful: ${item.id}');
    } catch (e, stackTrace) {
      _logger.error('Sync failed: ${item.id}', error: e, stackTrace: stackTrace);

      // Update retry count
      final updated = item.copyWith(
        retryCount: item.retryCount + 1,
        lastAttemptAt: DateTime.now(),
        errorMessage: e.toString(),
      );

      if (_retryManager.shouldRetry(updated.retryCount)) {
        // Retry with exponential backoff
        final delay = _retryManager.calculateBackoff(updated.retryCount);
        _logger.info('Retrying ${item.id} in ${delay.inSeconds}s (attempt ${updated.retryCount})');

        await Future.delayed(delay);

        // Update item in queue
        final key = _syncQueueBox.keys.firstWhere(
          (k) => (_syncQueueBox.get(k) as SyncQueueItem).id == item.id,
        );
        await _syncQueueBox.put(key, updated);
      } else {
        // Max retries exceeded: move to dead-letter queue
        _logger.error('Max retries exceeded for ${item.id}, moving to dead-letter queue');

        await _deadLetterBox.add(updated);

        final key = _syncQueueBox.keys.firstWhere(
          (k) => (_syncQueueBox.get(k) as SyncQueueItem).id == item.id,
        );
        await _syncQueueBox.delete(key);

        // TODO: Notify user of permanent sync failure
      }
    }
  }

  /// Syncs a single item to Firestore based on operation type.
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
          _logger.warning('Document ${item.documentId} deleted remotely, skipping update');
          return;
        }

        final remoteData = remoteDoc.data()!;
        final resolvedData = await _conflictResolver.resolveConflict(
          localData: item.data,
          remoteData: remoteData,
        );

        final dataWithVersion = _conflictResolver.incrementVersion(resolvedData);
        await docRef.update(dataWithVersion);
        break;

      case SyncOperation.delete:
        await docRef.delete();
        break;
    }
  }

  /// Returns current queue size (for monitoring/debugging).
  int getQueueSize() {
    return _syncQueueBox.length;
  }

  /// Returns dead-letter queue size (for monitoring/debugging).
  int getDeadLetterQueueSize() {
    return _deadLetterBox.length;
  }

  /// Clears the entire sync queue (use with caution!).
  Future<void> clearQueue() async {
    await _syncQueueBox.clear();
    _logger.warning('Sync queue cleared manually');
  }

  /// Clears the dead-letter queue.
  Future<void> clearDeadLetterQueue() async {
    await _deadLetterBox.clear();
    _logger.info('Dead-letter queue cleared');
  }
}
```

### 8. SyncService (High-Level Orchestrator)

**File**: `lib/core/data_sync/sync_service.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/network_monitor_service.dart';
import 'models/sync_status.dart';
import 'sync_queue_manager.dart';

part 'sync_service.g.dart';

@riverpod
class SyncService extends _$SyncService {
  late SyncQueueManager _queueManager;

  @override
  Stream<SyncStatus> build() async* {
    _queueManager = ref.read(syncQueueManagerProvider);

    // Listen to network changes
    final networkStream = ref.watch(networkMonitorProvider.stream);

    await for (final networkInfo in networkStream) {
      if (networkInfo.isConnected) {
        // Network available → trigger sync
        yield SyncStatus.syncing;

        try {
          await _queueManager.processSyncQueue();

          final queueSize = _queueManager.getQueueSize();
          if (queueSize == 0) {
            yield SyncStatus.synced;
          } else {
            // Still items in queue (partial sync)
            yield SyncStatus.syncing;
          }
        } catch (e) {
          yield SyncStatus.error;
        }
      } else {
        // Network unavailable
        final queueSize = _queueManager.getQueueSize();
        if (queueSize > 0) {
          yield SyncStatus.offline;
        } else {
          yield SyncStatus.synced;
        }
      }
    }
  }

  /// Manually triggers sync (user-initiated).
  Future<void> triggerSync() async {
    state = const AsyncData(SyncStatus.syncing);

    try {
      await _queueManager.processSyncQueue();
      state = const AsyncData(SyncStatus.synced);
    } catch (e) {
      state = const AsyncData(SyncStatus.error);
      rethrow;
    }
  }
}

// Providers
@riverpod
SyncQueueManager syncQueueManager(SyncQueueManagerRef ref) {
  // Dependencies injected via providers
  return SyncQueueManager(
    firestore: ref.read(firestoreProvider),
    conflictResolver: ref.read(conflictResolverProvider),
    retryManager: ref.read(syncRetryManagerProvider),
    logger: ref.read(loggerProvider),
  );
}

@riverpod
ConflictResolver conflictResolver(ConflictResolverRef ref) {
  return ConflictResolver();
}

@riverpod
SyncRetryManager syncRetryManager(SyncRetryManagerRef ref) {
  return SyncRetryManager();
}
```

#### SyncStatus Model

**File**: `lib/core/data_sync/models/sync_status.dart`

```dart
enum SyncStatus {
  synced,   // All changes synced successfully (green indicator)
  syncing,  // Currently syncing data (orange indicator)
  offline,  // No network, changes queued locally (gray indicator)
  error,    // Sync error occurred (red indicator)
}
```

### 9. Repository Integration (Example: Inventory)

**File**: `lib/features/inventory/data/repositories/inventory_repository_impl.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/data_sync/models/sync_queue_item.dart';
import '../../../../core/data_sync/sync_queue_manager.dart';
import '../../../../core/network/network_monitor_service.dart';
import '../../domain/entities/product.dart';
import '../datasources/inventory_local_datasource.dart';
import '../datasources/inventory_remote_datasource.dart';
import '../models/product_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;
  final InventoryRemoteDataSource remoteDataSource;
  final SyncQueueManager syncQueueManager;
  final NetworkMonitor networkMonitor;

  InventoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.syncQueueManager,
    required this.networkMonitor,
  });

  @override
  Future<void> addProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);

    // 1. Write to local Hive immediately (optimistic update)
    await localDataSource.addProduct(productModel);

    // 2. Enqueue sync operation
    await syncQueueManager.enqueue(
      operation: SyncOperation.create,
      collection: 'users/${product.userId}/inventory_items',
      documentId: product.id,
      data: productModel.toJson(),
    );

    // 3. If online, trigger immediate sync (optional, queue will process anyway)
    final isConnected = networkMonitor.state.value?.isConnected ?? false;
    if (isConnected) {
      syncQueueManager.processSyncQueue(); // Fire-and-forget
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);

    // 1. Update local Hive
    await localDataSource.updateProduct(productModel);

    // 2. Enqueue sync operation
    await syncQueueManager.enqueue(
      operation: SyncOperation.update,
      collection: 'users/${product.userId}/inventory_items',
      documentId: product.id,
      data: productModel.toJson(),
    );
  }

  @override
  Future<void> deleteProduct(String productId, String userId) async {
    // 1. Delete from local Hive
    await localDataSource.deleteProduct(productId);

    // 2. Enqueue sync operation
    await syncQueueManager.enqueue(
      operation: SyncOperation.delete,
      collection: 'users/$userId/inventory_items',
      documentId: productId,
      data: {}, // No data needed for delete
    );
  }

  @override
  Stream<List<Product>> watchInventory(String userId) {
    // Return local Hive data stream (real-time updates)
    return localDataSource.watchAllProducts().map((models) =>
        models.map((m) => m.toEntity()).toList());
  }
}
```

### 10. UI Integration

#### Sync Status Indicator Widget

**File**: `lib/core/widgets/sync_status_indicator.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sync/models/sync_status.dart';
import '../data_sync/sync_service.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncServiceProvider);

    return syncStatusAsync.when(
      data: (syncStatus) {
        final color = _getColorForStatus(syncStatus);
        final icon = _getIconForStatus(syncStatus);
        final tooltip = _getTooltipForStatus(syncStatus);

        return Tooltip(
          message: tooltip,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: syncStatus == SyncStatus.syncing
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(icon, size: 8, color: Colors.white),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => const Icon(Icons.error, color: Colors.red, size: 12),
    );
  }

  Color _getColorForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.orange;
      case SyncStatus.offline:
        return Colors.grey;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  IconData _getIconForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icons.check;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.offline:
        return Icons.cloud_off;
      case SyncStatus.error:
        return Icons.error;
    }
  }

  String _getTooltipForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Toutes vos données sont synchronisées';
      case SyncStatus.syncing:
        return 'Synchronisation en cours...';
      case SyncStatus.offline:
        return 'Hors ligne - Les modifications seront synchronisées à la reconnexion';
      case SyncStatus.error:
        return 'Erreur de synchronisation';
    }
  }
}
```

#### Offline Banner Widget

**File**: `lib/core/widgets/offline_banner.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_monitor_service.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkInfoAsync = ref.watch(networkMonitorProvider);

    return networkInfoAsync.when(
      data: (networkInfo) {
        if (networkInfo.isConnected) {
          return const SizedBox.shrink(); // Hide banner when online
        }

        return MaterialBanner(
          backgroundColor: Colors.orange.shade100,
          leading: const Icon(Icons.cloud_off, color: Colors.orange),
          content: const Text(
            'Vous êtes hors ligne. Vos modifications seront synchronisées automatiquement dès la reconnexion.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Dismiss banner (optional)
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
```

#### App Bar Integration

**File**: `lib/core/widgets/app_scaffold.dart`

```dart
import 'package:flutter/material.dart';
import 'offline_banner.dart';
import 'sync_status_indicator.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: SyncStatusIndicator()),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(), // Shows when offline
          Expanded(child: body),
        ],
      ),
    );
  }
}
```

### 11. Firestore Security Rules (with Versioning)

**File**: `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User-scoped collections
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;

      // Inventory items with version-based conflict detection
      match /inventory_items/{itemId} {
        allow read: if request.auth.uid == userId;

        // Create: no version check needed
        allow create: if request.auth.uid == userId
                      && request.resource.data.version == 1;

        // Update: version must increment by 1 (optimistic concurrency)
        allow update: if request.auth.uid == userId
                      && request.resource.data.version == resource.data.version + 1;

        // Delete: no version check needed
        allow delete: if request.auth.uid == userId;
      }

      // Nutrition tracking (similar rules)
      match /nutrition_tracking/{entryId} {
        allow read, write: if request.auth.uid == userId;
      }

      // Meal plans
      match /meal_plans/{planId} {
        allow read, write: if request.auth.uid == userId;
      }

      // Health profiles (sensitive data)
      match /health_profiles/{profileId} {
        allow read, write: if request.auth.uid == userId;
      }

      // Nutrition data (sensitive data)
      match /nutrition_data/{dataId} {
        allow read, write: if request.auth.uid == userId;
      }
    }

    // Global read-only collections
    match /recipes/{recipeId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin-only via Cloud Functions
    }

    match /products_catalog/{productId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin-only via Cloud Functions
    }
  }
}
```

### 12. Sync Exceptions Hierarchy

**File**: `lib/core/exceptions/sync_exceptions.dart`

```dart
/// Base exception for all sync-related errors.
abstract class SyncException implements Exception {
  final String message;
  const SyncException(this.message);

  @override
  String toString() => 'SyncException: $message';
}

/// Network connectivity error during sync.
class SyncNetworkException extends SyncException {
  const SyncNetworkException(super.message);

  @override
  String toString() => 'SyncNetworkException: $message';
}

/// Conflict detected during sync.
class SyncConflictException extends SyncException {
  final String itemId;
  final dynamic localValue;
  final dynamic remoteValue;

  const SyncConflictException(
    super.message,
    this.itemId,
    this.localValue,
    this.remoteValue,
  );

  @override
  String toString() =>
      'SyncConflictException: $message (itemId: $itemId)';
}

/// Firestore quota exceeded during sync.
class SyncQuotaException extends SyncException {
  const SyncQuotaException(super.message);

  @override
  String toString() => 'SyncQuotaException: $message';
}

/// Validation error during sync (data integrity).
class SyncValidationException extends SyncException {
  final String field;

  const SyncValidationException(super.message, this.field);

  @override
  String toString() => 'SyncValidationException: $message (field: $field)';
}

/// Unknown sync error.
class SyncUnknownException extends SyncException {
  final dynamic originalError;

  const SyncUnknownException(super.message, this.originalError);

  @override
  String toString() =>
      'SyncUnknownException: $message (original: $originalError)';
}
```

### 13. Logging & Monitoring

#### Logger Integration

**File**: `lib/core/logging/logger.dart`

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart' as log;

class Logger {
  final log.Logger _logger = log.Logger(
    printer: log.PrettyPrinter(methodCount: 0),
  );
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  void info(String message) {
    _logger.i(message);
  }

  void warning(String message) {
    _logger.w(message);
  }

  void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Log to Crashlytics for production monitoring
    _crashlytics.log(message);
    if (error != null) {
      _crashlytics.recordError(error, stackTrace, reason: message);
    }
  }

  void debug(String message) {
    _logger.d(message);
  }
}
```

#### Sync Metrics Tracking

**File**: `lib/core/data_sync/sync_metrics.dart`

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class SyncMetrics {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void trackSyncSuccess({
    required String collection,
    required int itemCount,
    required Duration duration,
  }) {
    _analytics.logEvent(
      name: 'sync_success',
      parameters: {
        'collection': collection,
        'item_count': itemCount,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }

  void trackSyncFailure({
    required String collection,
    required String errorType,
    required int retryCount,
  }) {
    _analytics.logEvent(
      name: 'sync_failure',
      parameters: {
        'collection': collection,
        'error_type': errorType,
        'retry_count': retryCount,
      },
    );
  }

  void trackQueueSize(int size) {
    _analytics.logEvent(
      name: 'sync_queue_size',
      parameters: {
        'size': size,
      },
    );
  }
}
```

### 14. Performance Optimizations

#### Batch Write to Firestore

**File**: `lib/core/data_sync/sync_queue_manager.dart` (enhanced)

```dart
// Enhanced version with batch writes

/// Processes sync queue in batches for better performance.
Future<void> processSyncQueueBatched() async {
  final items = _syncQueueBox.values.toList();

  if (items.isEmpty) {
    _logger.info('Sync queue is empty, nothing to process.');
    return;
  }

  // Process in batches of 20 items
  const batchSize = 20;
  for (var i = 0; i < items.length; i += batchSize) {
    final batch = items.skip(i).take(batchSize).toList();
    await _processBatch(batch);
  }
}

Future<void> _processBatch(List<SyncQueueItem> items) async {
  final batch = _firestore.batch();

  for (final item in items) {
    final docRef = _firestore.doc('${item.collection}/${item.documentId}');

    switch (item.operation) {
      case SyncOperation.create:
      case SyncOperation.update:
        batch.set(docRef, item.data, SetOptions(merge: true));
        break;
      case SyncOperation.delete:
        batch.delete(docRef);
        break;
    }
  }

  try {
    await batch.commit();

    // Remove all items from queue
    for (final item in items) {
      final key = _syncQueueBox.keys.firstWhere(
        (k) => (_syncQueueBox.get(k) as SyncQueueItem).id == item.id,
      );
      await _syncQueueBox.delete(key);
    }

    _logger.info('Batch sync successful: ${items.length} items');
  } catch (e) {
    _logger.error('Batch sync failed', error: e);
    // Retry items individually (fallback)
    for (final item in items) {
      await _processSingleItem(item);
    }
  }
}
```

---

## 📝 Implementation Tasks

### Phase 1: Core Models & Services (Days 1-2)

- [ ] **Task 1.1**: Create `SyncQueueItem` freezed model with `SyncOperation` enum
- [ ] **Task 1.2**: Create `SyncQueueItemAdapter` Hive TypeAdapter (typeId: 8)
- [ ] **Task 1.3**: Register adapter in `HiveService.init()` and open `sync_queue_box`
- [ ] **Task 1.4**: Create `NetworkInfo` model and `NetworkType` enum
- [ ] **Task 1.5**: Implement `NetworkMonitorService` with `connectivity_plus`
- [ ] **Task 1.6**: Create `SyncStatus` enum (synced, syncing, offline, error)
- [ ] **Task 1.7**: Create sync exception hierarchy (`SyncException` and subtypes)
- [ ] **Task 1.8**: Add `connectivity_plus: ^6.2.0` to `pubspec.yaml`

### Phase 2: Conflict Resolution & Retry Logic (Day 2-3)

- [ ] **Task 2.1**: Implement `ConflictResolver` with Last-Write-Wins strategy
- [ ] **Task 2.2**: Implement `resolveConflict()` method comparing timestamps
- [ ] **Task 2.3**: Implement `incrementVersion()` method for optimistic concurrency
- [ ] **Task 2.4**: Implement `SyncRetryManager` with exponential backoff
- [ ] **Task 2.5**: Write unit tests for `calculateBackoff()` (1s, 2s, 4s, 8s)
- [ ] **Task 2.6**: Write unit tests for `executeWithRetry()` with mock failures

### Phase 3: Sync Queue Manager (Days 3-4)

- [ ] **Task 3.1**: Implement `SyncQueueManager.init()` opening queue boxes
- [ ] **Task 3.2**: Implement `enqueue()` method adding items to queue
- [ ] **Task 3.3**: Implement `processSyncQueue()` iterating FIFO order
- [ ] **Task 3.4**: Implement `_processSingleItem()` with retry logic
- [ ] **Task 3.5**: Implement `_syncToFirestore()` handling CREATE/UPDATE/DELETE
- [ ] **Task 3.6**: Implement dead-letter queue logic for max retries exceeded
- [ ] **Task 3.7**: Create `dead_letter_queue_box` in HiveService
- [ ] **Task 3.8**: Implement `getQueueSize()` and `getDeadLetterQueueSize()` metrics
- [ ] **Task 3.9**: Add batch processing optimization (`processSyncQueueBatched()`)

### Phase 4: High-Level Sync Service (Day 4-5)

- [ ] **Task 4.1**: Create `SyncService` Riverpod provider returning `Stream<SyncStatus>`
- [ ] **Task 4.2**: Listen to `networkMonitorProvider` stream
- [ ] **Task 4.3**: Trigger `processSyncQueue()` when network restored
- [ ] **Task 4.4**: Emit `SyncStatus.syncing` during sync, `synced` on success
- [ ] **Task 4.5**: Emit `SyncStatus.offline` when network unavailable + queue not empty
- [ ] **Task 4.6**: Emit `SyncStatus.error` on sync failures
- [ ] **Task 4.7**: Implement `triggerSync()` method for manual sync
- [ ] **Task 4.8**: Create Riverpod providers for dependencies (SyncQueueManager, ConflictResolver, etc.)

### Phase 5: Repository Integration (Day 5-6)

- [ ] **Task 5.1**: Update `InventoryRepositoryImpl.addProduct()` to write to Hive + enqueue
- [ ] **Task 5.2**: Update `InventoryRepositoryImpl.updateProduct()` to write to Hive + enqueue
- [ ] **Task 5.3**: Update `InventoryRepositoryImpl.deleteProduct()` to delete from Hive + enqueue
- [ ] **Task 5.4**: Ensure `watchInventory()` returns Hive stream (local-first)
- [ ] **Task 5.5**: Add Firestore snapshot listeners for bidirectional sync (remote → Hive)
- [ ] **Task 5.6**: Apply same pattern to other repositories (Nutrition, MealPlans, etc.)

### Phase 6: UI Components (Day 6-7)

- [ ] **Task 6.1**: Create `SyncStatusIndicator` widget with colored circle badge
- [ ] **Task 6.2**: Map `SyncStatus` to colors (green, orange, gray, red)
- [ ] **Task 6.3**: Add tooltip to indicator with status description
- [ ] **Task 6.4**: Create `OfflineBanner` MaterialBanner widget
- [ ] **Task 6.5**: Show banner when `networkInfo.isConnected == false`
- [ ] **Task 6.6**: Update `AppScaffold` to include `SyncStatusIndicator` in AppBar actions
- [ ] **Task 6.7**: Update `AppScaffold` to include `OfflineBanner` above body

### Phase 7: Firestore Configuration (Day 7)

- [ ] **Task 7.1**: Update Firestore Security Rules with version-based conflict detection
- [ ] **Task 7.2**: Add `version` field validation in security rules (must increment by 1)
- [ ] **Task 7.3**: Add `updatedAt` server timestamp to all documents
- [ ] **Task 7.4**: Deploy updated security rules to Firebase Console
- [ ] **Task 7.5**: Test security rules with Firestore Emulator

### Phase 8: Logging & Monitoring (Day 7-8)

- [ ] **Task 8.1**: Implement `Logger` class with Firebase Crashlytics integration
- [ ] **Task 8.2**: Log all sync errors to Crashlytics with structured context
- [ ] **Task 8.3**: Implement `SyncMetrics` class with Firebase Analytics events
- [ ] **Task 8.4**: Track `sync_success`, `sync_failure`, `sync_queue_size` events
- [ ] **Task 8.5**: Add dead-letter queue monitoring alert

### Phase 9: Testing (Day 8)

- [ ] **Task 9.1**: Write unit tests for `ConflictResolver.resolveConflict()`
- [ ] **Task 9.2**: Write unit tests for `SyncRetryManager.calculateBackoff()`
- [ ] **Task 9.3**: Write integration tests for offline → online sync flow
- [ ] **Task 9.4**: Write integration tests for concurrent conflict scenarios
- [ ] **Task 9.5**: Write widget tests for `SyncStatusIndicator` states
- [ ] **Task 9.6**: Write widget tests for `OfflineBanner` visibility
- [ ] **Task 9.7**: Write E2E test for full sync workflow (add offline → go online → verify Firestore)

---

## 🧪 Testing Strategy

### Unit Tests

**File**: `test/core/data_sync/conflict_resolver_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigofute_v2/core/data_sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = ConflictResolver();
    });

    test('should resolve conflict using Last-Write-Wins (remote newer)', () async {
      final localData = {
        'id': '1',
        'name': 'Local Version',
        'updatedAt': DateTime(2026, 2, 15, 10, 0).toIso8601String(),
      };

      final remoteData = {
        'id': '1',
        'name': 'Remote Version',
        'updatedAt': DateTime(2026, 2, 15, 10, 5).toIso8601String(), // 5 min later
      };

      final result = await resolver.resolveConflict(
        localData: localData,
        remoteData: remoteData,
      );

      expect(result['name'], 'Remote Version'); // Remote should win
    });

    test('should resolve conflict using Last-Write-Wins (local newer)', () async {
      final localData = {
        'id': '1',
        'name': 'Local Version',
        'updatedAt': DateTime(2026, 2, 15, 10, 10).toIso8601String(),
      };

      final remoteData = {
        'id': '1',
        'name': 'Remote Version',
        'updatedAt': DateTime(2026, 2, 15, 10, 5).toIso8601String(),
      };

      final result = await resolver.resolveConflict(
        localData: localData,
        remoteData: remoteData,
      );

      expect(result['name'], 'Local Version'); // Local should win
    });

    test('should increment version correctly', () {
      final data = {
        'id': '1',
        'name': 'Test Product',
        'version': 3,
      };

      final result = resolver.incrementVersion(data);

      expect(result['version'], 4);
      expect(result['updatedAt'], isA<FieldValue>());
    });
  });
}
```

**File**: `test/core/data_sync/sync_retry_manager_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/data_sync/sync_retry_manager.dart';

void main() {
  group('SyncRetryManager', () {
    late SyncRetryManager manager;

    setUp(() {
      manager = SyncRetryManager();
    });

    test('should calculate exponential backoff correctly', () {
      expect(manager.calculateBackoff(0), const Duration(seconds: 1));
      expect(manager.calculateBackoff(1), const Duration(seconds: 2));
      expect(manager.calculateBackoff(2), const Duration(seconds: 4));
      expect(manager.calculateBackoff(3), const Duration(seconds: 8));
      expect(manager.calculateBackoff(4), const Duration(seconds: 8)); // Capped at 8s
    });

    test('should allow retry when count < 3', () {
      expect(manager.shouldRetry(0), true);
      expect(manager.shouldRetry(1), true);
      expect(manager.shouldRetry(2), true);
      expect(manager.shouldRetry(3), false); // Max retries reached
    });

    test('should execute operation with retry on failure', () async {
      int attemptCount = 0;

      final result = await manager.executeWithRetry(
        operation: () async {
          attemptCount++;
          if (attemptCount < 2) {
            throw Exception('Temporary failure');
          }
          return 'success';
        },
        maxAttempts: 3,
      );

      expect(result, 'success');
      expect(attemptCount, 2); // Failed once, succeeded on 2nd attempt
    });

    test('should throw after max retries exceeded', () async {
      expect(
        () => manager.executeWithRetry(
          operation: () async => throw Exception('Permanent failure'),
          maxAttempts: 3,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### Integration Tests

**File**: `integration_test/sync_workflow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frigofute_v2/core/data_sync/sync_queue_manager.dart';
import 'package:frigofute_v2/features/inventory/data/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sync Workflow Integration Tests', () {
    late SyncQueueManager syncQueueManager;

    setUpAll(() async {
      await Hive.initFlutter();
      // ... initialize dependencies
    });

    testWidgets('should sync offline mutation when network restored',
        (tester) async {
      // 1. Go offline
      // (Mock network monitor to return isConnected: false)

      // 2. Add product (should queue in sync_queue_box)
      final product = ProductModel(
        id: 'test-product-1',
        name: 'Offline Product',
        category: 'dairy',
        // ... other fields
      );

      await syncQueueManager.enqueue(
        operation: SyncOperation.create,
        collection: 'users/abc123/inventory_items',
        documentId: product.id,
        data: product.toJson(),
      );

      // Verify item in queue
      final queueSize = syncQueueManager.getQueueSize();
      expect(queueSize, 1);

      // 3. Go online
      // (Mock network monitor to return isConnected: true)

      // 4. Trigger sync
      await syncQueueManager.processSyncQueue();

      // 5. Verify queue is empty
      expect(syncQueueManager.getQueueSize(), 0);

      // 6. Verify product in Firestore
      // (Query Firestore and verify document exists)
    });

    testWidgets('should resolve conflict using Last-Write-Wins',
        (tester) async {
      // 1. Create product offline
      // 2. Create same product online with different data
      // 3. Go online and sync
      // 4. Verify remote version wins (newer timestamp)
    });
  });
}
```

### Widget Tests

**File**: `test/core/widgets/sync_status_indicator_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/data_sync/models/sync_status.dart';
import 'package:frigofute_v2/core/data_sync/sync_service.dart';
import 'package:frigofute_v2/core/widgets/sync_status_indicator.dart';

void main() {
  group('SyncStatusIndicator Widget Tests', () {
    testWidgets('should display green indicator when synced', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncServiceProvider.overrideWith(
              (ref) => Stream.value(SyncStatus.synced),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncStatusIndicator()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green);
    });

    testWidgets('should display orange indicator when syncing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncServiceProvider.overrideWith(
              (ref) => Stream.value(SyncStatus.syncing),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncStatusIndicator()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.orange);
    });

    // Add tests for offline (gray) and error (red) states
  });
}
```

---

## ⚠️ Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Blocking UI Thread During Sync

**Problem**:
```dart
// BAD: Synchronous sync blocks UI
Future<void> addProduct(Product product) async {
  await localDataSource.addProduct(product);

  // ❌ This blocks UI until Firestore responds
  await remoteDataSource.addProduct(product);
}
```

**Solution**:
```dart
// GOOD: Queue sync operation, return immediately
Future<void> addProduct(Product product) async {
  await localDataSource.addProduct(product);

  // ✅ Enqueue and return immediately (non-blocking)
  syncQueueManager.enqueue(
    operation: SyncOperation.create,
    collection: 'users/${product.userId}/inventory_items',
    documentId: product.id,
    data: product.toJson(),
  );
}
```

### ❌ Anti-Pattern 2: Ignoring Conflict Resolution

**Problem**:
```dart
// BAD: Overwrite remote data blindly
await docRef.set(localData); // ❌ Loses remote changes
```

**Solution**:
```dart
// GOOD: Resolve conflicts before writing
final remoteDoc = await docRef.get();
if (remoteDoc.exists) {
  final resolvedData = await conflictResolver.resolveConflict(
    localData: localData,
    remoteData: remoteDoc.data()!,
  );
  await docRef.update(resolvedData);
}
```

### ❌ Anti-Pattern 3: Infinite Retry Loop

**Problem**:
```dart
// BAD: Retry forever without limit
while (true) {
  try {
    await syncToFirestore(item);
    break;
  } catch (e) {
    // ❌ Will retry forever if Firestore is down
    await Future.delayed(Duration(seconds: 1));
  }
}
```

**Solution**:
```dart
// GOOD: Max 3 retries, then move to dead-letter queue
if (retryCount >= 3) {
  await deadLetterBox.add(item);
  await syncQueueBox.delete(item.key);
  // Notify user of permanent failure
}
```

### ❌ Anti-Pattern 4: Not Detecting Network Changes

**Problem**:
```dart
// BAD: Check network once at app start
final isConnected = await connectivity.checkConnectivity();
if (isConnected) {
  processSyncQueue();
}
// ❌ Doesn't react to network changes during runtime
```

**Solution**:
```dart
// GOOD: Listen to network changes continuously
ref.listen(networkMonitorProvider, (previous, next) {
  next.whenData((networkInfo) {
    if (networkInfo.isConnected && !previous.value.isConnected) {
      // Network restored → trigger sync
      syncQueueManager.processSyncQueue();
    }
  });
});
```

### ❌ Anti-Pattern 5: Syncing Sensitive Data Without Encryption

**Problem**:
```dart
// BAD: Store nutrition data in unencrypted sync queue
await syncQueueBox.add(SyncQueueItem(
  data: nutritionData, // ❌ Contains sensitive health data
));
```

**Solution**:
```dart
// GOOD: Sync queue stores operation metadata only
// Actual sensitive data stays in encrypted Hive boxes
await syncQueueBox.add(SyncQueueItem(
  operation: SyncOperation.update,
  collection: 'users/$userId/nutrition_data',
  documentId: nutritionData.id,
  data: nutritionData.toJson(), // ✅ Will be encrypted at rest in Firestore
));

// Sensitive data stays in encrypted Hive box
final encryptedBox = Hive.box('nutrition_data_box'); // Opened with HiveAesCipher
```

### ❌ Anti-Pattern 6: Large Payloads in Sync Queue

**Problem**:
```dart
// BAD: Store full recipe tutorial (2MB) in sync queue
await syncQueueBox.add(SyncQueueItem(
  data: {
    'id': recipeId,
    'tutorialVideo': base64EncodedVideo, // ❌ 2MB payload
  },
));
```

**Solution**:
```dart
// GOOD: Store reference only, upload to Firebase Storage separately
final videoUrl = await uploadToStorage(tutorialVideo);
await syncQueueBox.add(SyncQueueItem(
  data: {
    'id': recipeId,
    'tutorialVideoUrl': videoUrl, // ✅ URL reference only
  },
));
```

### ❌ Anti-Pattern 7: Not Showing Sync Status to Users

**Problem**:
```dart
// BAD: Silent sync failures
try {
  await processSyncQueue();
} catch (e) {
  // ❌ User doesn't know sync failed
}
```

**Solution**:
```dart
// GOOD: Show sync status indicator + error messages
final syncStatus = ref.watch(syncServiceProvider);
syncStatus.when(
  data: (status) {
    if (status == SyncStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync error. Will retry...')),
      );
    }
  },
);
```

### ❌ Anti-Pattern 8: Forgetting to Version Documents

**Problem**:
```dart
// BAD: No version field → can't detect concurrent updates
await docRef.set({
  'id': productId,
  'name': 'Updated Name',
  // ❌ No version field
});
```

**Solution**:
```dart
// GOOD: Always increment version for conflict detection
final dataWithVersion = conflictResolver.incrementVersion(data);
await docRef.update(dataWithVersion);
// ✅ Firestore security rules enforce version increment by 1
```

---

## 🔗 Integration Points

### Integration with Story 0.2 (Firebase Services)

**Dependency**: Requires Firestore, Firebase Auth initialized.

```dart
// lib/core/providers/firebase_providers.dart (from Story 0.2)
@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

// Used in SyncQueueManager:
final _firestore = ref.read(firestoreProvider);
final _auth = ref.read(firebaseAuthProvider);
```

### Integration with Story 0.3 (Hive Local Database)

**Dependency**: Requires `sync_queue_box` and `dead_letter_queue_box` opened in HiveService.

```dart
// lib/core/services/hive_service.dart (updated in Story 0.9)
static Future<void> init() async {
  await Hive.initFlutter();

  // Existing boxes from Story 0.3
  await Hive.openBox<ProductModel>('inventory_box');
  await Hive.openBox<RecipeModel>('recipes_box');
  // ...

  // NEW: Sync-related boxes (Story 0.9)
  Hive.registerAdapter(SyncQueueItemAdapter());
  await Hive.openBox<SyncQueueItem>('sync_queue_box');
  await Hive.openBox<SyncQueueItem>('dead_letter_queue_box');
}
```

### Integration with Story 0.4 (Riverpod State Management)

**Dependency**: Uses Riverpod providers for SyncService, NetworkMonitor, etc.

```dart
// Providers used across features
final syncServiceProvider = StreamProvider<SyncStatus>(...);
final networkMonitorProvider = StreamProvider<NetworkInfo>(...);
final syncQueueManagerProvider = Provider<SyncQueueManager>(...);
```

### Integration with Story 0.7 (Crash Reporting)

**Dependency**: Logs sync errors to Firebase Crashlytics.

```dart
// lib/core/logging/logger.dart
void error(String message, {dynamic error, StackTrace? stackTrace}) {
  _crashlytics.log(message);
  _crashlytics.recordError(error, stackTrace, reason: message);
}

// Usage in SyncQueueManager:
_logger.error('Sync failed: ${item.id}', error: e, stackTrace: stackTrace);
```

### Integration with Future Stories

**Epic 1 (Auth)**: User ID required for Firestore user-scoped collections.

```dart
// Sync uses current user ID
final userId = FirebaseAuth.instance.currentUser?.uid;
await syncQueueManager.enqueue(
  collection: 'users/$userId/inventory_items',
  // ...
);
```

**Epic 2 (Inventory)**: All inventory CRUD operations use sync queue.

```dart
// features/inventory/data/repositories/inventory_repository_impl.dart
await localDataSource.addProduct(product); // Write to Hive
await syncQueueManager.enqueue(...); // Queue for sync
```

**Epic 7 (Nutrition Tracking)**: Sensitive health data synced with encryption.

```dart
// Nutrition data stored in encrypted Hive box + synced to Firestore
final encryptedBox = Hive.box('nutrition_data_box'); // AES-256 encrypted
await syncQueueManager.enqueue(
  collection: 'users/$userId/nutrition_data',
  data: nutritionData.toJson(), // Encrypted in Firestore too
);
```

---

## 📚 Dev Notes

### Design Decisions

1. **Why Last-Write-Wins (LWW)?**
   - Simplicity: No need for complex CRDT (Conflict-free Replicated Data Type) logic
   - Firestore server timestamps are authoritative and consistent
   - Acceptable trade-off for most user data (inventory, meal plans)
   - For critical data (financial transactions), use transaction-based approach instead

2. **Why Hive for Sync Queue?**
   - Performance: Hive writes are faster than Firestore (local-first)
   - Persistence: Queue survives app restarts
   - Non-encrypted: Queue contains operation metadata, not sensitive user data
   - TypeAdapter: Easily serialize `SyncQueueItem` objects

3. **Why Exponential Backoff?**
   - Prevents hammering Firestore during outages (reduces quota consumption)
   - Gives transient errors time to resolve (network blips, rate limits)
   - Standard industry practice (AWS, Google Cloud recommend it)

4. **Why Dead-Letter Queue?**
   - Prevents infinite retry loops
   - Allows debugging of permanent failures
   - User can manually inspect/retry failed syncs via admin panel (future feature)

5. **Why Batch Writes?**
   - Firestore allows 500 operations per batch (cost-effective)
   - Reduces network round-trips (better performance)
   - Atomic: all-or-nothing (consistency guarantee)

### Performance Considerations

- **Offline Write Latency**: < 100ms (Hive SSD write + queue enqueue)
- **Sync Trigger Latency**: < 1s (network detection → queue processing start)
- **Single Item Sync**: < 5s (Firestore write + conflict resolution)
- **Batch Sync (100 items)**: < 30s (5 batches of 20 items, 6s per batch)
- **Queue Processing**: Run on background isolate to avoid blocking UI

### Security Considerations

- **Firestore Security Rules**: Enforce version increments (optimistic concurrency)
- **User Isolation**: All collections scoped to `users/{userId}` (no cross-user access)
- **Sensitive Data**: Nutrition data encrypted at rest (Hive AES-256 + Firestore encryption)
- **API Keys**: No API keys stored in sync queue (references only)

### Monitoring & Alerts

- **Firebase Crashlytics**: Log all sync errors with structured context
- **Firebase Analytics**: Track `sync_success`, `sync_failure`, `sync_queue_size` events
- **Dead-Letter Queue Size**: Alert if > 100 items (indicates systemic issue)
- **Sync Queue Size**: Alert if > 1000 items (indicates prolonged offline period)

### Common Pitfalls

1. **Forgetting to enqueue operations**: Always call `syncQueueManager.enqueue()` after local writes
2. **Not handling delete conflicts**: If remote deletes an item, local update should be discarded
3. **Large payloads in queue**: Store references (URLs) instead of full binary data
4. **Not showing sync status**: Users should know when data is syncing/offline
5. **Infinite retries**: Always enforce max retry limit (3 attempts)

### Testing Tips

- **Use Firestore Emulator**: Test sync logic locally without hitting production Firestore
- **Mock Network Monitor**: Simulate offline → online transitions in tests
- **Test Conflict Scenarios**: Create concurrent updates on multiple devices
- **Test Max Retries**: Verify dead-letter queue logic by forcing 3 failures
- **Test Batch Writes**: Verify 500-item batches work correctly

### Future Enhancements (Not in Story 0.9)

- **Differential Sync**: Only sync changed fields (reduce bandwidth)
- **Compression**: Compress large payloads before syncing (gzip)
- **Priority Queue**: High-priority items (user profile) sync first
- **Background Sync (WorkManager)**: Continue syncing even when app is closed
- **Multi-User Conflict UI**: Show diff viewer for concurrent edits (advanced)

---

## ✅ Definition of Done

### Functional Requirements
- [ ] All CRUD operations work offline and sync when online
- [ ] Sync queue processes in FIFO order with max 3 retries
- [ ] Conflicts resolved using Last-Write-Wins strategy
- [ ] Network detection triggers automatic sync
- [ ] Sync status indicator visible in app bar (green/orange/gray/red)
- [ ] Offline banner shows when network unavailable
- [ ] Dead-letter queue captures items exceeding max retries
- [ ] Sync errors logged to Firebase Crashlytics

### Non-Functional Requirements
- [ ] Offline mutations write to Hive in < 100ms
- [ ] Sync queue processing triggers in < 1s after network restoration
- [ ] Single item sync completes in < 5s
- [ ] Batch sync of 100 items completes in < 30s
- [ ] Sync processing does not block UI thread

### Code Quality
- [ ] All new code follows Flutter style guide (dartfmt, linting 0 errors)
- [ ] 100% test coverage for `ConflictResolver`, `SyncRetryManager`
- [ ] Integration tests for offline → online sync flow
- [ ] Widget tests for `SyncStatusIndicator`, `OfflineBanner`
- [ ] Code reviewed by at least 1 peer

### Documentation
- [ ] All public methods have dartdoc comments
- [ ] README updated with sync architecture diagram
- [ ] Dev team trained on sync workflow (sync queue, conflict resolution)

### Deployment
- [ ] Firestore Security Rules deployed to production
- [ ] Firebase Crashlytics receiving sync error logs
- [ ] Firebase Analytics tracking sync events
- [ ] No regressions in existing features (regression test suite passes)

---

## 📎 References

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management (Story 0.4)
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Local Storage (Story 0.3)
  hive: ^2.8.0
  hive_flutter: ^1.1.0

  # Firebase (Story 0.2)
  firebase_core: ^3.12.0
  firebase_auth: ^5.3.4
  firebase_firestore: ^5.6.1
  firebase_crashlytics: ^4.3.1
  firebase_analytics: ^11.4.1

  # Networking (NEW for Story 0.9)
  connectivity_plus: ^6.2.0

  # Code Generation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Utilities
  uuid: ^4.5.1
  logger: ^2.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.6.1
  hive_generator: ^2.0.1

  # Testing
  integration_test:
    sdk: flutter
  mocktail: ^1.0.4
```

### External Documentation

- [Firestore Offline Persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Last-Write-Wins Conflict Resolution](https://firebase.google.com/docs/firestore/manage-data/transactions)
- [Connectivity Plus Package](https://pub.dev/packages/connectivity_plus)
- [Exponential Backoff Best Practices](https://cloud.google.com/iot/docs/how-tos/exponential-backoff)

### Architecture Diagrams

See Story 0.9 Technical Specifications § 1 for sync architecture flowchart.

---

**Story Created**: 2026-02-15
**Last Updated**: 2026-02-15
**Ready for Dev**: ✅ Yes
