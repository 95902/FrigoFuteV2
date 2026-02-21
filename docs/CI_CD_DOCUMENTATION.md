# CI/CD Pipeline Documentation - FrigoFuteV2

## 📋 Overview

This document describes the complete CI/CD pipeline setup for FrigoFuteV2, including GitHub Actions workflows, build flavors, quality gates, and deployment processes.

## 🔧 Workflows Setup

### 1. PR Quality Gates (`.github/workflows/pr_checks.yml`)

**Trigger:** Pull requests to `main` or `develop` branches

**Jobs:**
- ✅ **quality-checks**: Linting, Testing, Coverage verification
  - Dart format check
  - Flutter analyze (fails on warnings)
  - Flutter test with coverage
  - Coverage threshold check (≥75%)
  - Upload to Codecov

- ✅ **build-verification**: Build verification for both platforms
  - Flutter build APK (dev, debug)
  - Flutter build iOS (dev, debug, no-codesign)

**Status:** ✅ Configured and ready
**Manual Steps Required:** None (runs automatically on PRs)

### 2. Staging Deploy (`.github/workflows/staging_deploy.yml`)

**Trigger:** Push to `develop` branch

**Jobs:**
- ✅ **build-and-deploy-android**: Build and distribute Android staging
  - Build APK (staging, release)
  - Upload to Firebase App Distribution
  - Notify beta-testers group

- ✅ **build-and-deploy-ios**: Build and distribute iOS staging
  - Build IPA (staging, release)
  - Upload to Firebase App Distribution
  - Notify beta-testers group

**Status:** ✅ Configured
**Manual Steps Required:**
- Create Firebase staging project
- Configure GitHub Secrets (see GITHUB_SECRETS_SETUP.md)
- Add beta-testers group in Firebase App Distribution

### 3. Production Deploy (`.github/workflows/production_deploy.yml`)

**Trigger:** Push tag matching `v*.*.*` (e.g., v1.0.0)

**Jobs:**
- ✅ **deploy-android**: Deploy to Google Play Store
  - Build AAB (prod, release, obfuscated)
  - Upload to Play Store (5% staged rollout)
  - Upload ProGuard mapping to Crashlytics
  - Upload debug symbols to Sentry

- ✅ **deploy-ios**: Deploy to Apple App Store
  - Build IPA (prod, release, obfuscated)
  - Upload to App Store (phased release)
  - Upload debug symbols to Sentry

- ✅ **create-github-release**: Create GitHub Release
  - Generate release notes
  - Document rollout plan
  - Include monitoring instructions

**Status:** ✅ Configured
**Manual Steps Required:**
- Create Firebase prod project
- Configure all GitHub Secrets
- Generate Android keystore
- Configure Apple certificates
- Test rollout process

## 📱 Build Flavors

### Android Configuration

**File:** `android/app/build.gradle.kts`

**Flavors:**
| Flavor | App ID | Display Name | Purpose |
|--------|--------|--------------|---------|
| dev | com.frigofute.frigofute_v2.dev | FrigoFute DEV | Local development |
| staging | com.frigofute.frigofute_v2.staging | FrigoFute STAGING | Beta testing |
| prod | com.frigofute.frigofute_v2 | FrigoFute | Production |

**Build Commands:**
```bash
# Dev
flutter build apk --flavor dev --debug

# Staging
flutter build apk --flavor staging --release

# Prod (with obfuscation)
flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/symbols/android
```

**Status:** ✅ Configured
**Limitation:** Using temporary google-services.json files (see android/FIREBASE_SETUP.md)

### iOS Configuration

**Status:** ⚠️ Documented, requires macOS
**Documentation:** ios/FIREBASE_SETUP.md

**Requirements:**
- Xcode 15+ on macOS
- Create 3 schemes (dev, staging, prod)
- Configure Bundle IDs
- Set up provisioning profiles
- Configure GoogleService-Info.plist per flavor

