# Story 1.8: Synchronize Data Across Multiple Devices

## METADATA

- **Story ID**: 1.8
- **Epic**: Epic 1 - User Authentication & Profile Management
- **Title**: Synchronize Data Across Multiple Devices
- **Story Points**: 13
- **Priority**: High
- **Sprint**: TBD
- **Status**: ready-for-dev
- **Created**: 2026-02-15
- **Updated**: 2026-02-15
- **Tags**: #multi-device #sync #firestore #offline-first #real-time
- **Dependencies**:
  - Story 1.1 (Create Account)
  - Story 1.2 (Login Email/Password)
  - Story 0.3 (Hive Local Storage)
  - Story 0.4 (Riverpod State Management)
  - Story 0.9 (Offline-First Sync Architecture Foundation)

---

## USER STORY

**As a** FrigoFute user with multiple devices (phone, tablet)
**I want** my inventory, settings, and profile data to automatically synchronize across all my devices in real-time
**So that** I can seamlessly switch between devices and always see the latest data, even when offline

### User Value Proposition

Multi-device synchronization is essential for modern app users who expect a seamless experience across all their devices. Users can add products on their phone while shopping, then view recipes on their tablet while cooking, or manage their inventory from their desktop. The sync happens automatically in the background with minimal user intervention, providing a native app experience.

### Business Value

- **User Retention**: Users who sync multiple devices have 3x higher retention rates
- **Premium Conversion**: Multi-device sync is a key feature that drives premium subscriptions
- **Engagement**: Seamless sync increases app usage by removing friction
- **Competitive Advantage**: Differentiates FrigoFute from competitors with poor sync

---

## ACCEPTANCE CRITERIA

### AC-1: Device Registration on Login ✅

**Given** a user logs in on a new device
**When** authentication succeeds
**Then** the device is automatically registered with:
- Unique device ID (generated once per install)
- Device name (auto-detected: "Marcel's iPhone 15 Pro")
- Device type (iOS/Android)
- OS version
- App version
- Last seen timestamp
- Active status (true)
- Push token (for notifications)

**Verification:**
- Device appears in Firestore: `users/{userId}/devices/{deviceId}`
- Local Hive stores device ID for future sessions

---

### AC-2: Real-Time Inventory Sync ✅

**Given** a user is logged in on multiple devices simultaneously
**When** user adds a product on Device A
**Then**:
- Product appears locally on Device A instantly (optimistic update)
- Product syncs to Firestore within 2 seconds
- Product appears on Device B within 3 seconds via real-time listener
- Both devices show identical inventory data

**Verification:**
- Open app on 2 devices
- Add product on Device 1
- Product appears on Device 2 within 3 seconds
- Firestore timestamp matches within acceptable delta

---

### AC-3: Real-Time Settings Sync ✅

**Given** a user changes app settings on one device
**When** settings are updated (notifications, theme, units)
**Then**:
- Settings update locally immediately
- Settings sync to Firestore
- Other devices receive updated settings via real-time listener
- UI reflects new settings within 3 seconds

**Verification:**
- Change notification settings on Device 1
- Device 2 reflects changes within 3 seconds
- Settings persist after app restart

---

### AC-4: Real-Time Profile Data Sync ✅

**Given** a user updates their health profile on one device
**When** profile data changes (weight, height, dietary preferences)
**Then**:
- Profile updates locally
- Encrypted profile syncs to Firestore
- BMR/TDEE recalculations happen locally on all devices
- Dashboard reflects updated metrics within 5 seconds

**Verification:**
- Update weight on Device 1
- Device 2 shows new weight + recalculated TDEE within 5 seconds
- Health data remains encrypted in Firestore

---

### AC-5: Offline Queue for Changes ✅

**Given** a user is offline
**When** user makes changes (add/edit/delete products)
**Then**:
- Changes save to local Hive immediately
- Changes queue in `SyncQueueItem` box
- Sync indicator shows "Offline - X changes pending"
- Changes persist across app restarts

**Verification:**
- Disable network
- Add 3 products
- App shows "3 changes queued"
- Restart app
- Queue persists with 3 items

---

### AC-6: Automatic Sync When Back Online ✅

**Given** user has queued changes from offline session
**When** network connectivity is restored
**Then**:
- Sync automatically starts within 5 seconds
- Queued operations process in order (FIFO)
- Progress indicator shows "Syncing X of Y changes"
- Success banner shows "All changes synced" when complete

**Verification:**
- Queue 5 changes while offline
- Re-enable network
- Auto-sync starts within 5 seconds
- All 5 changes reach Firestore
- Queue empties

---

### AC-7: Conflict Resolution (Last-Write-Wins) ✅

**Given** the same product is edited on 2 devices simultaneously while offline
**When** both devices come back online
**Then**:
- System detects conflicting versions via timestamp
- Last-Write-Wins strategy: newest Firestore server timestamp wins
- Losing edit is overwritten silently (no user intervention)
- Optional: Conflict log saved to Firestore for audit

**Verification:**
- Device 1: Edit product A offline (change name to "Tomatoes")
- Device 2: Edit product A offline (change name to "Cherry Tomatoes")
- Device 2 syncs first → name becomes "Cherry Tomatoes"
- Device 1 syncs second → if Device 1's timestamp is newer, name becomes "Tomatoes"
- Check Firestore `conflict_logs` collection for entry

---

### AC-8: View List of Active Devices ✅

**Given** a user navigates to Settings → Devices
**When** screen loads
**Then** user sees a list of all devices with:
- Device name + icon (phone/tablet)
- OS type and version
- Last seen timestamp (e.g., "2 minutes ago", "3 days ago")
- Current device highlighted
- Badge showing "This Device"

**Verification:**
- Login on 3 devices
- Navigate to Settings → Devices
- All 3 devices appear
- Current device has "This Device" badge
- Timestamps are accurate

---

### AC-9: Revoke Device Access ✅

**Given** a user views their device list
**When** user taps on a non-current device → "Revoke Access"
**Then**:
- Confirmation dialog: "Revoke access for [Device Name]?"
- On confirm:
  - Device marked as `isActive: false` in Firestore
  - Revoked device receives push notification
  - Revoked device auto-logs out on next activity
  - Device disappears from active list (moves to "Revoked" section)

**Verification:**
- Revoke Device 2 from Device 1
- Device 2 shows logout notification within 10 seconds
- Device 2 redirects to login screen
- Device 2 cannot access user data

---

### AC-10: Retry Failed Sync Operations ✅

**Given** a sync operation fails (network timeout, Firestore error)
**When** failure is detected
**Then**:
- Operation remains in sync queue
- Retry count increments
- Exponential backoff: 5s, 10s, 20s delays
- After 3 retries, operation moves to "Failed" list
- User can manually retry failed operations

**Verification:**
- Simulate Firestore outage
- Queue 1 operation
- Verify 3 retry attempts with delays
- Operation appears in "Failed Sync" list
- Manual "Retry All" button works

---

### AC-11: Delta Sync for Efficiency ✅

**Given** user opens app after being offline for hours
**When** initial sync starts
**Then**:
- Only fetch documents modified since last sync timestamp
- Use Firestore query: `where('_updatedAt', '>', lastSyncTime)`
- Progress shows estimated count
- Sync completes faster than full re-download

**Verification:**
- Close app for 1 hour
- Add 50 products on Device 2
- Open Device 1
- Delta sync fetches only 50 new products (not entire inventory)
- Verify via network logs: single Firestore query

---

### AC-12: Sync Status Indicator ✅

**Given** app is in any state
**Then** sync status is always visible via:
- Icon in app bar:
  - Green checkmark: "Synced"
  - Spinning circle: "Syncing..."
  - Orange cloud-off: "Offline (X pending)"
  - Red error: "Sync Error"
- Status text on tap
- Last sync timestamp

**Verification:**
- Check each sync state:
  - Online + synced: Green checkmark
  - Active sync: Animated spinner
  - Offline: Orange indicator + count
  - Error: Red indicator + error message

---

### AC-13: Encrypted Health Data Sync ✅

**Given** user has health profile data (weight, dietary preferences, allergies)
**When** syncing to Firestore
**Then**:
- Health data is encrypted with AES-256 before upload
- Firestore stores encrypted blob + integrity hash
- On download, data is decrypted locally
- Decryption uses device-specific encryption key (secure storage)

**Verification:**
- Update health profile
- Check Firestore document: `health_profiles/active`
- Verify `encryptedData` field is base64 blob (not plaintext)
- Verify `integrityHash` field exists
- Decrypt locally and verify matches original

---

### AC-14: Handle Device Limit (Max 5 Active Devices) ✅

**Given** user has 5 active devices registered
**When** user logs in on a 6th device
**Then**:
- Login succeeds
- Dialog: "You've reached the max of 5 devices. Revoke one to continue."
- User can revoke an existing device
- New device registration completes after revocation

**Verification:**
- Register 5 devices
- Attempt 6th login
- Dialog appears
- Revoke oldest device
- 6th device registers successfully

---

### AC-15: Sync Metadata Tracking ✅

**Given** sync operations happen
**Then** metadata is tracked:
- Last full sync timestamp
- Last incremental sync timestamp
- Total active devices count
- Pending changes count
- Metadata stored in Firestore: `users/{userId}/sync_metadata/latest`

**Verification:**
- Perform sync
- Check Firestore `sync_metadata/latest` document
- Verify timestamps are recent
- Verify counts match actual state

