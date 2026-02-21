# Epic 1 Preparation Guide

**Projet**: FrigoFuteV2
**Epic**: 1 - User Authentication & Profile Management
**Date**: 2026-02-15
**Prérequis**: Epic 0 complété ✅

---

## 📋 Vue d'ensemble

Ce guide vous permet de compléter les 4 étapes préparatoires avant de commencer Epic 1:

1. ✅ **Corriger Freezed** - Régénérer le code Freezed
2. ✅ **Configuration Firebase Console** - Activer les services cloud
3. ✅ **Vérification CI/CD** - Tester les pipelines
4. ✅ **Déployer Security Rules** - Publier les règles de sécurité (optionnel)

**Temps estimé**: 30-45 minutes

---

## 1️⃣ Corriger Freezed Code Generation

### Problème Actuel

Les fichiers `.freezed.dart` existent mais l'analyseur Flutter signale des erreurs:
- `lib/core/feature_flags/models/feature_config.freezed.dart`
- `lib/core/feature_flags/models/subscription_status.freezed.dart`
- `lib/core/data_sync/models/sync_queue_item.freezed.dart`
- `lib/core/network/models/network_info.freezed.dart`

**Impact**: Warnings de l'analyseur uniquement, le code compile correctement.

### Solution: Flutter SDK Lock

**Erreur actuelle**:
```
Error: Flutter failed to write to a file at "c:\flutter\bin\cache\artifacts\engine\windows-x64\icudtl.dat"
The file is being used by another program.
```

**Cause**: Un processus verrouille le SDK Flutter (VS Code, Cursor, Android Studio, ou processus Flutter).

### Étapes de Résolution

#### Option A: Fermer les IDEs (Recommandé)

1. **Fermer tous les éditeurs**:
   - ❌ Fermer VS Code
   - ❌ Fermer Cursor
   - ❌ Fermer Android Studio
   - ❌ Fermer IntelliJ IDEA

2. **Terminer les processus Flutter**:
   ```bash
   # Windows PowerShell (en tant qu'administrateur)
   taskkill /F /IM dart.exe
   taskkill /F /IM flutter.exe
   taskkill /F /IM flutter_tools.exe
   ```

3. **Régénérer le code Freezed**:
   ```bash
   cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2

   # Nettoyer le cache
   flutter pub run build_runner clean

   # Régénérer les fichiers Freezed
   flutter pub run build_runner build --delete-conflicting-outputs

   # Vérifier les erreurs
   flutter analyze
   ```

4. **Vérification**:
   ```bash
   # Devrait afficher "No issues found!"
   flutter analyze
   ```

#### Option B: Désactiver temporairement l'antivirus

Si Option A ne fonctionne pas:

1. **Désactiver Windows Defender** (temporairement):
   - Ouvrir "Sécurité Windows"
   - Protection contre les virus et menaces
   - Gérer les paramètres
   - Désactiver "Protection en temps réel"

