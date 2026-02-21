# Deployment Checklist

**Story 0.10 - Security Foundation**
**Last Updated**: 2026-02-15

This checklist ensures all security components are properly configured before deploying to production.

---

## 📋 Pre-Deployment Checklist

### 1. Environment Setup

#### Firebase Project Configuration

- [ ] **Create Firebase projects**:
  - [ ] Development: `frigofute-dev`
  - [ ] Staging: `frigofute-staging`
  - [ ] Production: `frigofute-prod`

- [ ] **Enable Firebase services** (all environments):
  - [ ] Authentication (Email/Password, Google, Apple)
  - [ ] Firestore Database
  - [ ] Firebase Storage
  - [ ] Remote Config
  - [ ] Crashlytics
  - [ ] Analytics
  - [ ] Performance Monitoring

- [ ] **Configure Firebase quotas**:
  - [ ] Firestore: 50K reads/day (free tier)
  - [ ] Storage: 1GB storage, 10MB/day downloads (free tier)
  - [ ] Remote Config: Unlimited fetches

#### Environment Variables

- [ ] **Create .env files** (DO NOT commit):
  ```bash
  # .env.dev
  FIREBASE_PROJECT_ID=frigofute-dev
  ENABLE_ANALYTICS=false
  ENABLE_CRASHLYTICS=false

  # .env.staging
  FIREBASE_PROJECT_ID=frigofute-staging
  ENABLE_ANALYTICS=true
  ENABLE_CRASHLYTICS=true

  # .env.prod
  FIREBASE_PROJECT_ID=frigofute-prod
  ENABLE_ANALYTICS=true
  ENABLE_CRASHLYTICS=true
  ```

- [ ] **Verify .env in .gitignore**:
  ```gitignore
  .env
  .env.*
  !.env.example
  ```

- [ ] **Verify .env.example exists** and is up-to-date

#### Firebase Configuration Files

- [ ] **Generate Firebase config**:
  ```bash
  # Install FlutterFire CLI
  dart pub global activate flutterfire_cli

  # Configure Firebase (creates firebase_options.dart)
  flutterfire configure --project=frigofute-dev
  flutterfire configure --project=frigofute-staging
  flutterfire configure --project=frigofute-prod
  ```

- [ ] **Verify firebase_options.dart** created
- [ ] **Verify google-services.json** (Android) created
- [ ] **Verify GoogleService-Info.plist** (iOS) created

---

### 2. Security Rules Deployment

#### Firestore Security Rules

- [ ] **Review firestore.rules**:
  - [ ] User data isolation (`users/{userId}/...`)
  - [ ] Custom claims validation (`health_data_consent`)
  - [ ] Version-based conflict detection
  - [ ] XSS prevention (`validProductName()`)
  - [ ] Fail-secure deny-all (undeclared paths)

- [ ] **Test rules locally**:
  ```bash
  # Start Firestore Emulator
  firebase emulators:start --only firestore

  # Run tests (if implemented)
  flutter test test/firestore_rules_test.dart
  ```

- [ ] **Validate syntax**:
  ```bash
  firebase deploy --only firestore:rules --dry-run
  ```

- [ ] **Deploy to staging**:
  ```bash
  firebase use staging
  firebase deploy --only firestore:rules
  ```

- [ ] **Test on staging** (manual verification)

- [ ] **Deploy to production**:
  ```bash
  firebase use production
  firebase deploy --only firestore:rules
  ```

#### Firebase Storage Security Rules

- [ ] **Review storage.rules**:
  - [ ] File size limits (10MB max)
  - [ ] File type validation (images only)
  - [ ] Health consent requirement (meal photos)
  - [ ] Fail-secure deny-all (undeclared paths)

- [ ] **Test rules locally**:
  ```bash
  firebase emulators:start --only storage
  ```

- [ ] **Validate syntax**:
  ```bash
  firebase deploy --only storage --dry-run
  ```

- [ ] **Deploy to staging**:
  ```bash
  firebase use staging
  firebase deploy --only storage
  ```

- [ ] **Test on staging** (upload image, verify limits)

- [ ] **Deploy to production**:
  ```bash
  firebase use production
  firebase deploy --only storage
  ```

#### Firestore Indexes

- [ ] **Review firestore.indexes.json**
- [ ] **Deploy indexes**:
  ```bash
  firebase deploy --only firestore:indexes
  ```

---

