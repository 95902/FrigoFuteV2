# Story 1.10: Delete Account and All Data Permanently

## METADATA

- **Story ID**: 1.10
- **Epic**: Epic 1 - User Authentication & Profile Management
- **Title**: Delete Account and All Data Permanently
- **Story Points**: 8
- **Priority**: High (Legal Compliance - RGPD Article 17)
- **Sprint**: TBD
- **Status**: ready-for-dev
- **Created**: 2026-02-15
- **Updated**: 2026-02-15
- **Tags**: #rgpd #gdpr #account-deletion #right-to-erasure #compliance #privacy
- **Dependencies**:
  - Story 1.1 (Create Account)
  - Story 1.8 (Multi-Device Sync - revoke all devices)
  - Story 1.9 (Export Data - suggest export before deletion)
  - All data features (Epic 2-16)

---

## USER STORY

**As a** FrigoFute user who wants to stop using the app
**I want** to permanently delete my account and all my personal data
**So that** I can exercise my right to erasure (RGPD Article 17) and ensure my data is completely removed from FrigoFute's systems

### User Value Proposition

Under RGPD (GDPR) Article 17 "Right to Erasure" (also known as "Right to be Forgotten"), users have the fundamental right to request deletion of their personal data without undue delay. This empowers users to:

- **Control**: Full control over their personal information
- **Privacy**: Ensure data is not retained indefinitely
- **Security**: Reduce attack surface for their personal data
- **Legal Right**: Exercise their fundamental RGPD rights
- **Peace of Mind**: Know their data won't be misused

### Business Value

- **Legal Compliance**: RGPD Article 17 is mandatory for EU operations
- **User Trust**: Demonstrates transparency and respect for privacy rights
- **Competitive Advantage**: Many apps make deletion difficult - easy deletion builds trust
- **Avoid Penalties**: Non-compliance can result in fines up to €20M or 4% of global revenue
- **Brand Reputation**: Ethical data handling improves brand perception

### Legal Context (RGPD Article 17)

**Scope**: Right applies when:
- Data is no longer necessary for its original purpose
- User withdraws consent and there's no other legal basis
- User objects to processing based on legitimate interests
- Data was unlawfully processed
- Erasure is required to comply with legal obligation

**Requirements**:
- Delete data "without undue delay" and "at the latest within one month"
- Provide **free of charge** deletion
- Confirm deletion to the user
- Notify data processors to delete data
- Keep only data required by law (audit logs, tax records)

---

## ACCEPTANCE CRITERIA

### AC-1: Access Delete Account Screen ✅

**Given** a user is logged in
**When** user navigates to Settings → Account → "Delete Account"
**Then**:
- Delete account screen displays
- Screen shows RGPD Article 17 explanation
- Lists what will be deleted with counts
- Explains 30-day grace period
- Shows warning about consequences
- Button: "Continue to Confirmation"

**Verification:**
- Navigate to Settings → Account
- Tap "Delete Account"
- Screen appears with legal text and data summary

---

### AC-2: View What Will Be Deleted ✅

**Given** user is on Delete Account screen
**When** screen loads
**Then** user sees a complete list:
- ✓ Profile information (email, name, photo)
- ✓ Health profile (weight, BMR, TDEE, allergies) - 1 profile
- ✓ Inventory products - 1,247 items
- ✓ Nutrition history - 342 entries
- ✓ Weight history - 150 measurements
- ✓ Settings and preferences
- ✓ Device registration data - 3 devices
- ✓ Recipes saved/created - 15 recipes
- ✓ Meal plans - 4 plans
- ✓ Shopping lists
- ✓ All files and photos

**Verification:**
- Checklist shows all data categories
- Item counts displayed dynamically
- Clear, user-friendly language

---

### AC-3: 30-Day Grace Period Explanation ✅

**Given** user is reviewing deletion details
**When** viewing deletion screen
**Then**:
- Prominent notice: "30-day grace period"
- Explanation: "You can recover your account within 30 days"
- Details: "After 30 days, deletion is permanent and irreversible"
- Recovery method: "Recovery link sent to your email"

**Verification:**
- Grace period clearly explained
- Recovery process described
- Final deadline shown

---

### AC-4: Password Re-authentication Required ✅

**Given** user confirms they want to delete account
**When** user taps "Continue to Confirmation"
**Then**:
- Password re-authentication dialog appears
- For email/password users: Password input field
- For OAuth users (Google, Apple): OAuth re-authentication
- Error message if password incorrect
- Cannot proceed without successful authentication

**Verification:**
- Tap "Continue"
- Password dialog appears
- Enter wrong password → error
- Enter correct password → proceed
- OAuth users see provider login

---

### AC-5: Strong Confirmation with Checkboxes ✅

**Given** user has re-authenticated
**When** confirmation screen loads
**Then** user must check ALL boxes to enable deletion:
- ☐ "I understand all my data will be permanently deleted"
- ☐ "I understand I have 30 days to recover my account"
- ☐ "I understand I must create a new account to use FrigoFute again"

**And**:
- "Delete Account Permanently" button disabled until all checked
- Button styled as danger (red)
- "Cancel" button available to abort

**Verification:**
- Checkboxes required
- Button disabled until all checked
- Button styling indicates danger
- Can cancel at any step

---

### AC-6: Suggest Data Export Before Deletion ✅

**Given** user is about to delete account
**When** user views delete confirmation
**Then**:
- Dialog suggests: "Export your data before deleting?"
- Link to Export Data screen (Story 1.9)
- Option to "Export Now" or "Skip and Delete"
- If "Export Now": navigate to export screen first

**Verification:**
- Export suggestion appears
- Can export before deletion
- Can skip export

---

### AC-7: Soft Delete (Immediate) ✅

**Given** user confirms final deletion
**When** deletion starts
**Then**:
- Account marked as `deletion_status: 'pending_hard_delete'`
- Timestamp `deleted_at` set to now
- Hard delete scheduled for 30 days from now
- User logged out immediately
- User cannot login (except with recovery link)
- Recovery email sent with recovery link
- Account invisible to other users

**Verification:**
- Check Firestore: `deleted_at` field present
- Check Firestore: `deletion_status` = 'pending_hard_delete'
- Check Firestore: `hard_delete_scheduled_at` = now + 30 days
- User logged out
- Cannot login with credentials

---

### AC-8: Deletion Progress Indicator ✅

**Given** soft delete is in progress
**When** deletion runs
**Then**:
- Progress screen displays
- Shows steps:
  - "Logging out all devices..." (20%)
  - "Marking account for deletion..." (40%)
  - "Scheduling permanent deletion..." (60%)
  - "Sending recovery email..." (80%)
  - "Completing logout..." (100%)
- Cannot navigate away during deletion
- Shows estimated time

**Verification:**
- Progress bar animates
- Current step displays
- Cannot back out mid-process

---

### AC-9: Success Screen After Soft Delete ✅

**Given** soft delete completes successfully
**When** deletion finishes
**Then**:
- Success screen displays
- Message: "Your account has been scheduled for deletion"
- Details:
  - "You have 30 days to recover your account"
  - "Recovery link sent to your email"
  - "You will be logged out in 3 seconds"
  - "Permanent deletion on: [DATE]"
- Auto-redirect to login screen after 3 seconds

**Verification:**
- Success message clear
- Timeline explained
- Auto-redirect works

---

### AC-10: Recovery Email Sent ✅

**Given** soft delete completed
**When** deletion confirmed
**Then** user receives email:
- Subject: "Account Deletion Scheduled"
- Content:
  - Account will be deleted in 30 days
  - List of what will be deleted
  - Recovery link (valid for 30 days)
  - Explanation: Click link anytime to recover
  - Final deletion date
  - Support contact

**Verification:**
- Email arrives within 1 minute
- Recovery link works
- Email professionally formatted

---

### AC-11: Account Recovery During Grace Period ✅

