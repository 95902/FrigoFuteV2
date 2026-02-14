---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - "_bmad-output/planning-artifacts/prd-original.md"
  - "_bmad-output/planning-artifacts/prd.md"
  - "_bmad-output/planning-artifacts/ux-design-specification.md"
  - "_bmad-output/planning-artifacts/research/technical-FrigoFuteV2-Complete-Stack-research-2026-02-13.md"
workflowType: 'architecture'
lastStep: 8
status: 'complete'
completedAt: '2026-02-14'
project_name: 'FrigoFuteV2'
user_name: 'Marcel'
date: '2026-02-14'
---

# Architecture Decision Document

_Ce document se construit de manière collaborative à travers une découverte étape par étape. Les sections sont ajoutées au fur et à mesure que nous travaillons ensemble sur chaque décision architecturale._

## Analyse du Contexte Projet

### Vue d'Ensemble des Exigences

**Exigences Fonctionnelles :**

FrigoFuteV2 comprend **85 exigences fonctionnelles** organisées en 14 domaines :

1. **Gestion Inventaire Alimentaire (10 FRs)** : CRUD complet produits, catégorisation automatique (12 catégories), 6 emplacements, états produits (frais/péremption/consommé), filtres multi-critères

2. **Acquisition Données Produits (5 FRs)** : Scan OCR tickets français, reconnaissance codes-barres EAN-13, enrichissement nutritionnel OpenFoodFacts, correction manuelle, confiance reconnaissance

3. **Alertes & Notifications Intelligentes (6 FRs)** : Notifications péremption DLC/DDM différenciées, configuration délais, quiet hours, suggestions recettes contextuelles

4. **Découverte Recettes & Suggestions (6 FRs)** : Matching inventaire temps réel, filtres multi-critères (budget/temps/difficulté/régime), tutoriels intégrés, favoris, adaptation profil nutritionnel

5. **Planning Repas & Génération IA (6 FRs)** : Génération hebdomadaire automatique via IA, contraintes nutritionnelles (macros/calories), optimisation anti-gaspi stock existant, batch cooking, modification manuelle, liste courses auto-générée

6. **Suivi Nutritionnel & Coach IA (8 FRs)** : 12 profils prédéfinis, calcul TDEE/BMR automatique, tracking calories/macros quotidien, reconnaissance photo repas Gemini Vision, conseils contextuels temps réel, historique, dashboard nutrition, chatbot IA

7. **Comparateur Prix & Optimisation (6 FRs)** : Comparaison 4+ enseignes, économies potentielles affichées, carte interactive magasins, parcours multi-magasins optimisé, export liste, source/date MAJ visible

8. **Dashboard Métriques & Impact (6 FRs)** : Gaspillage évité (kg/€), économies réalisées, impact CO2eq, graphiques évolution, stats nutrition agrégées

9. **Gamification & Engagement (5 FRs)** : Achievements/badges anti-gaspi, streaks activité, leaderboard amis opt-in, défis personnalisés, partage social

10. **Authentification & Profil (6 FRs)** : Auth sécurisée (email/OAuth), profil personnel, préférences alimentaires/allergies, sync multi-devices, export données RGPD, suppression compte

11. **Partage & Collaboration (4 FRs)** : Inventaire partagé famille/colocation, partage recettes/plannings, export PDF, liste courses temps réel multi-users

12. **Conformité RGPD & Sécurité (7 FRs)** : Disclaimers nutrition/prix/péremption, double opt-in données santé, retrait consentement <30j, encryption at-rest/in-transit, gestion consentements granulaires

13. **Accessibilité & UX (5 FRs)** : Onboarding adaptatif par profil, tutoriels interactifs, aide contextuelle tooltips, mode senior (boutons larges/texte agrandi), offline-first 100%

14. **Modèle Freemium (5 FRs)** : 6 modules gratuits, Premium 4.99€/mois (14 modules), essai 7j gratuit, annulation 3 clics, tableau comparatif transparent

**Exigences Non-Fonctionnelles Critiques :**

**Performance (7 NFRs) :**
- Scan OCR tickets <2s (95e percentile)
- App launch <3s cold start, <1s warm start
- Réactivité UI <100ms feedback visuel
- Scan code-barres <500ms
- Offline-first sans dégradation performance
- Génération planning IA <10s
- Reconnaissance photo repas Gemini <15s

**Sécurité (6 NFRs) :**
- Encryption AES-256 at-rest + TLS 1.3+ in-transit (données santé)
- Auth Firebase + OAuth2 + 2FA pour premium
- API keys stockées serveur, rotation 90j
- Double opt-in données santé RGPD Article 9
- Droit à l'oubli <30j
- Sanitization entrées (anti SQL/XSS injection)

**Scalabilité (5 NFRs) :**
- Baseline 10,000 MAU sans dégradation
- Scalable 100,000 MAU <10% dégradation
- Inventaire 1,000 produits/user, pagination >50
- Base recettes 10,000+ avec full-text search <1s
- Coût infra <0.50€/MAU, budget total <500€/mois (10K MAU)

**Fiabilité & Disponibilité (6 NFRs) :**
- Uptime 99.5% (backend Firebase + APIs)
- Crash-free rate >99.9%
- Notifications DLC >99% reliability avec retries
- Resilience APIs externes (fallbacks Vision→ML Kit, OpenFoodFacts→cache local)
- Sync offline-online avec résolution conflits
- Backup quotidien Firestore, RTO 4h

**Intégration (7 NFRs) :**
- Google Vision API : quota monitoring, circuit breaker 80%, retry exponential backoff
- ML Kit on-device : 100% offline, auto-update modèles Firebase ML
- Firebase services : timeouts Auth 10s, Firestore 5s, Functions 30s
- Gemini AI : quota 60 req/min, fallback graceful, cache réponses fréquentes
- OpenFoodFacts : offline-first cache local, TTL 7j
- APIs Prix : 4+ sources, MAJ quotidienne, disclaimers visibles
- Google Maps : chargement carte <3s, quota monitoring

**Accessibilité (4 NFRs) :**
- WCAG 2.1 Niveau A : contraste 4.5:1, navigation clavier, alt text
- Mode Senior : texte +30%, boutons ≥48dp, contraste élevé
- i18n : FR phase 1, préparé EN/NL/DE année 2
- Screen readers : TalkBack/VoiceOver compatible

**Utilisabilité (4 NFRs) :**
- Onboarding <2min (90s cible), max 5 écrans
- Courbe apprentissage : 10 produits ajoutés en 5 min sans aide
- Feedback visuel clair toute action, messages erreur explicites
- Cohérence Material Design 3 (Android) + HIG (iOS)

**Maintenabilité & DevOps (5 NFRs) :**
- Code coverage ≥75% (70% unit, 20% widget, 10% E2E)
- CI/CD : tests auto, staged rollouts 5%→25%→100% sur 72h, rollback auto si crash >0.5%
- Monitoring : logs centralisés Crashlytics, metrics DAU/MAU/conversion, alertes auto
- Hotfix <24h pour bugs critiques
- Documentation dartdoc fonctions complexes, ADRs décisions architecturales

**Échelle & Complexité :**

- **Domaine principal :** Application mobile native iOS/Android (Flutter 3.32)
- **Niveau de complexité :** Medium-High
  - 14 modules fonctionnels indépendants
  - Architecture Feature-First + Clean Architecture
  - Offline-first avec synchronisation complexe
  - IA générative multi-modèle (Gemini Vision + Chat)
  - Dual-engine OCR (Cloud + On-device)
  - Modèle freemium avec feature flags
  - Conformité réglementaire stricte (RGPD santé)
- **Composants architecturaux estimés :**
  - 14 feature modules isolés
  - Couches transversales : auth, data sync, offline storage, networking, monitoring, analytics, feature flags, compliance

### Contraintes Techniques & Dépendances

**Stack Technologique Imposé :**
- **Frontend :** Flutter 3.32 (Dart 3.5+), Material Design 3 / Cupertino
- **Backend :** Firebase suite (Auth, Firestore, Cloud Functions, Cloud Storage, Remote Config, Crashlytics)
- **Stockage Local :** Hive (NoSQL léger offline-first)
- **OCR :** Google Cloud Vision API + ML Kit Text Recognition (dual-engine)
- **IA Générative :** Google Gemini (Vision + Chat)
- **Données Produits :** OpenFoodFacts API (nutrition), APIs prix enseignes (crowdsourcing phase 1)
- **Maps :** Google Maps API (carte interactive comparateur)

**Quotas & Limitations Externes :**
- Google Cloud Vision : 1,000 requêtes/mois free tier → monitoring + circuit breaker
- Gemini AI : 60 requêtes/minute → throttling + cache réponses
- Google Maps : 28,000 map loads/mois gratuit → monitoring quota
- Budget infrastructure total : <500€/mois pour 10,000 MAU

**Contraintes Réglementaires :**
- **RGPD Article 9** (données santé) : double opt-in obligatoire, encryption renforcée, droit retrait <30j
- **Règlement UE 1924/2006** : interdiction allégations santé thérapeutiques Coach IA
- **Directive 96/9/CE** : interdiction scraping prix non autorisé (APIs officielles ou crowdsourcing uniquement)
- **Responsabilité civile** : disclaimers nutrition/prix/péremption, assurance RC professionnelle obligatoire
- **Loi Hamon + RGPD** : freemium transparent (pas dark patterns), annulation facile, droit rétractation 14j

**Timeline & Déploiement :**
- MVP Tier 1 (Anti-Gaspi) : Semaines 4-6
- MVP Tier 2 (Scan Magique) : Semaines 7-8
- MVP Tier 3 (Nutrition) : Semaines 9-11
- Growth Features (Premium) : Semaines 12-22
- Production complète : Semaine 24
- Staged rollouts : 5% → 25% → 100% sur 72h par release

### Préoccupations Transversales Identifiées

**1. Offline-First & Synchronisation**
- Architecture offline-first obligatoire (NFR-P5) : toutes fonctionnalités core 100% offline
- Sync bidirectionnelle Firebase Firestore ↔ Hive local avec résolution conflits intelligente
- Cache stratégique : OpenFoodFacts (TTL 7j), réponses Gemini fréquentes, données prix
- Gestion états réseau : détection online/offline, queuing mutations offline, retry logic
- Implications : state management complexe, conflict resolution, data versioning

**2. Conformité RGPD & Privacy by Design**
- Données santé (Article 9) : suivi nutrition, profils médicaux, journal repas, photos repas
- Double opt-in requis avant activation modules nutrition (FR72)
- Encryption at-rest AES-256 + in-transit TLS 1.3+ pour données sensibles (NFR-S1)
- Droit retrait consentement → suppression données <30j (NFR-S4)
- Droit à l'oubli : suppression compte complète <30j (NFR-S5)
- Export données (portabilité RGPD) : JSON/PDF complet
- Implications : architecture ségrégation données, audit logs consentements, encryption layer, anonymization pipelines

**3. Feature Flags & Freemium Gating**
- 6 modules gratuits : Inventaire, Scan basique, Notifications, Recettes, Dashboard, Profil
- 8 modules premium (4.99€/mois) : Planning IA, Coach IA, Comparateur prix avancé, Gamification, Export/Partage
- Feature flags dynamiques via Firebase Remote Config
- Gating logique UI : modules premium désactivés/teasers pour utilisateurs gratuits
- Conversion flow : essai 7j gratuit, onboarding transparent, annulation facile
- Implications : feature toggle architecture, permission system, paywall UI/UX, A/B testing infrastructure

**4. Performance Critique & Métriques SLA**
- OCR <2s (95e percentile) : optimisation dual-engine, compression images, parallel processing
- App launch <3s cold start : lazy loading modules, code splitting, warm caches
- Offline sans dégradation : architecture state-first, data preloading, virtual scrolling
- Monitoring temps réel : Firebase Performance + Crashlytics + metrics custom
- Implications : performance budget strict, profiling continu, lazy initialization, caching agressif

**5. Resilience & Fallbacks APIs Externes**
- 7 dépendances externes critiques : Google Vision, ML Kit, Firebase, Gemini, OpenFoodFacts, APIs prix, Maps
- Fallbacks automatiques configurés :
  - Vision API down → ML Kit local seul (dégradation précision acceptable)
  - OpenFoodFacts down → cache local + ajout manuel utilisateur
  - Prix APIs down → message "données temporairement indisponibles"
  - Gemini quota dépassé → throttling graceful + message utilisateur
- Circuit breakers : quota monitoring, exponential backoff retries, health checks
- Implications : retry logic sophistiquée, cache layers, degraded mode UX, status monitoring

**6. Sécurité Multi-Niveaux**
- API keys jamais exposées client : stockage serveur-side, rotation 90j (NFR-S3)
- Authentification : Firebase Auth + OAuth2 (Google/Apple) + 2FA premium (NFR-S2)
- Sanitization entrées : protection SQL injection, XSS, command injection (NFR-S6)
- Penetration testing pré-production
- Implications : secrets management (env vars, Firebase Functions config), input validation layers, security audits

**7. Testing Pyramide & Qualité Code**
- Coverage ≥75% obligatoire : 70% unit, 20% widget/integration, 10% E2E (NFR-M1)
- CI/CD quality gates : merge bloqué si coverage <75%
- Tests critiques : OCR accuracy, sync conflict resolution, offline scenarios, feature flags, RGPD flows
- Architecture testable : dependency injection, mocking layers, test doubles
- Implications : testability-first design, mock infrastructure, CI pipeline robuste, test data factories

**8. Observabilité & Monitoring Business**
- Logs techniques : Firebase Crashlytics → migration Sentry future
- Metrics business temps réel : DAU, MAU, conversion freemium (gratuit→premium), rétention D7/D30/M6
- Alertes automatiques : crash rate +50%, API errors >5%, quota warnings 80%
- Analytics événements : scan ticket, génération planning, conversion funnel, feature usage
- Implications : analytics SDK intégration, event tracking architecture, dashboards business, alerting rules

## Évaluation Starter Template

### Domaine Technologique Principal

**Application mobile native iOS/Android** utilisant Flutter 3.32 (Dart 3.5+), identifié à partir de l'analyse des exigences projet.

### Options Starter Considérées

**Recherche effectuée (février 2026) :**

Trois catégories de starters Flutter évaluées :

1. **Starters Clean Architecture génériques :**
   - Flutter Clean Starter (production-ready, modulaire)
   - Momentous Flutter Starter (Riverpod + GoRouter + Material 3)
   - Plusieurs templates GitHub avec BLoC/Riverpod

2. **Packages architecture modulaire :**
   - flutter_modular (package officiel DI + routing modulaire)
   - Approches Feature-First vs Layer-First