### 3. Code Quality & Security

#### Static Analysis

- [ ] **Run flutter analyze**:
  ```bash
  flutter analyze --fatal-infos --fatal-warnings
  ```
  - [ ] 0 errors
  - [ ] 0 warnings
  - [ ] 0 infos (strict mode)

#### Security Checks

- [ ] **Run local security audit**:
  ```bash
  ./scripts/security_check.sh
  # or on Windows:
  scripts\security_check.bat
  ```

- [ ] **Verify no hardcoded secrets**:
  - [ ] No API_KEY in code
  - [ ] No SECRET in code
  - [ ] No password in code
  - [ ] No Firebase credentials in code

- [ ] **Verify HTTPS usage**:
  - [ ] No http:// URLs (except localhost)
  - [ ] All external APIs use https://

- [ ] **Verify .env files not committed**:
  ```bash
  git ls-files | grep -E "\.env$|\.env\.(dev|staging|prod)$"
  # Should return no results
  ```

#### Dependency Security

- [ ] **Run OWASP audit**:
  ```bash
  flutter pub audit
  ```
  - [ ] No critical vulnerabilities
  - [ ] No high vulnerabilities
  - [ ] Review medium/low vulnerabilities

- [ ] **Update dependencies** (if needed):
  ```bash
  flutter pub upgrade --major-versions
  flutter pub audit
  ```

#### Testing

- [ ] **Run all tests**:
  ```bash
  flutter test
  ```
  - [ ] All tests passing
  - [ ] No test failures
  - [ ] No test errors

- [ ] **Check code coverage**:
  ```bash
  flutter test --coverage
  lcov --summary coverage/lcov.info
  ```
  - [ ] Coverage ≥ 75%
  - [ ] Critical paths covered

---

### 4. Build Configuration

#### Android Build

- [ ] **Configure build.gradle**:
  - [ ] minSdkVersion: 21 (Android 5.0)
  - [ ] targetSdkVersion: 34 (Android 14)
  - [ ] compileSdkVersion: 34

- [ ] **Configure ProGuard** (android/app/proguard-rules.pro):
  ```proguard
  # Keep Firebase classes
  -keep class com.google.firebase.** { *; }
  -keep class com.google.android.gms.** { *; }

  # Keep Hive models
  -keep class * extends hive.** { *; }
  ```

- [ ] **Generate signing key**:
  ```bash
  keytool -genkey -v -keystore upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias upload
  ```

- [ ] **Configure key.properties** (DO NOT commit):
  ```properties
  storePassword=<password>
  keyPassword=<password>
  keyAlias=upload
  storeFile=../upload-keystore.jks
  ```

- [ ] **Build release APK**:
  ```bash
  flutter build apk --release \
    --flavor prod \
    --obfuscate \
    --split-debug-info=build/app/outputs/symbols
  ```

- [ ] **Build release App Bundle**:
  ```bash
  flutter build appbundle --release \
    --flavor prod \
    --obfuscate \
    --split-debug-info=build/app/outputs/symbols
  ```

#### iOS Build

- [ ] **Configure Info.plist**:
  - [ ] Minimum iOS version: 12.0
  - [ ] Privacy descriptions (camera, photo library, etc.)
  - [ ] App Transport Security (HTTPS only)

- [ ] **Configure signing**:
  - [ ] Apple Developer account
  - [ ] Provisioning profile (production)
  - [ ] Distribution certificate

- [ ] **Build release IPA**:
  ```bash
  flutter build ipa --release \
    --flavor prod \
    --obfuscate \
    --split-debug-info=build/ios/symbols
  ```

---

### 5. CI/CD Pipeline

#### GitHub Actions Configuration

- [ ] **Verify workflows exist**:
  - [ ] `.github/workflows/security_checks.yml`
  - [ ] `.github/workflows/pr_checks.yml`
  - [ ] `.github/workflows/production_deploy.yml`
  - [ ] `.github/workflows/staging_deploy.yml`

- [ ] **Configure GitHub secrets**:
  - [ ] `FIREBASE_TOKEN` (for deployments)
  - [ ] `CODECOV_TOKEN` (for coverage reports)
  - [ ] `GOOGLE_SERVICES_JSON` (Android)
  - [ ] `GOOGLE_SERVICES_PLIST` (iOS)
  - [ ] `ANDROID_KEYSTORE` (base64 encoded)
  - [ ] `ANDROID_KEY_PASSWORD`
  - [ ] `IOS_CERTIFICATE` (base64 encoded)