---

### AC-16: Background Sync on App Launch ✅

**Given** user opens app
**When** app launches from cold start or background
**Then**:
- Background sync starts automatically within 3 seconds
- Sync is non-blocking (user can navigate immediately)
- Progress indicator shows sync status
- Sync completes silently without disrupting UX

**Verification:**
- Close app completely
- Wait 5 minutes
- Reopen app
- Sync starts within 3 seconds
- User can navigate while syncing

---

### AC-17: Firestore Security Rules Enforcement ✅

**Given** Firestore Security Rules are deployed
**Then**:
- User can only read/write their own data (`userId` match)
- Device must be `isActive: true` to write
- Revoked devices cannot write (rejected with `PermissionDenied`)
- Anonymous users cannot access any data

**Verification:**
- Revoke device
- Attempt write from revoked device → Firestore returns 403
- Attempt read from wrong user → Firestore returns 403
- Check Security Rules simulator

---

### AC-18: Manual Sync Trigger ✅

**Given** user suspects data is out of sync
**When** user navigates to Settings → Sync → "Sync Now"
**Then**:
- Full sync starts immediately
- Progress dialog shows sync status
- On success: "All data synchronized" toast
- On failure: Error message + retry option

**Verification:**
- Tap "Sync Now" button
- Sync completes within 10 seconds
- Toast confirms success
- Verify Firestore `lastFullSyncAt` timestamp updated

---

### AC-19: Sync Performance (Acceptable Latency) ✅

**Given** user performs sync operations
**Then** performance meets SLA:
- Single product sync: < 2 seconds
- Batch sync (100 products): < 10 seconds
- Real-time update propagation: < 3 seconds between devices
- Offline queue processing: 10 ops/second

**Verification:**
- Measure sync times with Stopwatch
- Add 100 products and measure batch sync
- Verify meets latency targets

---

### AC-20: Sync Notifications (Optional) ✅

**Given** app is in background
**When** important sync events happen
**Then** user receives local notification:
- "Sync Failed - 5 changes pending"
- "All changes synchronized"
- "New device detected - [Device Name]"

**Verification:**
- Background app
- Trigger sync failure
- Verify notification appears
- Notification taps opens sync status screen

---

## TECHNICAL SPECIFICATIONS

### 1. Firestore Collection Structure

```
users/
  {userId}/
    # Root user document
    email: string
    displayName: string
    photoUrl: string?
    createdAt: timestamp
    updatedAt: timestamp

    devices/
      {deviceId}/
        deviceId: string              # UUID generated on install
        userId: string                # Reference to parent user
        deviceName: string            # "Marcel's iPhone 15 Pro"
        deviceType: 'ios' | 'android' # Platform
        osVersion: string             # "iOS 17.2"
        appVersion: string            # "1.0.0"
        pushToken: string?            # FCM token
        isActive: boolean             # true = can write, false = revoked
        isTrustedDevice: boolean      # For future 2FA
        createdAt: timestamp          # First registration
        lastSeenAt: timestamp         # Updated on app launch
        lastSyncAt: timestamp?        # Last successful sync
        ipAddress: string?            # For security audit
        revokedAt: timestamp?         # When device was revoked
        revokedBy: string?            # Device ID that revoked this

    inventory/
      {productId}/
        id: string
        name: string
        category: string
        expirationDate: timestamp
        storageLocation: string
        status: string
        addedAt: timestamp
        barcode: string?
        photoUrl: string?
        # Sync metadata
        _createdBy: string            # Device ID
        _updatedBy: string            # Device ID
        _createdAt: timestamp         # Server timestamp
        _updatedAt: timestamp         # Server timestamp
        _version: number              # Incremented on update

    settings/
      {settingKey}/
        key: string
        value: any
        updatedAt: timestamp
        updatedBy: string             # Device ID
        _version: number

    health_profiles/
      active/
        encryptedData: string         # AES-256 encrypted JSON
        integrityHash: string         # SHA-256 hash
        _encryptedAt: timestamp
        _encryptedBy: string          # User ID

    sync_metadata/
      latest/
        lastFullSyncAt: timestamp
        lastIncrementalSyncAt: timestamp
        totalDevices: number
        activeDevices: number
        pendingChanges: number

    conflict_logs/
      {conflictId}/
        id: string
        userId: string
        entityId: string              # Product/setting ID
        entityType: string            # 'product', 'setting'
        localData: map
        remoteData: map
        resolvedData: map
        resolutionStrategy: string    # 'lww', 'manual'
        detectedAt: timestamp
        resolvedAt: timestamp
```

### 2. Data Models

#### DeviceModel

```dart
// lib/features/auth_profile/domain/entities/device.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
class DeviceEntity with _$DeviceEntity {
  const factory DeviceEntity({
    required String deviceId,
    required String userId,
    required String deviceName,
    required String deviceType,
    required String osVersion,
    required String appVersion,
    String? pushToken,
    required bool isActive,
    @Default(false) bool isTrustedDevice,
    required DateTime createdAt,
    required DateTime lastSeenAt,
    DateTime? lastSyncAt,
    String? ipAddress,
    DateTime? revokedAt,
    String? revokedBy,
  }) = _DeviceEntity;

  factory DeviceEntity.fromJson(Map<String, dynamic> json) =>
      _$DeviceEntityFromJson(json);
}
```

#### SyncQueueItem (Already Exists in Codebase)

```dart
// lib/core/data_sync/models/sync_queue_item.dart
// NOTE: This model already exists in the project

import 'package:hive/hive.dart';

part 'sync_queue_item.g.dart';

@HiveType(typeId: 10)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String operation; // 'create', 'update', 'delete'

  @HiveField(2)
  final String collection; // 'inventory', 'settings', etc.

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final DateTime queuedAt;

  @HiveField(5)
  final int retryCount;

  SyncQueueItem({
    required this.id,
    required this.operation,
    required this.collection,
    required this.data,
    required this.queuedAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'operation': operation,
        'collection': collection,
        'data': data,
        'queuedAt': queuedAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      operation: json['operation'] as String,
      collection: json['collection'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}
```

#### SyncMetadata

```dart
// lib/core/data_sync/models/sync_metadata.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_metadata.freezed.dart';
part 'sync_metadata.g.dart';

@freezed
class SyncMetadata with _$SyncMetadata {
  const factory SyncMetadata({
    required DateTime lastFullSyncAt,
    required DateTime lastIncrementalSyncAt,
    required int totalDevices,
    required int activeDevices,
    required int pendingChanges,
  }) = _SyncMetadata;

  factory SyncMetadata.fromJson(Map<String, dynamic> json) =>
      _$SyncMetadataFromJson(json);
}
```

#### SyncStatus Enum (Already Exists)

```dart
// lib/core/data_sync/models/sync_status.dart
// NOTE: This enum already exists in the project

enum SyncStatus {
  synced,    // All data synchronized
  syncing,   // Sync in progress
  offline,   // No network connection
  error,     // Sync error occurred
  queued,    // Operations queued, waiting to sync
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.error:
        return 'Sync Error';
      case SyncStatus.queued:
        return 'Queued';
    }
  }

  IconData get icon {
    switch (this) {
      case SyncStatus.synced:
        return Icons.check_circle;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.offline:
        return Icons.cloud_off;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.queued:
        return Icons.schedule;
    }
  }

  Color get color {
    switch (this) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.offline:
        return Colors.orange;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.queued:
        return Colors.amber;
    }
  }
}
```

### 3. Device Service

```dart
// lib/features/auth_profile/data/services/device_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final String _deviceId;

  DeviceService(
    this._auth,
    this._firestore,
    this._deviceId,
  );

  /// Initialize device ID (call once on app install)
  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }

    return deviceId;
  }

  /// Register device on login
  Future<void> registerDevice() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    final deviceRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(_deviceId);

    await deviceRef.set({
      'deviceId': _deviceId,
      'userId': userId,
      'deviceName': deviceInfo['deviceName'],
      'deviceType': deviceInfo['deviceType'],
      'osVersion': deviceInfo['osVersion'],
      'appVersion': appVersion,
      'isActive': true,
      'isTrustedDevice': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('Device registered: $_deviceId');
  }

  /// Update last seen timestamp
  Future<void> updateLastSeen() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(_deviceId)
        .update({
          'lastSeenAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
  }

  /// Watch all devices for current user
  Stream<List<DeviceEntity>> watchAllDevices() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DeviceEntity.fromJson({
                    ...doc.data(),
                    'deviceId': doc.id,
                  }))
              .toList()
            ..sort((a, b) => b.lastSeenAt.compareTo(a.lastSeenAt));
        });
  }

  /// Revoke device access
  Future<void> revokeDevice(String deviceIdToRevoke) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceIdToRevoke)
        .update({
          'isActive': false,
          'revokedAt': FieldValue.serverTimestamp(),
          'revokedBy': _deviceId,
        });

    debugPrint('Device revoked: $deviceIdToRevoke');
  }

  /// Check if current device is active
  Future<bool> isDeviceActive() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(_deviceId)
        .get();

    return doc.exists && (doc.data()?['isActive'] == true);
  }

  /// Listen for remote device revocation
  void setupDeviceRevocationListener(void Function() onRevoked) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(_deviceId)
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists || snapshot.data()?['isActive'] == false) {
            debugPrint('Device revoked remotely, triggering logout...');
            onRevoked();
          }
        });
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      return {
        'deviceName': iosInfo.name,
        'deviceType': 'ios',
        'osVersion': 'iOS ${iosInfo.systemVersion}',
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return {
        'deviceName': '${androidInfo.manufacturer} ${androidInfo.model}',
        'deviceType': 'android',
        'osVersion': 'Android ${androidInfo.version.release}',
      };
    }

    return {
      'deviceName': 'Unknown Device',
      'deviceType': 'unknown',
      'osVersion': 'Unknown',
    };
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
```