3. **Starters Firebase-intégrés :**
   - Templates avec Firebase Auth/Firestore pré-configurés
   - Architectures Clean + Firebase (diverses combinaisons état management)

**Analyse critique :**

Aucun starter existant ne correspond exactement aux besoins spécifiques de FrigoFuteV2 :
- 14 modules Feature-First avec isolation stricte
- Architecture offline-first (Firestore ↔ Hive sync)
- Dual-engine OCR (Google Vision Cloud + ML Kit on-device)
- Intégration Gemini IA (Vision + Chat)
- Feature flags freemium (Firebase Remote Config)
- Stack complet Firebase + Hive + APIs externes multiples

Les starters évalués offrent soit une structure générique à adapter massivement, soit des architectures incompatibles avec l'approche Feature-First à 14 modules isolés.

### Décision : Setup Manuel Feature-First Custom

**Rationale de Sélection :**

Création manuelle de la structure Feature-First optimisée pour les besoins spécifiques du projet :

1. **Contrôle total architecture :** 14 modules avec isolation stricte dès le départ
2. **Optimisation offline-first :** Sync Firestore ↔ Hive conçue pour le cas d'usage
3. **Feature flags intégrés :** Gating freemium au niveau architectural (6 gratuits / 8 premium)
4. **Évolutivité maîtrisée :** Ajout/désactivation modules via feature flags sans refactoring
5. **Pas de dette technique héritée :** Pas de code inutilisé ou patterns incompatibles

**Commande d'Initialisation :**

```bash
flutter create --org com.frigofute --platforms ios,android frigofute_v2
cd frigofute_v2
# Setup manuel de la structure Feature-First (voir ci-dessous)
```

**Note :** L'initialisation du projet Flutter et le setup de cette structure Feature-First custom constituent la **première story d'implémentation**.

## Décisions Architecturales Principales

### Analyse de Priorité des Décisions

