---
stepsCompleted: [1, 2, 3, 4]
completedAt: '2026-02-14'
totalEpics: 17
totalStories: 155
totalFRs: 85
totalNFRs: 43
additionalRequirements: 31
status: 'complete'
inputDocuments:
  - "_bmad-output/planning-artifacts/prd.md"
  - "_bmad-output/planning-artifacts/architecture.md"
  - "_bmad-output/planning-artifacts/ux-design-specification.md"
  - "_bmad-output/brainstorming/brainstorming-session-2026-02-12.md"
---

# FrigoFuteV2 - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for FrigoFuteV2, decomposing the requirements from the PRD, UX Design, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

**1. Gestion d'Inventaire Alimentaire (10 FRs)**

- **FR1:** Les utilisateurs peuvent ajouter des produits alimentaires à leur inventaire en scannant un code-barres
- **FR2:** Les utilisateurs peuvent ajouter des produits alimentaires à leur inventaire via scan OCR de ticket de caisse
- **FR3:** Les utilisateurs peuvent ajouter des produits alimentaires manuellement (nom, catégorie, quantité, date péremption, emplacement)
- **FR4:** Les utilisateurs peuvent modifier les informations d'un produit existant dans l'inventaire
- **FR5:** Les utilisateurs peuvent supprimer un produit de leur inventaire
- **FR6:** Les utilisateurs peuvent visualiser leur inventaire complet avec filtres par catégorie, emplacement, et statut
- **FR7:** Le système catégorise automatiquement les produits scannés parmi 12 catégories prédéfinies
- **FR8:** Le système assigne automatiquement un emplacement de stockage parmi 6 emplacements disponibles lors de l'ajout de produits
- **FR9:** Les utilisateurs peuvent marquer un produit comme consommé pour le retirer de l'inventaire actif
- **FR10:** Le système suit l'état de chaque produit (frais, à consommer bientôt, périmé, consommé)

**2. Acquisition de Données Produits (5 FRs)**

- **FR11:** Le système reconnaît et traite les tickets de caisse français via OCR avec extraction automatique des produits
- **FR12:** Le système reconnaît les codes-barres EAN-13 et récupère les informations produit depuis des bases de données externes
- **FR13:** Les utilisateurs peuvent prendre une photo d'un ticket de caisse pour l'analyser automatiquement
- **FR14:** Le système affiche la confiance de reconnaissance OCR et permet correction manuelle des produits mal détectés
- **FR15:** Le système enrichit automatiquement les produits scannés avec informations nutritionnelles (OpenFoodFacts ou équivalent)

**3. Alertes & Notifications Intelligentes (6 FRs)**

- **FR16:** Les utilisateurs reçoivent des notifications lorsqu'un produit approche de sa date de péremption (DLC ou DDM)
- **FR17:** Les utilisateurs peuvent configurer le délai d'alerte de péremption (par défaut 2 jours avant pour DLC)
- **FR18:** Le système différencie visuellement les alertes DLC (Date Limite Consommation - critique) des alertes DDM (Date Durabilité Minimale - information)
- **FR19:** Les utilisateurs peuvent désactiver les notifications pour des catégories spécifiques de produits
- **FR20:** Les utilisateurs peuvent définir des plages horaires de silence pour les notifications (quiet hours)
- **FR21:** Le système envoie des suggestions de recettes contextuelles lorsqu'un produit arrive à péremption

**4. Découverte de Recettes & Suggestions (6 FRs)**

- **FR22:** Les utilisateurs peuvent rechercher des recettes compatibles avec les produits présents dans leur inventaire actuel
- **FR23:** Les utilisateurs peuvent filtrer les recettes par critères (budget, temps de préparation, difficulté, régime alimentaire)
- **FR24:** Le système suggère automatiquement des recettes utilisant prioritairement les produits proches de la péremption
- **FR25:** Les utilisateurs peuvent accéder à des tutoriels détaillés pour chaque recette
- **FR26:** Les utilisateurs peuvent marquer des recettes comme favorites pour accès rapide
- **FR27:** Le système adapte les suggestions de recettes au profil nutritionnel de l'utilisateur

**5. Planning Repas & Génération Intelligente (6 FRs)**

- **FR28:** Les utilisateurs peuvent générer automatiquement un planning de repas hebdomadaire via IA
- **FR29:** Le système génère des plannings respectant les contraintes nutritionnelles du profil utilisateur (macros, calories)
- **FR30:** Le système optimise les plannings pour utiliser prioritairement les produits en stock (anti-gaspillage)
- **FR31:** Les utilisateurs peuvent spécifier des contraintes de planning (temps de préparation max, batch cooking, préférences culinaires)
- **FR32:** Les utilisateurs peuvent modifier manuellement le planning généré (remplacer un repas, ajuster portions)
- **FR33:** Le système génère automatiquement une liste de courses complémentaire basée sur le planning et l'inventaire existant

**6. Suivi Nutritionnel & Coach IA (8 FRs)**

- **FR34:** Les utilisateurs peuvent sélectionner un profil nutritionnel parmi 12 profils prédéfinis (famille, sportif prise de masse, sportif sèche, végan, diabétique, senior, etc.)
- **FR35:** Le système calcule automatiquement le TDEE (Total Daily Energy Expenditure) et BMR (Basal Metabolic Rate) basé sur les caractéristiques physiques de l'utilisateur
- **FR36:** Les utilisateurs peuvent enregistrer leur consommation alimentaire quotidienne avec tracking automatique des calories et macronutriments
- **FR37:** Les utilisateurs peuvent prendre une photo de leur repas pour reconnaissance automatique et logging nutritionnel via IA vision
- **FR38:** Le système fournit des conseils nutritionnels contextuels temps réel basés sur la consommation journalière actuelle
- **FR39:** Les utilisateurs peuvent consulter un historique de leur suivi nutritionnel (jour, semaine, mois)
- **FR40:** Le système affiche un dashboard nutrition montrant l'équilibre alimentaire (pourcentage jours équilibrés, carences potentielles, atteinte objectifs)
- **FR41:** Les utilisateurs peuvent interagir avec un chatbot IA pour poser des questions nutritionnelles générales

**7. Comparateur Prix & Optimisation Courses (6 FRs)**

- **FR42:** Les utilisateurs peuvent comparer les prix d'une liste de produits entre plusieurs enseignes (minimum 4 sources)
- **FR43:** Le système affiche les économies potentielles en euros et pourcentage pour chaque enseigne
- **FR44:** Les utilisateurs peuvent visualiser sur une carte interactive les magasins disponibles avec leurs prix
- **FR45:** Le système propose un parcours optimisé multi-magasins équilibrant économies et distance de trajet
- **FR46:** Les utilisateurs peuvent exporter leur liste de courses optimisée
- **FR47:** Le système indique la date de dernière mise à jour des prix et la source des données prix

**8. Dashboard, Métriques & Impact (6 FRs)**

- **FR48:** Les utilisateurs peuvent visualiser un dashboard récapitulatif de leur activité (gaspillage évité, économies, impact écologique)
- **FR49:** Le système calcule et affiche le gaspillage alimentaire évité (en kg et en euros) sur différentes périodes
- **FR50:** Le système calcule et affiche les économies réalisées grâce au comparateur prix
- **FR51:** Le système calcule et affiche l'impact écologique (kg CO2eq évités) basé sur le gaspillage évité
- **FR52:** Les utilisateurs peuvent consulter des graphiques d'évolution temporelle de leurs métriques
- **FR53:** Le système affiche des statistiques nutritionnelles agrégées (pourcentage jours équilibrés, macros moyens hebdomadaires)

**9. Gamification & Engagement (5 FRs)**

- **FR54:** Les utilisateurs peuvent débloquer des achievements (badges) pour actions anti-gaspillage, cuisine maison, économies
- **FR55:** Le système suit les streaks d'activité (jours consécutifs sans gaspillage, cuisine maison)
- **FR56:** Les utilisateurs peuvent rejoindre un leaderboard avec amis (opt-in) pour compétition ludique
- **FR57:** Le système propose des défis hebdomadaires ou mensuels personnalisés
- **FR58:** Les utilisateurs peuvent partager leurs accomplissements sur réseaux sociaux

**10. Authentification & Profil Utilisateur (6 FRs)**

- **FR59:** Les utilisateurs peuvent créer un compte avec authentification sécurisée (email/password, OAuth)
- **FR60:** Les utilisateurs peuvent configurer leur profil personnel (nom, caractéristiques physiques, objectifs)
- **FR61:** Les utilisateurs peuvent modifier leurs préférences alimentaires et restrictions (allergies, régimes spéciaux)
- **FR62:** Les utilisateurs peuvent synchroniser leurs données entre plusieurs appareils
- **FR63:** Les utilisateurs peuvent exporter l'intégralité de leurs données personnelles (portabilité RGPD)
- **FR64:** Les utilisateurs peuvent supprimer définitivement leur compte et toutes leurs données

**11. Partage & Collaboration Familiale (4 FRs)**

- **FR65:** Les utilisateurs peuvent partager leur inventaire avec d'autres utilisateurs (mode famille/colocation)
- **FR66:** Les utilisateurs peuvent partager des recettes et plannings repas avec d'autres utilisateurs
- **FR67:** Les utilisateurs peuvent exporter des rapports au format PDF (inventaire, planning, métriques)
- **FR68:** Les utilisateurs peuvent synchroniser une liste de courses partagée en temps réel avec d'autres membres de la famille

**12. Conformité, Sécurité & Consentements (7 FRs)**

- **FR69:** Le système affiche des disclaimers obligatoires pour conseils nutritionnels (non-dispositif médical, consulter professionnel santé)
- **FR70:** Le système affiche des disclaimers pour prix affichés (indicatifs, non contractuels, vérification en magasin)
- **FR71:** Le système affiche des disclaimers pour alertes péremption (responsabilité utilisateur, vérification visuelle produits)
- **FR72:** Les utilisateurs doivent fournir un double opt-in explicite pour activer le suivi de données de santé (nutrition)
- **FR73:** Les utilisateurs peuvent retirer leur consentement pour données santé à tout moment avec suppression sous 30 jours
- **FR74:** Le système chiffre les données sensibles (profils nutrition, historique achats) au repos et en transit
- **FR75:** Les utilisateurs peuvent gérer leurs consentements granulaires (données santé, cookies analytics, notifications marketing)

**13. Accessibilité & Expérience Utilisateur (5 FRs)**

- **FR76:** Le système propose un onboarding guidé adapté au profil utilisateur (famille, sportif, senior, étudiant)
- **FR77:** Le système affiche des tutoriels interactifs pour première utilisation des fonctionnalités principales
- **FR78:** Le système offre une aide contextuelle (tooltips) sur fonctionnalités complexes
- **FR79:** Les utilisateurs seniors peuvent bénéficier d'une interface adaptée (boutons larges, texte agrandi, contraste élevé)
- **FR80:** Le système fonctionne entièrement en mode hors-ligne avec synchronisation différée lors du retour de connexion

**14. Modèle Freemium & Abonnement (5 FRs)**

- **FR81:** Les utilisateurs peuvent accéder à 6 modules gratuits sans abonnement (Inventaire, Scan basique, Notifications, Recettes basiques, Dashboard, Profil)
- **FR82:** Les utilisateurs peuvent souscrire à un abonnement Premium (4.99€/mois) pour accès aux 14 modules complets
- **FR83:** Les utilisateurs peuvent tester la version Premium gratuitement pendant 7 jours
- **FR84:** Les utilisateurs peuvent annuler leur abonnement Premium en 3 clics maximum depuis l'application
- **FR85:** Le système affiche un tableau comparatif transparent des fonctionnalités Gratuit vs Premium

### NonFunctional Requirements

**Performance (7 NFRs)**

- **NFR-P1:** Le système doit traiter un ticket de caisse et extraire les produits en moins de 2 secondes (95e percentile) avec dual-engine (Google Vision + ML Kit) et fallback automatique <500ms
- **NFR-P2:** Cold start de l'application doit compléter en moins de 3 secondes sur devices mid-range, warm start en <1 seconde
- **NFR-P3:** Toutes interactions utilisateur (tap, swipe, navigation) doivent afficher feedback visuel en moins de 100ms
- **NFR-P4:** Reconnaissance code-barres EAN-13 doit détecter et traiter en moins de 500ms en conditions optimales
- **NFR-P5:** Toutes fonctionnalités core (inventaire, alertes, recettes, dashboard) doivent fonctionner en mode offline sans dégradation de performance
- **NFR-P6:** Génération planning repas hebdomadaire via IA doit compléter en moins de 10 secondes avec feedback visuel de progression
- **NFR-P7:** Analyse photo repas et estimation nutritionnelle (Gemini Vision) doit compléter en moins de 15 secondes avec loader

**Security (6 NFRs)**

- **NFR-S1:** Toutes données santé (suivi nutrition, profils médicaux, journal repas, photos repas) doivent être chiffrées at-rest (AES-256) et in-transit (TLS 1.3+)
- **NFR-S2:** Le système doit supporter authentification multi-facteurs (2FA) pour comptes premium, avec Firebase Auth + OAuth2 (Google, Apple, Email/Password) et tokens expirant après 7 jours inactivité
- **NFR-S3:** Les clés API (Google Cloud Vision, Gemini, Firebase) doivent être stockées côté serveur, jamais exposées dans le code client, avec rotation automatique tous les 90 jours minimum
- **NFR-S4:** Double opt-in obligatoire pour activation modules données santé, retrait consentement doit déclencher suppression données sous 30 jours avec logs audit conservés 3 ans
- **NFR-S5:** Suppression compte utilisateur doit effacer toutes données personnelles sous 30 jours (RGPD) avec confirmation par email et export données possible avant suppression
- **NFR-S6:** Toutes entrées utilisateur doivent être sanitizées contre injections (SQL, XSS, command injection) avec validation côté client ET serveur

**Scalability (5 NFRs)**

- **NFR-SC1:** Le système doit supporter 10,000 utilisateurs actifs mensuels (MAU) sans dégradation performance (baseline) et permettre passage à 100,000 MAU avec <10% dégradation via scaling horizontal
- **NFR-SC2:** Chaque utilisateur doit pouvoir stocker jusqu'à 1,000 produits dans son inventaire sans dégradation performance UI avec pagination automatique et virtual scrolling activés au-delà de 50 produits
- **NFR-SC3:** La base de données recettes doit supporter 10,000+ recettes avec recherche/filtrage performant (<1s) et indexation full-text
- **NFR-SC4:** Le système backend (Firebase) doit supporter pics de trafic 3x traffic moyen sans downtime avec auto-scaling Cloud Functions activé
- **NFR-SC5:** Coût infrastructure par utilisateur doit rester sous 0.50€/mois/MAU jusqu'à 10,000 MAU avec budget total infrastructure <500€/mois

**Reliability & Availability (6 NFRs)**

- **NFR-R1:** Backend Firebase + APIs externes doivent garantir 99.5% uptime minimum avec SLA monitoring et alertes automatiques si downtime >5 minutes
- **NFR-R2:** L'application mobile doit maintenir un crash-free rate >99.9% avec crash reporting temps réel (Firebase Crashlytics → Sentry)
- **NFR-R3:** Les notifications péremption critiques (DLC) doivent être délivrées avec >99% reliability, retry automatique si échec (3 tentatives sur 6h), fallback notification locale si push échoue
- **NFR-R4:** Le système doit continuer en mode dégradé si API externe indisponible avec fallbacks automatiques configurés (Vision down → ML Kit seul, OpenFoodFacts down → cache local, Prix down → message utilisateur)
- **NFR-R5:** Les données modifiées offline doivent se synchroniser automatiquement lors retour connexion avec conflict resolution intelligent sans perte de données
- **NFR-R6:** Backup automatique quotidien Firestore avec point-in-time recovery possible sur 30 jours et RTO (Recovery Time Objective) de 4 heures maximum