2. **Exécuter les commandes**:
   ```bash
   flutter pub run build_runner clean
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Réactiver Windows Defender** immédiatement après.

#### Option C: Redémarrage à froid

Si les options A et B échouent:

1. **Redémarrer l'ordinateur**
2. **NE PAS ouvrir d'IDE**
3. **Exécuter immédiatement** depuis un terminal:
   ```bash
   cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter analyze
   ```

### Résultat Attendu

```bash
$ flutter analyze
Analyzing frigofute_v2...
No issues found! ✅
```

**Status**: ⬜ À compléter

---

## 2️⃣ Configuration Firebase Console

### Prérequis

- Compte Google avec accès à Firebase Console
- Projet Firebase créé (ou à créer)

### 2.1 Créer les Projets Firebase

**Environnements requis**: Development, Staging, Production

#### Development (frigofute-dev)

1. **Accéder à Firebase Console**: https://console.firebase.google.com/
2. **Créer un nouveau projet**:
   - Nom: `FrigoFute Development`
   - Project ID: `frigofute-dev`
   - ✅ Activer Google Analytics (recommandé)
3. **Configurer le plan**: Spark (gratuit)

#### Staging (frigofute-staging)

1. **Créer un nouveau projet**:
   - Nom: `FrigoFute Staging`
   - Project ID: `frigofute-staging`
   - ✅ Activer Google Analytics
2. **Configurer le plan**: Spark (gratuit)

#### Production (frigofute-prod)

1. **Créer un nouveau projet**:
   - Nom: `FrigoFute Production`
   - Project ID: `frigofute-prod`
   - ✅ Activer Google Analytics
2. **Configurer le plan**: Blaze (pay-as-you-go) - **Requis pour certaines fonctionnalités**

### 2.2 Activer Crashlytics

**Pour chaque environnement** (dev, staging, prod):

1. **Accéder à Crashlytics**:
   - Menu latéral → "Release & Monitor" → "Crashlytics"
   - Cliquer "Get started"

2. **Configuration Android**:
   - Suivre l'assistant d'installation
   - Vérifier que `google-services.json` est présent dans `android/app/`

3. **Configuration iOS**:
   - Suivre l'assistant d'installation
   - Vérifier que `GoogleService-Info.plist` est présent dans `ios/Runner/`

4. **Test de validation**:
   ```dart
   // À exécuter dans l'app
   FirebaseCrashlytics.instance.crash(); // Force un crash test
   ```

5. **Vérifier les rapports**:
   - Les crashes devraient apparaître dans la console sous 5 minutes

**Status**:
- ⬜ Development
- ⬜ Staging
- ⬜ Production

### 2.3 Configurer Remote Config

**Pour chaque environnement**:

1. **Accéder à Remote Config**:
   - Menu latéral → "Engage" → "Remote Config"

2. **Créer les paramètres par défaut**:

   | Paramètre | Type | Valeur Dev | Valeur Staging | Valeur Prod | Description |
   |-----------|------|------------|----------------|-------------|-------------|
   | `enable_meal_planning` | Boolean | `false` | `false` | `false` | Active la planification de repas (Epic 9) |
   | `enable_ai_nutrition_coach` | Boolean | `false` | `false` | `false` | Active le coach nutrition IA (Epic 11) |
   | `enable_price_comparison` | Boolean | `false` | `false` | `false` | Active la comparaison de prix (Epic 12) |
   | `enable_gamification` | Boolean | `false` | `false` | `false` | Active la gamification (Epic 13) |
   | `max_free_ocr_scans` | Number | `10` | `10` | `10` | Limite OCR pour utilisateurs gratuits |
   | `max_premium_ocr_scans` | Number | `1000` | `1000` | `1000` | Limite OCR pour utilisateurs premium |
   | `gemini_rate_limit_seconds` | Number | `2` | `2` | `2` | Délai minimum entre requêtes Gemini |
   | `vision_api_monthly_quota` | Number | `1000` | `1000` | `1000` | Quota mensuel Vision API |
   | `enable_beta_features` | Boolean | `true` | `true` | `false` | Active les fonctionnalités beta |

3. **Publier la configuration**:
   - Cliquer "Publish changes"
   - Ajouter un message de commit: "Initial Remote Config setup"

4. **Test de validation**:
   ```dart
   // Vérifier que les paramètres sont récupérés
   final remoteConfig = FirebaseRemoteConfig.instance;
   await remoteConfig.fetchAndActivate();
   print(remoteConfig.getBool('enable_meal_planning')); // false
   ```

**Status**:
- ⬜ Development
- ⬜ Staging
- ⬜ Production

### 2.4 Vérifier les Quotas Firestore/Storage

**Pour chaque environnement**:

1. **Firestore Database**:
   - Menu → "Build" → "Firestore Database"
   - Vérifier les quotas:
     - ✅ **Reads**: 50,000 / jour (Spark)
     - ✅ **Writes**: 20,000 / jour (Spark)
     - ✅ **Deletes**: 20,000 / jour (Spark)
     - ✅ **Storage**: 1 GB (Spark)

2. **Firebase Storage**:
   - Menu → "Build" → "Storage"
   - Vérifier les quotas:
     - ✅ **Storage**: 5 GB (Spark)
     - ✅ **Downloads**: 1 GB / jour (Spark)
     - ✅ **Uploads**: 10 MB / jour (Spark)

3. **Configurer les alertes de quota**:
   - Accéder à "Usage and billing"
   - Configurer des alertes à 80% et 90% de chaque quota

**Status**:
- ⬜ Development
- ⬜ Staging
- ⬜ Production

### 2.5 Activer Authentication

**Pour chaque environnement**:

1. **Accéder à Authentication**:
   - Menu → "Build" → "Authentication"
   - Cliquer "Get started"

2. **Activer Email/Password**:
   - Onglet "Sign-in method"
   - Email/Password → Enable
   - ✅ Email link (passwordless sign-in) → Disable (pour l'instant)

3. **Activer Google Sign-In**:
   - Google → Enable
   - Email de support: `support@frigofute.com` (ou votre email)
   - Télécharger le nouveau `google-services.json` et `GoogleService-Info.plist`

4. **Activer Apple Sign-In** (requis pour iOS):
   - Apple → Enable
   - Suivre les instructions pour configurer Apple Developer Console

**Status**:
- ⬜ Development (Email/Password + Google)
- ⬜ Staging (Email/Password + Google)
- ⬜ Production (Email/Password + Google + Apple)

### 2.6 Configuration Analytics & Performance

**Pour chaque environnement**:

1. **Google Analytics**:
   - Déjà activé lors de la création du projet
   - Vérifier la collection de données: Menu → "Analytics" → "Dashboard"

2. **Performance Monitoring**:
   - Menu → "Release & Monitor" → "Performance"
   - Cliquer "Get started"
   - Suivre l'assistant (déjà configuré dans le code)

3. **Test de validation**:
   ```dart
   // Logger un événement de test
   FirebaseAnalytics.instance.logEvent(
     name: 'epic_1_preparation_test',
     parameters: {'environment': 'dev'},
   );
   ```

**Status**:
- ⬜ Development
- ⬜ Staging
- ⬜ Production

---

## 3️⃣ Vérification CI/CD

### 3.1 Workflows Disponibles

✅ **4 workflows GitHub Actions créés**:

1. **`.github/workflows/pr_checks.yml`** (Pull Request Checks)
   - Tests unitaires
   - Couverture de code ≥75%
   - Analyse statique
   - Build verification

2. **`.github/workflows/security_checks.yml`** (Security Audit)
   - Détection de secrets hardcodés
   - Audit OWASP des dépendances
   - Vérification de licence (GPL/AGPL)
   - Vérification de couverture

3. **`.github/workflows/staging_deploy.yml`** (Staging Deployment)
   - Build Android (APK + AAB)
   - Build iOS (IPA)
   - Déploiement Firebase App Distribution

4. **`.github/workflows/production_deploy.yml`** (Production Deployment)
   - Build production avec obfuscation
   - Upload Play Store (Android)
   - Upload App Store (iOS)

### 3.2 Tester Localement avec `act`

**Installation de `act`** (Docker requis):

```bash
# Windows (avec Chocolatey)
choco install act-cli

