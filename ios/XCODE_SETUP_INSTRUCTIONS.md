# iOS Xcode Setup Instructions

## Story 0.6: Configure iOS Build Flavors

### Prerequisites
- macOS with Xcode installed
- CocoaPods installed: `sudo gem install cocoapods`
- Flutter configured for iOS: `flutter doctor`

---

## Step 1: Open Project in Xcode

```bash
cd ios
open Runner.xcworkspace  # ⚠️ Open .xcworkspace, NOT .xcodeproj
```

---

## Step 2: Create Build Configurations

1. In Xcode, select the **Runner** project (blue icon at top of navigator)
2. Select the **Runner** target
3. Go to **Info** tab
4. Under **Configurations**, click **+** and **Duplicate "Debug" Configuration**
   - Rename to: `Debug-dev`
5. Duplicate **"Debug"** again:
   - Rename to: `Debug-staging`
6. Duplicate **"Release"**:
   - Rename to: `Release-staging`
7. Duplicate **"Release"** again:
   - Rename to: `Release-prod`

Final configuration list should be:
```
- Debug
- Debug-dev
- Debug-staging
- Release
- Release-staging
- Release-prod
```

---

## Step 3: Create Schemes

1. In Xcode, go to **Product > Scheme > Manage Schemes...**
2. Click **+** to create a new scheme
3. Name it: `Runner (dev)`
   - Target: Runner
   - Build Configuration (Debug): Debug-dev
   - Build Configuration (Release): Release (keep default)
4. Create second scheme: `Runner (staging)`
   - Build Configuration (Debug): Debug-staging
   - Build Configuration (Release): Release-staging
5. Create third scheme: `Runner (prod)`
   - Build Configuration (Debug): Debug (keep default)
   - Build Configuration (Release): Release-prod

---

## Step 4: Link Configuration Files

1. Select **Runner** project
2. Select **Runner** target
3. Go to **Build Settings** tab
4. Search for "Based on Configuration File"
5. For each configuration, set:
   - **Debug-dev**: `Configuration/Dev.xcconfig`
   - **Debug-staging**: `Configuration/Staging.xcconfig`
   - **Release-staging**: `Configuration/Staging.xcconfig`
   - **Release-prod**: `Configuration/Prod.xcconfig`

---

## Step 5: Configure Bundle IDs

1. Still in **Build Settings**
2. Search for "Product Bundle Identifier"
3. Expand the setting to show all configurations
4. Verify:
   - Debug-dev: `com.frigofute.frigofute-v2.dev`
   - Debug-staging: `com.frigofute.frigofute-v2.staging`
   - Release-staging: `com.frigofute.frigofute-v2.staging`
   - Release-prod: `com.frigofute.frigofute-v2`

---

## Step 6: Add Firebase Configs

1. Create directories in Finder:
   ```bash
   mkdir -p ios/Runner/Firebase/dev
   mkdir -p ios/Runner/Firebase/staging
   mkdir -p ios/Runner/Firebase/prod
   ```

2. Download GoogleService-Info.plist for each flavor from Firebase Console

3. Place files:
   ```
   ios/Runner/Firebase/dev/GoogleService-Info.plist
   ios/Runner/Firebase/staging/GoogleService-Info.plist
   ios/Runner/Firebase/prod/GoogleService-Info.plist
   ```

4. In Xcode, right-click **Runner** folder → **Add Files to "Runner"**
5. Select `Firebase` folder
6. ✅ Check "Create folder references" (NOT groups)
7. ✅ Check "Add to targets: Runner"

---

## Step 7: Update Info.plist (if needed)

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>$(DISPLAY_NAME)</string>

<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

---

## Step 8: Configure Signing

### For Development (dev flavor):
1. Select **Runner** target
2. Go to **Signing & Capabilities** tab
3. Select **Debug-dev** configuration
4. Enable **Automatically manage signing**
5. Select your **Team**

### For Staging/Production:
- Use **Fastlane Match** for certificate management
- See `ios/fastlane/README.md` for Match setup

---

## Step 9: Test Builds

```bash
# Test dev flavor
flutter build ios --flavor dev --debug --no-codesign

# Test staging flavor
flutter build ios --flavor staging --release

# Test production flavor
flutter build ios --flavor prod --release
```

---

## Verification Checklist

- [ ] 3 schemes created (dev, staging, prod)
- [ ] 5+ configurations exist
- [ ] xcconfig files linked correctly
- [ ] Bundle IDs different per flavor
- [ ] Firebase configs added for all flavors
- [ ] Dev build succeeds
- [ ] Staging build succeeds (with proper signing)
- [ ] Production build succeeds (with proper signing)

---

## Troubleshooting

### "No such module 'Firebase'"
- Run: `cd ios && pod install`
- Clean build: `flutter clean && flutter pub get`

### "Provisioning profile doesn't match"
- Check Bundle ID matches provisioning profile
- Run Fastlane Match: `cd ios && fastlane match development`

### "GoogleService-Info.plist not found"
- Verify file exists in correct Firebase/{flavor}/ directory
- Check FIREBASE_PLIST_PATH in xcconfig files

---

## Next Steps

After Xcode setup:
1. Configure signing certificates (Fastlane Match recommended)
2. Test Firebase integration with each flavor
3. Verify deep linking works for each flavor
4. Set up CI/CD for automated iOS builds

---

**🎯 Story 0.6 Status**: iOS configuration ready for manual Xcode setup