## 🎯 Quality Gates

### Coverage Threshold: ≥75%

**Current Status:** ⚠️ 14.12% (needs improvement)

**Verification Script:** `tool/check_coverage.dart`
```bash
flutter test --coverage
dart run tool/check_coverage.dart coverage/lcov.info 75
```

**Tests Created (67 tests):**
- Core Auth Providers (16 tests)
- Core Routing AppRoutes (26 tests)
- Core Routing RouteGuards (4 tests)
- Core Feature Flags Config (21 tests)

**Gap Analysis:**
- ❌ Core Storage tests (missing)
- ❌ Core Data Sync tests (missing)
- ❌ Feature integration tests (missing)
- ❌ Widget tests (limited)

**Action Plan to Reach 75%:**
1. Add storage tests (Hive, TypeAdapters) → +15%
2. Add data sync tests → +10%
3. Add feature provider tests → +20%
4. Add widget/integration tests → +20%

### Linting: 0 Errors

**Configuration:** `analysis_options.yaml` (from Story 0.1)
**Verification:** `flutter analyze --no-pub`
**Status:** ✅ Passing

## 📦 Firebase Setup

### Projects Required

| Environment | Project ID | Purpose |
|-------------|-----------|---------|
| Dev | frigofute-dev | Local development (exists) |
| Staging | frigofute-staging | Beta testing (**manual setup required**) |
| Prod | frigofute-prod | Production (**manual setup required**) |

### Services to Enable

For **each** Firebase project:
- ✅ Authentication (Email/Password, Google, Apple)
- ✅ Firestore Database
- ✅ Cloud Storage
- ✅ Crashlytics
- ✅ Performance Monitoring
- ✅ Remote Config
- ⚠️ App Distribution (staging only)

### Configuration Files

**Android:**
```
android/app/src/
├── dev/google-services.json          (⚠️ temporary placeholder)
├── staging/google-services.json      (⚠️ temporary placeholder)
└── prod/google-services.json         (⚠️ temporary placeholder)
```

**iOS:**
```
ios/Runner/
├── GoogleService-Info-dev.plist      (❌ needs creation)
├── GoogleService-Info-staging.plist  (❌ needs creation)
└── GoogleService-Info-prod.plist     (❌ needs creation)
```

**See:** `android/FIREBASE_SETUP.md` and `ios/FIREBASE_SETUP.md` for complete setup instructions.

## 🔐 GitHub Secrets

**Total Secrets Required:** 19

**Status:** ❌ All secrets need to be configured manually

**Categories:**
- Firebase (6 secrets)
- Android Play Store (5 secrets)
- iOS App Store (6 secrets)
- Monitoring (2 secrets - optional)

**See:** `docs/GITHUB_SECRETS_SETUP.md` for complete guide with generation instructions.

## 🚀 Deployment Process

### Staging Deployment

**Trigger:** Push to `develop` branch

**Process:**
1. Merge PR to develop
2. Workflow builds staging APK/IPA
3. Uploads to Firebase App Distribution
4. Beta-testers receive notification
5. Test in staging environment

**Manual Steps:**
- Create Firebase staging project
- Add beta-testers group
- Configure GitHub secrets

### Production Deployment

**Trigger:** Create and push tag (e.g., `v1.0.0`)

**Process:**
```bash
# 1. Create tag
git tag v1.0.0
git push origin v1.0.0

# 2. Workflow executes:
#    - Builds AAB/IPA with obfuscation
#    - Uploads to Play Store (5% rollout)
#    - Uploads to App Store (phased release)
#    - Creates GitHub Release

# 3. Monitor (Phase 1: 0-24h)
#    - Check Crashlytics (crash rate < 0.5%)
#    - Check Firebase Performance
#    - Verify user feedback

# 4. Promote to 25% (manual, after 24h)
gcloud alpha app instances rollout set \
  --rollout-percentage 25 \
  --app com.frigofute.frigofute_v2

# 5. Monitor (Phase 2: 24-48h)
#    - Continue monitoring metrics

# 6. Promote to 100% (manual, after 48h)
gcloud alpha app instances rollout set \
  --rollout-percentage 100 \
  --app com.frigofute.frigofute_v2
```