**Given** user clicked recovery link in email
**When** recovery link is valid (< 30 days old)
**Then**:
- Recovery screen displays
- Shows: "Recover Your Account?"
- Details: Account was scheduled for deletion on [DATE]
- Button: "Recover My Account"
- On confirm:
  - `deleted_at` field removed
  - `deletion_status` set to 'active'
  - Recovery token invalidated
  - User can login normally
  - Confirmation email sent

**Verification:**
- Click recovery link
- Account restored
- Can login again
- All data intact

---

### AC-12: Recovery Link Expires After 30 Days ✅

**Given** 30 days have passed since soft delete
**When** user clicks recovery link
**Then**:
- Error screen displays
- Message: "Recovery period expired"
- Details: "Your account was permanently deleted on [DATE]"
- Recovery no longer possible
- Link to create new account

**Verification:**
- After 30 days, link shows error
- Cannot recover
- Clear messaging

---

### AC-13: Hard Delete After 30 Days (Automatic) ✅

**Given** 30 days have passed since soft delete
**When** Cloud Function scheduled task runs
**Then**:
- **Firestore data deleted**:
  - User document deleted
  - All subcollections deleted (inventory, nutrition, health, settings, devices, etc.)
- **Firebase Auth deleted**:
  - User account deleted from Auth
- **Cloud Storage deleted**:
  - All user files deleted (profile photos, product photos)