### 4. Sync Queue Manager

```dart
// lib/core/data_sync/services/sync_queue_manager.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/sync_queue_item.dart';

class SyncQueueManager {
  final Box<SyncQueueItem> _syncBox;
  final FirebaseFirestore _firestore;
  final String _userId;
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 5);

  SyncQueueManager(
    this._syncBox,
    this._firestore,
    this._userId,
  );

  /// Add operation to sync queue
  Future<void> queueOperation({
    required String operation, // 'create', 'update', 'delete'
    required String collection, // 'inventory', 'settings', etc.
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    final item = SyncQueueItem(
      id: '${DateTime.now().microsecondsSinceEpoch}_$docId',
      operation: operation,
      collection: collection,
      data: {
        'docId': docId,
        'userId': _userId,
        ...data,
      },
      queuedAt: DateTime.now(),
      retryCount: 0,
    );

    await _syncBox.put(item.id, item);
    debugPrint('✓ Queued: $operation on $collection/$docId');
  }

  /// Process all queued operations
  Future<SyncResult> processSyncQueue() async {
    final items = _syncBox.values.toList();
    if (items.isEmpty) {
      return SyncResult(
        successCount: 0,
        failureCount: 0,
        totalCount: 0,
      );
    }

    debugPrint('Processing ${items.length} queued operations...');

    int successCount = 0;
    int failureCount = 0;
    final List<String> failedIds = [];

    for (final item in items) {
      try {
        await _processSingleOperation(item);
        await _syncBox.delete(item.id);
        successCount++;
        debugPrint('✓ Synced: ${item.operation} on ${item.collection}');
      } on FirebaseException catch (e) {
        if (item.retryCount < _maxRetries) {
          await _retryOperation(item);
        } else {
          failedIds.add(item.id);
          failureCount++;
          debugPrint('✗ Failed (max retries): ${item.operation}');
        }
      } catch (e) {
        failedIds.add(item.id);
        failureCount++;
        debugPrint('✗ Unexpected error: $e');
      }
    }

    debugPrint('Sync complete: $successCount succeeded, $failureCount failed');

    return SyncResult(
      successCount: successCount,
      failureCount: failureCount,
      totalCount: items.length,
      failedOperationIds: failedIds,
    );
  }

  Future<void> _processSingleOperation(SyncQueueItem item) async {
    final collectionRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection(item.collection);

    switch (item.operation.toLowerCase()) {
      case 'create':
      case 'update':
        await collectionRef.doc(item.data['docId']).set(
              {
                ...item.data,
                '_updatedAt': FieldValue.serverTimestamp(),
                '_version': FieldValue.increment(1),
              },
              SetOptions(merge: true),
            );
        break;
      case 'delete':
        await collectionRef.doc(item.data['docId']).delete();
        break;
      default:
        throw UnsupportedError('Unknown operation: ${item.operation}');
    }
  }

  Future<void> _retryOperation(SyncQueueItem item) async {
    final updatedItem = SyncQueueItem(
      id: item.id,
      operation: item.operation,
      collection: item.collection,
      data: item.data,
      queuedAt: item.queuedAt,
      retryCount: item.retryCount + 1,
    );

    await _syncBox.put(item.id, updatedItem);

    // Exponential backoff: 5s, 10s, 20s
    final backoffMs = _retryDelay.inMilliseconds * pow(2, item.retryCount);
    await Future.delayed(Duration(milliseconds: backoffMs.toInt()));
  }

  int getPendingOperationCount() => _syncBox.length;

  List<SyncQueueItem> getPendingOperations() => _syncBox.values.toList();

  Future<void> clearQueue() async => await _syncBox.clear();
}

class SyncResult {
  final int successCount;
  final int failureCount;
  final int totalCount;
  final List<String> failedOperationIds;

  SyncResult({
    required this.successCount,
    required this.failureCount,
    required this.totalCount,
    this.failedOperationIds = const [],
  });

  bool get isSuccess => failureCount == 0;
  int get retryCount => failureCount;
}
```

### 5. Conflict Resolution Service

```dart
// lib/core/data_sync/services/conflict_resolution_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ConflictResolutionService {
  final FirebaseFirestore _firestore;
  final String _userId;

  ConflictResolutionService(this._firestore, this._userId);

  /// Last-Write-Wins strategy using server timestamps
  T resolveConflict<T>({
    required T local,
    required T remote,
    required DateTime Function(T) getUpdatedAt,
    required int Function(T) getVersion,
  }) {
    final localVersion = getVersion(local);
    final remoteVersion = getVersion(remote);

    // Higher version wins
    if (remoteVersion > localVersion) {
      return remote;
    } else if (localVersion > remoteVersion) {
      return local;
    }

    // If versions equal, compare timestamps
    final localTime = getUpdatedAt(local);
    final remoteTime = getUpdatedAt(remote);

    return remoteTime.isAfter(localTime) ? remote : local;
  }

  /// Log conflict for audit trail
  Future<void> logConflict({
    required String entityId,
    required String entityType,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required Map<String, dynamic> resolvedData,
    String resolutionStrategy = 'lww',
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('conflict_logs')
          .add({
            'entityId': entityId,
            'entityType': entityType,
            'localData': localData,
            'remoteData': remoteData,
            'resolvedData': resolvedData,
            'resolutionStrategy': resolutionStrategy,
            'detectedAt': FieldValue.serverTimestamp(),
            'resolvedAt': FieldValue.serverTimestamp(),
          });
      debugPrint('Conflict logged: $entityType/$entityId');
    } catch (e) {
      debugPrint('Failed to log conflict: $e');
    }
  }
}
```

### 6. Riverpod Providers

```dart
// lib/features/auth_profile/presentation/providers/device_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/device_service.dart';
import '../../domain/entities/device.dart';

// Device ID provider (initialized on app start)
final deviceIdProvider = FutureProvider<String>((ref) async {
  return await DeviceService.getOrCreateDeviceId();
});

// Device service provider
final deviceServiceProvider = Provider<DeviceService>((ref) {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final deviceId = ref.watch(deviceIdProvider).value ?? '';
  return DeviceService(auth, firestore, deviceId);
});

// Stream of all user devices
final userDevicesProvider = StreamProvider.autoDispose<List<DeviceEntity>>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.watchAllDevices();
});

// Current device (highlighted in UI)
final currentDeviceProvider = Provider.autoDispose<DeviceEntity?>((ref) {
  final devices = ref.watch(userDevicesProvider).value ?? [];
  final currentDeviceId = ref.watch(deviceIdProvider).value;
  return devices.firstWhereOrNull((d) => d.deviceId == currentDeviceId);
});

// Active device count
final activeDeviceCountProvider = Provider.autoDispose<int>((ref) {
  final devices = ref.watch(userDevicesProvider).value ?? [];
  return devices.where((d) => d.isActive).length;
});
```

```dart
// lib/core/data_sync/providers/sync_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/sync_queue_item.dart';
import '../services/sync_queue_manager.dart';

// Sync queue box provider
final syncQueueBoxProvider = Provider<Box<SyncQueueItem>>((ref) {
  return Hive.box<SyncQueueItem>('sync_queue_box');
});

// Sync queue manager provider
final syncQueueManagerProvider = Provider<SyncQueueManager>((ref) {
  final syncBox = ref.watch(syncQueueBoxProvider);
  final firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  return SyncQueueManager(syncBox, firestore, userId);
});

// Pending sync count
final pendingSyncCountProvider = Provider.autoDispose<int>((ref) {
  final syncBox = ref.watch(syncQueueBoxProvider);
  return syncBox.length;
});

// Sync status stream
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  // Listen to connectivity + queue changes
  // Returns: synced, syncing, offline, error, queued
  // Implementation depends on connectivity_plus package
  return Stream.value(SyncStatus.synced); // Placeholder
});
```

### 7. Firestore Security Rules

```javascript
// firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuth() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isDeviceActive(userId, deviceId) {
      return get(/databases/$(database)/documents/users/$(userId)/devices/$(deviceId)).data.isActive == true;
    }

    // User documents
    match /users/{userId} {
      allow read, write: if isAuth() && isOwner(userId);

      // Devices subcollection
      match /devices/{deviceId} {
        allow read: if isAuth() && isOwner(userId);
        allow create: if isAuth() && isOwner(userId)
          && request.resource.data.keys().hasAll(['deviceName', 'deviceType', 'isActive']);
        allow update: if isAuth() && isOwner(userId);
        allow delete: if false; // Never delete, only revoke (isActive = false)
      }

      // Inventory subcollection
      match /inventory/{productId} {
        allow read: if isAuth() && isOwner(userId);
        allow create, update: if isAuth() && isOwner(userId)
          && isDeviceActive(userId, request.auth.token.device_id)
          && request.resource.data.keys().hasAll(['name', 'category']);
        allow delete: if isAuth() && isOwner(userId)
          && isDeviceActive(userId, request.auth.token.device_id);
      }

      // Settings subcollection
      match /settings/{settingId} {
        allow read, write: if isAuth() && isOwner(userId)
          && isDeviceActive(userId, request.auth.token.device_id);
      }

      // Health profiles (encrypted)
      match /health_profiles/{profileId} {
        allow read, write: if isAuth() && isOwner(userId)
          && isDeviceActive(userId, request.auth.token.device_id)
          && request.resource.data.keys().hasAll(['encryptedData', 'integrityHash']);
      }

      // Sync metadata
      match /sync_metadata/{metadataId} {
        allow read, write: if isAuth() && isOwner(userId);
      }

      // Conflict logs (append-only)
      match /conflict_logs/{logId} {
        allow create: if isAuth() && isOwner(userId);
        allow read: if isAuth() && isOwner(userId);
        allow update, delete: if false; // Immutable
      }
    }
  }
}
```

