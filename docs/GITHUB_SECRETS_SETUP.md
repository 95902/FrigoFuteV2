# GitHub Secrets Configuration Guide

## 📋 Overview

Ce guide détaille la configuration de tous les secrets GitHub nécessaires pour les workflows CI/CD de FrigoFuteV2.

**⚠️ CRITIQUE:** Ces secrets contiennent des credentials sensibles. Ne JAMAIS les commiter ou les partager.

## 🔐 Secrets Required

### Firebase Secrets

#### `FIREBASE_SERVICE_KEY_STAGING`
- **Type:** JSON (service account)
- **Usage:** Upload vers Firebase App Distribution (staging)
- **Génération:**
  1. Firebase Console → frigofute-staging → Project Settings
  2. Service Accounts tab
  3. Generate new private key → Download JSON
  4. Copier le contenu JSON complet dans le secret

**Permissions requises:**
- Firebase App Distribution Admin
- Cloud Storage for Firebase Admin

#### `FIREBASE_SERVICE_KEY_PROD`
- **Type:** JSON (service account)
- **Usage:** Crashlytics symbols upload (production)
- **Génération:** Même process que staging, mais pour frigofute-prod

#### `FIREBASE_ANDROID_APP_ID_STAGING`
- **Type:** String
- **Usage:** Identifier l'app Android dans Firebase App Distribution
- **Où trouver:** Firebase Console → frigofute-staging → Project Settings → Your apps → Android app
- **Format:** `1:123456789:android:abc123def456`

#### `FIREBASE_IOS_APP_ID_STAGING`
- **Type:** String
- **Usage:** Identifier l'app iOS dans Firebase App Distribution
- **Où trouver:** Firebase Console → frigofute-staging → Project Settings → Your apps → iOS app
- **Format:** `1:123456789:ios:abc123def456`

#### `FIREBASE_TOKEN`
- **Type:** String
- **Usage:** Firebase CLI authentication
- **Génération:**
  ```bash
  firebase login:ci
  # Copy the token displayed
  ```

#### `FIREBASE_PROJECT_ID`
- **Type:** String
- **Usage:** Crashlytics mapping upload
- **Valeur:** `frigofute-prod` (project ID de production)

### Android Play Store Secrets

#### `ANDROID_SERVICE_ACCOUNT_JSON`
- **Type:** JSON
- **Usage:** Upload vers Google Play Store
- **Génération:**
  1. Google Play Console → Setup → API access
  2. Create new service account (ou use existing)
  3. Grant permissions: Release to production, Release to testing tracks
  4. Download JSON key
  5. Copier le contenu JSON complet dans le secret

**Permissions requises:**
- Release to production
- Release to testing tracks
- View app information

#### `ANDROID_KEYSTORE_FILE`
- **Type:** Base64-encoded binary
- **Usage:** Sign l'APK/AAB pour release
- **Génération:**
  ```bash
  # 1. Generate keystore (si pas déjà fait)
  keytool -genkey -v -keystore android-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias frigofute-key

  # 2. Encode to base64
  base64 -i android-keystore.jks | tr -d '\n' | pbcopy  # macOS
  # ou
  base64 -w 0 android-keystore.jks  # Linux

  # 3. Paste dans GitHub secret
  ```

⚠️ **BACKUP:** Sauvegarder le keystore dans un coffre-fort sécurisé (1Password, LastPass, etc.)

#### `ANDROID_KEYSTORE_PASSWORD`
- **Type:** String
- **Usage:** Mot de passe du keystore
- **Valeur:** Le mot de passe choisi lors de la génération du keystore

