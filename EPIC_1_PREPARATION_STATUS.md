# Epic 1 - Preparation Status

**Date**: 2026-02-15
**Epic**: 1 - User Authentication & Profile Management
**Prérequis**: Epic 0 ✅ DONE

---

## 📋 Status Global

| Étape | Status | Priorité | Temps Estimé |
|-------|--------|----------|--------------|
| 1. Corriger Freezed | ⬜ À faire | 🔴 CRITIQUE | 5 min |
| 2. Firebase Console | ⬜ À faire | 🔴 CRITIQUE | 20 min |
| 3. Vérification CI/CD | ⬜ À faire | 🟡 Optionnel | 10 min |
| 4. Security Rules | ⬜ À faire | 🟡 Optionnel | 5 min |

**Temps total minimum**: 25 minutes

---

## 1️⃣ Corriger Freezed Code Generation

### Status: ⬜ À FAIRE (CRITIQUE)

**Problème**: SDK Flutter verrouillé par un processus

### Actions:

```bash
# 1. Fermer tous les IDEs (VS Code, Cursor, Android Studio)

# 2. Terminer les processus Flutter (PowerShell Admin)
taskkill /F /IM dart.exe
taskkill /F /IM flutter.exe

# 3. Régénérer le code
cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
```

### Validation:

```bash
flutter analyze
# Attendu: "No issues found!" ✅
```

### Fichiers Impactés:

- ✅ `lib/core/feature_flags/models/feature_config.freezed.dart`
- ✅ `lib/core/feature_flags/models/subscription_status.freezed.dart`
- ✅ `lib/core/data_sync/models/sync_queue_item.freezed.dart`
- ✅ `lib/core/network/models/network_info.freezed.dart`

**Complétion**: ⬜ / 100%

---

## 2️⃣ Configuration Firebase Console

### Status: ⬜ À FAIRE (CRITIQUE)

**IMPORTANT**: Sans cette configuration, l'authentication Epic 1 ne fonctionnera pas.

### 2.1 Créer Projet Development

**Console**: https://console.firebase.google.com/

- ⬜ Créer projet `FrigoFute Development` (ID: `frigofute-dev`)
- ⬜ Plan Spark (gratuit)
- ⬜ Activer Google Analytics

### 2.2 Activer Authentication

- ⬜ Menu → Authentication → Get Started
- ⬜ Email/Password → Enable
- ⬜ Google Sign-In → Enable
- ⬜ Télécharger `google-services.json` (Android)
- ⬜ Télécharger `GoogleService-Info.plist` (iOS)

### 2.3 Activer Crashlytics

- ⬜ Menu → Crashlytics → Get Started
- ⬜ Suivre l'assistant d'installation

### 2.4 Configurer Remote Config

Paramètres minimum requis:

- ⬜ `enable_beta_features` = `true` (Boolean)
- ⬜ `enable_meal_planning` = `false` (Boolean)
- ⬜ `enable_ai_nutrition_coach` = `false` (Boolean)
- ⬜ `enable_price_comparison` = `false` (Boolean)
- ⬜ `enable_gamification` = `false` (Boolean)
- ⬜ `max_free_ocr_scans` = `10` (Number)
- ⬜ `max_premium_ocr_scans` = `1000` (Number)
- ⬜ `gemini_rate_limit_seconds` = `2` (Number)
- ⬜ `vision_api_monthly_quota` = `1000` (Number)

### 2.5 Générer firebase_options.dart

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Générer la configuration
flutterfire configure --project=frigofute-dev
```

### 2.6 Vérifier les Quotas

- ⬜ Firestore: 50,000 reads/day (Spark)
- ⬜ Storage: 5 GB storage (Spark)
- ⬜ Authentication: Unlimited (Spark)

### Validation:

```bash
# Vérifier que le fichier existe
ls lib/firebase_options.dart
# ✅ Attendu: Le fichier existe

# Vérifier que l'app compile
flutter run
# ✅ Attendu: L'app démarre sans erreur Firebase
```

**Complétion**: ⬜ / 100%

---

## 3️⃣ Vérification CI/CD (Optionnel)

### Status: ⬜ À FAIRE (Optionnel)

**Note**: Peut être fait après le démarrage d'Epic 1.

### 3.1 Workflows Existants

- ✅ `.github/workflows/pr_checks.yml`
- ✅ `.github/workflows/security_checks.yml`
- ✅ `.github/workflows/staging_deploy.yml`
- ✅ `.github/workflows/production_deploy.yml`

### 3.2 Tests Locaux (avec act)

```bash
# Installer act (optionnel)
choco install act-cli

# Tester PR checks
act pull_request -W .github/workflows/pr_checks.yml

# Tester Security checks
act pull_request -W .github/workflows/security_checks.yml
```

### 3.3 Secrets GitHub

**Note**: Requis avant le premier déploiement, pas pour le développement local.

- ⬜ `FIREBASE_TOKEN`
- ⬜ `CODECOV_TOKEN`
- ⬜ `GOOGLE_SERVICES_JSON`
- ⬜ `GOOGLE_SERVICES_PLIST`
- ⬜ `ANDROID_KEYSTORE`
- ⬜ `ANDROID_KEY_PASSWORD`
- ⬜ `ANDROID_STORE_PASSWORD`
- ⬜ `IOS_CERTIFICATE`
- ⬜ `IOS_CERTIFICATE_PASSWORD`

**Complétion**: ⬜ / 100%

---

## 4️⃣ Déployer Security Rules (Optionnel)

### Status: ⬜ À FAIRE (Optionnel)

**Note**: Peut être fait après le démarrage d'Epic 1.

### 4.1 Fichiers de Rules

- ✅ `firestore.rules` (10,059 bytes)
- ✅ `storage.rules` (4,470 bytes)

### 4.2 Configuration Firebase CLI

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Authentification
firebase login

# Initialiser le projet
firebase init

# Ajouter les alias
firebase use --add
# Sélectionner: frigofute-dev
# Alias: dev
```