- **Hive local data** (user's devices):
  - Cleared on next app launch attempt
- **Audit log created**:
  - Anonymized deletion record (user ID hash, timestamp)
- **Final confirmation email sent**:
  - "Your account has been permanently deleted"

**Verification:**
- After 31 days, run Cloud Function manually
- Check Firestore: user doc not found
- Check Auth: user not found
- Check Storage: files not found
- Check audit logs: entry created

---

### AC-14: Revoke All Device Access on Soft Delete ✅

**Given** user has 3 active devices
**When** soft delete happens
**Then**:
- All devices marked as `isActive: false`
- Push notification sent to all devices: "Account deleted"
- Each device auto-logs out on next activity
- Devices cannot write to Firestore (Security Rules block)

**Verification:**
- Check Firestore: all devices `isActive: false`
- Devices receive logout notification
- Devices redirect to login

---

### AC-15: Prevent Deletion with Active Subscription ✅

**Given** user has active premium subscription
**When** user attempts to delete account
**Then**:
- Warning dialog appears
- Message: "Cancel your subscription first"
- Details: "Your subscription is active until [DATE]"
- Link to subscription management
- Cannot proceed with deletion until subscription cancelled

**Verification:**
- Active subscription blocks deletion
- Can cancel subscription
- After cancellation, can delete

---

### AC-16: Handle Deletion Failures Gracefully ✅

**Given** deletion encounters error (network, Firestore timeout)
**When** error occurs during deletion
**Then**:
- Error screen displays
- Message: "Account deletion failed"
- Technical details (in debug mode)
- Retry button: "Try Again"
- Cancel button: "Cancel Deletion"
- Error logged to Crashlytics
- No partial deletions (rollback if needed)

**Verification:**
- Simulate Firestore error
- Error screen appears
- Can retry
- Can cancel
- No data lost

---

### AC-17: Audit Log for Deletion Request ✅

**Given** RGPD compliance requirement
**When** user requests deletion
**Then**:
- Deletion request logged to Firestore `audit_logs`
- Log includes:
  - Timestamp
  - User ID (hashed for anonymization)
  - Reason (if provided)
  - Soft delete timestamp
  - Scheduled hard delete timestamp
  - User agent (app version)
- Log retained for 3 years (legal requirement)

**Verification:**
- Check Firestore `audit_logs` collection
- Verify entry created
- User ID is hashed (not plaintext)

---

### AC-18: Cannot Delete Account Twice ✅

**Given** account already marked for deletion
**When** user attempts to delete again
**Then**:
- Dialog: "Account already scheduled for deletion"
- Details: "Permanent deletion on: [DATE]"
- Option: "View Recovery Link"
- Option: "Cancel Deletion (Recover Now)"

**Verification:**
- Soft delete once
- Attempt again → blocked
- Shows existing deletion status

---

### AC-19: Legal Data Retention (Exceptions) ✅

**Given** RGPD Article 17 exceptions
**When** hard delete runs
**Then** the following are NOT deleted:
- ❌ Audit logs (3-year retention)
- ❌ Tax/payment records (7-year retention, if applicable)
- ❌ Anonymized analytics data
- ❌ Legal hold data (if court order exists)

**And** audit log entry explains:
- "Retained data: Audit logs (3 years), Tax records (7 years)"

**Verification:**
- After hard delete, check audit logs still exist
- User ID in audit logs is hashed
- Payment records retained (if applicable)

---

### AC-20: Final Deletion Confirmation Email ✅

**Given** hard delete completed (after 30 days)
**When** Cloud Function finishes deletion
**Then** user receives final email:
- Subject: "Your Account Has Been Permanently Deleted"
- Content:
  - Account permanently deleted on [DATE]
  - All data removed from systems
  - Recovery no longer possible
  - Thank you for using FrigoFute
  - Link to create new account (if they change mind)

**Verification:**
- Email sent after hard delete
- Professional and respectful tone
- Confirms final deletion

---

## TECHNICAL SPECIFICATIONS

### 1. Feature Structure

```
lib/
  features/
    account_deletion/                        # NEW FEATURE
      domain/
        entities/
          deletion_request.dart              # User deletion request
          deletion_status.dart               # Status enum
          recovery_token.dart                # Recovery link token
        repositories/
          account_deletion_repository.dart   # Repository contract
        usecases/
          request_account_deletion_usecase.dart
          confirm_account_deletion_usecase.dart
          recover_deleted_account_usecase.dart
          check_deletion_status_usecase.dart
      data/
        datasources/
          firebase_auth_deletion_datasource.dart
          firestore_deletion_datasource.dart
          cloud_storage_deletion_datasource.dart
          hive_deletion_datasource.dart
        models/
          deletion_request_model.dart
          deletion_status_model.dart
        repositories/
          account_deletion_repository_impl.dart
        services/
          email_service.dart                 # Send recovery emails
          audit_log_service.dart             # Audit logging
      presentation/
        providers/
          account_deletion_providers.dart
          deletion_progress_provider.dart
        screens/
          delete_account_screen.dart         # Step 1: Warning
          password_confirmation_screen.dart  # Step 2: Re-auth
          deletion_confirmation_screen.dart  # Step 3: Checkboxes
          deletion_progress_screen.dart      # Step 4: Progress
          deletion_success_screen.dart       # Step 5: Success
          recovery_screen.dart               # Recovery flow
        widgets/
          deletion_warning_card.dart
          deletion_checklist.dart
          recovery_dialog.dart
```

### 2. Domain Entities

#### DeletionRequest

```dart
// lib/features/account_deletion/domain/entities/deletion_request.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'deletion_request.freezed.dart';
part 'deletion_request.g.dart';

@freezed
class DeletionRequest with _$DeletionRequest {
  const factory DeletionRequest({
    required String userId,
    required DateTime requestedAt,
    required DateTime hardDeleteScheduledAt,
    String? reason,
    @Default(false) bool hardDeleteImmediately, // RGPD: user can request immediate deletion
    String? recoveryToken,
  }) = _DeletionRequest;

  factory DeletionRequest.fromJson(Map<String, dynamic> json) =>
      _$DeletionRequestFromJson(json);
}

enum DeletionStatus {
  active,               // Not deleted
  pendingHardDelete,    // Soft deleted, waiting for 30 days
  hardDeleted,          // Permanently deleted
  recovering,           // Recovery in progress
}

extension DeletionStatusExtension on DeletionStatus {
  String get displayName {
    switch (this) {
      case DeletionStatus.active:
        return 'Active';
      case DeletionStatus.pendingHardDelete:
        return 'Scheduled for Deletion';
      case DeletionStatus.hardDeleted:
        return 'Permanently Deleted';
      case DeletionStatus.recovering:
        return 'Recovering';
    }
  }

  String toFirestoreValue() {
    switch (this) {
      case DeletionStatus.active:
        return 'active';
      case DeletionStatus.pendingHardDelete:
        return 'pending_hard_delete';
      case DeletionStatus.hardDeleted:
        return 'hard_deleted';
      case DeletionStatus.recovering:
        return 'recovering';
    }
  }

  static DeletionStatus fromFirestoreValue(String value) {
    switch (value) {
      case 'active':
        return DeletionStatus.active;
      case 'pending_hard_delete':
        return DeletionStatus.pendingHardDelete;
      case 'hard_deleted':
        return DeletionStatus.hardDeleted;
      case 'recovering':
        return DeletionStatus.recovering;
      default:
        return DeletionStatus.active;
    }
  }
}

@freezed
class RecoveryToken with _$RecoveryToken {
  const factory RecoveryToken({
    required String token,
    required String userId,
    required DateTime expiresAt,
    required bool isValid,
  }) = _RecoveryToken;

  factory RecoveryToken.fromJson(Map<String, dynamic> json) =>
      _$RecoveryTokenFromJson(json);
}
```

### 3. Firestore Data Structure (Soft Delete)

```dart
// Firestore: users/{userId}
{
  "email": "user@example.com",
  "name": "Marie Dupont",
  "createdAt": Timestamp(2025-06-15),

  // Deletion fields
  "deleted_at": Timestamp(2026-02-20),              // Soft delete timestamp
  "deletion_status": "pending_hard_delete",         // Status
  "hard_delete_scheduled_at": Timestamp(2026-03-22), // Day 31
  "recovery_token": "abc123xyz789",                 // Recovery link token
  "recovery_token_expires_at": Timestamp(2026-03-22),
  "deletion_reason": "No longer need app",          // Optional user reason

  // Rest of user data remains intact during soft delete
  "profilePhoto": "https://...",
  // ...
}

// Firestore: user_deletions/{userId}
{
  "user_id": "user_123",
  "email": "user@example.com",  // For recovery email
  "deletion_requested_at": Timestamp(2026-02-20),
  "hard_delete_scheduled_at": Timestamp(2026-03-22),
  "recovery_token": "abc123xyz789",
  "recovery_link": "https://app.frigofute.com/recovery/abc123xyz789",
  "recovery_token_expires_at": Timestamp(2026-03-22),
  "status": "pending_recovery",  // or 'recovered', 'hard_deleted'
  "recovery_email_sent_at": Timestamp(2026-02-20),
}

// Firestore: audit_logs/deletion_logs/{logId}
{
  "action": "account_soft_deleted",
  "user_id_hash": "sha256(user_123)",  // Anonymized
  "timestamp": Timestamp(2026-02-20),
  "hard_delete_scheduled_at": Timestamp(2026-03-22),
  "reason": "User requested deletion",
  "ip_address": null,  // Privacy: don't log
  "user_agent": "FrigoFute/1.0.0 iOS",
  "retention_until": Timestamp(2029-02-20),  // 3 years
}
```

### 4. Firebase Auth Deletion Datasource

```dart
// lib/features/account_deletion/data/datasources/firebase_auth_deletion_datasource.dart

class FirebaseAuthDeletionDatasource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDeletionDatasource(this._firebaseAuth);

  /// Delete Firebase Auth user account
  /// Throws RequiresRecentLoginException if re-auth needed
  Future<void> deleteUserAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw RequiresRecentLoginException(
          'Please re-authenticate to delete your account',
        );
      }
      rethrow;
    }
  }

  /// Re-authenticate with email/password
  Future<void> reauthenticateWithEmailPassword(String password) async {
    final user = _firebaseAuth.currentUser!;
    final email = user.email!;

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  /// Re-authenticate with Google OAuth
  Future<void> reauthenticateWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.currentUser!
          .reauthenticateWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  /// Re-authenticate with Apple OAuth
  Future<void> reauthenticateWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: appleCredential.nonce,
      );

      await _firebaseAuth.currentUser!
          .reauthenticateWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }
}

class RequiresRecentLoginException implements Exception {
  final String message;
  RequiresRecentLoginException(this.message);
}
```

### 5. Firestore Deletion Datasource (Soft Delete)

```dart
// lib/features/account_deletion/data/datasources/firestore_deletion_datasource.dart

import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class FirestoreDeletionDatasource {
  final FirebaseFirestore _firestore;

  FirestoreDeletionDatasource(this._firestore);

  /// Soft delete: Mark user for deletion (30-day grace period)
  Future<DeletionRequest> softDeleteUser({
    required String userId,
    String? reason,
  }) async {
    final now = DateTime.now();
    final hardDeleteDate = now.add(const Duration(days: 30));
    final recoveryToken = const Uuid().v4();

    try {
      // Update user document
      await _firestore.collection('users').doc(userId).update({
        'deleted_at': FieldValue.serverTimestamp(),
        'deletion_status': 'pending_hard_delete',
        'hard_delete_scheduled_at': Timestamp.fromDate(hardDeleteDate),
        'recovery_token': recoveryToken,
        'recovery_token_expires_at': Timestamp.fromDate(hardDeleteDate),
        'deletion_reason': reason ?? '',
      });

      // Create deletion tracking document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final email = userDoc.data()?['email'] as String?;

      await _firestore.collection('user_deletions').doc(userId).set({
        'user_id': userId,
        'email': email,
        'deletion_requested_at': FieldValue.serverTimestamp(),
        'hard_delete_scheduled_at': Timestamp.fromDate(hardDeleteDate),
        'recovery_token': recoveryToken,
        'recovery_link':
            'https://app.frigofute.com/recovery/$recoveryToken',
        'recovery_token_expires_at': Timestamp.fromDate(hardDeleteDate),
        'status': 'pending_recovery',
        'recovery_email_sent_at': null, // Set after email sent
      });

      // Log deletion request (audit trail)
      await _logDeletionRequest(userId, reason);

      return DeletionRequest(
        userId: userId,
        requestedAt: now,
        hardDeleteScheduledAt: hardDeleteDate,
        reason: reason,
        recoveryToken: recoveryToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Check deletion status
  Future<DeletionStatus?> getDeletionStatus(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return DeletionStatus.hardDeleted;

      final status = doc.data()?['deletion_status'] as String?;
      if (status == null) return DeletionStatus.active;

      return DeletionStatus.fromFirestoreValue(status);
    } catch (e) {
      return null;
    }
  }

  /// Recover account during grace period
  Future<void> recoverAccount(String recoveryToken) async {
    try {
      // Find deletion record
      final query = await _firestore
          .collection('user_deletions')
          .where('recovery_token', isEqualTo: recoveryToken)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Invalid recovery token');
      }

      final deletionDoc = query.docs.first;
      final userId = deletionDoc['user_id'] as String;
      final expiresAt =
          (deletionDoc['recovery_token_expires_at'] as Timestamp).toDate();

      // Check if expired
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Recovery token expired (30 days passed)');
      }

      // Restore user account
      await _firestore.collection('users').doc(userId).update({
        'deleted_at': FieldValue.delete(),
        'deletion_status': 'active',
        'hard_delete_scheduled_at': FieldValue.delete(),
        'recovery_token': FieldValue.delete(),
        'recovery_token_expires_at': FieldValue.delete(),
        'deletion_reason': FieldValue.delete(),
        'recovered_at': FieldValue.serverTimestamp(),
      });

      // Update deletion record
      await deletionDoc.reference.update({
        'status': 'recovered',
        'recovered_at': FieldValue.serverTimestamp(),
      });

      // Log recovery (audit trail)
      await _logAccountRecovery(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Hard delete: Permanently delete all user data (called by Cloud Function)
  Future<void> hardDeleteUser(String userId) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      // List of subcollections to delete
      const collections = [
        'inventory',
        'nutrition',
        'health',
        'settings',
        'devices',
        'meal_plans',
        'recipes',
        'family_sharing',
        'subscriptions',
      ];

      // Delete each subcollection
      for (final collection in collections) {
        await _deleteCollectionBatch(
          userDocRef.collection(collection),
        );
      }

      // Delete user document
      await userDocRef.delete();

      // Update deletion record
      await _firestore.collection('user_deletions').doc(userId).update({
        'status': 'hard_deleted',
        'hard_deleted_at': FieldValue.serverTimestamp(),
      });

      // Log hard deletion (audit trail)
      await _logHardDeletion(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Batch delete collection (handles pagination)
  Future<void> _deleteCollectionBatch(
    CollectionReference collectionRef, {
    int batchSize = 100,
  }) async {
    final query = collectionRef.limit(batchSize);
    final docs = await query.get();

    if (docs.docs.isEmpty) {
      return; // All deleted
    }

    final batch = _firestore.batch();
    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    // Recursively delete remaining
    return _deleteCollectionBatch(collectionRef, batchSize: batchSize);
  }

  /// Audit logging: Deletion request
  Future<void> _logDeletionRequest(String userId, String? reason) async {
    await _firestore.collection('audit_logs').add({
      'action': 'account_soft_deleted',
      'user_id_hash': _hashUserId(userId),
      'timestamp': FieldValue.serverTimestamp(),
      'reason': reason ?? 'Not provided',
      'retention_until': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 365 * 3)), // 3 years
      ),
    });
  }

  /// Audit logging: Account recovery
  Future<void> _logAccountRecovery(String userId) async {
    await _firestore.collection('audit_logs').add({
      'action': 'account_recovered',
      'user_id_hash': _hashUserId(userId),
      'timestamp': FieldValue.serverTimestamp(),
      'retention_until': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 365 * 3)), // 3 years
      ),
    });
  }

  /// Audit logging: Hard deletion
  Future<void> _logHardDeletion(String userId) async {
    await _firestore.collection('audit_logs').add({
      'action': 'account_hard_deleted',
      'user_id_hash': _hashUserId(userId),
      'timestamp': FieldValue.serverTimestamp(),
      'retention_until': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 365 * 3)), // 3 years
      ),
    });
  }

  /// Hash user ID for anonymized audit logs
  String _hashUserId(String userId) {
    return sha256.convert(utf8.encode(userId)).toString().substring(0, 16);
  }
}
```

### 6. Cloud Storage Deletion Datasource

```dart
// lib/features/account_deletion/data/datasources/cloud_storage_deletion_datasource.dart

class CloudStorageDeletionDatasource {
  final FirebaseStorage _storage;

  CloudStorageDeletionDatasource(this._storage);

  /// Delete all user files from Cloud Storage
  Future<void> deleteUserFiles(String userId) async {
    try {
      final reference = _storage.ref('users/$userId');

      // List all files and subdirectories
      final result = await reference.listAll();

      // Delete all files
      await Future.wait(
        result.items.map((item) => item.delete()),
      );

      // Recursively delete subdirectories
      await Future.wait(
        result.prefixes.map((dir) => _deleteDirectory(dir)),
      );

      debugPrint('Deleted all files for user $userId');
    } catch (e) {
      // Log but don't fail entire deletion
      debugPrint('Error deleting storage files for user $userId: $e');
      // Notify admin for manual cleanup if needed
    }
  }

  /// Recursively delete directory
  Future<void> _deleteDirectory(Reference dirRef) async {
    final result = await dirRef.listAll();

    // Delete files in directory
    await Future.wait(
      result.items.map((item) => item.delete()),
    );

    // Recursively delete subdirectories
    await Future.wait(
      result.prefixes.map((subdir) => _deleteDirectory(subdir)),
    );
  }
}
```

### 7. Hive Local Data Deletion Datasource

```dart
// lib/features/account_deletion/data/datasources/hive_deletion_datasource.dart

class HiveDeletionDatasource {
  /// Delete all local Hive data for user
  Future<void> deleteLocalUserData() async {
    try {
      final boxes = [
        'user_profile_box',
        'inventory_box',
        'nutrition_box',
        'health_profiles_box',
        'settings_box',
        'sync_queue_box',
        'auth_cache_box',
      ];

      for (final boxName in boxes) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            await box.clear();
            await box.close();
          }
          await Hive.deleteBoxFromDisk(boxName);
        } catch (e) {
          // Box might not exist, continue
          debugPrint('Error deleting box $boxName: $e');
          continue;
        }
      }

      debugPrint('Deleted all local Hive data');
    } catch (e) {
      rethrow;
    }
  }
}
```

### 8. Cloud Function for Hard Delete (Server-Side)

```typescript
// functions/src/accountDeletion.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const storage = admin.storage();
const auth = admin.auth();

/**
 * Cloud Function: Delete user account (callable)
 * Called from Flutter app for soft delete
 */
export const deleteUserAccount = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User not authenticated');
  }

  const userId = context.auth.uid;
  const hardDelete = data.hardDelete || false;
  const reason = data.reason || '';

  try {
    // Soft delete (mark for deletion)
    const userRef = db.collection('users').doc(userId);
    const now = admin.firestore.Timestamp.now();
    const hardDeleteDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

    await userRef.update({
      deleted_at: now,
      deletion_status: 'pending_hard_delete',
      hard_delete_scheduled_at: admin.firestore.Timestamp.fromDate(hardDeleteDate),
      deletion_reason: reason,
    });

    // If user requests immediate hard delete (GDPR allows this)
    if (hardDelete) {
      await hardDeleteUserData(userId);
    }

    return {
      status: hardDelete ? 'hard_deleted' : 'soft_deleted',
      hardDeleteScheduledAt: hardDeleteDate.toISOString(),
    };
  } catch (error) {
    console.error(`Error deleting user ${userId}:`, error);
    throw new functions.https.HttpsError('internal', 'Failed to delete account');
  }
});

/**
 * Scheduled Cloud Function: Hard delete accounts after 30 days
 * Runs daily at 2:00 AM UTC
 */
export const hardDeleteScheduledAccounts = functions.pubsub
  .schedule('0 2 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    const cutoffDate = admin.firestore.Timestamp.now();

    // Find accounts scheduled for hard deletion
    const query = await db.collection('users')
      .where('deletion_status', '==', 'pending_hard_delete')
      .where('hard_delete_scheduled_at', '<=', cutoffDate)
      .get();

    console.log(`Found ${query.size} accounts to hard delete`);

    // Delete each account
    const deletePromises = query.docs.map(doc =>
      hardDeleteUserData(doc.id)
    );

    await Promise.all(deletePromises);

    console.log(`Hard deleted ${deletePromises.length} accounts`);
  });

/**
 * Helper: Permanently delete all user data
 */
async function hardDeleteUserData(userId: string): Promise<void> {
  try {
    // Step 1: Delete Firestore subcollections
    await deleteFirestoreData(userId);

    // Step 2: Delete Cloud Storage files
    await deleteStorageFiles(userId);

    // Step 3: Delete Firebase Auth user
    try {
      await auth.deleteUser(userId);
    } catch (error) {
      // User might already be deleted
      console.log(`Auth user ${userId} already deleted or doesn't exist`);
    }

    // Step 4: Update deletion record
    await db.collection('user_deletions').doc(userId).update({
      status: 'hard_deleted',
      hard_deleted_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Step 5: Log hard deletion (audit trail)
    await logHardDeletion(userId);

    console.log(`Successfully hard deleted user ${userId}`);
  } catch (error) {
    console.error(`Error hard deleting user ${userId}:`, error);
    throw error;
  }
}