# Ou avec Scoop
scoop install act

# Ou téléchargement manuel
# https://github.com/nektos/act/releases
```

**Tester le workflow PR Checks**:

```bash
cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2

# Simuler un pull request
act pull_request -W .github/workflows/pr_checks.yml

# Simuler seulement le job de tests
act pull_request -W .github/workflows/pr_checks.yml -j test

# Mode verbeux pour debug
act pull_request -W .github/workflows/pr_checks.yml -v
```

**Tester le workflow Security Checks**:

```bash
# Simuler un pull request avec security checks
act pull_request -W .github/workflows/security_checks.yml

# Tester seulement l'audit de sécurité
act pull_request -W .github/workflows/security_checks.yml -j security-audit
```

**Résultats attendus**:
- ✅ All jobs completed successfully
- ✅ Tests passing (316 tests)
- ✅ Coverage ≥75% (actuellement 78.5%)
- ✅ No security issues found

**Status**: ⬜ À tester

### 3.3 Configurer les Secrets GitHub

**Accéder à GitHub Repository Settings**:
1. Aller sur https://github.com/[votre-username]/FrigoFuteV2
2. Settings → Secrets and variables → Actions
3. Cliquer "New repository secret"

**Secrets requis**:

| Secret Name | Description | Comment l'obtenir |
|-------------|-------------|-------------------|
| `FIREBASE_TOKEN` | Token Firebase CLI | `firebase login:ci` |
| `CODECOV_TOKEN` | Token CodeCov | https://codecov.io/ |
| `GOOGLE_SERVICES_JSON` | Android config | Base64 de `android/app/google-services.json` |
| `GOOGLE_SERVICES_PLIST` | iOS config | Base64 de `ios/Runner/GoogleService-Info.plist` |
| `ANDROID_KEYSTORE` | Clé de signature Android | Base64 de `upload-keystore.jks` |
| `ANDROID_KEY_PASSWORD` | Mot de passe keystore | Celui utilisé lors de la création |
| `ANDROID_STORE_PASSWORD` | Mot de passe store | Celui utilisé lors de la création |
| `IOS_CERTIFICATE` | Certificat iOS | Base64 du certificat .p12 |
| `IOS_CERTIFICATE_PASSWORD` | Mot de passe certificat | Celui du certificat .p12 |

**Génération Firebase Token**:

```bash
# Installer Firebase CLI si nécessaire
npm install -g firebase-tools

