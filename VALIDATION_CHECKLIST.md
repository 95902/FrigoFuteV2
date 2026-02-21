# ✅ Checklist de Validation Epic 0

**Date de début**: 2026-02-15
**Objectif**: Valider Epic 0 avant de démarrer Epic 1
**Temps estimé**: 25-30 minutes

---

## 🔴 CRITIQUE - À Faire Maintenant

### 1. Corriger Freezed Code Generation (5 min)

- [ ] **Étape 1**: Fermer tous les IDEs
  - [ ] Fermer VS Code
  - [ ] Fermer Cursor
  - [ ] Fermer Android Studio
  - [ ] Fermer IntelliJ IDEA

- [ ] **Étape 2**: Terminer les processus Flutter (PowerShell Admin)
  ```powershell
  taskkill /F /IM dart.exe
  taskkill /F /IM flutter.exe
  ```

- [ ] **Étape 3**: Nettoyer le cache build_runner
  ```bash
  cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2
  flutter pub run build_runner clean
  ```

- [ ] **Étape 4**: Régénérer les fichiers Freezed
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- [ ] **Étape 5**: Vérifier l'analyseur
  ```bash
  flutter analyze
  ```
  **Résultat attendu**: `No issues found!` ✅

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

### 2. Configuration Firebase Console (20 min)

#### 2.1 Créer le Projet Firebase

- [ ] Accéder à https://console.firebase.google.com/
- [ ] Cliquer "Ajouter un projet"
- [ ] Nom du projet: `FrigoFute Development`
- [ ] Project ID suggéré: `frigofute-dev`
- [ ] Accepter les conditions
- [ ] Activer Google Analytics: **OUI** ✅
- [ ] Compte Analytics: Créer nouveau ou sélectionner existant
- [ ] Créer le projet (attendre 30 secondes)

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

#### 2.2 Activer Authentication

- [ ] Dans le projet, menu latéral → **Authentication**
- [ ] Cliquer **"Get started"** / "Commencer"
- [ ] Onglet **"Sign-in method"** / "Méthode de connexion"

**Email/Password**:
- [ ] Cliquer sur "Email/Password"
- [ ] Toggle **"Enable"** / "Activer"
- [ ] Email link (passwordless): **LAISSER DÉSACTIVÉ**
- [ ] Cliquer **"Save"** / "Enregistrer"

**Google Sign-In**:
- [ ] Cliquer sur "Google"
- [ ] Toggle **"Enable"** / "Activer"
- [ ] Email d'assistance: `support@frigofute.com` (ou votre email)
- [ ] Cliquer **"Save"** / "Enregistrer"

**Télécharger les fichiers de config**:
- [ ] Onglet "Settings" / "Paramètres" du projet (icône engrenage en haut)
- [ ] Descendre à "Vos applications" / "Your apps"
- [ ] Ajouter une app Android (icône robot Android)
  - [ ] Package name: `com.frigofute.frigofute_v2`
  - [ ] Télécharger `google-services.json`
  - [ ] Remplacer `android/app/google-services.json`
- [ ] Ajouter une app iOS (icône Apple)
  - [ ] Bundle ID: `com.frigofute.frigofuteV2`
  - [ ] Télécharger `GoogleService-Info.plist`
  - [ ] Remplacer `ios/Runner/GoogleService-Info.plist`

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

#### 2.3 Activer Crashlytics

- [ ] Menu latéral → **"Release & Monitor"** → **"Crashlytics"**
- [ ] Cliquer **"Get started"** / "Commencer"
- [ ] Suivre l'assistant (le SDK est déjà configuré dans le code)
- [ ] Android: Vérifier que `google-services.json` est présent
- [ ] iOS: Vérifier que `GoogleService-Info.plist` est présent
- [ ] Terminer l'assistant

**Test** (optionnel - après premier lancement):
```dart
FirebaseCrashlytics.instance.crash(); // Force un crash test
```

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

#### 2.4 Configurer Remote Config

- [ ] Menu latéral → **"Engage"** → **"Remote Config"**
- [ ] Cliquer **"Create configuration"** / "Créer une configuration"

**Créer les 10 paramètres** (cliquer "Add parameter" pour chaque):