**Integration (7 NFRs)**

- **NFR-I1:** Le système doit gérer quota Google Vision (1000 requêtes/mois free tier) avec monitoring, circuit breaker si quota atteint 80% → fallback ML Kit seul, retry exponential backoff max 3 tentatives
- **NFR-I2:** ML Kit Text Recognition doit fonctionner 100% offline sans dépendance réseau avec modèles mis à jour automatiquement via Firebase ML
- **NFR-I3:** Firebase Auth, Firestore, Cloud Functions, Cloud Storage doivent opérer en mode cohérent avec timeouts configurés (Auth 10s, Firestore queries 5s, Functions 30s)
- **NFR-I4:** Quota Gemini Free Tier monitoring (60 requests/minute) avec fallback graceful si quota dépassé et cache réponses fréquentes pour réduire calls API
- **NFR-I5:** Le système doit supporter offline-first avec cache local OpenFoodFacts (TTL 7 jours) et retry automatique si timeout API (>5s)
- **NFR-I6:** Le système doit supporter minimum 4 sources prix avec données mises à jour quotidiennement minimum et disclaimer visible "Prix indicatifs, dernière MAJ [date], vérifiez en magasin"
- **NFR-I7:** Carte interactive comparateur prix doit charger en <3 secondes avec gestion quota Maps API et circuit breaker si approche limite gratuite (28,000 map loads/mois)

**Accessibility (4 NFRs)**

- **NFR-A1:** Support WCAG 2.1 Niveau A minimum avec contraste couleurs 4.5:1 pour texte standard (3:1 texte large), navigation clavier complète, alternatives textuelles pour images/icônes
- **NFR-A2:** Mode "Accessibilité Senior" disponible (activable Settings) avec taille texte +30% minimum, boutons touch targets ≥48dp, contraste élevé automatique, simplification navigation
- **NFR-A3:** Phase 1 Français uniquement, architecture i18n préparée pour expansion (EN, NL, DE) année 2
- **NFR-A4:** Compatibilité TalkBack (Android) et VoiceOver (iOS) avec labels sémantiques corrects et annonces contextuelles

**Usability (4 NFRs)**

- **NFR-U1:** Nouveau utilisateur doit compléter onboarding en <2 minutes (cible 90 secondes) avec maximum 5 écrans et skip possible à tout moment
- **NFR-U2:** Utilisateur novice doit réussir à ajouter 10 produits (scan + manuel) sans aide externe dans les 5 premières minutes avec tutoriels contextuels lors première utilisation
- **NFR-U3:** Toute action utilisateur doit afficher confirmation visuelle claire et erreurs doivent afficher messages explicites avec action corrective suggérée
- **NFR-U4:** Respect strict Material Design 3 (Android) et Human Interface Guidelines (iOS) avec design tokens partagés pour cohérence visuelle

**Maintainability & DevOps (5 NFRs)**

- **NFR-M1:** Couverture tests ≥75% (pyramide : 70% unit, 20% widget, 10% E2E) avec CI/CD gate bloquant merge si coverage <75%
- **NFR-M2:** Build + tests automatisés sur chaque commit avec déploiement automatisé staged rollouts 5%→25%→100% sur 72h et rollback auto si crash rate >0.5%
- **NFR-M3:** Logs centralisés (Firebase Crashlytics + future Sentry) avec métriques business temps réel (DAU, MAU, conversion, rétention D7/D30) et alertes automatiques si dégradation
- **NFR-M4:** Correction bugs critiques déployable en <24h avec over-the-air updates pour configuration (feature flags Firebase Remote Config)
- **NFR-M5:** Fonctions complexes documentées (dartdoc) et ADRs (Architecture Decision Records) maintenus pour décisions architecturales majeures

### Additional Requirements

**From Architecture Document:**

**Starter Template:**
- **ARCH-REQ-1:** Initialisation projet Flutter avec setup manuel Feature-First custom : `flutter create --org com.frigofute --platforms ios,android frigofute_v2`
- **ARCH-REQ-2:** Structure Feature-First avec 14 modules isolés (lib/features/{module_name}/)
- **ARCH-REQ-3:** Architecture Clean Architecture par feature avec couches domain/data/presentation dans chaque module

**Technical Infrastructure:**
- **ARCH-REQ-4:** Stack technologique : Flutter 3.32, Dart 3.5+, Firebase suite (Auth, Firestore, Functions, Storage, Remote Config, Crashlytics), Hive 2.x
- **ARCH-REQ-5:** Dual-engine OCR : Google Cloud Vision API + ML Kit Text Recognition avec fallback automatique
- **ARCH-REQ-6:** IA générative : Google Gemini (Vision pour analyse photos repas + Chat pour chatbot nutrition)
- **ARCH-REQ-7:** State management : Riverpod 2.6+ avec provider scoping global + feature-scoped
- **ARCH-REQ-8:** Routing : GoRouter avec deep linking support

**Data Architecture:**
- **ARCH-REQ-9:** Synchronisation offline-online : Pattern Optimistic UI + background sync bidirectionnelle Firestore ↔ Hive avec Last-Write-Wins conflict resolution
- **ARCH-REQ-10:** Hive boxes : inventory_box, nutrition_box, recipes_box, settings_box, sync_queue_box avec boxes encryptées AES-256 pour données santé
- **ARCH-REQ-11:** Firestore collections structurées : users/{userId}/inventory, users/{userId}/nutrition_tracking, shared/recipes, shared/products_cache
- **ARCH-REQ-12:** Cache strategy : OpenFoodFacts (TTL 7j, LRU max 1000 produits), Gemini responses (in-memory LRU 100 items, 24h TTL), Prix (Firestore TTL 24h)

**Security Architecture:**
- **ARCH-REQ-13:** Firebase Authentication avec Email/Password + OAuth2 (Google Sign-In, Apple Sign-In) + Anonymous auth pour mode découverte
- **ARCH-REQ-14:** Feature flags freemium via Firebase Remote Config avec guard widgets PremiumFeatureGuard
- **ARCH-REQ-15:** API keys protection : stockage Firebase Functions environment config, jamais exposées client, rotation 90 jours
- **ARCH-REQ-16:** Rate limiting : Cloud Functions 100 req/min par userId, Gemini throttling client-side 1 req/2s

**Testing & DevOps:**
- **ARCH-REQ-17:** CI/CD pipeline : GitHub Actions + Fastlane avec quality gates (coverage ≥75%, tests passent, linting)
- **ARCH-REQ-18:** Staged rollouts : Firebase App Distribution → 5% users → 25% → 100% sur 72h avec rollback automatique si crash rate >0.5%
- **ARCH-REQ-19:** Monitoring : Firebase Crashlytics + Performance Monitoring + Analytics custom events (scan ticket, génération planning, conversion funnel)

**From Brainstorming Document:**

**MVP Phasing Strategy:**
- **BRAIN-REQ-1:** MVP Tier 1 (Semaines 4-6) : Modules 1 (Inventaire), 3 (Notifications), 4 (Dashboard) = Anti-gaspi basique
- **BRAIN-REQ-2:** MVP Tier 2 (Semaines 7-8) : + Module 2 (Scan OCR & Code-barres) = Scan magique
- **BRAIN-REQ-3:** MVP Tier 3 (Semaines 9-11) : + Modules 5 (Auth), 6 (Recettes), 7 (Suivi nutrition), 8 (Profils) = Nutrition-aware + DECISION POINT Freemium
- **BRAIN-REQ-4:** Phase 5 (Semaines 12-15) : + Modules 9 (Planning repas), 12 (Liste courses) = Planning & Intelligence
- **BRAIN-REQ-5:** Phase 6 (Semaines 16-20) : + Modules 10 (Coach IA), 11 (Gamification), 14 (Comparateur prix) = Premium features
- **BRAIN-REQ-6:** Phase 7 (Semaines 21-22) : + Module 13 (Export/Partage) = Collaboration

**UX Priorities:**
- **BRAIN-REQ-7:** "Moment magique" #1 : Premier scan ticket → 100+ produits ajoutés en <2s = Wow effect critique pour adoption
- **BRAIN-REQ-8:** "Moment magique" #2 : Premier planning hebdomadaire généré automatiquement → gain temps perçu = Trigger conversion premium
- **BRAIN-REQ-9:** Onboarding adaptatif par segment (Famille, Sportif, Senior, Étudiant) avec personnalisation profil dès 1ère utilisation

**Legal & Compliance Priorities:**
- **BRAIN-REQ-10:** Disclaimers légaux critiques intégrés dès MVP Tier 1 : nutrition (non-dispositif médical), péremption (vérification visuelle), prix (indicatifs)
- **BRAIN-REQ-11:** Double opt-in données santé implémenté avant activation Module 7 (Suivi nutrition) dans MVP Tier 3
- **BRAIN-REQ-12:** Stratégie prix légale : Phase 1 crowdsourcing utilisateurs (légal, gratuit), Phase 2 négocier APIs officielles enseignes

### FR Coverage Map

**Functional Requirements (85 FRs) → Epic Mapping:**

- FR1: Epic 2 (manual add), Epic 5 (barcode scan) - Ajout produits inventaire
- FR2: Epic 5 - Scan OCR ticket de caisse
- FR3: Epic 2 - Ajout manuel produits
- FR4: Epic 2 - Modification produits inventaire
- FR5: Epic 2 - Suppression produits inventaire
- FR6: Epic 2 - Visualisation inventaire avec filtres
- FR7: Epic 2 - Catégorisation automatique 12 catégories
- FR8: Epic 2 - Assignment automatique 6 emplacements
- FR9: Epic 2 - Marquage produit consommé
- FR10: Epic 2 - Suivi états produits (frais/péremption/consommé)
- FR11: Epic 5 - OCR tickets français extraction produits
- FR12: Epic 5 - Reconnaissance codes-barres EAN-13
- FR13: Epic 5 - Photo ticket de caisse analyse auto
- FR14: Epic 5 - Confiance OCR + correction manuelle
- FR15: Epic 5 - Enrichissement nutritionnel OpenFoodFacts
- FR16: Epic 3 - Notifications péremption DLC/DDM
- FR17: Epic 3 - Configuration délai alerte
- FR18: Epic 3 - Différenciation visuelle DLC/DDM
- FR19: Epic 3 - Désactivation notifications par catégorie
- FR20: Epic 3 - Plages horaires silence (quiet hours)
- FR21: Epic 6 - Suggestions recettes contextuelles péremption
- FR22: Epic 6 - Recherche recettes matching inventaire
- FR23: Epic 6 - Filtres recettes (budget/temps/difficulté/régime)
- FR24: Epic 6 - Suggestions auto produits proches péremption
- FR25: Epic 6 - Tutoriels détaillés recettes
- FR26: Epic 6 - Recettes favorites
- FR27: Epic 6 - Adaptation suggestions profil nutritionnel
- FR28: Epic 9 - Génération planning hebdomadaire IA
- FR29: Epic 9 - Planning contraintes nutritionnelles (macros/calories)
- FR30: Epic 9 - Optimisation planning anti-gaspi stock
- FR31: Epic 9 - Contraintes planning (temps/batch cooking/préférences)
- FR32: Epic 9 - Modification manuelle planning
- FR33: Epic 10 - Liste courses auto-générée
- FR34: Epic 8 - Sélection profil nutritionnel (12 profils)
- FR35: Epic 8 - Calcul auto TDEE/BMR
- FR36: Epic 7 - Enregistrement consommation quotidienne tracking
- FR37: Epic 11 - Photo repas reconnaissance IA vision
- FR38: Epic 11 - Conseils nutritionnels contextuels temps réel
- FR39: Epic 7 - Historique suivi nutritionnel
- FR40: Epic 7 - Dashboard nutrition équilibre alimentaire
- FR41: Epic 11 - Chatbot IA questions nutrition
- FR42: Epic 12 - Comparaison prix 4+ enseignes
- FR43: Epic 12 - Affichage économies potentielles
- FR44: Epic 12 - Carte interactive magasins
- FR45: Epic 12 - Parcours optimisé multi-magasins
- FR46: Epic 12 - Export liste courses optimisée
- FR47: Epic 12 - Date MAJ prix + source données
- FR48: Epic 4 - Dashboard récapitulatif activité
- FR49: Epic 4 - Calcul gaspillage évité (kg/€)
- FR50: Epic 12 - Calcul économies comparateur prix (affichage dashboard)
- FR51: Epic 4 - Calcul impact CO2eq évité
- FR52: Epic 4 - Graphiques évolution métriques
- FR53: Epic 7 - Stats nutritionnelles agrégées
- FR54: Epic 13 - Achievements/badges anti-gaspi
- FR55: Epic 13 - Streaks activité
- FR56: Epic 13 - Leaderboard amis opt-in
- FR57: Epic 13 - Défis personnalisés
- FR58: Epic 13 - Partage accomplissements réseaux sociaux
- FR59: Epic 1 - Création compte authentification sécurisée
- FR60: Epic 1 - Configuration profil personnel
- FR61: Epic 8 - Préférences alimentaires/allergies
- FR62: Epic 1 - Synchronisation multi-appareils
- FR63: Epic 1 - Export données RGPD
- FR64: Epic 1 - Suppression compte définitive
- FR65: Epic 14 - Partage inventaire famille/colocation
- FR66: Epic 14 - Partage recettes/plannings
- FR67: Epic 14 - Export PDF rapports
- FR68: Epic 14 - Liste courses partagée temps réel
- FR69: Epic 8, Epic 16 - Disclaimers nutrition obligatoires
- FR70: Epic 12, Epic 16 - Disclaimers prix indicatifs
- FR71: Epic 3, Epic 16 - Disclaimers péremption responsabilité
- FR72: Epic 7 - Double opt-in données santé
- FR73: Epic 7 - Retrait consentement données santé
- FR74: Epic 7 - Encryption données sensibles
- FR75: Epic 7 - Gestion consentements granulaires
- FR76: Epic 1 - Onboarding guidé adaptatif
- FR77: Epic 1 - Tutoriels interactifs première utilisation
- FR78: Epic 1 - Aide contextuelle tooltips
- FR79: Epic 1 - Interface adaptée seniors
- FR80: Epic 2 - Fonctionnement offline-first complet
- FR81: Epic 15 - Accès 6 modules gratuits
- FR82: Epic 15 - Abonnement Premium 4.99€/mois
- FR83: Epic 15 - Essai Premium 7j gratuit
- FR84: Epic 15 - Annulation abonnement 3 clics
- FR85: Epic 15 - Tableau comparatif Gratuit/Premium

**Non-Functional Requirements → Epic Mapping:**

- NFR-P1 to NFR-P7: Performance requirements implemented across all epics
- NFR-S1 to NFR-S6: Security requirements in Epic 0, 1, 7, 16
- NFR-SC1 to NFR-SC5: Scalability in Epic 0
- NFR-R1 to NFR-R6: Reliability in Epic 0, 2, 3
- NFR-I1 to NFR-I7: Integration in Epic 0, 5, 11, 12
- NFR-A1 to NFR-A4: Accessibility in Epic 0, 1
- NFR-U1 to NFR-U4: Usability in Epic 0, 1, 2
- NFR-M1 to NFR-M5: Maintainability/DevOps in Epic 0

