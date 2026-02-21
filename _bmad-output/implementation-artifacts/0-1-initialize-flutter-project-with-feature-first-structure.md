# Story 0.1: Initialize Flutter Project with Feature-First Structure

Status: done

## Story

En tant qu'utilisateur,
je veux que l'application soit correctement initialisée avec une fondation architecturale solide,
afin que je puisse bénéficier d'une application stable, performante et maintenable dès le premier jour.

## Acceptance Criteria

1. **Given** le projet doit être créé from scratch
2. **When** l'équipe de développement exécute la commande d'initialisation Flutter
3. **Then** le projet est créé avec l'organisation identifier "com.frigofute" et les plateformes iOS/Android
4. **And** la structure de répertoires Feature-First est configurée avec les placeholders pour les 14 modules
5. **And** le projet compile avec succès sans erreurs

## Tasks / Subtasks

- [x] Initialiser le projet Flutter avec org identifier com.frigofute (AC: #1, #2, #3)
  - [x] Exécuter `flutter create --org com.frigofute --platforms ios,android frigofute_v2`
  - [x] Vérifier que Flutter >= 3.32 (actuellement 3.32.6 stable)
  - [x] Vérifier que Dart >= 3.5+ (actuellement 3.8.1)

- [x] Créer la structure Feature-First complète (AC: #4)
  - [x] Créer les 8 couches transversales dans `lib/core/`
  - [x] Créer les placeholders pour les 14 modules dans `lib/features/`
  - [x] Créer la structure Clean Architecture (domain/data/presentation) pour chaque module
  - [x] Créer la structure Atomic Design dans `lib/core/shared/widgets/`

- [x] Configurer les fichiers de base (AC: #4)
  - [x] Configurer `pubspec.yaml` avec les dépendances de base
  - [x] Configurer `analysis_options.yaml` avec règles de linting strictes
  - [x] Configurer `.gitignore` pour exclure fichiers sensibles
  - [x] Créer templates `.env.example` pour variables d'environnement

- [x] Créer la structure de tests (AC: #5)
  - [x] Créer structure mirror dans `test/`
  - [x] Créer `test/test_helpers/` pour mocks et factories
  - [x] Créer `test/integration_test/` pour tests E2E

- [x] Configurer les assets (AC: #4)
  - [x] Créer structure `assets/{images,fonts,translations}/`
  - [x] Ajouter références assets dans `pubspec.yaml`

- [x] Vérifier la compilation (AC: #5)
  - [x] `flutter pub get` sans erreurs
  - [x] `flutter analyze` retourne 0 issues
  - [x] `flutter test` passe (1 test passed)
  - [x] `flutter build apk --debug` compile pour Android
  - [x] `flutter build ios` - Non testable sur Windows (nécessite macOS)

## Dev Notes

### 🎯 Objectif Critique de cette Story

Cette story est la **pierre angulaire absolue** du projet FrigoFuteV2. Elle établit la fondation architecturale qui sera utilisée pendant toute la durée du projet. Toutes les autres stories dépendent de celle-ci.

### 📋 Contexte Architectural

**Architecture choisie:** Feature-First + Clean Architecture

- **14 modules Feature-First** avec isolation stricte
- Chaque module suit Clean Architecture (domain/data/presentation)
- 6 modules GRATUITS, 8 modules PREMIUM (freemium à 4.99€/mois)
- Communication inter-features UNIQUEMENT via Riverpod providers et GoRouter

**Principes fondamentaux:**
- Isolation stricte des modules
- Dependency injection via Riverpod
- Offline-first architecture (Hive ↔ Firestore sync)
- Feature flags dynamiques (Firebase Remote Config)

### 🏗️ Les 14 Modules Feature-First

| # | Module | Type | Description |
|---|--------|------|-------------|
| 1 | `inventory` | ✅ GRATUIT | Gestion Inventaire CRUD |
| 2 | `ocr_scan` | ✅ GRATUIT | Scan OCR tickets + codes-barres |
| 3 | `notifications` | ✅ GRATUIT | Alertes péremption DLC/DDM |
| 4 | `dashboard` | ✅ GRATUIT | Dashboard métriques & impact |
| 5 | `auth_profile` | ✅ GRATUIT | Auth Firebase + Profil utilisateur |
| 6 | `recipes` | ✅ GRATUIT | Recettes & suggestions |
| 7 | `nutrition_tracking` | 💎 PREMIUM | Suivi alimentaire quotidien |
| 8 | `nutrition_profiles` | 💎 PREMIUM | 12 profils nutritionnels |
| 9 | `meal_planning` | 💎 PREMIUM | Planning repas IA (Gemini) |
| 10 | `ai_coach` | 💎 PREMIUM | Coach IA nutrition |
| 11 | `gamification` | 💎 PREMIUM | Badges, streaks, leaderboard |
| 12 | `shopping_list` | 💎 PREMIUM | Liste courses intelligente |
| 13 | `family_sharing` | 💎 PREMIUM | Partage famille, export PDF |
| 14 | `price_comparator` | 💎 PREMIUM | Comparateur prix 4+ enseignes |

### 🔧 Stack Technique & Versions

**Versions critiques (Février 2026):**
- Flutter: **3.41** (latest stable 2026, mais 3.32+ requis minimum)
- Dart: **3.5+**
- Material Design: **Material 3**
- Organisation ID: **com.frigofute**
- Plateformes: **iOS + Android**

**State Management:**
- **Riverpod 3.0** (latest) ou Riverpod 2.0 (stable recommandé)
  - Retry automatique pour Providers échoués
  - Support pause/resume pour providers
  - Mutations API pour writes (Login, Post Comment, etc.)
  - Compile-time safety vs Provider legacy

**Base de données:**
- **Hive Community Edition (hive_ce) v2.8.0** - Package original Hive non maintenu depuis 2+ ans
  - Local NoSQL lightweight
  - Offline-first
  - AES-256 encryption pour données santé

**Firebase:**
- **SDK v4.9.0** avec BoM (Bill of Materials) pour compatibilité
- Auth, Firestore, Functions, Storage, Remote Config, Crashlytics

### 📦 Packages à Ajouter

**Core Dependencies:**
```bash
# Firebase
flutter pub add firebase_core cloud_firestore firebase_auth firebase_storage firebase_remote_config firebase_crashlytics firebase_analytics firebase_performance

# State Management
flutter pub add flutter_riverpod  # ou riverpod_generator pour code gen

# Local Storage - IMPORTANT: Utiliser Hive Community Edition
flutter pub add hive_ce hive_ce_flutter

# Routing
flutter pub add go_router

# Networking
flutter pub add dio dio_retry_interceptor

# Functional Programming
flutter pub add dartz

# JSON Serialization
flutter pub add freezed_annotation json_annotation

# Utilities
flutter pub add intl timeago flutter_dotenv logger
```

**Dev Dependencies:**
```bash
flutter pub add --dev build_runner freezed json_serializable hive_ce_generator flutter_lints mockito mocktail
```

### 🚨 Conventions de Nommage STRICTES

**TOUS LES AGENTS IA DOIVENT IMPÉRATIVEMENT:**

#### Fichiers & Dossiers
```dart
// ✅ CORRECT: snake_case.dart
product_entity.dart
inventory_repository_impl.dart
add_product_usecase.dart

// ❌ INTERDIT: PascalCase
ProductEntity.dart
InventoryRepositoryImpl.dart
```

#### Classes, Variables, Constantes
```dart
// ✅ Classes: UpperCamelCase
class ProductEntity {}
class InventoryRepositoryImpl {}

// ✅ Variables, fonctions: lowerCamelCase
final String productName;
void addProduct(Product product) {}

// ✅ Constantes: lowerCamelCase (convention Dart)
const int maxProductsPerUser = 1000;

// ✅ Privé: préfixe _
final String _privateField;
void _privateMethod() {}
```

#### JSON & Firestore - TOUJOURS camelCase
```json
{
  "userId": "123",
  "productName": "Lait",
  "expirationDate": "2026-02-20T00:00:00Z"
}

// ❌ JAMAIS snake_case dans JSON
```

### ⚠️ Anti-Patterns à ÉVITER ABSOLUMENT

#### ❌ Structure Incorrecte
```dart
// ❌ INTERDIT: Feature dans core/
lib/core/inventory/

// ❌ INTERDIT: Domain dépend de data
// Dans domain/entities/product_entity.dart:
import '../../data/models/product_model.dart';  // INTERDIT

// ✅ CORRECT: Domain est pure, data dépend de domain
// Dans data/models/product_model.dart:
import '../../domain/entities/product_entity.dart';  // OK
```

#### ❌ State Management Riverpod Incorrect
```dart
// ❌ INTERDIT: Mutation directe state
class InventoryNotifier extends StateNotifier<List<Product>> {
  void addProduct(Product p) {
    state.add(p);  // ❌ INTERDIT - mutation directe
  }
}

// ✅ CORRECT: Immutabilité stricte
class InventoryNotifier extends StateNotifier<List<Product>> {
  void addProduct(Product p) {
    state = [...state, p];  // ✅ Nouvelle liste
  }
}
```

#### ❌ Performance Flutter
```dart
// ❌ LENT: ListView sans builder (grandes listes)
ListView(children: products.map(...).toList())

// ✅ RAPIDE: ListView.builder pour >50 items
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) => ProductCard(products[index])
)
```

### 🎯 Patterns OBLIGATOIRES

1. ✅ **Feature-First structure stricte** - Pas de mélange features/core
2. ✅ **Fichiers snake_case.dart** - Classes UpperCamelCase
3. ✅ **Tests mirror lib/** avec suffix `_test.dart`
4. ✅ **Riverpod state IMMUTABLE** - Jamais muter `state` directement
5. ✅ **JSON camelCase** - Jamais snake_case
6. ✅ **Dates ISO 8601** en JSON
7. ✅ **Exception hierarchy custom** - Pas de `throw Exception("...")`
8. ✅ **AsyncValue<T>** pour async data (FutureProvider, StreamProvider)
9. ✅ **Either<Error, Success>** pour repositories (package dartz)
10. ✅ **Analytics events snake_case** - Cohérence Firebase
11. ✅ **Retry exponential backoff** pour APIs externes
12. ✅ **Circuit breaker** pour quotas APIs (Google Vision, Gemini)
13. ✅ **Messages erreur FR** pour utilisateurs finaux
14. ✅ **Structured logging JSON** pour monitoring
15. ✅ **Hive Community Edition** (hive_ce) - Pas le package Hive original non maintenu

### 🔐 Sécurité & Compliance

**RGPD Article 9 - Données Santé:**
- Données nutrition = données santé sensibles
- Encryption AES-256 obligatoire pour Hive boxes nutrition
- Double opt-in avant activation module nutrition
- Droit retrait <30j

**Configuration .gitignore CRITIQUE:**
```gitignore
# ❌ NE JAMAIS COMMITER:
.env.dev
.env.staging
.env.prod
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

### 📊 Quality Gates CI/CD

```yaml
# .github/workflows/pr_checks.yml (à créer plus tard)
- flutter analyze          # 0 issues requis
- flutter test --coverage  # ≥75% coverage requis
- dart format --set-exit-if-changed
```

**Merge bloqué si:**
- Linting errors > 0
- Code coverage < 75%
- Formatting incorrect

### 📚 Références Techniques Récentes (2026)

**Flutter:**
- [Flutter 3.41 Latest Features](https://blog.flutter.dev/whats-new-in-flutter-3-41-302ec140e632)
- [Flutter 3.32 Release Notes](https://blog.flutter.dev/whats-new-in-flutter-3-32-40c1086bab6e)
- [State of Flutter 2026](https://devnewsletter.com/p/state-of-flutter-2026/)

**Riverpod:**
- [Riverpod 3.0 Major Redesign](https://medium.com/@lee645521797/flutter-riverpod-3-0-released-a-major-redesign-of-the-state-management-framework-f7e31f19b179)
- [Best Flutter State Management 2026](https://foresightmobile.com/blog/best-flutter-state-management)
- [Riverpod Official Docs](https://riverpod.dev/)

**Firebase:**
- [Firebase Flutter SDK Release Notes](https://firebase.google.com/support/release-notes/flutter)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)

**Hive:**
- [Hive Community Edition Setup](https://github.com/isar/hive)
- [Flutter Hive Tutorial 2026](https://www.dhiwise.com/post/flutter-hive-tutorial%E2%80%93setting-up-and-using-local-data-in-flutter)

### Project Structure Notes

**Arborescence complète à créer:**

```
frigofute_v2/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── auth/
│   │   ├── data_sync/
│   │   ├── networking/
│   │   ├── storage/
│   │   ├── feature_flags/
│   │   ├── monitoring/
│   │   ├── compliance/
│   │   ├── routing/
│   │   ├── theme/
│   │   └── shared/
│   │       ├── utils/
│   │       ├── extensions/
│   │       ├── constants/
│   │       ├── exceptions/
│   │       └── widgets/
│   │           ├── atoms/
│   │           ├── molecules/
│   │           └── organisms/
│   └── features/
│       ├── inventory/
│       │   ├── domain/{entities,repositories,usecases}/
│       │   ├── data/{models,datasources,repositories}/
│       │   └── presentation/{providers,screens,widgets}/
│       ├── ocr_scan/
│       ├── notifications/
│       ├── dashboard/
│       ├── auth_profile/
│       ├── recipes/
│       ├── nutrition_tracking/
│       ├── nutrition_profiles/
│       ├── meal_planning/
│       ├── ai_coach/
│       ├── gamification/
│       ├── shopping_list/
│       ├── family_sharing/
│       └── price_comparator/
├── test/ (mirror structure)
├── assets/
│   ├── images/
│   ├── fonts/
│   └── translations/
├── android/
├── ios/
└── pubspec.yaml
```

**Script automatisation création structure:**
```bash
# Créer lib/core/
mkdir -p lib/core/{auth,data_sync,networking,storage,feature_flags,monitoring,compliance,routing,theme,shared}
mkdir -p lib/core/shared/{utils,extensions,constants,exceptions,widgets/{atoms,molecules,organisms}}

# Créer 14 features/
for feature in inventory ocr_scan notifications dashboard auth_profile recipes nutrition_tracking nutrition_profiles meal_planning ai_coach gamification shopping_list family_sharing price_comparator; do
  mkdir -p lib/features/$feature/{domain/{entities,repositories,usecases},data/{models,datasources,repositories},presentation/{providers,screens,widgets}}
done

# Tests mirror
mkdir -p test/{core,features,integration_test,test_helpers}

# Assets
mkdir -p assets/{images/{onboarding,icons,illustrations},fonts,translations}
```

### Références Sources Documentation

**[Source: epics.md, lignes 621-633]** - Story 0.1 détaillée avec Acceptance Criteria

**[Source: architecture.md, lignes 267-286]** - Décision Setup Manuel Feature-First Custom

**[Source: architecture.md, lignes 1430-1820]** - Structure projet complète (arborescence 257 lignes)

**[Source: architecture.md, lignes 1838-1855]** - Mapping 14 modules fonctionnels

**[Source: architecture.md, lignes 2617-2648]** - Packages dependencies détaillés

**[Source: architecture.md, lignes 686-781, 1282-1299]** - Conventions nommage strictes

**[Source: architecture.md, lignes 1399-1428]** - Anti-patterns à éviter

**[Source: prd.md, lignes 141-178]** - Success criteria techniques (coverage 75%, NFRs)

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)

### Debug Log References

N/A - Première story du projet

### Completion Notes List

**Story 0.1 - Initialisation Complète - 2026-02-14**

✅ **Projet Flutter initialisé avec succès**
- Organisation ID: com.frigofute
- Package name: frigofute_v2
- Plateformes: iOS + Android
- Flutter 3.32.6, Dart 3.8.1

✅ **Structure Feature-First créée**
- 10 couches core/ (auth, data_sync, networking, storage, feature_flags, monitoring, compliance, routing, theme, shared)
- 14 modules features/ avec Clean Architecture complète
- Atomic Design: widgets/{atoms,molecules,organisms}

✅ **Dépendances installées** (99 packages)
- Firebase suite (core, auth, firestore, storage, analytics, crashlytics, performance, remote_config)
- Riverpod 2.6.1 (state management)
- Hive Community Edition 2.8.0 (local storage)
- GoRouter 17.0.0 (routing)
- Dio 5.9.1 + retry (networking)
- Dartz, Freezed, JSON serialization
- Testing: mockito, mocktail

✅ **Configuration stricte**
- analysis_options.yaml: Linting strict (prefer_const, prefer_final, no implicit casts/dynamic)
- .gitignore: Exclusions critiques (.env, Firebase config)
- .env.example + .env.dev/staging/prod créés

✅ **Compilation validée**
- flutter analyze: No issues found
- flutter test: All tests passed (1/1)
- flutter build apk: Success (build\app\outputs\flutter-apk\app-debug.apk)
- Android: minSdk 23, NDK 27.0.12077973 (requis Firebase)

⚠️ **Note iOS**: Compilation iOS non testée (Windows). À valider sur macOS.

---

**Story 0.1 - Code Review Fixes - 2026-02-14**

🔥 **Revue adversariale complétée** - 11 problèmes HIGH/MEDIUM corrigés

✅ **Corrections CRITIQUES appliquées:**
1. **Architecture documentée** - Ajouté README.md dans lib/core/, lib/features/, test/ pour expliquer la structure
2. **main.dart complètement réécrit** - Intégration Riverpod (ProviderScope), dotenv loading, Material 3 theme, placeholder screen professionnel
3. **Assets créés** - Structure assets/{images,fonts,translations}/ avec .gitkeep pour tracking git
4. **SÉCURITÉ FIX** - Retiré .env.* des assets pubspec.yaml (vulnérabilité critique)
5. **Tests améliorés** - Réécrit widget_test.dart avec 3 vrais tests (app init, placeholder, Material 3)

✅ **Corrections MOYENNES appliquées:**
6. **Package ajouté** - dio_smart_retry pour retry automatique (remplace dio_retry_interceptor)
7. **pubspec.yaml customisé** - Description professionnelle "FrigoFute V2 - Anti-gaspillage alimentaire intelligent"
8. **Configuration Riverpod** - ProviderScope wrapping MaterialApp dans main.dart
9. **Dotenv configuré** - Loading .env.dev au démarrage
10. **Material 3 activé** - Theme avec seed color green (#4CAF50), support dark mode
11. **Code nettoyé** - Supprimé imports inutilisés, corrigé deprecated APIs (withOpacity → withValues)

✅ **Validation finale:**
- flutter analyze: **No issues found!** ✅
- flutter test: **All tests passed! (3/3)** ✅
- Architecture documentée et fonctionnelle
- Sécurité: .env non exposés dans build
- Prêt pour Story 0.2 (Firebase config)

### File List

**Configuration:**
- pubspec.yaml (customisé: description, dio_smart_retry ajouté, .env retirés des assets)
- analysis_options.yaml (linting strict)
- .gitignore
- .env.example
- .env.dev
- .env.staging
- .env.prod

**Android:**
- android/app/build.gradle.kts (minSdk 23, NDK 27.0.12077973)

**Application:**
- lib/main.dart (✅ Réécrit: Riverpod ProviderScope, dotenv, Material 3, placeholder screen)
- lib/core/README.md (documentation architecture core)
- lib/features/README.md (documentation 14 modules)
- lib/features/inventory/README.md (exemple module)
- lib/features/auth_profile/README.md (exemple module)
- lib/core/{auth,data_sync,networking,storage,feature_flags,monitoring,compliance,routing,theme}/ (dossiers)
- lib/core/shared/{utils,extensions,constants,exceptions,widgets/{atoms,molecules,organisms}}/ (dossiers)
- lib/features/{inventory,ocr_scan,notifications,dashboard,auth_profile,recipes,nutrition_tracking,nutrition_profiles,meal_planning,ai_coach,gamification,shopping_list,family_sharing,price_comparator}/ (dossiers avec structure domain/data/presentation)

**Tests:**
- test/README.md (documentation stratégie de tests)
- test/widget_test.dart (✅ Réécrit: 3 tests - app init, placeholder, Material 3)
- test/{core,features,integration_test,test_helpers}/ (dossiers)

**Assets:**
- assets/images/onboarding/.gitkeep
- assets/images/icons/.gitkeep
- assets/images/illustrations/.gitkeep
- assets/fonts/.gitkeep
- assets/translations/.gitkeep

---

**Sources:**
- [Flutter 3.41 Latest Features](https://blog.flutter.dev/whats-new-in-flutter-3-41-302ec140e632)
- [Flutter 3.32 Release Notes](https://blog.flutter.dev/whats-new-in-flutter-3-32-40c1086bab6e)
- [State of Flutter 2026](https://devnewsletter.com/p/state-of-flutter-2026/)
- [Riverpod 3.0 Major Redesign](https://medium.com/@lee645521797/flutter-riverpod-3-0-released-a-major-redesign-of-the-state-management-framework-f7e31f19b179)
- [Best Flutter State Management 2026](https://foresightmobile.com/blog/best-flutter-state-management)
- [Firebase Flutter SDK Release Notes](https://firebase.google.com/support/release-notes/flutter)
- [Hive Flutter Tutorial](https://www.dhiwise.com/post/flutter-hive-tutorial%E2%80%93setting-up-and-using-local-data-in-flutter)
