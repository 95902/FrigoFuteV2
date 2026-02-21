# ⚠️ TEMPORARY CONFIGURATION

The `google-services.json` in this directory is a **TEMPORARY PLACEHOLDER** copied from the dev configuration.

## ⚠️ Action Required Before Production Use

This file **MUST BE REPLACED** with the actual google-services.json from the Firebase Console for the **frigofute-prod** project with package name `com.frigofute.frigofute_v2`.

See `android/FIREBASE_SETUP.md` for complete setup instructions.

## Current State
- ✅ Allows builds to complete (for development)
- ❌ NOT production-ready
- ❌ Package name mismatch (using wrong Firebase project)
- ❌ CRITICAL: Do NOT deploy to production with this file

## Next Steps
1. Create Firebase project: `frigofute-prod`
2. Add Android app with package: `com.frigofute.frigofute_v2`
3. Download correct google-services.json
4. Replace this file
5. Enable Production services (Crashlytics, Performance, Remote Config)