- [ ] **Test CI/CD locally** (with act):
  ```bash
  # Install act
  brew install act  # macOS
  # or
  curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

  # Run workflow
  act pull_request -W .github/workflows/security_checks.yml
  ```

- [ ] **Verify all checks pass**:
  - [ ] security-audit job
  - [ ] coverage-check job
  - [ ] license-check job
  - [ ] quality-checks job
  - [ ] build-verification job

---

### 6. Monitoring & Observability

#### Firebase Crashlytics

- [ ] **Verify Crashlytics enabled** in Firebase Console

- [ ] **Upload debug symbols**:
  ```bash
  firebase crashlytics:symbols:upload \
    --app=<your-app-id> \
    build/app/outputs/symbols
  ```

- [ ] **Test crash reporting**:
  ```dart
  // Force a test crash
  FirebaseCrashlytics.instance.crash();
  ```

- [ ] **Verify crash appears** in Firebase Console

#### Firebase Analytics

- [ ] **Verify Analytics enabled** in Firebase Console

- [ ] **Test event logging**:
  ```dart
  FirebaseAnalytics.instance.logEvent(
    name: 'test_deployment',
    parameters: {'environment': 'production'},
  );
  ```

- [ ] **Verify event appears** in Firebase Console (24h delay)

#### Performance Monitoring

- [ ] **Verify Performance Monitoring enabled** in Firebase Console

- [ ] **Test trace logging**:
  ```dart
  final trace = FirebasePerformance.instance.newTrace('test_trace');
  await trace.start();
  // ... perform work ...
  await trace.stop();
  ```

- [ ] **Verify trace appears** in Firebase Console

---

### 7. Data Migration & Backup

#### Existing Data (if applicable)

- [ ] **Backup existing data**:
  ```bash
  # Export Firestore data
  gcloud firestore export gs://<bucket-name>/backups/$(date +%Y%m%d)
  ```

- [ ] **Migrate encryption**:
  - [ ] Delete old unencrypted boxes
  - [ ] Regenerate encryption keys
  - [ ] Re-encrypt health data

- [ ] **Test data migration** on staging first

#### Security Rules Migration

- [ ] **Backup existing rules**:
  ```bash
  firebase firestore:rules:get > firestore.rules.backup
  firebase storage:rules:get > storage.rules.backup
  ```

- [ ] **Deploy new rules** (see section 2)

- [ ] **Verify data access** after deployment

---

### 8. Post-Deployment Verification

#### Functional Testing

- [ ] **User Registration**:
  - [ ] Email/password sign-up works
  - [ ] Google sign-in works
  - [ ] Apple sign-in works

- [ ] **Data Encryption**:
  - [ ] Health data encrypted at rest (check Hive files)
  - [ ] Encryption keys stored securely (Keychain/KeyStore)

- [ ] **Security Rules**:
  - [ ] Users can only access their own data
  - [ ] Health data requires consent
  - [ ] File uploads respect size/type limits

- [ ] **Rate Limiting**:
  - [ ] Gemini AI throttled (2-second delay)
  - [ ] Quota tracking works
  - [ ] Premium users bypass limits

- [ ] **Input Validation**:
  - [ ] XSS attacks blocked (test with `<script>alert("XSS")</script>`)
  - [ ] Invalid emails rejected
  - [ ] Invalid barcodes rejected

#### Security Verification

- [ ] **HTTPS enforcement**:
  ```bash
  # All API calls should use HTTPS
  grep -rn "http://" lib/ --include="*.dart" |
    grep -v "localhost\|127.0.0.1"
  # Should return no results
  ```

- [ ] **No secrets in code**:
  ```bash
  # No hardcoded API keys
  grep -rn "API_KEY\|SECRET\|password" lib/ --include="*.dart"
  # Should return no results (except comments/constants)
  ```

- [ ] **Security rules active**:
  - [ ] Test unauthorized access (should fail)
  - [ ] Test cross-user access (should fail)
  - [ ] Test file size limits (should fail for >10MB)

#### Performance Testing

- [ ] **App startup time** < 3 seconds
- [ ] **Encryption overhead** < 100ms per operation
- [ ] **API response time** < 2 seconds (p95)
- [ ] **Firestore query time** < 1 second (p95)

#### Monitoring Verification