**Décisions Critiques (Bloquent l'Implémentation) :**

Toutes décisions ci-dessous sont critiques pour démarrer l'implémentation des 14 modules Feature-First avec isolation stricte et conformité aux NFRs.

**Décisions Importantes (Façonnent l'Architecture) :**

L'ensemble des décisions data, sécurité, API, et infrastructure définissent l'architecture globale et garantissent le respect des contraintes offline-first, RGPD, et performance.

**Décisions Différées (Post-MVP) :**

- Migration Sentry (actuellement Crashlytics suffisant)
- Intégration domotique (frigos connectés) - Vision future année 2-3
- Extension géographique multi-pays - Année 2

### Architecture de Données

**Base de Données & Stockage :**

- **Cloud Database :** Firebase Firestore
  - Structure collections : `users/{userId}/inventory`, `users/{userId}/nutrition_tracking`, `users/{userId}/meal_plans`, `shared/recipes`, `shared/products_cache`
  - Indexes composites : category + expirationDate, status + location
  - Security Rules strictes : user-scoped, role-based premium access

- **Local Database :** Hive 2.x (NoSQL offline-first)
  - Boxes : inventory_box, nutrition_box, recipes_box, settings_box, sync_queue_box
  - Encrypted boxes (AES-256) : nutrition_data_box, health_profiles_box (données santé RGPD)
  - TypeAdapters custom pour entités : Product, Recipe, NutritionProfile, MealPlan

**Stratégie Synchronisation Offline-Online :**

- **Pattern :** Optimistic UI + background sync bidirectionnelle
- **Conflict Resolution :** Last-Write-Wins (LWW) avec timestamp serveur Firestore authoritative
- **Offline Mutations Queue :** Hive `sync_queue_box` stocke opérations pending (CRUD), traitement FIFO au retour connexion
- **Retry Logic :** Exponential backoff (1s, 2s, 4s, 8s max 4 retries) via WorkManager (Android) / BackgroundTasks (iOS)
- **Data Versioning :** Chaque document Firestore contient `version` field incrémental pour détection conflits
- **Sync Status Monitoring :** Riverpod provider global `SyncStatusNotifier` expose état sync (synced, syncing, offline, error)

**Stratégie de Cache :**

- **OpenFoodFacts API :**
  - Cache local Hive `products_cache_box` avec TTL 7 jours
  - Stratégie LRU (Least Recently Used) : max 1000 produits cached
  - Fallback : si API down + cache miss → ajout manuel utilisateur encouragé

- **Gemini AI Responses :**
  - Cache in-memory (LRU, max 100 réponses) pour requêtes nutrition fréquentes
  - Clé cache : hash(photo_repas) ou hash(question_chatbot)
  - Invalidation : 24h expiration ou éviction LRU

- **Prix Enseignes :**
  - Cache Firestore `price_data/{enseigne}/{date}` avec TTL 24h
  - Disclaimer visible : "Prix indicatifs, dernière MAJ {date}"

**Modélisation Données :**

- **Product Entity :** id, name, barcode, category, location, quantity, unit, expirationDate, expiryType (DLC/DDM), nutritionData, addedDate, status
- **Recipe Entity :** id, name, ingredients[], instructions[], prepTime, difficulty, nutritionInfo, tags[], imageUrl
- **NutritionProfile Entity :** id, userId, profileType (famille/sportif/senior/etc), tdee, bmr, macros (proteins/carbs/fats), objectives
- **MealPlan Entity :** id, userId, weekStartDate, meals[] (day, mealType, recipeId), shoppingList[]

**Validation de Données :**

- **Client-side :** flutter_form_builder + custom validators (expirationDate > today, quantity > 0)
- **Server-side :** Cloud Functions validation triggers avant écriture Firestore (security + business rules)
- **Schema validation :** JSON Schema pour payloads APIs externes (OpenFoodFacts, Gemini)

### Authentification & Sécurité

**Méthode d'Authentification :**

- **Firebase Authentication**
  - Email/Password signup + login
  - OAuth2 providers : Google Sign-In, Apple Sign-In
  - Anonymous auth pour mode découverte (data stockée local Hive, migration possible vers compte après signup)

- **Multi-Factor Authentication (2FA) :** Activable pour utilisateurs premium via Firebase Phone Auth
- **Session Management :** Firebase Auth tokens auto-refresh, expiration 7 jours inactivité

**Patterns d'Autorisation :**

- **Feature Flags Freemium :**
  - Firebase Remote Config : JSON config `{premium_features: ["meal_planning", "ai_coach", "price_comparator", ...]}`
  - Riverpod `SubscriptionStatusProvider` global expose isPremium, activePremiumFeatures[]
  - Guard Widgets : `PremiumFeatureGuard(featureId)` wrapper vérifie subscription + affiche paywall si nécessaire

- **Firestore Security Rules :**
  ```
  match /users/{userId} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
    allow read: if request.auth != null && resource.data.sharedWith.hasAny([request.auth.uid]);
  }
  ```

- **Role-Based Access (future) :** Field `role` (user, admin) dans user document pour fonctionnalités admin

**Security Middleware :**

- **API Keys Protection :**
  - Google Cloud Vision, Gemini, Maps API keys stockées Firebase Functions environment config
  - Jamais exposées dans code client Flutter
  - Rotation automatique clés via Cloud Functions scheduled (90 jours)

- **Rate Limiting :**
  - Firebase Functions HTTP endpoints : 100 req/min par utilisateur via Cloud Firestore compteurs
  - Gemini AI quota : throttling client-side (max 1 req/2s) + queue requests

- **Input Sanitization :**
  - Package `sanitize_html` pour champs texte utilisateur (recettes partagées, commentaires future)
  - Validation stricte regex pour codes-barres EAN-13, email, numéros téléphone

**Approche Encryption de Données :**

- **Données Santé (RGPD Article 9) :**
  - Hive encrypted boxes : `nutrition_data_box`, `health_profiles_box` avec clé AES-256 dérivée de Firebase Auth UID
  - Firestore encryption at-rest native (Google-managed keys)
  - Transmission TLS 1.3+ obligatoire

- **Données Non-Sensibles :**
  - Inventaire, recettes, listes courses : Hive boxes non-encryptées (performance)
  - Firestore stockage standard

- **Photos Repas :**
  - Firebase Storage avec Storage Security Rules user-scoped
  - Photos compressées client-side avant upload (image_picker + flutter_image_compress)

**Stratégie Sécurité API :**

- **Firebase Callable Functions :** Authentification automatique via Firebase Auth token
- **API Externes :** Proxy via Cloud Functions pour masquer API keys
- **CORS :** Cloud Functions configurées allow-origin restrictif (app mobile uniquement)
- **Secrets Management :** GitHub Secrets (CI/CD) + Firebase Functions config (runtime)

### Patterns API & Communication

**Design Patterns API :**

- **Architecture :** RESTful pour APIs externes (OpenFoodFacts, prix), Firebase Firestore SDK natif (pas REST)
- **Cloud Functions HTTP :** Endpoints `/ocr-process`, `/gemini-analyze-meal`, `/sync-prices`
- **Data Fetching :** Repository pattern (domain/repositories interfaces, data/repositories implémentations)
- **Response Format :** JSON standardisé `{success: bool, data: {}, error: {code, message}}`

**Approche Documentation API :**

- **Cloud Functions :** Commentaires JSDoc + OpenAPI spec générée (swagger_dart_code_generator)
- **Firestore Schema :** Documentation inline dans Security Rules + README.md database_schema.md
- **Repositories :** Dartdoc comments sur toutes méthodes publiques

**Standards Gestion d'Erreurs :**

- **Exception Hierarchy Custom :**
  ```dart
  abstract class AppException implements Exception
  class NetworkException extends AppException
  class APIException extends AppException (code, message, statusCode)
  class ValidationException extends AppException
  class QuotaExceededException extends APIException
  class UnauthorizedException extends APIException
  ```

- **Error Handling Layers :**
  - Repository layer : catch exceptions techniques, wrap en AppException
  - UseCase layer : business logic errors, throw domain exceptions
  - Presentation layer : catch AppException, afficher UI user-friendly

- **User-Facing Messages :** Mapping exception → message clair + action corrective (NFR-U3)
  - NetworkException → "Connexion internet impossible. Vérifiez votre réseau."
  - QuotaExceededException → "Limite quotidienne atteinte. Réessayez demain ou passez Premium."

**Stratégie Rate Limiting :**

- **Gemini AI (60 req/min quota) :**
  - Client-side throttling : queue requests, max 1 req/2s
  - Firestore compteur quotidien par user : max 100 analyses photo/jour gratuit, illimité premium

- **Google Vision API (1000 req/mois free tier) :**
  - Firestore compteur global mensuel
  - Circuit breaker : si >80% quota → fallback ML Kit seul

- **Cloud Functions endpoints :**
  - Firestore rate limit : 100 req/min par userId
  - Réponse 429 Too Many Requests si dépassement

**Communication entre Services :**

- **Mobile ↔ Firebase :** Firestore SDK real-time listeners, Cloud Functions callable/HTTP
- **Cloud Functions ↔ APIs Externes :** node-fetch / axios avec retry logic
- **Background Jobs :** Cloud Scheduler (cron) trigger Cloud Functions (sync prix quotidien, cleanup data)

### Architecture Frontend

**Approche State Management :**

- **Riverpod 2.6+**
  - Provider scoping : global providers (auth, subscription) + feature-scoped providers
  - StateNotifier pour états complexes avec historique (undo/redo future)
  - FutureProvider / StreamProvider pour async data (Firestore streams)
  - Family providers pour paramétrisé (productProvider(productId))

- **State Persistence :** riverpod_persisted pour settings, onboarding completion

**Architecture des Composants :**

- **Pattern :** Atomic Design adapté Flutter
  - Atoms : `lib/core/shared/widgets/atoms/` (buttons, inputs, icons, loaders)
  - Molecules : `lib/core/shared/widgets/molecules/` (cards, list_tiles, form_fields)
  - Organisms : `lib/core/shared/widgets/organisms/` (app_bar, bottom_nav, dialogs)
  - Templates : `lib/features/{module}/presentation/screens/` (screen layouts)

- **Feature Components :** `lib/features/{module}/presentation/widgets/` (feature-specific, non réutilisables)
- **Theming :** Material Design 3 ThemeData centralisé, dark/light modes

**Stratégie de Routing :**

- **GoRouter 14.x**
  - Declarative routing : routes définies centralisées `lib/core/routing/app_router.dart`
  - Type-safe navigation : GoRoute avec typed extra parameters
  - Deep linking : URIs custom scheme `frigofute://` pour notifications
  - Navigation guards : redirect callback vérifie auth + subscription pour routes premium
  - Nested navigation : ShellRoute pour tabs dashboard (inventory, dashboard, profile)

**Optimisation Performance :**

- **Lazy Loading Modules :**
  - Deferred imports (`import 'package:.../meal_planning.dart' deferred as meal_planning;`)
  - Chargement à la demande : après onboarding, post feature-flag check
  - Code splitting automatique Flutter (--split-debug-info)

- **Image Optimization :**
  - cached_network_image pour images distantes (recipes, products)
  - Compression auto flutter_image_compress avant upload Firebase Storage
  - Placeholders shimmer (shimmer package) pendant chargement

- **List Performance :**
  - ListView.builder pour listes inventaire (1000+ produits)
  - AutomaticKeepAliveClientMixin pour tabs navigation (évite rebuild)
  - Pagination Firestore : limit(50) + startAfter pour scroll infini
  - Virtual scrolling : flutter_staggered_grid_view pour grilles recettes

**Optimisation Bundle :**

- **Tree Shaking :** Activé par défaut Flutter release build
- **Obfuscation :** `flutter build --obfuscate --split-debug-info` (sécurité code)
- **Icon Fonts :** flutter_launcher_icons custom, suppression icônes inutilisées Material Icons
- **Asset Optimization :** Images WebP, SVG pour icônes (flutter_svg)

### Infrastructure & Déploiement

**Stratégie d'Hébergement :**

- **Mobile Apps :**
  - iOS : App Store (Apple Developer Program)
  - Android : Google Play Store
  - Distribution beta : Firebase App Distribution (testeurs alpha/beta)

- **Backend :** Firebase Cloud Functions (Node.js 20 runtime)
- **Assets Statiques :** Firebase Storage (images, documents)
- **Web Admin (future) :** Firebase Hosting

**Approche Pipeline CI/CD :**

- **GitHub Actions Workflows :**

  **PR Checks (pull_request trigger) :**
  ```yaml
  - flutter analyze (linting)
  - flutter test --coverage (quality gate >75%)
  - flutter build apk --debug (vérif compilation Android)
  - flutter build ios --debug --no-codesign (vérif compilation iOS)
  ```

  **Staging Deploy (push to develop branch) :**
  ```yaml
  - Build APK/IPA
  - Deploy Firebase App Distribution (staging testers)
  - Deploy Cloud Functions environnement staging
  ```

  **Production Deploy (push tag v*.*.* ) :**
  ```yaml
  - Build release APK/AAB (Android) + IPA (iOS)
  - Fastlane staged rollouts :
    - Play Store : 5% → attendre 24h → 25% → attendre 24h → 100%
    - App Store : phased release automatique Apple
  - Deploy Cloud Functions production
  - Sentry release tracking (source maps)
  ```

  **Rollback Automatique :**
  - Webhook Crashlytics → Cloud Function monitoring crash rate
  - Si crash rate >0.5% dans 2h post-deploy → GitHub Actions trigger rollback previous version

**Configuration Environnement :**

- **Build Flavors Flutter :**
  - dev : Firebase project frigofute-dev
  - staging : Firebase project frigofute-staging
  - prod : Firebase project frigofute-prod

- **Environment Variables :**
  - flutter_dotenv : .env.dev, .env.staging, .env.prod (pas committés git)
  - Contenu : API_BASE_URL, ENABLE_ANALYTICS, GEMINI_MODEL_VERSION

- **Firebase Config :**
  - google-services.json (Android) / GoogleService-Info.plist (iOS) par flavor
  - Firebase Remote Config : feature flags différents par environnement

**Monitoring & Logging :**

- **Crash Reporting :**
  - Firebase Crashlytics (phase 1)
  - Migration Sentry prévue (meilleure stack traces, release tracking)

- **Performance Monitoring :**
  - Firebase Performance : traces automatiques (app_start, screen_rendering) + custom traces (ocr_scan_duration, sync_duration)

- **Analytics Événements :**
  - Firebase Analytics : événements business custom
    - scan_ticket, scan_barcode, add_product_manual
    - generate_meal_plan, analyze_meal_photo
    - view_premium_paywall, start_premium_trial, subscribe_premium
    - product_expired_notif_received, recipe_suggestion_clicked

- **Logging :**
  - Package logger : structured logs JSON
  - Niveaux : debug (dev), info (staging/prod), error/warning (toujours)
  - Cloud Functions logs : Cloud Logging (Stackdriver)

**Stratégie de Scaling :**

- **Firebase Firestore :** Auto-scaling natif Google, pas de config requise
- **Cloud Functions :** Auto-scaling horizontal (concurrency, instances min/max configurables)
- **Firebase Storage :** CDN global automatique
- **Monitoring Quotas :**
  - Firestore : alertes Cloud Monitoring si reads/writes approchent limites
  - Cloud Functions : alertes si invocations >80% quota gratuit
  - Google Vision API : circuit breaker custom 80% quota

### Analyse d'Impact des Décisions

**Séquence d'Implémentation Recommandée :**

1. **Infrastructure Setup (Epic 0 - Semaine 1-2) :**
   - Initialisation projet Flutter + structure Feature-First
   - Setup Firebase projects (dev/staging/prod) + Firestore
   - Configuration CI/CD GitHub Actions basique
   - Setup Hive + TypeAdapters initiaux

2. **Core Auth & Data Sync (Epic 1 - Semaine 2-3) :**
   - Firebase Auth intégration (Email/OAuth)
   - Implémentation sync Firestore ↔ Hive avec conflict resolution
   - Repository pattern base classes
   - Error handling hierarchy

3. **MVP Tier 1 Modules (Semaines 4-6) :**
   - Module Inventaire (CRUD + Hive/Firestore)
   - Module Notifications (local + push)
   - Module Dashboard (métriques basiques)
   - Tests pyramide >75% coverage

4. **MVP Tier 2 - OCR (Semaines 7-8) :**
   - Dual-engine OCR (Google Vision + ML Kit)
   - Retry logic + circuit breaker
   - Cache OpenFoodFacts

5. **MVP Tier 3 - Nutrition (Semaines 9-11) :**
   - Modules Nutrition Tracking + Profiles
   - Module Recipes avec matching inventaire
   - Encryption layer données santé

6. **Premium Features (Semaines 12-22) :**
   - Feature flags Remote Config + guards
   - Modules premium (Meal Planning IA, AI Coach, Price Comparator, Gamification)
   - In-app purchase intégration

7. **Production Readiness (Semaines 23-24) :**
   - Performance optimization (lazy loading, code splitting)
   - Security audit + penetration testing
   - Staged rollouts configuration

**Dépendances Inter-Composants :**

- **Auth → Tous modules** : Subscription status requis pour feature flags premium
- **Data Sync → Offline-first** : Tous modules dépendent sync Hive ↔ Firestore
- **Notifications → Modules métier** : Alertes péremption (Inventaire), suggestions recettes (Recipes), rappels planning (Meal Planning)
- **Analytics → Tous modules** : Tracking événements business cross-features
- **Feature Flags → Modules Premium** : Gating logique dépend Remote Config + Subscription

## Patterns d'Implémentation & Règles de Cohérence

### Points de Conflit Critiques Identifiés

**20 zones potentielles** où différents agents IA pourraient faire des choix incompatibles ont été identifiées et standardisées ci-dessous pour garantir la cohérence du code.

### Patterns de Nommage

**Conventions de Nommage Code (Dart Standard) :**

```dart
// Classes, Enums, Typedefs, Extensions: UpperCamelCase
class ProductEntity {}
class InventoryRepositoryImpl implements InventoryRepository {}
enum ProductStatus { fresh, expiring, expired, consumed }
typedef ProductCallback = void Function(Product);
extension StringExtension on String {}

// Variables, fonctions, paramètres, membres: lowerCamelCase
final String productName;
void addProduct(Product product) {}
int calculateDaysUntilExpiry(DateTime expirationDate) {}

// Constantes: lowerCamelCase (Dart convention, pas SCREAMING_CASE)
const int maxProductsPerUser = 1000;
const String defaultCategory = 'Autre';

// Membres privés: préfixe _ (underscore)
final String _privateField;
void _privateMethod() {}
class _PrivateClass {}

// Fichiers: snake_case.dart
product_entity.dart
inventory_repository_impl.dart
add_product_usecase.dart
inventory_list_screen.dart
```

**Conventions de Nommage Firestore :**

```
Collections: plural snake_case
✅ users
✅ inventory_items
✅ meal_plans
✅ nutrition_profiles
✅ recipes

Document IDs: auto-generated Firestore ou UUID v4
✅ users/abc123xyz (auto-generated)
✅ inventory_items/550e8400-e29b-41d4-a716-446655440000 (UUID)

Fields: camelCase (cohérence Dart json_serializable)
✅ {
  userId: "123",
  productName: "Lait demi-écrémé",
  expirationDate: Timestamp,
  isExpired: false,
  categoryId: "dairy"
}

Subcollections: plural snake_case
✅ users/{userId}/inventory_items
✅ users/{userId}/meal_plans
```

**Conventions de Nommage API :**

```dart
// Cloud Functions HTTP endpoints: kebab-case
✅ /ocr-process-ticket
✅ /gemini-analyze-meal
✅ /sync-price-data

// Route/Query parameters: camelCase (JSON standard)
✅ {userId: "123", productId: "456", includeNutrition: true}

// Headers: Kebab-Case (HTTP standard)
✅ Authorization: Bearer token
✅ Content-Type: application/json
✅ X-User-Id: 123
```

**Conventions de Nommage Providers Riverpod :**

```dart
// Pattern: {feature}{Purpose}Provider
✅ final inventoryListProvider = StateNotifierProvider<...>
✅ final currentProductProvider = StateProvider<Product?>
✅ final productByIdProvider = Provider.family<Product?, String>
✅ final authStateProvider = StreamProvider<User?>

// Notifiers: {Feature}Notifier
✅ class InventoryNotifier extends StateNotifier<List<Product>>
✅ class MealPlanningNotifier extends StateNotifier<MealPlanState>

// UseCases providers: {action}{Feature}UseCaseProvider
✅ final addProductUseCaseProvider = Provider<AddProductUseCase>
✅ final scanTicketUseCaseProvider = Provider<ScanTicketUseCase>
```

### Patterns de Structure

**Organisation Projet Feature-First (STRICT) :**

```
lib/
├── core/                           # Couches transversales (PAS de domain/data/presentation ici)
│   ├── auth/
│   │   ├── auth_service.dart
│   │   └── auth_providers.dart
│   ├── data_sync/
│   │   ├── sync_service.dart
│   │   ├── conflict_resolver.dart
│   │   └── sync_queue.dart
│   ├── networking/
│   │   ├── dio_client.dart
│   │   ├── retry_interceptor.dart
│   │   └── circuit_breaker.dart
│   ├── storage/
│   │   ├── hive_service.dart
│   │   └── type_adapters/
│   ├── feature_flags/
│   │   ├── remote_config_service.dart
│   │   └── feature_flag_providers.dart
│   ├── monitoring/
│   │   ├── analytics_service.dart
│   │   └── crashlytics_service.dart
│   ├── compliance/
│   │   ├── encryption_service.dart
│   │   ├── consent_manager.dart
│   │   └── data_export_service.dart
│   └── shared/
│       ├── utils/
│       ├── extensions/
│       ├── constants/
│       └── widgets/              # Atomic Design
│           ├── atoms/           # Buttons, inputs, icons
│           ├── molecules/       # Cards, list tiles, form fields
│           └── organisms/       # App bars, dialogs, bottom sheets
│
├── features/                      # 14 modules Feature-First
│   ├── inventory/                # Clean Architecture PAR feature (isolation stricte)
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── product_entity.dart
│   │   │   │   └── category_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── inventory_repository.dart        # Interface (abstract)
│   │   │   └── usecases/
│   │   │       ├── add_product_usecase.dart
│   │   │       ├── update_product_usecase.dart
│   │   │       └── delete_product_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── product_model.dart               # Hive + Firestore serialization
│   │   │   │   └── category_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── inventory_local_datasource.dart  # Hive
│   │   │   │   └── inventory_remote_datasource.dart # Firestore
│   │   │   └── repositories/
│   │   │       └── inventory_repository_impl.dart   # Implémentation
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── inventory_providers.dart         # Riverpod providers
│   │       │   └── inventory_notifier.dart
│   │       ├── screens/
│   │       │   ├── inventory_list_screen.dart
│   │       │   └── product_detail_screen.dart
│   │       └── widgets/
│   │           ├── product_card_widget.dart
│   │           └── category_filter_widget.dart
│   │
│   ├── ocr_scan/                 # Même structure Clean Architecture
│   ├── notifications/
│   ├── dashboard/
│   ├── auth_profile/
│   ├── recipes/
│   ├── nutrition_tracking/
│   ├── nutrition_profiles/
│   ├── meal_planning/
│   ├── ai_coach/
│   ├── gamification/
│   ├── shopping_list/
│   ├── family_sharing/
│   └── price_comparator/
│
└── main.dart
```

**Organisation Tests (MIRROR lib/) :**

```
test/
├── core/
│   ├── auth/auth_service_test.dart
│   ├── data_sync/sync_service_test.dart
│   └── networking/dio_client_test.dart
│
├── features/
│   ├── inventory/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       ├── add_product_usecase_test.dart
│   │   │       └── delete_product_usecase_test.dart
│   │   ├── data/
│   │   │   ├── models/product_model_test.dart
│   │   │   └── repositories/inventory_repository_impl_test.dart
│   │   └── presentation/
│   │       └── providers/inventory_providers_test.dart
│   └── ocr_scan/
│       └── ...
│
└── test_helpers/
    ├── mock_repositories.dart
    ├── mock_providers.dart
    └── test_data_factories.dart

// ✅ RÈGLE: Chaque fichier lib/path/to/file.dart → test/path/to/file_test.dart
```

**Organisation Assets :**

```
assets/
├── images/
│   ├── onboarding/
│   ├── icons/
│   └── illustrations/
├── fonts/
│   └── Roboto/
└── translations/
    ├── fr.json
    └── en.json (future)
```

### Patterns de Format

**Format Réponse API (Cloud Functions) :**

```dart
// ✅ Success response standard
{
  "success": true,
  "data": {
    "productId": "abc123",
    "recognizedItems": 127,
    "processingTimeMs": 1850
  },
  "timestamp": "2026-02-14T12:00:00.000Z"
}

// ✅ Error response standard
{
  "success": false,
  "error": {
    "code": "QUOTA_EXCEEDED",              // Enum-like code
    "message": "Gemini API quota dépassé", // User-facing message FR
    "details": {                           // Optional debug info
      "quotaLimit": 60,
      "quotaUsed": 60,
      "resetTime": "2026-02-14T13:00:00Z"
    }
  },
  "timestamp": "2026-02-14T12:00:00.000Z"
}

// ✅ Error codes standardisés
// Network errors: NETWORK_*, API_UNAVAILABLE, TIMEOUT
// Auth errors: UNAUTHORIZED, TOKEN_EXPIRED, INVALID_CREDENTIALS
// Quota errors: QUOTA_EXCEEDED, RATE_LIMIT_EXCEEDED
// Validation errors: VALIDATION_FAILED, INVALID_INPUT
// Business errors: PRODUCT_NOT_FOUND, SUBSCRIPTION_REQUIRED
```

**Formats Date/Time :**

```dart
// ✅ Firestore storage: Timestamp objects
Timestamp.now()
Timestamp.fromDate(dateTime)

// ✅ Dart DateTime: ISO 8601 strings pour JSON
DateTime.now().toIso8601String() // "2026-02-14T12:00:00.000Z"

// ✅ Display utilisateur: intl package (localized)
DateFormat('dd/MM/yyyy').format(date)     // "14/02/2026"
DateFormat('dd MMMM yyyy', 'fr_FR').format(date) // "14 février 2026"
DateFormat.yMd('fr_FR').format(date)      // "14/02/2026"

// ✅ Relative time display (notifications)
timeago package: "il y a 2 jours", "dans 3 heures"
```

**Nommage Champs JSON :**

```dart
// ✅ TOUJOURS camelCase (Dart json_serializable convention)
{
  "userId": "123",
  "productName": "Lait",
  "expirationDate": "2026-02-20T00:00:00Z",
  "isExpired": false,
  "nutritionData": {
    "calories": 150,
    "proteins": 8.5,
    "carbohydrates": 12.0
  }
}

// ❌ JAMAIS snake_case dans JSON
{
  "user_id": "123",        // ❌ INTERDIT
  "product_name": "Lait"   // ❌ INTERDIT
}
```

**Sérialisation Modèles :**

```dart
// ✅ json_serializable + freezed pattern
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String category,
    required DateTime expirationDate,
    @Default(false) bool isExpired,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

// ✅ Hive TypeAdapter séparé
@HiveType(typeId: 1)
class ProductHiveAdapter extends TypeAdapter<ProductModel> {...}
```

### Patterns de Communication

**State Management Riverpod (IMMUTABILITÉ STRICTE) :**

```dart
// ✅ State update IMMUTABLE (copie state)
class InventoryNotifier extends StateNotifier<List<Product>> {
  void addProduct(Product product) {
    state = [...state, product]; // ✅ CORRECT: nouvelle liste
  }

  void removeProduct(String productId) {
    state = state.where((p) => p.id != productId).toList(); // ✅ CORRECT
  }

  void updateProduct(Product updated) {
    state = [
      for (final product in state)
        if (product.id == updated.id) updated else product
    ]; // ✅ CORRECT
  }
}

// ❌ JAMAIS muter state directement
class InventoryNotifier extends StateNotifier<List<Product>> {
  void addProduct(Product product) {
    state.add(product); // ❌ INTERDIT: mutation directe
    notifyListeners();  // ❌ INTERDIT: pas de notifyListeners avec Riverpod
  }
}
```

**Analytics Events Naming :**

```dart
// ✅ Event naming: snake_case (Firebase Analytics convention)
FirebaseAnalytics.instance.logEvent(
  name: 'scan_ticket_success',
  parameters: {
    'ticket_item_count': 127,
    'scan_duration_ms': 1850,
    'ocr_engine': 'google_vision', // ou 'ml_kit'
  },
);

// ✅ Event categories standardisées
// User actions: scan_*, add_*, generate_*, view_*, edit_*, delete_*
// Business conversions: subscribe_premium, cancel_subscription, start_trial
// Feature usage: use_meal_planning, use_ai_coach, use_price_comparator
// Errors: ocr_failed, sync_conflict_detected, api_error_*
// Onboarding: complete_onboarding, skip_tutorial, select_profile_*
```

**Firestore Real-Time Listeners :**

```dart
// ✅ Riverpod StreamProvider pattern
final inventoryStreamProvider = StreamProvider<List<Product>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('inventory_items')
      .orderBy('expirationDate', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList());
});
```

### Patterns de Processus

**Gestion d'Erreurs Standardisée :**

```dart
// ✅ Exception hierarchy custom
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, [this.code, this.originalError]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  NetworkException(String message, [String? code, dynamic originalError])
      : super(message, code ?? 'NETWORK_ERROR', originalError);
}

class APIException extends AppException {
  final int? statusCode;
  APIException(String message, [String? code, this.statusCode, dynamic originalError])
      : super(message, code ?? 'API_ERROR', originalError);
}

class QuotaExceededException extends APIException {
  QuotaExceededException(String message)
      : super(message, 'QUOTA_EXCEEDED', 429);
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  ValidationException(String message, [this.fieldErrors])
      : super(message, 'VALIDATION_FAILED');
}

// ✅ Repository error handling avec Either (dartz)
Future<Either<AppException, List<Product>>> getProducts() async {
  try {
    final products = await remoteDataSource.fetchProducts();
    return Right(products);
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return Left(NetworkException('Timeout connexion'));
    }
    return Left(NetworkException('Erreur réseau', null, e));
  } on FirebaseException catch (e) {
    return Left(APIException('Erreur Firestore: ${e.message}', e.code, null, e));
  } catch (e) {
    return Left(AppException('Erreur inconnue', 'UNKNOWN_ERROR', e));
  }
}

// ✅ UI error handling
final inventoryState = ref.watch(inventoryListProvider);
inventoryState.when(
  data: (products) => ProductsList(products),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) {
    String userMessage = 'Une erreur est survenue';
    if (error is NetworkException) {
      userMessage = 'Connexion internet impossible. Vérifiez votre réseau.';
    } else if (error is QuotaExceededException) {
      userMessage = 'Limite quotidienne atteinte. Réessayez demain.';
    } else if (error is AppException) {
      userMessage = error.message;
    }
    return ErrorWidget(message: userMessage);
  },
);
```

**Loading States avec AsyncValue :**

```dart
// ✅ AsyncValue pattern (Riverpod best practice)
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.read(inventoryRepositoryProvider);
  return await repository.getAll();
});

// UI consumption
Widget build(BuildContext context, WidgetRef ref) {
  final asyncProducts = ref.watch(productsProvider);

  return asyncProducts.when(
    data: (products) => ProductsList(products),
    loading: () => const ShimmerLoading(),
    error: (err, stack) => ErrorWidget(err.toString()),
  );
}

// ✅ Loading state local (forms, buttons)
class AddProductButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    return ElevatedButton(
      onPressed: isLoading.value ? null : () async {
        isLoading.value = true;
        try {
          await ref.read(addProductUseCaseProvider).call(product);
        } finally {
          isLoading.value = false;
        }
      },
      child: isLoading.value
          ? const CircularProgressIndicator()
          : const Text('Ajouter'),
    );
  }
}
```

**Retry Logic & Circuit Breaker :**

```dart
// ✅ dio_retry_interceptor pour HTTP calls
final dio = Dio()
  ..interceptors.add(
    RetryInterceptor(
      dio: dio,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ],
      retryEvaluator: (error, attempt) {
        // Retry seulement sur erreurs réseau et 5xx
        return error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            (error.response?.statusCode ?? 0) >= 500;
      },
    ),
  );

// ✅ Circuit Breaker custom pour Google Vision API
class VisionAPICircuitBreaker {
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  static const _threshold = 3;
  static const _resetDuration = Duration(minutes: 5);

  Future<T> execute<T>(Future<T> Function() call) async {
    if (_isOpen()) {
      throw QuotaExceededException('Circuit breaker open: trop d\'échecs Google Vision API');
    }

    try {
      final result = await call();
      _reset();
      return result;
    } catch (e) {
      _recordFailure();
      rethrow;
    }
  }

  bool _isOpen() {
    if (_failureCount >= _threshold) {
      if (_lastFailureTime != null &&
          DateTime.now().difference(_lastFailureTime!) < _resetDuration) {
        return true;
      }
      _reset(); // Auto-reset après timeout
    }
    return false;
  }

  void _recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
  }

  void _reset() {
    _failureCount = 0;
    _lastFailureTime = null;
  }
}
```

### Directives d'Enforcement

**TOUS LES AGENTS IA DOIVENT IMPÉRATIVEMENT :**

1. **Respecter structure Feature-First stricte** : Chaque feature contient domain/data/presentation isolés
2. **Nommer fichiers en snake_case.dart** : `product_entity.dart` JAMAIS `ProductEntity.dart`
3. **Classes UpperCamelCase, variables/fonctions lowerCamelCase** : Conventions Dart officielles
4. **Tests mirror lib/ structure** : `test/features/inventory/` ↔ `lib/features/inventory/` avec suffix `_test.dart`
5. **Riverpod state IMMUTABLE** : JAMAIS muter `state` directement, toujours copier
6. **JSON camelCase** : Tous champs JSON (Firestore, API responses) en camelCase
7. **Dates ISO 8601 en JSON** : Firestore Timestamp pour stockage, ISO strings pour JSON exchanges
8. **Exception hierarchy AppException** : Toutes exceptions métier héritent AppException
9. **AsyncValue pour async data** : Riverpod FutureProvider/StreamProvider, pas bool isLoading manuels
10. **Analytics events snake_case** : Firebase Analytics `scan_ticket_success` pas `scanTicketSuccess`
11. **Either<Error, Success> repositories** : Pattern functional avec dartz pour gestion erreurs
12. **Retry exponential backoff** : Dio interceptor pour HTTP, custom pour APIs externes
13. **Circuit breaker quotas** : Google Vision API, Gemini AI avec fallbacks définis
14. **User-facing error messages FR** : Messages explicites + action corrective (NFR-U3)
15. **Structured logging JSON** : Package logger avec niveaux debug/info/warning/error

**Enforcement Automatique :**

- ✅ **flutter analyze** : Linting strict (analysis_options.yaml), CI/CD quality gate
- ✅ **flutter test --coverage** : Coverage >75% obligatoire, merge bloqué si <75%
- ✅ **dart format** : Auto-formatting 80 chars, pre-commit hook
- ✅ **PR template checklist** : Patterns respect vérifié en code review

**Process Mise à Jour Patterns :**

- Patterns évolutifs : propositions via PR sur architecture.md
- Validation équipe : discussion + approval avant merge
- Communication : Slack announcement nouveaux patterns adoptés
- Documentation : architecture.md source de vérité unique

### Exemples Concrets

**✅ Bon Exemple - Feature Inventory Complet :**

```dart
// lib/features/inventory/domain/entities/product_entity.dart
class ProductEntity {
  final String id;
  final String name;
  final String category;
  final DateTime expirationDate;

  ProductEntity({required this.id, required this.name, ...});
}

// lib/features/inventory/domain/repositories/inventory_repository.dart
abstract class InventoryRepository {
  Future<Either<AppException, List<ProductEntity>>> getAll();
  Future<Either<AppException, void>> add(ProductEntity product);
}

// lib/features/inventory/data/models/product_model.dart
@freezed
class ProductModel with _$ProductModel {
  factory ProductModel.fromEntity(ProductEntity entity) {...}
  ProductEntity toEntity() {...}
  factory ProductModel.fromJson(Map<String, dynamic> json) => ...;
}

// lib/features/inventory/data/repositories/inventory_repository_impl.dart
class InventoryRepositoryImpl implements InventoryRepository {
  @override
  Future<Either<AppException, List<ProductEntity>>> getAll() async {
    try {
      final models = await _remoteDataSource.fetchProducts();
      return Right(models.map((m) => m.toEntity()).toList());
    } on FirebaseException catch (e) {
      return Left(APIException('Erreur Firestore', e.code));
    }
  }
}

// lib/features/inventory/presentation/providers/inventory_providers.dart
final inventoryStreamProvider = StreamProvider<List<ProductEntity>>((ref) {
  final repo = ref.read(inventoryRepositoryProvider);
  return repo.watchAll().map((either) => either.fold(
    (error) => throw error,
    (products) => products,
  ));
});

// lib/features/inventory/presentation/screens/inventory_list_screen.dart
class InventoryListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(inventoryStreamProvider);

    return Scaffold(
      body: asyncProducts.when(
        data: (products) => ListView.builder(...),
        loading: () => const CircularProgressIndicator(),
        error: (err, _) => ErrorWidget(err.toString()),
      ),
    );
  }
}

// test/features/inventory/data/repositories/inventory_repository_impl_test.dart
void main() {
  group('InventoryRepositoryImpl', () {
    test('getAll returns products on success', () async {
      // Arrange
      final mockDataSource = MockInventoryRemoteDataSource();
      final repository = InventoryRepositoryImpl(mockDataSource);

      // Act
      final result = await repository.getAll();

      // Assert
      expect(result.isRight(), true);
    });
  });
}
```

**❌ Anti-Patterns à ÉVITER :**

```dart
// ❌ Fichier nommé UpperCamelCase
lib/features/inventory/ProductEntity.dart  // INTERDIT

// ❌ Mutation state directe Riverpod
class InventoryNotifier extends StateNotifier<List<Product>> {
  void addProduct(Product p) {
    state.add(p); // INTERDIT: mutable
  }
}

// ❌ JSON snake_case
{"product_name": "Lait", "expiration_date": "2026-02-20"} // INTERDIT

// ❌ Tests pas en mirror
test/inventory_test.dart  // INTERDIT si lib/features/inventory/...

// ❌ Exception générique sans hierarchy
throw Exception('Error'); // INTERDIT, utiliser AppException

// ❌ Bool isLoading manuel au lieu AsyncValue
final isLoading = useState(false);
final data = useState<List<Product>>([]);
// Préférer: final asyncData = ref.watch(productsProvider);

// ❌ Analytics camelCase
logEvent('scanTicketSuccess'); // INTERDIT, utiliser scan_ticket_success

// ❌ Dates en timestamp Unix ou formats custom
{"date": 1707912000} // INTERDIT, utiliser ISO 8601 "2026-02-14T12:00:00Z"
```

## Structure Projet & Boundaries Architecturales

### Structure Complète du Projet

```
frigofute_v2/
├── README.md
├── pubspec.yaml                    # Dependencies Flutter + versioning
├── analysis_options.yaml           # Linting rules strictes
├── .gitignore
├── .env.dev                        # Environment vars dev (pas commit git)
├── .env.staging                    # Environment vars staging
├── .env.prod                       # Environment vars production
├── .env.example                    # Template env vars (commité)
│
├── .github/
│   └── workflows/
│       ├── pr_checks.yml          # flutter analyze + test --coverage >75%
│       ├── staging_deploy.yml     # Firebase App Distribution beta testers
│       └── production_deploy.yml  # Play Store + App Store staged rollouts
│
├── android/
│   ├── app/
│   │   ├── build.gradle           # Android build config + flavors
│   │   ├── google-services.json   # Firebase config dev (gitignored)
│   │   └── src/
│   │       ├── dev/               # Dev flavor resources
│   │       ├── staging/           # Staging flavor resources
│   │       └── prod/              # Prod flavor resources
│   └── gradle/
│
├── ios/
│   ├── Runner/
│   │   ├── Info.plist
│   │   ├── GoogleService-Info.plist  # Firebase config dev (gitignored)
│   │   └── Assets.xcassets/
│   ├── Podfile
│   └── Runner.xcodeproj/
│
├── lib/
│   ├── main.dart                  # Entry point + ProviderScope Riverpod
│   ├── main_dev.dart              # Dev flavor entry
│   ├── main_staging.dart          # Staging flavor entry
│   ├── main_prod.dart             # Prod flavor entry
│   │
│   ├── core/                      # Couches transversales (isolation stricte)
│   │   ├── auth/
│   │   │   ├── auth_service.dart
│   │   │   ├── auth_providers.dart
│   │   │   └── models/
│   │   │       ├── user_model.dart
│   │   │       └── auth_state.dart
│   │   │
│   │   ├── data_sync/
│   │   │   ├── sync_service.dart
│   │   │   ├── sync_queue_manager.dart
│   │   │   ├── conflict_resolver.dart
│   │   │   └── sync_providers.dart
│   │   │
│   │   ├── networking/
│   │   │   ├── dio_client.dart
│   │   │   ├── retry_interceptor.dart
│   │   │   ├── circuit_breaker.dart
│   │   │   └── network_info.dart
│   │   │
│   │   ├── storage/
│   │   │   ├── hive_service.dart
│   │   │   ├── encryption_service.dart
│   │   │   └── type_adapters/
│   │   │       ├── product_adapter.dart
│   │   │       ├── recipe_adapter.dart
│   │   │       └── nutrition_profile_adapter.dart
│   │   │
│   │   ├── feature_flags/
│   │   │   ├── remote_config_service.dart
│   │   │   ├── feature_flag_providers.dart
│   │   │   └── models/feature_config.dart
│   │   │
│   │   ├── monitoring/
│   │   │   ├── analytics_service.dart
│   │   │   ├── crashlytics_service.dart
│   │   │   ├── performance_monitor.dart
│   │   │   └── logger_service.dart
│   │   │
│   │   ├── compliance/
│   │   │   ├── encryption_service.dart
│   │   │   ├── consent_manager.dart
│   │   │   ├── data_export_service.dart
│   │   │   └── models/consent_log.dart
│   │   │
│   │   ├── routing/
│   │   │   ├── app_router.dart              # GoRouter config centralisée
│   │   │   ├── route_guards.dart            # Auth + premium guards
│   │   │   └── app_routes.dart              # Route paths constants
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart               # Material 3 theme
│   │   │   ├── color_palette.dart
│   │   │   └── text_styles.dart
│   │   │
│   │   └── shared/
│   │       ├── utils/
│   │       │   ├── date_utils.dart
│   │       │   ├── string_utils.dart
│   │       │   └── validators.dart
│   │       ├── extensions/
│   │       │   ├── datetime_extensions.dart
│   │       │   ├── string_extensions.dart
│   │       │   └── context_extensions.dart
│   │       ├── constants/
│   │       │   ├── app_constants.dart
│   │       │   ├── api_constants.dart
│   │       │   └── storage_constants.dart
│   │       ├── exceptions/
│   │       │   ├── app_exception.dart
│   │       │   ├── network_exception.dart
│   │       │   ├── api_exception.dart
│   │       │   └── validation_exception.dart
│   │       └── widgets/                     # Atomic Design
│   │           ├── atoms/
│   │           │   ├── app_button.dart
│   │           │   ├── app_text_field.dart
│   │           │   ├── app_icon.dart
│   │           │   └── loading_indicator.dart
│   │           ├── molecules/
│   │           │   ├── product_card.dart
│   │           │   ├── category_chip.dart
│   │           │   ├── expiry_badge.dart
│   │           │   └── nutrition_label.dart
│   │           └── organisms/
│   │               ├── app_bar_custom.dart
│   │               ├── bottom_nav_bar.dart
│   │               ├── error_dialog.dart
│   │               └── paywall_sheet.dart
│   │
│   └── features/                  # 14 Modules Feature-First (Clean Architecture stricte)
│       │
│       ├── inventory/             # Module 1 - Gestion Inventaire (GRATUIT)
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── product_entity.dart
│       │   │   │   ├── category_entity.dart
│       │   │   │   └── storage_location_entity.dart
│       │   │   ├── repositories/
│       │   │   │   └── inventory_repository.dart        # Interface abstract
│       │   │   └── usecases/
│       │   │       ├── add_product_usecase.dart
│       │   │       ├── update_product_usecase.dart
│       │   │       ├── delete_product_usecase.dart
│       │   │       ├── get_all_products_usecase.dart
│       │   │       └── mark_as_consumed_usecase.dart
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── product_model.dart               # Freezed + json_serializable
│       │   │   │   └── category_model.dart
│       │   │   ├── datasources/
│       │   │   │   ├── inventory_local_datasource.dart  # Hive
│       │   │   │   └── inventory_remote_datasource.dart # Firestore
│       │   │   └── repositories/
│       │   │       └── inventory_repository_impl.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   ├── inventory_providers.dart
│       │       │   └── inventory_notifier.dart
│       │       ├── screens/
│       │       │   ├── inventory_list_screen.dart
│       │       │   ├── product_detail_screen.dart
│       │       │   └── add_product_screen.dart
│       │       └── widgets/
│       │           ├── product_list_tile.dart
│       │           ├── category_filter.dart
│       │           └── sort_dropdown.dart
│       │
│       ├── ocr_scan/              # Module 2 - Scan OCR & Code-barres (GRATUIT)
│       ├── notifications/         # Module 3 - Alertes & Notifications (GRATUIT)
│       ├── dashboard/             # Module 4 - Dashboard Métriques (GRATUIT)
│       ├── auth_profile/          # Module 5 - Auth & Profil Utilisateur (GRATUIT)
│       ├── recipes/               # Module 6 - Recettes & Suggestions (GRATUIT)
│       ├── nutrition_tracking/    # Module 7 - Suivi Alimentaire (PREMIUM)
│       ├── nutrition_profiles/    # Module 8 - Profils Nutritionnels (PREMIUM)
│       ├── meal_planning/         # Module 9 - Planning Repas IA (PREMIUM)
│       ├── ai_coach/              # Module 10 - Coach IA Nutrition (PREMIUM)
│       ├── gamification/          # Module 11 - Gamification (PREMIUM)
│       ├── shopping_list/         # Module 12 - Liste Courses (PREMIUM)
│       ├── family_sharing/        # Module 13 - Export & Partage (PREMIUM)
│       └── price_comparator/      # Module 14 - Comparateur Prix (PREMIUM)
│           └── (même structure domain/data/presentation)
│
├── test/                          # Tests (MIRROR lib/ structure)
│   ├── core/
│   │   ├── auth/auth_service_test.dart
│   │   ├── data_sync/
│   │   │   ├── sync_service_test.dart
│   │   │   └── conflict_resolver_test.dart
│   │   └── networking/dio_client_test.dart
│   │
│   ├── features/
│   │   ├── inventory/
│   │   │   ├── domain/usecases/add_product_usecase_test.dart
│   │   │   ├── data/
│   │   │   │   ├── models/product_model_test.dart
│   │   │   │   └── repositories/inventory_repository_impl_test.dart
│   │   │   └── presentation/providers/inventory_providers_test.dart
│   │   └── ocr_scan/
│   │       └── (même structure mirror)
│   │
│   ├── integration_test/
│   │   ├── app_test.dart
│   │   ├── inventory_flow_test.dart
│   │   └── ocr_scan_flow_test.dart
│   │
│   └── test_helpers/
│       ├── mock_repositories.dart
│       ├── mock_providers.dart
│       ├── test_data_factories.dart
│       └── fake_datasources.dart
│
├── assets/                        # Assets statiques
│   ├── images/
│   │   ├── onboarding/
│   │   ├── icons/
│   │   └── illustrations/
│   ├── fonts/
│   │   └── Roboto/
│   └── translations/
│       ├── fr.arb                 # Français (défaut)
│       └── en.arb                 # Anglais (future)
│
├── firebase/                      # Firebase Cloud Functions (Node.js 20)
│   ├── functions/
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── ocr/processTicket.ts
│   │   │   ├── gemini/analyzeMeal.ts
│   │   │   ├── sync/syncPriceData.ts
│   │   │   └── utils/
│   │   └── test/functions.test.ts
│   │
│   ├── firestore.rules            # Security Rules Firestore
│   ├── firestore.indexes.json     # Composite indexes
│   ├── storage.rules              # Storage Security Rules
│   └── firebase.json              # Firebase config
│
├── scripts/
│   ├── setup_flavors.sh
│   ├── generate_icons.sh
│   └── cleanup_build.sh
│
└── docs/
    ├── architecture.md            # CE DOCUMENT
    ├── database_schema.md
    ├── api_endpoints.md
    └── deployment_guide.md
```

### Boundaries Architecturales

**API Boundaries :**

**Cloud Functions HTTP Endpoints :**
```
POST /ocr-process-ticket
  Request: {image: base64, userId: string}
  Response: {success: bool, data: {products: Product[]}, timestamp: ISO8601}

POST /gemini-analyze-meal
  Request: {image: base64, userId: string, nutritionGoals: object}
  Response: {success: bool, data: {calories: number, macros: object, suggestions: string[]}}

POST /gemini-generate-meal-plan
  Request: {userId: string, inventory: Product[], preferences: object, weekStartDate: ISO8601}
  Response: {success: bool, data: {meals: Meal[], shoppingList: Product[]}}

GET /sync-price-data
  Scheduled: Cloud Scheduler daily 6:00 AM
  Action: Scrape/fetch prix enseignes → update Firestore price_data
```

**Firestore Collections (API Boundary interne) :**
```
users/{userId}
├── profile: UserProfile
├── subscription: SubscriptionStatus
├── consent_logs/: ConsentLog[]
│
├── inventory_items/{productId}: Product
├── meal_plans/{planId}: MealPlan
├── nutrition_tracking/{date}: DailyNutrition
├── nutrition_profiles/{profileId}: NutritionProfile
└── achievements/{achievementId}: Achievement

shared/
├── recipes/{recipeId}: Recipe
├── products_cache/{barcode}: ProductCache (OpenFoodFacts)
└── price_data/{enseigne}/{date}: PriceData
```

**Component Boundaries :**

**Feature Module Isolation (STRICT) :**
- Chaque feature module = bounded context isolé
- Communication inter-features UNIQUEMENT via:
  1. Riverpod providers exposure (barrel exports)
  2. Navigation GoRouter (deep links)
  3. Events Firebase Analytics (découplage total)

**Exemple Communication :**
```dart
// ❌ INTERDIT: Import direct cross-features
import 'package:frigofute_v2/features/recipes/domain/entities/recipe_entity.dart'; // INTERDIT

// ✅ CORRECT: Communication via core/shared providers
final selectedRecipeProvider = StateProvider<String?>((ref) => null); // core/shared
// Feature recipes expose recipe via provider
// Feature meal_planning consomme via provider reference
```

**State Management Boundaries :**

**Riverpod Provider Scopes :**
- **Global providers** : core/auth, core/feature_flags, core/monitoring
- **Feature-scoped providers** : lib/features/{module}/presentation/providers/
- **Screen-scoped providers** : Provider.autoDispose pour cleanup automatique

**Data Flow Unidirectionnel :**
```
UI (Screens/Widgets)
  ↓ read provider / call usecase
Providers (Riverpod StateNotifier)
  ↓ call usecase
UseCases (domain/usecases/)
  ↓ call repository
Repositories (data/repositories/)
  ↓ call datasources
DataSources (data/datasources/)
  ↓ Hive / Firestore / APIs externes
```

**Service Boundaries :**

**Core Services (Singletons via Riverpod) :**
```dart
// lib/core/auth/auth_providers.dart
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// lib/core/data_sync/sync_providers.dart
final syncServiceProvider = Provider<SyncService>((ref) {
  final auth = ref.watch(authServiceProvider);
  final hive = ref.watch(hiveServiceProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return SyncService(auth, hive, firestore);
});

// lib/core/feature_flags/feature_flag_providers.dart
final featureFlagsProvider = StreamProvider<FeatureConfig>((ref) {
  return RemoteConfigService().configStream;
});
```

**External Service Boundaries :**
- Google Cloud Vision API → via Firebase Cloud Function proxy (masque API key)
- Gemini AI → via Firebase Cloud Function proxy (quota monitoring)
- OpenFoodFacts → direct HTTP via Dio (rate limiting client-side)
- Google Maps → direct SDK Flutter (API key Android/iOS config)

**Data Boundaries :**

**Firestore Security Rules (User-Scoped) :**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data: read/write only own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Shared data: read all, write none (Cloud Functions only)
    match /shared/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Only Cloud Functions can write
    }
  }
}
```

**Hive Boxes (Local Storage Boundaries) :**
```dart
// Non-encrypted boxes (performance)
Box<ProductModel> inventoryBox;
Box<RecipeModel> recipesBox;
Box<SettingsModel> settingsBox;