### 8. Delta Sync Implementation

```dart
// lib/core/data_sync/services/delta_sync_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class DeltaSyncService {
  final FirebaseFirestore _firestore;
  final String _userId;

  DeltaSyncService(this._firestore, this._userId);

  /// Sync only documents modified since last sync
  Future<void> performDeltaSync({
    required String collection,
    required DateTime lastSyncTime,
    required Box localBox,
    required Function(Map<String, dynamic>) fromJson,
  }) async {
    debugPrint('Starting delta sync for $collection since $lastSyncTime');

    try {
      // Query only changed documents
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collection)
          .where('_updatedAt', isGreaterThan: Timestamp.fromDate(lastSyncTime))
          .get();

      debugPrint('Found ${snapshot.docs.length} changed documents');

      // Update local storage
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final entity = fromJson({...data, 'id': doc.id});
        await localBox.put(doc.id, entity);
      }

      // Update last sync timestamp
      await _updateLastSyncTime(collection);

      debugPrint('Delta sync completed for $collection');
    } catch (e) {
      debugPrint('Delta sync failed: $e');
      rethrow;
    }
  }

  Future<void> _updateLastSyncTime(String collection) async {
    final settingsBox = Hive.box('settings_box');
    await settingsBox.put('${collection}_last_sync', DateTime.now().toIso8601String());
  }

  Future<DateTime> getLastSyncTime(String collection) async {
    final settingsBox = Hive.box('settings_box');
    final lastSyncStr = settingsBox.get('${collection}_last_sync') as String?;

    if (lastSyncStr == null) {
      // First sync: fetch all
      return DateTime.fromMicrosecondsSinceEpoch(0);
    }

    return DateTime.parse(lastSyncStr);
  }
}
```

### 9. UI Components

#### Device List Screen

```dart
// lib/features/auth_profile/presentation/screens/device_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/device_providers.dart';

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(userDevicesProvider);
    final currentDevice = ref.watch(currentDeviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDeviceInfoDialog(context),
          ),
        ],
      ),
      body: devicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading devices: $err'),
            ],
          ),
        ),
        data: (devices) {
          if (devices.isEmpty) {
            return const Center(
              child: Text('No devices found'),
            );
          }

          final activeDevices = devices.where((d) => d.isActive).toList();
          final revokedDevices = devices.where((d) => !d.isActive).toList();

          return ListView(
            children: [
              if (activeDevices.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Active Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...activeDevices.map((device) {
                  final isCurrent = device.deviceId == currentDevice?.deviceId;
                  return _DeviceListTile(
                    device: device,
                    isCurrent: isCurrent,
                    onRevoke: () => _revokeDevice(context, ref, device.deviceId),
                  );
                }),
              ],
              if (revokedDevices.isNotEmpty) ...[
                const Divider(height: 32),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Revoked Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...revokedDevices.map((device) {
                  return _DeviceListTile(
                    device: device,
                    isCurrent: false,
                    isRevoked: true,
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _revokeDevice(
    BuildContext context,
    WidgetRef ref,
    String deviceId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Device Access?'),
        content: const Text(
          'This device will be logged out and lose access to your data. '
          'The user can log in again to restore access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deviceService = ref.read(deviceServiceProvider);
        await deviceService.revokeDevice(deviceId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device access revoked')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showDeviceInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Devices'),
        content: const Text(
          'Manage all devices with access to your FrigoFute account. '
          'You can revoke access from any device at any time.\n\n'
          'Maximum 5 active devices allowed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _DeviceListTile extends StatelessWidget {
  final DeviceEntity device;
  final bool isCurrent;
  final bool isRevoked;
  final VoidCallback? onRevoke;

  const _DeviceListTile({
    required this.device,
    required this.isCurrent,
    this.isRevoked = false,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildDeviceIcon(),
      title: Row(
        children: [
          Text(device.deviceName),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'This Device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        '${device.osVersion} • Last seen: ${timeago.format(device.lastSeenAt)}',
        style: TextStyle(
          color: isRevoked ? Colors.grey : null,
        ),
      ),
      trailing: isCurrent || isRevoked
          ? null
          : PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: onRevoke,
                  child: const Row(
                    children: [
                      Icon(Icons.block, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Revoke Access'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDeviceIcon() {
    IconData icon;
    Color color;

    if (isRevoked) {
      icon = Icons.block;
      color = Colors.grey;
    } else if (device.deviceType == 'ios') {
      icon = Icons.phone_iphone;
      color = Colors.blue;
    } else if (device.deviceType == 'android') {
      icon = Icons.phone_android;
      color = Colors.green;
    } else {
      icon = Icons.devices;
      color = Colors.grey;
    }

    return Icon(icon, color: color, size: 32);
  }
}
```

#### Sync Status Indicator

```dart
// lib/core/data_sync/widgets/sync_status_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_providers.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider);

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const Icon(Icons.error, color: Colors.red),
      data: (status) {
        if (status == SyncStatus.synced && pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: _buildIcon(status, pendingCount),
          tooltip: _getTooltip(status, pendingCount),
          onPressed: () => _showSyncStatusDialog(context, status, pendingCount),
        );
      },
    );
  }

  Widget _buildIcon(SyncStatus status, int pendingCount) {
    switch (status) {
      case SyncStatus.synced:
        return const Icon(Icons.check_circle, color: Colors.green);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.offline:
        return Badge(
          label: Text(pendingCount.toString()),
          child: const Icon(Icons.cloud_off, color: Colors.orange),
        );
      case SyncStatus.error:
        return const Icon(Icons.error, color: Colors.red);
      case SyncStatus.queued:
        return Badge(
          label: Text(pendingCount.toString()),
          child: const Icon(Icons.schedule, color: Colors.amber),
        );
    }
  }

  String _getTooltip(SyncStatus status, int pendingCount) {
    switch (status) {
      case SyncStatus.synced:
        return 'All data synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.offline:
        return 'Offline - $pendingCount changes pending';
      case SyncStatus.error:
        return 'Sync error';
      case SyncStatus.queued:
        return '$pendingCount changes queued';
    }
  }

  void _showSyncStatusDialog(BuildContext context, SyncStatus status, int pendingCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pendingCount > 0)
              Text('$pendingCount changes pending sync'),
            if (status == SyncStatus.error)
              const Text('Some changes failed to sync. Check your connection.'),
          ],
        ),
        actions: [
          if (status == SyncStatus.error || status == SyncStatus.queued)
            TextButton(
              onPressed: () {
                // Trigger manual sync
                Navigator.pop(context);
              },
              child: const Text('Retry Sync'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
```

---

## IMPLEMENTATION TASKS

### Task 1: Initialize Device ID on App Start ✅
**Estimated Time**: 2 hours

- [ ] Install `uuid` package: `flutter pub add uuid`
- [ ] Install `shared_preferences` package if not already installed
- [ ] Create `DeviceService.getOrCreateDeviceId()` method
- [ ] Generate UUID v4 on first app install
- [ ] Store device ID in SharedPreferences with key `device_id`
- [ ] Return existing device ID on subsequent app launches
- [ ] Create Riverpod provider `deviceIdProvider` (FutureProvider)
- [ ] Initialize device ID in `main()` before runApp

**Files to Create/Modify:**
- `lib/features/auth_profile/data/services/device_service.dart`
- `lib/features/auth_profile/presentation/providers/device_providers.dart`
- `lib/main.dart`

**Testing:**
- Verify device ID persists across app restarts
- Verify device ID is same UUID on each launch

---

### Task 2: Implement Device Registration on Login ✅
**Estimated Time**: 4 hours

- [ ] Install packages: `device_info_plus`, `package_info_plus`
- [ ] Implement `DeviceService.registerDevice()` method
- [ ] Auto-detect device name using DeviceInfoPlugin
- [ ] Auto-detect device type (iOS/Android)
- [ ] Get OS version
- [ ] Get app version from PackageInfo
- [ ] Create Firestore document: `users/{userId}/devices/{deviceId}`
- [ ] Call `registerDevice()` after successful login/signup
- [ ] Handle registration errors gracefully

**Files to Create/Modify:**
- `lib/features/auth_profile/data/services/device_service.dart`
- `lib/features/auth_profile/presentation/providers/auth_providers.dart`

**Testing:**
- Login on 2 devices
- Verify both appear in Firestore `devices` subcollection
- Verify device metadata is accurate

---

### Task 3: Create DeviceEntity and Freezed Models ✅
**Estimated Time**: 2 hours

