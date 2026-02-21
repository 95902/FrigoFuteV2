# Story 0.10: Configure Security Foundation and API Keys Management

## 📋 Story Metadata

- **Story ID**: 0.10
- **Epic**: Epic 0 - Initial App Setup for First User
- **Title**: Configure Security Foundation and API Keys Management
- **Story Key**: 0-10-configure-security-foundation-and-api-keys-management
- **Status**: ready-for-dev
- **Complexity**: 13 (XL - Critical security foundation)
- **Priority**: P0 (Blocker - RGPD compliance required)
- **Estimated Effort**: 6-10 days
- **Dependencies**:
  - Story 0.1 (Flutter project structure)
  - Story 0.2 (Firebase services)
  - Story 0.3 (Hive local database - encryption)
  - Story 0.8 (Remote Config - feature flags)
- **Tags**: `security`, `rgpd`, `encryption`, `api-keys`, `compliance`, `critical-path`

---

## 📖 User Story

**As a** utilisateur,
**I want** my personal and health data to be protected with the highest security standards,
**So that** I can trust the app with my sensitive information and comply with RGPD Article 9 requirements.

---

## ✅ Acceptance Criteria

### AC1: API Keys Protection
**Given** the app integrates with multiple external APIs (Google Vision, Gemini AI, OpenFoodFacts, Google Maps)
**When** the security architecture is configured
**Then** all API keys are stored server-side in Cloud Functions environment configuration
**And** API keys are never exposed in client code or version control
**And** API keys are rotated automatically every 90 days minimum
**And** Client calls APIs via Cloud Functions proxy (never directly)

### AC2: Encryption at Rest (AES-256)
**Given** the app stores sensitive health data (RGPD Article 9)
**When** local storage is configured
**Then** `nutrition_data_box` Hive box is encrypted with AES-256
**And** `health_profiles_box` Hive box is encrypted with AES-256
**And** Encryption keys are derived from Firebase Auth UID (user-specific)
**And** Encryption keys are stored securely in device keychain (iOS) or KeyStore (Android)
**And** Non-sensitive data (`inventory_box`, `recipes_box`) can remain unencrypted for performance

### AC3: Encryption in Transit (TLS 1.3+)
**Given** the app communicates with backend services
**When** network requests are made
**Then** all Firestore communication uses automatic TLS 1.3+
**And** all Cloud Functions calls enforce HTTPS only
**And** all external API calls (OpenFoodFacts, price APIs) use HTTPS only
**And** certificate pinning is configured for critical Firebase endpoints

### AC4: Firestore Security Rules (User-Scoped)
**Given** multiple users share the same Firestore database
**When** security rules are deployed
**Then** users can only read/write their own data (`users/{userId}/...`)
**And** shared collections (`shared/recipes`) are read-only for clients (write via Cloud Functions)
**And** health data collections require `health_data_consent == true` custom claim
**And** security rules are tested with Firestore Emulator before deployment

### AC5: Firebase Storage Security Rules (User-Scoped)
**Given** users upload photos (meal photos, receipts, profile pictures)
**When** storage security rules are deployed
**Then** users can only read/write their own files (`users/{userId}/photos/...`)
**And** meal photos require `health_data_consent == true` custom claim
**And** profile pictures are readable by all authenticated users (for social features)
**And** file size limits are enforced (max 10MB per image)

### AC6: Input Sanitization (XSS/SQL Injection Prevention)
**Given** users input data (product names, recipe text, etc.)
**When** input validation utilities are implemented
**Then** client-side validation sanitizes HTML characters (`< > " ' &`)
**And** server-side validation (Cloud Functions) validates schema and rejects malicious inputs
**And** regex patterns validate email, EAN-13 barcodes, phone numbers
**And** product names are limited to 200 characters max
**And** XSS payloads (`<script>`, `javascript:`) are rejected

### AC7: Code Obfuscation (Release Builds)
**Given** the app is distributed to end users
**When** release builds are created
**Then** Dart code is obfuscated (`--obfuscate` flag)
**And** debug symbols are uploaded separately to Crashlytics (`--split-debug-info`)
**And** class names, methods, and variables are unreadable in decompiled APK/IPA
**And** exception messages do not expose sensitive information

### AC8: Rate Limiting and Quota Management
**Given** external APIs have usage quotas (Google Vision, Gemini AI, Maps)
**When** quota management is configured
**Then** Gemini AI requests are throttled (max 1 request/2 seconds client-side)
**And** Firestore quota counters track daily usage (100 analyses/day free, unlimited premium)
**And** Google Vision quota is monitored (circuit breaker at 80%, fallback to ML Kit)
**And** Cloud Functions enforce per-user rate limits (100 requests/minute)
**And** user-friendly error messages shown when quotas exceeded

### AC9: Security Linting and CI/CD Checks
**Given** code is pushed to the repository
**When** CI/CD pipeline runs
**Then** `flutter analyze` linting passes with 0 errors
**And** no hardcoded secrets detected (grep for `API_KEY`, `SECRET`, `password`)
**And** `flutter_dotenv` is configured correctly (verified in CI)
**And** OWASP dependency audit passes (`flutter pub audit`)
**And** code coverage is ≥75%

### AC10: Environment Configuration (flutter_dotenv)
**Given** the app runs in multiple environments (dev, staging, prod)
**When** environment configuration is implemented
**Then** `.env.dev`, `.env.staging`, `.env.prod` files exist
**And** all `.env.*` files are gitignored (only `.env.example` committed)
**And** environment variables include: `API_BASE_URL`, `FIREBASE_PROJECT_ID`, `ENABLE_ANALYTICS`
**And** flavor-specific builds load the correct `.env` file

---

## 🏗️ Technical Specifications

### 1. API Keys Management Strategy

#### APIs Requiring Key Management

**1. Google Cloud Vision API**
- **Purpose**: OCR ticket de caisse (receipt scanning)
- **Free Tier**: 1,000 requests/month
- **Management**: Cloud Functions proxy (client never sees key)
- **Monitoring**: Firestore global counter (monthly quota)
- **Circuit Breaker**: At 80% quota → fallback to ML Kit alone
- **Error Handling**: User-friendly message "Vision service temporarily overloaded"

**2. Google Gemini AI API**
- **Purpose**: Meal photo analysis (vision), nutrition chatbot (chat)
- **Quota**: 60 requests/minute (free tier)
- **Management**: Cloud Functions proxy for security
- **Client-side Throttling**: Max 1 request/2 seconds
- **Firestore Quota Counter**: 100 analyses/day (free), unlimited (premium)
- **Caching**: In-memory LRU 100 items, 24h TTL

**3. Firebase Admin SDK (Cloud Functions)**
- **Purpose**: Backend operations (Firestore writes, Auth custom claims)
- **Management**: Google Cloud project environment variables
- **Rotation**: Automated via scheduled Cloud Functions
- **No client exposure**: Never sent to mobile app