**1. enable_beta_features**
- [ ] Parameter key: `enable_beta_features`
- [ ] Default value: Type = **Boolean**, Value = `true`
- [ ] Description: "Enable beta features"

**2. enable_meal_planning**
- [ ] Parameter key: `enable_meal_planning`
- [ ] Default value: Type = **Boolean**, Value = `false`
- [ ] Description: "Enable meal planning feature (Epic 9)"

**3. enable_ai_nutrition_coach**
- [ ] Parameter key: `enable_ai_nutrition_coach`
- [ ] Default value: Type = **Boolean**, Value = `false`
- [ ] Description: "Enable AI nutrition coach (Epic 11)"

**4. enable_price_comparison**
- [ ] Parameter key: `enable_price_comparison`
- [ ] Default value: Type = **Boolean**, Value = `false`
- [ ] Description: "Enable price comparison (Epic 12)"

**5. enable_gamification**
- [ ] Parameter key: `enable_gamification`
- [ ] Default value: Type = **Boolean**, Value = `false`
- [ ] Description: "Enable gamification features (Epic 13)"

**6. max_free_ocr_scans**
- [ ] Parameter key: `max_free_ocr_scans`
- [ ] Default value: Type = **Number**, Value = `10`
- [ ] Description: "Max OCR scans for free users"

**7. max_premium_ocr_scans**
- [ ] Parameter key: `max_premium_ocr_scans`
- [ ] Default value: Type = **Number**, Value = `1000`
- [ ] Description: "Max OCR scans for premium users"

**8. gemini_rate_limit_seconds**
- [ ] Parameter key: `gemini_rate_limit_seconds`
- [ ] Default value: Type = **Number**, Value = `2`
- [ ] Description: "Minimum seconds between Gemini API calls"

**9. vision_api_monthly_quota**
- [ ] Parameter key: `vision_api_monthly_quota`
- [ ] Default value: Type = **Number**, Value = `1000`
- [ ] Description: "Monthly quota for Vision API calls"

**10. enable_offline_mode**
- [ ] Parameter key: `enable_offline_mode`
- [ ] Default value: Type = **Boolean**, Value = `true`
- [ ] Description: "Enable offline-first mode"

**Publier la configuration**:
- [ ] Cliquer **"Publish changes"** / "Publier les modifications"
- [ ] Message de commit: "Initial Remote Config setup for Epic 0"
- [ ] Confirmer

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

#### 2.5 Générer firebase_options.dart

**Installer FlutterFire CLI**:
- [ ] Ouvrir un terminal
- [ ] Exécuter:
  ```bash
  dart pub global activate flutterfire_cli
  ```
- [ ] Attendre la fin de l'installation

**Générer la configuration**:
- [ ] Dans le terminal, aller au dossier du projet:
  ```bash
  cd C:\Users\Marcel\Documents\Cursor\FrigoFuteV2
  ```
- [ ] Exécuter:
  ```bash
  flutterfire configure --project=frigofute-dev
  ```
- [ ] Sélectionner les plateformes: **Android** et **iOS** (avec espace pour cocher)
- [ ] Confirmer
- [ ] Attendre la génération

**Vérifier**:
- [ ] Fichier créé: `lib/firebase_options.dart`
- [ ] Ouvrir le fichier et vérifier qu'il contient les configs Android et iOS

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

#### 2.6 Vérifier les Quotas Firebase

- [ ] Menu → **"Usage and billing"** / "Utilisation et facturation"
- [ ] Vérifier les quotas Spark (gratuits):
  - [ ] **Firestore**: 50,000 reads/day
  - [ ] **Storage**: 5 GB
  - [ ] **Authentication**: Unlimited
  - [ ] **Crashlytics**: Unlimited
  - [ ] **Remote Config**: Unlimited

**Configurer des alertes** (optionnel):
- [ ] Configurer alerte à 80% du quota
- [ ] Configurer alerte à 90% du quota

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

## ✅ Validation Finale

### Tests de Validation

- [ ] **Test 1: Flutter Analyze**
  ```bash
  flutter analyze
  ```
  Résultat: `No issues found!` ✅

- [ ] **Test 2: Tests Unitaires**
  ```bash
  flutter test
  ```
  Résultat: `All tests passed!` (316/316) ✅