**Additional Requirements → Epic Mapping:**

- ARCH-REQ-1 to ARCH-REQ-19: Epic 0 (Foundation & Setup)
- BRAIN-REQ-1 to BRAIN-REQ-6: MVP phasing strategy (Epic sequence)
- BRAIN-REQ-7: Epic 5 ("moment magique" scan)
- BRAIN-REQ-8: Epic 9 ("moment magique" planning)
- BRAIN-REQ-9: Epic 1 (onboarding adaptatif)
- BRAIN-REQ-10 to BRAIN-REQ-12: Epic 16 (Compliance)

## Epic List

### Epic 0: Initial App Setup for First User

**User Outcome:** Les utilisateurs peuvent télécharger l'application FrigoFute depuis App Store et Play Store, l'installer sur leur device iOS ou Android, la lancer avec succès (cold start < 3 secondes), et bénéficier d'une application stable, performante et conforme (crash-free rate > 99.9%, RGPD-compliant) dès le premier lancement.

**FRs covered:** ARCH-REQ-1 à ARCH-REQ-19, NFR-M1 à NFR-M5, NFR-A3, NFR-U4, NFR-SC1, NFR-I3

**Dependencies:** Aucune - C'est le premier epic qui enable tous les autres

---

### 📦 MVP TIER 1 (Semaines 4-6): Anti-Gaspi Basique

### Epic 1: User Authentication & Profile Management

**User Outcome:** Les utilisateurs peuvent créer un compte sécurisé (email/password ou OAuth Google/Apple), se connecter, configurer leur profil personnel avec préférences alimentaires et objectifs, bénéficier d'un onboarding guidé adapté à leur segment (famille/sportif/senior/étudiant), et synchroniser leurs données entre appareils.

**FRs covered:** FR59, FR60, FR61, FR62, FR63, FR64, FR76, FR77, FR78, FR79

**NFRs covered:** NFR-S2, NFR-U1, NFR-U2, NFR-A2, NFR-A4

**Additional:** ARCH-REQ-13, BRAIN-REQ-9

**Dependencies:** Epic 0

---

### Epic 2: Inventory Management

**User Outcome:** Les utilisateurs peuvent gérer complètement leur inventaire alimentaire : ajouter manuellement des produits avec toutes informations (nom, catégorie parmi 12, quantité, date péremption, emplacement parmi 6), modifier/supprimer produits, visualiser l'inventaire avec filtres par catégorie/emplacement/statut, marquer produits consommés, et tout fonctionne offline-first avec sync automatique.

**FRs covered:** FR1 (ajout manuel uniquement), FR3, FR4, FR5, FR6, FR7, FR8, FR9, FR10, FR80

**NFRs covered:** NFR-P3, NFR-P5, NFR-SC2, NFR-U2, NFR-U3

**Additional:** ARCH-REQ-9 à ARCH-REQ-12

**Dependencies:** Epic 0, Epic 1

---

### Epic 3: Expiration Alerts & Notifications

**User Outcome:** Les utilisateurs reçoivent des notifications intelligentes et fiables (>99% delivery) lorsque leurs produits approchent de la péremption, avec différenciation visuelle DLC (critique rouge) vs DDM (info jaune), configuration personnalisable des délais d'alerte, quiet hours, et désactivation par catégorie, incluant le disclaimer légal de responsabilité.

**FRs covered:** FR16, FR17, FR18, FR19, FR20, FR71

**NFRs covered:** NFR-R3, NFR-U3

**Additional:** BRAIN-REQ-10

**Dependencies:** Epic 0, Epic 1, Epic 2

---

### Epic 4: Dashboard & Impact Metrics

**User Outcome:** Les utilisateurs visualisent leur impact anti-gaspillage via un dashboard récapitulatif temps réel (<1s chargement) montrant gaspillage évité (kg/€), impact écologique (CO2eq), et graphiques d'évolution temporelle, leur donnant fierté et motivation.

**FRs covered:** FR48, FR49, FR51, FR52

**NFRs covered:** NFR-P3, NFR-U3

**Dependencies:** Epic 0, Epic 1, Epic 2

---

### 🔍 MVP TIER 2 (Semaines 7-8): Scan Magique

### Epic 5: OCR & Barcode Scanning