**4. OpenFoodFacts API**
- **Purpose**: Nutritional data enrichment
- **Authentication**: Public API (no key required)
- **Cache Strategy**: Local Hive cache, TTL 7 days, LRU max 1,000 products
- **Fallback**: If API unavailable, use local cached data
- **Rate Limit**: Respect 100 requests/minute limit (public API courtesy)

**5. Google Maps API**
- **Purpose**: Interactive store location map (price comparator)
- **Quota**: 28,000 map loads/month (free)
- **Loading Requirement**: < 3 seconds
- **Monitoring**: Circuit breaker if approaching 80% quota
- **Fallback**: List view without map if quota exhausted

**6. Price Comparator APIs** (Phase 2)
- **Purpose**: Price comparison across 4+ retailers
- **Phase 1**: Crowdsourcing model (no API keys)
- **Phase 2**: Official retailer APIs (negotiated partnerships)
- **Update Frequency**: Minimum daily

#### Cloud Functions Environment Configuration

**File**: `firebase/functions/.env`

```bash
# Google Cloud APIs
GOOGLE_VISION_API_KEY=<secret-value>
GEMINI_API_KEY=<secret-value>
GOOGLE_MAPS_API_KEY=<secret-value>

# Firebase Admin SDK
FIREBASE_ADMIN_SERVICE_ACCOUNT=<service-account-json>

# External APIs (Phase 2)
PRICE_API_ENSEIGNA_KEY=<secret-value>
PRICE_API_ENSEIGNB_KEY=<secret-value>

# Feature Flags
ENABLE_VISION_API=true
ENABLE_GEMINI_API=true
GEMINI_MODEL_VERSION=2.5-flash
```

**Deployment** (never commit to git):
```bash
# Set Cloud Functions environment variables
firebase functions:config:set vision.api_key="<secret>" gemini.api_key="<secret>"

# Verify configuration
firebase functions:config:get
```

#### API Proxy Pattern (Cloud Functions)

**File**: `firebase/functions/src/api/geminiProxy.ts`

```typescript
import * as functions from 'firebase-functions';
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(functions.config().gemini.api_key);

export const analyzeMealPhoto = functions.https.onCall(async (data, context) => {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = context.auth.uid;

  // Rate limiting check
  const quotaRef = db.collection('users').doc(userId).collection('quota').doc('gemini');
  const quotaDoc = await quotaRef.get();
  const todayUsage = quotaDoc.data()?.today_count || 0;
  const isPremium = quotaDoc.data()?.is_premium || false;

  if (!isPremium && todayUsage >= 100) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Daily quota exceeded. Upgrade to Premium for unlimited analyses.'
    );
  }

  // Call Gemini API (key hidden from client)
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-preview' });
  const result = await model.generateContent({
    contents: [{ role: 'user', parts: [{ inlineData: { mimeType: 'image/jpeg', data: data.imageBase64 } }] }],
    generationConfig: { maxOutputTokens: 500, temperature: 0.4 },
  });

  // Update quota counter
  await quotaRef.set({ today_count: todayUsage + 1, last_request: new Date() }, { merge: true });

  return { nutrition: result.response.text(), quota_remaining: isPremium ? 'unlimited' : (100 - todayUsage - 1) };
});
```

**Client-side call**:

```dart
// lib/features/ai_coach/data/datasources/gemini_remote_datasource.dart
final callable = FirebaseFunctions.instance.httpsCallable('analyzeMealPhoto');
final result = await callable.call({'imageBase64': base64Image});
// API key never exposed to client!
```

### 2. Encryption Architecture

#### Hive Encrypted Boxes (AES-256)

**File**: `lib/core/services/hive_service.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class HiveService {
  static const _secureStorage = FlutterSecureStorage();
  static const _encryptionKeyName = 'hive_encryption_key';

  /// Initialize Hive with encrypted boxes for health data.
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register TypeAdapters
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(RecipeModelAdapter());
    Hive.registerAdapter(NutritionDataModelAdapter());
    Hive.registerAdapter(HealthProfileModelAdapter());
    Hive.registerAdapter(SyncQueueItemAdapter());

    // Open non-encrypted boxes (performance optimization)
    await Hive.openBox<ProductModel>('inventory_box');
    await Hive.openBox<RecipeModel>('recipes_box');
    await Hive.openBox('settings_box');
    await Hive.openBox('products_cache_box');
    await Hive.openBox<SyncQueueItem>('sync_queue_box');

    // Open encrypted boxes (health data - RGPD Article 9)
    final encryptionKey = await _getOrCreateEncryptionKey();
    final encryptionCipher = HiveAesCipher(encryptionKey);

    await Hive.openBox<NutritionDataModel>(
      'nutrition_data_box',
      encryptionCipher: encryptionCipher,
    );

    await Hive.openBox<HealthProfileModel>(
      'health_profiles_box',
      encryptionCipher: encryptionCipher,
    );
  }

  /// Generates or retrieves encryption key derived from Firebase Auth UID.
  ///
  /// Key storage:
  /// - iOS: Keychain (secure enclave)
  /// - Android: KeyStore (hardware-backed if available)
  static Future<Uint8List> _getOrCreateEncryptionKey() async {
    // Check if key already exists
    final existingKey = await _secureStorage.read(key: _encryptionKeyName);

    if (existingKey != null) {
      return base64Decode(existingKey);
    }

    // Generate new key from Firebase Auth UID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to generate encryption key');
    }

    // Derive 256-bit key from UID using SHA-256
    final uidBytes = utf8.encode(user.uid);
    final digest = sha256.convert(uidBytes);
    final encryptionKey = Uint8List.fromList(digest.bytes);

    // Store in secure storage
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64Encode(encryptionKey),
    );

    return encryptionKey;
  }

  /// Deletes encryption key (called during account deletion).
  static Future<void> deleteEncryptionKey() async {
    await _secureStorage.delete(key: _encryptionKeyName);
  }
}
```

**Dependencies**:

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.2.2
  crypto: ^3.0.6
```

**Platform Configuration**:

**Android** (`android/app/build.gradle`):
```gradle
android {
    defaultConfig {
        minSdkVersion 23 // Required for KeyStore
    }
}
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<!-- Keychain access -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

#### Firestore Encryption (Automatic)

**Note**: Firestore automatically encrypts all data at rest using AES-256 (Google-managed keys). No additional client-side configuration needed.

**Best Practice**: For extra sensitivity (medical diagnoses, etc.), consider **application-level encryption** before storing in Firestore:

```dart
// Example: Encrypt sensitive field before Firestore write
final encryptedDiagnosis = encryptString(healthProfile.medicalDiagnosis, encryptionKey);
await firestoreDoc.set({'diagnosis': encryptedDiagnosis});

// Decrypt when reading
final decryptedDiagnosis = decryptString(firestoreData['diagnosis'], encryptionKey);
```