- [ ] **Test 3: Firebase Options**
  ```bash
  cat lib/firebase_options.dart
  ```
  Résultat: Fichier existe et contient les configs ✅

- [ ] **Test 4: Compilation Android**
  ```bash
  flutter build apk --debug
  ```
  Résultat: Build successful ✅

- [ ] **Test 5: Compilation iOS** (sur Mac uniquement)
  ```bash
  flutter build ios --debug --no-codesign
  ```
  Résultat: Build successful ✅

- [ ] **Test 6: Lancement App**
  ```bash
  flutter run
  ```
  Résultat: App démarre sans erreur Firebase ✅

---

### Script de Vérification Automatique

- [ ] **Exécuter le script de vérification**:
  ```bash
  # Linux/Mac
  ./scripts/verify_epic1_readiness.sh

  # Windows
  scripts\verify_epic1_readiness.bat
  ```

**Résultat attendu**:
```
✅ Passed:    XX/XX checks
❌ Failed:    0
⚠️  Warnings: 0

🎉 READY FOR EPIC 1!
```

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

## 🟡 OPTIONNEL - Post Epic 1

### 3. Vérification CI/CD (10 min)

- [ ] Installer `act` pour tests locaux
  ```bash
  choco install act-cli
  ```

- [ ] Tester PR Checks workflow
  ```bash
  act pull_request -W .github/workflows/pr_checks.yml
  ```

- [ ] Tester Security Checks workflow
  ```bash
  act pull_request -W .github/workflows/security_checks.yml
  ```

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

### 4. Déployer Security Rules - Staging (5 min)

- [ ] Installer Firebase CLI
  ```bash
  npm install -g firebase-tools
  ```

- [ ] Authentification
  ```bash
  firebase login
  ```

- [ ] Initialiser Firebase (si pas déjà fait)
  ```bash
  firebase init
  ```
  Sélectionner: Firestore, Storage

- [ ] Ajouter alias staging
  ```bash
  firebase use --add
  ```
  Sélectionner projet staging, alias: `staging`

- [ ] Déployer les rules
  ```bash
  firebase use staging
  firebase deploy --only firestore:rules,storage
  ```

**Status**: ⬜ Non commencé | ⏳ En cours | ✅ Complété

---

## 📊 Progression Globale

### Checklist Minimale (CRITIQUE)

| Tâche | Status | Durée |
|-------|--------|-------|
| 1. Freezed Code Generation | ⬜ | 5 min |
| 2. Firebase Console Config | ⬜ | 20 min |
| **TOTAL CRITIQUE** | **0%** | **25 min** |

### Checklist Complète (avec optionnel)

| Tâche | Status | Durée |
|-------|--------|-------|
| 1. Freezed | ⬜ | 5 min |
| 2. Firebase | ⬜ | 20 min |
| 3. CI/CD | ⬜ | 10 min |
| 4. Security Rules | ⬜ | 5 min |
| **TOTAL COMPLET** | **0%** | **40 min** |

---

## 🚀 Prêt pour Epic 1?

### Conditions Minimales (CRITIQUES):

- [ ] Freezed: `flutter analyze` = No issues
- [ ] Firebase: Projet dev créé et configuré
- [ ] Authentication: Email/Password + Google activés
- [ ] firebase_options.dart: Généré et valide
- [ ] Tests: 316/316 passing

**Quand ces 5 items sont ✅, vous pouvez démarrer Epic 1!**

---

## 📅 Timeline

- **Début**: 2026-02-15 (aujourd'hui)
- **Fin prévue**: 2026-02-15 (même jour, 25-40 min de travail)
- **Epic 1 start**: Immédiatement après validation

---

## 🎯 Prochaine Action Immédiate

1. ⬜ Fermer tous les IDEs
2. ⬜ Exécuter les commandes Freezed
3. ⬜ Configurer Firebase Console (20 min)
4. ⬜ Valider avec le script de vérification
5. ⬜ Créer branche `epic-1/user-authentication`
6. ⬜ Démarrer Story 1.1

---

**Dernière mise à jour**: 2026-02-15
**Prochaine mise à jour**: Après chaque tâche complétée
**Complétion**: ⬜ 0% → Objectif: ✅ 100%