### 4.3 Déployer sur Staging

```bash
# Basculer sur staging
firebase use staging

# Déployer les rules
firebase deploy --only firestore:rules,storage
```

### Validation:

- ⬜ Rules Playground tests passed
- ⬜ User isolation works
- ⬜ Health consent validation works
- ⬜ File size limits enforced

**Complétion**: ⬜ / 100%

---

## 📊 Progression Globale

### Checklist Minimale (CRITIQUE pour Epic 1)

- [ ] Freezed corrigé (`flutter analyze` OK)
- [ ] Firebase projet dev créé
- [ ] Authentication activée (Email + Google)
- [ ] `firebase_options.dart` généré
- [ ] Tests passent (`flutter test` OK)

**5 items critiques** - Complétion: ⬜ 0%

### Checklist Complète (Optionnel)

- [ ] CI/CD testé localement
- [ ] Secrets GitHub configurés
- [ ] Security rules déployées
- [ ] Crashlytics configuré
- [ ] Remote Config 10 paramètres
- [ ] Quotas Firebase vérifiés

**6 items optionnels** - Complétion: ⬜ 0%

---

## 🚀 Quand Démarrer Epic 1?

### Conditions Minimales (CRITIQUES):

✅ **Checklist minimale 100% complète** (5 items)

### Conditions Recommandées:

✅ Checklist minimale 100%
✅ Firebase Console fully configured
✅ CI/CD basics verified

---

## 📚 Documentation Créée

### Guides Disponibles:

1. ✅ **docs/EPIC_1_PREPARATION_GUIDE.md** (Guide complet - 900+ lignes)
   - Instructions détaillées pour chaque étape
   - Troubleshooting complet
   - Tous les environnements (dev, staging, prod)

2. ✅ **docs/EPIC_1_QUICK_START.md** (Quick Start - 200 lignes)
   - Actions minimales pour démarrer
   - Checklist rapide
   - Dépannage express

3. ✅ **scripts/verify_epic1_readiness.sh** (Script de vérification Linux/Mac)
   - 8 catégories de checks
   - Output colorisé
   - Validation automatique

4. ✅ **scripts/verify_epic1_readiness.bat** (Script de vérification Windows)
   - Version Windows du script
   - Mêmes vérifications
   - Compatible PowerShell

### Documentation Epic 0:

1. ✅ **docs/EPIC_0_FINAL_REPORT.md** (1000+ lignes)
2. ✅ **docs/STORY_0.10_FINAL_REPORT.md** (750+ lignes)
3. ✅ **docs/DEPLOYMENT_CHECKLIST.md** (665 lignes)
4. ✅ **docs/SECURITY_BEST_PRACTICES.md** (670 lignes)

---

## 🛠️ Outils de Vérification

### Script de Vérification Rapide:

```bash
# Linux/Mac
./scripts/verify_epic1_readiness.sh

# Windows
scripts\verify_epic1_readiness.bat
```

### Vérification Manuelle:

```bash
# 1. Freezed
flutter analyze

# 2. Firebase
ls lib/firebase_options.dart

# 3. Tests
flutter test

# 4. Security Rules
ls firestore.rules storage.rules

# 5. CI/CD Workflows
ls .github/workflows/
```

---

## 📅 Timeline Estimée

| Activité | Durée | Quand |
|----------|-------|-------|
| **Préparation Epic 1** | 25-40 min | Aujourd'hui |
| - Freezed (critique) | 5 min | 🔴 Maintenant |
| - Firebase Console (critique) | 20 min | 🔴 Maintenant |
| - CI/CD (optionnel) | 10 min | 🟡 Plus tard |
| - Security Rules (optionnel) | 5 min | 🟡 Plus tard |
| **Story 1.1 Start** | - | Après checklist minimale |
| **Epic 1 Complete** | 8 semaines | - |

---

## ✅ Prochaine Action

### Immédiat (Aujourd'hui):

1. **Fermer tous les IDEs**
2. **Exécuter les commandes Freezed**:
   ```bash
   taskkill /F /IM dart.exe
   taskkill /F /IM flutter.exe
   cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter analyze
   ```

3. **Configurer Firebase Console** (20 min):
   - Créer projet `frigofute-dev`
   - Activer Authentication (Email + Google)
   - Activer Crashlytics
   - Configurer Remote Config (10 paramètres)
   - Générer `firebase_options.dart`

4. **Valider**:
   ```bash
   flutter analyze  # No issues
   flutter test     # All passing
   ```

5. **Démarrer Story 1.1**:
   ```bash
   git checkout -b epic-1/user-authentication
   ```

---

## 📞 Support

**En cas de blocage**:

1. Consulter `docs/EPIC_1_PREPARATION_GUIDE.md` (section troubleshooting)
2. Consulter `docs/EPIC_1_QUICK_START.md` (FAQ)
3. Exécuter le script de vérification pour identifier le problème

---

**Epic 0**: ✅ DONE (19,500 lignes, 316 tests, 78.5% coverage)
**Epic 1**: 🟡 PREPARATION IN PROGRESS

**Dernière mise à jour**: 2026-02-15 (auto-generated)
**Prochaine mise à jour**: Quand checklist minimale = 100%