/**
 * Delete all Firestore documents for user
 */
async function deleteFirestoreData(userId: string): Promise<void> {
  const userDocRef = db.collection('users').doc(userId);

  // Subcollections to delete
  const collections = [
    'inventory',
    'nutrition',
    'health',
    'settings',
    'devices',
    'meal_plans',
    'recipes',
    'family_sharing',
    'subscriptions',
  ];

  // Delete each subcollection
  for (const collection of collections) {
    await deleteCollectionBatch(userDocRef.collection(collection));
  }

  // Delete user document
  await userDocRef.delete();
}

/**
 * Batch delete collection (handles large datasets)
 */
async function deleteCollectionBatch(
  collectionRef: admin.firestore.CollectionReference,
  batchSize = 100
): Promise<void> {
  const query = collectionRef.limit(batchSize);
  const docs = await query.get();

  if (docs.size === 0) {
    return; // All deleted
  }

  const batch = db.batch();
  docs.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();

  // Recursively delete remaining
  return deleteCollectionBatch(collectionRef, batchSize);
}

/**
 * Delete user files from Cloud Storage
 */
async function deleteStorageFiles(userId: string): Promise<void> {
  const bucket = storage.bucket();
  const prefix = `users/${userId}`;

  try {
    const [files] = await bucket.getFiles({ prefix });

    for (const file of files) {
      await file.delete();
    }

    console.log(`Deleted ${files.length} files for user ${userId}`);
  } catch (error) {
    console.error(`Error deleting storage files for user ${userId}:`, error);
    // Don't throw - continue with other deletions
  }
}