// Encrypted boxes AES-256 (données santé RGPD)
Box<NutritionDataModel> nutritionDataBox; // encrypted
Box<HealthProfileModel> healthProfilesBox; // encrypted

// Sync queue (offline mutations pending)
Box<SyncQueueItem> syncQueueBox;
```

### Mapping Exigences → Structure

**14 Modules Fonctionnels → Features :**

| Module | FR Category | Feature Directory | Gratuit/Premium |
|--------|-------------|-------------------|-----------------|
| Module 1 | Gestion Inventaire (10 FRs) | `lib/features/inventory/` | ✅ Gratuit |
| Module 2 | Acquisition Données (5 FRs) | `lib/features/ocr_scan/` | ✅ Gratuit |
| Module 3 | Alertes & Notifications (6 FRs) | `lib/features/notifications/` | ✅ Gratuit |
| Module 4 | Dashboard Métriques (6 FRs) | `lib/features/dashboard/` | ✅ Gratuit |
| Module 5 | Auth & Profil (6 FRs) | `lib/features/auth_profile/` | ✅ Gratuit |
| Module 6 | Recettes (6 FRs) | `lib/features/recipes/` | ✅ Gratuit |
| Module 7 | Suivi Nutrition (tracking) | `lib/features/nutrition_tracking/` | 💎 Premium |
| Module 8 | Profils Nutritionnels (12 profils) | `lib/features/nutrition_profiles/` | 💎 Premium |
| Module 9 | Planning Repas IA (6 FRs) | `lib/features/meal_planning/` | 💎 Premium |
| Module 10 | Coach IA Nutrition (8 FRs) | `lib/features/ai_coach/` | 💎 Premium |
| Module 11 | Gamification (5 FRs) | `lib/features/gamification/` | 💎 Premium |
| Module 12 | Liste Courses (génération auto) | `lib/features/shopping_list/` | 💎 Premium |
| Module 13 | Export & Partage Famille (4 FRs) | `lib/features/family_sharing/` | 💎 Premium |
| Module 14 | Comparateur Prix (6 FRs) | `lib/features/price_comparator/` | 💎 Premium |

**Préoccupations Transversales → Core :**

| Concern | Implementation | Core Directory |
|---------|---------------|----------------|
| Offline-First & Sync | Firestore ↔ Hive bidirectional | `lib/core/data_sync/` |
| RGPD & Privacy | Encryption, consent, export | `lib/core/compliance/` |
| Feature Flags Freemium | Remote Config gating | `lib/core/feature_flags/` |
| Performance SLA | Monitoring, profiling | `lib/core/monitoring/` |
| Resilience APIs | Retry, circuit breaker | `lib/core/networking/` |
| Sécurité Multi-Niveaux | Auth, secrets, validation | `lib/core/auth/` + guards |
| Testing Pyramide | Mock infrastructure | `test/test_helpers/` |
| Observabilité | Analytics, crashlytics | `lib/core/monitoring/` |

### Points d'Intégration

**Communication Interne :**

**Feature → Core Services :**
```dart
// Exemple: Feature inventory utilise sync service
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDS;
  final InventoryRemoteDataSource remoteDS;
  final SyncService syncService; // Injecté via Riverpod

  @override
  Future<void> addProduct(Product product) async {
    // 1. Write local Hive
    await localDS.add(product);

    // 2. Queue sync if online, defer if offline
    await syncService.queueMutation(
      type: MutationType.create,
      collection: 'inventory_items',
      data: product.toJson(),
    );
  }
}
```

**Feature → Feature (via Routing) :**
```dart
// Navigation cross-features via GoRouter
context.push('/recipes/detail', extra: {'recipeId': '123'});