**User Outcome:** Les utilisateurs ajoutent 100+ produits à leur inventaire en <2 secondes ("moment magique" #1) via scan ticket de caisse (OCR dual-engine Google Vision + ML Kit fallback) ou scan code-barres EAN-13, avec enrichissement automatique informations nutritionnelles OpenFoodFacts, affichage confiance reconnaissance, et correction manuelle facilitée.

**FRs covered:** FR1 (scan barcode complet), FR2, FR11, FR12, FR13, FR14, FR15

**NFRs covered:** NFR-P1, NFR-P4, NFR-I1, NFR-I2, NFR-I5

**Additional:** ARCH-REQ-5, BRAIN-REQ-7

**Dependencies:** Epic 0, Epic 1, Epic 2

---

### 🥗 MVP TIER 3 (Semaines 9-11): Nutrition-Aware

### Epic 6: Recipe Discovery & Suggestions

**User Outcome:** Les utilisateurs découvrent des recettes compatibles avec leur inventaire actuel, reçoivent des suggestions anti-gaspillage contextuelles pour produits proches péremption (intégration alerte Epic 3), filtrent par budget/temps/difficulté/régime, accèdent à des tutoriels détaillés, marquent favoris, et bénéficient d'adaptation automatique à leur profil nutritionnel.

**FRs covered:** FR21, FR22, FR23, FR24, FR25, FR26, FR27

**NFRs covered:** NFR-SC3

**Dependencies:** Epic 0, Epic 1, Epic 2, Epic 3

---

### Epic 7: Nutritional Tracking

**User Outcome:** Les utilisateurs enregistrent leur consommation alimentaire quotidienne avec tracking automatique calories/macronutriments, consultent historique (jour/semaine/mois), visualisent dashboard nutrition montrant équilibre alimentaire et atteinte objectifs, avec double opt-in explicite pour données santé (RGPD Article 9), encryption AES-256, et possibilité retrait consentement/suppression données <30j.

**FRs covered:** FR36, FR39, FR40, FR53, FR72, FR73, FR74, FR75

**NFRs covered:** NFR-S1, NFR-S4, NFR-S5, NFR-S6

**Additional:** ARCH-REQ-10, BRAIN-REQ-11

**Dependencies:** Epic 0, Epic 1

---

### Epic 8: Nutrition Profiles & Calculations

**User Outcome:** Les utilisateurs sélectionnent un profil nutritionnel parmi 12 profils prédéfinis (famille/sportif prise masse/sportif sèche/végan/diabétique/senior/etc.), renseignent leurs caractéristiques physiques, et le système calcule automatiquement TDEE/BMR pour personnaliser suggestions recettes et plannings futurs, avec disclaimer légal nutrition (non-dispositif médical).

**FRs covered:** FR34, FR35, FR61, FR69

**Additional:** BRAIN-REQ-10

**Dependencies:** Epic 0, Epic 1

---

### 🚀 GROWTH FEATURES (Post-MVP - Semaines 12-22)

### Epic 9: Meal Planning with AI

**User Outcome:** Les utilisateurs génèrent automatiquement un planning repas hebdomadaire via IA Gemini ("moment magique" #2 - gain 2-3h/semaine) respectant contraintes nutritionnelles (macros/calories profil Epic 8), optimisant utilisation stock existant (anti-gaspi), avec contraintes personnalisables (temps préparation/batch cooking), modification manuelle, et feedback progression <10s.

**FRs covered:** FR28, FR29, FR30, FR31, FR32

**NFRs covered:** NFR-P6

**Additional:** ARCH-REQ-6, BRAIN-REQ-4, BRAIN-REQ-8

**Dependencies:** Epic 0, Epic 1, Epic 2, Epic 6, Epic 8

---

### Epic 10: Smart Shopping List

**User Outcome:** Les utilisateurs reçoivent automatiquement une liste de courses complémentaire intelligente basée sur leur planning repas (Epic 9) et inventaire existant (Epic 2), évitant achats redondants et optimisant anti-gaspi.

**FRs covered:** FR33

**Additional:** BRAIN-REQ-4

**Dependencies:** Epic 0, Epic 1, Epic 2, Epic 9

---

### Epic 11: AI Nutrition Coach

**User Outcome:** Les utilisateurs prennent une photo de leur repas pour reconnaissance automatique et logging nutritionnel via Gemini Vision (<15s), reçoivent conseils nutritionnels contextuels temps réel basés sur consommation journalière (Epic 7), et interagissent avec chatbot IA pour questions nutrition générales.

**FRs covered:** FR37, FR38, FR41

**NFRs covered:** NFR-P7, NFR-I4

**Additional:** ARCH-REQ-6, BRAIN-REQ-5

**Dependencies:** Epic 0, Epic 1, Epic 7, Epic 8

---

### Epic 12: Price Comparison & Route Optimization

**User Outcome:** Les utilisateurs comparent prix de leur liste courses (Epic 10) entre 4+ enseignes, visualisent économies potentielles (€/%), consultent carte interactive magasins (<3s chargement), reçoivent parcours optimisé multi-magasins équilibrant économies/distance, exportent liste optimisée, et voient économies réalisées affichées dans dashboard (Epic 4), avec disclaimer prix légal.

**FRs covered:** FR42, FR43, FR44, FR45, FR46, FR47, FR50, FR70

**NFRs covered:** NFR-I6, NFR-I7

**Additional:** BRAIN-REQ-5, BRAIN-REQ-12

**Dependencies:** Epic 0, Epic 1, Epic 10, Epic 4

---

### Epic 13: Gamification & Engagement

**User Outcome:** Les utilisateurs débloquent achievements/badges pour actions anti-gaspillage/cuisine maison/économies, suivent streaks d'activité (jours consécutifs sans gaspillage), rejoignent leaderboard amis opt-in pour compétition ludique, complètent défis hebdomadaires/mensuels personnalisés, et partagent accomplissements sur réseaux sociaux.

**FRs covered:** FR54, FR55, FR56, FR57, FR58

**Additional:** BRAIN-REQ-5

**Dependencies:** Epic 0, Epic 1, Epic 2, Epic 4

---

### Epic 14: Family Sharing & Collaboration

**User Outcome:** Les utilisateurs partagent leur inventaire avec famille/colocation (Epic 2), partagent recettes/plannings (Epic 6/9), exportent rapports PDF (inventaire/planning/métriques), et synchronisent liste de courses en temps réel avec autres membres famille.

**FRs covered:** FR65, FR66, FR67, FR68

**Additional:** BRAIN-REQ-6

**Dependencies:** Epic 0, Epic 1, Epic 2, Epic 6, Epic 9, Epic 10

---

### Epic 15: Premium Features & Freemium Management

**User Outcome:** Les utilisateurs comprennent clairement via tableau comparatif transparent les fonctionnalités Gratuit (6 modules: Epics 1-6) vs Premium (14 modules complets), peuvent s'abonner Premium 4.99€/mois avec essai 7j gratuit, et annuler en 3 clics maximum depuis l'app (conformité Loi Hamon).

**FRs covered:** FR81, FR82, FR83, FR84, FR85

**Additional:** ARCH-REQ-14, BRAIN-REQ-3

**Dependencies:** Epic 0, Epic 1, tous les epics fonctionnels

---

### Epic 16: Compliance & Legal

**User Outcome:** L'application respecte toutes contraintes légales RGPD/CNIL/UE avec disclaimers obligatoires nutrition/péremption/prix affichés dans contextes appropriés (Epics 3, 8, 12), gestion consentements granulaires (Epic 7), encryption données sensibles, API keys protection serveur-side, et processus complets export/suppression données.

**FRs covered:** FR69, FR70, FR71 (implémentés dans epics respectifs), compliance transversale

**NFRs covered:** NFR-S1, NFR-S3, NFR-S4, NFR-S5, NFR-S6

**Additional:** BRAIN-REQ-10, BRAIN-REQ-11, BRAIN-REQ-12

**Dependencies:** Epic 0 - Implémenté progressivement dans tous les epics concernés

---

# DETAILED STORIES

## Epic 0: Initial App Setup for First User

### Story 0.1: Initialize Flutter Project with Feature-First Structure

As a utilisateur,
I want the application to be properly initialized with a solid architectural foundation,
So that I can benefit from a stable, performant, and maintainable app from day one.

**Acceptance Criteria:**

**Given** the project needs to be created from scratch
**When** the development team runs the Flutter initialization command
**Then** the project is created with org identifier "com.frigofute" and platforms iOS/Android
**And** the Feature-First directory structure is set up with 14 module placeholders
**And** the project compiles successfully with no errors

---

### Story 0.2: Configure Firebase Services Integration

As a utilisateur,
I want my data to be securely stored and synchronized in the cloud,
So that I can access my inventory and settings from any device reliably.

**Acceptance Criteria:**

**Given** the Flutter project is initialized
**When** Firebase is configured for both iOS and Android platforms
**Then** Firebase Auth, Firestore, Cloud Functions, Cloud Storage, Remote Config, and Crashlytics are properly integrated
**And** Firebase configuration files (google-services.json, GoogleService-Info.plist) are correctly placed
**And** Firebase SDK initialization succeeds on app launch
**And** Environment-specific configurations (dev, staging, prod) are separated

---

### Story 0.3: Set Up Hive Local Database for Offline Storage

As a utilisateur,
I want the app to work seamlessly even without internet connection,
So that I can manage my inventory anytime, anywhere without interruption.

**Acceptance Criteria:**

**Given** the app needs to support offline-first functionality
**When** Hive is configured and initialized on app startup
**Then** Hive boxes are created for inventory, nutrition, recipes, settings, and sync queue
**And** Boxes for health data (nutrition_box) are encrypted with AES-256
**And** Data persistence is verified across app restarts
**And** Hive initialization completes in less than 500ms

---

### Story 0.4: Implement Riverpod State Management Foundation

As a utilisateur,
I want the app to respond instantly to my actions without lag or bugs,
So that I have a smooth and enjoyable user experience.

**Acceptance Criteria:**

**Given** the app requires reactive state management
**When** Riverpod 2.6+ is integrated with provider scoping
**Then** Global providers are set up for authentication, network status, and feature flags
**And** Feature-scoped providers are prepared for each of the 14 modules
**And** Provider dependencies are properly configured
**And** State changes trigger UI updates in less than 100ms

---

### Story 0.5: Configure GoRouter for Navigation and Deep Linking

As a utilisateur,
I want to navigate seamlessly between app features and share specific screens via links,
So that I can quickly access the information I need and share it with others.

**Acceptance Criteria:**

**Given** the app needs declarative routing with deep linking support
**When** GoRouter is configured with route definitions for all 14 modules
**Then** Navigation between screens works correctly with proper stack management
**And** Deep links (frigofute://...) are registered and handled for iOS and Android
**And** Route guards are implemented for premium features
**And** Navigation transitions are smooth with no jank (60 fps maintained)

---

### Story 0.6: Set Up CI/CD Pipeline with Quality Gates

As a utilisateur,
I want to receive app updates that are thoroughly tested and reliable,
So that I never experience crashes or bugs that disrupt my workflow.

**Acceptance Criteria:**

**Given** the project needs automated build and deployment
**When** GitHub Actions workflow is configured with Fastlane
**Then** CI pipeline runs on every commit with build, linting, and tests
**And** Quality gates block merges if code coverage is below 75%
**And** Quality gates block merges if linting errors exist
**And** Automated deployment is configured for Firebase App Distribution (staging)
**And** Staged rollout configuration (5% → 25% → 100% over 72h) is prepared

---

### Story 0.7: Implement Crash Reporting and Performance Monitoring

As a utilisateur,
I want the development team to quickly identify and fix any issues I encounter,
So that the app continuously improves and remains highly reliable.

**Acceptance Criteria:**

**Given** the app needs observability for production issues
**When** Firebase Crashlytics and Performance Monitoring are integrated
**Then** Crash reports are automatically sent with device info, logs, and stack traces
**And** Custom performance traces are configured for critical operations (scan OCR, API calls)
**And** Network request monitoring is enabled for Firebase and external APIs
**And** Crash-free rate metric is tracked and visible in Firebase console
**And** Alerts are configured for crash rate exceeding 0.5%

---

### Story 0.8: Configure Feature Flags via Firebase Remote Config

As a utilisateur,
I want to access new features gradually as they are tested and perfected,
So that I always have a stable experience while still benefiting from innovation.

**Acceptance Criteria:**

**Given** the app needs dynamic feature toggling for freemium and A/B testing
**When** Firebase Remote Config is integrated with default values
**Then** Feature flags are defined for all 14 modules (6 free, 8 premium)
**And** Remote Config fetches and activates on app startup (with cache)
**And** Feature flag values can be updated server-side without app release
**And** Premium feature guard widgets (PremiumFeatureGuard) are implemented
**And** Fetch timeout is configured to 5 seconds with fallback to cache

---

### Story 0.9: Implement Offline-First Sync Architecture Foundation

As a utilisateur,
I want my changes to be saved instantly even offline and synchronized automatically when I reconnect,
So that I never lose my data and can work without worrying about connectivity.

**Acceptance Criteria:**

**Given** the app must support offline-first with bidirectional sync
**When** the sync architecture pattern is implemented (Optimistic UI + background sync)
**Then** Local mutations (Hive) are queued when offline
**And** Sync queue is processed automatically when network is detected
**And** Conflict resolution strategy (Last-Write-Wins) is implemented for Firestore ↔ Hive
**And** Sync status is visible to users (synced, syncing, offline)
**And** Sync errors are logged and retried with exponential backoff (max 3 attempts)

---

### Story 0.10: Configure Security Foundation and API Keys Management

As a utilisateur,
I want my personal and health data to be protected with the highest security standards,
So that I can trust the app with my sensitive information.

**Acceptance Criteria:**

**Given** the app handles sensitive health data (RGPD Article 9)
**When** security infrastructure is configured
**Then** API keys (Google Vision, Gemini, Firebase) are stored server-side in Cloud Functions environment config
**And** API keys are never exposed in client code or version control
**And** TLS 1.3+ is enforced for all network communications
**And** AES-256 encryption is configured for Hive boxes containing health data
**And** Input sanitization utilities are created to prevent SQL/XSS injection
**And** Security linting rules are added to CI pipeline

---

## Epic 1: User Authentication & Profile Management

### Story 1.1: Create Account with Email and Password

As a Sophie (utilisatrice famille),
I want to create an account with my email and password,
So that I can save my food inventory and access it from multiple devices.

**Acceptance Criteria:**

**Given** I have downloaded the FrigoFute app and opened it for the first time
**When** I click "Create Account" and enter my email, password (min 8 chars), and confirm password
**Then** my account is created successfully and I receive a verification email
**And** I am automatically logged in and redirected to the onboarding screen
**And** my password is encrypted and stored securely (Firebase Auth)
**And** I see a clear error message if the email is already registered or password is too weak

---

### Story 1.2: Login with Email and Password

As a Thomas (utilisateur sportif),
I want to login with my existing email and password,
So that I can access my saved food inventory and nutrition tracking.

**Acceptance Criteria:**

**Given** I have an existing FrigoFute account
**When** I enter my email and correct password and click "Login"
**Then** I am authenticated successfully and redirected to the dashboard
**And** my authentication token is valid for 7 days of inactivity
**And** if I enter wrong password 3 times, I see a "Forgot password?" link
**And** I receive clear error messages for invalid credentials

---

### Story 1.3: Login with OAuth (Google Sign-In)

As a Lucas (étudiant),
I want to login quickly using my Google account,
So that I can start using the app immediately without creating another password.

**Acceptance Criteria:**

**Given** I am on the login screen
**When** I click "Continue with Google" and select my Google account
**Then** I am authenticated via OAuth2 and logged in successfully
**And** my profile is created automatically with my Google name and email
**And** I am redirected to the onboarding screen
**And** my Google profile picture is used as my avatar

---

### Story 1.4: Login with OAuth (Apple Sign-In)

As a Marie (senior utilisatrice),
I want to login securely using my Apple ID,
So that I can protect my privacy and avoid sharing my email address if I choose.

**Acceptance Criteria:**

**Given** I am on the login screen using an iOS device
**When** I click "Continue with Apple" and authenticate with Face ID or password
**Then** I am authenticated via Apple OAuth2 and logged in successfully
**And** I can choose to hide my real email (Apple private relay)
**And** my profile is created with my Apple name or pseudonym
**And** I am redirected to the onboarding screen

---

### Story 1.5: Complete Adaptive Onboarding Flow

As a utilisateur,
I want a quick, personalized onboarding experience adapted to my profile,
So that I can start using the app immediately with relevant features for my needs.

**Acceptance Criteria:**

**Given** I have just created my account or logged in for the first time
**When** I enter the onboarding flow
**Then** I am asked to select my profile type (Famille, Sportif, Senior, Étudiant)
**And** I complete a maximum of 5 onboarding screens in less than 2 minutes
**And** the onboarding content is personalized to my selected profile
**And** I can skip onboarding at any time
**And** I am redirected to the main dashboard after completion

---

### Story 1.6: Configure Personal Profile with Physical Characteristics

As a Thomas (sportif),
I want to enter my physical characteristics (weight, height, age, activity level),
So that the app can calculate my daily calorie needs and personalize nutrition recommendations.

**Acceptance Criteria:**

**Given** I am in the profile settings screen
**When** I enter my weight (kg), height (cm), age, gender, and activity level
**Then** my profile is saved successfully
**And** the app calculates my TDEE and BMR automatically (displayed in nutrition module)
**And** I can update these values at any time
**And** changes trigger recalculation of nutrition targets

---

### Story 1.7: Set Dietary Preferences and Allergies

As a Sophie (maman famille),
I want to specify dietary restrictions and allergies for my family,
So that the app never suggests recipes containing ingredients we cannot eat.

**Acceptance Criteria:**

**Given** I am in the profile settings screen
**When** I select dietary preferences (vegetarian, vegan, gluten-free, lactose-free, etc.) and add allergies
**Then** my preferences are saved successfully
**And** recipe suggestions automatically exclude incompatible recipes
**And** I receive warnings if I try to add an allergen to my inventory
**And** I can update preferences at any time

---

### Story 1.8: Synchronize Data Across Multiple Devices

As a Sophie (famille),
I want my inventory and settings to sync automatically across my phone and tablet,
So that I can use whichever device is most convenient without losing data.

**Acceptance Criteria:**

**Given** I am logged in on multiple devices with the same account
**When** I make changes on one device (add product, update settings)
**Then** the changes sync to Firestore within 5 seconds if online
**And** I see the updated data on my other devices within 10 seconds
**And** if I am offline, changes sync automatically when I reconnect
**And** I see a sync status indicator (synced, syncing, offline)

---

### Story 1.9: Export Personal Data (RGPD Portability)

As a Marie (senior),
I want to download all my personal data in a readable format,
So that I have a copy of my information and can comply with my RGPD rights.

**Acceptance Criteria:**

**Given** I am in the privacy settings screen
**When** I click "Export my data"
**Then** the app generates a complete export of my data (inventory, nutrition, settings) in JSON format
**And** I receive a download link via email within 24 hours
**And** the export includes all personal data categories with clear labels
**And** I can open the JSON file and read my data

---

### Story 1.10: Delete Account and All Data Permanently

As a utilisateur,
I want to permanently delete my account and all associated data,
So that I can exercise my RGPD right to be forgotten if I stop using the app.

**Acceptance Criteria:**

**Given** I am in the account settings screen
**When** I click "Delete account" and confirm my choice twice
**Then** I receive a confirmation email warning about data deletion
**And** my account and all personal data are scheduled for deletion within 30 days
**And** I can cancel the deletion within 30 days if I change my mind
**And** after 30 days, all data is permanently deleted from Firebase and backups
**And** I receive a final confirmation email after deletion

---

## Epic 2: Inventory Management

### Story 2.1: Add Product Manually to Inventory

As a Marie (senior),
I want to add homemade products or items without barcodes manually to my inventory,
So that I can track everything I have in my fridge and pantry.

**Acceptance Criteria:**

**Given** I am on the inventory screen
**When** I click "Add product manually" and fill in name, category, quantity, expiration date, and location
**Then** the product is added successfully to my inventory
**And** the product appears immediately in my inventory list
**And** the system assigns a default category if I don't specify one
**And** the system assigns a default storage location if I don't specify one

---

### Story 2.2: Edit Product Information in Inventory

As a Sophie (famille),
I want to modify product details like quantity or expiration date,
So that I can keep my inventory accurate when I use part of a product or find a different date.

**Acceptance Criteria:**

**Given** I have products in my inventory
**When** I tap on a product and select "Edit", then modify any field (quantity, date, location)
**Then** the changes are saved successfully
**And** the updated information is displayed immediately in the inventory
**And** the product status (fresh, expiring soon, expired) is recalculated if the date changed
**And** changes sync to Firestore if online, or queue for sync if offline

---

### Story 2.3: Delete Product from Inventory

As a Lucas (étudiant),
I want to remove products I threw away or that are no longer in my inventory,
So that my inventory stays clean and accurate.

**Acceptance Criteria:**

**Given** I have products in my inventory
**When** I swipe left on a product and tap "Delete", or select "Delete" from product details
**Then** a confirmation dialog appears asking "Are you sure?"
**And** when I confirm, the product is removed from my inventory immediately
**And** the deletion syncs to Firestore if online
**And** I can undo the deletion within 5 seconds using a snackbar action

---

### Story 2.4: Mark Product as Consumed

As a Thomas (sportif),
I want to mark products as consumed when I eat them,
So that the app can track my consumption and remove them from my active inventory.

**Acceptance Criteria:**

**Given** I have products in my inventory
**When** I tap "Mark as consumed" on a product
**Then** the product is moved to "Consumed" status and removed from the active inventory
**And** the consumption is logged with timestamp for dashboard metrics
**And** the product contributes to my nutrition tracking if nutrition module is active
**And** I see visual feedback confirming the action

---

### Story 2.5: View Inventory with Filters by Category

As a Sophie (famille),
I want to filter my inventory by food category (dairy, vegetables, meat, etc.),
So that I can quickly see what I have in each category and plan my meals.

**Acceptance Criteria:**

**Given** I have products in my inventory across multiple categories
**When** I select a category filter (e.g., "Dairy", "Vegetables")
**Then** only products in the selected category are displayed
**And** I can see the count of products in each category
**And** I can select multiple categories simultaneously
**And** I can clear filters to see all products again
**And** filter state is preserved when I navigate away and return

---

### Story 2.6: View Inventory with Filters by Storage Location

As a Marie (senior),
I want to filter my inventory by storage location (fridge, freezer, pantry),
So that I can see exactly what is in each location when I'm organizing my kitchen.

**Acceptance Criteria:**

**Given** I have products stored in different locations (6 locations available)
**When** I select a location filter (e.g., "Refrigerator", "Freezer")
**Then** only products in the selected location are displayed
**And** I can see the count of products in each location
**And** I can select multiple locations simultaneously
**And** filter state is preserved across sessions

---

### Story 2.7: View Inventory with Filters by Product Status

As a Lucas (étudiant),
I want to filter my inventory by product status (fresh, expiring soon, expired),
So that I can prioritize what to use first and avoid waste.

**Acceptance Criteria:**

**Given** I have products with different statuses in my inventory
**When** I select a status filter (e.g., "Expiring soon", "Expired")
**Then** only products with the selected status are displayed
**And** status is calculated based on expiration date and current date
**And** "Expiring soon" includes products within configured alert window (default 2 days for DLC)
**And** expired products are visually highlighted in red
**And** I can clear the filter to see all products

---

### Story 2.8: Automatic Product Categorization for Scanned Items

As a Thomas (sportif),
I want scanned products to be automatically categorized,
So that I don't have to manually organize every item I add.

**Acceptance Criteria:**

**Given** I scan a product barcode or ticket
**When** the product information is retrieved from OpenFoodFacts or OCR
**Then** the system automatically assigns one of the 12 predefined categories based on product type
**And** the categorization is accurate for at least 85% of common products
**And** I can manually change the category if the automatic assignment is incorrect
**And** the system learns from manual corrections to improve future categorization

---

### Story 2.9: Automatic Storage Location Assignment for Added Products

As a Sophie (famille),
I want new products to be assigned a default storage location automatically,
So that I don't have to specify it every time unless I want to.

**Acceptance Criteria:**

**Given** I add a product to my inventory
**When** the product category is determined (automatic or manual)
**Then** the system assigns one of the 6 default storage locations based on category
**And** fresh products (dairy, meat, vegetables) are assigned to "Refrigerator"
**And** frozen products are assigned to "Freezer"
**And** dry goods (pasta, rice, cans) are assigned to "Pantry"
**And** I can manually override the location before or after adding

---

### Story 2.10: Track Product Status Lifecycle (Fresh → Expiring → Expired → Consumed)

As a utilisateur,
I want to see the current status of each product visually,
So that I can quickly identify what needs to be used soon and what is still fresh.

**Acceptance Criteria:**

**Given** I have products in my inventory with different expiration dates
**When** I view my inventory list
**Then** each product displays a visual status indicator (color badge or icon)
**And** "Fresh" products (expiration >3 days) are displayed with green indicator
**And** "Expiring soon" products (expiration ≤2 days for DLC) are displayed with yellow/orange indicator
**And** "Expired" products are displayed with red indicator
**And** product status is recalculated automatically every day at midnight
**And** status changes trigger notifications if alerts are enabled

---

### Story 2.11: Search Products in Inventory

As a Lucas (étudiant),
I want to search for specific products by name in my inventory,
So that I can quickly find what I'm looking for without scrolling.

**Acceptance Criteria:**

**Given** I have many products in my inventory
**When** I type a product name in the search bar
**Then** the inventory list filters to show only matching products in real-time
**And** search is case-insensitive
**And** search matches partial names (e.g., "tom" matches "Tomatoes")
**And** I can clear the search to see all products again
**And** search performs smoothly even with 1,000 products

---

### Story 2.12: Inventory Works Fully Offline

As a Marie (senior),
I want to manage my inventory even when I have no internet connection,
So that I can use the app anywhere without worrying about connectivity.

**Acceptance Criteria:**

**Given** I have no internet connection
**When** I add, edit, delete, or mark products as consumed
**Then** all changes are saved immediately to local Hive storage
**And** the UI responds instantly without lag (<100ms)
**And** I see an "Offline" indicator in the app header
**And** when I reconnect to internet, all changes sync automatically to Firestore
**And** no data is lost during offline operations

---

## Epic 3: Expiration Alerts & Notifications

### Story 3.1: Receive Push Notification for DLC Expiration (2 Days Before)

As a Sophie (famille),
I want to receive a notification 2 days before a product's DLC (Date Limite Consommation) expires,
So that I can use it in time and avoid throwing away food.

**Acceptance Criteria:**

**Given** I have products with DLC expiration dates in my inventory
**When** a product is 2 days away from its DLC expiration date
**Then** I receive a push notification with the product name and expiration date
**And** the notification is marked as urgent (critical priority) with distinct sound
**And** the notification is delivered with >99% reliability
**And** tapping the notification opens the app to the product details or recipe suggestions
**And** the notification respects quiet hours if configured

---

### Story 3.2: Receive Push Notification for DDM Expiration (5 Days Before)

As a Marie (senior),
I want to receive a reminder 5 days before a product's DDM (Date Durabilité Minimale) expires,
So that I can plan to use it even though it's not urgent.

**Acceptance Criteria:**

**Given** I have products with DDM expiration dates in my inventory
**When** a product is 5 days away from its DDM expiration date
**Then** I receive a push notification with the product name and expiration date
**And** the notification is marked as informational (standard priority) with soft sound
**And** the notification clearly states "Best before" vs "Use by" to avoid confusion
**And** tapping the notification opens the app to the product details
**And** I can dismiss the notification without penalty

---

### Story 3.3: Visual Differentiation of DLC vs DDM Alerts in App

As a Lucas (étudiant),
I want to easily distinguish critical DLC alerts from informational DDM alerts,
So that I know which products absolutely must be consumed first.

**Acceptance Criteria:**

**Given** I have both DLC and DDM products expiring soon
**When** I view alerts in the app (notifications screen or inventory)
**Then** DLC alerts are displayed with red background and "URGENT" label
**And** DDM alerts are displayed with yellow/orange background and "INFO" label
**And** the difference is explained clearly with a tooltip or info icon
**And** expired DLC products show a red "EXPIRED - Do not consume" warning
**And** expired DDM products show "Quality may be reduced, check before consuming"

---

### Story 3.4: Configure Custom Alert Delay for DLC Products

As a Thomas (sportif),
I want to adjust when I receive alerts for DLC products (e.g., 3 days instead of 2),
So that I have more flexibility based on my meal prep schedule.

**Acceptance Criteria:**

**Given** I am in the notifications settings screen
**When** I select "DLC alert delay" and choose a value (1-7 days)
**Then** my preference is saved successfully
**And** future DLC alerts are sent according to my custom delay
**And** the default value is 2 days if I don't customize
**And** I can reset to default at any time

---

### Story 3.5: Configure Custom Alert Delay for DDM Products

As a Sophie (famille),
I want to adjust when I receive alerts for DDM products,
So that I can balance reducing waste with not getting too many notifications.

**Acceptance Criteria:**

**Given** I am in the notifications settings screen
**When** I select "DDM alert delay" and choose a value (3-14 days)
**Then** my preference is saved successfully
**And** future DDM alerts are sent according to my custom delay
**And** the default value is 5 days if I don't customize
**And** I can reset to default at any time

---

### Story 3.6: Disable Notifications for Specific Product Categories

As a Marie (senior),
I want to turn off notifications for certain categories (e.g., condiments, spices),
So that I don't get alerts for products that rarely spoil.

**Acceptance Criteria:**

**Given** I am in the notifications settings screen
**When** I toggle off notifications for selected categories (e.g., "Condiments", "Dry Goods")
**Then** my preferences are saved successfully
**And** I no longer receive expiration alerts for products in disabled categories
**And** I can re-enable categories at any time
**And** the change applies to both DLC and DDM alerts

---

### Story 3.7: Configure Quiet Hours for Notifications

As a Lucas (étudiant),
I want to set quiet hours (e.g., 10 PM - 8 AM) when I don't receive notifications,
So that I can sleep without being disturbed by food alerts.

**Acceptance Criteria:**

**Given** I am in the notifications settings screen
**When** I enable quiet hours and set start/end times
**Then** my quiet hours preferences are saved successfully
**And** I do not receive push notifications during the quiet hours window
**And** notifications scheduled during quiet hours are delayed until the end of the window
**And** critical DLC alerts on expiration day can optionally override quiet hours (user setting)
**And** I can disable quiet hours at any time

---

### Story 3.8: View Disclaimer About Expiration Alert Responsibility

As a utilisateur,
I want to understand that I am responsible for verifying product freshness visually,
So that I use the app as a helpful tool but make my own final decisions.

**Acceptance Criteria:**

**Given** I am using the expiration alerts feature for the first time
**When** I receive my first notification or view the notifications settings
**Then** I see a clear disclaimer stating:
"Expiration alerts are indicative and based on dates you entered. FrigoFute does not guarantee product freshness. Always verify products visually and by smell before consuming. You are responsible for your food safety."
**And** I must acknowledge the disclaimer before continuing
**And** the disclaimer is accessible in settings for future reference
**And** the disclaimer complies with legal liability requirements

---

## Epic 4: Dashboard & Impact Metrics

### Story 4.1: View Dashboard Summary Widget with Real-Time Metrics

As a Sophie (famille),
I want to see a quick summary of my anti-waste impact when I open the app,
So that I feel motivated and proud of my progress.

**Acceptance Criteria:**

**Given** I have been using the app for at least one week
**When** I open the dashboard screen
**Then** I see a summary widget displaying:
- Total food waste avoided (kg) this week/month
- Money saved (€) this week/month
- CO2 emissions avoided (kg CO2eq) this week/month
**And** the widget loads and displays in less than 1 second
**And** metrics are calculated from my consumption logs and expired products avoided
**And** I can tap the widget to see detailed breakdowns

---

### Story 4.2: View Food Waste Avoided Metric (kg and €)

As a Marie (senior),
I want to see exactly how much food I've saved from waste in kilograms and euros,
So that I can quantify my anti-waste efforts.

**Acceptance Criteria:**

**Given** I have consumed products before expiration using the app
**When** I view the detailed dashboard metrics screen
**Then** I see "Food waste avoided" displayed in both kg and euros
**And** the calculation includes products marked as consumed before DLC/DDM expiration
**And** the € value is estimated based on average product prices or user-entered values
**And** I can filter the metric by time period (this week, this month, this year, all time)
**And** the metric updates in real-time as I mark products as consumed

---

### Story 4.3: View Ecological Impact Metric (CO2eq Avoided)

As a Thomas (sportif eco-responsable),
I want to see my environmental impact in terms of CO2 emissions avoided,
So that I can understand the broader ecological benefit of reducing food waste.

**Acceptance Criteria:**

**Given** I have avoided food waste using the app
**When** I view the dashboard metrics screen
**Then** I see "CO2eq avoided" displayed in kg CO2eq
**And** the calculation is based on food waste avoided (kg) × average CO2eq emission factor per food category
**And** the metric is explained with a tooltip: "CO2eq includes production, transport, and waste processing emissions avoided"
**And** I can filter the metric by time period
**And** the metric updates automatically as I use the app

---

### Story 4.4: View Temporal Evolution Charts for Metrics

As a Sophie (famille),
I want to see graphs showing how my anti-waste metrics evolve over time,
So that I can track my progress and see trends.

**Acceptance Criteria:**

**Given** I have used the app for multiple weeks
**When** I view the dashboard metrics screen and scroll to charts
**Then** I see line charts displaying:
- Food waste avoided (kg) per week over the last 3 months
- Money saved (€) per week over the last 3 months
- CO2eq avoided per week over the last 3 months
**And** the charts are visually clear with labeled axes
**And** I can tap on data points to see exact values
**And** charts load in less than 2 seconds
**And** I can switch between weekly, monthly, and yearly views

---

### Story 4.5: View Nutritional Statistics on Dashboard (Premium)

As a Thomas (sportif premium),
I want to see aggregated nutritional statistics on my dashboard,
So that I can track my dietary balance at a glance.

**Acceptance Criteria:**

**Given** I am a premium user with nutrition tracking enabled
**When** I view the dashboard
**Then** I see a nutrition widget displaying:
- Percentage of balanced days this week (macros within targets)
- Average daily calories this week
- Average macros (protein, carbs, fats) this week
**And** the widget displays visual indicators (green check for balanced, yellow warning for imbalanced)
**And** I can tap the widget to access detailed nutrition history
**And** the widget updates daily at midnight

---

### Story 4.6: Dashboard Widgets Load Fast from Local Cache

As a Lucas (étudiant),
I want the dashboard to load instantly even on slow connections,
So that I can check my stats quickly without waiting.

**Acceptance Criteria:**

**Given** I open the app dashboard
**When** the dashboard screen is rendered
**Then** all widgets load and display within 1 second using local Hive cache
**And** if online, updated data from Firestore is fetched in the background
**And** if new data is available, widgets update smoothly without jarring UI changes
**And** if offline, I see the last synced data with a timestamp "Last updated: X hours ago"

---

## Epic 5: OCR & Barcode Scanning

### Story 5.1: Scan Product Barcode (EAN-13) to Add to Inventory

As a Lucas (étudiant),
I want to quickly scan product barcodes to add them to my inventory,
So that I can avoid tedious manual entry and save time.

**Acceptance Criteria:**

**Given** I am on the "Add product" screen
**When** I tap "Scan barcode" and point my camera at an EAN-13 barcode
**Then** the barcode is recognized in less than 500ms
**And** product information is retrieved from OpenFoodFacts API
**And** the product is automatically added to my inventory with name, category, and nutrition data
**And** I can manually adjust quantity and expiration date before confirming
**And** if the barcode is not found in OpenFoodFacts, I am prompted to add it manually

---

### Story 5.2: Scan Receipt via OCR to Add Multiple Products

As a Sophie (famille),
I want to scan my grocery receipt and have all products added automatically,
So that I can inventory 100+ items in seconds instead of typing each one.

**Acceptance Criteria:**

**Given** I am on the "Add product" screen
**When** I tap "Scan receipt" and take a photo of my grocery receipt
**Then** the OCR engine (Google Vision + ML Kit dual-engine) processes the image in less than 2 seconds
**And** products are extracted automatically with names and quantities
**And** extracted products are displayed in a review list for confirmation
**And** I can edit or remove incorrectly detected products before confirming
**And** all confirmed products are added to my inventory in batch
**And** the "moment magique" wow effect is delivered (100+ products in <2s)

---

### Story 5.3: OCR Dual-Engine with Automatic Fallback (Google Vision + ML Kit)

As a Thomas (sportif),
I want the app to use the best OCR engine available to ensure high accuracy,
So that my receipt scans are reliable and I don't have to correct many errors.

**Acceptance Criteria:**

**Given** I scan a receipt via OCR
**When** the OCR processing starts
**Then** Google Cloud Vision API is attempted first (higher accuracy)
**And** if Vision API fails or times out (>2s), ML Kit is used as fallback in less than 500ms
**And** if both engines are unavailable, I see an error message with retry option
**And** OCR engine selection is transparent to me (automatic)
**And** the chosen engine is logged for analytics (to monitor Vision API quota usage)

---

### Story 5.4: Display OCR Confidence Score and Allow Manual Correction

As a Marie (senior),
I want to see how confident the app is about the scanned products,
So that I can review and correct any mistakes before adding them to my inventory.

**Acceptance Criteria:**

**Given** I have scanned a receipt via OCR
**When** the extracted products are displayed for review
**Then** each product shows a confidence score (e.g., "95% confident")
**And** products with low confidence (<70%) are highlighted in yellow for review
**And** I can tap any product to edit name, quantity, or category
**And** I can delete products that were incorrectly detected
**And** I can manually add products that were missed by OCR
**And** I confirm the final list before products are added to inventory

---

### Story 5.5: Enrich Scanned Products with Nutritional Data from OpenFoodFacts

As a Thomas (sportif),
I want scanned products to automatically include nutritional information,
So that I can track my macros and calories without looking them up manually.

**Acceptance Criteria:**

**Given** I scan a barcode or receipt
**When** a product is recognized and added to my inventory
**Then** the app fetches nutritional data (calories, protein, carbs, fats) from OpenFoodFacts API
**And** nutritional data is displayed in product details
**And** if nutritional data is unavailable, the product is still added with a "No nutritional data" label
**And** I can manually add or edit nutritional values
**And** nutritional data is cached locally for 7 days to reduce API calls

---

### Story 5.6: Handle OCR Failures Gracefully with Clear Error Messages

As a Lucas (étudiant),
I want helpful error messages if my receipt scan fails,
So that I know what to do to fix the problem.

**Acceptance Criteria:**

**Given** I attempt to scan a receipt
**When** the OCR process fails (e.g., poor image quality, non-French receipt, API error)
**Then** I see a clear error message explaining the issue:
- "Image quality too low. Please take a clearer photo in good lighting."
- "This receipt format is not recognized. Please try a different receipt or add products manually."
- "OCR service temporarily unavailable. Please try again later."
**And** I am offered options to retry, take a new photo, or add products manually
**And** the error is logged for analytics to improve OCR accuracy

---

### Story 5.7: OCR Optimized for French Grocery Receipts

As a Sophie (famille),
I want the OCR to accurately recognize French receipt formats from major retailers,
So that my scans work reliably at Carrefour, Leclerc, Auchan, and other stores.

**Acceptance Criteria:**

**Given** I shop at major French retailers
**When** I scan receipts from Carrefour, Leclerc, Auchan, Intermarché, Casino, or Lidl
**Then** the OCR extracts product names and quantities with at least 85% accuracy
**And** common French product names are recognized correctly (e.g., "Yaourt", "Baguette", "Lait")
**And** receipt structure (headers, totals, product lines) is parsed correctly
**And** non-product lines (totals, payment info) are filtered out automatically
**And** the OCR handles various receipt fonts and layouts

---

### Story 5.8: Barcode Scan with Visual Guidance for Correct Positioning

As a Marie (senior),
I want clear visual guidance when scanning barcodes,
So that I know how to position the camera correctly for successful scans.

**Acceptance Criteria:**

**Given** I am on the barcode scan screen
**When** I point my camera at a barcode
**Then** I see a visual frame overlay indicating the scan area
**And** I see real-time feedback: "Move closer", "Hold steady", "Barcode detected"
**And** the camera auto-focuses on the barcode
**And** when the barcode is successfully scanned, I hear a confirmation beep and see a green checkmark
**And** the interface is simple and easy to understand for senior users

---

### Story 5.9: Cache OpenFoodFacts Data Locally for Offline Barcode Scans

As a Lucas (étudiant),
I want to scan products even when I'm offline,
So that I can add items to my inventory at the store without needing internet.

**Acceptance Criteria:**

**Given** I have previously scanned products that are cached locally
**When** I scan a barcode while offline
**Then** if the product is in the local cache, it is added immediately using cached data
**And** if the product is not in cache, I see a message: "Product not found. Add manually or try again when online."
**And** when I reconnect, the app fetches and caches nutritional data for any newly added products
**And** the local cache stores up to 1,000 most recently scanned products
**And** cache entries expire after 7 days

---

### Story 5.10: Monitor and Display OCR/Barcode Scan Success Rate

As a utilisateur,
I want the development team to track scan success rates,
So that the app continuously improves and becomes more reliable over time.

**Acceptance Criteria:**

**Given** I scan barcodes and receipts regularly
**When** the app processes scans
**Then** scan success/failure events are logged to Firebase Analytics
**And** metrics include: scan type (barcode/receipt), success rate, OCR confidence, engine used (Vision/ML Kit)
**And** the development team can view aggregated metrics in dashboards
**And** failed scans are anonymously logged with error types for debugging
**And** quota usage for Google Vision API is tracked to avoid overage

---

## Epic 6: Recipe Discovery & Suggestions

### Story 6.1: Search Recipes Based on Current Inventory

As a Sophie (famille),
I want to find recipes that I can make with the ingredients I already have,
So that I can cook without needing to go shopping.

**Acceptance Criteria:**

**Given** I have products in my inventory
**When** I navigate to the "Recipes" screen and tap "Find recipes with my ingredients"
**Then** the app displays recipes that match at least 70% of ingredients with my inventory
**And** recipes are sorted by match percentage (highest first)
**And** each recipe shows which ingredients I have and which I'm missing
**And** I can filter to show only recipes I can make 100% with current inventory
**And** search completes in less than 1 second

---

### Story 6.2: Filter Recipes by Budget (Cheap, Moderate, Expensive)

As a Lucas (étudiant),
I want to filter recipes by budget so I only see affordable options,
So that I can cook delicious meals without overspending.

**Acceptance Criteria:**

**Given** I am browsing recipes
**When** I apply the "Budget" filter and select "Cheap" (< 3€/portion)
**Then** only recipes within the selected budget range are displayed
**And** each recipe shows the estimated cost per portion
**And** I can adjust the budget range with a slider
**And** filter state is preserved when I navigate away and return

---

### Story 6.3: Filter Recipes by Preparation Time

As a Thomas (sportif),
I want to filter recipes by preparation time (e.g., < 20 minutes),
So that I can cook quick meals on busy days.

**Acceptance Criteria:**

**Given** I am browsing recipes
**When** I apply the "Preparation time" filter and select "< 20 min"
**Then** only recipes that can be prepared in less than 20 minutes are displayed
**And** preparation time is clearly displayed on each recipe card
**And** I can choose from predefined time ranges: <15 min, <30 min, <45 min, <1h, >1h
**And** filter state is preserved across sessions

---

### Story 6.4: Filter Recipes by Difficulty (Easy, Medium, Hard)

As a Marie (senior),
I want to filter recipes by difficulty to find simple recipes I can manage,
So that I don't get overwhelmed with complicated techniques.

**Acceptance Criteria:**

**Given** I am browsing recipes
**When** I apply the "Difficulty" filter and select "Easy"
**Then** only easy recipes are displayed
**And** difficulty is clearly indicated on each recipe card (e.g., 1-3 stars, or Easy/Medium/Hard labels)
**And** "Easy" recipes have simple steps and common techniques
**And** I can select multiple difficulty levels simultaneously

---

### Story 6.5: Filter Recipes by Dietary Regime (Vegetarian, Vegan, Gluten-Free, etc.)

As a Sophie (famille végan),
I want to filter recipes by dietary regime,
So that I only see recipes that match my family's dietary restrictions.

**Acceptance Criteria:**

**Given** I am browsing recipes
**When** I apply the "Diet" filter and select "Vegan"
**Then** only vegan recipes are displayed
**And** recipes automatically respect dietary preferences set in my profile
**And** available diet options include: Vegetarian, Vegan, Gluten-free, Lactose-free, Keto, Paleo
**And** I can combine multiple diet filters
**And** recipes containing allergens from my profile are excluded automatically

---

### Story 6.6: Receive Recipe Suggestions for Products Expiring Soon

As a Marie (senior),
I want to receive recipe suggestions when products are about to expire,
So that I can use them in time and avoid waste.

**Acceptance Criteria:**

**Given** I have products expiring within 2 days in my inventory
**When** I receive an expiration notification or view my dashboard
**Then** I see suggested recipes that prioritize using the expiring products
**And** suggestions are contextual and relevant (e.g., "Use your expiring tomatoes in this pasta recipe")
**And** I can tap the suggestion to view the full recipe
**And** suggestions appear in notifications, dashboard, and recipe screen

---

### Story 6.7: Mark Recipes as Favorites for Quick Access

As a Thomas (sportif),
I want to save my favorite recipes,
So that I can quickly find and cook them again without searching.

**Acceptance Criteria:**

**Given** I am viewing a recipe
**When** I tap the "Favorite" heart icon
**Then** the recipe is added to my "Favorites" collection
**And** I can access all my favorite recipes from a dedicated "Favorites" tab
**And** I can remove a recipe from favorites by tapping the heart icon again
**And** favorites sync across devices via Firestore
**And** favorites are accessible offline via local Hive storage

---

### Story 6.8: View Detailed Recipe Tutorial with Step-by-Step Instructions

As a Lucas (étudiant débutant cuisine),
I want clear, step-by-step instructions for each recipe,
So that I can follow along easily and succeed even as a beginner.

**Acceptance Criteria:**

**Given** I have selected a recipe to cook
**When** I tap "View recipe" and navigate to the recipe details screen
**Then** I see a clear list of ingredients with quantities
**And** I see step-by-step instructions numbered clearly
**And** each step is concise and easy to understand
**And** I can check off steps as I complete them
**And** I can adjust serving sizes and ingredient quantities recalculate automatically

---

### Story 6.9: Recipe Suggestions Adapt to Nutritional Profile (Premium)

As a Thomas (sportif premium),
I want recipe suggestions to prioritize high-protein meals that match my macros,
So that I can hit my fitness goals while enjoying varied meals.

**Acceptance Criteria:**

**Given** I am a premium user with a nutritional profile configured (e.g., "Athlete - Muscle Gain")
**When** I browse recipes or receive suggestions
**Then** recipes are ranked/filtered to prioritize those matching my macro targets (high protein, moderate carbs)
**And** each recipe displays macros per serving (calories, protein, carbs, fats)
**And** I see a badge like "Matches your goals" on suitable recipes
**And** I can toggle this filter on/off in settings

---

### Story 6.10: Access Recipe Database of 10,000+ Recipes with Fast Search

As a Sophie (famille),
I want access to a large variety of recipes with fast search,
So that I never run out of cooking inspiration.

**Acceptance Criteria:**

**Given** the app has a recipe database with 10,000+ recipes
**When** I search for a recipe by name or ingredient (e.g., "chicken", "pasta")
**Then** search results appear in less than 1 second
**And** search uses full-text indexing for performance
**And** I can search by recipe name, ingredient, or cuisine type
**And** search handles typos gracefully with fuzzy matching
**And** popular recipes are prioritized in results

---

## Epic 7: Nutritional Tracking

### Story 7.1: Activate Nutrition Tracking with Double Opt-In

As a Thomas (sportif),
I want to explicitly consent to nutrition tracking with clear information,
So that I understand how my health data will be used and stored.

**Acceptance Criteria:**

**Given** I want to enable nutrition tracking
**When** I navigate to the nutrition module for the first time
**Then** I see a clear consent screen explaining:
- What data will be collected (calories, macros, meal logs, photos)
- How the data will be used (personalized nutrition coaching)
- How the data is stored (encrypted, RGPD-compliant)
- My rights (access, deletion, withdrawal of consent)
**And** I must actively check "I agree" to proceed (double opt-in)
**And** I can decline and use the app without nutrition tracking
**And** my consent is logged with timestamp for RGPD compliance

---

### Story 7.2: Log Daily Food Consumption Manually with Calorie/Macro Tracking

As a Sophie (famille),
I want to log meals I eat each day and see calories and macros automatically,
So that I can track my nutrition without complicated calculations.

**Acceptance Criteria:**

**Given** I have enabled nutrition tracking
**When** I tap "Log meal" and add food items from my inventory or recipe database
**Then** the meal is saved with timestamp and nutritional data
**And** calories, protein, carbs, and fats are calculated automatically from OpenFoodFacts data
**And** I can adjust portion sizes and servings
**And** daily totals are updated immediately
**And** I can log breakfast, lunch, dinner, and snacks separately

---

### Story 7.3: View Daily Nutrition Dashboard with Macro Breakdown

As a Thomas (sportif),
I want to see my daily calories and macros at a glance,
So that I can track my progress toward my nutritional goals.

**Acceptance Criteria:**

**Given** I have logged meals today
**When** I view the nutrition dashboard
**Then** I see my daily totals for calories, protein, carbs, and fats
**And** I see visual progress bars showing my current intake vs targets
**And** macros are color-coded: green if within target, yellow if close, red if over/under
**And** I see percentage of daily goals achieved
**And** dashboard updates in real-time as I log meals

---

### Story 7.4: View Weekly and Monthly Nutrition History

As a Sophie (famille),
I want to see my nutrition trends over time,
So that I can understand my eating patterns and make adjustments.

**Acceptance Criteria:**

**Given** I have been tracking nutrition for multiple weeks
**When** I navigate to "Nutrition History"
**Then** I see a calendar view with daily summaries
**And** I can switch between daily, weekly, and monthly views
**And** each day shows a summary: total calories, macro balance, and goal achievement
**And** I can tap any day to see detailed meal logs
**And** I see charts showing trends over time (average calories, macro distribution)

---

### Story 7.5: Withdraw Consent and Delete All Nutrition Data

As a Marie (senior),
I want to stop nutrition tracking and delete all my health data if I change my mind,
So that I have full control over my sensitive information.

**Acceptance Criteria:**

**Given** I have previously consented to nutrition tracking
**When** I navigate to Privacy Settings and tap "Withdraw nutrition data consent"
**Then** I see a confirmation dialog explaining that all nutrition data will be deleted
**And** when I confirm, all nutrition data (meal logs, macros, photos) is scheduled for deletion within 30 days
**And** nutrition features are immediately disabled in the app
**And** I receive a confirmation email
**And** I can re-enable nutrition tracking later with a new opt-in

---

### Story 7.6: View Disclaimer About Non-Medical Device Status

As a utilisateur,
I want to understand that nutrition advice is informational and not medical,
So that I consult a healthcare professional for personalized medical advice.

**Acceptance Criteria:**

**Given** I am using the nutrition tracking feature
**When** I view the nutrition dashboard or coaching advice
**Then** I see a clear disclaimer:
"This app is not a medical device. Nutritional information is indicative and should not replace advice from a qualified healthcare professional. Consult a doctor or dietitian for personalized medical nutrition advice."
**And** the disclaimer is prominently displayed and acknowledged during opt-in
**And** the disclaimer is accessible in settings for future reference

---

### Story 7.7: Encrypt Nutrition Data at Rest and in Transit

As a Thomas (sportif),
I want my health data to be encrypted and secure,
So that my sensitive nutrition information is protected from unauthorized access.

**Acceptance Criteria:**

**Given** I have nutrition tracking enabled
**When** my nutrition data is stored and transmitted
**Then** all nutrition data is encrypted at rest using AES-256 in Hive
**And** all nutrition data is encrypted in transit using TLS 1.3+
**And** encryption keys are managed securely and never exposed
**And** encrypted data is only accessible by authenticated users
**And** the app passes security audits for health data protection

---

### Story 7.8: View Aggregated Nutritional Statistics on Dashboard

As a Sophie (famille),
I want to see how balanced my eating has been overall,
So that I can celebrate successes and identify areas for improvement.

**Acceptance Criteria:**

**Given** I have been tracking nutrition for at least one week
**When** I view the nutrition dashboard
**Then** I see aggregated statistics:
- Percentage of balanced days (macros within target ranges)
- Average daily calories this week/month
- Average macros (protein/carbs/fats) this week/month
**And** statistics are visually clear with charts and percentages
**And** I can filter by time period (this week, this month, last 3 months)
**And** I see encouraging messages like "80% balanced days this week - Great job!"

---

## Epic 8: Nutrition Profiles & Calculations

### Story 8.1: Select Nutritional Profile from 12 Predefined Options

As a Sophie (famille),
I want to choose a nutritional profile that matches my lifestyle,
So that the app gives me personalized recommendations.

**Acceptance Criteria:**

**Given** I am setting up my profile or updating nutrition settings
**When** I tap "Select nutritional profile"
**Then** I see 12 predefined options:
- Family (balanced nutrition)
- Athlete - Muscle Gain (high protein, calorie surplus)
- Athlete - Cutting (high protein, calorie deficit)
- Vegan
- Vegetarian
- Diabetic
- Heart Health (low saturated fats)
- Senior (balanced, lower calories)
- Student (budget-friendly, balanced)
- Weight Loss (calorie deficit)
- Weight Gain (calorie surplus)
- Gluten-Free
**And** each profile has a clear description
**And** I can select one profile that best matches my needs
**And** I can change my profile at any time

---

### Story 8.2: Calculate TDEE (Total Daily Energy Expenditure) Automatically

As a Thomas (sportif),
I want the app to calculate my daily calorie needs based on my body stats,
So that I know exactly how much to eat to reach my goals.

**Acceptance Criteria:**

**Given** I have entered my weight, height, age, gender, and activity level
**When** the app calculates my TDEE
**Then** TDEE is calculated using the Mifflin-St Jeor equation
**And** activity level multiplier is applied (sedentary, lightly active, moderately active, very active, extremely active)
**And** my TDEE is displayed clearly in calories/day
**And** TDEE is recalculated automatically when I update my profile
**And** the calculation is explained with a tooltip for transparency

---

### Story 8.3: Calculate BMR (Basal Metabolic Rate) Automatically

As a Sophie (famille),
I want to see my basal metabolic rate to understand my baseline calorie needs,
So that I can make informed decisions about my nutrition.

**Acceptance Criteria:**

**Given** I have entered my weight, height, age, and gender
**When** the app calculates my BMR
**Then** BMR is calculated using the Mifflin-St Jeor equation
**And** BMR is displayed clearly in calories/day
**And** BMR is explained with a tooltip: "Calories your body burns at rest"
**And** BMR is recalculated automatically when I update my profile

---

### Story 8.4: Set Macro Targets Based on Nutritional Profile

As a Thomas (sportif prise de masse),
I want the app to suggest macro targets aligned with my muscle-gain goal,
So that I get the right protein/carbs/fats ratios.

**Acceptance Criteria:**

**Given** I have selected "Athlete - Muscle Gain" profile
**When** the app calculates my macro targets
**Then** macros are set based on profile recommendations:
- Protein: 2g per kg body weight
- Carbs: 50-55% of calories
- Fats: 20-25% of calories
**And** macro targets are displayed in grams per day
**And** I can manually adjust targets if I have specific preferences
**And** targets are used for nutrition tracking and recipe suggestions

---

### Story 8.5: View Disclaimer for Medical Profiles (Diabetic, Heart Health)

As a utilisateur diabétique,
I want to see a clear warning that I should consult my doctor before following app recommendations,
So that I prioritize my health and safety.

**Acceptance Criteria:**

**Given** I select a medical profile like "Diabetic" or "Heart Health"
**When** the profile selection is confirmed
**Then** I see a prominent disclaimer:
"This profile provides general nutrition guidance only. It is NOT a substitute for medical advice. Consult your doctor or dietitian before making dietary changes, especially if you have a medical condition."
**And** I must acknowledge the disclaimer before proceeding
**And** the disclaimer is accessible in settings for future reference

---

### Story 8.6: Update Dietary Preferences and Allergies

As a Marie (senior allergique aux fruits à coque),
I want to specify my allergies so the app never suggests recipes with nuts,
So that I stay safe and avoid allergic reactions.

**Acceptance Criteria:**

**Given** I am in profile settings
**When** I tap "Allergies and restrictions" and add "Tree nuts" and "Peanuts"
**Then** my allergies are saved successfully
**And** recipe suggestions automatically exclude recipes containing allergens
**And** I receive a warning if I try to log a meal containing an allergen
**And** I can add or remove allergies at any time
**And** common allergens are listed for easy selection (nuts, dairy, eggs, gluten, soy, shellfish, etc.)

---

## Epic 9: Meal Planning with AI

### Story 9.1: Generate Weekly Meal Plan via Gemini AI

As a Sophie (famille),
I want the app to automatically create a full week of meal plans for me,
So that I save hours of planning time and always know what to cook.

**Acceptance Criteria:**

**Given** I am on the meal planning screen
**When** I tap "Generate weekly plan"
**Then** the app uses Gemini AI to generate 7 days of meals (lunch + dinner)
**And** the plan is personalized based on my nutritional profile (e.g., Family - Balanced)
**And** generation completes in less than 10 seconds with a progress indicator
**And** the plan is displayed in a clear calendar view
**And** I see the "moment magique" effect (full week planned instantly)

---

### Story 9.2: Meal Plan Respects Nutritional Constraints (Macros and Calories)

As a Thomas (sportif),
I want the generated meal plan to match my macro targets exactly,
So that I stay on track with my fitness goals effortlessly.

**Acceptance Criteria:**

**Given** I have macro targets configured (e.g., 180g protein, 2800 kcal/day)
**When** the AI generates my weekly meal plan
**Then** each day's meals total within ±5% of my calorie target
**And** each day's macros are within ±10% of my protein/carbs/fats targets
**And** I can see daily totals for calories and macros in the plan view
**And** the plan adapts if I change my profile or targets

---

### Story 9.3: Meal Plan Optimizes Use of Existing Inventory (Anti-Waste)

As a Marie (senior),
I want the meal plan to prioritize ingredients I already have,
So that I reduce waste and save money on groceries.

**Acceptance Criteria:**

**Given** I have products in my inventory
**When** the AI generates my weekly meal plan
**Then** at least 70% of ingredients come from my existing inventory
**And** products expiring soon are prioritized in earlier meals
**And** I see which inventory items are used in each recipe
**And** the plan minimizes the number of new ingredients I need to buy

---

### Story 9.4: Specify Meal Planning Constraints (Time, Batch Cooking, Preferences)

As a Thomas (sportif meal prep),
I want to set constraints like "batch cooking on Sundays" and "max 30 min prep time",
So that the plan fits my lifestyle and schedule.

**Acceptance Criteria:**

**Given** I am customizing meal plan generation
**When** I set constraints:
- Max preparation time (e.g., <30 min)
- Batch cooking preference (yes/no)
- Cuisine preferences (Italian, Asian, French, etc.)
- Exclude specific ingredients
**Then** the AI respects all constraints when generating the plan
**And** batch cooking recipes are grouped on specified days
**And** no meal exceeds the max preparation time
**And** excluded ingredients never appear in the plan

---

### Story 9.5: Manually Edit and Replace Meals in Generated Plan

As a Sophie (famille),
I want to swap meals I don't like in the generated plan,
So that I have full control while still benefiting from automation.

**Acceptance Criteria:**

**Given** I have a generated weekly meal plan
**When** I tap on a meal and select "Replace"
**Then** I see alternative recipes that fit the same nutritional profile
**And** I can select a replacement recipe
**And** the meal is replaced and calorie/macro totals update automatically
**And** I can also manually add custom meals or recipes
**And** changes are saved and synced across devices

---

### Story 9.6: Adjust Portion Sizes in Meal Plan

As a Lucas (étudiant colocation),
I want to adjust serving sizes for recipes in the plan,
So that I can cook for just myself or for multiple people.

**Acceptance Criteria:**

**Given** I am viewing a meal in my weekly plan
**When** I tap "Adjust portions" and change from 2 servings to 4 servings
**Then** ingredient quantities are recalculated automatically
**And** calorie and macro totals update based on new portion size
**And** I see the updated values immediately
**And** portion adjustments are saved to the plan

---

### Story 9.7: View Weekly Meal Plan in Calendar View

As a Sophie (famille),
I want to see my meal plan in a clear weekly calendar,
So that I know exactly what I'm cooking each day.

**Acceptance Criteria:**

**Given** I have a generated meal plan
**When** I view the meal planning screen
**Then** I see a calendar view showing 7 days
**And** each day displays lunch and dinner with recipe names
**And** I can tap a meal to see full recipe details
**And** I can navigate between weeks to see past or future plans
**And** the view is clear and easy to read on mobile screens

---

### Story 9.8: Regenerate Meal Plan with Different Preferences

As a Thomas (sportif),
I want to regenerate the plan if I don't like the first result,
So that I can get a variety of options without starting over.

**Acceptance Criteria:**

**Given** I have viewed a generated meal plan
**When** I tap "Regenerate plan" with optional new constraints
**Then** a new plan is generated in less than 10 seconds
**And** the new plan is different from the previous one
**And** I can keep regenerating until I find a plan I like
**And** previous plans are not saved unless I explicitly save them

---

## Epic 10: Smart Shopping List

### Story 10.1: Auto-Generate Shopping List from Meal Plan

As a Sophie (famille),
I want the app to create a shopping list automatically from my meal plan,
So that I know exactly what to buy without manual work.

**Acceptance Criteria:**

**Given** I have a weekly meal plan generated
**When** I tap "Generate shopping list"
**Then** the app analyzes the meal plan and compares it to my current inventory
**And** only missing ingredients are added to the shopping list
**And** ingredients are grouped by category (produce, dairy, meat, etc.)
**And** quantities are aggregated (e.g., 3 recipes need tomatoes → total: 6 tomatoes)
**And** the shopping list is displayed in a clear, printable format

---

### Story 10.2: Deduct Existing Inventory from Shopping List

As a Marie (senior),
I want the shopping list to exclude items I already have,
So that I don't buy duplicates and waste money.

**Acceptance Criteria:**

**Given** I have products in my inventory
**When** the shopping list is generated
**Then** ingredients present in my inventory are NOT added to the list
**And** if I have partial quantities (e.g., 2 tomatoes but need 5), only the difference (3 tomatoes) is added
**And** I can manually override and add/remove items
**And** the list updates in real-time as my inventory changes

---

### Story 10.3: Manually Add or Remove Items from Shopping List

As a Lucas (étudiant),
I want to add personal items to the shopping list,
So that I can use it as my complete grocery list, not just for meals.

**Acceptance Criteria:**

**Given** I have a generated shopping list
**When** I tap "Add item" and enter a product name
**Then** the item is added to the shopping list
**And** I can specify quantity and category
**And** I can remove items by swiping left
**And** manual additions are saved and synced across devices

---

### Story 10.4: Check Off Items as I Shop

As a Sophie (famille),
I want to check off items as I put them in my cart,
So that I can track what I've already picked up.

**Acceptance Criteria:**

**Given** I am shopping with the app open
**When** I tap the checkbox next to an item
**Then** the item is marked as "purchased" with a strikethrough
**And** purchased items move to the bottom of the list or a separate section
**And** I can uncheck items if I made a mistake
**And** the shopping list state persists if I close and reopen the app

---

### Story 10.5: Export Shopping List (Share, Print, or Copy)

As a Thomas (sportif),
I want to share my shopping list with my partner or print it,
So that someone else can shop for me or I can shop without my phone.

**Acceptance Criteria:**

**Given** I have a shopping list
**When** I tap "Export list"
**Then** I see options to:
- Share via message/email
- Copy to clipboard
- Print (PDF)
**And** the exported list is formatted clearly with categories and quantities
**And** the export includes only items not yet checked off (or all items, based on user choice)

---

## Epic 11: AI Nutrition Coach

### Story 11.1: Take Photo of Meal for Automatic Nutritional Logging (Gemini Vision)

As a Thomas (sportif),
I want to take a photo of my meal and have calories/macros logged automatically,
So that I can track nutrition without tedious manual entry.

**Acceptance Criteria:**

**Given** I have nutrition tracking enabled
**When** I take a photo of my meal and tap "Analyze with AI"
**Then** Gemini Vision processes the photo in less than 15 seconds
**And** the app identifies food items in the photo
**And** calories, protein, carbs, and fats are estimated automatically
**And** the meal is logged to my nutrition tracker
**And** I can review and edit the AI's estimates before confirming

---

### Story 11.2: Receive Real-Time Contextual Nutrition Advice

As a Sophie (famille),
I want personalized nutrition tips based on what I've eaten today,
So that I can make better food choices throughout the day.

**Acceptance Criteria:**

**Given** I have logged meals today
**When** I view my nutrition dashboard
**Then** I see contextual advice based on my current intake, such as:
- "You're low on protein today. Consider adding chicken or tofu to dinner."
- "Great job hitting your veggie target!"
- "You've consumed 80% of your calories. Save 500 kcal for dinner."
**And** advice is updated in real-time as I log meals
**And** advice is personalized to my nutritional profile and goals

---

### Story 11.3: Interact with Nutrition Chatbot for General Questions

As a Lucas (étudiant),
I want to ask the chatbot questions like "What's a good protein snack?" and get instant answers,
So that I can learn about nutrition and make informed choices.

**Acceptance Criteria:**

**Given** I am on the nutrition screen
**When** I tap "Ask a nutrition question" and type a query
**Then** the Gemini chatbot responds with relevant, helpful advice in less than 5 seconds
**And** responses are clear, concise, and easy to understand
**And** the chatbot can answer common questions about macros, calories, meal timing, etc.
**And** I see a disclaimer that the chatbot is not a replacement for professional medical advice
**And** conversations are saved for reference

---

### Story 11.4: View Photo Meal Recognition Confidence and Edit Results

As a Thomas (sportif),
I want to see how confident the AI is about its meal analysis,
So that I can correct mistakes and ensure accurate tracking.

**Acceptance Criteria:**

**Given** I have taken a photo of my meal for analysis
**When** Gemini Vision returns results
**Then** I see confidence scores for each detected food item (e.g., "Chicken breast - 90% confident")
**And** items with low confidence (<70%) are highlighted for review
**And** I can edit food names, portions, and nutritional values before logging
**And** I can delete incorrectly detected items
**And** I can manually add items the AI missed

---

### Story 11.5: Manage Gemini API Quota with Graceful Throttling

As a utilisateur,
I want the app to handle AI service limits gracefully,
So that I'm not frustrated by errors when the quota is reached.

**Acceptance Criteria:**

**Given** the app uses Gemini AI with a free tier quota (60 requests/minute)
**When** the quota is approached or exceeded
**Then** the app throttles requests client-side (max 1 request per 2 seconds per user)
**And** if quota is exceeded, I see a friendly message: "AI service is busy. Please try again in 1 minute."
**And** cached responses are used when possible to reduce API calls
**And** quota usage is monitored server-side with alerts for the dev team

---

### Story 11.6: Display Nutrition Coach Disclaimer Prominently

As a utilisateur,
I want clear information that the AI coach is not a medical professional,
So that I understand the limits of the advice and consult a doctor when needed.

**Acceptance Criteria:**

**Given** I am using the AI nutrition coach feature
**When** I interact with the chatbot or view AI-generated advice
**Then** I see a disclaimer:
"This AI nutrition coach provides general guidance only. It is not a medical device or substitute for professional advice. Consult a doctor or dietitian for personalized medical nutrition advice."
**And** the disclaimer is displayed prominently on first use
**And** the disclaimer is accessible in settings for future reference

---

## Epic 12: Price Comparison & Route Optimization

### Story 12.1: Compare Shopping List Prices Across 4+ Stores

As a Lucas (étudiant),
I want to see which store offers the best prices for my shopping list,
So that I can save money on groceries.

**Acceptance Criteria:**

**Given** I have a shopping list generated
**When** I tap "Compare prices"
**Then** the app displays prices for my list at minimum 4 stores (e.g., Carrefour, Lidl, Auchan, Intermarché)
**And** total cost is shown for each store
**And** I see potential savings in euros and percentage compared to the most expensive option
**And** price data is updated daily
**And** I see a disclaimer: "Prices are indicative. Verify in store."

---

### Story 12.2: View Price Data Source and Last Update Date

As a Marie (senior),
I want to know where prices come from and when they were last updated,
So that I can trust the information and make informed decisions.

**Acceptance Criteria:**

**Given** I am viewing price comparison results
**When** I look at the prices displayed
**Then** I see the data source for each store (e.g., "Crowdsourced by users" or "Official API")
**And** I see the last update date (e.g., "Last updated: 2 hours ago")
**And** I see a disclaimer: "Prices are indicative and may change. Always verify in store."
**And** outdated prices (>3 days) are flagged with a warning

---

### Story 12.3: View Stores on Interactive Map with Prices

As a Sophie (famille),
I want to see stores on a map with their prices,
So that I can choose based on location and cost together.

**Acceptance Criteria:**

**Given** I am comparing prices for my shopping list
**When** I tap "View on map"
**Then** I see an interactive Google Map with store locations marked
**And** each store marker shows the total price for my list
**And** I can tap a marker to see detailed price breakdown
**And** the map loads in less than 3 seconds
**And** I can switch between map view and list view easily

---

### Story 12.4: Calculate Optimized Multi-Store Route (Savings vs Distance)

As a Thomas (sportif),
I want the app to suggest the best combination of stores to visit,
So that I maximize savings while minimizing travel time.

**Acceptance Criteria:**

**Given** I am comparing prices across multiple stores
**When** I tap "Optimize route"
**Then** the app calculates the best multi-store route balancing savings and distance
**And** the route is displayed on the map with driving/walking directions
**And** I see estimated total savings and total travel distance/time
**And** I can adjust the optimization preference (e.g., "prioritize savings" vs "prioritize distance")
**And** the route is exportable to Google Maps or other navigation apps

---

### Story 12.5: Export Optimized Shopping List per Store

As a Sophie (famille),
I want to export separate shopping lists for each store I'll visit,
So that I can shop efficiently without confusion.

**Acceptance Criteria:**

**Given** I have an optimized multi-store route
**When** I tap "Export lists"
**Then** I receive separate shopping lists for each store in the route
**And** each list includes only items to buy at that specific store
**And** lists are formatted clearly and can be shared or printed
**And** I can check off items as I shop at each store

---

### Story 12.6: View Legal Disclaimer About Price Accuracy

As a utilisateur,
I want to understand that prices are estimates and not guaranteed,
So that I'm not misled and can verify before purchasing.

**Acceptance Criteria:**

**Given** I am using the price comparison feature
**When** I view price data
**Then** I see a prominent disclaimer:
"Prices displayed are indicative and non-contractual. They may change without notice. Always verify prices in store before purchasing. FrigoFute is not responsible for price discrepancies."
**And** the disclaimer is displayed on the price comparison screen
**And** I acknowledge the disclaimer on first use
**And** the disclaimer is accessible in settings for future reference

---

### Story 12.7: Handle Missing Price Data Gracefully

As a Marie (senior),
I want clear information when prices are unavailable for a product,
So that I'm not confused or frustrated.

**Acceptance Criteria:**

**Given** I am comparing prices and some products have missing data
**When** the price comparison results are displayed
**Then** products with missing prices show "Price not available" or "N/A"
**And** I see a note: "This product's price is not in our database. Check in store."
**And** stores with missing data for many products show a warning
**And** I can still proceed with available price data

---

### Story 12.8: Crowdsource Price Data from Users (Phase 1 Strategy)

As a Lucas (étudiant),
I want to contribute prices I see in stores to help the community,
So that everyone benefits from accurate, up-to-date pricing.

**Acceptance Criteria:**

**Given** I am shopping and see a product price
**When** I tap "Report price" and enter the store, product, and price
**Then** my price report is submitted to the database
**And** other users can benefit from my contribution
**And** I receive a thank-you message or gamification reward (points/badge)
**And** price reports are moderated to ensure quality
**And** I can opt-in or opt-out of crowdsourcing at any time

---

## Epic 13: Gamification & Engagement

### Story 13.1: Unlock Achievements for Anti-Waste Actions

As a Sophie (famille),
I want to earn badges when I reduce food waste,
So that I feel proud and motivated to continue.

**Acceptance Criteria:**

**Given** I use the app to avoid food waste
**When** I achieve milestones like "Zero waste for 7 days" or "Saved 10 kg of food"
**Then** I unlock an achievement badge
**And** I receive a congratulatory notification
**And** the badge is displayed in my profile
**And** I can view all my unlocked achievements in an "Achievements" screen
**And** achievements are synced across devices

---

### Story 13.2: Track Activity Streaks (Days Without Waste, Days Cooked at Home)

As a Thomas (sportif),
I want to see my streak of consecutive days without waste or cooking at home,
So that I stay motivated to maintain good habits.

**Acceptance Criteria:**

**Given** I use the app daily
**When** I avoid waste or cook at home for consecutive days
**Then** my streak counter increases (e.g., "5-day no-waste streak!")
**And** I see my current streak prominently on the dashboard
**And** I receive encouragement notifications to maintain my streak
**And** if I break a streak, I see my best streak record
**And** streaks are synced across devices

---

### Story 13.3: Join Friends Leaderboard (Opt-In)

As a Lucas (étudiant),
I want to compete with my friends on anti-waste and savings,
So that we motivate each other and have fun.

**Acceptance Criteria:**

**Given** I opt-in to the leaderboard feature
**When** I invite friends or they invite me
**Then** I see a leaderboard ranking friends by points (based on waste avoided, savings, streaks, etc.)
**And** the leaderboard updates weekly
**And** I can view friends' achievements and stats (with their consent)
**And** I can leave the leaderboard at any time
**And** leaderboard is private and only visible to opted-in friends

---

### Story 13.4: Complete Weekly or Monthly Challenges

As a Marie (senior),
I want to participate in challenges like "Use all expiring products this week",
So that I have clear goals and stay engaged.

**Acceptance Criteria:**

**Given** I am an active user
**When** a new weekly or monthly challenge is available
**Then** I see the challenge description and reward (e.g., "Save 5 kg this week, earn a badge")
**And** I can accept or skip the challenge
**And** my progress is tracked automatically based on my app usage
**And** I receive notifications when I complete a challenge
**And** I earn rewards (badges, points, or premium trial) upon completion

---

### Story 13.5: Share Achievements on Social Media

As a Sophie (famille),
I want to share my anti-waste achievements on Facebook or Instagram,
So that I can inspire friends and family.

**Acceptance Criteria:**

**Given** I have unlocked an achievement or completed a challenge
**When** I tap "Share achievement"
**Then** I see options to share on social media (Facebook, Instagram, Twitter)
**And** a pre-formatted post is generated with my achievement and a link to the app
**And** the post includes visuals (badge image, stats) that are shareable
**And** I can edit the message before posting
**And** sharing is optional and respects my privacy preferences

---

### Story 13.6: Earn Points for Actions and Redeem Rewards (Future)

As a Lucas (étudiant),
I want to earn points for various actions and unlock rewards,
So that I feel recognized for my efforts.

**Acceptance Criteria:**

**Given** I perform actions like scanning products, avoiding waste, or completing challenges
**When** I accumulate points
**Then** I can view my total points on my profile
**And** I can see what actions earn points (e.g., "Scan product: +10 points")
**And** future versions may allow redeeming points for rewards (premium trial, partner discounts)
**And** points are synced across devices
**And** gamification is fun but not intrusive

---

## Epic 14: Family Sharing & Collaboration

### Story 14.1: Share Inventory with Family Members

As a Sophie (famille),
I want to share my inventory with my partner,
So that we both know what's in the fridge and can shop together.

**Acceptance Criteria:**

**Given** I have an inventory
**When** I invite my partner via email or link
**Then** my partner can view and edit the shared inventory
**And** changes made by either person sync in real-time
**And** both users see who made each change (e.g., "Added by Sophie")
**And** I can revoke access at any time
**And** we can both receive expiration notifications for shared products

---

### Story 14.2: Share Recipes with Other Users

As a Thomas (sportif),
I want to share my favorite recipes with friends,
So that they can try them too.

**Acceptance Criteria:**

**Given** I have a favorite recipe
**When** I tap "Share recipe"
**Then** I can share via link, email, or social media
**And** the recipient can view the recipe in the app (if they have it) or on the web
**And** the recipe includes ingredients, instructions, and nutritional info
**And** I can see how many people I've shared recipes with

---

### Story 14.3: Share Meal Plans with Family Members

As a Sophie (famille),
I want to share my weekly meal plan with my family,
So that everyone knows what we're eating and can help cook.

**Acceptance Criteria:**

**Given** I have a weekly meal plan
**When** I tap "Share plan"
**Then** I can share via link, email, or app invite
**And** family members can view the plan in read-only or edit mode (based on permissions)
**And** changes to the plan sync in real-time for all users
**And** shared plans are accessible on all devices

---

### Story 14.4: Export Reports as PDF (Inventory, Meal Plan, Metrics)

As a Marie (senior),
I want to print or save my inventory and meal plan as a PDF,
So that I have a physical copy to refer to while cooking or shopping.

**Acceptance Criteria:**

**Given** I have inventory, meal plans, or metrics
**When** I tap "Export as PDF"
**Then** a PDF is generated with a clear, formatted layout
**And** I can choose what to include (inventory, meal plan, dashboard metrics, etc.)
**And** the PDF is downloadable and shareable via email or print
**And** the PDF includes my name, date, and FrigoFute branding

---

### Story 14.5: Sync Shared Shopping List in Real-Time

As a Lucas (colocation),
I want to share a shopping list with my roommates that updates in real-time,
So that we coordinate shopping without duplicates.

**Acceptance Criteria:**

**Given** I create a shared shopping list
**When** I invite my roommates via email or link
**Then** all users can view and edit the list in real-time
**And** when someone checks off an item, it's immediately checked for everyone
**And** we can add notes to items (e.g., "Get the organic version")
**And** I can revoke sharing access at any time
**And** the list syncs instantly across all devices

---

## Epic 15: Premium Features & Freemium Management

### Story 15.1: View Clear Comparison Table of Free vs Premium Features

As a utilisateur,
I want to see exactly what I get with the free version versus premium,
So that I can make an informed decision about upgrading.

**Acceptance Criteria:**

**Given** I am using the free version of the app
**When** I navigate to "Upgrade to Premium" or view premium feature screens
**Then** I see a clear comparison table showing:
- Free: 6 modules (Inventory, Scan, Notifications, Recipes, Dashboard, Profile)
- Premium: All 14 modules (+ Meal Planning AI, Nutrition Coach AI, Price Comparison, Gamification, Family Sharing, etc.)
**And** each feature is described concisely
**And** the table is visually clear with checkmarks for included features
**And** I see the price: 4.99€/month with 7-day free trial
**And** there are no dark patterns or misleading information

---

### Story 15.2: Subscribe to Premium with 7-Day Free Trial

As a Sophie (famille),
I want to try premium features for 7 days free,
So that I can decide if they're worth the monthly cost.

**Acceptance Criteria:**

**Given** I am a free user
**When** I tap "Start 7-day free trial"
**Then** I can enter payment information (credit card or app store billing)
**And** I am NOT charged during the 7-day trial period
**And** I have full access to all 14 premium modules immediately
**And** I receive a confirmation email with trial start and end dates
**And** I can cancel anytime during the trial without being charged
**And** if I don't cancel, I'm automatically charged 4.99€/month after 7 days

---

### Story 15.3: Cancel Premium Subscription in 3 Clicks

As a Thomas (sportif),
I want to cancel my subscription easily if I no longer need it,
So that I'm not locked in or frustrated.

**Acceptance Criteria:**

**Given** I am a premium subscriber
**When** I navigate to "Manage subscription" and tap "Cancel"
**Then** I see a confirmation dialog explaining what I'll lose
**And** I can confirm cancellation in maximum 3 clicks
**And** my subscription is canceled immediately (no hoops to jump through)
**And** I retain premium access until the end of my current billing period
**And** I receive a confirmation email
**And** I can resubscribe at any time

---

### Story 15.4: View Transparent Pricing with No Hidden Fees

As a Marie (senior),
I want to see the exact price including all taxes,
So that I know what I'll pay with no surprises.

**Acceptance Criteria:**

**Given** I am viewing premium subscription options
**When** I see the price displayed
**Then** the price is shown as 4.99€/month TTC (taxes included)
**And** I see a note: "Renews automatically monthly. Cancel anytime."
**And** there are no hidden fees or additional charges
**And** the price is displayed before I enter payment information
**And** I can see billing history in account settings

---

### Story 15.5: Downgrade from Premium to Free Seamlessly

As a Lucas (étudiant),
I want to downgrade to free if my budget is tight,
So that I can continue using the app with basic features.

**Acceptance Criteria:**

**Given** I am a premium subscriber
**When** I cancel my subscription
**Then** I retain premium access until the end of my billing period
**And** after the period ends, I am automatically downgraded to free
**And** I lose access to premium modules but keep all my data (inventory, nutrition logs, etc.)
**And** I can resubscribe to premium at any time to regain access
**And** premium-only data (e.g., meal plans) is archived and restored if I resubscribe

---

### Story 15.6: Feature Guards Display Premium Teasers for Free Users

As a utilisateur gratuit,
I want to see what premium features offer,
So that I understand the value and can decide if I want to upgrade.

**Acceptance Criteria:**

**Given** I am a free user
**When** I tap on a premium-only feature (e.g., "AI Meal Planning")
**Then** I see a teaser screen explaining the feature with visuals
**And** I see a clear "Upgrade to Premium" button
**And** I can try the feature if I start a free trial
**And** the teaser is not intrusive or annoying (no forced full-screen popups)
**And** I can easily dismiss the teaser and continue using free features

---

## Epic 16: Compliance & Legal

### Story 16.1: Display Nutrition Disclaimer in Relevant Screens

As a utilisateur,
I want to see clear legal disclaimers about nutrition advice,
So that I understand the app is informational, not medical.

**Acceptance Criteria:**

**Given** I am using nutrition-related features
**When** I view the nutrition dashboard, coach, or meal planning screens
**Then** I see a disclaimer:
"Nutritional information is indicative and not certified by a healthcare professional. This app is not a medical device. Consult a doctor or dietitian for personalized medical advice."
**And** the disclaimer is prominently displayed and acknowledged on first use
**And** the disclaimer is accessible in settings and legal section
**And** the disclaimer complies with EU regulations (1924/2006)

---

### Story 16.2: Display Price Comparison Disclaimer

As a utilisateur,
I want to see disclaimers about price accuracy,
So that I verify prices in store and don't rely solely on the app.

**Acceptance Criteria:**

**Given** I am using the price comparison feature
**When** I view price data
**Then** I see a disclaimer:
"Prices are indicative and non-contractual. They may change without notice. Always verify prices in store. FrigoFute is not responsible for discrepancies."
**And** the disclaimer is displayed on the price comparison screen
**And** I acknowledge it on first use
**And** the disclaimer is accessible in settings

---

### Story 16.3: Display Expiration Alert Disclaimer

As a utilisateur,
I want to understand that I'm responsible for verifying food safety,
So that I don't rely solely on app alerts.

**Acceptance Criteria:**

**Given** I am using expiration alerts
**When** I receive notifications or view expiration warnings
**Then** I see a disclaimer:
"Expiration alerts are based on dates you entered and are indicative only. FrigoFute does not guarantee product freshness. Always verify products visually and by smell before consuming. You are responsible for food safety."
**And** the disclaimer is displayed on first alert or settings
**And** I acknowledge it on first use
**And** the disclaimer complies with liability requirements

---

### Story 16.4: Manage Granular Consent Settings (Health Data, Analytics, Marketing)

As a Marie (senior),
I want to control exactly what data the app collects,
So that I can protect my privacy according to my preferences.

**Acceptance Criteria:**

**Given** I am in privacy settings
**When** I view "Manage consents"
**Then** I see toggles for:
- Health data (nutrition tracking) - with RGPD Article 9 explanation
- Analytics cookies (app usage tracking)
- Marketing notifications
**And** I can enable or disable each consent independently
**And** disabling health data triggers deletion of nutrition data within 30 days
**And** my consent preferences are saved and respected
**And** I can update consents at any time

---

### Story 16.5: View Complete Privacy Policy (RGPD-Compliant)

As a utilisateur,
I want to read the full privacy policy to understand data handling,
So that I can make informed decisions about my privacy.

**Acceptance Criteria:**

**Given** I want to know how my data is used
**When** I navigate to "Privacy Policy" in settings or legal section
**Then** I see a complete, RGPD-compliant privacy policy including:
- Data collected (inventory, nutrition, photos, usage analytics)
- Purpose of data collection
- Legal basis (consent, contract, legitimate interest)
- Data retention periods
- Third parties (Firebase, Google Cloud, Gemini)
- User rights (access, rectification, deletion, portability, opposition)
- Contact for data protection officer (DPO) or data controller
**And** the policy is written in clear, understandable language (not legalese)
**And** the policy is available in French

---

### Story 16.6: View Terms of Service and Legal Notices

As a utilisateur,
I want to access terms of service and legal information,
So that I understand my rights and obligations.

**Acceptance Criteria:**

**Given** I want to review legal information
**When** I navigate to "Legal" or "Terms of Service" in settings
**Then** I see:
- Terms of Service (CGU)
- Terms of Sale (CGV) for premium subscription
- Legal notices (publisher, hosting, contact)
**And** all legal documents are accessible without requiring login
**And** documents are available in French
**And** I can download or print the documents

---

### Story 16.7: Export All Personal Data for RGPD Portability

As a Thomas (sportif),
I want to download all my data in a machine-readable format,
So that I can transfer it to another service if I choose.

**Acceptance Criteria:**

**Given** I am logged in
**When** I request "Export my data" in privacy settings
**Then** the app generates a complete export including:
- Inventory data
- Nutrition tracking logs
- Meal plans
- Settings and preferences
**And** the export is in JSON format (machine-readable)
**And** I receive a download link via email within 24 hours
**And** the export complies with RGPD portability requirements (Article 20)

---

### Story 16.8: Request and Confirm Account Deletion (Right to be Forgotten)

As a Lucas (étudiant),
I want to permanently delete my account and all data,
So that I can exercise my RGPD right to be forgotten.

**Acceptance Criteria:**

**Given** I no longer want to use the app
**When** I navigate to "Delete account" in settings
**Then** I see a warning about data loss and a confirmation dialog
**And** I must confirm my decision twice to prevent accidental deletion
**And** I receive an email confirming deletion is scheduled within 30 days
**And** I can cancel the deletion within 30 days if I change my mind
**And** after 30 days, all personal data is permanently deleted from servers and backups
**And** I receive a final confirmation email after deletion

---

# END OF DETAILED STORIES