### Rollback Process

**Automatic Triggers:**
- Crash rate > 0.5% within 2 hours
- ANR rate > 1%

**Manual Rollback:**
```bash
# Android
gcloud alpha app instances rollback \
  --version <previous_version> \
  --app com.frigofute.frigofute_v2

# iOS
# Pause phased release in App Store Connect
# Submit previous version
```

## 📊 Monitoring

### Firebase Crashlytics
- Crash rate alerts (> 0.5%)
- ANR rate alerts (> 1%)
- Stack traces with device info

### Firebase Performance
- App start time (target < 3s)
- Screen rendering (60 fps)
- Network latency

### Sentry (Optional)
- Debug symbols upload
- Release tracking
- Error monitoring

## ✅ Checklist - Story 0.6 Status

### Infrastructure
- [x] GitHub Actions workflows created (3 files)
- [x] Build flavors Android configured
- [x] Build flavors iOS documented
- [x] Coverage check script created
- [x] Export options iOS created

### Documentation
- [x] CI/CD Documentation (this file)
- [x] Firebase Setup Android guide
- [x] Firebase Setup iOS guide
- [x] GitHub Secrets Setup guide

### Testing
- [x] Test structure created
- [x] 67 tests passing
- [ ] ⚠️ Coverage ≥75% (currently 14.12%)

### Manual Setup Required
- [ ] Create Firebase staging project
- [ ] Create Firebase prod project
- [ ] Configure all GitHub Secrets (19)
- [ ] Create Android keystore
- [ ] Configure iOS schemes (macOS required)
- [ ] Configure Apple certificates
- [ ] Test staging deployment
- [ ] Test production deployment

## 📚 Next Steps

### Immediate (before first deployment)
1. Create Firebase staging project
2. Configure critical GitHub Secrets:
   - FIREBASE_SERVICE_KEY_STAGING
   - FIREBASE_ANDROID_APP_ID_STAGING
   - FIREBASE_IOS_APP_ID_STAGING
3. Test staging deploy workflow

### Short-term (before production release)
1. Increase test coverage to ≥75%
2. Create Firebase prod project
3. Generate Android keystore (store backup securely!)
4. Configure all production secrets
5. Complete iOS setup (requires macOS)

### Long-term
1. Optimize coverage (aim for 80%+)
2. Add integration tests
3. Set up monitoring dashboards
4. Document rollout procedures
5. Train team on deployment process

## 🐛 Known Issues & Limitations

### Coverage Gap
- **Current:** 14.12%
- **Target:** 75%
- **Plan:** See "Action Plan to Reach 75%" above
- **Blocker:** No - CI will fail PRs but development can continue

### iOS Configuration
- **Issue:** Requires macOS to complete
- **Workaround:** Documentation provided, placeholder files created
- **Blocker:** Yes - for iOS builds

### Temporary Firebase Configs
- **Issue:** Using modified google-services.json with wrong package names
- **Risk:** Low (dev/staging only)
- **Resolution:** Replace with real configs from Firebase Console

## 📞 Support

**Issues with CI/CD?**
1. Check workflow logs in GitHub Actions
2. Verify secrets are configured correctly
3. Review Firebase project settings
4. Check Android/iOS setup guides

**Coverage not improving?**
1. Run `flutter test --coverage`
2. Generate HTML report: `genhtml coverage/lcov.info -o coverage/html`
3. Open `coverage/html/index.html` to see uncovered lines
4. Add tests for uncovered code

**Deployment failing?**
1. Check GitHub Secrets are all configured
2. Verify Firebase projects exist
3. Check keystore/certificates are valid
4. Review workflow logs for specific errors