- [ ] Create `DeviceEntity` with Freezed
- [ ] Add all device fields (deviceId, deviceName, deviceType, etc.)
- [ ] Generate `device.freezed.dart` and `device.g.dart`
- [ ] Create `DeviceModel` in data layer with Hive annotations
- [ ] Create TypeAdapter for DeviceModel if needed
- [ ] Add fromJson/toJson methods

**Files to Create/Modify:**
- `lib/features/auth_profile/domain/entities/device.dart`
- `lib/features/auth_profile/data/models/device_model.dart`

**Testing:**
- Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Verify JSON serialization works
- Verify Freezed copyWith works

---

### Task 4: Implement Device List Stream Provider ✅
**Estimated Time**: 3 hours

- [ ] Create `DeviceService.watchAllDevices()` stream method
- [ ] Subscribe to Firestore `devices` subcollection snapshots
- [ ] Map snapshots to `List<DeviceEntity>`
- [ ] Sort devices by `lastSeenAt` (most recent first)
- [ ] Create Riverpod `userDevicesProvider` (StreamProvider)
- [ ] Create `currentDeviceProvider` to highlight current device
- [ ] Create `activeDeviceCountProvider` for device limit check

**Files to Create/Modify:**
- `lib/features/auth_profile/data/services/device_service.dart`
- `lib/features/auth_profile/presentation/providers/device_providers.dart`

**Testing:**
- Add device on Device A
- Verify Device B sees new device in list
- Verify current device is highlighted

---

### Task 5: Build Device List UI Screen ✅
**Estimated Time**: 6 hours

- [ ] Create `DeviceListScreen` with Riverpod ConsumerWidget
- [ ] Display loading/error/data states
- [ ] Show active devices section
- [ ] Show revoked devices section
- [ ] Display device icon (phone/tablet) based on type
- [ ] Show "This Device" badge for current device
- [ ] Format "last seen" with `timeago` package
- [ ] Add PopupMenuButton for device actions (Revoke)
- [ ] Navigate to screen from Settings → Devices

**Files to Create:**
- `lib/features/auth_profile/presentation/screens/device_list_screen.dart`
- `lib/features/auth_profile/presentation/widgets/device_list_tile.dart`

**Testing:**
- Open screen
- Verify devices display correctly
- Verify current device badge shows
- Verify last seen timestamps update

---

### Task 6: Implement Device Revocation ✅
**Estimated Time**: 4 hours

- [ ] Create `DeviceService.revokeDevice(deviceId)` method
- [ ] Show confirmation dialog before revoke
- [ ] Update Firestore: `isActive: false`, `revokedAt: timestamp`
- [ ] Add `revokedBy: currentDeviceId` field
- [ ] Show success/error snackbar
- [ ] Refresh device list after revocation
- [ ] Handle case where user tries to revoke current device (disallow)

**Files to Modify:**
- `lib/features/auth_profile/data/services/device_service.dart`
- `lib/features/auth_profile/presentation/screens/device_list_screen.dart`

**Testing:**
- Revoke Device B from Device A
- Verify Device B marked inactive in Firestore
- Verify revokedAt timestamp set
- Verify Device B moves to "Revoked" section

---

### Task 7: Implement Remote Logout Detection ✅
**Estimated Time**: 3 hours

- [ ] Create `DeviceService.setupDeviceRevocationListener()`
- [ ] Subscribe to current device document snapshots
- [ ] Detect when `isActive` changes to `false`
- [ ] Trigger logout when device is revoked
- [ ] Clear local Hive boxes
- [ ] Navigate to login screen
- [ ] Show notification: "Device access revoked remotely"
- [ ] Initialize listener in `main()` after authentication

**Files to Modify:**
- `lib/features/auth_profile/data/services/device_service.dart`
- `lib/main.dart`

**Testing:**
- Login on Device A and Device B
- Revoke Device B from Device A
- Verify Device B auto-logs out within 10 seconds
- Verify Device B redirects to login

---

### Task 8: Implement Firestore Security Rules ✅
**Estimated Time**: 3 hours

- [ ] Create `firestore.rules` file
- [ ] Add helper function `isAuth()`
- [ ] Add helper function `isOwner(userId)`
- [ ] Add helper function `isDeviceActive(userId, deviceId)`
- [ ] Add rules for `devices` subcollection
- [ ] Add rules for `inventory` subcollection (require active device)
- [ ] Add rules for `settings` subcollection
- [ ] Add rules for `health_profiles` (encrypted data validation)
- [ ] Add rules for `conflict_logs` (append-only)
- [ ] Deploy rules: `firebase deploy --only firestore:rules`

**Files to Create:**
- `firestore.rules`

**Testing:**
- Use Firestore Rules Simulator in Firebase Console
- Test: User A cannot read User B's data
- Test: Revoked device cannot write
- Test: Anonymous user cannot access any data

---

### Task 9: Implement Sync Queue with Hive ✅
**Estimated Time**: 5 hours

- [ ] Verify `SyncQueueItem` model exists (already in codebase)
- [ ] Create Hive box: `sync_queue_box`
- [ ] Register TypeAdapter for SyncQueueItem
- [ ] Create `SyncQueueManager` class
- [ ] Implement `queueOperation()` method
- [ ] Implement `processSyncQueue()` method
- [ ] Implement retry logic with exponential backoff
- [ ] Implement `getPendingOperationCount()` method
- [ ] Create Riverpod providers for sync queue

**Files to Create/Modify:**
- `lib/core/data_sync/services/sync_queue_manager.dart`
- `lib/core/data_sync/providers/sync_providers.dart`
- `lib/core/storage/hive_service.dart` (register TypeAdapter)

**Testing:**
- Add operation to queue
- Verify stored in Hive
- Process queue
- Verify operations reach Firestore
- Verify queue empties

---

### Task 10: Implement Offline Queue for Inventory Changes ✅
**Estimated Time**: 4 hours

- [ ] Modify `InventoryRepository` to queue writes when offline
- [ ] Detect offline state using `connectivity_plus`
- [ ] Save to local Hive immediately (optimistic update)
- [ ] Queue operation in `sync_queue_box`
- [ ] Show "Offline - X pending" indicator
- [ ] Persist queue across app restarts

**Files to Modify:**
- `lib/features/inventory/data/repositories/inventory_repository_impl.dart`
- `lib/core/data_sync/services/sync_queue_manager.dart`

**Testing:**
- Disable network
- Add 5 products
- Verify products saved locally
- Verify 5 items in sync queue
- Restart app
- Verify queue persists

---

### Task 11: Implement Auto-Sync on Network Restore ✅
**Estimated Time**: 4 hours

- [ ] Listen to connectivity changes using `connectivity_plus`
- [ ] Detect when network becomes available
- [ ] Automatically call `processSyncQueue()` within 5 seconds
- [ ] Show progress indicator: "Syncing X of Y"
- [ ] Show success banner when complete
- [ ] Handle sync failures gracefully

**Files to Create/Modify:**
- `lib/core/data_sync/services/connectivity_service.dart`
- `lib/core/data_sync/providers/sync_providers.dart`

**Testing:**
- Queue 10 changes offline
- Re-enable network
- Verify auto-sync starts within 5 seconds
- Verify all 10 reach Firestore
- Verify queue empties

---

### Task 12: Implement Real-Time Inventory Sync ✅
**Estimated Time**: 6 hours

- [ ] Create Firestore real-time listener for `inventory` collection
- [ ] Create Riverpod StreamProvider: `userInventoryProvider`
- [ ] Map Firestore snapshots to `List<Product>`
- [ ] Update local Hive on remote changes
- [ ] Handle snapshot changes (added, modified, deleted)
- [ ] Avoid infinite loops (local write → remote listener → local write)
- [ ] Use timestamp comparison to detect changes

**Files to Create/Modify:**
- `lib/features/inventory/data/repositories/inventory_repository_impl.dart`
- `lib/features/inventory/presentation/providers/inventory_providers.dart`

**Testing:**
- Open app on 2 devices
- Add product on Device A
- Verify appears on Device B within 3 seconds
- Verify Firestore timestamp matches

---

### Task 13: Implement Conflict Resolution (LWW) ✅
**Estimated Time**: 5 hours

- [ ] Create `ConflictResolutionService`
- [ ] Implement Last-Write-Wins strategy using `_version` field
- [ ] Compare Firestore server timestamps
- [ ] Higher version number wins
- [ ] If versions equal, newer timestamp wins
- [ ] Log conflicts to `conflict_logs` subcollection
- [ ] Integrate with sync queue processing

**Files to Create:**
- `lib/core/data_sync/services/conflict_resolution_service.dart`

**Testing:**
- Edit same product on 2 devices offline
- Bring both online
- Device with newer timestamp wins
- Verify conflict log in Firestore

---

### Task 14: Implement Delta Sync ✅
**Estimated Time**: 4 hours

- [ ] Create `DeltaSyncService`
- [ ] Store last sync timestamp in Hive settings
- [ ] Query Firestore: `where('_updatedAt', '>', lastSyncTime)`
- [ ] Fetch only changed documents
- [ ] Update local Hive with changes
- [ ] Update last sync timestamp after successful sync
- [ ] Implement for inventory, settings, health profiles

**Files to Create:**
- `lib/core/data_sync/services/delta_sync_service.dart`

**Testing:**
- Perform full sync
- Close app for 1 hour
- Add 20 products on Device B
- Open Device A
- Verify delta sync fetches only 20 products
- Verify via network logs

---

### Task 15: Implement Sync Status Indicator UI ✅
**Estimated Time**: 5 hours

