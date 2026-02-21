# Security Best Practices

**Story 0.10 - Phase 9: CI/CD Security Checks**

This document outlines security best practices for the FrigoFute V2 project. All developers must follow these guidelines to ensure production-ready security.

---

## 🔐 Table of Contents

1. [Secrets Management](#secrets-management)
2. [Dependency Security](#dependency-security)
3. [Code Security](#code-security)
4. [Firebase Security](#firebase-security)
5. [Build Security](#build-security)
6. [CI/CD Security](#cicd-security)
7. [Testing Security](#testing-security)
8. [Pre-Commit Checklist](#pre-commit-checklist)

---

## 1. Secrets Management

### ❌ NEVER Do This

```dart
// ❌ BAD: Hardcoded API key
const String API_KEY = "AIzaSyC1234567890abcdefghijklmno";

// ❌ BAD: Hardcoded credentials
const Map<String, String> config = {
  'apiKey': 'secret123',
  'password': 'admin123',
  'token': 'Bearer xyz',
};

// ❌ BAD: Hardcoded Firebase config
final firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyC1234567890abcdefghijklmno",
  authDomain: "myapp.firebaseapp.com",
  // ...
);
```

### ✅ DO This Instead

```dart
// ✅ GOOD: Use environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiKey = dotenv.env['GEMINI_API_KEY'];

// ✅ GOOD: Use Firebase Remote Config
final remoteConfig = FirebaseRemoteConfig.instance;
final featureFlag = remoteConfig.getBool('enable_premium_feature');

// ✅ GOOD: Use firebase_options.dart (from flutterfire configure)
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Environment Variables Setup

1. **Create `.env.example` (commit to git)**:
```bash
# .env.example - Template for environment variables
# Copy this to .env.dev, .env.staging, .env.prod

# Gemini AI API
GEMINI_API_KEY=your_key_here

# Firebase Project ID
FIREBASE_PROJECT_ID=your_project_id

# Enable analytics (true/false)
ENABLE_ANALYTICS=false
```

2. **Create actual `.env` files (DON'T commit)**:
```bash
# .env.dev
GEMINI_API_KEY=AIzaSy_dev_key_123
FIREBASE_PROJECT_ID=frigofute-dev
ENABLE_ANALYTICS=false

# .env.prod
GEMINI_API_KEY=AIzaSy_prod_key_456
FIREBASE_PROJECT_ID=frigofute-prod
ENABLE_ANALYTICS=true
```

3. **Add to `.gitignore`**:
```gitignore
# Environment variables
.env
.env.*
!.env.example
```

4. **Load in `main.dart`**:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env.dev'); // or .env.prod
  runApp(MyApp());
}
```

---

## 2. Dependency Security

### OWASP Dependency Audit

Run regularly to check for known vulnerabilities:

```bash
# Check for vulnerabilities
flutter pub audit

# Update dependencies
flutter pub upgrade --major-versions

# Check outdated packages
flutter pub outdated
```

### Dependency Selection Guidelines

1. **Prefer well-maintained packages**:
   - Check GitHub stars (>1000)
   - Check pub.dev popularity (>90%)
   - Check last update (<6 months)
   - Check issue response time

2. **Avoid deprecated packages**:
   ```bash
   flutter pub outdated
   ```

3. **Pin major versions** in `pubspec.yaml`:
   ```yaml
   dependencies:
     # ✅ GOOD: Pin major version
     firebase_core: ^3.0.0

     # ❌ BAD: Unpinned (risky)
     some_package: any
   ```

4. **Review licenses**:
   - MIT, BSD, Apache 2.0: ✅ OK
   - GPL, AGPL: ⚠️ Copyleft (check compatibility)
   - Commercial: ⚠️ May have restrictions

---

## 3. Code Security

### Input Validation

**ALWAYS sanitize user input** (see `lib/core/validation/input_sanitizer.dart`):

```dart
import 'package:frigofute_v2/core/validation/input_sanitizer.dart';

// ✅ GOOD: Sanitize before use
final sanitizedName = InputSanitizer.sanitizeProductName(nameController.text);
if (sanitizedName.isEmpty) {
  return 'Product name cannot be empty';
}

// ✅ GOOD: Validate format
if (!InputSanitizer.isValidEmail(emailController.text)) {
  return 'Invalid email format';
}

// ✅ GOOD: Validate barcode
final barcode = InputSanitizer.sanitizeEAN13(barcodeController.text);
if (barcode == null) {
  return 'Invalid barcode format (must be 13 digits)';
}
```

### XSS Prevention

```dart
// ❌ BAD: Rendering unsanitized HTML
Text(userInput) // Could contain <script>alert('XSS')</script>

// ✅ GOOD: Sanitize first
final safeText = InputSanitizer.sanitizeProductName(userInput);
Text(safeText)

// ✅ GOOD: Strip HTML tags
final plainText = InputSanitizer.stripHtmlTags(htmlInput);
```

### SQL Injection Prevention

While Firestore (NoSQL) is not vulnerable to SQL injection, **defense-in-depth** is important:

```dart
// ✅ GOOD: Firestore automatically escapes queries
await FirebaseFirestore.instance
  .collection('products')
  .where('name', isEqualTo: userInput) // Safe
  .get();

// ✅ GOOD: Still sanitize for XSS prevention
final sanitizedInput = InputSanitizer.sanitizeGenericInput(userInput);
```

### Secure HTTP

```dart
// ❌ BAD: Insecure HTTP
final response = await http.get(Uri.parse('http://api.example.com/data'));

// ✅ GOOD: Always use HTTPS
final response = await http.get(Uri.parse('https://api.example.com/data'));

// ✅ GOOD: Validate URL scheme
final url = InputSanitizer.sanitizeUrl(userProvidedUrl);
if (url == null) {
  throw Exception('Invalid URL (must be https://)');
}
```

### Debug Statements

```dart
// ❌ BAD: Prints sensitive data
print('User password: $password');
print('API key: $apiKey');

// ✅ GOOD: Use logger with levels
import 'package:logger/logger.dart';

final logger = Logger();
logger.d('User logged in'); // Debug only
logger.i('Request sent to API'); // Info

// ✅ GOOD: Conditional debug
if (kDebugMode) {
  print('Debug info: $data');
}
```

---

## 4. Firebase Security

### Firestore Security Rules

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

    // User data (user-scoped)
    match /users/{userId}/inventory/{itemId} {
      allow read, write: if isOwner(userId);
    }

    // Health data (requires consent)
    match /users/{userId}/nutrition_tracking/{entryId} {
      allow read, write: if isOwner(userId) && hasHealthConsent();
    }

    // Quota tracking (read-only for users)
    match /users/{userId}/quota/{apiName} {
      allow read: if isOwner(userId);
      allow write: if false; // Only Cloud Functions
    }

    // Fail-secure: deny all undeclared paths
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Storage Security Rules

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

    function isValidImageSize() {
      return request.resource.size <= 10 * 1024 * 1024; // 10MB
    }

    function isValidImageType() {
      return request.resource.contentType.matches('image/.*');
    }

    // Profile pictures (public read)
    match /users/{userId}/profile_picture {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId) && isValidImageSize() && isValidImageType();
    }

    // Meal photos (requires health consent)
    match /users/{userId}/meal_photos/{photoId} {
      allow read, write: if isOwner(userId)
                         && request.auth.token.health_data_consent == true
                         && isValidImageSize()
                         && isValidImageType();
    }

    // Fail-secure: deny all undeclared paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Deploy Security Rules

```bash
# Dry run (test syntax)
firebase deploy --only firestore:rules,storage --dry-run

# Deploy to staging first
firebase use staging
firebase deploy --only firestore:rules,storage

# Deploy to production (after testing)
firebase use production
firebase deploy --only firestore:rules,storage
```

---

## 5. Build Security

### Code Obfuscation (Release Builds)

**ALWAYS obfuscate release builds** to prevent reverse engineering:

```bash
# Android APK (obfuscated)
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# Android App Bundle (obfuscated)
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# iOS IPA (obfuscated)
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/ios/symbols
```

### ProGuard Configuration (Android)

**File**: `android/app/proguard-rules.pro`

```proguard
# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Firestore models
-keep class * extends com.google.firebase.firestore.DocumentReference { *; }

# Keep Hive models
-keep class * extends hive.** { *; }

# Keep JSON serialization
-keepattributes *Annotation*
-keepclassmembers class ** {
  @com.google.gson.annotations.SerializedName <fields>;
}
```

### Upload Debug Symbols to Crashlytics

```bash
# Android
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# Upload symbols to Firebase Crashlytics
firebase crashlytics:symbols:upload \
  --app=<your-app-id> \
  build/app/outputs/symbols
```

---

## 6. CI/CD Security

### GitHub Actions Secrets

**Configure in GitHub Repository Settings > Secrets**:

```yaml
# Required secrets
CODECOV_TOKEN          # For coverage reports
FIREBASE_TOKEN         # For Firebase deployments
GOOGLE_SERVICES_JSON   # Android Firebase config
GOOGLE_SERVICES_PLIST  # iOS Firebase config
ANDROID_KEYSTORE       # Android signing key
ANDROID_KEY_PASSWORD   # Keystore password
IOS_CERTIFICATE        # iOS signing certificate
```

### Security Checks Workflow

**File**: `.github/workflows/security_checks.yml`

Runs automatically on every PR:
- ✅ Hardcoded secrets detection
- ✅ OWASP dependency audit
- ✅ Firestore/Storage rules validation
- ✅ Code coverage check (≥75%)
- ✅ License compliance

### Manual Security Audit

```bash
# Run locally before committing
flutter analyze --fatal-infos
flutter pub audit
flutter test --coverage
```

---

## 7. Testing Security

### Security Test Examples

**File**: `test/security/input_sanitizer_test.dart`

```dart
group('XSS Attack Prevention', () {
  test('should block script tags', () {
    final input = '<script>alert("XSS")</script>Product';
    final sanitized = InputSanitizer.sanitizeProductName(input);
    expect(sanitized, equals('Product'));
  });

  test('should block JavaScript URLs', () {
    final input = 'javascript:alert("XSS")';
    final sanitized = InputSanitizer.sanitizeUrl(input);
    expect(sanitized, isNull);
  });
});

group('SQL Injection Prevention', () {
  test('should remove dangerous characters', () {
    final input = "' OR '1'='1";
    final sanitized = InputSanitizer.sanitizeGenericInput(input);
    expect(sanitized, equals('OR 11'));
  });
});
```

### Firestore Rules Testing

```dart
// Use Firebase Emulator for security rules testing
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  setUpAll(() async {
    // Connect to Firestore Emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  });

  test('users cannot access other users data', () async {
    // Test user isolation
  });

  test('health data requires consent', () async {
    // Test custom claims validation
  });
}
```

---

## 8. Pre-Commit Checklist

Before committing code, verify:

### Code Quality
- [ ] `flutter analyze` passes with 0 errors/warnings
- [ ] `flutter test` passes with ≥75% coverage
- [ ] `flutter format lib/ test/` applied

### Security
- [ ] No hardcoded API keys or secrets
- [ ] No `print()` statements with sensitive data
- [ ] All user inputs sanitized with `InputSanitizer`
- [ ] HTTPS used for all external API calls
- [ ] `.env` files not committed (in `.gitignore`)
- [ ] No Firebase credentials in code

### Dependencies
- [ ] `flutter pub audit` passes (no critical vulnerabilities)
- [ ] All dependencies up-to-date
- [ ] Licenses reviewed (no GPL/AGPL conflicts)

### Documentation
- [ ] Public methods documented with dartdoc
- [ ] Security-sensitive code has comments
- [ ] README updated if API changes

---

## 🚨 Security Incident Response

If you discover a security vulnerability:

1. **DO NOT commit the fix directly**
2. **DO NOT create a public GitHub issue**
3. **DO** notify the security team immediately
4. **DO** create a private security advisory on GitHub
5. **DO** rotate any exposed credentials immediately

---

## 📚 Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/best-practices)
- [Flutter Security Guidelines](https://docs.flutter.dev/security)
- [Dart Security](https://dart.dev/guides/language/effective-dart/usage#do-use-strings-in-part-of-directives)

---

## ✅ Security Compliance Status

| Requirement | Status | Evidence |
|------------|--------|----------|
| API Keys Protected | ✅ Complete | `.env` + `flutter_dotenv` |
| Encryption at Rest | ✅ Complete | AES-256 via Hive |
| Encryption in Transit | ✅ Complete | TLS 1.3+ (Firebase) |
| Firestore Security Rules | ✅ Complete | `firestore.rules` deployed |
| Storage Security Rules | ✅ Complete | `storage.rules` deployed |
| Input Sanitization | ✅ Complete | `InputSanitizer` class |
| Rate Limiting | ✅ Complete | `GeminiThrottler`, `VisionCircuitBreaker` |
| Code Obfuscation | 🟡 Documented | Build scripts ready |
| CI/CD Security Checks | ✅ Complete | `security_checks.yml` |
| OWASP Dependency Audit | ✅ Complete | `flutter pub audit` in CI |
| Code Coverage ≥75% | ✅ Complete | Coverage gate in CI |

---

**Last Updated**: 2026-02-15
**Story**: 0.10 - Configure Security Foundation and API Keys Management
**Phase**: 9 - CI/CD Security Checks
