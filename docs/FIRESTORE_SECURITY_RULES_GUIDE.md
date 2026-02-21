# Firestore Security Rules - Deployment & Testing Guide

**Story 0.9 Phase 7**: Firestore Security Rules with Version-Based Conflict Detection

---

## 📋 Overview

This guide covers deployment and testing of Firestore Security Rules for FrigoFuteV2.

### Key Features

- **User Data Isolation**: Users can only access their own data under `users/{userId}/`
- **Version-Based Concurrency**: `inventory_items` use optimistic concurrency control
- **Read-Only Collections**: Global collections (recipes, products_catalog) are read-only
- **Authentication Required**: All operations require authenticated users

---

## 🚀 Deployment

### Prerequisites

1. Firebase CLI installed:
   ```bash
   npm install -g firebase-tools
   ```

2. Authenticated with Firebase:
   ```bash
   firebase login
   ```

3. Firebase project initialized:
   ```bash
   firebase init firestore
   ```

### Deploy Security Rules

#### Deploy to Production

```bash
# Deploy only security rules (recommended for isolated changes)
firebase deploy --only firestore:rules

# Deploy with indexes (if you have firestore.indexes.json)
firebase deploy --only firestore
```

#### Deploy to Specific Project

```bash
# If you have multiple Firebase projects
firebase use <project-id>
firebase deploy --only firestore:rules
```

**Example Output:**
```
=== Deploying to 'frigofute-v2-dev'...

i  firestore: checking firestore.rules for compilation errors...
✓  firestore: rules file firestore.rules compiled successfully

i  firestore: uploading rules firestore.rules...
✓  firestore: released rules firestore.rules to cloud.firestore

✓  Deploy complete!
```

---

## 🧪 Testing Security Rules

### 1. Using Firebase Emulator (Recommended)

#### Start Firestore Emulator

```bash
# Start only Firestore emulator
firebase emulators:start --only firestore

# Start with UI
firebase emulators:start --only firestore --import=./emulator-data
```

**Emulator UI:** http://localhost:4000

#### Connect App to Emulator

Update your Flutter app (dev environment only):

```dart
// lib/main.dart (dev mode)
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

### 2. Manual Testing Scenarios

#### Test 1: Create Inventory Item (Valid)

**Request:**
```json
POST /users/user-123/inventory_items/item-456
Auth: uid = user-123

{
  "id": "item-456",
  "name": "Milk",
  "category": "dairy",
  "expirationDate": "2026-02-20T00:00:00Z",
  "storageLocation": "fridge",
  "status": "fresh",
  "version": 1,
  "updatedAt": "2026-02-15T14:00:00Z"
}
```

**Expected:** ✅ Success (version = 1, all required fields present)

#### Test 2: Create Inventory Item (Invalid Version)

**Request:**
```json
POST /users/user-123/inventory_items/item-789
Auth: uid = user-123

{
  "id": "item-789",
  "name": "Bread",
  "category": "bakery",
  "expirationDate": "2026-02-18T00:00:00Z",
  "version": 2,  // ❌ Should be 1
  "updatedAt": "2026-02-15T14:00:00Z"
}
```

**Expected:** ❌ Permission Denied (version must be 1 on create)

#### Test 3: Update Inventory Item (Valid Version Increment)

**Existing Document:**
```json
{
  "id": "item-456",
  "name": "Milk",
  "version": 1,
  "updatedAt": "2026-02-15T14:00:00Z"
}
```

**Update Request:**
```json
PATCH /users/user-123/inventory_items/item-456
Auth: uid = user-123

{
  "id": "item-456",
  "name": "Milk 2L",
  "version": 2,  // ✅ Correct increment (1 + 1)
  "updatedAt": "2026-02-15T15:00:00Z"
}
```

**Expected:** ✅ Success (version incremented by 1)

#### Test 4: Update Inventory Item (Invalid Version Increment)

**Update Request:**
```json
PATCH /users/user-123/inventory_items/item-456
Auth: uid = user-123

