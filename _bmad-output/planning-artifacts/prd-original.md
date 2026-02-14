---
stepsCompleted: ["step-01-init", "step-02-discovery", "step-03-success", "step-04-journeys", "step-05-domain", "step-06-innovation", "step-07-project-type", "step-08-scoping", "step-09-functional", "step-10-nonfunctional"]
inputDocuments:
  - "_bmad-output/planning-artifacts/research/technical-FrigoFuteV2-Complete-Stack-research-2026-02-13.md"
  - "_bmad-output/brainstorming/brainstorming-session-2026-02-12.md"
  - "_bmad-output/market-research/analyse-marche-frigofute-2026.md"
workflowType: 'prd'
briefCount: 0
researchCount: 1
brainstormingCount: 1
projectDocsCount: 0
classification:
  projectType: mobile_app
  domain: general
  complexity: medium-high
  projectContext: greenfield
---

# Product Requirements Document - FrigoFuteV2

**Author:** Marcel
**Date:** 2026-02-13

## Success Criteria

### User Success

**Valeur Délivrée - Triple Impact :**

FrigoFute V2 réussit quand les utilisateurs expérimentent concrètement le triple bénéfice **santé + économie + écologie** :

**Impact Anti-Gaspillage :**
- ✅ **5-8 kg de nourriture évités** par utilisateur/mois (vs moyenne française 29 kg/an gaspillés)
- ✅ Réduction de **70% du gaspillage** alimentaire domestique après 3 mois d'utilisation
- ✅ **Zéro produit périmé oublié** - alertes péremption actives et efficaces

**Impact Économique :**
- ✅ **50-80€ économisés/mois** sur le budget courses grâce au comparateur prix multi-enseignes
- ✅ Utilisateurs perçoivent un **ROI clair** : 4.99€ premium → 50-80€ économies réelles
- ✅ **Optimisation parcours courses** réduit temps trajet de 20-30% (algorithme multi-magasins)

**Impact Santé & Nutrition :**
- ✅ **3-5 recettes saines cuisinées/semaine** via suggestions personnalisées
- ✅ Utilisateurs atteignent leurs **objectifs nutritionnels** (macros, calories) grâce au suivi intelligent
- ✅ **Profils nutritionnels personnalisés** (12 profils) adaptés à chaque besoin (sportif, végan, diabétique, etc.)

**Gain Temps & Charge Mentale :**
- ✅ **2-3 heures gagnées/semaine** : planning repas auto-généré + liste courses intelligente
- ✅ **Charge mentale réduite** pour familles : fini "qu'est-ce qu'on mange ce soir ?"
- ✅ **Décisions simplifiées** : suggestions contextuelles basées sur inventaire réel

**Le "Moment Magique" (Aha Moment) :**

Les utilisateurs réalisent que FrigoFute change leur vie quand :
1. **Premier scan ticket** → 100+ produits ajoutés automatiquement à l'inventaire en <2s
2. **Première semaine complète** → Dashboard montre gaspillage évité + économies réalisées
3. **Premier planning généré** → Repas semaine organisés automatiquement avec ce qu'ils ont déjà

**États Émotionnels de Succès :**
- **Familles :** Soulagement (organisation), Fierté (éco-responsabilité), Contrôle (budget maîtrisé)
- **Sportifs :** Accomplissement (objectifs atteints), Optimisation (performance nutritionnelle)
- **Étudiants/Budget serré :** Sécurité (économies), Simplicité (cuisine accessible)

### Business Success

**Objectifs Acquisition (Année 1) :**

- **Mois 3 (MVP Tier 2 lancé) :** 10,000 utilisateurs gratuits
- **Mois 6 (MVP Tier 3 + Freemium) :** 50,000 utilisateurs gratuits
- **Mois 12 (App complète 14 modules) :** 150,000 utilisateurs gratuits

**Métriques d'Engagement :**