// Deep link depuis notification
frigofute://inventory/product/abc123
```

**Intégrations Externes :**

**Firebase Services :**
```dart
// Firebase Auth (core/auth/)
FirebaseAuth.instance.signInWithEmailAndPassword(...);

// Firestore (features/{module}/data/datasources/)
FirebaseFirestore.instance.collection('users').doc(userId)...;

// Cloud Functions (core/networking/)
final response = await dio.post('https://us-central1-frigofute-prod.cloudfunctions.net/ocr-process-ticket');

// Remote Config (core/feature_flags/)
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.fetchAndActivate();
final featureConfig = remoteConfig.getString('premium_features');

// Analytics (core/monitoring/)
FirebaseAnalytics.instance.logEvent(name: 'scan_ticket_success', parameters: {...});
```

**APIs Externes (via Dio + Retry) :**
```dart
// OpenFoodFacts API
GET https://world.openfoodfacts.org/api/v0/product/{barcode}.json

// Google Cloud Vision (via Cloud Function proxy)
POST https://us-central1-frigofute-prod.cloudfunctions.net/ocr-process-ticket

// Gemini AI (via Cloud Function proxy)
POST https://us-central1-frigofute-prod.cloudfunctions.net/gemini-analyze-meal
```

**Flux de Données :**

**User Action → Local Storage → Cloud Sync :**
```
1. User ajoute produit via UI
   ↓