- [ ] Create `SyncStatusIndicator` widget
- [ ] Show icon in app bar
- [ ] Icon variants:
  - Green checkmark: Synced
  - Spinning circle: Syncing
  - Orange cloud-off: Offline (with count badge)
  - Red error: Sync error
- [ ] Show tooltip on hover/long-press
- [ ] Show dialog on tap with details
- [ ] Add to main app scaffold

**Files to Create:**
- `lib/core/data_sync/widgets/sync_status_indicator.dart`

**Testing:**
- Check each sync state displays correct icon
- Tap icon → dialog shows details
- Offline state shows pending count

---

### Task 16: Implement Real-Time Settings Sync ✅
**Estimated Time**: 4 hours

- [ ] Create Firestore listener for `settings` collection
- [ ] Create Riverpod StreamProvider: `userSettingsProvider`
- [ ] Update local Hive on remote changes
- [ ] Sync notification preferences
- [ ] Sync theme preferences
- [ ] Sync unit preferences (metric/imperial)
- [ ] Apply settings changes to UI in real-time

**Files to Modify:**
- `lib/features/settings/data/repositories/settings_repository_impl.dart`
- `lib/features/settings/presentation/providers/settings_providers.dart`

**Testing:**
- Change notification settings on Device A
- Verify Device B reflects changes within 3 seconds
- Verify settings persist after app restart

---

### Task 17: Implement Encrypted Health Profile Sync ✅
**Estimated Time**: 6 hours

- [ ] Create `EncryptedHealthDataService`
- [ ] Encrypt health profile with AES-256 before upload
- [ ] Generate integrity hash (SHA-256)
- [ ] Upload encrypted blob to Firestore: `health_profiles/active`
- [ ] Download encrypted blob on other devices
- [ ] Verify integrity hash before decryption
- [ ] Decrypt locally using device-specific key
- [ ] Update local Hive with decrypted data

**Files to Create:**
- `lib/core/security/services/encrypted_health_data_service.dart`

**Testing:**
- Update health profile on Device A
- Check Firestore: verify `encryptedData` is base64
- Device B downloads and decrypts
- Verify decrypted data matches original

---

### Task 18: Implement Sync Metadata Tracking ✅
**Estimated Time**: 3 hours

- [ ] Create `SyncMetadata` model
- [ ] Store metadata in Firestore: `sync_metadata/latest`
- [ ] Track `lastFullSyncAt` timestamp
- [ ] Track `lastIncrementalSyncAt` timestamp
- [ ] Track `totalDevices` count
- [ ] Track `activeDevices` count
- [ ] Track `pendingChanges` count
- [ ] Update metadata after each sync operation

**Files to Create:**
- `lib/core/data_sync/models/sync_metadata.dart`

**Testing:**
- Perform sync
- Check Firestore `sync_metadata/latest`
- Verify timestamps are recent
- Verify counts match actual state

---

### Task 19: Implement Background Sync on App Launch ✅
**Estimated Time**: 4 hours

- [ ] Detect app launch from cold start
- [ ] Start background sync within 3 seconds
- [ ] Use Isolate or compute() for non-blocking sync
- [ ] Show progress indicator (non-blocking)
- [ ] Allow user to navigate while syncing
- [ ] Handle sync completion silently
- [ ] Log sync results

**Files to Modify:**
- `lib/main.dart`
- `lib/core/data_sync/services/background_sync_service.dart`

**Testing:**
- Close app completely
- Wait 5 minutes
- Reopen app
- Verify sync starts within 3 seconds
- Verify user can navigate immediately

---

### Task 20: Implement Manual Sync Trigger ✅
**Estimated Time**: 3 hours

- [ ] Add "Sync Now" button in Settings → Sync
- [ ] Trigger full sync on button tap
- [ ] Show progress dialog
- [ ] Show success toast: "All data synchronized"
- [ ] Show error message + retry option on failure
- [ ] Update `lastFullSyncAt` timestamp

**Files to Create:**
- `lib/features/settings/presentation/screens/sync_settings_screen.dart`

**Testing:**
- Tap "Sync Now"
- Verify sync completes within 10 seconds
- Verify success toast appears
- Verify Firestore timestamp updated

---

### Task 21: Implement Device Limit Check (Max 5) ✅
**Estimated Time**: 3 hours

- [ ] Check active device count before registration
- [ ] Show dialog if limit reached: "You have 5 devices. Revoke one to continue."
- [ ] List existing devices in dialog
- [ ] Allow user to revoke from dialog
- [ ] Complete registration after revocation
- [ ] Handle edge case: user cancels dialog

**Files to Modify:**
- `lib/features/auth_profile/data/services/device_service.dart`
- `lib/features/auth_profile/presentation/providers/auth_providers.dart`

**Testing:**
- Register 5 devices
- Attempt 6th login
- Dialog appears
- Revoke oldest device
- 6th device registers successfully

---

### Task 22: Implement Update Last Seen Timestamp ✅
**Estimated Time**: 2 hours

- [ ] Call `updateLastSeen()` on app launch
- [ ] Call `updateLastSeen()` on app resume from background
- [ ] Update Firestore: `lastSeenAt: serverTimestamp()`
- [ ] Throttle updates (max once per minute)
- [ ] Handle errors gracefully

**Files to Modify:**
- `lib/features/auth_profile/data/services/device_service.dart`
- `lib/main.dart` (AppLifecycleObserver)

**Testing:**
- Launch app
- Verify `lastSeenAt` updates in Firestore
- Background app for 2 minutes
- Resume app
- Verify `lastSeenAt` updates again

---

### Task 23: Implement Sync Retry Logic ✅
**Estimated Time**: 4 hours

- [ ] Detect sync operation failures (Firestore errors)
- [ ] Increment retry count in `SyncQueueItem`
- [ ] Implement exponential backoff: 5s, 10s, 20s
- [ ] Max 3 retries per operation
- [ ] Move failed operations to "Failed Sync" list
- [ ] Provide manual "Retry All" button
- [ ] Log retry attempts

**Files to Modify:**
- `lib/core/data_sync/services/sync_queue_manager.dart`

**Testing:**
- Simulate Firestore outage
- Queue 1 operation
- Verify 3 retry attempts with delays
- Operation appears in "Failed Sync" list
- Manual retry works

---

### Task 24: Add Sync Performance Monitoring ✅
**Estimated Time**: 3 hours

- [ ] Measure sync operation latency with Stopwatch
- [ ] Log performance metrics:
  - Single product sync time
  - Batch sync time (100 products)
  - Real-time propagation delay
- [ ] Send metrics to Firebase Performance Monitoring
- [ ] Alert if SLA violated (>10 seconds for 100 products)

**Files to Create:**
- `lib/core/data_sync/services/sync_performance_monitor.dart`

**Testing:**
- Add 100 products
- Measure batch sync time
- Verify meets SLA (<10 seconds)
- Check Firebase Performance dashboard

---

### Task 25: Implement Sync Notifications (Optional) ✅
**Estimated Time**: 4 hours

- [ ] Show local notification on sync failure
- [ ] Show notification: "Sync Failed - 5 changes pending"
- [ ] Show notification on sync success (optional)
- [ ] Show notification: "New device detected - [Device Name]"
- [ ] Notification tap opens sync status screen
- [ ] Use `flutter_local_notifications` package

**Files to Create:**
- `lib/core/notifications/services/sync_notification_service.dart`

**Testing:**
- Background app
- Trigger sync failure
- Verify notification appears
- Tap notification
- Verify opens sync status screen

---

### Task 26: Write Unit Tests for Device Service ✅
**Estimated Time**: 4 hours

- [ ] Test device ID generation and persistence
- [ ] Test device registration
- [ ] Test device revocation
- [ ] Test device list fetching
- [ ] Test remote logout detection
- [ ] Mock Firestore and FirebaseAuth
- [ ] Use `mockito` or `mocktail`

**Files to Create:**
- `test/features/auth_profile/data/services/device_service_test.dart`

**Target Coverage**: 80%

---

### Task 27: Write Unit Tests for Sync Queue Manager ✅
**Estimated Time**: 4 hours

- [ ] Test queueing operations
- [ ] Test processing queue
- [ ] Test retry logic
- [ ] Test exponential backoff
- [ ] Test max retries
- [ ] Mock Firestore and Hive
- [ ] Test edge cases (empty queue, network failures)

**Files to Create:**
- `test/core/data_sync/services/sync_queue_manager_test.dart`

**Target Coverage**: 85%

---

### Task 28: Write Integration Tests for Multi-Device Sync ✅
**Estimated Time**: 6 hours

- [ ] Test: Add product on Device A → appears on Device B
- [ ] Test: Edit product on Device A → updates on Device B
- [ ] Test: Delete product on Device A → removes on Device B
- [ ] Test: Conflict resolution (concurrent edits)
- [ ] Test: Offline queue → auto-sync on network restore
- [ ] Test: Device revocation → remote logout
- [ ] Use Firebase Emulator Suite

**Files to Create:**
- `integration_test/multi_device_sync_test.dart`

**Target**: 5-10 test scenarios

---

### Task 29: Write E2E Tests for Device Management ✅
**Estimated Time**: 4 hours

- [ ] Test: Register device on login
- [ ] Test: View device list
- [ ] Test: Revoke device
- [ ] Test: Device limit (max 5)
- [ ] Test: Remote logout after revocation
- [ ] Use `flutter_test` and Firebase Emulator

**Files to Create:**
- `integration_test/device_management_test.dart`