/**
 * Log hard deletion to audit logs
 */
async function logHardDeletion(userId: string): Promise<void> {
  const crypto = require('crypto');
  const userIdHash = crypto.createHash('sha256').update(userId).digest('hex').substring(0, 16);

  await db.collection('audit_logs').add({
    action: 'account_hard_deleted',
    user_id_hash: userIdHash,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    retention_until: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 3 * 365 * 24 * 60 * 60 * 1000) // 3 years
    ),
  });
}
```

### 9. Email Service (Recovery Emails)

```dart
// lib/features/account_deletion/data/services/email_service.dart

class EmailService {
  /// Send recovery email
  Future<void> sendRecoveryEmail({
    required String email,
    required String recoveryLink,
    required DateTime hardDeleteDate,
  }) async {
    // Use SendGrid, Firebase Cloud Functions, or other email service
    // Example using Cloud Function:

    final callable = FirebaseFunctions.instance
        .httpsCallable('sendDeletionRecoveryEmail');

    try {
      await callable.call({
        'email': email,
        'recoveryLink': recoveryLink,
        'hardDeleteDate': hardDeleteDate.toIso8601String(),
      });

      debugPrint('Recovery email sent to $email');
    } catch (e) {
      debugPrint('Error sending recovery email: $e');
      rethrow;
    }
  }

  /// Send final deletion confirmation email
  Future<void> sendFinalDeletionEmail({
    required String email,
  }) async {
    final callable = FirebaseFunctions.instance
        .httpsCallable('sendFinalDeletionEmail');

    try {
      await callable.call({'email': email});
      debugPrint('Final deletion email sent to $email');
    } catch (e) {
      debugPrint('Error sending final deletion email: $e');
      // Don't throw - email is not critical
    }
  }
}
```

### 10. Riverpod Providers

```dart
// lib/features/account_deletion/presentation/providers/account_deletion_providers.dart

// Services
final firebaseAuthDeletionProvider =
    Provider<FirebaseAuthDeletionDatasource>((ref) {
  return FirebaseAuthDeletionDatasource(FirebaseAuth.instance);
});

final firestoreDeletionProvider = Provider<FirestoreDeletionDatasource>((ref) {
  return FirestoreDeletionDatasource(FirebaseFirestore.instance);
});

final cloudStorageDeletionProvider =
    Provider<CloudStorageDeletionDatasource>((ref) {
  return CloudStorageDeletionDatasource(FirebaseStorage.instance);
});

final hiveDeletionProvider = Provider<HiveDeletionDatasource>((ref) {
  return HiveDeletionDatasource();
});

final emailServiceProvider = Provider<EmailService>((ref) {
  return EmailService();
});

// State
final deletionStatusProvider = FutureProvider<DeletionStatus?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final datasource = ref.watch(firestoreDeletionProvider);
  return await datasource.getDeletionStatus(userId);
});

final deletionProgressProvider =
    StateProvider<DeletionProgress>((ref) => DeletionProgress.idle());

// Use case: Soft delete account
final softDeleteAccountProvider = FutureProvider.family<
    DeletionRequest,
    String? // reason
>((ref, reason) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('No user logged in');

  final firestoreDatasource = ref.watch(firestoreDeletionProvider);
  final emailService = ref.watch(emailServiceProvider);

  // Step 1: Soft delete in Firestore
  final deletionRequest = await firestoreDatasource.softDeleteUser(
    userId: userId,
    reason: reason,
  );

  // Step 2: Revoke all devices
  await _revokeAllDevices(userId);

  // Step 3: Send recovery email
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();
  final email = userDoc.data()?['email'] as String;

  await emailService.sendRecoveryEmail(
    email: email,
    recoveryLink:
        'https://app.frigofute.com/recovery/${deletionRequest.recoveryToken}',
    hardDeleteDate: deletionRequest.hardDeleteScheduledAt,
  );

  // Step 4: Logout user
  await FirebaseAuth.instance.signOut();

  // Step 5: Clear local data
  final hiveDatasource = ref.watch(hiveDeletionProvider);
  await hiveDatasource.deleteLocalUserData();

  return deletionRequest;
});

// Helper: Revoke all devices
Future<void> _revokeAllDevices(String userId) async {
  final devicesSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('devices')
      .get();

  final batch = FirebaseFirestore.instance.batch();

  for (final doc in devicesSnapshot.docs) {
    batch.update(doc.reference, {
      'isActive': false,
      'revokedAt': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
}
```

### 11. UI Screens

#### Delete Account Screen (Step 1: Warning)

```dart
// lib/features/account_deletion/presentation/screens/delete_account_screen.dart

class DeleteAccountScreen extends ConsumerWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RGPD Article 17 notice
            _buildLegalNotice(),
            const SizedBox(height: 24),

            // What will be deleted
            _buildDeletionList(ref),
            const SizedBox(height: 24),

            // 30-day grace period
            _buildGracePeriodCard(),
            const SizedBox(height: 24),

            // Suggest export first
            _buildExportSuggestion(context),
            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _continueToConfirmation(context, ref),
                child: const Text('Continue to Confirmation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalNotice() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'RGPD Article 17 - Right to Erasure',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'You have the right to request deletion of your personal data. '
              'This action will permanently remove all your data from FrigoFute.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletionList(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What Will Be Deleted',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildDeletionItem('Profile information', 'Email, name, photos'),
        _buildDeletionItem('Health profile', 'Weight, BMR, TDEE, allergies'),
        _buildDeletionItem('Inventory', '1,247 products'),
        _buildDeletionItem('Nutrition history', '342 entries'),
        _buildDeletionItem('Settings', 'All preferences'),
        _buildDeletionItem('Devices', '3 registered devices'),
        _buildDeletionItem('Files', 'All photos and documents'),
      ],
    );
  }

  Widget _buildDeletionItem(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
    );
  }

  Widget _buildGracePeriodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                '30-Day Grace Period',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You have 30 days to recover your account. We\'ll send a recovery link to your email. '
            'After 30 days, deletion is permanent and irreversible.',
            style: TextStyle(fontSize: 12, color: Colors.green.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSuggestion(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.download, color: Colors.blue),
        title: const Text('Export Your Data First?'),
        subtitle: const Text(
          'We recommend exporting your data before deletion',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to export screen (Story 1.9)
          Navigator.pushNamed(context, '/export-data');
        },
      ),
    );
  }

  void _continueToConfirmation(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PasswordConfirmationScreen(),
      ),
    );
  }
}
```

#### Password Confirmation Screen (Step 2: Re-auth)

```dart
// lib/features/account_deletion/presentation/screens/password_confirmation_screen.dart

class PasswordConfirmationScreen extends ConsumerStatefulWidget {
  const PasswordConfirmationScreen({super.key});

  @override
  ConsumerState<PasswordConfirmationScreen> createState() =>
      _PasswordConfirmationScreenState();
}