2. UI call provider.addProduct()
   ↓
3. Provider call AddProductUseCase
   ↓
4. UseCase call InventoryRepository.add()
   ↓
5. Repository write Hive local (immediate, offline-first)
   ↓
6. Repository queue SyncService.queueMutation()
   ↓
7. SyncService (background):
   - Si online: POST Firestore immediately
   - Si offline: queue Hive sync_queue_box
   ↓
8. NetworkInfo listener détecte online → SyncService process queue FIFO
   ↓
9. Firestore write success → remove from sync queue
```

**Real-Time Updates (Firestore → Local) :**
```
1. Firestore collection snapshot listener (StreamProvider)
   ↓
2. New data detected → StreamProvider emit
   ↓
3. Repository.watchAll() propagate stream
   ↓
4. Riverpod StreamProvider update state
   ↓
5. UI rebuild automatically (Consumer widgets)
   ↓
6. Background: SyncService update Hive cache (eventually consistent)
```

### Organisation Fichiers

**Fichiers Configuration (Root) :**
- `pubspec.yaml` : Dependencies, assets, fonts declarations
- `analysis_options.yaml` : Linting rules (flutter_lints + custom rules)
- `.env.dev`, `.env.staging`, `.env.prod` : Environment variables (gitignored)
- `.env.example` : Template env vars (commité comme doc)
- `.gitignore` : Ignore build/, .env*, .dart_tool/, etc.

**Code Source (lib/) :**
- `main.dart` : Entry point, ProviderScope, runApp(), Firebase init
- `main_dev.dart`, `main_staging.dart`, `main_prod.dart` : Flavor entry points
- `lib/core/` : Transversal layers (8 core services + shared utilities)
- `lib/features/` : 14 feature modules Feature-First Clean Architecture

**Tests (test/) :**
- `test/core/` : Tests core services
- `test/features/{module}/` : Tests par feature (mirror lib structure)
- `test/integration_test/` : Integration tests E2E
- `test/test_helpers/` : Mocks, fakes, factories partagés

**Assets (assets/) :**
- `assets/images/` : PNG, JPG, SVG illustrations
- `assets/fonts/` : Custom fonts TTF
- `assets/translations/` : ARB files i18n (intl package)

**Backend (firebase/) :**
- `firebase/functions/src/` : Cloud Functions TypeScript
- `firebase/firestore.rules` : Security Rules
- `firebase/storage.rules` : Storage Security Rules

### Intégration Workflow Développement

**Development Server :**
```bash
# Run dev flavor
flutter run --flavor dev --target lib/main_dev.dart

# Hot reload: r (incremental changes)
# Hot restart: R (full app restart)
# Quit: q
```

**Build Process :**
```bash
# Android APK debug
flutter build apk --flavor dev --debug

# Android AAB release (Play Store)
flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/symbols

# iOS IPA release (App Store)
flutter build ipa --flavor prod --release --obfuscate --split-debug-info=build/symbols
```

**Structure Déploiement :**

**CI/CD Pipeline GitHub Actions :**
```yaml
# .github/workflows/pr_checks.yml
on: pull_request
jobs:
  quality-gate:
    - flutter analyze (fail si warnings)
    - flutter test --coverage (fail si <75%)
    - flutter build apk --debug (vérif compilation)

# .github/workflows/production_deploy.yml
on:
  push:
    tags: 'v*.*.*'
jobs:
  deploy:
    - flutter build appbundle --release
    - fastlane android deploy (staged rollout 5%→25%→100%)
    - flutter build ipa --release
    - fastlane ios deploy (phased release Apple)
    - Deploy Firebase Functions production