**Target**: 5-8 test scenarios

---

### Task 30: Accessibility Testing ✅
**Estimated Time**: 2 hours

- [ ] Test screen reader on DeviceListScreen
- [ ] Test sync status indicator with TalkBack/VoiceOver
- [ ] Ensure all interactive elements have semantic labels
- [ ] Test keyboard navigation (for web/desktop)
- [ ] Verify color contrast for sync status icons

**Files to Modify:**
- Add semantic labels to all widgets

**Testing:**
- Enable TalkBack (Android) or VoiceOver (iOS)
- Navigate through device list
- Verify all elements are announced

---

### Task 31: Update Architecture Diagrams ✅
**Estimated Time**: 2 hours

- [ ] Create multi-device sync flow diagram
- [ ] Document Firestore collection structure
- [ ] Document conflict resolution flow
- [ ] Document offline queue architecture
- [ ] Add diagrams to `docs/architecture/`

**Files to Create:**
- `docs/architecture/multi_device_sync.md`
- `docs/architecture/diagrams/sync_flow.png`

---

### Task 32: Write Developer Documentation ✅
**Estimated Time**: 3 hours

- [ ] Document Device Service API
- [ ] Document SyncQueueManager API
- [ ] Document conflict resolution strategy
- [ ] Add code examples for common tasks
- [ ] Document troubleshooting steps
- [ ] Add to `docs/features/multi_device_sync.md`

**Files to Create:**
- `docs/features/multi_device_sync.md`

---

### Task 33: Performance Optimization ✅
**Estimated Time**: 4 hours

- [ ] Optimize Firestore queries with indexes
- [ ] Batch write operations when possible
- [ ] Debounce rapid changes (e.g., typing)
- [ ] Implement pagination for device list (if >20 devices)
- [ ] Optimize real-time listeners (limit to active screen)
- [ ] Profile with DevTools

**Files to Modify:**
- `firestore.indexes.json`
- Various repository files

**Testing:**
- Measure sync performance with 1000+ products
- Verify no UI jank
- Check memory usage

---

### Task 34: Security Audit ✅
**Estimated Time**: 3 hours

- [ ] Review Firestore Security Rules
- [ ] Test rules with Firestore Rules Simulator
- [ ] Verify encrypted health data cannot be read in Firestore Console
- [ ] Test device revocation prevents further writes
- [ ] Test cross-user data isolation
- [ ] Document security considerations

**Files to Review:**
- `firestore.rules`

**Testing:**
- Attempt to read other user's data
- Attempt to write from revoked device
- Verify all blocked by rules

---

### Task 35: User Acceptance Testing ✅
**Estimated Time**: 4 hours

- [ ] Test on 3 real devices (2 phones + 1 tablet)
- [ ] Add 100+ products and sync
- [ ] Test offline → online transitions
- [ ] Test device revocation flow
- [ ] Test conflict resolution with real concurrent edits
- [ ] Gather feedback from beta testers
- [ ] Fix any UX issues discovered

**Testing:**
- Real-world usage scenario
- Multiple users testing simultaneously

---

**Total Estimated Time**: 120-140 hours (~3-4 weeks for 1 developer)

---

## TESTING STRATEGY

### Unit Tests (Target: 80% Coverage)

#### Device Service Tests
```dart
// test/features/auth_profile/data/services/device_service_test.dart

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late DeviceService deviceService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    deviceService = DeviceService(mockAuth, mockFirestore, 'test-device-id');
  });

  group('Device Registration', () {
    test('should register device with correct metadata', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockFirestore.collection('users').doc(any).collection('devices').doc(any))
        .thenReturn(mockDocRef);

      // Act
      await deviceService.registerDevice();

      // Assert
      verify(mockDocRef.set(argThat(containsPair('deviceId', 'test-device-id'))));
      verify(mockDocRef.set(argThat(containsPair('isActive', true))));
    });

    test('should throw exception if user not authenticated', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(() => deviceService.registerDevice(), throwsException);
    });
  });

  group('Device Revocation', () {
    test('should mark device as inactive', () async {
      // Test implementation
    });

    test('should set revokedAt timestamp', () async {
      // Test implementation
    });
  });
}
```

#### Sync Queue Manager Tests
```dart
// test/core/data_sync/services/sync_queue_manager_test.dart

void main() {
  late MockBox<SyncQueueItem> mockBox;
  late MockFirebaseFirestore mockFirestore;
  late SyncQueueManager syncQueueManager;

  setUp(() {
    mockBox = MockBox<SyncQueueItem>();
    mockFirestore = MockFirebaseFirestore();
    syncQueueManager = SyncQueueManager(mockBox, mockFirestore, 'test-user');
  });

  group('Queue Operations', () {
    test('should add item to queue', () async {
      // Test implementation
    });

    test('should process queue successfully', () async {
      // Test implementation
    });
  });

  group('Retry Logic', () {
    test('should retry failed operation with exponential backoff', () async {
      // Test implementation
    });

    test('should stop retrying after max attempts', () async {
      // Test implementation
    });
  });
}
```

### Integration Tests (Target: 5-10 Scenarios)

```dart
// integration_test/multi_device_sync_test.dart

void main() {
  testWidgets('Device A adds product, Device B sees it', (tester) async {
    // Arrange: Login on 2 devices
    await tester.pumpWidget(MyApp());
    await loginAsUser1();

    // Act: Add product on Device A
    await tester.tap(find.byIcon(Icons.add));
    await tester.enterText(find.byKey(Key('product_name')), 'Tomatoes');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Assert: Verify appears in Firestore
    final firestoreDoc = await FirebaseFirestore.instance
      .collection('users/$userId/inventory')
      .where('name', isEqualTo: 'Tomatoes')
      .get();
    expect(firestoreDoc.docs.length, 1);

    // Simulate Device B receiving update via listener
    // (Would require real multi-device setup or emulator)
  });

  testWidgets('Conflict resolution: Last-Write-Wins', (tester) async {
    // Test concurrent edits on same product
  });

  testWidgets('Offline queue syncs when back online', (tester) async {
    // Test offline → queue → online → auto-sync
  });
}
```

### E2E Tests (Target: 5-8 Scenarios)

```dart
// integration_test/device_management_test.dart

void main() {
  testWidgets('User can view all devices', (tester) async {
    await tester.pumpWidget(MyApp());
    await loginAsUser();

    // Navigate to Settings → Devices
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Devices'));
    await tester.pumpAndSettle();

    // Verify device list appears
    expect(find.byType(DeviceListScreen), findsOneWidget);
    expect(find.text('This Device'), findsOneWidget);
  });

  testWidgets('User can revoke device', (tester) async {
    // Test revocation flow
  });
}
```

### Manual Testing Checklist

- [ ] Test on 3 real devices (iOS + Android + tablet)
- [ ] Add 100+ products and verify sync performance
- [ ] Test airplane mode → offline queue → back online
- [ ] Test concurrent edits on same product from 2 devices
- [ ] Test device revocation → verify remote logout
- [ ] Test device limit (register 6th device)
- [ ] Test encrypted health profile sync
- [ ] Test poor network conditions (throttle to 3G)
- [ ] Test app kill during sync
- [ ] Verify Firestore Security Rules block unauthorized access

---

## ANTI-PATTERNS TO AVOID

### ❌ Anti-Pattern 1: Syncing Entire Dataset on Every Launch

**Problem**: Downloading all data from Firestore on each app launch is inefficient and slow.

**Solution**: Use delta sync with `_updatedAt` timestamp filtering to fetch only changed documents since last sync.

---

### ❌ Anti-Pattern 2: Infinite Sync Loops

**Problem**: Local write → Firestore → Listener triggers → Local write → Firestore → ...

**Solution**:
- Use `_version` field to detect changes
- Compare timestamps before writing
- Debounce rapid changes

```dart
// BAD
firestoreStream.listen((snapshot) {
  localBox.put(snapshot.id, snapshot.data); // Triggers another write!
});

// GOOD
firestoreStream.listen((snapshot) {
  final local = localBox.get(snapshot.id);
  if (local == null || snapshot.data['_version'] > local.version) {
    localBox.put(snapshot.id, snapshot.data); // Only if newer
  }
});
```

---

### ❌ Anti-Pattern 3: Blocking UI During Sync

**Problem**: Long sync operations freeze the UI, poor UX.

**Solution**:
- Use background isolates for heavy sync
- Show non-blocking progress indicators
- Allow user to navigate while syncing

---

### ❌ Anti-Pattern 4: Storing Unencrypted Health Data in Firestore

**Problem**: Health data (weight, allergies) is sensitive and must be encrypted.

**Solution**: Always encrypt health profiles with AES-256 before uploading to Firestore.

---

### ❌ Anti-Pattern 5: Not Handling Conflict Resolution

**Problem**: Concurrent edits on same document from 2 devices result in data loss.

**Solution**: Implement Last-Write-Wins or CRDT conflict resolution strategy.

---

### ❌ Anti-Pattern 6: Forgetting to Revoke Devices on Logout

**Problem**: User logs out but device remains active, can still sync data.

**Solution**: Mark device as `isActive: false` on logout.

---

### ❌ Anti-Pattern 7: Not Throttling Last Seen Updates

**Problem**: Updating `lastSeenAt` on every app interaction spams Firestore writes.

**Solution**: Throttle updates to once per minute maximum.

---

### ❌ Anti-Pattern 8: Querying Firestore Without Indexes