#### `ANDROID_KEY_ALIAS`
- **Type:** String
- **Usage:** Alias de la clé dans le keystore
- **Valeur:** `frigofute-key` (ou l'alias choisi lors de la génération)

#### `ANDROID_KEY_PASSWORD`
- **Type:** String
- **Usage:** Mot de passe de la clé
- **Valeur:** Le mot de passe de la clé (peut être identique au keystore password)

### iOS App Store Secrets

#### `APPSTORE_ISSUER_ID`
- **Type:** String (UUID)
- **Usage:** App Store Connect API authentication
- **Où trouver:**
  1. App Store Connect → Users and Access → Keys
  2. API Keys tab
  3. Issuer ID (en haut de la page)
- **Format:** `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

#### `APPSTORE_API_KEY_ID`
- **Type:** String
- **Usage:** App Store Connect API key identifier
- **Où trouver:**
  1. App Store Connect → Users and Access → Keys
  2. Créer une nouvelle clé (ou use existing)
  3. Key ID (8-10 caractères alphanumériques)
- **Format:** `AB12CD34EF`

**Permissions requises:**
- App Manager (ou Admin)

#### `APPSTORE_API_PRIVATE_KEY`
- **Type:** String (multi-line)
- **Usage:** App Store Connect API private key
- **Génération:**
  1. App Store Connect → Users and Access → Keys
  2. Download la clé .p8 file
  3. Copier le contenu COMPLET (including headers):
     ```
     -----BEGIN PRIVATE KEY-----
     [key content]
     -----END PRIVATE KEY-----
     ```

#### `APPLE_CERTIFICATES_P12`
- **Type:** Base64-encoded binary
- **Usage:** iOS code signing
- **Génération:**
  ```bash
  # Option 1: Export depuis Keychain (macOS)
  # 1. Open Keychain Access
  # 2. Find "Apple Distribution: [Your Name]"
  # 3. Right-click → Export
  # 4. Save as .p12 file
  # 5. Encode:
  base64 -i Certificates.p12 | tr -d '\n' | pbcopy

  # Option 2: Use Fastlane Match
  fastlane match appstore
  # Match stocke les certificats dans un repo git privé
  ```

#### `APPLE_CERTIFICATES_PASSWORD`
- **Type:** String
- **Usage:** Password for .p12 certificate file
- **Valeur:** Le mot de passe choisi lors de l'export

### Monitoring Secrets

#### `SENTRY_AUTH_TOKEN`
- **Type:** String
- **Usage:** Upload debug symbols to Sentry
- **Génération:**
  1. Sentry.io → Settings → Account → Auth Tokens
  2. Create new token
  3. Scopes: `project:read`, `project:releases`, `project:write`

**Optional:** Si vous n'utilisez pas Sentry, vous pouvez skip ce secret (le workflow le détecte).

#### `SENTRY_ORG`
- **Type:** String
- **Usage:** Sentry organization slug
- **Valeur:** Votre organization name dans Sentry (visible dans l'URL)

#### `SENTRY_PROJECT`
- **Type:** String
- **Usage:** Sentry project slug
- **Valeur:** `frigofute-v2` (ou le nom du projet dans Sentry)

#### `CODECOV_TOKEN`
- **Type:** String
- **Usage:** Upload coverage reports to Codecov
- **Génération:**
  1. Codecov.io → Add repository
  2. Copy the token

**Optional:** Si vous n'utilisez pas Codecov, le workflow continue sans échec.

## 📝 Configuration Steps

### 1. Aller dans GitHub Settings

```
GitHub Repository → Settings → Secrets and variables → Actions
```

### 2. Ajouter chaque secret

Click "New repository secret" pour chaque secret de la liste ci-dessus.

### 3. Vérifier les secrets

Liste minimale pour CI/CD fonctionnel:

**PR Checks (ne nécessite aucun secret)**
- ✅ Pas de secrets requis

**Staging Deploy (nécessite Firebase)**
- `FIREBASE_SERVICE_KEY_STAGING`
- `FIREBASE_ANDROID_APP_ID_STAGING`
- `FIREBASE_IOS_APP_ID_STAGING`

**Production Deploy (nécessite tous les secrets)**
- Tous les secrets Firebase
- Tous les secrets Android
- Tous les secrets iOS
- (Optionnel) Secrets monitoring

## 🧪 Testing Secrets

### Test Firebase Secrets

```bash
# Create a test script
cat > test_firebase.sh <<'EOF'
#!/bin/bash
echo "$FIREBASE_SERVICE_KEY_STAGING" | jq '.'
EOF

chmod +x test_firebase.sh

# Run locally (DO NOT commit this script)
FIREBASE_SERVICE_KEY_STAGING='<paste secret here>' ./test_firebase.sh
```

### Test Android Keystore

```bash
# Decode and verify keystore
echo "$ANDROID_KEYSTORE_FILE" | base64 -d > test-keystore.jks

keytool -list -v -keystore test-keystore.jks \
  -storepass "$ANDROID_KEYSTORE_PASSWORD"

# Should show your key alias and validity

rm test-keystore.jks  # Clean up
```

## 🔒 Security Best Practices

### ✅ DO:
- Rotate secrets every 6 months
- Use unique passwords for each secret
- Store backups in a password manager (1Password, LastPass)
- Limit access to secrets (GitHub repo admins only)
- Use environment-specific service accounts

### ❌ DON'T:
- Commit secrets to git (même dans .env files)
- Share secrets via email/Slack
- Use production secrets for development
- Reuse passwords across services

## 📊 Secrets Checklist

Copiez cette checklist dans un fichier sécurisé (NOT in git):

```markdown
## Firebase
- [ ] FIREBASE_SERVICE_KEY_STAGING
- [ ] FIREBASE_SERVICE_KEY_PROD
- [ ] FIREBASE_ANDROID_APP_ID_STAGING
- [ ] FIREBASE_IOS_APP_ID_STAGING
- [ ] FIREBASE_TOKEN
- [ ] FIREBASE_PROJECT_ID

## Android
- [ ] ANDROID_SERVICE_ACCOUNT_JSON
- [ ] ANDROID_KEYSTORE_FILE (base64)
- [ ] ANDROID_KEYSTORE_PASSWORD
- [ ] ANDROID_KEY_ALIAS
- [ ] ANDROID_KEY_PASSWORD

## iOS
- [ ] APPSTORE_ISSUER_ID
- [ ] APPSTORE_API_KEY_ID
- [ ] APPSTORE_API_PRIVATE_KEY
- [ ] APPLE_CERTIFICATES_P12 (base64)
- [ ] APPLE_CERTIFICATES_PASSWORD

## Monitoring (Optional)
- [ ] SENTRY_AUTH_TOKEN
- [ ] SENTRY_ORG
- [ ] SENTRY_PROJECT
- [ ] CODECOV_TOKEN
```

## 📞 Support

**Issues avec secrets?**
1. Vérifier le format (JSON valid, base64 encodé correctly)
2. Vérifier les permissions (service account, API key)
3. Tester localement avec les scripts ci-dessus
4. Check GitHub Actions logs pour error messages

**Référence:**
- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Firebase Service Accounts](https://firebase.google.com/docs/admin/setup#initialize-sdk)
- [Google Play Publish API](https://developers.google.com/android-publisher/getting_started)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