```

**Artifacts Déploiement :**
- Android: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
- iOS: `build/ios/ipa/frigofute_v2.ipa`
- Firebase Functions: `firebase/functions/lib/` (compiled JS)
- Source maps (obfuscation): `build/symbols/` (upload Crashlytics/Sentry)

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:**

Toutes les décisions technologiques sont compatibles et se renforcent mutuellement :
- **Flutter 3.32 + Dart 3.5+** ✅ Compatible avec l'ensemble du stack (Riverpod 2.6, GoRouter 14.x, Hive 2.x, Firebase SDK)
- **Firebase suite** (Auth, Firestore, Functions, Remote Config, Crashlytics) ✅ Écosystème cohérent, intégrations natives Flutter
- **Dual-engine OCR** (Google Vision Cloud + ML Kit on-device) ✅ Stratégie fallback robuste, circuit breaker prévient dépassement quota
- **Gemini AI** (Vision + Chat) ✅ Intégration via Cloud Functions proxy sécurise API keys
- **Offline-first Hive ↔ Firestore** ✅ Sync bidirectionnelle avec conflict resolution (Last-Write-Wins timestamp authoritative) bien architecturée
- **Feature flags Remote Config** ✅ Freemium gating (6 gratuits / 8 premium) intégré au niveau architectural

Aucun conflit de versions ni incompatibilité détectée. Stack homogène et éprouvé pour applications Flutter offline-first.

**Pattern Consistency:**

Les patterns d'implémentation supportent intégralement les décisions architecturales :
- **Feature-First + Clean Architecture** ✅ Appliqué uniformément aux 14 modules avec isolation stricte (domain/data/presentation)
- **Repository pattern** ✅ Interfaces domain + implémentations data cohérentes avec dependency injection Riverpod
- **Riverpod state management** ✅ Immutabilité stricte, provider scoping (global/feature/screen), AsyncValue pattern pour async data
- **Error handling hierarchy** ✅ AppException → NetworkException/APIException/ValidationException standardisée, Either pattern (dartz) pour repositories
- **Naming conventions** ✅ Dart standard (UpperCamelCase classes, lowerCamelCase vars/functions, snake_case files) + Firestore camelCase alignés
- **Testing patterns** ✅ Structure mirror lib/, pyramide 75% coverage (70% unit, 20% widget, 10% E2E), mock infrastructure

**20 points de conflit critiques** identifiés et résolus avec directives d'enforcement (flutter analyze, coverage gates, PR checklists).

**Structure Alignment:**

La structure projet supporte entièrement l'architecture définie :
- **14 modules Feature-First isolés** ✅ Chaque module = bounded context avec domain/data/presentation complets
- **8 couches transversales core/** ✅ Auth, data_sync, networking, storage, feature_flags, monitoring, compliance, routing séparés
- **Boundaries architecturales strictes** ✅ Communication inter-features UNIQUEMENT via Riverpod providers exposure, navigation GoRouter, events analytics (découplage total)
- **Atomic Design widgets** ✅ Réutilisabilité maximale (atoms/molecules/organisms) dans core/shared/widgets/
- **Tests mirror structure** ✅ test/features/{module}/ ↔ lib/features/{module}/ facilite TDD et maintenance
- **Firebase Cloud Functions séparées** ✅ firebase/functions/ avec endpoints OCR, Gemini, Prix isolés du code Flutter

Structure complète 257 lignes détaillée (lib/, test/, assets/, firebase/, scripts/, docs/) prête pour scaffolding.

### Requirements Coverage Validation ✅

**Functional Requirements Coverage (85 FRs):**

Mapping complet Requirements → Modules architecturaux :

1. **Inventaire (10 FRs)** ✅ Module `features/inventory/` - CRUD produits, catégorisation (12 catégories), 6 emplacements, états (frais/péremption/consommé), filtres multi-critères
2. **OCR Scan (5 FRs)** ✅ Module `features/ocr_scan/` - Dual-engine (Google Vision + ML Kit), reconnaissance EAN-13, enrichissement OpenFoodFacts, correction manuelle
3. **Notifications (6 FRs)** ✅ Module `features/notifications/` - Alertes DLC/DDM différenciées, configuration délais, quiet hours, suggestions recettes contextuelles
4. **Recettes (6 FRs)** ✅ Module `features/recipes/` - Matching inventaire temps réel, filtres (budget/temps/difficulté/régime), tutoriels, favoris
5. **Planning IA (6 FRs)** ✅ Module `features/meal_planning/` - Génération hebdomadaire Gemini, contraintes nutritionnelles, optimisation anti-gaspi, liste courses auto
6. **Nutrition Tracking (8 FRs)** ✅ Modules `features/nutrition_tracking/` + `features/nutrition_profiles/` - 12 profils, TDEE/BMR, tracking calories/macros, Gemini Vision reconnaissance photo repas, chatbot IA
7. **Comparateur Prix (6 FRs)** ✅ Module `features/price_comparator/` - 4+ enseignes, économies potentielles, Google Maps, parcours optimisé, export liste
8. **Dashboard (6 FRs)** ✅ Module `features/dashboard/` - Gaspillage évité (kg/€), économies, impact CO2eq, graphiques, stats nutrition
9. **Gamification (5 FRs)** ✅ Module `features/gamification/` - Achievements/badges, streaks, leaderboard opt-in, défis personnalisés
10. **Auth & Profil (6 FRs)** ✅ Module `features/auth_profile/` + `core/auth/` - Firebase Auth (Email/OAuth), profil, préférences allergies, sync multi-devices, export RGPD
11. **Partage (4 FRs)** ✅ Module `features/family_sharing/` - Inventaire partagé, partage recettes/plannings, export PDF, liste courses collaborative
12. **RGPD (7 FRs)** ✅ `core/compliance/` - Disclaimers, double opt-in santé, retrait consentement <30j, encryption AES-256, gestion consentements granulaires
13. **Accessibilité (5 FRs)** ✅ Intégré architecture - Onboarding adaptatif, tutoriels interactifs, tooltips, mode senior (core/theme/), offline-first 100%
14. **Freemium (5 FRs)** ✅ `core/feature_flags/` - Remote Config, 6 gratuits/8 premium, essai 7j, annulation facile, tableau comparatif

**Couverture 100% des 85 FRs** avec mapping précis Requirements → Modules Feature-First.

**Non-Functional Requirements Coverage (44 NFRs):**

**Performance (7 NFRs)** ✅ Architecturalement supporté :
- OCR <2s : Dual-engine avec circuit breaker, compression images, parallel processing
- App launch <3s : Lazy loading modules (deferred imports), code splitting, warm caches
- Offline-first sans dégradation : Architecture state-first, Hive local DB, sync background
- Réactivité UI <100ms : AsyncValue Riverpod, shimmer placeholders, optimistic UI
- Gemini génération <10s : Cloud Functions async, queue requests throttling

**Sécurité (6 NFRs)** ✅ Architecturalement supporté :
- Encryption AES-256 : Hive encrypted boxes (nutrition_data_box, health_profiles_box), Firestore at-rest native
- TLS 1.3+ : Firestore/Functions transport encryption automatique
- Auth Firebase + OAuth2 + 2FA premium : `core/auth/` intégré
- API keys protection : Cloud Functions proxy, rotation 90j, jamais exposées client
- Sanitization entrées : Validation client (flutter_form_builder) + server-side (Cloud Functions triggers)
- Double opt-in RGPD Article 9 : `core/compliance/consent_manager.dart`

**Scalabilité (5 NFRs)** ✅ Architecturalement supporté :
- 10K-100K MAU : Firestore auto-scaling, Cloud Functions horizontal scaling
- Inventaire 1000 produits/user : Pagination Firestore limit(50) + startAfter, ListView.builder
- Base 10K+ recettes : Full-text search Firestore, cache local Hive
- Budget <500€/mois : Circuit breakers quotas (Vision API 80%, Gemini throttling), Firebase free tier optimisé

**Fiabilité (6 NFRs)** ✅ Architecturalement supporté :
- Uptime 99.5% : Firebase infrastructure SLA
- Crash-free >99.9% : Crashlytics monitoring, staged rollouts (5%→25%→100%), rollback auto si crash >0.5%
- Resilience APIs : Fallbacks (Vision→ML Kit, OpenFoodFacts→cache local, Gemini→throttling graceful)
- Sync offline-online : Conflict resolution LWW timestamp, retry exponential backoff, WorkManager/BackgroundTasks
- Backup quotidien : Firestore automated backups, RTO 4h

**Intégration (7 NFRs)** ✅ Architecturalement supporté :
- Quota monitoring : Circuit breakers custom (VisionAPICircuitBreaker), Firestore compteurs
- Retry logic : dio_retry_interceptor (1s, 2s, 4s max 4 retries), exponential backoff
- Timeouts : Auth 10s, Firestore 5s, Functions 30s configurés
- Cache strategies : OpenFoodFacts TTL 7j, Gemini in-memory LRU 100 réponses, Prix 24h

**Accessibilité (4 NFRs)** ✅ Architecturalement supporté :
- WCAG 2.1 Niveau A : Contraste 4.5:1 Material 3, alt text, navigation clavier
- Mode Senior : `core/theme/` texte +30%, boutons ≥48dp, contraste élevé
- i18n préparé : assets/translations/ (fr.arb, en.arb future)
- Screen readers : TalkBack/VoiceOver semantic widgets Flutter

**Utilisabilité (4 NFRs)** ✅ Architecturalement supporté :
- Onboarding <2min : Riverpod state, max 5 écrans, profils adaptatifs
- Feedback visuel : AsyncValue loading states, CircularProgressIndicator, shimmer placeholders, messages erreur explicites FR
- Cohérence Material 3 / HIG : `core/theme/app_theme.dart` centralisé

**Maintenabilité (5 NFRs)** ✅ Architecturalement supporté :
- Coverage ≥75% : CI/CD quality gate GitHub Actions (.github/workflows/pr_checks.yml), merge bloqué si <75%
- Staged rollouts : Fastlane (Play Store 5%→25%→100%, App Store phased release)
- Monitoring : Crashlytics + Firebase Performance + Analytics, alertes auto (crash +50%, API errors >5%)
- Hotfix <24h : CI/CD workflows production_deploy.yml, rollback automatique
- Documentation : Dartdoc, ADRs (architecture.md = source de vérité)

**Couverture 100% des 44 NFRs** avec décisions architecturales précises pour chaque requirement.

### Implementation Readiness Validation ✅

**Decision Completeness:**

✅ **Stack technologique complet avec versions précises** :
- Frontend : Flutter 3.32, Dart 3.5+, Riverpod 2.6+, GoRouter 14.x, Hive 2.x
- Backend : Firebase (Auth, Firestore, Cloud Functions Node.js 20, Cloud Storage, Remote Config, Crashlytics)
- APIs : Google Cloud Vision API, ML Kit, Gemini AI (Vision + Chat), OpenFoodFacts, Google Maps
- Packages clés : freezed, json_serializable, dartz (Either pattern), dio + dio_retry_interceptor, flutter_form_builder, cached_network_image, shimmer

✅ **Architecture data détaillée** :
- Firestore collections définies : users/{userId}/inventory_items, meal_plans, nutrition_tracking, shared/recipes, price_data
- Hive boxes spécifiés : inventory_box, nutrition_data_box (encrypted AES-256), recipes_box, settings_box, sync_queue_box
- Sync strategy précise : Optimistic UI, Last-Write-Wins timestamp, conflict resolution, retry exponential backoff
- Cache strategies : OpenFoodFacts TTL 7j LRU 1000 produits, Gemini in-memory LRU 100, Prix 24h

✅ **Patterns API/Communication complets** :
- Cloud Functions endpoints : POST /ocr-process-ticket, /gemini-analyze-meal, /gemini-generate-meal-plan, GET /sync-price-data (scheduled)
- Error responses standardisés : {success: bool, data/error: object, timestamp: ISO8601}
- Exception hierarchy : AppException → NetworkException/APIException/ValidationException/QuotaExceededException
- Rate limiting : Gemini 60 req/min, Vision API circuit breaker 80%, Cloud Functions 100 req/min/user

✅ **Infrastructure CI/CD définie** :
- GitHub Actions workflows : pr_checks.yml (analyze + test >75%), staging_deploy.yml (Firebase App Distribution), production_deploy.yml (staged rollouts)
- Build flavors : dev/staging/prod avec Firebase projects séparés
- Environment variables : .env.dev/.staging/.prod (flutter_dotenv)
- Monitoring : Crashlytics → migration Sentry future, Firebase Performance, Analytics événements business

✅ **Exemples de code concrets** fournis pour tous patterns critiques (Feature Inventory complet, error handling, state management, retry logic, circuit breaker).

**Structure Completeness:**

✅ **Arborescence projet complète 257 lignes** détaillant :
- `lib/core/` : 8 couches transversales (auth, data_sync, networking, storage, feature_flags, monitoring, compliance, routing, theme, shared)
- `lib/features/` : 14 modules Feature-First avec template domain/data/presentation pour chaque
- `test/` : Structure mirror + test_helpers/, integration_test/
- `assets/` : images/, fonts/, translations/ (fr.arb, en.arb)
- `firebase/` : functions/ (TypeScript), firestore.rules, firestore.indexes.json, storage.rules
- `.github/workflows/` : 3 workflows CI/CD
- Configuration files : pubspec.yaml, analysis_options.yaml, .env.{dev,staging,prod}, flavors Android/iOS

✅ **Tous fichiers critiques définis** avec organisation précise (255 fichiers/dossiers explicitement listés).

✅ **Boundaries architecturales spécifiées** :
- API Boundaries : Cloud Functions endpoints + Firestore collections schema
- Component Boundaries : Feature module isolation stricte, communication via providers/navigation/events
- Service Boundaries : Core singletons Riverpod (AuthService, SyncService, RemoteConfigService)
- Data Boundaries : Firestore Security Rules user-scoped, Hive boxes encrypted/non-encrypted

**Pattern Completeness:**

✅ **20 points de conflit critiques** résolus avec patterns explicites :
1. Naming conventions (Dart, Firestore, API, Riverpod) ✅
2. Structure Feature-First stricte ✅
3. Test structure mirror ✅
4. JSON camelCase ✅
5. Dates ISO 8601 ✅
6. Exception hierarchy AppException ✅
7. AsyncValue pour async data ✅
8. Analytics events snake_case ✅
9. Either<Error, Success> repositories ✅
10. Retry exponential backoff ✅
11. Circuit breaker quotas ✅
12. User-facing error messages FR ✅
13. Structured logging JSON ✅
14. Riverpod state immutabilité stricte ✅
15. Firestore real-time listeners pattern ✅
16. Loading states standardisés ✅
17. Format API responses ✅
18. Sérialisation modèles (freezed + json_serializable) ✅
19. Atomic Design widgets ✅
20. State Management boundaries (global/feature/screen scopes) ✅

✅ **Enforcement automatique configuré** :
- flutter analyze : Linting strict (analysis_options.yaml)
- flutter test --coverage : Quality gate >75% bloque merge
- dart format : Auto-formatting 80 chars
- PR template checklist : Vérification patterns en code review

✅ **Exemples concrets ✅ + Anti-patterns ❌** documentés pour chaque pattern majeur.

### Gap Analysis Results

**✅ Aucun Gap Critique Détecté**

Toutes les décisions architecturales bloquantes pour l'implémentation sont documentées avec précision suffisante. L'équipe de développement peut démarrer Epic 0 (Infrastructure Setup) immédiatement.

**⚠️ Gaps Importants (Non-Bloquants pour Démarrage) :**

**Gap 1 : Firestore Security Rules Détaillées**
- **Statut actuel** : Exemples génériques fournis (user-scoped read/write, shared collections read-only)
- **Manque** : Rules spécifiques pour chaque collection (inventory_items, meal_plans, nutrition_tracking, achievements) avec conditions granulaires
- **Impact** : Sécurité potentiellement insuffisante en production
- **Action recommandée** : Écrire `firebase/firestore.rules` complètes avec rules par collection et tests associés
- **Timeline** : Epic 0-1 (Semaines 2-3)
- **Priorité** : Importante (sécurité)

**Gap 2 : Composite Indexes Firestore**
- **Statut actuel** : Indexes mentionnés (category + expirationDate, status + location)
- **Manque** : Fichier `firestore.indexes.json` complet pour toutes queries complexes
- **Impact** : Queries lentes ou échouées en production si indexes manquants
- **Action recommandée** : Identifier toutes queries Firestore composites, générer indexes.json, tester en staging
- **Timeline** : Epic 1 (Semaine 3)
- **Priorité** : Importante (performance)

**Gap 3 : Cloud Functions Payload Validation Schemas**
- **Statut actuel** : Endpoints définis (/ocr-process-ticket, /gemini-analyze-meal, /sync-price-data) avec exemples request/response
- **Manque** : JSON Schemas validation stricte (ajv package), timeout configs, memory limits, error handling détaillé
- **Impact** : Vulnérabilités sécurité (injection), erreurs runtime Cloud Functions
- **Action recommandée** : Implémenter middleware validation ajv pour chaque endpoint, configurer timeouts/memory par fonction
- **Timeline** : Epic 2-4 (Semaines 7-11 selon feature)
- **Priorité** : Importante (sécurité + fiabilité)

**Gap 4 : OpenAPI Spec Cloud Functions**
- **Statut actuel** : Documentation JSDoc mentionnée
- **Manque** : OpenAPI 3.0 spec formelle générée (swagger_dart_code_generator)
- **Impact** : Documentation API moins claire pour développeurs
- **Action recommandée** : Générer openapi.yaml à partir des Cloud Functions, publier docs
- **Timeline** : Epic 2 (Semaine 7)
- **Priorité** : Moyenne (documentation)

**💡 Gaps Nice-to-Have (Optimisations Futures, Non-Urgents) :**

**Gap 5 : Performance Budgets Précis**
- **Statut actuel** : Optimisations définies (lazy loading, code splitting, pagination)
- **Manque** : Budgets numériques stricts (APK size <50MB, IPA <60MB, memory max heap 256MB, FPS ≥60)
- **Impact** : Risque dérive performance sans métriques claires
- **Action recommandée** : Définir budgets, monitorer CI/CD (size-limit package), alertes si dépassement
- **Timeline** : Epic 7 (Semaine 23)
- **Priorité** : Basse (optimisation)

**Gap 6 : A/B Testing Strategy**
- **Statut actuel** : Firebase Remote Config prévu pour feature flags
- **Manque** : Stratégie A/B testing formelle (quels tests, métriques success, rollout percentages)
- **Impact** : Difficile optimiser conversion freemium sans A/B testing structuré
- **Action recommandée** : Définir A/B tests prioritaires (onboarding flows, paywall UI, pricing), intégrer Firebase A/B Testing
- **Timeline** : Post-MVP (Semaine 25+)
- **Priorité** : Basse (croissance)

**Gap 7 : Analytics Dashboard Business**
- **Statut actuel** : Événements Firebase Analytics définis (scan_ticket_success, subscribe_premium, etc.)
- **Manque** : Dashboard business custom (DAU/MAU, conversion funnel, rétention D7/D30, LTV)
- **Impact** : Visibilité limitée métriques business clés
- **Action recommandée** : Configurer BigQuery export Firebase Analytics, créer dashboard Looker Studio ou Metabase
- **Timeline** : Post-MVP (Semaine 26+)
- **Priorité** : Basse (analytics)

**Gap 8 : Penetration Testing & Security Audit**
- **Statut actuel** : Sécurité architecturale bien définie (encryption, auth, sanitization)
- **Manque** : Audit sécurité externe (pentest) avant production
- **Impact** : Vulnérabilités potentielles non détectées
- **Action recommandée** : Contracter pentest professionnel pré-production (semaine 23)
- **Timeline** : Epic 7 (Semaine 23)
- **Priorité** : Importante (sécurité production)

### Validation Issues Addressed

**✅ Aucune Issue Critique Bloquante**

L'analyse de validation n'a révélé aucun conflit architectural, incohérence majeure, ou gap critique empêchant le démarrage de l'implémentation.

**⚠️ Issues Importantes (Non-Bloquantes) Identifiées et Résolues :**

**Issue 1 : Absence de séquence d'implémentation prioritaire**
- **Problème** : Sans ordre d'implémentation clair, risque d'implémenter features premium avant core infrastructure
- **Résolution** : Séquence Epic 0-7 définie dans section "Analyse d'Impact des Décisions"
  - Epic 0 : Infrastructure (Semaines 1-2)
  - Epic 1 : Auth & Data Sync (Semaines 2-3)
  - Epic 2 : MVP Tier 1 - Modules gratuits (Semaines 4-6)
  - Epic 3-4 : MVP Tier 2-3 (Semaines 7-11)
  - Epic 5-7 : Premium Features + Production Readiness (Semaines 12-24)
- **Statut** : ✅ Résolu

**Issue 2 : Manque de détails sur dépendances inter-composants**
- **Problème** : Modules interdépendants pourraient bloquer implémentation si ordre incorrect
- **Résolution** : Dépendances inter-composants documentées dans section "Analyse d'Impact"
  - Auth → Tous modules (subscription status requis feature flags)
  - Data Sync → Offline-first (base pour tous modules)
  - Notifications → Modules métier (alertes péremption, suggestions recettes, rappels planning)
  - Analytics → Cross-features (tracking événements business)
  - Feature Flags → Modules Premium (gating logique)
- **Statut** : ✅ Résolu

**Issue 3 : Communication inter-features pas assez explicite**
- **Problème** : Feature-First isolation stricte pourrait bloquer communication légitimes (ex: Recipes → Inventory pour matching)
- **Résolution** : Boundaries architecturales section "Component Boundaries" clarifie :
  - ❌ INTERDIT : Import direct cross-features
  - ✅ CORRECT : Communication via core/shared providers, navigation GoRouter, events analytics
  - Exemple concret fourni (selectedRecipeProvider global)
- **Statut** : ✅ Résolu

**💡 Suggestions Mineures (Améliorations Optionnelles) :**

**Suggestion 1 : Ajouter diagrammes architecture**
- **Opportunité** : Diagrammes C4 (Context, Container, Component, Code) faciliteraient compréhension globale
- **Action** : Générer diagrammes PlantUML ou Mermaid (architecture overview, data flow, sync sequence)
- **Priorité** : Basse (documentation visuelle)

**Suggestion 2 : Documenter patterns migration données**
- **Opportunité** : Évolutions schema Firestore/Hive futures nécessiteront migrations
- **Action** : Définir stratégie migration (Firestore Cloud Functions triggers, Hive version adapters)
- **Priorité** : Basse (future-proofing)

**Suggestion 3 : Ajouter decision records (ADRs) formels**
- **Opportunité** : ADRs (Architecture Decision Records) traceraient historique décisions + rationales
- **Action** : Créer docs/adr/ avec template ADR (contexte, décision, conséquences, alternatives)
- **Priorité** : Basse (documentation historique)

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Projet contexte analysé (85 FRs + 44 NFRs documentés)
- [x] Échelle et complexité évaluée (Medium-High, 14 modules, offline-first, IA multi-modèle)
- [x] Contraintes techniques identifiées (quotas APIs Google Vision/Gemini, budget infra <500€/mois, RGPD Article 9)
- [x] Cross-cutting concerns mappées (8 préoccupations : offline-first, RGPD, feature flags freemium, performance SLA, resilience APIs, sécurité multi-niveaux, testing pyramide, observabilité business)

**✅ Architectural Decisions**
- [x] Décisions critiques documentées avec versions (Flutter 3.32, Riverpod 2.6+, GoRouter 14.x, Hive 2.x, Firebase suite)
- [x] Technology stack complet spécifié (Frontend, Backend, APIs externes, packages clés)
- [x] Integration patterns définis (Cloud Functions proxy, Firestore SDK, dual-engine OCR, cache strategies)
- [x] Performance considerations adressées (lazy loading, code splitting, pagination, circuit breakers, offline-first)

**✅ Implementation Patterns**
- [x] Naming conventions établies (Dart standard, Firestore camelCase, API kebab-case, Riverpod providers, analytics snake_case)
- [x] Structure patterns définis (Feature-First stricte 14 modules, Clean Architecture domain/data/presentation, Atomic Design widgets)
- [x] Communication patterns spécifiés (Riverpod immutabilité, AsyncValue, Firestore listeners, analytics events)
- [x] Process patterns documentés (AppException hierarchy, Either pattern, retry exponential backoff, circuit breakers, loading states)

**✅ Project Structure**
- [x] Structure complète définie (257 lignes détaillées lib/, test/, assets/, firebase/, .github/, scripts/, docs/)
- [x] Component boundaries établies (Feature modules isolation, core services séparés, boundaries API/Component/Service/Data)
- [x] Integration points mappés (Cloud Functions endpoints, Firestore collections, External APIs, provider exposure)
- [x] Requirements to structure mapping complet (85 FRs → 14 modules Feature-First, 44 NFRs → décisions architecturales)

### Architecture Readiness Assessment

**Overall Status: ✅ READY FOR IMPLEMENTATION**

**Confidence Level: 🟢 ÉLEVÉ (95/100)**

**Justification du Niveau de Confiance :**
- Architecture cohérente avec stack homogène éprouvé (Flutter + Firebase + Hive)
- Couverture 100% des requirements (85 FRs + 44 NFRs mappés précisément)
- Patterns d'implémentation complets avec 20 conflict points résolus
- Structure projet détaillée (257 lignes) prête pour scaffolding
- Gaps identifiés sont non-bloquants (Security Rules, Indexes, Validation Schemas à compléter en Epic 0-1)
- Séquence d'implémentation Epic 0-7 claire avec timeline 24 semaines
- Enforcement automatique (CI/CD quality gates flutter analyze + coverage >75%)

**Seuls 5% de risque résiduel** liés à :
- Complexité technique dual-engine OCR (Google Vision + ML Kit fallback)
- Performance cible OCR <2s (95e percentile) - nécessitera optimisations itératives
- Conformité RGPD Article 9 données santé - audit légal externe recommandé pré-production

**Key Strengths:**

1. **🎯 Architecture Feature-First Stricte & Scalable**
   - 14 modules isolés avec Clean Architecture (domain/data/presentation) permettent développement parallèle sans conflits
   - Boundaries architecturales strictes (communication via providers/navigation/events) garantissent découplage
   - Ajout/désactivation modules via feature flags sans refactoring

2. **💾 Offline-First Robuste & Performant**
   - Dual storage Hive (local) ↔ Firestore (cloud) avec sync bidirectionnelle automatique
   - Conflict resolution LWW timestamp authoritative éprouvée
   - Optimistic UI + background sync = UX fluide même hors ligne
   - Fallbacks APIs multiples (Vision→ML Kit, OpenFoodFacts→cache, Gemini→throttling) = résilience maximale

3. **🔒 Sécurité RGPD-Compliant by Design**
   - Encryption AES-256 données santé (Hive encrypted boxes + Firestore at-rest)
   - Double opt-in Article 9 + consent management + droit oubli <30j architecture
   - API keys JAMAIS exposées client (Cloud Functions proxy)
   - Security Rules Firestore user-scoped + Storage rules + input sanitization

4. **💰 Freemium Architecture-Ready**
   - Feature flags Remote Config intégrés dès architecture (6 gratuits / 8 premium)
   - Guard Widgets PremiumFeatureGuard réutilisables
   - A/B testing infrastructure préparée (Remote Config)
   - Conversion funnel analytics événements déjà définis

5. **⚡ Performance Optimizations Intégrées**
   - Lazy loading modules (deferred imports) = app launch <3s
   - Code splitting automatique Flutter (--split-debug-info)
   - Pagination Firestore (limit 50 + startAfter) = scrolling fluide 1000+ produits
   - Circuit breakers quotas APIs (Vision 80%, Gemini throttling) = coûts maîtrisés
   - Caching agressif (OpenFoodFacts TTL 7j, Gemini in-memory LRU, Prix 24h)

6. **🧪 Testability-First avec Enforcement Automatique**
   - Structure tests mirror lib/ = TDD facilité
   - Pyramide 75% coverage obligatoire (70% unit, 20% widget, 10% E2E)
   - CI/CD quality gates bloquent merge si <75% ou flutter analyze errors
   - Mock infrastructure définie (test_helpers/, mock repositories/providers)

7. **📊 Observabilité & Monitoring Complets**
   - Crashlytics + Firebase Performance + Analytics = visibilité complète
   - Événements business custom (scan_ticket, subscribe_premium, conversion funnel)
   - Alertes automatiques (crash rate +50%, API errors >5%, quota warnings 80%)
   - Staged rollouts (5%→25%→100%) + rollback auto si crash >0.5%

8. **📐 20 Conflict Points Résolus avec Patterns Explicites**
   - Naming (Dart/Firestore/API), structure (Feature-First), tests (mirror), JSON (camelCase), dates (ISO 8601)
   - Error handling (AppException hierarchy + Either pattern), state management (immutabilité stricte Riverpod)
   - Retry logic (exponential backoff), circuit breakers, loading states (AsyncValue)
   - Exemples concrets ✅ + anti-patterns ❌ documentés = guidance claire pour agents IA

**Areas for Future Enhancement (Post-MVP):**

1. **🔍 Analytics Dashboard Business Custom**
   - BigQuery export Firebase Analytics + dashboard Looker Studio/Metabase
   - Métriques business clés (DAU/MAU, conversion funnel, rétention D7/D30/M6, LTV, churn)
   - Timeline : Semaine 26+

2. **🧪 A/B Testing Strategy Formalisée**
   - Tests prioritaires : onboarding flows, paywall UI variations, pricing tiers, feature discovery
   - Firebase A/B Testing intégration + métriques success définies
   - Timeline : Semaine 25+

3. **🛡️ Penetration Testing & Security Audit Externe**
   - Pentest professionnel pré-production (OWASP Top 10, injection, auth bypass, data leaks)
   - Audit conformité RGPD Article 9 par cabinet spécialisé
   - Timeline : Semaine 23

4. **📈 Performance Budgets Numériques Stricts**
   - APK size <50MB, IPA <60MB, memory max heap 256MB, FPS ≥60, network requests <100/session
   - Monitoring CI/CD (size-limit package), alertes si dépassement
   - Timeline : Semaine 23

5. **🌍 Internationalisation EN/NL/DE**
   - i18n Flutter préparé (assets/translations/), ajout locales EN/NL/DE année 2
   - Adaptation culturelle (formats dates/nombres, devises, disclaimers légaux localisés)
   - Timeline : Année 2

6. **🔗 Intégration Frigos Connectés (IoT)**
   - APIs Samsung SmartThings, LG ThinQ pour inventaire automatique
   - Vision future année 2-3 mentionnée dans PRD
   - Timeline : Année 2-3

7. **📊 Migration Crashlytics → Sentry**
   - Sentry meilleures stack traces, release tracking, performance monitoring
   - Migration prévue post-MVP
   - Timeline : Année 2

8. **🎨 Diagrammes Architecture C4**
   - Context, Container, Component, Code (PlantUML ou Mermaid)
   - Facilite onboarding nouveaux développeurs
   - Timeline : Optionnel (documentation visuelle)

### Implementation Handoff

**AI Agent Guidelines:**

**🎯 Source de Vérité Unique : `architecture.md`**
- Toutes les décisions architecturales sont documentées dans CE document
- En cas de doute, TOUJOURS se référer à architecture.md AVANT d'implémenter
- Ne JAMAIS deviner ou improviser patterns - ils sont tous spécifiés ici

**📐 Respecter Feature-First Stricte :**
- Chaque module `lib/features/{module}/` = bounded context isolé avec domain/data/presentation complets
- ❌ INTERDIT : Import direct cross-features (`import 'package:frigofute_v2/features/recipes/...'`)
- ✅ CORRECT : Communication via `core/shared` providers, navigation GoRouter, events analytics

**✅ Appliquer Patterns Sans Exception :**
- **Naming** : UpperCamelCase classes, lowerCamelCase vars/functions, snake_case files, camelCase JSON
- **Error handling** : AppException hierarchy + Either<Error, Success> pattern (dartz)
- **State management** : Riverpod immutabilité stricte (state = [...state, newItem], JAMAIS state.add())
- **Async data** : AsyncValue pattern (FutureProvider/StreamProvider), PAS bool isLoading manuels
- **Tests** : Mirror structure lib/ → test/, suffix _test.dart, pyramide 75% coverage obligatoire

**🧪 Tests Obligatoires >75% Coverage :**
- CI/CD GitHub Actions bloquera merge PR si coverage <75% ou flutter analyze errors
- Pyramide : 70% unit tests, 20% widget/integration tests, 10% E2E tests
- Utiliser mock_repositories, mock_providers, test_data_factories de test_helpers/

**📖 Lire Sections Pertinentes Avant Implémentation :**
- **Section "Patterns de Nommage"** avant créer classes/fichiers/providers
- **Section "Patterns de Structure"** avant organiser feature module
- **Section "Patterns de Processus"** avant implémenter error handling/retry logic
- **Section "Exemples Concrets"** pour voir ✅ bon code vs ❌ anti-patterns

**🚨 Enforcement Automatique Configuré :**
- `flutter analyze` : Linting strict (analysis_options.yaml) obligatoire avant commit
- `flutter test --coverage` : Quality gate >75%
- `dart format` : Auto-formatting 80 chars, pre-commit hook recommandé
- PR template checklist : Vérification patterns en code review

**First Implementation Priority:**

**🚀 Epic 0 - Infrastructure Setup (Semaines 1-2)**

**Étape 1 : Initialiser Projet Flutter**
```bash
# Créer projet Flutter multi-platform
flutter create --org com.frigofute --platforms ios,android frigofute_v2
cd frigofute_v2