class _PasswordConfirmationScreenState
    extends ConsumerState<PasswordConfirmationScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final isEmailPasswordUser = user.providerData
        .any((provider) => provider.providerId == 'password');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Identity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please re-authenticate to confirm account deletion.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),

            if (isEmailPasswordUser)
              _buildPasswordInput()
            else
              _buildOAuthReauth(),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmPassword,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Icon(Icons.lock),
      ),
      obscureText: true,
      autofocus: true,
    );
  }

  Widget _buildOAuthReauth() {
    final user = FirebaseAuth.instance.currentUser!;
    final isGoogleUser = user.providerData
        .any((provider) => provider.providerId == 'google.com');
    final isAppleUser = user.providerData
        .any((provider) => provider.providerId == 'apple.com');

    return Column(
      children: [
        if (isGoogleUser)
          ElevatedButton.icon(
            onPressed: _reauthWithGoogle,
            icon: const Icon(Icons.g_mobiledata),
            label: const Text('Sign in with Google'),
          ),
        if (isAppleUser)
          ElevatedButton.icon(
            onPressed: _reauthWithApple,
            icon: const Icon(Icons.apple),
            label: const Text('Sign in with Apple'),
          ),
      ],
    );
  }

  Future<void> _confirmPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authDatasource = ref.read(firebaseAuthDeletionProvider);
      await authDatasource
          .reauthenticateWithEmailPassword(_passwordController.text);

      // Success - navigate to confirmation
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DeletionConfirmationScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _reauthWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authDatasource = ref.read(firebaseAuthDeletionProvider);
      await authDatasource.reauthenticateWithGoogle();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DeletionConfirmationScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign-in failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _reauthWithApple() async {
    setState(() => _isLoading = true);

    try {
      final authDatasource = ref.read(firebaseAuthDeletionProvider);
      await authDatasource.reauthenticateWithApple();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DeletionConfirmationScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Apple sign-in failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
```

#### Deletion Confirmation Screen (Step 3: Checkboxes)

```dart
// lib/features/account_deletion/presentation/screens/deletion_confirmation_screen.dart

class DeletionConfirmationScreen extends ConsumerStatefulWidget {
  const DeletionConfirmationScreen({super.key});

  @override
  ConsumerState<DeletionConfirmationScreen> createState() =>
      _DeletionConfirmationScreenState();
}

class _DeletionConfirmationScreenState
    extends ConsumerState<DeletionConfirmationScreen> {
  final Map<String, bool> _checkboxes = {
    'understand_deletion': false,
    'understand_grace_period': false,
    'understand_new_account': false,
  };

  bool get _allChecked => _checkboxes.values.every((v) => v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Strong warning
            _buildWarningCard(),
            const SizedBox(height: 24),

            // Checkboxes
            _buildCheckbox(
              'understand_deletion',
              'I understand all my data will be permanently deleted',
            ),
            _buildCheckbox(
              'understand_grace_period',
              'I understand I have 30 days to recover my account',
            ),
            _buildCheckbox(
              'understand_new_account',
              'I understand I must create a new account to use FrigoFute again',
            ),

            const Spacer(),

            // Delete button (danger style)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _allChecked ? _confirmDeletion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete Account Permanently'),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade700, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Action Cannot Be Undone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have 30 days to recover. After that, all data is permanently deleted.',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String key, String label) {
    return CheckboxListTile(
      value: _checkboxes[key],
      onChanged: (value) {
        setState(() => _checkboxes[key] = value ?? false);
      },
      title: Text(label, style: const TextStyle(fontSize: 14)),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Future<void> _confirmDeletion() async {
    // Navigate to progress screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DeletionProgressScreen(),
      ),
    );

    // Start deletion process
    try {
      await ref.read(softDeleteAccountProvider(null).future);
    } catch (e) {
      // Handle error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deletion failed: $e')),
        );
      }
    }
  }
}
```

---

## IMPLEMENTATION TASKS

### Task 1: Create Feature Structure ✅
**Estimated Time**: 1 hour

- [ ] Create `lib/features/account_deletion/` directory
- [ ] Create subdirectories: `domain/`, `data/`, `presentation/`
- [ ] Create entity files with Freezed
- [ ] Run `flutter pub run build_runner build`

**Files to Create:**
- `lib/features/account_deletion/domain/entities/deletion_request.dart`
- `lib/features/account_deletion/domain/entities/deletion_status.dart`
- `lib/features/account_deletion/domain/entities/recovery_token.dart`

---

### Task 2: Implement Firebase Auth Deletion Datasource ✅
**Estimated Time**: 4 hours

- [ ] Create `FirebaseAuthDeletionDatasource`
- [ ] Implement `deleteUserAccount()` method
- [ ] Implement `reauthenticateWithEmailPassword()`
- [ ] Implement `reauthenticateWithGoogle()`
- [ ] Implement `reauthenticateWithApple()`
- [ ] Handle `requires-recent-login` exception

**Files to Create:**
- `lib/features/account_deletion/data/datasources/firebase_auth_deletion_datasource.dart`

---

### Task 3: Implement Firestore Soft Delete Datasource ✅
**Estimated Time**: 6 hours

- [ ] Create `FirestoreDeletionDatasource`
- [ ] Implement `softDeleteUser()` method
- [ ] Generate recovery token (UUID)
- [ ] Create `user_deletions` tracking document
- [ ] Implement `getDeletionStatus()` method
- [ ] Implement `recoverAccount()` method
- [ ] Implement audit logging

**Files to Create:**
- `lib/features/account_deletion/data/datasources/firestore_deletion_datasource.dart`

---

### Task 4: Implement Firestore Hard Delete Datasource ✅
**Estimated Time**: 6 hours

- [ ] Implement `hardDeleteUser()` method
- [ ] Implement `_deleteCollectionBatch()` for pagination
- [ ] Delete all subcollections (inventory, nutrition, health, etc.)
- [ ] Delete user document
- [ ] Update deletion record status
- [ ] Implement audit logging for hard delete

**Files to Modify:**
- `lib/features/account_deletion/data/datasources/firestore_deletion_datasource.dart`

---

### Task 5: Implement Cloud Storage Deletion Datasource ✅
**Estimated Time**: 3 hours

- [ ] Create `CloudStorageDeletionDatasource`
- [ ] Implement `deleteUserFiles()` method
- [ ] List all files with prefix `users/{userId}`
- [ ] Delete files recursively
- [ ] Delete subdirectories recursively
- [ ] Handle errors gracefully

**Files to Create:**
- `lib/features/account_deletion/data/datasources/cloud_storage_deletion_datasource.dart`

---

### Task 6: Implement Hive Local Data Deletion Datasource ✅
**Estimated Time**: 2 hours

- [ ] Create `HiveDeletionDatasource`
- [ ] Implement `deleteLocalUserData()` method
- [ ] List all Hive boxes to clear
- [ ] Clear and delete each box
- [ ] Handle boxes that don't exist

**Files to Create:**
- `lib/features/account_deletion/data/datasources/hive_deletion_datasource.dart`

---

### Task 7: Implement Cloud Functions (Server-Side) ✅
**Estimated Time**: 8 hours

- [ ] Create `functions/src/accountDeletion.ts`
- [ ] Implement `deleteUserAccount` callable function
- [ ] Implement `hardDeleteScheduledAccounts` scheduled function (runs daily)
- [ ] Implement `hardDeleteUserData()` helper
- [ ] Implement `deleteFirestoreData()` helper
- [ ] Implement `deleteCollectionBatch()` with pagination
- [ ] Implement `deleteStorageFiles()` helper
- [ ] Implement `logHardDeletion()` audit logging
- [ ] Deploy Cloud Functions

**Files to Create:**
- `functions/src/accountDeletion.ts`

**Testing:**
- Use Firebase Emulator to test locally
- Deploy to staging environment

---

### Task 8: Implement Email Service ✅
**Estimated Time**: 4 hours

- [ ] Create `EmailService` class
- [ ] Implement `sendRecoveryEmail()` method
- [ ] Implement `sendFinalDeletionEmail()` method
- [ ] Create email templates (HTML)
- [ ] Use Cloud Function to send emails (SendGrid, Mailgun, or Firebase Extension)
- [ ] Test email delivery

**Files to Create:**
- `lib/features/account_deletion/data/services/email_service.dart`
- `functions/src/emailTemplates.ts` (email HTML templates)

---

### Task 9: Create Riverpod Providers ✅
**Estimated Time**: 3 hours

- [ ] Create datasource providers
- [ ] Create state providers for deletion status
- [ ] Create state provider for deletion progress
- [ ] Create use case provider for soft delete
- [ ] Create provider for recovery

**Files to Create:**
- `lib/features/account_deletion/presentation/providers/account_deletion_providers.dart`

---

### Task 10: Build Delete Account Screen (Step 1) ✅
**Estimated Time**: 5 hours

- [ ] Create `DeleteAccountScreen`
- [ ] Add RGPD Article 17 legal notice
- [ ] Display deletion list with counts
- [ ] Add grace period explanation card
- [ ] Add export suggestion
- [ ] Add "Continue to Confirmation" button
- [ ] Navigate to Settings → Account

**Files to Create:**
- `lib/features/account_deletion/presentation/screens/delete_account_screen.dart`

---

### Task 11: Build Password Confirmation Screen (Step 2) ✅
**Estimated Time**: 4 hours

- [ ] Create `PasswordConfirmationScreen`
- [ ] Add password input for email/password users
- [ ] Add OAuth re-authentication for Google/Apple users
- [ ] Handle incorrect password errors
- [ ] Navigate to confirmation after success

**Files to Create:**
- `lib/features/account_deletion/presentation/screens/password_confirmation_screen.dart`

---

### Task 12: Build Deletion Confirmation Screen (Step 3) ✅
**Estimated Time**: 4 hours

- [ ] Create `DeletionConfirmationScreen`
- [ ] Add strong warning card
- [ ] Add 3 confirmation checkboxes
- [ ] Disable delete button until all checked
- [ ] Style delete button as danger (red)
- [ ] Add cancel button

**Files to Create:**
- `lib/features/account_deletion/presentation/screens/deletion_confirmation_screen.dart`

---

### Task 13: Build Deletion Progress Screen (Step 4) ✅
**Estimated Time**: 3 hours

- [ ] Create `DeletionProgressScreen`
- [ ] Display circular progress indicator
- [ ] Show current step text
- [ ] Show percentage
- [ ] Prevent navigation away during deletion

**Files to Create:**
- `lib/features/account_deletion/presentation/screens/deletion_progress_screen.dart`

---

### Task 14: Build Deletion Success Screen (Step 5) ✅
**Estimated Time**: 3 hours

- [ ] Create `DeletionSuccessScreen`
- [ ] Display success message
- [ ] Show 30-day grace period details
- [ ] Show permanent deletion date
- [ ] Auto-redirect to login after 3 seconds

**Files to Create:**
- `lib/features/account_deletion/presentation/screens/deletion_success_screen.dart`

---

### Task 15: Build Recovery Screen ✅
**Estimated Time**: 4 hours

- [ ] Create `RecoveryScreen`
- [ ] Parse recovery token from URL
- [ ] Check if token is valid (< 30 days)
- [ ] Display recovery confirmation
- [ ] Implement recovery logic
- [ ] Show success/error messages

**Files to Create:**
- `lib/features/account_deletion/presentation/screens/recovery_screen.dart`

---

### Task 16: Implement Navigation from Settings ✅
**Estimated Time**: 1 hour

- [ ] Add "Delete Account" option to Settings → Account screen
- [ ] Navigate to `DeleteAccountScreen` on tap
- [ ] Add icon (delete/danger icon)

**Files to Modify:**
- `lib/features/settings/presentation/screens/account_settings_screen.dart`

---

### Task 17: Handle Active Subscription Check ✅
**Estimated Time**: 3 hours

- [ ] Check if user has active subscription before deletion
- [ ] Show warning dialog if subscription active
- [ ] Link to subscription management
- [ ] Block deletion until subscription cancelled

**Files to Modify:**
- `lib/features/account_deletion/presentation/screens/delete_account_screen.dart`

---

### Task 18: Implement Device Revocation on Soft Delete ✅
**Estimated Time**: 2 hours

- [ ] Mark all devices as `isActive: false` on soft delete
- [ ] Send push notification to all devices
- [ ] Devices auto-logout on next activity

**Files to Modify:**
- `lib/features/account_deletion/data/datasources/firestore_deletion_datasource.dart`

---

### Task 19: Write Unit Tests ✅
**Estimated Time**: 6 hours

- [ ] Test `FirebaseAuthDeletionDatasource`
- [ ] Test `FirestoreDeletionDatasource`
- [ ] Test `CloudStorageDeletionDatasource`
- [ ] Test `HiveDeletionDatasource`
- [ ] Test soft delete logic
- [ ] Test hard delete logic
- [ ] Test recovery logic
- [ ] Mock Firebase services

**Files to Create:**
- `test/features/account_deletion/data/datasources/firebase_auth_deletion_datasource_test.dart`
- `test/features/account_deletion/data/datasources/firestore_deletion_datasource_test.dart`

**Target Coverage**: 85%

---

### Task 20: Write Integration Tests ✅
**Estimated Time**: 6 hours

- [ ] Test complete deletion flow (soft delete)
- [ ] Test recovery flow
- [ ] Test hard delete (Cloud Function)
- [ ] Test with Firebase Emulator
- [ ] Test edge cases (expired token, invalid token)

**Files to Create:**
- `integration_test/account_deletion_test.dart`

**Target**: 8-10 test scenarios

---

### Task 21: Write E2E Tests ✅
**Estimated Time**: 4 hours

- [ ] Test full UI flow (all 5 steps)
- [ ] Test password re-authentication
- [ ] Test OAuth re-authentication
- [ ] Test recovery link
- [ ] Test auto-redirect after success

**Files to Create:**
- `integration_test/account_deletion_e2e_test.dart`

**Target**: 5-8 test scenarios

---

### Task 22: Manual Testing & QA ✅
**Estimated Time**: 6 hours

- [ ] Test on real device
- [ ] Soft delete account
- [ ] Receive recovery email
- [ ] Test recovery link
- [ ] Wait 31 days (or mock time) → test hard delete
- [ ] Verify all data deleted from Firestore
- [ ] Verify Auth user deleted
- [ ] Verify Storage files deleted
- [ ] Test error scenarios

**Testing Checklist**:
- ✅ All data deleted
- ✅ Recovery works
- ✅ Hard delete runs
- ✅ Emails sent

---

**Total Estimated Time**: 90-100 hours (~2.5-3 weeks for 1 developer)

---

## TESTING STRATEGY

### Unit Tests (Target: 85% Coverage)

```dart
// test/features/account_deletion/data/datasources/firestore_deletion_datasource_test.dart