# Générer le token
firebase login:ci

# Copier le token affiché et l'ajouter comme secret GitHub
```

**Encoder en Base64 (Windows PowerShell)**:

```powershell
# Pour google-services.json
$file = "android/app/google-services.json"
$bytes = [System.IO.File]::ReadAllBytes($file)
$base64 = [System.Convert]::ToBase64String($bytes)
$base64 | Set-Clipboard
# Le base64 est maintenant dans le presse-papiers

# Pour GoogleService-Info.plist
$file = "ios/Runner/GoogleService-Info.plist"
$bytes = [System.IO.File]::ReadAllBytes($file)
$base64 = [System.Convert]::ToBase64String($bytes)
$base64 | Set-Clipboard
```

**Status**: ⬜ À configurer

### 3.4 Valider le Pipeline

**Test complet du pipeline**:

1. **Créer une branche de test**:
   ```bash
   git checkout -b test/ci-cd-validation
   ```

2. **Faire un changement mineur**:
   ```bash
   echo "# CI/CD Test" >> README.md
   git add README.md
   git commit -m "test: Validate CI/CD pipeline"
   ```

3. **Pousser et créer une PR**:
   ```bash
   git push origin test/ci-cd-validation
   ```

4. **Créer une Pull Request sur GitHub**

5. **Vérifier les checks**:
   - ✅ PR Checks workflow passe
   - ✅ Security Checks workflow passe
   - ✅ Tous les jobs verts

6. **Merger la PR** si tout est vert

**Status**: ⬜ À valider

---

## 4️⃣ Déployer Security Rules (Optionnel)

### Prérequis

- Firebase CLI installé: `npm install -g firebase-tools`
- Authentifié: `firebase login`
- Projets Firebase configurés (étape 2)

### 4.1 Vérifier les Fichiers de Rules

**Fichiers de sécurité disponibles**:

✅ `firestore.rules` (10,059 bytes)
- User data isolation
- Custom claims validation (health_data_consent, is_premium)
- XSS prevention (validProductName, validRecipeText)
- Fail-secure deny-all

✅ `storage.rules` (4,470 bytes)
- File size limits (10MB)
- File type validation (images only)
- Health consent requirement
- Fail-secure deny-all

### 4.2 Configuration Firebase CLI

**Initialiser Firebase** (si pas déjà fait):

```bash
cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2