# Vérifier installation
flutter doctor -v
flutter --version  # Doit être >= 3.32
```

**Étape 2 : Setup Structure Feature-First Manuelle**
```bash
# Créer structure lib/core/
mkdir -p lib/core/{auth,data_sync,networking,storage,feature_flags,monitoring,compliance,routing,theme,shared}
mkdir -p lib/core/shared/{utils,extensions,constants,exceptions,widgets/{atoms,molecules,organisms}}

# Créer 14 modules features/
mkdir -p lib/features/{inventory,ocr_scan,notifications,dashboard,auth_profile,recipes,nutrition_tracking,nutrition_profiles,meal_planning,ai_coach,gamification,shopping_list,family_sharing,price_comparator}

# Pour chaque feature, créer structure Clean Architecture
# Exemple pour inventory :
mkdir -p lib/features/inventory/{domain/{entities,repositories,usecases},data/{models,datasources,repositories},presentation/{providers,screens,widgets}}

# Structure tests mirror
mkdir -p test/core test/features test/integration_test test/test_helpers
```

**Étape 3 : Configurer Firebase Projects (Dev/Staging/Prod)**
```bash
# Installer Firebase CLI
npm install -g firebase-tools
firebase login

# Créer 3 projets Firebase (console.firebase.google.com)
# - frigofute-dev
# - frigofute-staging
# - frigofute-prod

# Initialiser Firebase Flutter
flutterfire configure --project=frigofute-dev --platforms=ios,android --out=lib/firebase_options_dev.dart
flutterfire configure --project=frigofute-staging --platforms=ios,android --out=lib/firebase_options_staging.dart
flutterfire configure --project=frigofute-prod --platforms=ios,android --out=lib/firebase_options_prod.dart

# Ajouter firebase_core, cloud_firestore, firebase_auth au pubspec.yaml
flutter pub add firebase_core cloud_firestore firebase_auth firebase_storage firebase_remote_config firebase_crashlytics firebase_analytics
```

**Étape 4 : Initialiser Hive + TypeAdapters**
```dart
// lib/core/storage/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Enregistrer TypeAdapters
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(RecipeModelAdapter());

    // Ouvrir boxes
    await Hive.openBox('inventory_box');
    await Hive.openBox('recipes_box');
    await Hive.openBox('settings_box');

    // Boxes encryptées (données santé)
    final encryptionKey = await _getOrCreateEncryptionKey();
    await Hive.openBox('nutrition_data_box', encryptionCipher: HiveAesCipher(encryptionKey));
  }
}

// Ajouter hive, hive_flutter au pubspec.yaml
flutter pub add hive hive_flutter
flutter pub add --dev hive_generator build_runner
```

**Étape 5 : Setup CI/CD GitHub Actions Basique**
```yaml
# .github/workflows/pr_checks.yml
name: PR Checks
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - name: Check coverage
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 75" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 75% threshold"
            exit 1
          fi
```

**Étape 6 : Configurer analysis_options.yaml (Linting Strict)**
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_final_fields
    - unnecessary_this
    - sort_pub_dependencies
    - always_declare_return_types
    - avoid_print
    - prefer_single_quotes

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
```

**Étape 7 : Initialiser Riverpod + Providers Basiques**
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Init Hive
  await HiveService.init();

  runApp(
    const ProviderScope(
      child: FrigoFuteApp(),
    ),
  );
}

// Ajouter flutter_riverpod au pubspec.yaml
flutter pub add flutter_riverpod
```

**✅ Livrables Epic 0 :**
- [x] Projet Flutter initialisé avec structure Feature-First complète (14 modules)
- [x] Firebase projects créés (dev/staging/prod) + FlutterFire configuré
- [x] Hive initialisé avec boxes + TypeAdapters basiques
- [x] CI/CD GitHub Actions avec quality gates (analyze + coverage >75%)
- [x] Linting strict configuré (analysis_options.yaml)
- [x] Riverpod ProviderScope setup dans main.dart

**📌 Durée Estimée Epic 0 : 1-2 semaines** (setup infrastructure)

**🎯 Epic 1 Suivant : Core Auth & Data Sync (Semaines 2-3)**
- Implémentation `lib/core/auth/` (Firebase Auth + OAuth2 Google/Apple)
- Implémentation `lib/core/data_sync/` (SyncService, ConflictResolver, SyncQueue)
- Repository pattern base classes + Either<Error, Success>
- Error handling hierarchy (AppException → NetworkException/APIException)
- Tests coverage >75% pour core services

**📚 Références Implémentation :**
- Architecture patterns : Voir section "Patterns d'Implémentation & Règles de Cohérence" (lignes 677-1429)
- Structure détaillée : Voir section "Structure Projet & Boundaries Architecturales" (lignes 1430+)
- Décisions tech : Voir section "Décisions Architecturales Principales" (lignes 286-676)
- Exemples code : Voir "Exemples Concrets" (lignes 1311-1428)

---

**🚀 L'ARCHITECTURE EST VALIDÉE ET PRÊTE POUR IMPLÉMENTATION !**
