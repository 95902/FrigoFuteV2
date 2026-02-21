# Firebase Security Rules Deployment & Testing Guide

**Story 0.10 Phase 3**: Firestore & Storage Security Rules
**Date**: 2026-02-15
**Status**: Production-Ready

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Firestore Security Rules](#firestore-security-rules)
3. [Storage Security Rules](#storage-security-rules)
4. [Custom Claims Management](#custom-claims-management)
5. [Deployment](#deployment)
6. [Testing with Emulator](#testing-with-emulator)
7. [Security Validation Checklist](#security-validation-checklist)
8. [Troubleshooting](#troubleshooting)

---

## Overview

### Security Architecture

FrigoFuteV2 implements a comprehensive security model with:

- **User Data Isolation**: Users can only access their own data
- **Health Data Protection**: RGPD Article 9 compliance via custom claims
- **Premium Features**: Premium-only access via `is_premium` custom claim
- **Version-Based Concurrency**: Optimistic locking for inventory items
- **Input Validation**: XSS and SQL injection prevention
- **File Upload Protection**: Size limits (10MB) and type validation (images only)

### Custom Claims

| Claim | Type | Purpose | Set By |
|-------|------|---------|--------|
| `health_data_consent` | boolean | Access to health data (nutrition, meal photos) | User consent flow |
| `is_premium` | boolean | Access to premium features | Subscription service |
| `health_data_consent_withdrawal_approved` | boolean | Right to erasure (RGPD) | User deletion flow |

---

## Firestore Security Rules

### File Structure

```
firestore.rules (245 lines)
├── Helper Functions
│   ├── isAuthenticated()
│   ├── isOwner(userId)
│   ├── hasHealthConsent()
│   ├── isPremium()
│   ├── validVersionIncrement()
│   ├── validStringLength(field, maxLength)
│   └── validProductName()
├── User-Scoped Collections
│   ├── /users/{userId}/inventory_items/{itemId}
│   ├── /users/{userId}/nutrition_tracking/{entryId} (requires health consent)
│   ├── /users/{userId}/meal_plans/{planId}
│   ├── /users/{userId}/health_profiles/{profileId} (requires health consent)
│   ├── /users/{userId}/nutrition_data/{dataId} (requires health consent)
│   ├── /users/{userId}/settings/{settingId}
│   └── /users/{userId}/quota/{apiName} (read-only)
├── Shared Read-Only Collections
│   ├── /shared/recipes/{recipeId}
│   └── /shared/products_catalog/{productId}
├── Shared Inventories
│   └── /shared_inventories/{sharedId}
├── Feature Flags
│   └── /feature_flags/{featureId}
└── Deny All Other Paths
    └── /{document=**}
```

### Key Security Features

#### 1. Health Data Protection (RGPD Article 9)

```javascript
// Nutrition tracking requires health_data_consent custom claim
match /users/{userId}/nutrition_tracking/{entryId} {
  allow read, write: if isOwner(userId) && hasHealthConsent();

  // Right to erasure - allow delete even without consent
  allow delete: if isOwner(userId)
                && request.auth.token.health_data_consent_withdrawal_approved == true;
}
```

#### 2. Version-Based Conflict Detection

```javascript
// Inventory items use optimistic concurrency control
match /users/{userId}/inventory_items/{itemId} {
  // Create: Version must be 1
  allow create: if isOwner(userId)
                && request.resource.data.version == 1;

  // Update: Version must increment by exactly 1
  allow update: if isOwner(userId)
                && request.resource.data.version == resource.data.version + 1;
}
```

#### 3. Input Validation (XSS Prevention)

```javascript
// Validate product name to prevent XSS attacks
function validProductName() {
  return validStringLength('name', 200)
         && !request.resource.data.name.matches('.*<script.*')
         && !request.resource.data.name.matches('.*javascript:.*');
}
```

#### 4. Shared Inventories (Family Mode)

```javascript
match /shared_inventories/{sharedId} {
  // Read: User must be a member
  allow read: if isAuthenticated()
              && request.auth.uid in resource.data.members;

  // Write: Only the owner can modify
  allow write: if isAuthenticated()
               && request.auth.uid in resource.data.members
               && request.auth.uid == resource.data.owner;
}
```

---

## Storage Security Rules

### File Structure

```
storage.rules (118 lines)
├── Helper Functions
│   ├── isAuthenticated()
│   ├── isOwner(userId)
│   ├── hasHealthConsent()
│   ├── isValidImageSize() (10MB max)
│   └── isValidImageType() (images only)
├── User Files
│   ├── /users/{userId}/profile_picture (public read)
│   ├── /users/{userId}/meal_photos/{photoId} (requires health consent)
│   └── /users/{userId}/receipts/{receiptId}
├── Shared Files
│   └── /shared_inventories/{sharedId}/photos/{photoId}
└── Deny All Other Paths
    └── /{allPaths=**}
```

### Key Security Features

#### 1. File Size Validation

```javascript
// Maximum 10MB per image
function isValidImageSize() {
  return request.resource.size <= 10 * 1024 * 1024;
}
```

#### 2. File Type Validation

```javascript
// Only image files allowed
function isValidImageType() {
  return request.resource.contentType.matches('image/.*');
}
```

#### 3. Health Data Protection (Meal Photos)

```javascript
match /users/{userId}/meal_photos/{photoId} {
  // Requires health_data_consent custom claim
  allow read, write: if isOwner(userId)
                     && hasHealthConsent()
                     && isValidImageType()
                     && isValidImageSize();
}
```

#### 4. Public Profile Pictures

```javascript
match /users/{userId}/profile_picture {
  // All authenticated users can view (for social features)
  allow read: if isAuthenticated();

  // Only owner can upload
  allow write: if isOwner(userId)
               && isValidImageType()
               && isValidImageSize();
}
```

---

## Custom Claims Management

### Setting Custom Claims (Cloud Functions)

```typescript
// firebase/functions/src/auth/setHealthConsent.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const setHealthConsent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = context.auth.uid;
  const consent = data.consent === true;

  // Set custom claim
  await admin.auth().setCustomUserClaims(userId, {
    health_data_consent: consent,
  });

  // Log to Firestore for audit trail
  await admin.firestore().collection('users').doc(userId).set({
    health_data_consent: consent,
    health_data_consent_date: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  return { success: true, consent };
});
```

### Client-Side Usage (Flutter)

```dart
// lib/features/health/data/repositories/health_consent_repository.dart
import 'package:cloud_functions/cloud_functions.dart';

class HealthConsentRepository {
  final _functions = FirebaseFunctions.instance;

  Future<void> grantHealthConsent() async {
    final callable = _functions.httpsCallable('setHealthConsent');
    await callable.call({'consent': true});

    // Force token refresh to get updated custom claims
    await FirebaseAuth.instance.currentUser?.getIdToken(true);
  }

  Future<void> revokeHealthConsent() async {
    final callable = _functions.httpsCallable('setHealthConsent');
    await callable.call({'consent': false});

    // Force token refresh
    await FirebaseAuth.instance.currentUser?.getIdToken(true);
  }
}
```

---

## Deployment

### Prerequisites

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Select project
firebase use <your-project-id>
```

### Deployment Commands

#### Deploy Firestore Rules Only

```bash
firebase deploy --only firestore:rules
```

**Expected Output**:
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/your-project/firestore/rules
```

#### Deploy Storage Rules Only

```bash
firebase deploy --only storage
```

**Expected Output**:
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/your-project/storage/rules
```

#### Deploy Both Rules

```bash
firebase deploy --only firestore:rules,storage
```

### Staged Deployment (Recommended)

```bash
# 1. Deploy to staging first
firebase use staging
firebase deploy --only firestore:rules,storage

# 2. Test thoroughly in staging

# 3. Deploy to production
firebase use production
firebase deploy --only firestore:rules,storage
```

---

## Testing with Emulator

### Start Emulator

```bash
# Start Firestore and Storage emulators
firebase emulators:start --only firestore,storage

# With UI (recommended)
firebase emulators:start --only firestore,storage --import=./emulator-data
```

**Emulator URLs**:
- Firestore UI: http://localhost:4000/firestore
- Storage UI: http://localhost:4000/storage
- Emulator Suite UI: http://localhost:4000

### Automated Testing

Create test file: `test/firestore_rules_test.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firestore Security Rules', () {
    test('users can only read their own data', () async {
      final firestore = FirebaseFirestore.instance;

      // User A tries to read their own data (should succeed)
      final userADoc = await firestore.collection('users').doc('user-a').get();
      expect(userADoc, isNotNull);

      // User A tries to read User B's data (should fail)
      expect(
        () => firestore.collection('users').doc('user-b').get(),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('health data requires consent', () async {
      final firestore = FirebaseFirestore.instance;

      // User without health_data_consent tries to read nutrition data (should fail)
      expect(
        () => firestore.collection('users/user-a/nutrition_tracking').get(),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('version-based conflict detection works', () async {
      final firestore = FirebaseFirestore.instance;

      // Create with version 1 (should succeed)
      await firestore.collection('users/user-a/inventory_items').add({
        'id': 'item-1',
        'name': 'Milk',
        'category': 'dairy',
        'expirationDate': Timestamp.now(),
        'version': 1,
        'updatedAt': Timestamp.now(),
      });

      // Update with version 2 (should succeed)
      final itemRef = firestore.doc('users/user-a/inventory_items/item-1');
      await itemRef.update({'version': 2, 'name': 'Whole Milk'});

      // Update with version 1 (should fail - version conflict)
      expect(
        () => itemRef.update({'version': 1, 'name': 'Skim Milk'}),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('XSS prevention works', () async {
      final firestore = FirebaseFirestore.instance;

      // Try to create product with <script> tag (should fail)
      expect(
        () => firestore.collection('users/user-a/inventory_items').add({
          'id': 'item-xss',
          'name': '<script>alert("XSS")</script>Milk',
          'category': 'dairy',
          'expirationDate': Timestamp.now(),
          'version': 1,
          'updatedAt': Timestamp.now(),
        }),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}
```

### Run Tests

```bash
# Start emulator
firebase emulators:start --only firestore

# In another terminal, run tests
flutter test test/firestore_rules_test.dart
```

---

## Security Validation Checklist

### Pre-Deployment Validation

- [ ] Firestore rules syntax is valid (`firebase deploy --only firestore:rules`)
- [ ] Storage rules syntax is valid (`firebase deploy --only storage`)
- [ ] All helper functions are tested
- [ ] User data isolation is verified (users can't access other users' data)
- [ ] Health data protection works (requires `health_data_consent` custom claim)
- [ ] Premium features are protected (`is_premium` custom claim)
- [ ] Version-based concurrency control works for inventory items
- [ ] XSS prevention is tested (script tags, javascript: URLs)
- [ ] File size limits are enforced (10MB max)
- [ ] File type validation works (images only)
- [ ] Shared inventories work correctly (members can read, owner can write)
- [ ] Deny-all rule catches undeclared paths

### Post-Deployment Validation

- [ ] Test user registration and login
- [ ] Test health data consent flow (grant/revoke)
- [ ] Test inventory CRUD operations (create, read, update, delete)
- [ ] Test version conflict detection (concurrent updates)
- [ ] Test file uploads (profile picture, meal photos, receipts)
- [ ] Test file size rejection (> 10MB)
- [ ] Test file type rejection (non-images)
- [ ] Test quota counters (users can read, cannot write)
- [ ] Test shared inventory access (members vs non-members)
- [ ] Monitor Firebase Console for permission denied errors

---

## Troubleshooting

### Common Issues

#### 1. "Permission Denied" Errors

**Symptom**: `FirebaseException: [firebase_firestore/permission-denied]`

**Causes**:
- User not authenticated (`request.auth == null`)
- User trying to access another user's data
- Health data access without `health_data_consent` custom claim
- Premium feature access without `is_premium` custom claim

**Solution**:
```dart
// Check authentication
if (FirebaseAuth.instance.currentUser == null) {
  await FirebaseAuth.instance.signInAnonymously();
}

// Check custom claims
final idTokenResult = await FirebaseAuth.instance.currentUser?.getIdTokenResult();
print('Custom claims: ${idTokenResult?.claims}');

// Refresh token if custom claims were just set
await FirebaseAuth.instance.currentUser?.getIdToken(true);
```

#### 2. Version Conflict Errors

**Symptom**: Update fails with "version must increment by exactly 1"

**Cause**: Concurrent updates or stale version number

**Solution**:
```dart
// Read latest version before updating
final doc = await inventoryRef.doc(productId).get();
final currentVersion = doc.data()?['version'] ?? 0;

// Update with correct version
await inventoryRef.doc(productId).update({
  'version': currentVersion + 1,
  'name': 'Updated name',
  'updatedAt': FieldValue.serverTimestamp(),
});
```

#### 3. File Upload Fails

**Symptom**: Storage upload rejected

**Causes**:
- File size > 10MB
- File type not image
- Missing health consent (meal photos)
- Wrong path (not owned by user)

**Solution**:
```dart
// Check file size before upload
if (file.lengthSync() > 10 * 1024 * 1024) {
  throw Exception('File too large (max 10MB)');
}

// Check file type
final mimeType = lookupMimeType(file.path);
if (!mimeType.startsWith('image/')) {
  throw Exception('Only images allowed');
}

// For meal photos, check health consent
final claims = (await FirebaseAuth.instance.currentUser?.getIdTokenResult())?.claims;
if (claims?['health_data_consent'] != true) {
  throw Exception('Health data consent required for meal photos');
}
```

#### 4. Custom Claims Not Applied

**Symptom**: Custom claims check fails even after setting

**Cause**: Token not refreshed after setting custom claims

**Solution**:
```dart
// After setting custom claims via Cloud Functions
await FirebaseFunctions.instance.httpsCallable('setHealthConsent').call({'consent': true});

// IMPORTANT: Force token refresh to get updated claims
await FirebaseAuth.instance.currentUser?.getIdToken(true);

// Verify claims
final idTokenResult = await FirebaseAuth.instance.currentUser?.getIdTokenResult();
print('Health consent: ${idTokenResult?.claims?['health_data_consent']}');
```

---

## References

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules Documentation](https://firebase.google.com/docs/storage/security)
- [Custom Claims Documentation](https://firebase.google.com/docs/auth/admin/custom-claims)
- [RGPD Article 9 (Health Data)](https://gdpr-info.eu/art-9-gdpr/)
- [OWASP XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)

---

**Guide Version**: 1.0
**Last Updated**: 2026-02-15
**Story**: 0.10 Phase 3
**Status**: Production-Ready ✅