# Initialiser Firebase
firebase init

# Sélectionner:
# ✅ Firestore
# ✅ Storage
# (Autres: déjà configurés)

# Utiliser les fichiers existants:
# - firestore.rules
# - storage.rules
```

**Configurer les alias d'environnement**:

```bash
# Ajouter l'alias dev
firebase use --add
# Sélectionner: frigofute-dev
# Alias: dev

# Ajouter l'alias staging
firebase use --add
# Sélectionner: frigofute-staging
# Alias: staging

# Ajouter l'alias production
firebase use --add
# Sélectionner: frigofute-prod
# Alias: production
```

### 4.3 Déployer sur Staging

**Étape 1: Backup des rules existantes**:

```bash
# Basculer sur staging
firebase use staging

# Sauvegarder les rules actuelles
firebase firestore:rules:get > firestore.rules.backup
firebase storage:rules:get > storage.rules.backup

# Vérifier les backups
ls -l *.backup
```

**Étape 2: Valider la syntaxe**:

```bash
# Dry-run pour Firestore
firebase deploy --only firestore:rules --dry-run

# Dry-run pour Storage
firebase deploy --only storage --dry-run

# Si aucune erreur, continuer
```

**Étape 3: Déployer les rules**:

```bash
# Déployer Firestore rules
firebase deploy --only firestore:rules

# Déployer Storage rules
firebase deploy --only storage

# Ou tout en une fois
firebase deploy --only firestore:rules,storage
```

**Étape 4: Vérifier le déploiement**:

```bash
# Les rules devraient être actives dans la console Firebase
# https://console.firebase.google.com/u/0/project/frigofute-staging/firestore/rules
```

**Status**: ⬜ Staging deployed

### 4.4 Tester les Rules sur Staging

**Tests manuels dans la console Firebase**:

1. **Accéder à Firestore Rules Playground**:
   - Console Firebase → Firestore → Rules → Onglet "Rules Playground"

2. **Test 1: Accès utilisateur anonyme** (devrait échouer):
   ```
   Location: /users/user123/profile
   Operation: get
   Authenticated: No
   Expected: ❌ Denied
   ```

3. **Test 2: Accès utilisateur authentifié** (devrait réussir):
   ```
   Location: /users/user123/profile
   Operation: get
   Authenticated: Yes
   Auth UID: user123
   Expected: ✅ Allowed
   ```

4. **Test 3: Accès cross-user** (devrait échouer):
   ```
   Location: /users/user456/profile
   Operation: get
   Authenticated: Yes
   Auth UID: user123
   Expected: ❌ Denied (not owner)
   ```

5. **Test 4: Health data sans consent** (devrait échouer):
   ```
   Location: /users/user123/health/nutrition_data
   Operation: get
   Authenticated: Yes
   Auth UID: user123
   Custom Claims: { "health_data_consent": false }
   Expected: ❌ Denied
   ```

6. **Test 5: Health data avec consent** (devrait réussir):
   ```
   Location: /users/user123/health/nutrition_data
   Operation: get
   Authenticated: Yes
   Auth UID: user123
   Custom Claims: { "health_data_consent": true }
   Expected: ✅ Allowed
   ```

**Status**: ⬜ Tests passed

### 4.5 Déployer sur Production (Après validation staging)

**⚠️ IMPORTANT**: Ne déployer en production qu'après validation complète sur staging !

```bash
# Basculer sur production
firebase use production

# Backup des rules existantes
firebase firestore:rules:get > firestore.rules.prod.backup
firebase storage:rules:get > storage.rules.prod.backup

# Déployer
firebase deploy --only firestore:rules,storage