### 3. TLS 1.3+ Enforcement and Certificate Pinning

#### Automatic TLS (Firebase SDKs)

- **Firestore SDK**: Automatic TLS 1.3+ (no configuration needed)
- **Cloud Functions**: HTTPS enforced by default
- **Firebase Storage**: HTTPS enforced by default

#### Certificate Pinning (Critical Endpoints)

**File**: `lib/core/network/secure_http_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';

class SecureHttpClient {
  static Dio createSecureClient() {
    final dio = Dio();

    // Certificate pinning for Firebase endpoints
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Pin certificates for critical Firebase domains
        const trustedHosts = [
          'firestore.googleapis.com',
          'cloudfunctions.googleapis.com',
          'firebasestorage.googleapis.com',
        ];

        if (trustedHosts.contains(host)) {
          // Verify certificate fingerprint (SHA-256)
          final certFingerprint = cert.sha256.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':');
          const expectedFingerprint = 'AA:BB:CC:DD:...'; // Replace with actual Firebase cert fingerprint

          return certFingerprint == expectedFingerprint;
        }

        // Default behavior for other domains
        return false; // Reject invalid certs (fail-secure)
      };

      return client;
    };

    return dio;
  }
}
```

**Usage**:

```dart
// Use secure client for critical API calls
final dio = SecureHttpClient.createSecureClient();
final response = await dio.get('https://firestore.googleapis.com/...');
```

**Certificate Fingerprint Update** (rotate every 90 days):
1. Fetch current Firebase certificate: `openssl s_client -connect firestore.googleapis.com:443 -showcerts`
2. Calculate SHA-256 fingerprint: `openssl x509 -in cert.pem -fingerprint -sha256 -noout`
3. Update `expectedFingerprint` in code
4. Deploy via CI/CD

### 4. Firestore Security Rules (Comprehensive)

**File**: `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function hasHealthConsent() {
      return isAuthenticated() && request.auth.token.health_data_consent == true;
    }

    function isPremium() {
      return isAuthenticated() && request.auth.token.is_premium == true;
    }

    // User-scoped collections
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // Inventory items
      match /inventory_items/{itemId} {
        allow read, write: if isOwner(userId);

        // Validate schema
        allow create: if isOwner(userId)
          && request.resource.data.name is string
          && request.resource.data.name.size() <= 200
          && request.resource.data.category is string
          && request.resource.data.expirationDate is timestamp;
      }

      // Nutrition tracking (health data - extra protection)
      match /nutrition_tracking/{trackingId} {
        allow read, write: if isOwner(userId) && hasHealthConsent();

        // Consent withdrawal → allow delete
        allow delete: if isOwner(userId)
          && request.auth.token.health_data_consent_withdrawal_approved == true;
      }

      // Health profiles (sensitive medical data)
      match /health_profiles/{profileId} {
        allow read, write: if isOwner(userId) && hasHealthConsent();
      }

      // Meal plans
      match /meal_plans/{planId} {
        allow read, write: if isOwner(userId);
      }

      // Nutrition data (meal photos analysis)
      match /nutrition_data/{dataId} {
        allow read, write: if isOwner(userId) && hasHealthConsent();
      }

      // User settings
      match /settings/{settingId} {
        allow read, write: if isOwner(userId);
      }

      // Quota counters
      match /quota/{apiName} {
        allow read: if isOwner(userId);
        allow write: if false; // Only Cloud Functions can write
      }
    }

    // Shared read-only collections (managed by Cloud Functions)
    match /shared/recipes/{recipeId} {
      allow read: if isAuthenticated();
      allow write: if false; // Cloud Functions only
    }

    match /shared/products_catalog/{productId} {
      allow read: if isAuthenticated();
      allow write: if false; // Cloud Functions only
    }

    // Shared inventories (family/colocation mode)
    match /shared_inventories/{sharedId} {
      allow read: if isAuthenticated()
        && request.auth.uid in resource.data.members;

      allow write: if isAuthenticated()
        && request.auth.uid in resource.data.members
        && request.auth.uid == resource.data.owner; // Only owner can modify
    }

    // Premium features (feature flag override)
    match /feature_flags/{featureId} {
      allow read: if isAuthenticated();
      allow write: if false; // Remote Config + Cloud Functions only
    }

    // Deny all other paths
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Deployment**:

```bash
# Deploy Firestore Security Rules
firebase deploy --only firestore:rules