{
  "id": "item-456",
  "name": "Milk 3L",
  "version": 5,  // ❌ Jumped from 2 to 5
  "updatedAt": "2026-02-15T16:00:00Z"
}
```

**Expected:** ❌ Permission Denied (version must increment by exactly 1)

#### Test 5: Access Other User's Data (Unauthorized)

**Request:**
```json
GET /users/user-999/inventory_items/item-456
Auth: uid = user-123  // ❌ Different user
```

**Expected:** ❌ Permission Denied (can only access own data)

#### Test 6: Read Recipe (Valid)

**Request:**
```json
GET /recipes/recipe-123
Auth: uid = user-123  // ✅ Authenticated
```

**Expected:** ✅ Success (read-only global collection)

#### Test 7: Write Recipe (Invalid)

**Request:**
```json
POST /recipes/recipe-456
Auth: uid = user-123

{
  "name": "Pasta Carbonara",
  "ingredients": [...]
}
```

**Expected:** ❌ Permission Denied (write not allowed on global collections)

### 3. Automated Testing

Create a test file for security rules:

**File:** `test/firestore_rules_test.dart`

```dart
import 'package:test/test.dart';

void main() {
  group('Firestore Security Rules', () {
    test('User can create inventory item with version 1', () async {
      // TODO: Implement with @firebase/rules-unit-testing
    });

    test('User cannot create inventory item with version != 1', () async {
      // TODO: Implement
    });

    test('User can update inventory item with correct version increment', () async {
      // TODO: Implement
    });

    test('User cannot access other users data', () async {
      // TODO: Implement
    });
  });
}
```

---

## 📊 Version-Based Conflict Detection

### How It Works

1. **Create**: Initial `version` must be 1
2. **Update**: `version` must be `currentVersion + 1`
3. **Conflict**: If version mismatch, Firestore rejects the write
4. **Resolution**: Client refetches latest version and retries

### Example Conflict Scenario

**Initial State (Firestore):**
```json
{
  "id": "item-123",
  "name": "Milk",
  "version": 3,
  "updatedAt": "2026-02-15T10:00:00Z"
}
```

**Device A (Offline):**
```dart
// User edits offline (based on version 3)
final updatedProduct = product.copyWith(name: "Milk 2L");
// When online, attempts to update with version 4
```

**Device B (Online):**
```dart
// User updates immediately (based on version 3)
final updatedProduct = product.copyWith(name: "Milk 1L");
// Successfully updates to version 4
```

**Conflict:**
- Device A comes online and tries to update with version 4
- Firestore sees current version is already 4
- Security rules reject (expected version 5, got version 4)
- ConflictResolver refetches, resolves with LWW, retries with version 5

---

## 🔧 Troubleshooting

### Issue: "Permission Denied" on Valid Request

**Cause:** Security rules not deployed or emulator using old rules

**Solution:**
```bash
# Redeploy rules
firebase deploy --only firestore:rules

# Or restart emulator
firebase emulators:start --only firestore
```

### Issue: Version Increment Failing

**Cause:** ConflictResolver not incrementing version correctly

**Check:**
```dart
// Ensure ConflictResolver.incrementVersion() is called
final dataWithVersion = conflictResolver.incrementVersion(data);
```

### Issue: Emulator Not Connecting

**Cause:** Firestore emulator URL incorrect

**Solution:**
```dart
// Ensure correct emulator config (dev only)
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

---

## 📝 Best Practices

1. **Always Deploy to Staging First**
   ```bash
   firebase use staging
   firebase deploy --only firestore:rules
   # Test thoroughly
   firebase use production
   firebase deploy --only firestore:rules
   ```

2. **Test Version Increments**
   - Verify ConflictResolver increments version
   - Test concurrent updates
   - Validate conflict resolution

3. **Monitor Security Rules Violations**
   - Check Firebase Console → Firestore → Usage
   - Look for denied requests
   - Investigate unexpected permission errors

4. **Document Custom Rules**
   - Add comments for complex logic
   - Explain version-based validation
   - Document helper functions

---

## 🔐 Security Checklist

- ✅ Users can only access their own data (`users/{userId}/`)
- ✅ All operations require authentication
- ✅ Version validation on inventory_items create/update
- ✅ Global collections are read-only
- ✅ Required fields validated on create
- ✅ Admin writes blocked (Cloud Functions only)
- ✅ Helper functions for common checks

---

## 📚 References

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Testing Security Rules](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
- [Optimistic Concurrency Control](https://en.wikipedia.org/wiki/Optimistic_concurrency_control)

---

**Last Updated**: 2026-02-15
**Story**: 0.9 Phase 7 - Firestore Security Rules