**Problem**: Complex queries (`where` + `orderBy`) fail without indexes.

**Solution**: Add Firestore indexes via `firestore.indexes.json` and deploy with Firebase CLI.

---

## INTEGRATION POINTS

### 1. Authentication Module (Epic 1)
- Device registration triggered after login (Story 1.1, 1.2, 1.3, 1.4)
- Device revocation triggers logout
- Auth state changes affect sync service

### 2. Inventory Module (Epic 2)
- Inventory changes queue for sync
- Real-time inventory sync across devices
- Offline inventory edits persist in sync queue

### 3. Settings Module (Epic 16)
- Settings changes sync across devices
- Device list accessible from Settings screen
- Sync settings screen (manual sync trigger)

### 4. Health Profile Module (Epic 1)
- Encrypted health profile sync
- Weight history syncs across devices
- Dietary preferences sync

### 5. Offline-First Architecture (Story 0.9)
- Builds on existing `SyncService` and `SyncStatus`
- Uses existing Hive boxes
- Integrates with connectivity detection

### 6. Firebase Services
- Firestore for real-time sync
- Firestore Security Rules for access control
- Firebase Auth for device authentication
- Firebase Performance Monitoring for sync metrics
- Firebase Crashlytics for error tracking

### 7. Notifications Module
- Sync failure notifications
- New device detected notifications

---

## DEV NOTES

### 1. Firebase Emulator Suite for Testing

Use Firebase Emulator Suite for local testing without affecting production data:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize emulators
firebase init emulators

# Start emulators (Firestore, Auth)
firebase emulators:start
```

Connect Flutter app to emulators:

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    // Use emulators in debug mode
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  runApp(MyApp());
}
```

---

### 2. Firestore Indexes Required

Create `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "inventory",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "_updatedAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "devices",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "lastSeenAt", "order": "DESCENDING"}
      ]
    }
  ]
}
```

Deploy indexes:

```bash
firebase deploy --only firestore:indexes
```

---

### 3. Device ID Generation Strategy

Use UUID v4 for device IDs:

```dart
import 'package:uuid/uuid.dart';

final deviceId = const Uuid().v4();
// Example: "550e8400-e29b-41d4-a716-446655440000"
```

Store in SharedPreferences for persistence across app restarts.

---

### 4. Handling Firestore Offline Persistence

Firestore SDK has built-in offline persistence. Enable it:

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(MyApp());
}
```

---

### 5. Sync Queue Persistence

Use Hive for sync queue persistence:

```dart
// lib/main.dart
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SyncQueueItemAdapter());
  await Hive.openBox<SyncQueueItem>('sync_queue_box');

  runApp(MyApp());
}
```

Queue persists across app restarts automatically.

---

### 6. Conflict Resolution Logging

Log conflicts for debugging and analytics:

```dart
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('conflict_logs')
  .add({
    'entityId': productId,
    'localVersion': 5,
    'remoteVersion': 6,
    'resolutionStrategy': 'lww',
    'timestamp': FieldValue.serverTimestamp(),
  });
```

---

### 7. Performance Considerations

- **Batch Writes**: Use `WriteBatch` for multiple operations
- **Debounce Rapid Changes**: Delay sync for 500ms after last change
- **Pagination**: Limit device list to 20 per page if needed
- **Background Sync**: Use Isolates for heavy sync operations

---

### 8. Security Best Practices

- Never store device encryption keys in Firestore
- Always validate device `isActive` status before allowing writes
- Use Firestore Security Rules as primary defense
- Encrypt all health data before upload
- Audit device revocation logs regularly

---

### 9. Debugging Multi-Device Sync

Use Firestore Console to inspect real-time data:

1. Open Firebase Console → Firestore Database
2. Navigate to `users/{userId}/inventory`
3. Watch documents update in real-time as devices sync
4. Check `_updatedAt` and `_version` fields

---

### 10. Handling Timezone Issues

Always use Firestore server timestamps to avoid timezone issues:

```dart
// GOOD
'_updatedAt': FieldValue.serverTimestamp(),

// BAD
'_updatedAt': DateTime.now().toIso8601String(), // Device timezone!
```

---

## DEFINITION OF DONE

### Code Complete ✅

- [ ] All 35 implementation tasks completed
- [ ] Code passes `flutter analyze` with no errors
- [ ] Code formatted with `flutter format .`
- [ ] No console warnings or errors
- [ ] All TODO comments resolved

### Testing Complete ✅

- [ ] Unit tests written for Device Service (80% coverage)
- [ ] Unit tests written for Sync Queue Manager (85% coverage)
- [ ] Integration tests written (5-10 scenarios)
- [ ] E2E tests written (5-8 scenarios)
- [ ] Manual testing on 3 real devices passed
- [ ] Accessibility testing passed (TalkBack/VoiceOver)
- [ ] All 20 acceptance criteria verified

### Documentation Complete ✅

- [ ] Developer documentation written
- [ ] Architecture diagrams created
- [ ] API documentation complete
- [ ] Code comments added for complex logic
- [ ] README updated with multi-device sync setup

### Deployment Complete ✅

- [ ] Firestore Security Rules deployed
- [ ] Firestore indexes deployed
- [ ] Firebase emulator configurations saved
- [ ] Feature flag enabled (if applicable)

### Performance Verified ✅

- [ ] Single product sync: < 2 seconds
- [ ] Batch sync (100 products): < 10 seconds
- [ ] Real-time propagation: < 3 seconds
- [ ] No memory leaks detected
- [ ] No UI jank during sync

### Security Verified ✅

- [ ] Firestore Security Rules tested
- [ ] Cross-user data isolation verified
- [ ] Revoked devices cannot write
- [ ] Health data encryption verified
- [ ] Security audit passed

### User Acceptance ✅

- [ ] Product Owner approval
- [ ] Beta testers feedback positive
- [ ] No critical bugs reported
- [ ] UX flows intuitive and smooth

---

## REFERENCES

### Official Documentation

1. **Firebase Firestore**
   - https://firebase.google.com/docs/firestore
   - Real-time listeners: https://firebase.google.com/docs/firestore/query-data/listen
   - Security Rules: https://firebase.google.com/docs/firestore/security/get-started

2. **FlutterFire**
   - https://firebase.flutter.dev/
   - cloud_firestore plugin: https://pub.dev/packages/cloud_firestore
   - firebase_auth plugin: https://pub.dev/packages/firebase_auth

3. **Riverpod**
   - https://riverpod.dev/
   - StreamProvider: https://riverpod.dev/docs/providers/stream_provider

4. **Hive**
   - https://docs.hivedb.dev/
   - TypeAdapters: https://docs.hivedb.dev/#/custom-objects/type_adapters

### Packages Used

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.12.0
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0

  # State Management
  flutter_riverpod: ^2.6.1

  # Local Storage
  hive: ^2.8.0
  hive_flutter: ^1.1.0

  # Utilities
  uuid: ^4.5.1
  device_info_plus: ^11.2.0
  package_info_plus: ^8.1.2
  connectivity_plus: ^6.2.0
  shared_preferences: ^2.3.4

  # UI
  timeago: ^3.7.0

  # Notifications
  flutter_local_notifications: ^18.0.1

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.14
  freezed: ^2.5.8
  json_serializable: ^6.9.2
  hive_generator: ^2.0.1

  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

### Related Stories

- **Story 0.3**: Set Up Hive Local Database for Offline Storage
- **Story 0.4**: Implement Riverpod State Management Foundation
- **Story 0.9**: Implement Offline-First Sync Architecture Foundation
- **Story 1.1**: Create Account with Email and Password
- **Story 1.2**: Login with Email and Password
- **Story 1.6**: Configure Personal Profile with Physical Characteristics
- **Story 1.7**: Set Dietary Preferences and Allergies

### External Resources

1. **Conflict-Free Replicated Data Types (CRDT)**
   - https://crdt.tech/
   - Research papers on distributed systems

2. **Offline-First Architecture**
   - https://offlinefirst.org/
   - Best practices for offline-first mobile apps

3. **Firestore Data Modeling**
   - https://firebase.google.com/docs/firestore/manage-data/structure-data
   - NoSQL data modeling patterns

4. **Multi-Device Sync Patterns**
   - Google I/O talks on Firebase sync
   - Case studies: Evernote, Dropbox, Notion

---

## STORY CARD SUMMARY

**Story 1.8: Synchronize Data Across Multiple Devices**

**Epic**: User Authentication & Profile Management
**Points**: 13
**Priority**: High

**Summary**: Implement real-time multi-device synchronization using Firestore, allowing users to seamlessly access their inventory, settings, and profile data across all their devices. Features include device management, offline queue, conflict resolution (Last-Write-Wins), real-time listeners, encrypted health data sync, and device revocation.

**Key Features**:
- Device registration and management (max 5 devices)
- Real-time sync for inventory, settings, health profiles
- Offline queue with auto-sync on network restore
- Last-Write-Wins conflict resolution
- Device revocation with remote logout
- Encrypted health data sync
- Sync status indicators and manual sync trigger

**Success Metrics**:
- Sync latency: < 3 seconds between devices
- Offline queue processes at 10 ops/second
- Zero data loss during sync
- 95%+ sync success rate

**Risks**:
- Firestore costs scale with device count
- Complex conflict resolution edge cases
- Network partition scenarios

**Estimated Development Time**: 3-4 weeks (1 developer)

---

**End of Story 1.8**