- **DAU/MAU (Daily/Monthly Active Users) :** > 30% (benchmark apps santé/lifestyle)
- **Fréquence utilisation :** 4-5 fois/semaine minimum
- **Produits scannés :** > 10 produits/utilisateur/semaine (preuve d'usage réel)
- **Rétention :**
  - D7 (7 jours) : > 40%
  - D30 (30 jours) : > 25%
  - M6 (6 mois) : > 15%

**Objectifs Monétisation (Freemium) :**

- **Conversion Freemium → Premium :**
  - Mois 6 : > 3% (1,500 utilisateurs premium sur 50K)
  - Mois 12 : > 5% (7,500 utilisateurs premium sur 150K)
- **Churn Premium :** < 5%/mois
- **LTV (Lifetime Value) Premium :** > 180€ (= 3 ans d'abonnement à 4.99€/mois)
- **LTV/CAC ratio :** > 3:1 (santé économique)

**Revenus :**

- **Année 1 :** ~90,000€ (1,500 premium × 59.88€ ARPU/an)
- **Année 2 :** ~450,000€ (7,500 premium × 59.88€)
- **Année 3 :** ~1,440,000€ (24,000 premium × 59.88€)

**Positionnement Marché :**

- ✅ **Top 3 apps Food Tech** France en téléchargements catégorie "Alimentation" (App Store + Play Store)
- ✅ **Notoriété spontanée** > 15% cible prioritaire (familles + sportifs) fin Année 1
- ✅ **NPS (Net Promoter Score)** > 50 (utilisateurs promoteurs actifs)

**Vision Long-Terme (3-5 ans) :**

- **2-3M utilisateurs actifs mensuels** d'ici 2029-2030
- **Leader incontesté** marché français "alimentation domestique intelligente"
- **Expansion géographique :** Belgique, Suisse, Canada francophone

### Technical Success

**Qualité Code & Architecture :**

- ✅ **Code coverage ≥ 75%** (pyramide tests : 70% Unit / 20% Widget / 10% E2E)
- ✅ **Architecture Feature-First + Clean Architecture** respectée sur les 14 modules
- ✅ **Modules indépendants** : isolation stricte, feature flags fonctionnels
- ✅ **SOLID principles** appliqués, dette technique minimale

**Performance & Fiabilité :**

- ✅ **Performance Scan OCR < 2 secondes** (dual-engine Google Vision + ML Kit)
- ✅ **Précision OCR tickets français ≥ 85%** (reconnaissance produits)
- ✅ **App launch time < 3 secondes** (cold start)
- ✅ **Offline-first robuste** : app 100% fonctionnelle sans connexion
- ✅ **Uptime ≥ 99.5%** (backend Firebase + APIs externes)
- ✅ **Zero crash tolerance** : crash-free rate > 99.9%

**Sécurité & Conformité :**

- ✅ **RGPD by design** : encryption at-rest, consent granulaire, droit à l'oubli fonctionnel
- ✅ **Données sensibles chiffrées** (profils nutrition, historique achats)
- ✅ **Authentification sécurisée** : Firebase Auth + OAuth2
- ✅ **Penetration testing** réalisé avant production

**Scalabilité & Coûts :**

- ✅ **Coûts infrastructure < 500€/mois** pour 10,000 MAU
  - Firebase : ~65€/mois
  - Google Vision OCR : ~75€/mois
  - Gemini AI : ~10€/mois (ou gratuit free tier)
- ✅ **Architecture scalable** : pagination, lazy loading, virtual scrolling
- ✅ **Gestion gros volumes** : >100,000 produits inventaire testés

**DevOps & Livraison :**

- ✅ **CI/CD Pipeline** : GitHub Actions + Fastlane avec quality gates
- ✅ **Déploiement automatisé** : staged rollouts (5% → 25% → 100%)
- ✅ **Monitoring temps réel** : Firebase Crashlytics → Sentry (future)
- ✅ **Hotfix capability** : correction bugs critiques en <24h

### Measurable Outcomes

**Semaine 6 (MVP Tier 1 - Anti-Gaspi Basique) :**
- 500-1,000 early adopters alpha testing
- Inventaire CRUD fonctionnel : 100% success rate ajout/édition/suppression
- Alertes péremption : >90% delivered on-time
- Dashboard stats : temps chargement < 1s

**Semaine 8 (MVP Tier 2 - Scan Magique) :**
- 3,000-5,000 utilisateurs beta
- Scan tickets : >80% précision OCR tickets français
- Scan code-barres : >95% reconnaissance produits packagés
- Feedback utilisateurs : "scan magique" mentionné spontanément

**Semaine 11 (MVP Tier 3 - Nutrition-Aware) :**
- 10,000+ utilisateurs
- Suivi alimentaire quotidien : >20% utilisateurs actifs l'utilisent
- Calcul macros précis : <5% marge erreur vs bases OpenFoodFacts
- **DECISION POINT FREEMIUM VALIDÉ** : conversion test >2% sur échantillon

**Semaine 24 (App Complète - 14 Modules) :**
- 50,000-100,000 utilisateurs
- Tous les modules production-ready
- Comparateur prix : 4+ sources prix intégrées
- Coach IA nutrition : >15% utilisateurs premium l'utilisent régulièrement
- Planning repas : >30% génération hebdomadaire automatique
- Store reviews : >4.5/5 stars moyenne (iOS + Android)

**Année 1 (Post-Launch Production) :**
- 150,000 utilisateurs gratuits, 3,000-5,000 premium
- Revenus : 90K€
- NPS > 50
- Top 10 apps catégorie Food France

## Product Scope

### MVP - Minimum Viable Product

Le MVP FrigoFute V2 est structuré en **3 tiers progressifs**, chacun apportant une couche de valeur incrémentale. L'approche permet de valider product-market fit à chaque étape.

#### MVP Tier 1: Anti-Gaspi Basique (Semaines 4-6)

**Modules inclus :**
- **Module 1:** Inventaire (CRUD complet, 12 catégories, 6 emplacements, statuts)
- **Module 3:** Notifications & Alertes (expiration, rappels)
- **Module 4:** Dashboard & Statistiques (widgets temps réel, métriques gaspillage)

**Valeur délivrée :** Gestion inventaire frigo + alertes péremption = anti-gaspillage fondamental

**Critère de succès Tier 1 :** 500-1,000 early adopters, inventaire fonctionnel, feedback positif

**Milestone :** ✅ MVP Tier 1 Shippable (Alpha testing)

---

#### MVP Tier 2: Scan Magique (Semaines 7-8)

**Modules ajoutés :**
- **Module 2:** Scan OCR & Code-barres (Google Vision + ML Kit dual-engine, parsing tickets FR)

**Valeur ajoutée :** Scan automatisé tickets + code-barres = ajout 100+ produits en 2s (vs saisie manuelle pénible)

**Critère de succès Tier 2 :** 3,000-5,000 utilisateurs beta, >80% précision OCR, "wow effect" scan

**Milestone :** ✅ MVP Tier 2 Shippable (Beta testing élargie)

---

#### MVP Tier 3: Nutrition-Aware (Semaines 9-11)

**Modules ajoutés :**
- **Module 5:** Authentification & Profil (Firebase Auth, profils utilisateur)
- **Module 6:** Recettes & Suggestions (base recettes, matching inventaire)
- **Module 7:** Suivi Alimentaire Quotidien (calories/macros, journal repas)
- **Module 8:** Profils Nutritionnels (12 profils prédéfinis, calcul BMR/TDEE)

**Valeur ajoutée :** Dimension nutrition personnalisée + suggestions recettes intelligentes

**Critère de succès Tier 3 :** 10,000+ utilisateurs, suivi nutrition actif >20%, décision freemium validée

**Milestone :** ✅ MVP Tier 3 Shippable + **DECISION POINT : Lancer Freemium ?**

---

### Growth Features (Post-MVP)

Après validation MVP Tier 3, déploiement des **modules premium** pour activation freemium.

#### Phase 5: Planning & Intelligence (Semaines 12-15)

**Modules :**
- **Module 9:** Planning Repas Hebdomadaire (génération IA, batch cooking)
- **Module 12:** Liste de Courses Intelligente (génération auto, déduction inventaire)

**Valeur :** Automatisation planning + liste courses = gain 2-3h/semaine

---

#### Phase 6: Premium Features (Semaines 16-20)

**Modules :**
- **Module 10:** Coach IA Nutrition (Gemini Vision, analyse photo, chatbot)
- **Module 11:** Gamification (achievements, streaks, badges)
- **Module 14:** Comparateur Prix & Optimisation Parcours (carte interactive, 4 sources, algorithme multi-magasins)

**Valeur :** IA avancée + économies courses massives = différenciation maximale

---

#### Phase 7: Polish & Ecosystem (Semaines 21-22)

**Modules :**
- **Module 13:** Export, Partage & Famille (PDF, multi-utilisateurs)

**Valeur :** Collaboration familiale + partage données

**Milestone :** ✅ **App Complète 14 Modules Prête Production**

---

### Vision (Future - Post V2 Launch)

**Expansion Fonctionnelle (Année 2-3) :**

- 🏠 **Intégration Domotique**
  - Connexion frigos connectés (Samsung Family Hub, LG InstaView)
  - Synchronisation automatique inventaire via caméras internes frigo
  - Balances connectées (Withings) pour tracking portions

- 🤖 **Assistant Vocal Cuisine**
  - Guide recettes pas-à-pas mains-libres
  - Intégration Alexa, Google Home
  - Ajout produits par commande vocale

- 🌍 **Extension Géographique**
  - Belgique (Q1 Année 2)
  - Suisse romande (Q2 Année 2)
  - Canada francophone (Q3 Année 2)
  - Extension Europe (Année 3) : Espagne, Italie, Allemagne

- 👨‍👩‍👧‍👦 **Famille & Partage Avancé**
  - Profils enfants avec suivi nutrition adapté
  - Suggestions lunch box école automatiques
  - Partage liste courses synchronisée temps réel (multi-devices)
  - Mode "colocation" : inventaire partagé + dépenses réparties

- 🏪 **Marketplace Ingrédients**
  - Commande directe producteurs locaux
  - Intégration circuits courts (AMAP, fermes)
  - Partenariats enseignes (Carrefour, Leclerc) : click & collect optimisé

- 📈 **Insights Santé Long-Terme**
  - Analyse tendances nutrition personnelle sur années
  - Recommandations préventives santé (carences, déséquilibres)
  - Export données médecin/nutritionniste (format standardisé)

- 🎮 **Gamification Avancée**
  - Défis communautaires anti-gaspi
  - Leaderboard social opt-in
  - NFT badges achievements (Web3 bonus)
  - Challenges inter-familles, inter-villes

**Vision Stratégique 2030 :**

"Frigofute = **Spotify de l'alimentation domestique**"
- 2-3M utilisateurs actifs mensuels France
- Leader incontesté marché français apps alimentation intelligente
- Expansion 5+ pays francophones réussie
- Potentiel acquisition par géant tech (Google, Meta) ou agro-alimentaire (Danone, Nestlé)

**Impact Sociétal Ambitieux :**

**Mission :** "Diviser par 2 le gaspillage alimentaire des foyers français d'ici 2030"

**Si 2M utilisateurs :**
- 🗑️ **144,000 tonnes/an** gaspillage évité (2M × 6kg/mois)
- 💰 **1.44 milliards €/an** économies foyers (2M × 60€/mois × 12)
- 🌱 **300,000 tonnes CO2eq/an** évitées (production + transport)

**Frigofute devient acteur majeur transition alimentaire durable France.** 🌱


## User Journeys

### Parcours 1 : Sophie, la Maman Organisée - "La Libération de la Charge Mentale"

**Opening Scene - Le Mercredi Soir de Trop**

Sophie, 38 ans, rentre du travail à 18h30. Les enfants (Emma 8 ans, Lucas 5 ans) réclament le dîner. Elle ouvre le frigo : "Merde, le poulet est périmé depuis hier. Les yaourts aussi. Et c'est quoi ce truc au fond ?"

Elle jette 3 produits périmés (encore 15€ à la poubelle cette semaine), improvise des pâtes au beurre pour la 3e fois cette semaine. Les enfants râlent. Son mari demande "On mange quoi demain ?". Sophie explose : "J'EN SAIS RIEN ! Je peux pas penser à TOUT !"

**État émotionnel :** Épuisement, culpabilité (gaspillage + nutrition enfants), sentiment d'être submergée.

**Déclencheur :** Le lendemain, une collègue lui parle de FrigoFute : "Ça a changé ma vie, vraiment. Plus de stress courses."

---

**Rising Action - Première Semaine : La Découverte**

**Jour 1 - Samedi matin, courses Carrefour**

Sophie télécharge FrigoFute (gratuit). Onboarding 2 minutes : elle choisit profil "Famille avec enfants", objectif "Réduire gaspillage + Manger équilibré".

Retour des courses, elle sort son ticket de caisse (127 articles, 186€). Ouvre l'app, clique "Scanner ticket". **Moment magique #1 :** En 3 secondes, 127 produits s'affichent dans son inventaire, classés automatiquement (Frais → Réfrigérateur, Pâtes → Placard, etc.).

Elle murmure : "Putain... c'est de la magie."

**Émotions :** Étonnement, curiosité, premier soulagement.

**Jour 3 - Lundi soir**

Notification : "⚠️ Poulet (frigo) expire dans 2 jours".

Sophie clique → L'app suggère 3 recettes avec le poulet + légumes qu'elle a déjà. Elle choisit "Poulet rôti aux carottes" (20 min). Fini l'improvisation.

**Émotions :** Contrôle retrouvé, confiance.

**Jour 5 - Mercredi midi**

Deuxième notification : "🍓 Fraises (frigo) à consommer aujourd'hui". Sophie les donne aux enfants au goûter. **Zéro gaspillage cette semaine.**

Dashboard : "Cette semaine : 8 kg gaspillage évités, 24€ économisés 🎉"

**Émotions :** Fierté, accomplissement.

---

**Climax - Semaine 3 : Le Déclic Freemium**

**Dimanche soir, planification semaine**

Sophie découvre la fonction Premium (essai 7 jours gratuit) : **Planning Repas Hebdomadaire IA**.

Elle clique "Générer planning semaine". L'app analyse son inventaire actuel + profil famille équilibrée → Génère 7 dîners :
- Utilise 80% des produits déjà en stock (anti-gaspi)
- Équilibrés nutritionnellement (légumes, protéines, féculents)
- Adaptés enfants (pas trop épicé)
- Liste courses complémentaire auto-générée (seulement 12 articles manquants)

**Moment magique #2 :** Sophie réalise : "Je viens de gagner 2 heures. Toute la semaine est organisée. C'est EXACTEMENT ce qu'il me fallait."

Elle clique "Comparer prix courses" → L'app montre que les 12 articles coûtent :
- Carrefour (à côté) : 47€
- Lidl (5 min détour) : 38€
- **Économie potentielle : 9€** pour ce trajet

**Décision :** Sophie s'abonne Premium 4.99€/mois. ROI immédiat : elle économise 50-70€/mois avec le comparateur prix.

**Émotions :** Libération, clarté mentale, sensation "j'ai repris le contrôle".

---

**Resolution - Mois 3 : La Nouvelle Réalité**

**Routine installée :**

- **Samedi :** Courses + scan ticket (2 min)
- **Dimanche soir :** Génération planning semaine (1 clic)
- **Quotidien :** Suit le planning, reçoit alertes péremption, zéro improvisation

**Résultats mesurables :**
- ✅ **Gaspillage divisé par 4** (de 8 kg/mois → 2 kg/mois)
- ✅ **60€ économisés/mois** sur courses (comparateur prix)
- ✅ **2h30 gagnées/semaine** (planning auto + liste courses)
- ✅ **Enfants mangent plus équilibré** (dashboard nutrition montre 85% jours équilibrés vs 60% avant)

**État émotionnel final :** Sérénité, fierté, recommande l'app à 5 amies.

**Quote de Sophie :** "Avant FrigoFute, je courais après le temps. Maintenant, j'ai l'impression d'avoir une assistante cuisine. Mon mari dit que je suis moins stressée le soir. Les enfants aussi ont remarqué."

---

**Requirements révélés par ce parcours :**
- Scan OCR tickets ultra-rapide (<3s) avec haute précision
- Onboarding profils personnalisés (famille, sportif, etc.)
- Notifications intelligentes péremption (timing optimal)
- Suggestions recettes contextuelles (inventaire + profil)
- Dashboard métriques impact (gaspillage évité, économies)
- Planning repas IA avec contraintes (équilibre, préférences, stock existant)
- Comparateur prix multi-enseignes temps réel
- Liste courses générée automatiquement

---

### Parcours 2 : Thomas, le Sportif Optimisateur - "La Performance Sans Compromis"

**Opening Scene - Le Dimanche Meal Prep**

Thomas, 29 ans, développeur web, passionné musculation (5x/semaine). Chaque dimanche, il passe **3 heures** à préparer ses meal prep pour la semaine.

Il utilise MyFitnessPal pour tracker ses macros (objectif : 180g protéines, 2800 kcal/jour pour prise de masse). Problème : **workflow laborieux** :

1. Planifier 5 repas variés qui atteignent ses macros
2. Faire liste courses
3. Aller supermarché (souvent 2 magasins : Carrefour + magasin bio pour protéines)
4. Cuisiner 3h (batch cooking poulet, riz, légumes)
5. Peser portions, logger manuellement dans MyFitnessPal

**État émotionnel :** Déterminé mais frustré par le temps perdu. "Il doit y avoir plus efficace."

**Déclencheur :** Il voit une pub Instagram FrigoFute : "Meal prep intelligent. Macros automatiques. Économise 50€/mois." Il teste.

---

**Rising Action - Semaine 1 : L'Optimisation**

**Jour 1 - Setup**

Thomas crée son profil : "Sportif - Prise de masse", entre ses stats (82kg, 178cm, actif très élevé). L'app calcule automatiquement son TDEE : 2850 kcal/jour, suggère macros : 180g protéines, 350g glucides, 80g lipides.

Il scanne son frigo actuel (poulet, œufs, riz, patates douces, brocolis). **37 produits** inventoriés en 1 minute.

**Jour 3 - Première surprise**

Notification : "🥚 Œufs (18 unités) expirent dans 5 jours. Recette riche protéines : Omelette mega-protéinée (45g protéines)". Thomas sourit : "Pas con."

**Jour 6 - Courses optimisées**

Thomas doit refaire ses courses protéines. Habituellement : Carrefour (poulet 11€/kg) + Naturalia (saumon bio 24€/kg).

FrigoFute comparateur prix lui montre :
- Lidl : Poulet 7.50€/kg (-32%), Saumon 19€/kg (-21%)
- **Économie totale trajet : 18€**

Il change ses habitudes. "18€ économisés, ça paye déjà la moitié de l'abonnement."

---

**Climax - Semaine 2 : Le Planning IA qui Change Tout**

**Dimanche matin, avant meal prep habituel**

Thomas teste "Planning Repas Hebdomadaire - Profil Sportif".

Il entre :
- Objectif : 2850 kcal/jour, macros optimales
- Contraintes : batch cooking (prépare dimanche pour 5 jours)
- Ingrédients déjà en stock

**Moment magique :** L'IA génère :
- **5 repas équilibrés** (déjeuner + dîner × 5 jours)
- **Macros exactes** pour chaque repas (affichage précis : Repas 1 = 650 kcal, 48g protéines, 72g glucides, 18g lipides)
- **Recettes batch-cooking friendly** (tout préparable en 1 session)
- **Utilise 70% de son stock existant** (anti-gaspi)
- **Liste courses optimale** : seulement 8 articles manquants (38€ chez Lidl vs 52€ Carrefour)

Thomas calcule : "Ce planning m'aurait pris 1h30 à faire manuellement. Là, 30 secondes."

**Décision immédiate :** Abonnement Premium annuel (49.99€, 2 mois offerts).

**Émotions :** Excitation, validation ("enfin une app qui comprend mes besoins"), gain d'efficacité.

---

**Rising Action Suite - Semaine 3 : Coach IA Nutrition**

**Jeudi soir, dîner imprévu restaurant**

Thomas va au restaurant avec des amis. Il prend photo de son plat (burger + frites). Upload dans FrigoFute Coach IA (Gemini Vision).

**Réponse instantanée (15s) :**
"Plat détecté : Burger bœuf, frites, sauce. Estimation : 1150 kcal, 52g protéines, 98g glucides, 58g lipides.

⚠️ Alerte : Tu as déjà consommé 1820 kcal aujourd'hui. Ce plat t'amène à 2970 kcal (objectif 2850).

💡 Conseil : Ton macro protéines est à 148g/180g. Si tu veux rester dans tes objectifs, partage les frites avec un ami ou prends légumes à la place. Sinon, ajoute 30g protéines demain (ex: shaker whey)."

Thomas ajuste. **Auto-logging automatique** (vs saisie manuelle MyFitnessPal 5 min).

**Émotions :** Impressed. "Cette app est meilleure que MyFitnessPal."

---

**Resolution - Mois 2 : La Nouvelle Routine**

**Workflow Thomas 2.0 :**

- **Dimanche 10h :** Planning IA généré (30s) + courses Lidl optimisées (économie 15-20€/semaine)
- **Dimanche 11h-13h :** Meal prep (1h30 vs 3h avant grâce au planning pré-organisé)
- **Quotidien :** Photo repas → Coach IA → Auto-logging macros

**Résultats mesurables :**
- ✅ **1h30 gagnées/semaine** (moins de planning manuel)
- ✅ **70€ économisés/mois** sur courses protéines (comparateur prix)
- ✅ **Macros atteints 95% des jours** (vs 80% avant avec tracking manuel approximatif)
- ✅ **Prise de masse optimale** : +3kg muscle en 2 mois (objectif atteint)

**État émotionnel final :** Performance maximale, efficacité, satisfaction d'avoir "hacké" son meal prep.

**Quote de Thomas :** "J'ai désinstallé MyFitnessPal. FrigoFute fait tout mieux : planning, macros, économies, coach IA. C'est le Notion du fitness nutrition."

**Post Instagram :** Photo meal prep + screenshot macros FrigoFute → 340 likes, 28 commentaires, 12 amis téléchargent l'app.

---

**Requirements révélés par ce parcours :**
- Profils nutritionnels sportifs (prise de masse, sèche, endurance, etc.)
- Calcul TDEE automatique (BMR + niveau activité)
- Planning repas avec contraintes macros précises
- Suggestions batch cooking / meal prep
- Intégration Gemini Vision (reconnaissance photo repas)
- Auto-logging nutritionnel (vs saisie manuelle)
- Coach IA avec conseils contextuels temps réel
- Comparateur prix pour produits sportifs/protéines

---

### Parcours 3 : Marie, la Retraitée Éco-responsable - "Économies et Conscience Tranquille"

**Opening Scene - Le Budget Serré**

Marie, 67 ans, retraitée (pension 1200€/mois), vit seule. Chaque euro compte. Elle cuisine quotidiennement, recettes traditionnelles qu'elle connaît par cœur.

**Problème :** Malgré son attention, elle gaspille quand même. La semaine dernière : 1 salade fanée oubliée, pot de crème fraîche moisi, reste de fromage desséché. "Encore 8€ jetés... À ce rythme, c'est 30€/mois gaspillés. Inacceptable."

**Valeurs :** Profond respect de la nourriture (génération d'après-guerre), sensibilité écologique forte, mais revenus fixes limitent les achats bio/locaux qu'elle voudrait faire.

**État émotionnel :** Culpabilité morale (gaspillage = péché) + frustration financière.

**Déclencheur :** Sa petite-fille Clara (24 ans) lui dit : "Mamie, j'ai trouvé une app pour toi. C'est gratuit et ça évite de jeter. Je t'aide à l'installer."

---

**Rising Action - Semaine 1 : L'Apprentissage Guidé**

**Jour 1 - Installation avec Clara**

Clara installe FrigoFute sur le smartphone de Marie (Samsung A15). Onboarding simplifié : profil "Senior - Budget maîtrisé", objectif "Réduire gaspillage".

Clara explique : "Mamie, regarde. Tu vas au frigo, tu scannes les codes-barres avec le téléphone, ça enregistre tout. Après, l'app te prévient avant que ça expire."

Marie scanne 3 produits (yaourts, jambon, lait). **Succès.** "Ah oui, c'est comme à la caisse du supermarché !"

Clara ajoute manuellement 10 autres produits (légumes frais sans code-barres, fromages, reste de quiche). Marie observe, apprend.

**Émotions :** Appréhension initiale → Curiosité → Première confiance ("Clara est là, je vais y arriver").

**Jour 2 - Première notification seule**

Marie reçoit sa première alerte : "🥛 Lait demi-écrémé expire demain".

Elle sourit : "Ah ! Je l'aurais oublié celui-là." Elle fait un riz au lait pour le goûter (recette de sa mère). **Zéro gaspi.**

**Émotions :** Fierté, validation ("l'app marche vraiment").

---

**Jour 4 - Première difficulté**

Marie veut ajouter "reste de pot-au-feu maison" (Tupperware frigo). Pas de code-barres. Elle cherche... trouve le bouton "+ Ajouter produit manuel".

Remplit :
- Nom : "Pot-au-feu maison"
- Catégorie : "Plats préparés"
- Emplacement : "Réfrigérateur"
- Date péremption : "Dans 3 jours"

**Petit blocage :** Elle met 5 minutes, hésite sur la catégorie. Mais **réussit**.

**Émotions :** Légère frustration → Satisfaction d'avoir résolu seule.

**Jour 6 - Courses avec comparateur**

Marie prépare sa liste courses papier habituelle (15 articles). Clara lui a montré la fonction comparateur prix.

Marie entre sa liste dans l'app :
- Carrefour City (100m) : 42€
- Intermarché (800m, 10 min marche) : 36€
- **Économie : 6€**

Marie décide : "10 minutes de marche pour 6€, ça en vaut la peine. Et puis ça me fait de l'exercice."

**Émotions :** Satisfaction du bon plan, fierté d'utiliser la technologie "comme les jeunes".

---

**Climax - Semaine 3 : La Validation Morale et Financière**

**Dimanche après-midi**

Marie montre fièrement son dashboard FrigoFute à Clara (venue déjeuner) :

**Statistiques 3 semaines :**
- 🗑️ **Gaspillage évité : 4.2 kg**
- 💰 **Économies estimées : 18€**
- 🌱 **Impact CO2 évité : 8.4 kg CO2eq**

Clara : "Mamie, tu vois ! 18€ en 3 semaines, c'est presque 80€ par an !"

Marie, émue : "Tu sais Clara, quand j'étais petite pendant la guerre, on ne jetait JAMAIS rien. Aujourd'hui avec cette app, j'ai l'impression de respecter à nouveau la nourriture comme on me l'a appris. Et en plus j'économise. C'est... c'est bien."

**Moment magique :** Marie réalise qu'elle peut **aligner ses valeurs (anti-gaspi) et ses contraintes (budget)** grâce à l'app.

**Émotions :** Accomplissement moral, cohérence retrouvée, gratitude.

---

**Resolution - Mois 2 : La Routine Intégrée**

**Routine Marie :**

- **Après chaque courses (2x/semaine) :** Scan codes-barres nouveaux produits (5 min)
- **Chaque matin :** Check rapide notifications péremption (1 min)
- **Dimanche :** Consulte dashboard (plaisir de voir économies)

**Résultats mesurables :**
- ✅ **Gaspillage divisé par 5** (de 8€/mois → 1.5€/mois)
- ✅ **25€ économisés/mois** (comparateur prix courses)
- ✅ **Conscience tranquille** : respecte ses valeurs anti-gaspi

**État émotionnel final :** Sérénité, fierté générationnelle ("moi aussi je maîtrise la technologie"), alignement valeurs/actions.

**Quote de Marie :** "À mon âge, on me dit souvent que je suis dépassée par les téléphones. Mais cette app, elle est simple. Et surtout, elle m'aide à faire ce qui est juste : ne rien gaspiller. Je la recommande à toutes mes amies de la chorale."

**Action :** Marie reste sur la **version gratuite** (suffisante pour ses besoins : inventaire + alertes + comparateur basique). Elle en parle à 8 amies retraitées → 3 téléchargent.

---

**Requirements révélés par ce parcours :**
- Onboarding ultra-simplifié pour seniors (moins tech-savvy)
- Interface claire, boutons larges, texte lisible (accessibilité)
- Aide contextuelle (tooltips, tutoriels courts)
- Ajout manuel produits facile (pour produits sans code-barres)
- Dashboard impact écologique (kg CO2 évité) - argument moral
- Version gratuite robuste (MVP suffit pour ce segment)
- Comparateur prix simple (pas besoin optimisation parcours complexe)
- Notifications claires, non-intrusives

---

### Parcours 4 : Lucas, l'Étudiant Débrouillard - "Survie Budget + Découverte Culinaire"

**Opening Scene - Le Frigo du Chaos**

Lucas, 22 ans, étudiant ingénieur (L3), vit en coloc (3 colocataires). Budget courses : **180€/mois** (serré).

**Problème :** Lucas cuisine "au feeling". Résultat : **chaos organisationnel** :
- Achète pâtes, riz, conserves sans savoir ce qu'il a déjà → doublons
- Oublie produits frais au fond du frigo → poivrons moisis (3€ jetés), reste de viande hachée douteux
- Manque d'inspiration recettes → mange pâtes carbo 4x/semaine
- Fait courses "au pif" → dépense 220€ certains mois (over budget)

**Samedi soir, frigo vide, 23h :** Lucas commande Uber Eats burger (14€). Il regarde son compte bancaire : **-47€ jusqu'à la fin du mois.**

"Putain, faut que j'arrête de cramer mon budget bouffe."

**État émotionnel :** Stress financier, sentiment d'incompétence culinaire, frustration de manger "mal" (malbouffe répétitive).

**Déclencheur :** Lundi matin, amphi. Son pote Théo : "Mec, télécharge FrigoFute. C'est gratuit, ça t'aide à gérer ton frigo et ça trouve les courses les moins chères. J'économise genre 40€/mois."

Lucas installe pendant le cours de thermo.

---

**Rising Action - Semaine 1 : La Prise de Contrôle**

**Jour 1 - État des lieux**

Lucas rentre chez lui, ouvre le frigo/placards. Il inventorie tout avec FrigoFute :
- Scan code-barres : 12 produits
- Ajout manuel : 8 produits (légumes, reste pâtes, boîte thon)

**Résultat inventaire :** 20 produits, valeur estimée **32€**. "Ah... j'ai quand même de quoi manger."

**Émotions :** Surprise (a plus qu'il pensait), début de contrôle.

**Jour 2 - Première alerte + première recette**

Notification : "🥕 Carottes (1kg) à consommer dans 2 jours".

Lucas : "Je fais quoi avec des carottes moi ?"

Il clique → Suggestions recettes avec ingrédients dispo :
- "Soupe carottes-pommes de terre (15 min, 0.80€/portion)"
- "Carottes rôties au miel (20 min, facile)"

Lucas choisit soupe (jamais fait). **Tuto simple intégré**. Il cuisine, réussit. **4 portions** (2 jours de repas).

**Moment surprise :** "Putain, c'est bon. Et ça m'a coûté genre 3€ pour 4 repas vs 14€ le burger Uber Eats."

**Émotions :** Fierté culinaire (première fois réussit une vraie recette), validation économique.

---

**Jour 5 - Courses optimisées**

Lucas doit refaire courses (budget restant : 60€ pour 3 semaines).

Il utilise FrigoFute comparateur prix, entre liste 15 articles :
- Carrefour Campus : 48€
- Lidl (15 min bus) : 35€
- Aldi (20 min bus) : 33€
- **Économie Aldi : 15€**

Lucas prend le bus, fait courses Aldi. **Victoire : 33€ dépensés, reste 27€ buffer.**

**Émotions :** Soulagement financier, sensation "j'ai hacké le système".

---

**Climax - Semaine 3 : La Transformation Culinaire**

**Dimanche après-midi, semaine exam**

Lucas découvre la fonction **"Recettes avec ce que j'ai"**. Il filtre :
- Budget : "Très économique"
- Temps : "< 20 min" (semaine exam chargée)
- Difficulté : "Facile"

**Résultats :** 12 recettes possibles avec son inventaire actuel.

Il découvre :
- Omelette champignons-fromage (ingrédients dispo, 10 min)
- Riz sauté légumes (utilise reste riz + légumes qui vont s'abîmer)
- Pâtes aglio e olio améliorées (ail, huile, piment, parmesan)

**Moment magique :** Lucas réalise : "Je peux cuisiner varié, rapide, pas cher, AVEC ce que j'ai déjà. Je suis plus obligé de bouffer des pâtes carbo ou commander."

**Semaine exam :** Lucas cuisine 6 recettes différentes, 0 commande Uber Eats, **économie : 50€ vs semaine exam habituelle.**

**Émotions :** Autonomie culinaire découverte, confiance en soi, excitation ("je deviens bon en cuisine").

---

**Rising Action Suite - Semaine 4 : Gamification**

Lucas découvre le module **Gamification** (gratuit) :

**Achievements débloqués :**
- 🏆 "Zéro Gaspi Week" : aucun produit périmé jeté pendant 7 jours
- 🔥 "Streak Chef" : cuisiné maison 5 jours d'affilée
- 💰 "Économe Pro" : économisé 15€+ sur courses cette semaine

**Leaderboard amis** (opt-in) : Lucas invite ses 3 colocs + Théo. Il voit :
1. Théo : 850 points
2. **Lucas : 720 points** 🥈
3. Coloc1 : 340 points

Lucas, compétitif : "Je vais le défoncer Théo." → Motivation gamifiée pour continuer.

**Émotions :** Fun, compétition saine, engagement ludique.

---

**Resolution - Mois 2 : Le New Normal**

**Routine Lucas :**

- **Courses 1x/semaine :** Comparateur prix systématique (économie 12-18€/semaine)
- **Cuisine 4-5x/semaine :** Recettes app simples/rapides
- **Check inventaire :** Régulièrement (évite achats doublons)
- **Gamification :** Check leaderboard, défis hebdo

**Résultats mesurables :**
- ✅ **Budget courses maîtrisé : 165€/mois** (vs 220€ avant, -55€/mois)
- ✅ **Gaspillage quasi-zéro** (de 10€/mois jeté → 1€/mois)
- ✅ **Variété culinaire** : 15 recettes différentes apprises en 2 mois
- ✅ **Commandes Uber Eats divisées par 5** (de 4x/mois → 1x/mois ou moins)
- ✅ **Économie totale : 60-70€/mois**

**État émotionnel final :** Autonomie financière et culinaire, confiance, fierté devant ses colocs ("le mec qui gère").

**Quote de Lucas :** "FrigoFute m'a appris à cuisiner sans m'en rendre compte. Avant je galérais, maintenant je gère mon budget ET je mange mieux. En plus c'est gratuit. Tous mes potes étudiants l'ont installé."

**Action virale :** Lucas poste TikTok "Comment j'économise 60€/mois en tant qu'étudiant fauché" avec démo FrigoFute → 12K vues, 340 téléchargements app.

---

**Requirements révélés par ce parcours :**
- Version gratuite robuste et complète (segment étudiant ne paiera pas premium)
- Recettes budget-friendly, rapide, facile (filtres essentiels)
- Fonction "Cuisiner avec ce que j'ai" (anti-achat inutile)
- Comparateur prix essentiel (argument #1 pour étudiants)
- Gamification (achievements, leaderboard) - engagement jeune public
- Tutoriels recettes intégrés (débutants cuisine)
- Viral features (partage stats, défis amis)

---

### Journey Requirements Summary

**Capacités Révélées par les 4 Parcours**

**Scan & Inventaire :**
- Scan OCR tickets ultra-rapide (<3s, précision >85%)
- Scan code-barres produits packagés (>95% reconnaissance)
- Ajout manuel produits (interface simple, accessible seniors)
- Catégorisation automatique (12 catégories, 6 emplacements)
- Inventaire partageable (future : mode colocation pour Lucas)

**Alertes & Notifications :**
- Notifications péremption intelligentes (timing optimal : 2 jours avant)
- Notifications contextuelles (suggestions recettes quand produit expire)
- Paramétrage quiet hours (pas la nuit)
- Fréquence ajustable (quotidien, hebdo)

**Suggestions Recettes :**
- Matching inventaire temps réel ("Cuisiner avec ce que j'ai")
- Filtres multiples : budget, temps, difficulté, profil nutritionnel
- Tutoriels intégrés (débutants comme Lucas)
- Base recettes cuisine française variée (Sophie, Marie)
- Recettes batch-cooking (Thomas meal prep)

**Profils Nutritionnels :**
- 12 profils prédéfinis (famille, sportif prise masse/sèche, senior, étudiant, végan, diabétique, etc.)
- Calcul automatique TDEE/BMR
- Ajustement macros précis (Thomas 180g protéines)
- Suivi quotidien calories/macros
- Dashboard nutrition (% équilibre, carences potentielles)

**Planning Repas IA :**
- Génération planning hebdomadaire contextualisé
- Contraintes multiples : profil, macros, budget, temps, stock existant
- Mode batch-cooking (Thomas)
- Adaptation famille (Sophie enfants)
- Variété imposée (pas répétition)

**Coach IA Nutrition (Gemini Vision) :**
- Reconnaissance photo repas (<15s)
- Estimation calories/macros
- Auto-logging nutritionnel
- Conseils contextuels temps réel (Thomas restaurant)
- Chatbot questions nutrition

**Comparateur Prix :**
- Multi-enseignes (4+ sources : Carrefour, Leclerc, Lidl, Aldi, etc.)
- Comparaison temps réel
- Affichage économies potentielles (€ + %)
- Optimisation parcours multi-magasins (algorithme distance/économie)
- Mode simple (Marie) vs mode avancé (Sophie/Thomas)

**Liste Courses Intelligente :**
- Génération auto basée planning repas
- Déduction inventaire existant
- Optimisation prix intégrée
- Export/partage (future : mode famille)

**Dashboard & Métriques :**
- Gaspillage évité (kg + €)
- Économies réalisées (€/semaine, /mois)
- Impact écologique (kg CO2eq évités) - Marie valeurs
- Stats nutrition (jours équilibrés %, macros moyens)
- Graphiques évolution temporelle

**Gamification :**
- Achievements (badges anti-gaspi, chef, économe)
- Streaks (jours consécutifs cuisine maison, zéro gaspi)
- Leaderboard amis opt-in (Lucas compétition)
- Défis hebdomadaires/mensuels
- Partage social (TikTok, Instagram)

**Onboarding & Accessibilité :**
- Profils simplifiés (famille, sportif, senior, étudiant)
- Tutoriels interactifs courts
- Aide contextuelle (tooltips)
- Interface adaptative (senior : gros boutons, texte lisible)
- Mode guidé première utilisation

**Freemium Architecture :**
- **Gratuit (6 modules)** : Inventaire, scan basique, alertes, recettes basiques, dashboard, profil
- **Premium (14 modules)** : Planning IA, Coach IA, Comparateur prix avancé, Gamification complète, Export/Partage


## Domain-Specific Requirements

### Nutritional & Health Claims Compliance

**Regulatory Context:** Règlement (UE) n°1169/2011 sur l'information des consommateurs + Règlement (CE) n°1924/2006 sur les allégations nutritionnelles et de santé.

**Requirements:**

- ❌ **Interdiction allégations santé thérapeutiques** - Le Coach IA Nutrition ne doit pas faire d'allégations médicales ("ce produit prévient le diabète", "réduit le cholestérol", "guérit X maladie")
- ✅ **Limitation conseils nutritionnels généraux** - Coach IA limité à conseils nutrition généralistes, non personnalisés médicalement
- ✅ **Disclaimer obligatoire visible** - Affichage permanent : "Informations nutritionnelles indicatives, non certifiées par professionnel de santé. Consultez un médecin ou nutritionniste pour conseils personnalisés."
- ✅ **Données OpenFoodFacts non garanties** - Source collaborative, précision variable. Mention explicite : "Base de données OpenFoodFacts collaborative, exactitude non garantie. Vérifiez étiquettes produits."
- ✅ **Profils médicaux avec avertissement** - Pour profils diabétique, hypertendu, allergies sévères : avertissement obligatoire "Consultez votre médecin avant modification régime alimentaire"
- ✅ **Pas de promesses perte poids** - Éviter formulations "perdez X kg en Y semaines" (publicité mensongère)

**Implementation:**
- Disclaimer écran Coach IA Nutrition
- Pop-up premier usage profils médicaux
- Mentions légales section "Non-dispositif médical"

---

### Health Data Privacy (RGPD Article 9 - Données Sensibles)

**Regulatory Context:** Données de santé = catégorie spéciale RGPD Article 9, exigences renforcées.

**Classification Données:**

- **Données NON sensibles :** Inventaire frigo (produits alimentaires), listes courses, recettes
- **Données SENSIBLES (santé) :** Suivi calories/macros quotidien, profils nutritionnels médicaux (diabétique, hypertendu), journal repas, objectifs perte/prise poids, photos repas analysées par IA

**Requirements:**

- ✅ **Double opt-in données santé** - Consentement explicite distinct pour activation modules nutrition (séparé du consentement général CGU)
- ✅ **Information transparente pré-consentement** :
  - Quelles données collectées (calories, macros, photos repas, profil santé)
  - Finalité usage (suivi nutrition personnalisé, coaching IA)
  - Durée conservation (tant que compte actif + 30 jours post-suppression)
  - Destinataires (serveurs Firebase, API Gemini - préciser localisations UE/US)
- ✅ **Droit retrait consentement facilité** - Bouton "Désactiver suivi nutrition" accessible → suppression données santé sous 30 jours
- ✅ **Droit suppression données santé** - Fonction "Supprimer mes données nutrition" distincte de suppression compte global
- ✅ **Minimisation données** - Collecte strictement nécessaire (pas de collecte "au cas où")
- ✅ **Chiffrement renforcé données santé** - Encryption at-rest + in-transit pour données nutrition
- ✅ **DPO (Data Protection Officer)** - Si >250 employés ou traitement données santé à grande échelle, nommer DPO (optionnel startup early stage)

**Implementation:**
- Écran onboarding modules nutrition avec opt-in explicite
- Politique confidentialité section "Données santé"
- Paramètres > Confidentialité > "Gérer mes données nutrition"

---

### Price Data Legal Compliance

**Regulatory Context:** Scraping sites web enseignes peut violer CGU, propriété intellectuelle, directive bases de données (96/9/CE).

**Legal Risks:**

- ⚠️ **Scraping non autorisé** = violation CGU enseignes → risque contentieux (mise en demeure, cessation, dommages-intérêts)
- ⚠️ **Protection bases de données** - Prix catalogues protégés (investissement substantiel enseignes)

**Requirements:**

- ✅ **Stratégie acquisition prix légale - Priorité partenariats** :
  1. **APIs officielles enseignes** (Carrefour API, Leclerc Drive API, etc.) - Négocier accords
  2. **Open Data** - Données prix publiques si disponibles (rare)
  3. **Crowdsourcing utilisateurs** - Utilisateurs scannent tickets, partagent prix volontairement (opt-in)
  4. **Services tiers agrégateurs** - Si APIs commerciales existantes (vérifier légalité source)

- ❌ **Interdiction scraping non autorisé** - Ne pas scraper sites web sans accord explicite enseigne

- ✅ **Disclaimer prix affichés** - Mention obligatoire :
  "Prix indicatifs, sous réserve de modification sans préavis. Vérifiez prix en magasin. [Nom app] ne garantit pas l'exactitude des prix affichés."

- ✅ **Fréquence mise à jour raisonnable** :
  - Temps réel si API officielle
  - Quotidien minimum si crowdsourcing
  - Mention date dernière MAJ visible

- ✅ **Attribution source prix** - Transparence : "Prix source [Carrefour API | utilisateurs | partenaire X]"

**Implementation:**
- Phase 1 MVP : Crowdsourcing utilisateurs (légal, gratuit)
- Phase 2 : Négocier partenariats enseignes (APIs officielles)
- Disclaimer écran comparateur prix
- CGU section "Données prix non contractuelles"

---

### Food Safety & Expiration Dates Liability

**Regulatory Context:** Responsabilité civile si défaillance app → consommation produit périmé → intoxication alimentaire.

**Legal Risks:**

- ⚠️ **Notification manquée** → Utilisateur consomme produit périmé → maladie → responsabilité app ?
- ⚠️ **Date erronée** → Alerte précoce/tardive → gaspillage ou risque santé

**Requirements:**

- ✅ **Distinction DLC vs DDM critique** :
  - **DLC (Date Limite Consommation)** : "À consommer jusqu'au" = santé (viandes, poissons, produits frais) → Alerte urgente rouge
  - **DDM (Date Durabilité Minimale)** : "À consommer de préférence avant" = qualité (conserves, secs) → Alerte info jaune
  - UI différenciée selon type date

- ✅ **Disclaimer responsabilité utilisateur** - Affichage clair :
  "Les alertes péremption sont indicatives et basées sur dates saisies. [Nom app] ne garantit pas la fraîcheur des produits. Utilisateur responsable de vérifier visuellement/olfactivement produits avant consommation."

- ✅ **Pas de garantie fiabilité absolue** - Clause CGU :
  "Notifications dépendent connectivité, paramètres appareil, bugs potentiels. Ne pas se fier exclusivement à l'application."

- ✅ **Vérification visuelle encouragée** - UX : "Vérifiez toujours l'aspect du produit avant consommation"

- ✅ **Assurance RC produit recommandée** - Souscrire assurance responsabilité civile professionnelle couvrant risques app (conseils nutrition, alertes péremption)

**Implementation:**
- Types alertes différenciés (DLC critique / DDM info)
- Disclaimer premier usage module alertes
- CGU section "Limitation responsabilité"
- Assurance RC souscrite avant lancement production

---

### Consumer Protection & Commercial Practices

**Regulatory Context:** Directive 2005/29/CE pratiques commerciales déloyales, Loi Hamon (France) protection consommateurs, RGPD dark patterns interdits.

**Requirements:**

- ✅ **Freemium transparent - Pas de dark patterns** :
  - Tableau comparatif clair gratuit/premium (features visibles)
  - Pas de compte à rebours "offre expire dans 3h" factice
  - Pas de pré-sélection abonnement annuel caché
  - Bouton "Rester en gratuit" aussi visible que "S'abonner"

- ✅ **Annulation facile abonnement** :
  - Annulation en 3 clics max depuis app
  - Pas besoin contacter support
  - Confirmation immédiate, remboursement si <14 jours (droit rétractation UE)

- ✅ **Tarification claire** :
  - Prix TTC affiché (TVA incluse)
  - Mention "4.99€/mois, renouvelé automatiquement, annulable à tout moment"
  - Pas de frais cachés

- ✅ **Partenariats enseignes/marques - Transparence** :
  - Si affiliation (cashback, commissions) → Mention "Partenaire" visible
  - Comparateur prix neutre : ne pas favoriser enseignes partenaires payantes
  - Si placement produit recettes → Label "Sponsorisé" ou "Partenaire"

- ✅ **Avis utilisateurs authentiques** :
  - Si système reviews/notes → Pas de faux avis
  - Modération contenu généré utilisateurs (recettes partagées, photos)

**Implementation:**
- Design onboarding freemium éthique (pas de dark patterns)
- CGU/CGV conformes loi Hamon + RGPD
- Mentions "Partenaire" si affiliation
- Système annulation self-service

---

### General Legal Protections & Compliance

**Requirements:**

- ✅ **CGU/CGV complètes** (Conditions Générales Utilisation/Vente) :
  - Éditeur app (société, SIRET, siège social)
  - Objet/services fournis
  - Responsabilités/limitations
  - Propriété intellectuelle
  - Loi applicable + juridiction compétente

- ✅ **Politique Confidentialité RGPD-compliant** :
  - Données collectées exhaustives
  - Finalités traitements
  - Bases légales (consentement, intérêt légitime, contrat)
  - Durées conservation
  - Destinataires (sous-traitants : Firebase, Google Cloud, Gemini)
  - Droits utilisateurs (accès, rectification, suppression, portabilité, opposition)
  - Coordonnées DPO ou responsable données

- ✅ **Mentions Légales** :
  - Éditeur, hébergeur (Firebase/GCP)
  - Directeur publication
  - DPO si applicable

- ✅ **Modération Contenu Généré Utilisateurs** :
  - Si partage recettes/photos entre utilisateurs → Modération nécessaire
  - Signalement contenus inappropriés
  - CGU interdisant contenus illicites, diffamatoires, haineux

- ✅ **Cookie Consent (ePrivacy)** :
  - Si web app ou analytics cookies → Bandeau cookies conforme
  - Refus doit être aussi facile qu'accepter

- ✅ **Accessibilité (optionnel mais recommandé)** :
  - RGAA (France) ou WCAG 2.1 AA si app publique/service essentiel
  - Interface accessible seniors (déjà prévu UX)

**Implementation:**
- Pages CGU, CGV, Politique Confidentialité, Mentions Légales accessibles footer app
- Validation juridique avant lancement (avocat spécialisé numérique/RGPD)
- Assurance RC professionnelle souscrite

---

### Risk Mitigations Summary

| Risque Domaine | Probabilité | Impact | Mitigation |
|-----------------|-------------|--------|------------|
| **Allégations santé illégales** | Moyenne | Élevé (amende DGCCRF) | Disclaimer + limitation Coach IA + validation juridique |
| **Violation RGPD données santé** | Faible | Très élevé (4% CA ou 20M€) | Double opt-in + encryption + DPO si nécessaire |
| **Contentieux scraping prix** | Moyenne | Moyen (mise en demeure, coûts légaux) | Priorité APIs officielles + crowdsourcing légal |
| **Responsabilité intoxication alimentaire** | Très faible | Élevé (poursuites) | Disclaimer + assurance RC + distinction DLC/DDM |
| **Dark patterns / pratiques déloyales** | Faible | Moyen (sanctions, réputation) | Design éthique + annulation facile |
| **Données erronées nutrition** | Moyenne | Faible-Moyen | Disclaimer OpenFoodFacts + vérification étiquettes |

**Action prioritaire avant lancement :**
1. ✅ Validation CGU/Politique Confidentialité par avocat RGPD
2. ✅ Souscription assurance RC professionnelle
3. ✅ Audit disclaimers app (nutrition, prix, péremption)
4. ✅ Stratégie légale acquisition prix (partenariats prioritaires)
5. ✅ Formation équipe : limites conseils nutrition (pas allégations santé)


## Functional Requirements

### 1. Gestion d'Inventaire Alimentaire

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

### 2. Acquisition de Données Produits

- **FR11:** Le système reconnaît et traite les tickets de caisse français via OCR avec extraction automatique des produits
- **FR12:** Le système reconnaît les codes-barres EAN-13 et récupère les informations produit depuis des bases de données externes
- **FR13:** Les utilisateurs peuvent prendre une photo d'un ticket de caisse pour l'analyser automatiquement
- **FR14:** Le système affiche la confiance de reconnaissance OCR et permet correction manuelle des produits mal détectés
- **FR15:** Le système enrichit automatiquement les produits scannés avec informations nutritionnelles (OpenFoodFacts ou équivalent)

### 3. Alertes & Notifications Intelligentes

- **FR16:** Les utilisateurs reçoivent des notifications lorsqu'un produit approche de sa date de péremption (DLC ou DDM)
- **FR17:** Les utilisateurs peuvent configurer le délai d'alerte de péremption (par défaut 2 jours avant pour DLC)
- **FR18:** Le système différencie visuellement les alertes DLC (Date Limite Consommation - critique) des alertes DDM (Date Durabilité Minimale - information)
- **FR19:** Les utilisateurs peuvent désactiver les notifications pour des catégories spécifiques de produits
- **FR20:** Les utilisateurs peuvent définir des plages horaires de silence pour les notifications (quiet hours)
- **FR21:** Le système envoie des suggestions de recettes contextuelles lorsqu'un produit arrive à péremption

### 4. Découverte de Recettes & Suggestions

- **FR22:** Les utilisateurs peuvent rechercher des recettes compatibles avec les produits présents dans leur inventaire actuel
- **FR23:** Les utilisateurs peuvent filtrer les recettes par critères (budget, temps de préparation, difficulté, régime alimentaire)
- **FR24:** Le système suggère automatiquement des recettes utilisant prioritairement les produits proches de la péremption
- **FR25:** Les utilisateurs peuvent accéder à des tutoriels détaillés pour chaque recette
- **FR26:** Les utilisateurs peuvent marquer des recettes comme favorites pour accès rapide
- **FR27:** Le système adapte les suggestions de recettes au profil nutritionnel de l'utilisateur

### 5. Planning Repas & Génération Intelligente

- **FR28:** Les utilisateurs peuvent générer automatiquement un planning de repas hebdomadaire via IA
- **FR29:** Le système génère des plannings respectant les contraintes nutritionnelles du profil utilisateur (macros, calories)
- **FR30:** Le système optimise les plannings pour utiliser prioritairement les produits en stock (anti-gaspillage)
- **FR31:** Les utilisateurs peuvent spécifier des contraintes de planning (temps de préparation max, batch cooking, préférences culinaires)
- **FR32:** Les utilisateurs peuvent modifier manuellement le planning généré (remplacer un repas, ajuster portions)
- **FR33:** Le système génère automatiquement une liste de courses complémentaire basée sur le planning et l'inventaire existant

### 6. Suivi Nutritionnel & Coach IA

- **FR34:** Les utilisateurs peuvent sélectionner un profil nutritionnel parmi 12 profils prédéfinis (famille, sportif prise de masse, sportif sèche, végan, diabétique, senior, etc.)
- **FR35:** Le système calcule automatiquement le TDEE (Total Daily Energy Expenditure) et BMR (Basal Metabolic Rate) basé sur les caractéristiques physiques de l'utilisateur
- **FR36:** Les utilisateurs peuvent enregistrer leur consommation alimentaire quotidienne avec tracking automatique des calories et macronutriments
- **FR37:** Les utilisateurs peuvent prendre une photo de leur repas pour reconnaissance automatique et logging nutritionnel via IA vision
- **FR38:** Le système fournit des conseils nutritionnels contextuels temps réel basés sur la consommation journalière actuelle
- **FR39:** Les utilisateurs peuvent consulter un historique de leur suivi nutritionnel (jour, semaine, mois)
- **FR40:** Le système affiche un dashboard nutrition montrant l'équilibre alimentaire (pourcentage jours équilibrés, carences potentielles, atteinte objectifs)
- **FR41:** Les utilisateurs peuvent interagir avec un chatbot IA pour poser des questions nutritionnelles générales

### 7. Comparateur Prix & Optimisation Courses

- **FR42:** Les utilisateurs peuvent comparer les prix d'une liste de produits entre plusieurs enseignes (minimum 4 sources)
- **FR43:** Le système affiche les économies potentielles en euros et pourcentage pour chaque enseigne
- **FR44:** Les utilisateurs peuvent visualiser sur une carte interactive les magasins disponibles avec leurs prix
- **FR45:** Le système propose un parcours optimisé multi-magasins équilibrant économies et distance de trajet
- **FR46:** Les utilisateurs peuvent exporter leur liste de courses optimisée
- **FR47:** Le système indique la date de dernière mise à jour des prix et la source des données prix

### 8. Dashboard, Métriques & Impact

- **FR48:** Les utilisateurs peuvent visualiser un dashboard récapitulatif de leur activité (gaspillage évité, économies, impact écologique)
- **FR49:** Le système calcule et affiche le gaspillage alimentaire évité (en kg et en euros) sur différentes périodes
- **FR50:** Le système calcule et affiche les économies réalisées grâce au comparateur prix
- **FR51:** Le système calcule et affiche l'impact écologique (kg CO2eq évités) basé sur le gaspillage évité
- **FR52:** Les utilisateurs peuvent consulter des graphiques d'évolution temporelle de leurs métriques
- **FR53:** Le système affiche des statistiques nutritionnelles agrégées (pourcentage jours équilibrés, macros moyens hebdomadaires)

### 9. Gamification & Engagement

- **FR54:** Les utilisateurs peuvent débloquer des achievements (badges) pour actions anti-gaspillage, cuisine maison, économies
- **FR55:** Le système suit les streaks d'activité (jours consécutifs sans gaspillage, cuisine maison)
- **FR56:** Les utilisateurs peuvent rejoindre un leaderboard avec amis (opt-in) pour compétition ludique
- **FR57:** Le système propose des défis hebdomadaires ou mensuels personnalisés
- **FR58:** Les utilisateurs peuvent partager leurs accomplissements sur réseaux sociaux

### 10. Authentification & Profil Utilisateur

- **FR59:** Les utilisateurs peuvent créer un compte avec authentification sécurisée (email/password, OAuth)
- **FR60:** Les utilisateurs peuvent configurer leur profil personnel (nom, caractéristiques physiques, objectifs)
- **FR61:** Les utilisateurs peuvent modifier leurs préférences alimentaires et restrictions (allergies, régimes spéciaux)
- **FR62:** Les utilisateurs peuvent synchroniser leurs données entre plusieurs appareils
- **FR63:** Les utilisateurs peuvent exporter l'intégralité de leurs données personnelles (portabilité RGPD)
- **FR64:** Les utilisateurs peuvent supprimer définitivement leur compte et toutes leurs données

### 11. Partage & Collaboration Familiale

- **FR65:** Les utilisateurs peuvent partager leur inventaire avec d'autres utilisateurs (mode famille/colocation)
- **FR66:** Les utilisateurs peuvent partager des recettes et plannings repas avec d'autres utilisateurs
- **FR67:** Les utilisateurs peuvent exporter des rapports au format PDF (inventaire, planning, métriques)
- **FR68:** Les utilisateurs peuvent synchroniser une liste de courses partagée en temps réel avec d'autres membres de la famille

### 12. Conformité, Sécurité & Consentements

- **FR69:** Le système affiche des disclaimers obligatoires pour conseils nutritionnels (non-dispositif médical, consulter professionnel santé)
- **FR70:** Le système affiche des disclaimers pour prix affichés (indicatifs, non contractuels, vérification en magasin)
- **FR71:** Le système affiche des disclaimers pour alertes péremption (responsabilité utilisateur, vérification visuelle produits)
- **FR72:** Les utilisateurs doivent fournir un double opt-in explicite pour activer le suivi de données de santé (nutrition)
- **FR73:** Les utilisateurs peuvent retirer leur consentement pour données santé à tout moment avec suppression sous 30 jours
- **FR74:** Le système chiffre les données sensibles (profils nutrition, historique achats) au repos et en transit
- **FR75:** Les utilisateurs peuvent gérer leurs consentements granulaires (données santé, cookies analytics, notifications marketing)

### 13. Accessibilité & Expérience Utilisateur

- **FR76:** Le système propose un onboarding guidé adapté au profil utilisateur (famille, sportif, senior, étudiant)
- **FR77:** Le système affiche des tutoriels interactifs pour première utilisation des fonctionnalités principales
- **FR78:** Le système offre une aide contextuelle (tooltips) sur fonctionnalités complexes
- **FR79:** Les utilisateurs seniors peuvent bénéficier d'une interface adaptée (boutons larges, texte agrandi, contraste élevé)
- **FR80:** Le système fonctionne entièrement en mode hors-ligne avec synchronisation différée lors du retour de connexion

### 14. Modèle Freemium & Abonnement

- **FR81:** Les utilisateurs peuvent accéder à 6 modules gratuits sans abonnement (Inventaire, Scan basique, Notifications, Recettes basiques, Dashboard, Profil)
- **FR82:** Les utilisateurs peuvent souscrire à un abonnement Premium (4.99€/mois) pour accès aux 14 modules complets
- **FR83:** Les utilisateurs peuvent tester la version Premium gratuitement pendant 7 jours
- **FR84:** Les utilisateurs peuvent annuler leur abonnement Premium en 3 clics maximum depuis l'application
- **FR85:** Le système affiche un tableau comparatif transparent des fonctionnalités Gratuit vs Premium


## Non-Functional Requirements

### Performance

**NFR-P1: Temps de Scan OCR**
- Le système doit traiter un ticket de caisse et extraire les produits en moins de **2 secondes** (95e percentile)
- Le dual-engine (Google Vision + ML Kit) doit fournir un fallback automatique si un moteur échoue en moins de **500ms**

**NFR-P2: Temps de Lancement Application**
- Cold start de l'application doit compléter en moins de **3 secondes** sur devices mid-range (Android 2 ans, iOS 2 générations précédentes)
- Warm start doit compléter en moins de **1 seconde**

**NFR-P3: Réactivité Interface Utilisateur**
- Toutes interactions utilisateur (tap, swipe, navigation) doivent afficher feedback visuel en moins de **100ms**
- Dashboard métriques doit se charger et afficher en moins de **1 seconde** (données locales Hive)

**NFR-P4: Performance Scan Code-Barres**
- Reconnaissance code-barres EAN-13 doit détecter et traiter en moins de **500ms** en conditions optimales (éclairage correct)
- Le système doit afficher guidance visuelle si positionnement code-barres incorrect

**NFR-P5: Performance Offline**
- Toutes fonctionnalités core (inventaire, alertes, recettes, dashboard) doivent fonctionner en mode offline sans dégradation de performance
- Synchronisation différée lors retour connexion doit compléter en background sans impacter UX

**NFR-P6: Temps Génération Planning IA**
- Génération planning repas hebdomadaire via IA doit compléter en moins de **10 secondes**
- Interface doit afficher progression avec feedback visuel pendant génération

**NFR-P7: Reconnaissance Photo Repas (Gemini Vision)**
- Analyse photo repas et estimation nutritionnelle doit compléter en moins de **15 secondes**
- Le système doit afficher loader avec estimation temps restant

### Security

**NFR-S1: Encryption Données Sensibles**
- Toutes données santé (suivi nutrition, profils médicaux, journal repas, photos repas) doivent être chiffrées **at-rest** (AES-256) et **in-transit** (TLS 1.3+)
- Données non-sensibles (inventaire produits, listes courses) peuvent être stockées non-chiffrées pour performance

**NFR-S2: Authentification Sécurisée**
- Le système doit supporter authentification multi-facteurs (2FA) pour comptes premium
- Authentification Firebase Auth avec OAuth2 providers (Google, Apple, Email/Password)
- Tokens d'authentification doivent expirer après **7 jours** inactivité, refresh automatique transparent

**NFR-S3: Protection API Keys**
- Les clés API (Google Cloud Vision, Gemini, Firebase) doivent être stockées côté serveur, jamais exposées dans le code client
- Rotation automatique API keys tous les **90 jours** minimum

**NFR-S4: Gestion Consentements RGPD**
- Double opt-in obligatoire pour activation modules données santé (tracking nutrition)
- Retrait consentement doit déclencher suppression données santé sous **30 jours** maximum
- Logs audit consentements conservés **3 ans** (preuve compliance)

**NFR-S5: Droit à l'Oubli**
- Suppression compte utilisateur doit effacer **toutes données personnelles** sous **30 jours** (RGPD)
- Confirmation par email avant suppression définitive
- Export données complètes (portabilité) doit être possible avant suppression

**NFR-S6: Protection contre Injections**
- Toutes entrées utilisateur (recherche recettes, ajout manuel produits, chatbot IA) doivent être sanitizées contre injections (SQL, XSS, command injection)
- Validation côté client ET serveur obligatoire

### Scalability

**NFR-SC1: Scalabilité Utilisateurs**
- Le système doit supporter **10,000 utilisateurs actifs mensuels (MAU)** sans dégradation performance (baseline)
- Architecture doit permettre passage à **100,000 MAU** avec moins de **10% dégradation performance** et scaling horizontal

**NFR-SC2: Scalabilité Inventaire Individuel**
- Chaque utilisateur doit pouvoir stocker jusqu'à **1,000 produits** dans son inventaire sans dégradation performance UI
- Pagination automatique et virtual scrolling activés au-delà de **50 produits** affichés

**NFR-SC3: Scalabilité Base Recettes**
- La base de données recettes doit supporter **10,000+ recettes** avec recherche/filtrage performant (<1s)
- Indexation full-text pour recherche recettes

**NFR-SC4: Gestion Pics de Trafic**
- Le système backend (Firebase) doit supporter pics de trafic **3x traffic moyen** (ex: campagne marketing, weekend courses) sans downtime
- Auto-scaling Cloud Functions activé

**NFR-SC5: Coûts Infrastructure Scalables**
- Coût infrastructure par utilisateur doit rester sous **0.50€/mois/MAU** jusqu'à 10,000 MAU
- Budget total infrastructure <**500€/mois** pour 10,000 MAU (cible Technical Success Criteria)

### Reliability & Availability

**NFR-R1: Uptime Système**
- Backend Firebase + APIs externes doivent garantir **99.5% uptime** minimum (cible Technical Success Criteria)
- SLA monitoring avec alertes automatiques si downtime >5 minutes

**NFR-R2: Crash-Free Rate**
- L'application mobile doit maintenir un **crash-free rate >99.9%** (moins de 0.1% sessions avec crash)
- Crash reporting temps réel (Firebase Crashlytics → Sentry)

**NFR-R3: Fiabilité Notifications**
- Les notifications péremption critiques (DLC) doivent être délivrées avec **>99% reliability**
- Retry automatique si échec delivery (jusqu'à 3 tentatives sur 6h)
- Fallback notification locale si push notification échoue

**NFR-R4: Resilience APIs Externes**
- Le système doit continuer à fonctionner en mode dégradé si une API externe (Google Vision, OpenFoodFacts, prix enseignes) est indisponible
- Fallbacks automatiques configurés :
  - Vision API down → ML Kit local seul
  - OpenFoodFacts down → Base locale cache + ajout manuel
  - Prix API down → Message utilisateur "Données prix temporairement indisponibles"

**NFR-R5: Synchronisation Offline-Online**
- Les données modifiées offline doivent se synchroniser automatiquement lors retour connexion avec **conflict resolution** intelligent
- Pas de perte de données en cas de conflit (merge intelligent ou demande arbitrage utilisateur)

**NFR-R6: Backup & Disaster Recovery**
- Backup automatique quotidien Firestore (données utilisateurs)
- Point-in-time recovery possible sur **30 jours** glissants
- RTO (Recovery Time Objective) : **4 heures** maximum en cas désastre majeur

### Integration

**NFR-I1: Intégration Google Cloud Vision API**
- Le système doit gérer quota Google Vision (1000 requêtes/mois free tier) avec monitoring
- Circuit breaker activé si quota atteint 80% → fallback ML Kit seul
- Retry exponential backoff si erreur temporaire API (max 3 retries)

**NFR-I2: Intégration ML Kit (On-Device)**
- ML Kit Text Recognition doit fonctionner 100% offline (aucune dépendance réseau)
- Modèles ML Kit mis à jour automatiquement via Firebase ML

**NFR-I3: Intégration Firebase Services**
- Firebase Auth, Firestore, Cloud Functions, Cloud Storage doivent opérer en mode cohérent
- Timeouts configurés : Auth (10s), Firestore queries (5s), Cloud Functions (30s)

**NFR-I4: Intégration Gemini AI (Vision + Chat)**
- Quota Gemini Free Tier monitoring (60 requests/minute)
- Fallback graceful si quota dépassé : message utilisateur "Service IA temporairement saturé, réessayez dans 1 minute"
- Cache réponses Gemini fréquentes (ex: aliments communs) pour réduire calls API

**NFR-I5: Intégration OpenFoodFacts API**
- Le système doit supporter offline-first avec cache local OpenFoodFacts (produits scannés récemment)
- TTL cache : **7 jours** pour données nutritionnelles produits
- Retry automatique si timeout API (>5s)

**NFR-I6: Intégration APIs Prix Enseignes**
- Le système doit supporter **minimum 4 sources prix** (crowdsourcing utilisateurs + APIs partenaires si disponibles)
- Données prix mises à jour **quotidiennement** minimum
- Disclaimer visible : "Prix indicatifs, dernière MAJ [date], vérifiez en magasin"

**NFR-I7: Intégration Google Maps API**
- Carte interactive comparateur prix doit charger en moins de **3 secondes**
- Gestion quota Maps API : monitoring + circuit breaker si approche limite gratuite (28,000 map loads/mois)

### Accessibility

**NFR-A1: Support WCAG 2.1 Niveau A (Minimum)**
- Contraste couleurs minimum **4.5:1** pour texte standard, **3:1** pour texte large
- Navigation clavier complète (focus visible, ordre logique)
- Alternatives textuelles pour images/icônes (screen readers)

**NFR-A2: Interface Adaptative Seniors**
- Mode "Accessibilité Senior" disponible (activable Settings) avec :
  - Taille texte **+30%** minimum
  - Boutons touch targets **≥48dp** (recommandation Android/iOS)
  - Contraste élevé automatique
  - Simplification navigation (moins d'options simultanées)

**NFR-A3: Support Multi-Langues**
- Phase 1 : Français uniquement
- Architecture i18n préparée pour expansion (EN, NL, DE) année 2

**NFR-A4: Support Screen Readers**
- Compatibilité TalkBack (Android) et VoiceOver (iOS)
- Labels sémantiques corrects pour éléments UI
- Annonces contextuelles (ex: "Produit ajouté à l'inventaire")

### Usability

**NFR-U1: Onboarding Guidé**
- Nouveau utilisateur doit compléter onboarding en **moins de 2 minutes** (cible : 90 secondes)
- Maximum **5 écrans** onboarding (éviter fatigue)
- Skip possible à tout moment

**NFR-U2: Courbe d'Apprentissage**
- Utilisateur novice doit réussir à **ajouter 10 produits (scan + manuel)** sans aide externe dans les **5 premières minutes** d'utilisation
- Tutoriels contextuels (tooltips) affichés lors première utilisation fonctionnalité complexe

**NFR-U3: Feedback Utilisateur**
- Toute action utilisateur (ajout produit, génération planning, scan) doit afficher confirmation visuelle claire
- Erreurs doivent afficher messages explicites avec action corrective suggérée (pas juste "Erreur 500")

**NFR-U4: Cohérence Design**
- Respect strict Material Design 3 (Android) et Human Interface Guidelines (iOS)
- Design tokens partagés (couleurs, typographie, spacing) pour cohérence visuelle

### Maintainability & DevOps

**NFR-M1: Code Coverage Tests**
- Couverture tests **≥75%** (pyramide : 70% unit, 20% integration, 10% E2E)
- CI/CD gate : merge bloqué si coverage <75%

**NFR-M2: CI/CD Pipeline**
- Build + tests automatisés sur chaque commit
- Déploiement automatisé staged rollouts : 5% → 25% → 100% utilisateurs sur **72h**
- Rollback automatique si crash rate >0.5% détecté

**NFR-M3: Monitoring & Observability**
- Logs centralisés (Firebase Crashlytics + future Sentry)
- Métriques business temps réel : DAU, MAU, conversion freemium, rétention D7/D30
- Alertes automatiques si métriques critiques dégradées (ex: crash rate +50%, API errors >5%)

**NFR-M4: Hotfix Capability**
- Correction bugs critiques déployable en **<24h** (release emergency)
- Over-the-air updates pour configuration (feature flags Firebase Remote Config)

**NFR-M5: Documentation Code**
- Fonctions complexes (algorithmes OCR, matching recettes, optimisation parcours) doivent être documentées (dartdoc)
- ADRs (Architecture Decision Records) maintenus pour décisions architecturales majeures