void main() {
  late FirestoreDeletionDatasource datasource;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    datasource = FirestoreDeletionDatasource(mockFirestore);
  });

  group('Soft Delete', () {
    test('should mark user for deletion', () async {
      // Arrange
      when(mockFirestore.collection('users').doc(any).update(any))
          .thenAnswer((_) async => {});

      // Act
      final result = await datasource.softDeleteUser(
        userId: 'test_user',
        reason: 'No longer need app',
      );

      // Assert
      expect(result.userId, 'test_user');
      expect(result.hardDeleteScheduledAt.isAfter(DateTime.now()), true);
      verify(mockFirestore.collection('users').doc('test_user').update(
          argThat(containsPair('deletion_status', 'pending_hard_delete'))));
    });

    test('should generate recovery token', () async {
      final result = await datasource.softDeleteUser(
        userId: 'test_user',
      );

      expect(result.recoveryToken, isNotNull);
      expect(result.recoveryToken!.length, greaterThan(10));
    });
  });

  group('Recovery', () {
    test('should recover account with valid token', () async {
      // Test implementation
    });

    test('should throw exception for expired token', () async {
      // Test implementation
    });
  });
}
```

### Integration Tests

```dart
// integration_test/account_deletion_test.dart

void main() {
  testWidgets('Complete account deletion flow', (tester) async {
    await tester.pumpWidget(MyApp());

    // Login
    await loginAsTestUser();

    // Navigate to Delete Account
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    // Step 1: Warning screen
    expect(find.text('RGPD Article 17'), findsOneWidget);
    await tester.tap(find.text('Continue to Confirmation'));
    await tester.pumpAndSettle();

    // Step 2: Password confirmation
    await tester.enterText(find.byType(TextField), 'password123');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    // Step 3: Checkboxes
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.tap(find.byType(Checkbox).at(2));
    await tester.pumpAndSettle();

    // Confirm deletion
    await tester.tap(find.text('Delete Account Permanently'));
    await tester.pumpAndSettle(Duration(seconds: 5));

    // Step 4: Success screen
    expect(find.text('Account Deletion Scheduled'), findsOneWidget);

    // Verify soft delete in Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc('test_user')
        .get();
    expect(userDoc['deletion_status'], 'pending_hard_delete');
  });
}
```

### Manual Testing Checklist

- [ ] Soft delete with email/password account
- [ ] Soft delete with Google OAuth account
- [ ] Soft delete with Apple OAuth account
- [ ] Recovery within 30 days works
- [ ] Recovery after 30 days fails
- [ ] Hard delete runs after 31 days (Cloud Function)
- [ ] All Firestore data deleted
- [ ] All Cloud Storage files deleted
- [ ] Firebase Auth user deleted
- [ ] Audit logs created
- [ ] Recovery email sent and received
- [ ] Final deletion email sent
- [ ] Devices revoked and logged out
- [ ] Handle active subscription blocking deletion
- [ ] Handle network errors gracefully

---

## ANTI-PATTERNS TO AVOID

### ❌ Anti-Pattern 1: Deleting Data Without 30-Day Grace Period

**Problem**: Immediate permanent deletion doesn't allow user to change their mind.

**Solution**: Soft delete first, hard delete after 30 days. RGPD allows immediate deletion if user specifically requests it, but grace period is best practice.

---

### ❌ Anti-Pattern 2: Not Re-authenticating Before Deletion

**Problem**: Hijacked accounts can be deleted without user knowledge.

**Solution**: Require recent authentication (password or OAuth) before deletion.

---

### ❌ Anti-Pattern 3: Deleting Legal-Hold Data

**Problem**: Deleting audit logs, tax records violates legal requirements.

**Solution**: Keep audit logs (3 years), tax records (7 years), anonymized analytics.

---

### ❌ Anti-Pattern 4: Not Notifying User

**Problem**: User doesn't know deletion succeeded or when data will be removed.

**Solution**: Send recovery email immediately, final deletion email after 30 days.

---

### ❌ Anti-Pattern 5: Orphaning Data in Subcollections

**Problem**: Firestore doesn't cascade delete - subcollections remain.

**Solution**: Use Cloud Functions to recursively delete all subcollections.

---

### ❌ Anti-Pattern 6: Weak Confirmation Flow

**Problem**: User accidentally deletes account with one tap.

**Solution**: Multi-step confirmation with checkboxes, re-authentication, strong warnings.

---

## INTEGRATION POINTS

### 1. Authentication Module
- Re-authentication required before deletion
- Logout after soft delete

### 2. Multi-Device Sync (Story 1.8)
- Revoke all devices on soft delete

### 3. Data Export (Story 1.9)
- Suggest export before deletion

### 4. Subscription Module (Epic 15)
- Block deletion if active subscription

### 5. All Data Features
- Delete inventory (Epic 2)
- Delete nutrition data (Epic 7)
- Delete recipes (Epic 6)
- Delete meal plans (Epic 9)

---

## DEV NOTES

### 1. Firebase Emulator Testing

```bash
firebase emulators:start --only firestore,auth,storage,functions
```

Connect app:

```dart
if (kDebugMode) {
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
}
```

---

### 2. Cloud Function Deployment

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:hardDeleteScheduledAccounts
```

