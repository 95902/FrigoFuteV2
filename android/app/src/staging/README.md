# ⚠️ TEMPORARY CONFIGURATION

The `google-services.json` in this directory is a **TEMPORARY PLACEHOLDER** copied from the dev configuration.

## ⚠️ Action Required Before Production Use

This file **MUST BE REPLACED** with the actual google-services.json from the Firebase Console for the **frigofute-staging** project with package name `com.frigofute.frigofute_v2.staging`.

See `android/FIREBASE_SETUP.md` for complete setup instructions.

## Current State
- ✅ Allows builds to complete (for development)
- ❌ NOT production-ready
- ❌ Package name mismatch (using wrong Firebase project)

## Next Steps
1. Create Firebase project: `frigofute-staging`
2. Add Android app with package: `com.frigofute.frigofute_v2.staging`
3. Download correct google-services.json
4. Replace this file
5. Configure Firebase App Distribution for beta testing