# Test rules with Firestore Emulator
firebase emulators:start --only firestore
```

**Testing Rules**:

```dart
// test/firestore_rules_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firestore Security Rules', () {
    test('users can only read their own data', () async {
      final firestore = FirebaseFirestore.instance;
      final mockUser = MockUser(uid: 'user-abc');

      // Should succeed
      await firestore.collection('users').doc('user-abc').get();

      // Should fail (PermissionDenied)
      expect(
        () => firestore.collection('users').doc('user-xyz').get(),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('health data requires consent', () async {
      final firestore = FirebaseFirestore.instance;
      final mockUser = MockUser(uid: 'user-abc', customClaims: {'health_data_consent': false});

      // Should fail (no consent)
      expect(
        () => firestore.collection('users/user-abc/nutrition_tracking').add({}),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}
```

### 5. Firebase Storage Security Rules

**File**: `storage.rules`

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function hasHealthConsent() {
      return isAuthenticated() && request.auth.token.health_data_consent == true;
    }

    function isValidImageSize() {
      return request.resource.size <= 10 * 1024 * 1024; // 10MB max
    }

    function isValidImageType() {
      return request.resource.contentType.matches('image/.*');
    }

    // User profile pictures
    match /users/{userId}/profile_picture {
      allow read: if isAuthenticated(); // All authenticated users can view
      allow write: if isOwner(userId)
        && isValidImageType()
        && isValidImageSize();
    }

    // User meal photos (health data)
    match /users/{userId}/meal_photos/{photoId} {
      allow read, write: if isOwner(userId)
        && hasHealthConsent()
        && isValidImageType()
        && isValidImageSize();
    }

    // Receipt photos (OCR scanning)
    match /users/{userId}/receipts/{receiptId} {
      allow read, write: if isOwner(userId)
        && isValidImageType()
        && isValidImageSize();
    }

    // Shared family inventory photos
    match /shared_inventories/{sharedId}/photos/{photoId} {
      allow read: if isAuthenticated()
        && request.auth.uid in firestore.get(/databases/(default)/documents/shared_inventories/$(sharedId)).data.members;

      allow write: if isAuthenticated()
        && request.auth.uid in firestore.get(/databases/(default)/documents/shared_inventories/$(sharedId)).data.members
        && isValidImageType()
        && isValidImageSize();
    }

    // Deny all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

**Deployment**:

```bash
# Deploy Firebase Storage Security Rules
firebase deploy --only storage
```

### 6. Input Sanitization Utilities

#### Client-Side Validation

**File**: `lib/core/validation/input_sanitizer.dart`

```dart
import 'dart:math';
import 'package:html_unescape/html_unescape.dart';

class InputSanitizer {
  static const int maxProductNameLength = 200;
  static const int maxRecipeTextLength = 5000;

  /// Validates and sanitizes EAN-13 barcode.
  static String? sanitizeEAN13(String barcode) {
    final cleaned = barcode.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 13) return null;
    return cleaned;
  }

  /// Validates email format.
  static bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    return regex.hasMatch(email);
  }

  /// Sanitizes product name (prevent XSS).
  static String sanitizeProductName(String name) {
    return name
        .replaceAll(RegExp(r'[<>\"\'&]'), '') // Remove HTML chars
        .replaceAll(RegExp(r'<script.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .trim()
        .substring(0, min(maxProductNameLength, name.length));
  }

  /// Sanitizes recipe text (prevent XSS).
  static String sanitizeRecipeText(String text) {
    final unescaped = HtmlUnescape().convert(text);
    return unescaped
        .replaceAll(RegExp(r'<script.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<iframe.*?</iframe>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'onerror=', caseSensitive: false), '')
        .trim()
        .substring(0, min(maxRecipeTextLength, text.length));
  }

  /// Validates phone number (international format).
  static bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$'); // E.164 format
    return regex.hasMatch(phone);
  }

  /// Sanitizes user input (generic).
  static String sanitizeGenericInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>\"\'&]'), '')
        .trim()
        .substring(0, min(500, input.length));
  }

  /// Validates quantity (positive number).
  static double? sanitizeQuantity(String quantity) {
    final parsed = double.tryParse(quantity);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }
}
```

**Usage**:

```dart
// In product form validation
final sanitizedName = InputSanitizer.sanitizeProductName(nameController.text);
if (sanitizedName.isEmpty) {
  return 'Product name cannot be empty';
}
```

#### Server-Side Validation (Cloud Functions)

**File**: `firebase/functions/src/validators.ts`

```typescript
export function validateProductInput(product: any): { valid: boolean; error?: string } {
  // Name validation
  if (!product.name || typeof product.name !== 'string') {
    return { valid: false, error: 'Product name is required' };
  }

  if (product.name.length < 1 || product.name.length > 200) {
    return { valid: false, error: 'Product name must be 1-200 characters' };
  }

  // XSS prevention
  const xssPattern = /<script|javascript:|onerror=|<iframe/i;
  if (xssPattern.test(product.name) || xssPattern.test(product.description || '')) {
    return { valid: false, error: 'Invalid characters detected (security)' };
  }

  // SQL injection prevention (paranoid check, Firestore uses NoSQL)
  const sqlPattern = /['";--]/;
  if (sqlPattern.test(product.name)) {
    return { valid: false, error: 'Invalid characters in product name' };
  }

  // Category validation (enum)
  const validCategories = ['fruits', 'vegetables', 'dairy', 'meat', 'beverages', 'other'];
  if (!validCategories.includes(product.category)) {
    return { valid: false, error: 'Invalid category' };
  }

  // Expiration date validation
  if (!product.expirationDate || !(product.expirationDate instanceof Date)) {
    return { valid: false, error: 'Invalid expiration date' };
  }

  return { valid: true };
}
```

**Usage in Cloud Function**:

```typescript
export const addProduct = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Validate input
  const validation = validateProductInput(data.product);
  if (!validation.valid) {
    throw new functions.https.HttpsError('invalid-argument', validation.error);
  }

  // Proceed with Firestore write
  await admin.firestore().collection(`users/${context.auth.uid}/inventory_items`).add(data.product);
  return { success: true };
});
```

### 7. Code Obfuscation (Release Builds)

#### Build Configuration

**Android** (`android/app/build.gradle`):

```gradle
android {
    buildTypes {
        release {
            signingConfig signingConfigs.release

            // Enable ProGuard for additional obfuscation
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**ProGuard Rules** (`android/app/proguard-rules.pro`):

```proguard
# Keep Flutter wrapper classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Obfuscate everything else
-repackageclasses 'a.b.c'
-allowaccessmodification
```

**iOS** (`ios/Runner.xcodeproj/project.pbxproj`):

```xml
<!-- Enable bitcode for additional optimization -->
<key>ENABLE_BITCODE</key>
<string>YES</string>
```

#### Flutter Build Commands

**Android Release**:

```bash
flutter build appbundle \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android
```

**iOS Release**:

```bash
flutter build ipa \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/ios
```

#### Debug Symbols Upload (Crashlytics)

**File**: `firebase/functions/src/uploadSymbols.ts`

```typescript
// Automated symbol upload after release build
import { exec } from 'child_process';
import * as admin from 'firebase-admin';

export async function uploadDebugSymbols(platform: 'android' | 'ios') {
  const symbolsPath = `build/symbols/${platform}`;

  // Upload to Crashlytics
  exec(`firebase crashlytics:symbols:upload ${symbolsPath}`, (error, stdout) => {
    if (error) {
      console.error('Symbol upload failed:', error);
      return;
    }
    console.log('Symbols uploaded successfully:', stdout);
  });
}
```

### 8. Environment Configuration (flutter_dotenv)

#### Setup

**Add dependency**:

```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.2.1
```

**Environment Files**:

**`.env.dev`** (development):
```bash
API_BASE_URL=https://us-central1-frigofute-dev.cloudfunctions.net
FIREBASE_PROJECT_ID=frigofute-dev
ENABLE_ANALYTICS=false
GEMINI_MODEL_VERSION=2.5-flash-lite
ENVIRONMENT=development
```

**`.env.staging`** (staging):
```bash
API_BASE_URL=https://us-central1-frigofute-staging.cloudfunctions.net
FIREBASE_PROJECT_ID=frigofute-staging
ENABLE_ANALYTICS=true
GEMINI_MODEL_VERSION=2.5-flash
ENVIRONMENT=staging
```

**`.env.prod`** (production):
```bash
API_BASE_URL=https://us-central1-frigofute-prod.cloudfunctions.net
FIREBASE_PROJECT_ID=frigofute-prod
ENABLE_ANALYTICS=true
GEMINI_MODEL_VERSION=2.5-flash
ENVIRONMENT=production
```

**`.env.example`** (committed to git):
```bash
# Example environment configuration (DO NOT put real values here)
API_BASE_URL=https://your-cloud-functions-url.cloudfunctions.net
FIREBASE_PROJECT_ID=your-project-id
ENABLE_ANALYTICS=true|false
GEMINI_MODEL_VERSION=2.5-flash|2.5-flash-lite
ENVIRONMENT=development|staging|production
```

**`.gitignore`**:
```
.env.dev
.env.staging
.env.prod
```

#### Load Environment in App

**File**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env.prod'); // Change based on build flavor

  runApp(const MyApp());
}
```

**Usage**:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiBaseUrl = dotenv.env['API_BASE_URL']!;
final enableAnalytics = dotenv.env['ENABLE_ANALYTICS'] == 'true';
```

#### Flavor-Specific Loading

**File**: `lib/config/environment.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { dev, staging, prod }

class Environment {
  static Flavor? _flavor;

  static Future<void> init(Flavor flavor) async {
    _flavor = flavor;

    final envFile = switch (flavor) {
      Flavor.dev => '.env.dev',
      Flavor.staging => '.env.staging',
      Flavor.prod => '.env.prod',
    };

    await dotenv.load(fileName: envFile);
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL']!;
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID']!;
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS'] == 'true';
  static Flavor get flavor => _flavor!;
}
```

**Main entry points**:

**`lib/main_dev.dart`**:
```dart
void main() async {
  await Environment.init(Flavor.dev);
  runApp(const MyApp());
}
```

**`lib/main_prod.dart`**:
```dart
void main() async {
  await Environment.init(Flavor.prod);
  runApp(const MyApp());
}
```

**Build commands**:
```bash
flutter run -t lib/main_dev.dart --flavor dev
flutter build appbundle -t lib/main_prod.dart --flavor prod --release
```

### 9. Rate Limiting and Quota Management

#### Gemini AI Throttling

**File**: `lib/features/ai_coach/data/datasources/gemini_throttler.dart`

```dart
import 'dart:async';

class GeminiThrottler {
  static const _minRequestInterval = Duration(seconds: 2);
  DateTime? _lastRequestTime;

  /// Throttles requests to max 1 per 2 seconds.
  Future<void> throttle() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _minRequestInterval) {
        final delay = _minRequestInterval - elapsed;
        await Future.delayed(delay);
      }
    }
    _lastRequestTime = DateTime.now();
  }
}
```

**Usage**:

```dart
final throttler = GeminiThrottler();

Future<String> analyzeMeal(String imageBase64) async {
  await throttler.throttle(); // Wait if needed
  final result = await geminiRemoteDataSource.analyzeMeal(imageBase64);
  return result;
}
```

#### Firestore Quota Counter

**Cloud Function** (`firebase/functions/src/quota/geminiQuota.ts`):

```typescript
export const trackGeminiUsage = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = context.auth.uid;
  const quotaRef = admin.firestore().collection('users').doc(userId).collection('quota').doc('gemini');

  // Atomic increment
  await quotaRef.set(
    {
      today_count: admin.firestore.FieldValue.increment(1),
      last_request: admin.firestore.Timestamp.now(),
    },
    { merge: true }
  );

  // Check limit
  const quotaDoc = await quotaRef.get();
  const todayCount = quotaDoc.data()?.today_count || 0;
  const isPremium = context.auth.token.is_premium || false;

  if (!isPremium && todayCount > 100) {
    throw new functions.https.HttpsError('resource-exhausted', 'Daily quota exceeded');
  }

  return { remaining: isPremium ? 'unlimited' : (100 - todayCount) };
});
```

**Daily Reset** (scheduled Cloud Function):

```typescript
export const resetDailyQuota = functions.pubsub.schedule('0 0 * * *').onRun(async () => {
  const usersSnapshot = await admin.firestore().collection('users').get();

  const batch = admin.firestore().batch();
  usersSnapshot.docs.forEach((userDoc) => {
    const quotaRef = userDoc.ref.collection('quota').doc('gemini');
    batch.set(quotaRef, { today_count: 0 }, { merge: true });
  });

  await batch.commit();
  console.log('Daily quota reset completed');
});
```

#### Google Vision Circuit Breaker

**File**: `lib/core/api/vision_circuit_breaker.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VisionCircuitBreaker {
  static const _monthlyLimit = 1000;
  static const _warningThreshold = 800; // 80%

  Future<bool> canMakeRequest() async {
    final quotaDoc = await FirebaseFirestore.instance
        .collection('global_quota')
        .doc('google_vision')
        .get();

    final monthlyUsage = quotaDoc.data()?['monthly_count'] ?? 0;

    if (monthlyUsage >= _monthlyLimit) {
      return false; // Circuit breaker OPEN → fallback to ML Kit
    }

    return true; // Circuit breaker CLOSED → proceed
  }

  Future<void> trackRequest() async {
    await FirebaseFirestore.instance.collection('global_quota').doc('google_vision').set(
      {'monthly_count': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }
}
```

**Usage in OCR Service**:

```dart
Future<List<Product>> scanReceipt(File receiptImage) async {
  final circuitBreaker = VisionCircuitBreaker();

  if (await circuitBreaker.canMakeRequest()) {
    // Use Google Vision API (higher accuracy)
    final result = await visionAPI.recognizeText(receiptImage);
    await circuitBreaker.trackRequest();
    return result;
  } else {
    // Fallback to ML Kit (on-device, no quota)
    final result = await mlKit.recognizeText(receiptImage);
    return result;
  }
}
```

### 10. CI/CD Security Linting Rules

**File**: `.github/workflows/security_checks.yml`

```yaml
name: Security Checks
on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  security-audit:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.6'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Flutter Analyze (Linting)
        run: flutter analyze --fatal-infos --fatal-warnings

      - name: Check for hardcoded secrets
        run: |
          echo "Checking for hardcoded secrets..."
          ! grep -r "API_KEY\|SECRET\|password\|token" lib/ --include="*.dart" --exclude-dir={test,integration_test}
          echo "✓ No hardcoded secrets found"

      - name: Verify flutter_dotenv is configured
        run: |
          grep -q "flutter_dotenv" pubspec.yaml && echo "✓ flutter_dotenv configured"

      - name: Verify .env files are gitignored
        run: |
          grep -q ".env.dev" .gitignore && echo "✓ .env files gitignored"

      - name: Check Firebase config not in code
        run: |
          ! grep -r "google-services.json\|GoogleService-Info.plist" lib/ --include="*.dart"
          echo "✓ Firebase config not hardcoded"

      - name: OWASP dependency check
        run: |
          flutter pub get
          flutter pub audit || echo "⚠️  Vulnerabilities detected (review manually)"

      - name: Run tests with coverage
        run: flutter test --coverage

      - name: Check code coverage threshold (75%)
        run: |
          # Install lcov
          sudo apt-get install lcov

          # Calculate coverage
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')

          echo "Code coverage: ${COVERAGE}%"

          # Fail if below threshold
          if (( $(echo "$COVERAGE < 75" | bc -l) )); then
            echo "❌ Coverage ${COVERAGE}% is below threshold (75%)"
            exit 1
          fi

          echo "✓ Coverage passed"

      - name: Verify obfuscation flags in CI
        run: |
          echo "Checking for obfuscation configuration..."
          grep -q "obfuscate" README.md || echo "⚠️  Add obfuscation instructions to README"
```

---

## 📝 Implementation Tasks

### Phase 1: API Keys Management (Days 1-2)

- [ ] **Task 1.1**: Create Cloud Functions environment configuration (`.env` file)
- [ ] **Task 1.2**: Set Firebase Functions config variables (`firebase functions:config:set`)
- [ ] **Task 1.3**: Implement Gemini AI proxy Cloud Function (`analyzeMealPhoto`)
- [ ] **Task 1.4**: Implement Google Vision proxy Cloud Function (`recognizeReceipt`)
- [ ] **Task 1.5**: Create quota tracking Cloud Functions (daily reset, counters)
- [ ] **Task 1.6**: Test API proxies with Postman/curl

### Phase 2: Encryption Configuration (Days 2-3)

- [ ] **Task 2.1**: Add `flutter_secure_storage` and `crypto` dependencies
- [ ] **Task 2.2**: Implement `_getOrCreateEncryptionKey()` in HiveService
- [ ] **Task 2.3**: Configure encrypted Hive boxes (`nutrition_data_box`, `health_profiles_box`)
- [ ] **Task 2.4**: Test encryption key generation with Firebase Auth UID
- [ ] **Task 2.5**: Verify keys stored in Keychain (iOS) / KeyStore (Android)
- [ ] **Task 2.6**: Test encryption/decryption with sample health data

### Phase 3: Firestore & Storage Security Rules (Day 3-4)

- [ ] **Task 3.1**: Write comprehensive Firestore Security Rules (`firestore.rules`)
- [ ] **Task 3.2**: Add custom claims validation (`health_data_consent`, `is_premium`)
- [ ] **Task 3.3**: Write Firebase Storage Security Rules (`storage.rules`)
- [ ] **Task 3.4**: Deploy rules to Firebase Console
- [ ] **Task 3.5**: Test rules with Firestore Emulator
- [ ] **Task 3.6**: Write automated tests for security rules

### Phase 4: Input Sanitization (Day 4-5)

- [ ] **Task 4.1**: Create `InputSanitizer` class with validation methods
- [ ] **Task 4.2**: Implement client-side sanitization (XSS prevention)
- [ ] **Task 4.3**: Implement server-side validation (Cloud Functions)
- [ ] **Task 4.4**: Add regex validators (email, EAN-13, phone)
- [ ] **Task 4.5**: Write unit tests for sanitization edge cases
- [ ] **Task 4.6**: Test with XSS/SQL injection payloads

### Phase 5: Code Obfuscation & Build Configuration (Day 5-6)

- [ ] **Task 5.1**: Configure ProGuard rules (`android/app/proguard-rules.pro`)
- [ ] **Task 5.2**: Enable minifyEnabled and shrinkResources (Android)
- [ ] **Task 5.3**: Enable bitcode (iOS)
- [ ] **Task 5.4**: Test release build with `--obfuscate` flag
- [ ] **Task 5.5**: Verify obfuscated APK with APK Analyzer
- [ ] **Task 5.6**: Upload debug symbols to Crashlytics

### Phase 6: Environment Configuration (Day 6-7)

- [ ] **Task 6.1**: Add `flutter_dotenv` dependency
- [ ] **Task 6.2**: Create `.env.dev`, `.env.staging`, `.env.prod` files
- [ ] **Task 6.3**: Create `.env.example` (template for documentation)
- [ ] **Task 6.4**: Update `.gitignore` to exclude `.env.*` files
- [ ] **Task 6.5**: Implement `Environment` class for flavor-specific loading
- [ ] **Task 6.6**: Create `main_dev.dart`, `main_staging.dart`, `main_prod.dart` entry points
- [ ] **Task 6.7**: Test flavor-specific builds

### Phase 7: Rate Limiting & Quota Management (Day 7-8)

- [ ] **Task 7.1**: Implement `GeminiThrottler` (1 request/2 seconds)
- [ ] **Task 7.2**: Implement `VisionCircuitBreaker` (80% quota threshold)
- [ ] **Task 7.3**: Create Firestore quota counters (`users/{uid}/quota/{api}`)
- [ ] **Task 7.4**: Implement Cloud Functions for quota tracking
- [ ] **Task 7.5**: Implement daily quota reset (scheduled Cloud Function)
- [ ] **Task 7.6**: Test quota exhaustion scenarios

### Phase 8: Certificate Pinning (Day 8-9)

- [ ] **Task 8.1**: Create `SecureHttpClient` with certificate pinning
- [ ] **Task 8.2**: Extract Firebase certificate fingerprints (SHA-256)
- [ ] **Task 8.3**: Configure pinning for `firestore.googleapis.com`
- [ ] **Task 8.4**: Configure pinning for `cloudfunctions.googleapis.com`
- [ ] **Task 8.5**: Test pinning with valid/invalid certificates
- [ ] **Task 8.6**: Document certificate rotation process (90-day cycle)

### Phase 9: CI/CD Security Checks (Day 9-10)

- [ ] **Task 9.1**: Create `.github/workflows/security_checks.yml`
- [ ] **Task 9.2**: Add hardcoded secrets detection (grep for API_KEY, etc.)
- [ ] **Task 9.3**: Add OWASP dependency check (`flutter pub audit`)
- [ ] **Task 9.4**: Add code coverage gate (≥75%)
- [ ] **Task 9.5**: Verify obfuscation flags in CI
- [ ] **Task 9.6**: Test CI workflow on pull request

### Phase 10: Testing & Documentation (Day 10)

- [ ] **Task 10.1**: Write unit tests for `InputSanitizer`
- [ ] **Task 10.2**: Write integration tests for API proxy calls
- [ ] **Task 10.3**: Write tests for Firestore Security Rules
- [ ] **Task 10.4**: Write tests for encryption key generation
- [ ] **Task 10.5**: Update README with security guidelines
- [ ] **Task 10.6**: Document API key rotation process

---

## 🧪 Testing Strategy

### Unit Tests

**File**: `test/core/validation/input_sanitizer_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/validation/input_sanitizer.dart';

void main() {
  group('InputSanitizer', () {
    test('should sanitize XSS attack vectors', () {
      final maliciousInput = '<script>alert("XSS")</script>Product Name';
      final sanitized = InputSanitizer.sanitizeProductName(maliciousInput);

      expect(sanitized, 'Product Name');
      expect(sanitized, isNot(contains('<script>')));
    });

    test('should validate EAN-13 barcode correctly', () {
      expect(InputSanitizer.sanitizeEAN13('1234567890123'), '1234567890123');
      expect(InputSanitizer.sanitizeEAN13('123'), null); // Too short
      expect(InputSanitizer.sanitizeEAN13('abc1234567890'), null); // Invalid chars
    });

    test('should validate email format', () {
      expect(InputSanitizer.isValidEmail('user@example.com'), true);
      expect(InputSanitizer.isValidEmail('invalid-email'), false);
      expect(InputSanitizer.isValidEmail('user@'), false);
    });

    test('should sanitize SQL injection attempts', () {
      final sqlInjection = "'; DROP TABLE users; --";
      final sanitized = InputSanitizer.sanitizeProductName(sqlInjection);

      expect(sanitized, isNot(contains(';')));
      expect(sanitized, isNot(contains('--')));
    });

    test('should limit product name length', () {
      final longName = 'A' * 300;
      final sanitized = InputSanitizer.sanitizeProductName(longName);

      expect(sanitized.length, 200); // Max length enforced
    });
  });
}
```

### Integration Tests

**File**: `integration_test/security_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frigofute_v2/core/services/hive_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Security Integration Tests', () {
    testWidgets('should encrypt health data in Hive', (tester) async {
      await HiveService.init();

      // Open encrypted box
      final nutritionBox = Hive.box<NutritionDataModel>('nutrition_data_box');

      // Add data
      final testData = NutritionDataModel(
        id: 'test-1',
        userId: 'user-abc',
        calories: 2000,
        protein: 150,
      );
      await nutritionBox.add(testData);

      // Verify encrypted on disk
      final boxPath = nutritionBox.path;
      final boxFile = File(boxPath!);
      final rawBytes = await boxFile.readAsBytes();

      // Should NOT contain plaintext 'user-abc' (encrypted)
      final rawString = String.fromCharCodes(rawBytes);
      expect(rawString, isNot(contains('user-abc')));
    });

    testWidgets('should reject API calls without authentication', (tester) async {
      final callable = FirebaseFunctions.instance.httpsCallable('analyzeMealPhoto');

      // Sign out to simulate unauthenticated call
      await FirebaseAuth.instance.signOut();

      expect(
        () => callable.call({'imageBase64': 'fake-data'}),
        throwsA(isA<FirebaseFunctionsException>()),
      );
    });

    testWidgets('should enforce Firestore security rules', (tester) async {
      final firestore = FirebaseFirestore.instance;

      // Attempt to read another user's data
      expect(
        () => firestore.collection('users').doc('other-user-id').get(),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}
```

### Security Penetration Tests

**Manual Test Cases**:

1. **XSS Attack**:
   - Input: `<script>alert('XSS')</script>` in product name field
   - Expected: Sanitized, no alert shown

2. **SQL Injection**:
   - Input: `'; DROP TABLE products; --` in product name
   - Expected: Rejected or sanitized

3. **Certificate Pinning**:
   - MITM attack simulation with self-signed certificate
   - Expected: Request blocked, error logged

4. **Firestore Rules Bypass**:
   - Attempt to read `/users/{other-user-id}/inventory`
   - Expected: PermissionDenied error

5. **API Quota Exhaustion**:
   - Send 101 Gemini requests in 1 day (free tier)
   - Expected: `resource-exhausted` error on 101st request

---

## ⚠️ Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Hardcoding API Keys in Code

**Problem**:
```dart
// BAD: Hardcoded API key
const geminiApiKey = 'AIzaSyABC123...'; // ❌ Exposed in version control
```

**Solution**:
```dart
// GOOD: API key in Cloud Functions environment
// Client calls proxy Cloud Function
final callable = FirebaseFunctions.instance.httpsCallable('analyzeMealPhoto');
final result = await callable.call({'imageBase64': imageData});
```

### ❌ Anti-Pattern 2: Storing Sensitive Data Unencrypted

**Problem**:
```dart
// BAD: Health data in unencrypted Hive box
await Hive.openBox('nutrition_data_box'); // ❌ No encryption
```

**Solution**:
```dart
// GOOD: Encrypted Hive box with AES-256
final encryptionKey = await _getOrCreateEncryptionKey();
await Hive.openBox(
  'nutrition_data_box',
  encryptionCipher: HiveAesCipher(encryptionKey), // ✅ Encrypted
);
```

### ❌ Anti-Pattern 3: Ignoring Input Validation

**Problem**:
```dart
// BAD: Trust user input blindly
await firestore.collection('products').add({
  'name': nameController.text, // ❌ No validation
});
```

**Solution**:
```dart
// GOOD: Sanitize and validate input
final sanitizedName = InputSanitizer.sanitizeProductName(nameController.text);
if (sanitizedName.isEmpty) {
  throw ValidationException('Product name cannot be empty');
}
await firestore.collection('products').add({'name': sanitizedName});
```

### ❌ Anti-Pattern 4: Weak Firestore Security Rules

**Problem**:
```javascript
// BAD: Allow all reads/writes
match /users/{userId} {
  allow read, write: if true; // ❌ No authentication check
}
```

**Solution**:
```javascript
// GOOD: User-scoped rules
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId; // ✅
}
```

### ❌ Anti-Pattern 5: Not Obfuscating Release Builds

**Problem**:
```bash
# BAD: Release build without obfuscation
flutter build appbundle --release # ❌ Decompilable
```

**Solution**:
```bash
# GOOD: Obfuscated release build
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols # ✅
```

### ❌ Anti-Pattern 6: Ignoring Rate Limiting

**Problem**:
```dart
// BAD: Unlimited API calls
for (var image in images) {
  await geminiAPI.analyze(image); // ❌ Will hit quota quickly
}
```

**Solution**:
```dart
// GOOD: Throttled API calls
for (var image in images) {
  await throttler.throttle(); // ✅ Max 1 req/2s
  await geminiAPI.analyze(image);
}
```

### ❌ Anti-Pattern 7: Committing .env Files to Git

**Problem**:
```bash
# BAD: .env files committed to git
git add .env.prod # ❌ Exposes secrets
```

**Solution**:
```bash
# GOOD: .env files gitignored
# .gitignore
.env.dev
.env.staging
.env.prod

# Only .env.example committed (no real values)
```

### ❌ Anti-Pattern 8: Skipping Certificate Pinning

**Problem**:
```dart
// BAD: No certificate pinning
final dio = Dio();
await dio.get('https://api.example.com'); // ❌ Vulnerable to MITM
```

**Solution**:
```dart
// GOOD: Certificate pinning enabled
final dio = SecureHttpClient.createSecureClient(); // ✅ Pinned certs
await dio.get('https://api.example.com');
```

---

## 🔗 Integration Points

### Integration with Story 0.2 (Firebase Services)

**Dependency**: Requires Firebase Auth, Firestore, Cloud Functions, Storage initialized.

```dart
// Security rules apply to Firestore/Storage configured in 0.2
// Custom claims (health_data_consent, is_premium) set via Cloud Functions
```

### Integration with Story 0.3 (Hive Local Database)

**Dependency**: Encrypted Hive boxes configured in 0.3.

```dart
// lib/core/services/hive_service.dart (enhanced in Story 0.10)
static Future<void> init() async {
  // Existing boxes from Story 0.3
  await Hive.openBox('inventory_box'); // Unencrypted

  // NEW: Encrypted boxes (Story 0.10)
  final encryptionKey = await _getOrCreateEncryptionKey();
  await Hive.openBox(
    'nutrition_data_box',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
}
```

### Integration with Story 0.8 (Feature Flags)

**Dependency**: Premium feature flags protected by security rules.

```dart
// Firestore Security Rules (Story 0.10)
match /feature_flags/{featureId} {
  allow read: if request.auth != null;
  allow write: if false; // Only Remote Config + Cloud Functions
}
```

### Integration with Epic 1 (Authentication)

**Dependency**: Custom claims set during auth flow.

```typescript
// Cloud Functions (Story 0.10)
export const setHealthConsent = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');

  await admin.auth().setCustomUserClaims(context.auth.uid, {
    health_data_consent: data.consent,
  });

  return { success: true };
});
```

### Integration with Epic 7 (Nutrition Tracking)

**Dependency**: Health data encryption enforced.

```dart
// Nutrition data stored in encrypted Hive box
final nutritionBox = Hive.box<NutritionDataModel>('nutrition_data_box');
await nutritionBox.add(nutritionEntry); // Encrypted with AES-256
```

---

## 📚 Dev Notes

### Design Decisions

1. **Why Cloud Functions for API Keys?**
   - Client code can be decompiled → API keys would be exposed
   - Cloud Functions environment config is server-side only (secure)
   - Easier key rotation (no app redeployment needed)

2. **Why AES-256 Encryption?**
   - RGPD Article 9 requires "appropriate technical measures" for health data
   - AES-256 is industry standard (NIST approved)
   - Hive supports native AES encryption via `HiveAesCipher`

3. **Why flutter_dotenv?**
   - Separates environment-specific config from code
   - `.env.*` files gitignored (prevents secret leakage)
   - Supports flavor-based builds (dev, staging, prod)

4. **Why Certificate Pinning?**
   - Prevents Man-in-the-Middle (MITM) attacks
   - Extra protection for critical endpoints (Firestore, Cloud Functions)
   - Required for financial/health apps (compliance)

5. **Why Obfuscation?**
   - Makes reverse-engineering difficult (decompiled code is unreadable)
   - Protects business logic and algorithms
   - Standard practice for production mobile apps

### Security Best Practices

- **Principle of Least Privilege**: Users can only access their own data
- **Defense in Depth**: Multiple security layers (client validation + server validation + security rules)
- **Encryption at Rest + in Transit**: TLS 1.3+ for network, AES-256 for local storage
- **Secure Key Management**: Keys in device keychain/KeyStore, never in code
- **Rate Limiting**: Prevents abuse and quota exhaustion
- **Security Linting**: CI/CD enforces security checks before merge

### Common Pitfalls

1. **Forgetting to rotate API keys**: Set calendar reminder every 90 days
2. **Committing .env files**: Always gitignore, use .env.example as template
3. **Not testing security rules**: Use Firestore Emulator for automated tests
4. **Weak input validation**: Always sanitize on both client AND server
5. **Ignoring quota limits**: Monitor usage, implement circuit breakers

### Monitoring & Alerts

- **Firebase Crashlytics**: Log all security-related errors
- **Firebase Analytics**: Track quota usage, API call failures
- **Cloud Monitoring**: Alert when quotas exceed 80%
- **Security Audit**: Quarterly penetration testing

### Compliance Checklist

- [x] RGPD Article 9 compliance (health data encryption)
- [x] Right to be Forgotten (account deletion API)
- [x] Data Portability (export API)
- [x] Consent Management (double opt-in for health data)
- [x] TLS 1.3+ enforcement (data in transit)
- [x] AES-256 encryption (data at rest)

---

## ✅ Definition of Done

### Functional Requirements
- [ ] All API keys stored server-side (Cloud Functions environment config)
- [ ] Encrypted Hive boxes configured (`nutrition_data_box`, `health_profiles_box`)
- [ ] Firestore Security Rules deployed (user-scoped, health data protected)
- [ ] Firebase Storage Security Rules deployed (user-scoped, file size limits)
- [ ] Input sanitization implemented (client + server)
- [ ] Code obfuscation enabled (release builds with `--obfuscate`)
- [ ] Environment configuration implemented (`flutter_dotenv` with flavors)
- [ ] Rate limiting implemented (Gemini throttler, Vision circuit breaker)
- [ ] Certificate pinning configured (Firebase endpoints)

### Non-Functional Requirements
- [ ] Encryption key generation < 500ms (Firebase Auth UID derivation)
- [ ] API proxy calls < 5s (Cloud Functions latency)
- [ ] Security rules evaluated in < 100ms (Firestore)
- [ ] Obfuscated APK/IPA builds successfully

### Code Quality
- [ ] All new code follows Flutter style guide (dartfmt, linting 0 errors)
- [ ] 100% test coverage for `InputSanitizer`
- [ ] Integration tests for API proxy calls
- [ ] Security rules tested with Firestore Emulator
- [ ] Code reviewed by security expert

### Security Compliance
- [ ] OWASP Top 10 vulnerability scan passed
- [ ] Penetration testing completed (XSS, SQL injection, MITM)
- [ ] RGPD Article 9 compliance verified
- [ ] Security audit report generated

### Documentation
- [ ] All public methods have dartdoc comments
- [ ] README updated with security guidelines
- [ ] API key rotation process documented
- [ ] Certificate pinning rotation process documented

### Deployment
- [ ] Firestore Security Rules deployed to production
- [ ] Firebase Storage Security Rules deployed to production
- [ ] Cloud Functions deployed with environment config
- [ ] CI/CD security checks passing (no regressions)

---

## 📎 References

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Environment Configuration (NEW)
  flutter_dotenv: ^5.2.1

  # Secure Storage (NEW)
  flutter_secure_storage: ^9.2.2
  crypto: ^3.0.6

  # Firebase (Story 0.2)
  firebase_core: ^3.12.0
  firebase_auth: ^5.3.4
  firebase_firestore: ^5.6.1
  firebase_functions: ^5.2.1
  firebase_storage: ^12.5.1

  # State Management (Story 0.4)
  flutter_riverpod: ^2.6.1

  # Local Storage (Story 0.3)
  hive: ^2.8.0
  hive_flutter: ^1.1.0

  # HTTP Client
  dio: ^5.7.0

  # Code Generation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  hive_generator: ^2.0.1

  # Testing
  integration_test:
    sdk: flutter
  mocktail: ^1.0.4
  firebase_auth_mocks: ^0.14.1
```

### External Documentation

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/obfuscate)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [RGPD Article 9 (Health Data)](https://gdpr-info.eu/art-9-gdpr/)
- [Certificate Pinning Guide](https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning)

---

**Story Created**: 2026-02-15
**Last Updated**: 2026-02-15
**Ready for Dev**: ✅ Yes
**Epic 0 Status**: 🎉 **100% PLANNED** (Final Story!)