- [ ] **Crashlytics** receiving crash reports
- [ ] **Analytics** receiving events (24h delay)
- [ ] **Performance Monitoring** receiving traces
- [ ] **Firestore metrics** visible in console
- [ ] **Storage metrics** visible in console

---

### 9. Rollback Plan

In case of deployment issues:

#### Quick Rollback

- [ ] **Document current version**:
  ```bash
  git rev-parse HEAD > deployed_version.txt
  ```

- [ ] **Rollback security rules**:
  ```bash
  firebase firestore:rules:set firestore.rules.backup
  firebase storage:rules:set storage.rules.backup
  ```

- [ ] **Rollback app version**:
  - [ ] Android: Upload previous APK/AAB to Play Console
  - [ ] iOS: Submit previous IPA to App Store Connect

#### Data Recovery

- [ ] **Restore Firestore backup**:
  ```bash
  gcloud firestore import gs://<bucket-name>/backups/<backup-date>
  ```

- [ ] **Restore Storage files** (if needed):
  ```bash
  gsutil -m cp -r gs://<bucket-name>/backups/<backup-date>/* gs://<bucket-name>/
  ```

#### Communication

- [ ] **Notify users** (if downtime occurred)
- [ ] **Update status page** (if applicable)
- [ ] **Post-mortem** (document incident)

---

### 10. Sign-Off

#### Development Team

- [ ] Code review completed
- [ ] All tests passing
- [ ] Security audit passed
- [ ] Documentation complete

#### QA Team

- [ ] Functional testing passed
- [ ] Security testing passed
- [ ] Performance testing passed
- [ ] Regression testing passed

#### Product Owner

- [ ] Acceptance criteria met
- [ ] User stories complete
- [ ] RGPD compliance verified

#### Security Team

- [ ] Security audit passed
- [ ] Penetration testing passed (if applicable)
- [ ] Compliance review passed

---

## 📊 Deployment Checklist Summary

**Total Items**: 150+

**Critical Items** (must pass):
- [ ] All tests passing
- [ ] No hardcoded secrets
- [ ] Security rules deployed
- [ ] Encryption enabled
- [ ] HTTPS enforced
- [ ] CI/CD checks passing

**Pre-Production Items** (recommended):
- [ ] Code coverage ≥75%
- [ ] Dependency audit passed
- [ ] Performance testing passed
- [ ] Staging deployment successful

**Post-Deployment Items** (verify):
- [ ] Monitoring active
- [ ] Crashlytics receiving data
- [ ] Analytics receiving events
- [ ] Security rules enforced

---

## 🚨 Deployment Risks

### High Risk Items

1. **Data Loss**:
   - **Risk**: Encryption migration could lose unencrypted data
   - **Mitigation**: Backup before migration, test on staging first

2. **Security Rules**:
   - **Risk**: Overly restrictive rules could block legitimate access
   - **Mitigation**: Test on staging, gradual rollout

3. **API Quota**:
   - **Risk**: Rate limiting too aggressive could block users
   - **Mitigation**: Monitor quota usage, adjust limits if needed

### Medium Risk Items

1. **Performance**:
   - **Risk**: Encryption overhead could slow down app
   - **Mitigation**: Performance testing, optimization if needed

2. **Compatibility**:
   - **Risk**: New security rules could break older app versions
   - **Mitigation**: Version checks, backward compatibility

3. **Monitoring**:
   - **Risk**: Missing crash reports could hide issues
   - **Mitigation**: Test Crashlytics before production deployment

---

## 📞 Support Contacts

**During Deployment**:
- Development Lead: [Contact]
- DevOps Engineer: [Contact]
- Security Engineer: [Contact]

**Post-Deployment**:
- On-Call Engineer: [Contact]
- Firebase Support: https://firebase.google.com/support

**Emergency Rollback**:
- Incident Commander: [Contact]
- Database Admin: [Contact]

---

## ✅ Final Sign-Off

**Deployment Date**: _______________
**Deployed By**: _______________
**Approved By**: _______________

**Post-Deployment Verification**:
- [ ] All systems operational
- [ ] Monitoring active
- [ ] No critical errors
- [ ] Performance acceptable

**Notes**:
_______________________________________________
_______________________________________________
_______________________________________________

---

**Last Updated**: 2026-02-15
**Version**: 1.0
**Story**: 0.10 - Configure Security Foundation and API Keys Management