---

### 3. Testing Hard Delete Locally

```bash
# Trigger scheduled function manually
firebase functions:shell
> hardDeleteScheduledAccounts()
```

---

### 4. RGPD Compliance Notes

- **Response Time**: 30 days maximum (our target: immediate soft delete)
- **User Rights**: Free of charge, simple request process
- **Exceptions**: Keep audit logs (3 years), tax records (7 years)
- **Notification**: Confirm deletion to user via email

---

## DEFINITION OF DONE

### Code Complete ✅

- [ ] All 22 implementation tasks completed
- [ ] Code passes `flutter analyze` with no errors
- [ ] Code formatted with `flutter format .`
- [ ] All TODO comments resolved
- [ ] Cloud Functions deployed

### Testing Complete ✅

- [ ] Unit tests written (85% coverage)
- [ ] Integration tests written (8-10 scenarios)
- [ ] E2E tests written (5-8 scenarios)
- [ ] Manual testing on real device
- [ ] All 20 acceptance criteria verified
- [ ] Cloud Function tested with emulator

### Documentation Complete ✅

- [ ] Developer documentation written
- [ ] Email templates created
- [ ] Code comments added
- [ ] API documentation complete

### Legal Compliance ✅

- [ ] RGPD Article 17 requirements met
- [ ] 30-day grace period implemented
- [ ] Audit logs implemented
- [ ] Recovery flow tested
- [ ] User notification emails sent

### Performance Verified ✅

- [ ] Soft delete completes < 5 seconds
- [ ] Hard delete completes < 60 seconds for 10,000+ items
- [ ] Cloud Function handles large datasets
- [ ] No memory leaks detected

### User Acceptance ✅

- [ ] Product Owner approval
- [ ] Beta testers feedback positive
- [ ] No critical bugs reported
- [ ] UX flows intuitive and safe

---

## REFERENCES

### Legal Documentation

1. **RGPD Article 17 - Right to Erasure**
   - https://gdpr-info.eu/art-17-gdpr/
   - https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/individual-rights/right-to-erasure/

2. **CNIL (France) Guidance**
   - https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre3#Article17

### Technical Documentation

3. **Firebase Packages**
   - firebase_auth: https://pub.dev/packages/firebase_auth
   - cloud_firestore: https://pub.dev/packages/cloud_firestore
   - firebase_storage: https://pub.dev/packages/firebase_storage
   - cloud_functions: https://pub.dev/packages/cloud_functions

4. **Firebase Documentation**
   - Delete User: https://firebase.flutter.dev/docs/auth/manage-users/#delete-a-user
   - Delete Collections: https://firebase.google.com/docs/firestore/solutions/delete-collections
   - Cloud Functions: https://firebase.google.com/docs/functions/typescript

### Related Stories

- **Story 1.8**: Multi-Device Sync (revoke devices)
- **Story 1.9**: Export Personal Data (suggest export first)
- **Epic 15**: Premium Subscription (check active subscription)

---

## STORY CARD SUMMARY

**Story 1.10: Delete Account and All Data Permanently**

**Epic**: User Authentication & Profile Management
**Points**: 8
**Priority**: High (Legal Compliance - RGPD Article 17)

**Summary**: Implement RGPD Article 17 compliant account deletion feature with 30-day grace period. Soft delete marks account for deletion and sends recovery email. Hard delete after 30 days permanently removes all data from Firestore, Auth, and Storage. Multi-step confirmation flow prevents accidental deletion.

**Key Features**:
- Soft delete with 30-day grace period
- Multi-step confirmation (warning → re-auth → checkboxes → progress → success)
- Recovery via email link (valid for 30 days)
- Automatic hard delete via Cloud Function after 30 days
- Revoke all devices on deletion
- Audit logging for compliance
- Email notifications (recovery + final confirmation)

**Success Metrics**:
- Soft delete completes < 5 seconds
- Hard delete completes < 60 seconds
- Zero accidental deletions (strong confirmation works)
- 100% audit trail compliance

**Risks**:
- Hard delete fails mid-process (handle with retries)
- User regrets deletion (30-day recovery mitigates)
- Legal data retention violations (audit logs solve)

**Estimated Development Time**: 2.5-3 weeks (1 developer)

---

**Fin d'Epic 1 - 100% Complet ! 🎉**

Epic 1 (User Authentication & Profile Management) est maintenant COMPLET avec 10 stories créées !

---

**End of Story 1.10**