# Vérifier immédiatement
# Tester l'accès à l'app en production
```

**Status**: ⬜ Production deployed

---

## ✅ Checklist de Validation Finale

### Avant de Commencer Epic 1

- [ ] **1. Freezed Code Generation**
  - [ ] Processus Flutter/IDE fermés
  - [ ] `flutter pub run build_runner clean` exécuté
  - [ ] `flutter pub run build_runner build --delete-conflicting-outputs` exécuté
  - [ ] `flutter analyze` = "No issues found!"

- [ ] **2. Firebase Console - Development**
  - [ ] Projet créé (frigofute-dev)
  - [ ] Crashlytics activé et testé
  - [ ] Remote Config configuré (10 paramètres)
  - [ ] Quotas Firestore/Storage vérifiés
  - [ ] Authentication activée (Email/Password + Google)
  - [ ] Analytics & Performance actifs

- [ ] **3. Firebase Console - Staging**
  - [ ] Projet créé (frigofute-staging)
  - [ ] Crashlytics activé et testé
  - [ ] Remote Config configuré (10 paramètres)
  - [ ] Quotas Firestore/Storage vérifiés
  - [ ] Authentication activée (Email/Password + Google)
  - [ ] Analytics & Performance actifs

- [ ] **4. Firebase Console - Production**
  - [ ] Projet créé (frigofute-prod)
  - [ ] Plan Blaze configuré
  - [ ] Crashlytics activé et testé
  - [ ] Remote Config configuré (10 paramètres)
  - [ ] Quotas Firestore/Storage vérifiés
  - [ ] Authentication activée (Email/Password + Google + Apple)
  - [ ] Analytics & Performance actifs

- [ ] **5. CI/CD Pipeline**
  - [ ] `act` installé (pour tests locaux)
  - [ ] PR Checks workflow testé localement
  - [ ] Security Checks workflow testé localement
  - [ ] Secrets GitHub configurés (9 secrets)
  - [ ] Pipeline validé avec une PR de test

- [ ] **6. Security Rules (Optionnel)**
  - [ ] Firebase CLI installé et authentifié
  - [ ] Alias environnements configurés (dev, staging, prod)
  - [ ] Rules déployées sur staging
  - [ ] Tests manuels réussis sur staging
  - [ ] Rules déployées sur production (après validation)

---

## 🚀 Prêt pour Epic 1

Une fois toutes les étapes complétées, Epic 1 peut démarrer:

```bash
# Créer la branche Epic 1
git checkout -b epic-1/user-authentication

# Commencer Story 1.1
# Story 1.1: Create Account with Email and Password
```

### Stories Epic 1 (10 stories ready-for-dev)

1. **Story 1.1**: Create Account (Email/Password)
2. **Story 1.2**: Login (Email/Password)
3. **Story 1.3**: Google Sign-In
4. **Story 1.4**: Apple Sign-In
5. **Story 1.5**: Adaptive Onboarding Flow
6. **Story 1.6**: Personal Profile Configuration
7. **Story 1.7**: Dietary Preferences & Allergies
8. **Story 1.8**: Multi-Device Data Sync
9. **Story 1.9**: RGPD Data Export
10. **Story 1.10**: Account Deletion (Right to be Forgotten)

---

## 📞 Support

**En cas de problème**:

1. **Freezed Issues**: Consulter https://pub.dev/packages/freezed/install
2. **Firebase Console**: https://firebase.google.com/support
3. **GitHub Actions**: Consulter les logs dans l'onglet "Actions"
4. **Security Rules**: Tester dans Rules Playground avant déploiement

**Documentation**:
- `docs/EPIC_0_FINAL_REPORT.md` - Rapport complet Epic 0
- `docs/DEPLOYMENT_CHECKLIST.md` - Checklist de déploiement détaillée
- `docs/SECURITY_BEST_PRACTICES.md` - Guide de sécurité pour développeurs

---

**Date de création**: 2026-02-15
**Dernière mise à jour**: 2026-02-15
**Version**: 1.0
**Status**: 🟡 En attente de complétion manuelle
