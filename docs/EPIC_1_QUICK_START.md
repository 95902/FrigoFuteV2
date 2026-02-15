# Epic 1 - Quick Start Guide

**🚀 Démarrage Rapide - User Authentication & Profile Management**

---

## ✅ Actions Requises AVANT Epic 1

### 🔧 1. Corriger Freezed (5 min)

**Problème**: Le SDK Flutter est verrouillé par un processus.

**Solution Rapide**:

```bash
# Étape 1: Fermer TOUS les éditeurs (VS Code, Cursor, Android Studio)

# Étape 2: Terminer les processus Flutter (PowerShell Admin)
taskkill /F /IM dart.exe
taskkill /F /IM flutter.exe

# Étape 3: Régénérer Freezed
cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze

# Résultat attendu: "No issues found!"
```

**Alternative**: Redémarrez l'ordinateur et exécutez immédiatement les commandes ci-dessus.

---

### 🔥 2. Configuration Firebase Console (15-20 min)

**CRITIQUE pour Epic 1**: Authentication ne fonctionnera pas sans cette configuration.

#### Accès: https://console.firebase.google.com/

#### Actions Minimales (Development uniquement pour commencer):

1. **Créer Projet Firebase**:
   - Nom: `FrigoFute Development`
   - ID: `frigofute-dev`
   - Plan: Spark (gratuit)

2. **Activer Authentication**:
   - Menu → Authentication → Get Started
   - Email/Password → **Enable** ✅
   - Google Sign-In → **Enable** ✅
   - Télécharger les nouveaux fichiers de config

3. **Activer Crashlytics**:
   - Menu → Crashlytics → Get Started
   - Suivre l'assistant

4. **Configurer Remote Config**:
   - Menu → Remote Config
   - Créer 2 paramètres minimum:
     - `enable_beta_features` = `true` (Boolean)
     - `gemini_rate_limit_seconds` = `2` (Number)

5. **Générer les fichiers de configuration**:
   ```bash
   # Installer FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Générer firebase_options.dart
   flutterfire configure --project=frigofute-dev
   ```

**Status**: ⬜ À compléter AVANT de démarrer Story 1.1

---

### 🔐 3. Vérification CI/CD (Optionnel - 10 min)

**Peut être fait après** le démarrage d'Epic 1.

```bash
# Vérifier que les workflows existent
ls .github/workflows/

# Tester localement (si act installé)
act pull_request -W .github/workflows/pr_checks.yml
```

**Secrets GitHub**: Configuration requise avant le premier déploiement, pas pour le développement local.

---

### 📜 4. Security Rules (Optionnel - 5 min)

**Peut être fait après** le démarrage d'Epic 1.

```bash
# Déployer sur staging uniquement
firebase use staging
firebase deploy --only firestore:rules,storage
```

---

## 🎯 Validation Minimale

**Avant de commencer Story 1.1**, vérifiez:

```bash
# Vérification rapide (2 min)
cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2

# 1. Freezed OK?
flutter analyze
# ✅ Attendu: "No issues found!"

# 2. Firebase configuré?
ls lib/firebase_options.dart
# ✅ Attendu: Le fichier existe

# 3. Tests passent?
flutter test
# ✅ Attendu: All tests passing (316 tests)
```

---

## 🚀 Démarrer Epic 1

Une fois les **étapes 1 et 2** complétées:

```bash
# Créer la branche Epic 1
git checkout -b epic-1/user-authentication

# Commencer Story 1.1
# Story: Create Account with Email and Password

# Lire la story
cat _bmad-output/implementation-artifacts/1-1-create-account-with-email-and-password.md
```

---

## 📊 Checklist Minimale (CRITIQUE)

- [ ] **Freezed corrigé** (`flutter analyze` = No issues)
- [ ] **Firebase projet créé** (frigofute-dev)
- [ ] **Authentication activée** (Email/Password + Google)
- [ ] **firebase_options.dart généré**
- [ ] **Tests passent** (`flutter test` = OK)

**Une fois ces 5 items ✅, vous pouvez démarrer Story 1.1.**

---

## 📚 Documentation Complète

Pour des instructions détaillées:

- **Guide complet**: `docs/EPIC_1_PREPARATION_GUIDE.md` (27 pages)
- **Checklist déploiement**: `docs/DEPLOYMENT_CHECKLIST.md`
- **Rapport Epic 0**: `docs/EPIC_0_FINAL_REPORT.md`

---

## 🆘 En Cas de Problème

### Freezed ne se régénère pas

```bash
# Solution nucléaire
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firebase Authentication ne fonctionne pas

1. Vérifier que Authentication est activée dans la console
2. Vérifier que `firebase_options.dart` existe
3. Vérifier que `google-services.json` et `GoogleService-Info.plist` sont à jour
4. Régénérer les fichiers: `flutterfire configure --project=frigofute-dev`

### Tests échouent

```bash
# Voir les tests en échec
flutter test --reporter expanded

# Exécuter un test spécifique
flutter test test/path/to/test_file.dart
```

---

## ⏱️ Temps Estimé Total

| Tâche | Temps | Priorité |
|-------|-------|----------|
| Corriger Freezed | 5 min | 🔴 CRITIQUE |
| Firebase Console | 15-20 min | 🔴 CRITIQUE |
| Vérification CI/CD | 10 min | 🟡 Optionnel |
| Security Rules | 5 min | 🟡 Optionnel |

**Total minimum**: **20-25 minutes** avant de pouvoir démarrer Epic 1.

---

## 🎉 C'est Parti !

Une fois la checklist minimale complétée:

```bash
git checkout -b epic-1/user-authentication
# Ready for Story 1.1: Create Account with Email and Password
```

**Epic 0**: ✅ DONE (19,500 lignes, 316 tests, 78.5% coverage)
**Epic 1**: 🚀 READY TO START (10 stories, ~8 semaines estimées)

---

**Dernière mise à jour**: 2026-02-15
**Version**: 1.0
**Status**: 🟡 Préparation en cours
