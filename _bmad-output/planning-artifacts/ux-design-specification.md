---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
lastStep: 14
workflowComplete: true
completionDate: 2026-02-14
inputDocuments:
  - "_bmad-output/planning-artifacts/prd.md"
  - "_bmad-output/planning-artifacts/prd-original.md"
  - "_bmad-output/planning-artifacts/research/technical-FrigoFuteV2-Complete-Stack-research-2026-02-13.md"
---

# UX Design Specification FrigoFuteV2

**Author:** Marcel
**Date:** 2026-02-14

---

<!-- UX design content will be appended sequentially through collaborative workflow steps -->

## Executive Summary

### Project Vision

FrigoFuteV2 est la première plateforme mobile française convergente 4-en-1 combinant anti-gaspillage alimentaire, nutrition personnalisée, planning repas intelligent et comparateur prix multi-enseignes. Le produit transforme le frigo domestique en hub intelligent pour une alimentation saine, économique et durable.

**Différenciateur unique :** Convergence inédite sur le marché français où les concurrents proposent maximum 2 dimensions isolées. FrigoFute délivre un **triple impact mesurable** : santé + économie + écologie.

**Architecture produit :** Application mobile native iOS/Android (Flutter), modèle freemium avec 6 modules gratuits et 8 modules premium (4.99€/mois). Déploiement MVP progressif en 3 tiers validant le product-market fit à chaque étape.

### Target Users

**4 segments prioritaires avec besoins UX distincts :**

**1. Familles organisées (40% TAM)**
- **Persona :** Sophie, 38 ans, maman de 2 enfants, active professionnellement
- **Pain point :** Charge mentale écrasante ("qu'est-ce qu'on mange ce soir ?"), gaspillage par oubli, nutrition enfants déséquilibrée
- **Aha moment :** Planning semaine généré en 1 clic → "2 heures gagnées, contrôle retrouvé"
- **Niveau tech :** Intermédiaire, utilise apps quotidiennes
- **Contexte usage :** Retour courses (scan rapide), soir (décision repas), dimanche (planning semaine)

**2. Sportifs optimisateurs (25% TAM)**
- **Persona :** Thomas, 29 ans, développeur web, passionné musculation 5x/semaine
- **Pain point :** 3h perdues chaque dimanche en meal prep manuel, tracking macros laborieux (MyFitnessPal)
- **Aha moment :** Planning IA avec macros exactes en 30s → "Efficacité maximale"
- **Niveau tech :** Avancé, early adopter, attentes UX élevées
- **Contexte usage :** Dimanche (meal prep), quotidien (photo repas + auto-logging)

**3. Seniors éco-responsables (20% TAM)**
- **Persona :** Marie, 67 ans, retraitée, vit seule, budget serré (1200€/mois)
- **Pain point :** Culpabilité morale du gaspillage, appréhension technologique, revenus fixes limités
- **Aha moment :** Dashboard montre "18€ économisés en 3 semaines" → Validation morale ET financière
- **Niveau tech :** Débutant, besoin accompagnement (petite-fille Clara installe)
- **Contexte usage :** Après courses (scan codes-barres), matin (check alertes), dimanche (consulte stats)

**4. Étudiants budget serré (15% TAM)**
- **Persona :** Lucas, 22 ans, étudiant ingénieur L3, colocation, budget 180€/mois
- **Pain point :** Chaos organisationnel, achats doublons, commandes Uber Eats répétées (budget cramé)
- **Aha moment :** "Recettes avec ce que j'ai" → 12 recettes possibles → "Autonomie culinaire découverte"
- **Niveau tech :** Natif digital, attente UX fluide type TikTok/Instagram
- **Contexte usage :** Quotidien mobile-first, partage social (TikTok), gamification (leaderboard amis)

### Key Design Challenges

**1. Accessibilité multi-générationnelle**
- **Défi :** Interface unique pour seniors (Marie, 67 ans, appréhension tech) ET Gen Z (Lucas, 22 ans, natif digital)
- **Risque :** Marie abandonne si trop complexe, Lucas si pas assez moderne/rapide
- **Contrainte UX :** Mode accessibilité senior (boutons larges ≥48dp, texte +30%, contraste élevé) sans compromettre esthétique moderne
- **Approche :** Onboarding adaptatif par profil + aide contextuelle progressive (tooltips, tutoriels courts)

**2. Onboarding progressif multi-profils sans friction**
- **Défi :** 4 segments = 4 parcours onboarding différents (famille vs sportif vs senior vs étudiant)
- **Contrainte :** "Aha moment" doit arriver en <2 min (scan ticket magique = wow immédiat)
- **Risque :** Questionnaire onboarding trop long → abandon avant valeur perçue
- **Approche :** Onboarding minimaliste (5 écrans max, 90 secondes), profil sélectionné en 1 clic, skip possible

**3. Freemium transparent et éthique (anti-dark patterns)**
- **Défi :** Montrer valeur premium SANS manipulation (pas de compte à rebours factice, pré-sélection cachée)
- **Contrainte réglementaire :** RGPD interdit dark patterns, Loi Hamon protection consommateurs
- **Segmentation conversion :** Étudiants restent gratuits (suffisant), familles/sportifs convertissent naturellement (planning IA = besoin évident)
- **Approche :** Tableau comparatif clair gratuit/premium, bouton "Rester gratuit" aussi visible que "S'abonner", essai 7 jours sans CB

**4. Performance scan OCR critique pour première impression**
- **Défi :** Scan ticket doit être "magique" (<3s pour 100+ produits) sinon retour saisie manuelle pénible
- **Contrainte technique :** Dual-engine Google Vision + ML Kit, parsing tickets français complexe
- **Risque :** Échec scan = frustration immédiate → désinstallation
- **Approche :** Feedback visuel temps réel (progression), correction manuelle facile si reconnaissance partielle, tutoriel scan optimisé (éclairage, angle)

**5. Notifications intelligentes sans spam**
- **Défi :** Alertes péremption utiles (Marie sauve lait) vs intrusives (fatigue notification)
- **Contrainte :** Timing optimal (2 jours avant DLC), contexte pertinent (suggestion recette)
- **Risque :** Trop de notifs → désactivation → perte valeur core (anti-gaspi)
- **Approche :** Quiet hours configurables, fréquence adaptative, notifications contextuelles (pas juste "expire" mais "recette suggérée")

### Design Opportunities

**1. Scan "magique" comme signature UX différenciante**
- **Opportunité :** Le scan ticket ultra-rapide (127 produits en 3s) = différenciateur #1 vs concurrence
- **Impact émotionnel :** Sophie murmure "Putain... c'est de la magie" → moment wow partageable
- **Approche UX :** Micro-interactions célébrant le succès (animations fluides, son subtil, confettis visuels), compteur produits détectés en temps réel, transition satisfaisante inventaire → catégorisation auto

**2. Dashboard impact émotionnel (métriques tangibles)**
- **Opportunité :** Chiffres concrets résonnent émotionnellement ("8kg gaspillage évités, 24€ économisés cette semaine")
- **Segmentation impact :**
  - Marie (senior) : Impact écologique (kg CO2 évités) = validation morale
  - Sophie (famille) : Économies € + temps gagné = soulagement charge mentale
  - Lucas (étudiant) : Graphiques progression = gamification compétitive
- **Approche UX :** Visualisations data claires (graphiques évolution), comparaisons tangibles ("= 2 repas restaurant économisés"), partage social (screenshot stats)

**3. Notifications contextuelles IA proactive**
- **Opportunité :** Pas juste alerter mais **résoudre** (produit expire → recette suggérée automatiquement)
- **Cas d'usage :**
  - Thomas (sportif) : "🥚 18 œufs expirent dans 5j → Recette protéinée : Omelette 45g protéines"
  - Sophie (famille) : "🍓 Fraises à consommer aujourd'hui → Smoothie enfants 5 min"
- **Approche UX :** Notifications riches (image recette, temps prépa, bouton direct "Cuisiner maintenant"), timing intelligent (soir = décision repas)

**4. Gamification subtile multi-générations**
- **Opportunité :** Engagement ludique sans infantiliser
- **Segmentation ludique :**
  - Lucas (étudiant) : Leaderboard amis, achievements TikTok-friendly, compétition
  - Marie (senior) : Streaks simples (7 jours sans gaspi), badges sobres (fierté discrète)
  - Thomas (sportif) : Défis performance (macros parfaits 5j consécutifs)
- **Approche UX :** Opt-in (pas imposé), esthétique mature (pas cartoon), récompenses signifiantes (unlock recettes premium temporaire)

**5. Mode offline-first = fiabilité perçue**
- **Opportunité :** App 100% fonctionnelle sans connexion = confiance utilisateur (inventaire, alertes, recettes)
- **Cas d'usage :** Marie (zone rurale connexion faible), Sophie (magasin sous-sol réseau absent)
- **Approche UX :** Sync transparente background, indicateur statut connexion discret, pas de blocage features core offline

## Core User Experience

### Defining Experience

**Action Core : Le Scan Ticket "Magique"**

L'expérience FrigoFuteV2 est structurée autour d'une action centrale absolue : **le scan de ticket de caisse ultra-rapide**. Cette interaction unique définit la proposition de valeur différenciante et déclenche tous les bénéfices downstream (anti-gaspillage, nutrition, économies).

**Le Core Loop Utilisateur :**

1. **Entrée** : Retour courses → Scan ticket (3 secondes, 100+ produits)
2. **Activation continue** : Notifications intelligentes contextuelles (produit expire → recette suggérée)
3. **Engagement régulier** : Consultation inventaire, décisions repas guidées, dashboard impact
4. **Upgrade naturel** : Découverte valeur premium (planning IA) → conversion sans friction

**Fréquence d'interaction :**
- **Scan ticket** : 1-2x/semaine (après courses)
- **Notifications + actions** : 3-5x/semaine (quotidien léger)
- **Dashboard consultation** : 1x/semaine (validation progrès)
- **Planning génération** (premium) : 1x/semaine (dimanche soir)

**Définition de succès :** L'utilisateur doit percevoir que **l'app fait le travail pénible à sa place** (scan auto vs saisie manuelle, suggestions vs recherche, planning auto vs réflexion mentale).

### Platform Strategy

**Plateforme Principale : Mobile Native iOS/Android (Flutter)**

**Justification plateforme :**
- **Caméra native** : Scan OCR tickets + codes-barres = interaction core critique
- **Notifications push** : Alertes péremption contextuelles = engagement quotidien
- **Stockage local performant** : Inventaire offline-first = fiabilité perçue
- **Contexte usage mobile** : Magasin (scan sur place), cuisine (consultation inventaire), transport (check notifications)

**Capacités Device Exploitées :**

1. **Caméra Optimisée**
   - Dual-engine OCR (Google Vision API + ML Kit local)
   - Auto-détection ticket (cadrage assisté)
   - Guidances visuelles temps réel (éclairage, angle, distance)
   - Feedback haptic subtil au succès scan

2. **Offline-First Critique**
   - **ML Kit local** : Scan fonctionne sans connexion (précision réduite acceptable)
   - **Hive local database** : Inventaire, recettes, dashboard accessibles offline
   - **Sync différée transparente** : Background sync au retour connexion
   - **Cas d'usage critique** : Marie (zones rurales), Sophie (parkings sous-sol magasins)

3. **Notifications Rich Natives**
   - Notifications contextuelles avec **actions directes** : "Cuisiner maintenant", "Marquer consommé"
   - Timing intelligent (soir = décision repas, pas 3h du matin)
   - Rich media (image recette, macros résumées)

4. **Performance Native**
   - Cold start <3s (Material Design 3 / iOS Human Interface Guidelines)
   - Scan OCR <2s (95e percentile)
   - UI 60fps (animations fluides, micro-interactions satisfaisantes)

**Contraintes Plateforme :**
- **Multi-générationnel** : Touch targets ≥48dp (accessibilité Marie), gestures intuitifs (swipe, tap, pas de gestures complexes)
- **Pas de version Web initiale** : Caméra scan = fonctionnalité core mobile-only

### Effortless Interactions

**Zones d'interaction sans effort absolu :**

**1. Scan Ticket → Inventaire Complet (Le Moment Magique)**

**Effort utilisateur :**
- Prendre photo ticket (1 tap)

**App fait automatiquement :**
- OCR dual-engine (Google Vision + ML Kit fallback)
- Parsing produits français (formats tickets Carrefour, Leclerc, Lidl, etc.)
- Catégorisation automatique (12 catégories prédéfinies)
- Assignation emplacement (6 emplacements : frigo, congélateur, placard, etc.)
- Enrichissement nutritionnel (OpenFoodFacts API)
- Estimation dates péremption (DLC/DDM)

**Résultat utilisateur :**
- 127 produits classés en 3 secondes
- Zéro saisie manuelle
- Sophie murmure : "Putain... c'est de la magie"

**Gestion erreurs scan (80-85% précision) :**
- **Mode validation rapide post-scan** : Liste produits détectés, swipe droite = confirmer, swipe gauche = corriger/supprimer
- Produits "confiance faible" marqués visuellement (icône ⚠️)
- Correction suggérée contextuelle (si OCR lit "Pouet" → suggère "Poulet")
- **Principe** : Validation rapide acceptable (30s pour 15 produits douteux) vs saisie manuelle cauchemar (10 min pour 127 produits)

**2. Notifications → Action Directe**

**Effort utilisateur :**
- Recevoir notification → 1 tap action

**App fait automatiquement :**
- Monitoring péremption background (DLC vs DDM différenciés)
- Matching recettes inventaire actuel (produit expire → recettes utilisant ce produit)
- Timing intelligent (soir 18h-20h = décision repas)

**Notification rich exemple :**
```
🍓 Fraises (frigo) expirent aujourd'hui
→ Recette suggérée : Smoothie enfants (5 min)
[Cuisiner maintenant] [Marquer consommé]
```

**Résultat :** Marie sauve son lait en 1 tap → riz au lait fait → zéro gaspi → validation app utile

**3. Planning Génération IA (Premium)**

**Effort utilisateur :**
- 1 tap "Générer planning semaine"
- (Optionnel) Ajuster contraintes (temps prépa max, batch cooking, etc.)

**App fait automatiquement :**
- Analyse inventaire actuel (utilise produits proches péremption prioritairement)
- Respect profil nutritionnel (macros Sophie famille, Thomas sportif, etc.)
- Génération 7 dîners variés (pas de répétition)
- Liste courses complémentaire (seulement produits manquants)
- Optimisation prix (via comparateur multi-enseignes)

**Résultat :** Thomas génère planning en 30s vs 1h30 planification manuelle → "Efficacité maximale"

**4. Catégorisation & Organisation Auto**

**Zero mental load :**
- Produits scannés → catégories assignées automatiquement (viande → frais, pâtes → placard)
- Emplacements suggérés (yaourts → réfrigérateur)
- États suivis automatiquement (frais → à consommer bientôt → périmé)

**Marie (senior) n'a jamais à "choisir catégorie"** → simplicité absolue

### Critical Success Moments

**Make-or-break interactions définissant adoption vs abandon :**

**1. Premier Scan Ticket (Onboarding - Minute 2)**

**Moment critique :** L'utilisateur scanne son premier ticket de caisse.

**Succès = Aha Moment**
- Scan détecte 80%+ des produits (100+ produits)
- Animation satisfaisante (compteur temps réel : "45 produits détectés... 89... 127 !")
- Transition fluide vers inventaire classé automatiquement
- Sophie : "Putain c'est de la magie" → **Hooked**

**Échec = Abandon**
- Scan rate <60%, produits majoritairement mal détectés
- Pas de feedback pendant scan (utilisateur pense que ça bug)
- Erreurs sans possibilité correction facile
- Frustration → Désinstallation immédiate

**UX Critique :**
- **Tutoriel premier scan** : 3 écrans visuels (éclairage optimal, angle ticket, distance caméra)
- **Guidances temps réel** : Cadre auto-détection ticket (bordures vertes si bien positionné)
- **Feedback progressif** : "Analyse en cours... 12 produits détectés... 45... 89..."
- **Célébration succès** : Animation confettis subtils, son satisfaisant (optionnel), "127 produits ajoutés avec succès !"
- **Fallback échec** : Si scan total échec → "Réessayez avec meilleur éclairage" + option ajout manuel simple

**2. Première Notification + Action (Jour 2-3)**

**Moment critique :** Première alerte péremption reçue et action prise.

**Succès = Validation Valeur**
- Marie reçoit "🥛 Lait expire demain" (timing optimal : 19h)
- Tap notification → Suggestion recette (riz au lait 20 min)
- Marie cuisine → Zéro gaspi → **Fierté morale**
- Dashboard montre "Premier produit sauvé !"

**Échec = Désengagement**
- Notification manquée (mauvais timing : 3h du matin)
- Pas d'action claire ("Produit expire" → et alors ?)
- Utilisateur ignore → Produit périme quand même → "App sert à rien"

**UX Critique :**
- **Timing intelligent** : Notifications soir 18h-20h (décision repas) ou matin 8h-9h (planning journée)
- **Quiet hours** : Configurables (pas de notifs nuit)
- **Actionabilité directe** : Boutons "Cuisiner maintenant" (ouvre recette), "Marquer consommé", "Reporter 2 jours"
- **Rich content** : Image recette, temps préparation, ingrédients dispo

**3. Dashboard Impact Tangible (Semaine 1)**

**Moment critique :** Première consultation dashboard après 7 jours d'utilisation.

**Succès = Validation Impact**
- Dashboard montre métriques tangibles :
  - "8 kg gaspillage évités cette semaine"
  - "24€ économisés"
  - "8.4 kg CO2 évités"
- Comparaison visuelle : "= 2 repas restaurant économisés"
- Marie : Accomplissement moral, Sophie : Soulagement financier, Lucas : Gamification (badges débloqués)

**Échec = Valeur Non Perçue**
- Dashboard vide ou chiffres insignifiants ("0.5 kg évités")
- Pas de contexte (utilisateur ne comprend pas l'impact)
- Métriques abstraites (CO2 sans explication)

**UX Critique :**
- **Visualisations claires** : Graphiques évolution (courbes tendances semaine, mois)
- **Comparaisons tangibles** : "24€ = 2 burgers Uber Eats" (Lucas), "8kg = 1 semaine courses famille" (Sophie)
- **Segmentation impact** : Marie voit CO2 en avant (valeurs écolo), Sophie voit € + temps gagné, Lucas voit compétition (leaderboard)

**4. Découverte Valeur Premium (Semaine 2-3)**

**Moment critique :** Trigger naturel vers essai premium (planning IA).

**Succès = Conversion Sans Friction**
- Sophie a 12 produits qui expirent cette semaine (inventaire bien rempli)
- App suggère (in-app banner subtil) : "Générer planning semaine automatique avec ces produits ? Essai gratuit 7 jours"
- Sophie teste → Planning généré en 30s → "2h gagnées, contrôle retrouvé"
- Fin essai 7j → Conversion 4.99€/mois naturelle (ROI évident)

**Échec = Churn Freemium**
- Paywall agressif avant valeur gratuite perçue (popup "Upgrade premium !" après 2 jours)
- Dark pattern (compte à rebours factice "Offre expire dans 3h !")
- Utilisateur sent manipulation → Désinstallation

**UX Critique :**
- **Trigger contextuel** : Suggestion premium quand inventaire riche (opportunité planning évidente)
- **Essai sans CB** : 7 jours gratuits, pas de carte bancaire requise (réduction friction)
- **Tableau comparatif transparent** : Gratuit vs Premium clair (bouton "Rester gratuit" aussi visible que "Essayer premium")
- **Pas de dark patterns** : Conformité RGPD + Loi Hamon (éthique business)

### Experience Principles

**5 Principes Directeurs UX (Guident Toutes Décisions Design) :**

**1. "Scan First, Everything Flows"**

**Principe :** Le scan ticket est l'interaction fondatrice. Sa perfection débloque toute la valeur downstream (anti-gaspi, nutrition, économies). Priorité absolue : performance technique (< 2s) + UX satisfaisante (feedback temps réel, célébration succès).

**Décisions guidées :**
- Budget engineering : 40% du temps MVP Tier 2 sur optimisation scan OCR
- Tests utilisateurs : 50% sessions focalisées sur premier scan
- Animations/micro-interactions : Investissement design sur célébration scan réussi

**2. "Proactive, Not Reactive"**

**Principe :** L'app anticipe les besoins utilisateurs et propose des solutions, pas juste des alertes. Marie ne "cherche" pas une recette pour son lait qui expire, l'app la suggère au bon moment avec timing intelligent.

**Décisions guidées :**
- Notifications riches avec actions directes (pas juste "Produit expire" mais "Recette suggérée : Riz au lait 20 min [Cuisiner]")
- Planning IA génère solutions complètes (pas juste "Faites un planning" mais "Voici 7 dîners organisés")
- Dashboard montre impact (pas juste données brutes mais "24€ = 2 repas restaurant économisés")

**3. "Offline-First Reliability"**

**Principe :** L'app fonctionne TOUJOURS, même sans réseau. La fiabilité perçue prime sur les fonctionnalités avancées. Marie (zone rurale) et Sophie (parking sous-sol) doivent pouvoir scanner et consulter inventaire sans connexion.

**Décisions guidées :**
- Architecture technique : ML Kit local (scan offline), Hive database (inventaire local), sync différée background
- Features core offline : Inventaire, alertes locales, recettes basiques, dashboard
- Features online-only acceptables : Planning IA (Gemini API), comparateur prix (APIs enseignes), Coach IA nutrition
- Indicateur connexion discret (pas de blocage brutal)

**4. "Effortless Entry, Progressive Depth"**

**Principe :** Version gratuite robuste et complète pour entrée sans friction (Marie et Lucas restent gratuits et satisfaits). Premium évident pour power users qui en ont besoin (Sophie planning famille, Thomas macros sportif) → conversion naturelle sans manipulation.

**Décisions guidées :**
- Freemium équilibré : 6 modules gratuits suffisants pour usage basique (inventaire, scan, alertes, recettes, dashboard)
- Premium = fonctionnalités avancées clairement différenciées (planning IA, coach IA, comparateur prix avancé, gamification complète)
- Pas de dark patterns : Tableau comparatif transparent, bouton "Rester gratuit" visible, essai 7j sans CB
- Trigger premium contextuel (quand utilisateur a inventaire riche → "Générer planning ?")

**5. "Multi-Gen Accessible"**

**Principe :** Marie (67 ans, appréhension tech) ET Lucas (22 ans, natif digital) réussissent le premier scan en <2 min. Interface adaptative sans compromettre modernité esthétique.

**Décisions guidées :**
- Onboarding adaptatif par profil (senior = tutoriel guidé avec Clara, étudiant = skip rapide)
- Mode accessibilité senior (Settings) : Boutons ≥48dp, texte +30%, contraste élevé, navigation simplifiée
- Design moderne baseline (Material Design 3 / iOS HIG) avec adaptations progressives
- Aide contextuelle optionnelle (tooltips, tutoriels courts, pas imposés)
- Touch gestures simples (tap, swipe horizontal, pas de gestures complexes multi-doigts)

## Desired Emotional Response

### Primary Emotional Goals

**Émotion Core : "Contrôle Sans Effort"**

FrigoFuteV2 doit créer une émotion unique que les concurrents n'offrent pas : **le sentiment de maîtriser sa vie alimentaire SANS charge mentale ajoutée**. L'utilisateur sent que l'app fait le travail pénible à sa place tout en lui donnant contrôle et visibilité totale.

**Différenciation émotionnelle vs concurrents :**
- **MyFitnessPal** : Satisfaction tracking mais effort laborieux (saisie manuelle pénible)
- **Apps anti-gaspi** : Culpabilité réduite mais pas d'impact émotionnel positif fort
- **Apps recettes** : Inspiration mais déconnectée de la réalité (pas de lien inventaire)
- **FrigoFute** : Contrôle + Soulagement + Accomplissement tangible = Triple impact émotionnel

**Objectifs émotionnels par segment :**

**Sophie (Famille organisée) :**
- **Primaire** : Soulagement (charge mentale libérée)
- **Secondaire** : Contrôle (budget + nutrition maîtrisés), Fierté (éco-responsabilité)
- **Quote visée** : "Mon mari dit que je suis moins stressée le soir"

**Thomas (Sportif optimisateur) :**
- **Primaire** : Accomplissement (objectifs atteints avec efficacité maximale)
- **Secondaire** : Performance (workflow optimisé), Validation ("app me comprend")
- **Quote visée** : "J'ai hacké mon meal prep"

**Marie (Senior éco-responsable) :**
- **Primaire** : Accomplissement moral (alignement valeurs anti-gaspi)
- **Secondaire** : Confiance tech (réussit seule), Sérénité (cohérence retrouvée)
- **Quote visée** : "Je respecte à nouveau la nourriture comme on m'a appris"

**Lucas (Étudiant budget serré) :**
- **Primaire** : Autonomie découverte (culinaire + financière)
- **Secondaire** : Confiance en soi, Fierté sociale ("le mec qui gère")
- **Quote visée** : "FrigoFute m'a appris à cuisiner sans m'en rendre compte"

### Emotional Journey Mapping

**Cartographie émotionnelle par étape d'adoption :**

**Étape 1 : Découverte & Premier Scan (Minute 1-2)**

**État émotionnel entrant :**
- Sophie : Épuisement, scepticisme ("encore une app qui promet")
- Thomas : Curiosité optimiste (early adopter)
- Marie : Appréhension technologique ("je vais pas y arriver")
- Lucas : Désespoir financier ("faut que je règle ce budget bouffe")

**Émotion cible après premier scan :**
- ✅ **Émerveillement** : "Putain c'est de la magie" (Sophie scanne 127 produits en 3s)
- ✅ **Validation tech** : "Ça marche vraiment"
- ✅ **Confiance initiale** : "Cette app va m'aider"

**Moment critique** : Si scan échoue (<60% précision) → Frustration → Désinstallation immédiate

---

**Étape 2 : Validation Valeur (Jour 2-5)**

**État émotionnel entrant :**
- Curiosité post-wow (scan a impressionné)
- Attente de preuve que l'app aide vraiment

**Émotion cible après première notification actionnable :**
- ✅ **Utilité perçue** : Marie reçoit "Lait expire demain" → fait riz au lait → "L'app m'a sauvé mon lait"
- ✅ **Accomplissement** : Dashboard montre "Premier produit sauvé !"
- ✅ **Contrôle retrouvé** : Sophie évite gaspillage fraises grâce alerte

**Moment critique** : Si notification mal timée (3h matin) ou pas d'action claire → Intrusion → Désactivation notifs

---

**Étape 3 : Climax Valeur (Semaine 2-3)**

**État émotionnel entrant :**
- Engagement régulier établi (scan après courses, check notifs)
- Inventaire bien rempli (opportunité planning évidente)

**Émotion cible après découverte valeur premium :**
- ✅ **Révélation** : Sophie génère planning semaine en 30s → "2h gagnées, c'est EXACTEMENT ce qu'il me fallait"
- ✅ **Évidence ROI** : Thomas voit macros parfaites → "Cette app est meilleure que MyFitnessPal"
- ✅ **Libération** : "J'ai repris le contrôle" (Sophie), "Autonomie culinaire" (Lucas)

**Moment critique** : Si paywall agressif avant valeur perçue → Manipulation sentie → Churn

---

**Étape 4 : Routine Établie (Mois 2-3)**

**État émotionnel entrant :**
- Usage hebdomadaire régulier
- Habitudes intégrées (scan automatique, check dashboard dimanche)

**Émotion cible routine long-terme :**
- ✅ **Sérénité** : Sophie "moins stressée le soir" (mari le remarque)
- ✅ **Fierté sociale** : Lucas poste TikTok "Comment j'économise 60€/mois" (340 téléchargements app)
- ✅ **Accomplissement moral** : Marie montre dashboard à Clara "18€ économisés en 3 semaines, c'est bien"
- ✅ **Maîtrise** : Thomas "Performance maximale atteinte"

**Moment critique** : Si dashboard montre valeur insignifiante → Désengagement progressif

### Micro-Emotions

**Micro-états émotionnels critiques à chaque interaction :**

**Confiance vs Scepticisme**

**Où joué :**
- **Premier scan** : Précision OCR >80% = Confiance ("ça marche"), <60% = Scepticisme ("app bugue")
- **Offline-first** : App fonctionne sans réseau (Marie zone rurale) = Confiance fiabilité
- **Disclaimers transparents** : Prix indicatifs, OpenFoodFacts collaboratif = Confiance honnêteté

**Design pour confiance :**
- Feedback temps réel scan ("45 produits détectés... 89... 127")
- Indicateur connexion discret (pas de blocage brutal)
- Freemium transparent (bouton "Rester gratuit" visible)

---

**Accomplissement vs Frustration**

**Où joué :**
- **Dashboard impact** : "8kg évités, 24€ économisés" = Accomplissement tangible
- **Badges milestones** : "7 jours zéro gaspi" = Accomplissement célébré
- **Scan raté** : Produits mal détectés sans correction facile = Frustration

**Design pour accomplissement :**
- Métriques concrètes (pas abstraites)
- Comparaisons tangibles ("= 2 burgers Uber Eats")
- Célébrations subtiles (badges, animations, pas over-the-top)

---

**Autonomie vs Dépendance**

**Où joué :**
- **Lucas "Recettes avec ce que j'ai"** : Autonomie culinaire découverte vs dépendance Uber Eats
- **Planning modifiable** : Thomas peut ajuster = contrôle vs dépendance aveugle IA
- **Mode accessibilité** : Marie peut activer texte +30% = autonomie vs dépendance aide externe

**Design pour autonomie :**
- App suggère mais utilisateur décide (pas d'imposition)
- Tutoriels optionnels (pas obligatoires)
- Corrections faciles (swipe correction post-scan)

---

**Delight vs Satisfaction**

**Où joué :**
- **Scan magique** : Delight (émerveillement "putain c'est de la magie")
- **Dashboard régulier** : Satisfaction (validation progrès continus)
- **Planning généré** : Delight première fois, Satisfaction routine suivante

**Design pour delight :**
- Micro-interactions scan (animations fluides, confettis subtils, son optionnel)
- Surprises positives (unlock recette premium temporaire après streak)
- Pas de sur-utilisation (delight dilué si constant)

---

**Sérénité vs Anxiété**

**Où joué :**
- **Notifications timing** : Soir 18h-20h décision repas = Sérénité, 3h matin = Anxiété
- **Quiet hours** : Configurables = Sérénité contrôle, Non configurables = Anxiété intrusion
- **Dashboard positif** : Focus "sauvé" vs "gaspillé" = Sérénité vs Culpabilité/Anxiété

**Design pour sérénité :**
- Timing intelligent notifications (contextuel)
- Focus positif (accomplissements vs échecs)
- Pas de spam (fréquence adaptative)

---

**Appartenance vs Isolation**

**Où joué :**
- **Gamification sociale** : Lucas leaderboard amis = Appartenance compétitive
- **Partage TikTok** : Lucas "Comment j'économise 60€/mois" → 12K vues = Appartenance communauté
- **Opt-in** : Gamification optionnelle = Pas d'isolation forcée si pas intéressé

**Design pour appartenance :**
- Leaderboard amis opt-in (pas imposé)
- Partage social facile (screenshot dashboard stats)
- Défis communautaires (challenges inter-familles future)

### Design Implications

**Connexions directes Émotions → Décisions UX :**

**1. Émerveillement (Premier Scan) → Micro-Interactions Magiques**

**Émotion cible :** Sophie murmure "Putain c'est de la magie" après scan 127 produits en 3s.

**Implications UX :**
- **Animation compteur temps réel** : "12 produits détectés... 45... 89... 127 !"
- **Transition fluide** : Scan → Inventaire catégorisé (animation satisfaisante)
- **Confettis subtils** : Célébration visuelle succès (pas over-the-top)
- **Son optionnel** : Feedback audio satisfaisant (désactivable)
- **Haptic feedback** : Vibration subtile au succès scan
- **Fallback gracieux** : Si scan partiel → "89 produits détectés, 12 à vérifier" (pas "Échec")

---

**2. Contrôle Sans Effort → Automatisation Intelligente**

**Émotion cible :** Sophie sent qu'elle maîtrise sa vie alimentaire SANS charge mentale ajoutée.

**Implications UX :**
- **Catégorisation auto** : Zéro décision utilisateur (viande → frais, pâtes → placard)
- **Emplacements suggérés** : Yaourts → réfrigérateur (Marie n'a jamais à choisir)
- **Planning 1 clic** : Génération automatique, utilisateur peut ajuster (contrôle gardé)
- **Notifications proactives** : Pas juste "Produit expire" mais "Recette suggérée : Riz au lait 20 min [Cuisiner]"
- **Dashboard auto-calculé** : Métriques mises à jour sans action utilisateur

---

**3. Accomplissement Tangible → Métriques Concrètes**

**Émotion cible :** Marie montre dashboard à Clara "18€ économisés en 3 semaines, c'est bien" → Accomplissement moral validé.

**Implications UX :**
- **Chiffres concrets** : "8kg", "24€", "8.4kg CO2" (pas pourcentages abstraits)
- **Comparaisons tangibles** : "24€ = 2 burgers Uber Eats" (Lucas), "8kg = 1 semaine courses" (Sophie)
- **Visualisations évolution** : Graphiques courbes tendances (semaine, mois)
- **Segmentation impact** : Marie voit CO2 en avant (valeurs écolo), Sophie voit € + temps gagné
- **Célébrations milestones** : "Premier produit sauvé !", "7 jours zéro gaspi streak !"

---

**4. Confiance/Fiabilité → Offline-First + Transparence**

**Émotion cible :** Marie (zone rurale) et Sophie (parking sous-sol) : "L'app fonctionne TOUJOURS" → Confiance fiabilité.

**Implications UX :**
- **ML Kit local** : Scan fonctionne sans réseau (précision réduite acceptable)
- **Hive database** : Inventaire accessible offline
- **Sync background** : Transparente, pas de blocage brutal
- **Indicateur connexion discret** : Icône statut, pas de popup "Pas de réseau !"
- **Disclaimers clairs** : "Prix indicatifs, vérifiez en magasin" (pas de fausses promesses)
- **Correction facile** : Si OCR erreur → Suggestions contextuelles ("Pouet" → "Poulet ?")

---

**5. Autonomie Culinaire → Empowerment Progressif**

**Émotion cible :** Lucas "FrigoFute m'a appris à cuisiner sans m'en rendre compte" → Autonomie découverte.

**Implications UX :**
- **"Recettes avec ce que j'ai"** : Matching inventaire actuel → Pas besoin acheter nouveau
- **Filtres budget/temps** : Lucas filtre "Très économique + <20 min" → 12 recettes possibles
- **Tutoriels intégrés** : Pas condescendants, juste guidances simples
- **Gamification progression** : "Chef débutant → Cuistot confirmé" (valorisation apprentissage)
- **Partage social** : TikTok-friendly (Lucas poste "60€ économisés/mois" → fierté sociale)

---

**6. Sérénité Morale → Validation Valeurs**

**Émotion cible :** Marie "Aujourd'hui avec cette app, j'ai l'impression de respecter à nouveau la nourriture comme on me l'a appris" → Alignement valeurs générationnelles.

**Implications UX :**
- **Dashboard impact écologique** : kg CO2 évités EN AVANT (pas secondaire)
- **Focus positif** : "Vous avez sauvé 8kg" vs "Vous avez gaspillé 2kg"
- **Encouragement doux** : "Premier produit sauvé !" (célébration douce, pas punitive)
- **Interface senior** : Mode accessibilité (gros boutons, aide contextuelle) → Confiance tech
- **Onboarding guidé** : Clara aide Marie installer (accompagnement humain valorisé)

### Emotional Design Principles

**5 Principes Design Émotionnel (Guident Choix UX) :**

**1. "Célébrer les Victoires, Pas les Échecs"**

**Principe :** Focus émotionnel sur accomplissements positifs (produits sauvés, économies réalisées) plutôt que sur échecs/gaspillages. Marie ne doit jamais se sentir "honteuse" d'avoir gaspillé.

**Applications UX :**
- Dashboard montre "8kg sauvés" en grand, "2kg gaspillés" en petit (si affiché)
- Notifications "Produit sauvé grâce à vous !" (positif) vs "Vous avez jeté X" (négatif)
- Badges achievements anti-gaspi (pas de "shame badges" pour gaspillage)

---

**2. "Magie au Début, Fiabilité au Quotidien"**

**Principe :** Premier scan = émerveillement (delight), usage régulier = satisfaction fiable (pas de sur-stimulation). Équilibre entre wow initial et confort routine.

**Applications UX :**
- Premier scan : Animations riches, confettis, célébration
- Scans suivants : Feedback simple, efficace (pas de confettis chaque fois)
- Dashboard : Satisfaction progrès continus (graphiques évolution)
- Surprises positives occasionnelles (unlock recette premium temporaire après streak)

---

**3. "Proactif Sans Intrusion"**

**Principe :** App anticipe besoins (notifications intelligentes) SANS spam. Timing optimal, fréquence adaptative, quiet hours respectées.

**Applications UX :**
- Notifications soir 18h-20h (décision repas) ou matin 8h-9h (planning journée)
- Quiet hours configurables (pas de notifs nuit)
- Fréquence adaptative (si utilisateur ignore 3 alertes consécutives → réduire fréquence)
- Rich content actionnable (boutons "Cuisiner maintenant", pas juste texte)

---

**4. "Autonomie Guidée, Pas Dépendance Forcée"**

**Principe :** App suggère solutions intelligentes mais utilisateur garde contrôle. Lucas apprend à cuisiner (autonomie) vs dépendance aveugle app.

**Applications UX :**
- Planning IA : Génération auto mais modifiable (Thomas peut remplacer repas)
- Tutoriels : Optionnels, pas obligatoires (skip possible)
- Corrections : Faciles post-scan (swipe gauche/droite)
- Transparence IA : Expliquer pourquoi suggestion ("Utilise produits proches péremption")

---

**5. "Impact Tangible, Pas Métriques Abstraites"**

**Principe :** Chiffres concrets résonnent émotionnellement ("24€", "2 burgers Uber Eats") vs abstractions ("Réduction 15% gaspillage").

**Applications UX :**
- Dashboard : "8kg gaspillage évités" vs "Réduction 70% gaspillage"
- Comparaisons : "24€ = 2 repas restaurant" (tangible) vs "Économies 12.5%" (abstrait)
- Impact écologique : "8.4kg CO2 évités = 50km voiture non roulés" (Marie comprend)
- Temps gagné : "2h30 gagnées cette semaine" (Sophie ressent)

## UX Pattern Analysis & Inspiration

### Inspiring Products Analysis

**Apps analysées pour extraction patterns UX réussis :**

**1. MyFitnessPal - Concurrent Nutrition (Référence Thomas)**

**Forces UX :**
- Base de données massive produits alimentaires (millions références)
- Tracking macro précis (Protéines/Glucides/Lipides détaillés)
- Dashboard nutrition circulaire (graphiques macros visuels)
- Historique quotidien/hebdomadaire/mensuel

**Faiblesses UX (Opportunités FrigoFute) :**
- Saisie manuelle pénible (Thomas 5 min logging par repas)
- Déconnecté réalité inventaire (pas de lien frigo)
- Pas d'auto-logging (pas de scan photo repas)
- Workflow laborieux (chercher → sélectionner → quantité → valider)

**Patterns adoptés :**
- Dashboard nutrition circulaire macros
- Historique nutritionnel multi-périodes
- Affichage précis calories + macros

**Améliorations FrigoFute :**
- Auto-logging Gemini Vision (photo repas vs saisie manuelle)
- Connexion inventaire → Suggestions recettes contextuelles

---

**2. Duolingo - Maître Gamification & Engagement (Inspiration Lucas)**

**Forces UX :**
- Streaks visuels forts (flamme jours consécutifs = engagement addictif)
- Achievements progressifs (badges Bronze → Argent → Or)
- Dashboard progression clair (XP, niveau, graphiques)
- Objectifs quotidiens simples ("10 min/jour" atteignable)
- Leaderboard amis opt-in (compétition amicale)

**Patterns transférables FrigoFute :**
- Streaks zéro gaspi ("7 jours consécutifs sans produit périmé")
- Achievements milestones ("Premier produit sauvé", "10kg évités", "Économe Pro 50€")
- Leaderboard amis (Lucas invite colocs + Théo compétition)
- Objectifs quotidiens ("Scanne tes courses aujourd'hui")

**Adaptations nécessaires :**
- Pas de pression excessive (Marie senior ne doit pas stresser streaks)
- Opt-in total gamification (pas imposé)
- Esthétique mature (pas cartoon enfantin pour Thomas 29 ans, Sophie 38 ans)

---

**3. Google Lens - Excellence Scan Visuel (Inspiration Scan Ticket)**

**Forces UX :**
- Scan instantané (<1s reconnaissance visuelle)
- Auto-détection cadrage (bordures vertes si objet bien cadré)
- Guidances visuelles temps réel ("Approchez-vous", "Stabilisez")
- Feedback progressif (animation scanning pendant traitement)
- Fallback gracieux (reconnaissance partielle → suggestions multiples)

**Patterns transférables FrigoFute :**
- Cadre auto-détection ticket (bordures vertes si bien positionné)
- Guidances temps réel ("Éclairage insuffisant", "Ticket trop éloigné")
- Animation scanning (effet visuel pendant OCR 2-3s)
- Compteur progressif ("12 produits détectés... 45... 89... 127 !")

**Adaptations nécessaires :**
- Dual-engine (Google Vision online + ML Kit offline fiabilité)
- Correction post-scan (Google Lens ne corrige pas, FrigoFute swipe validation)

---

**4. Headspace - Sérénité & Notifications Intelligentes (Inspiration Marie)**

**Forces UX :**
- Design serein (couleurs douces, animations fluides, pas de stress)
- Notifications timing optimal (reminders matin 8h ou soir 20h, pas 3h matin)
- Métriques impact émotionnel ("7 jours méditation = -15% stress" tangible)
- Quiet hours automatiques (pas de notifs nuit)
- Micro-animations satisfaisantes (confettis subtils, pas over-the-top)

**Patterns transférables FrigoFute :**
- Timing notifications intelligent (soir 18h-20h décision repas, matin 8h-9h planning)
- Quiet hours configurables (Marie 22h-7h)
- Dashboard impact positif ("8kg sauvés, 24€ économisés" focus accomplissements)
- Design apaisant (couleurs vertes éco-responsabilité, animations douces)

**Adaptations nécessaires :**
- Contexte food (notifs "Produit expire" + recette actionnable vs Headspace "Médite" passif)
- Segmentation design (Lucas moderne/TikTok, Marie serein/simple)

---

**5. Yuka - Scan Code-Barres Nutrition Simplifié (Concurrent Français)**

**Forces UX :**
- Scan code-barres ultra-rapide (<1s feedback immédiat)
- Notation visuelle simple (Vert/Orange/Rouge - Marie comprend)
- Détails optionnels (info nutritionnelle accessible mais pas imposée)
- Offline partiel (cache local produits scannés récemment)

**Patterns transférables FrigoFute :**
- Scan code-barres rapide (<500ms NFR-P4)
- Feedback visuel immédiat (produit détecté → nom + catégorie)
- Cache local OpenFoodFacts (produits récents offline 7j TTL)

**Différences FrigoFute :**
- Dual-mode scan (Yuka codes-barres uniquement, FrigoFute codes-barres + OCR tickets)
- Contexte inventaire (Yuka évalue nutrition magasin, FrigoFute gère inventaire maison long-terme)

---

**6. Notion - Organisation Sans Effort (Inspiration Planning Sophie)**

**Forces UX :**
- Templates intelligents (modèles pré-configurés meal plan, calendrier)
- Suggestions contextuelles (Notion AI suggère contenu basé contexte)
- Modification facile (drag & drop, édition inline fluide)
- Sync multi-devices (desktop, mobile, tablet seamless)

**Patterns transférables FrigoFute :**
- Planning auto-généré (template planning semaine pré-rempli recettes IA)
- Modification inline (Sophie remplace repas Jour 3 en 1 tap drag new recipe)
- Sync multi-devices (Sophie iPad, mari iPhone)

**Adaptations nécessaires :**
- Simplicité FrigoFute (Notion complexe power users, FrigoFute 1 clic génération Sophie pas le temps)
- IA food-aware (Gemini génère planning basé inventaire actuel, Notion AI générique)

### Transferable UX Patterns

**Navigation Patterns :**

**1. Bottom Navigation Bar (Material Design 3 / iOS Tabs)**

**Source :** Standard mobile iOS/Android (Instagram, Spotify, Duolingo)

**Application FrigoFute :**
- 5 tabs principaux : **Inventaire**, **Scan**, **Recettes**, **Planning** (premium), **Profil**
- Tab central = **Scan** (action core accessible rapidement)
- Badge notifications sur tab Inventaire (produits proches péremption)

**Justification :**
- Navigation familière (muscle memory utilisateurs)
- Action core (scan) accessible 1 tap
- Marie (senior) comprend immédiatement (pattern standard universel)

---

**2. Swipe Gestures Actions Rapides**

**Source :** Gmail (swipe archive/delete), Tinder (swipe like/dislike)

**Application FrigoFute :**
- Post-scan validation : Liste produits détectés, swipe droite = confirmer, swipe gauche = supprimer
- Inventaire : Swipe droite produit = marquer consommé, swipe gauche = supprimer
- Notifications : Swipe action boutons ("Cuisiner", "Marquer consommé")

**Justification :**
- Rapide (validation 15 produits 30s vs 5 min tap un par un)
- Satisfaisant (feedback haptic, animation fluide)
- Lucas (Gen Z) habitué (Tinder, Instagram stories)

---

**Interaction Patterns :**

**1. Pull-to-Refresh (Inventaire Sync)**

**Source :** Twitter, Instagram, apps sociales

**Application FrigoFute :**
- Pull-to-refresh inventaire → force sync cloud (si offline changes)
- Animation satisfaisante (spinner ou custom animation)

**Justification :**
- Pattern universel (muscle memory)
- Contrôle utilisateur (force sync si doute)

---

**2. Progressive Disclosure (Détails Produits)**

**Source :** Notion (collapsible sections), Apple Settings

**Application FrigoFute :**
- Inventaire list view : Nom produit + catégorie + date péremption (compact)
- Tap produit → Expand détails (nutrition OpenFoodFacts, emplacement, quantité, historique)

**Justification :**
- Simplicité par défaut (Marie pas submergée)
- Profondeur optionnelle (Thomas accède détails si besoin)

---

**3. Smart Suggestions Contextuelles**

**Source :** Google Maps (suggestions destinations), Spotify (playlists suggestions)

**Application FrigoFute :**
- Notifications recettes : "Poulet expire dans 2j → Recette suggérée : Poulet rôti 20min"
- Planning IA : Suggère recettes utilisant produits proches péremption prioritairement
- Liste courses : Déduit automatiquement ce qui manque (vs inventaire actuel)

**Justification :**
- Proactif (app anticipe besoins)
- Réduit décisions utilisateur (Sophie charge mentale libérée)

---

**Visual Patterns :**

**1. Dashboard Circulaire Macros (MyFitnessPal Style)**

**Source :** MyFitnessPal, Fitbit, Apple Health

**Application FrigoFute :**
- Dashboard nutrition : Graphique circulaire Protéines/Glucides/Lipides
- Barres progression calories jour (2850 kcal objectif Thomas)

**Justification :**
- Visuel immédiat (Thomas voit balance macros 1 coup d'œil)
- Pattern familier (déjà utilisé MyFitnessPal)

---

**2. Streaks Visuels (Duolingo Flamme)**

**Source :** Duolingo (flamme), Snapchat (streaks amis)

**Application FrigoFute :**
- Gamification : Icône flamme "7 jours zéro gaspi"
- Dashboard : "Streak actuel : 14 jours sans gaspillage 🔥"

**Justification :**
- Engagement addictif (Lucas compétitif)
- Validation visuelle (Marie fierté morale)

---

**3. Cartes Material Design (Inventaire Items)**

**Source :** Google Material Design, apps Android modernes

**Application FrigoFute :**
- Inventaire list : Chaque produit = carte (elevation subtile, shadow)
- Badges statut (Frais/À consommer/Périmé) couleur-codés (vert/orange/rouge)

**Justification :**
- Hiérarchie visuelle claire
- Accessibilité couleur (Marie distingue facilement statuts)

### Anti-Patterns to Avoid

**1. Dark Patterns Freemium (ÉVITER ABSOLUMENT)**

**Exemples négatifs :**
- Compte à rebours factice "Offre expire dans 3h !" (répété chaque jour)
- Pré-sélection abonnement annuel caché (checkout piège)
- Bouton "Rester gratuit" invisible vs "S'abonner" énorme rouge
- Popup paywall après 2 jours (avant valeur perçue)

**Pourquoi éviter :**
- Illégal RGPD + Loi Hamon (pratiques commerciales déloyales)
- Réputation destroyed (Lucas poste TikTok "App arnaque" → viral négatif)
- Churn massif (utilisateurs sentent manipulation → désinstallation)

**FrigoFute fait l'inverse (transparent) :**
- Tableau comparatif clair Gratuit/Premium
- Bouton "Rester gratuit" aussi visible que "Essayer premium"
- Essai 7j sans CB (friction réduite)
- Trigger premium contextuel (quand valeur évidente : inventaire riche → "Générer planning ?")

---

**2. Onboarding Questionnaire Interminable (ÉVITER)**

**Exemples négatifs :**
- 15 écrans questions avant accéder app (abandon 80%)
- Formulaires longs (nom, prénom, âge, poids, taille, objectifs, préférences, allergies, budget...)
- Pas de skip (utilisateur forcé compléter)

**Pourquoi éviter :**
- Abandon avant "aha moment" (Marie senior abandonne écran 5 "trop compliqué")
- Friction excessive (Lucas veut scanner ticket MAINTENANT, pas répondre 20 questions)

**FrigoFute fait l'inverse (minimal) :**
- 5 écrans max onboarding (90 secondes)
- Profil 1 tap : Choix visuel (icône famille, sportif, senior, étudiant)
- Skip possible ("Passer" visible, configuration plus tard)
- Progressive profiling (questions avancées au fur et à mesure, pas tout upfront)

---

**3. Notifications Spam Non-Configurables (ÉVITER)**

**Exemples négatifs :**
- Notifications 3h du matin (Marie réveillée → désactive tout)
- Fréquence excessive (5 notifs/jour → fatigue)
- Pas de quiet hours configurables
- Notifications marketing agressives ("Abonne-toi premium MAINTENANT !")

**Pourquoi éviter :**
- Désactivation totale (Marie désactive notifs → perd valeur core alertes péremption)
- Intrusion perçue (Sophie stressée vs apaisée)

**FrigoFute fait l'inverse (intelligent) :**
- Timing optimal (soir 18h-20h décision repas, matin 8h-9h planning journée)
- Quiet hours configurables (Marie 22h-7h)
- Fréquence adaptative (si utilisateur ignore 3 alertes consécutives → réduire fréquence)
- Actionabilité (notifications riches boutons "Cuisiner", "Marquer consommé" vs texte passif)

---

**4. Dashboard Métriques Abstraites (ÉVITER)**

**Exemples négatifs :**
- "Réduction 15% gaspillage" (abstrait, Marie comprend pas impact)
- Pourcentages sans contexte ("Économies +12.5%")
- Graphiques complexes (courbes multiples, axes incompréhensibles)

**Pourquoi éviter :**
- Valeur non perçue (Sophie voit chiffres mais ressent rien)
- Désengagement (dashboard incompréhensible → jamais consulté)

**FrigoFute fait l'inverse (tangible) :**
- Chiffres concrets ("8kg gaspillage évités" pas "Réduction 70%")
- Comparaisons tangibles ("24€ = 2 burgers Uber Eats" Lucas ressent)
- Visualisations simples (graphiques évolution clairs, courbe unique tendance semaine)

### Design Inspiration Strategy

**Stratégie d'utilisation des patterns inspirants :**

**Ce qu'on Adopte (Best Practices Prouvées) :**

**1. Scan Visuel Excellence (Google Lens)**
- Cadre auto-détection temps réel
- Guidances visuelles ("Éclairage", "Distance")
- Compteur progressif ("45... 89... 127 produits !")
- **Justification :** Core action FrigoFute = scan ticket magique (principe "Scan First, Everything Flows")

**2. Gamification Engageante (Duolingo)**
- Streaks visuels (flamme jours consécutifs)
- Achievements progressifs (badges milestones)
- Leaderboard amis opt-in
- **Justification :** Engagement Lucas (étudiant compétitif), validation Marie (senior fierté morale)

**3. Notifications Intelligentes (Headspace)**
- Timing optimal (18h-20h décision repas)
- Quiet hours configurables
- Rich content actionnable
- **Justification :** Principe design émotionnel "Proactif Sans Intrusion"

**4. Dashboard Tangible (MyFitnessPal + adaptations)**
- Graphiques circulaires macros (Thomas)
- Métriques concrètes ("8kg", "24€") vs pourcentages abstraits
- Comparaisons tangibles ("= 2 burgers Uber Eats")
- **Justification :** Principe design émotionnel "Impact Tangible, Pas Métriques Abstraites"

---

**Ce qu'on Adapte (Patterns Modifiés) :**

**1. Swipe Gestures (Gmail/Tinder) → Validation Post-Scan**
- **Original :** Gmail swipe archive/delete emails
- **Adapté FrigoFute :** Swipe droite/gauche validation produits post-scan OCR
- **Modification :** Contexte food (produits) vs emails, correction suggérée contextuelle ("Pouet" → "Poulet ?")
- **Justification :** Rapidité validation (30s pour 15 produits vs 5 min tap un par un)

**2. Progressive Disclosure (Notion) → Détails Produits**
- **Original :** Notion collapsible sections complexes
- **Adapté FrigoFute :** Liste inventaire compacte, tap expand détails nutrition
- **Modification :** Simplicité senior (Marie) vs complexité Notion power users
- **Justification :** Principe "Multi-Gen Accessible" (Marie pas submergée, Thomas accède détails si besoin)

**3. Planning Templates (Notion) → Génération IA 1 Clic**
- **Original :** Notion templates manuels (utilisateur remplit)
- **Adapté FrigoFute :** Template auto-rempli par IA (Gemini génère 7 repas)
- **Modification :** Automatisation totale vs semi-manuelle Notion
- **Justification :** Principe "Contrôle Sans Effort" (Sophie 2h gagnées vs planning manuel)

---

**Ce qu'on Évite (Anti-Patterns) :**

**1. Dark Patterns Freemium**
- **Conflit avec :** Principe émotionnel "Confiance/Fiabilité" + conformité RGPD
- **Remplacement :** Freemium transparent, trigger contextuel naturel

**2. Onboarding Questionnaire Long**
- **Conflit avec :** Core Experience "Aha moment <2 min" (scan ticket magique)
- **Remplacement :** Onboarding 5 écrans max, profil 1 tap, progressive profiling

**3. Notifications Spam**
- **Conflit avec :** Principe émotionnel "Proactif Sans Intrusion"
- **Remplacement :** Timing intelligent, quiet hours, fréquence adaptative

**4. Dashboard Métriques Abstraites**
- **Conflit avec :** Principe émotionnel "Impact Tangible, Pas Métriques Abstraites"
- **Remplacement :** Chiffres concrets, comparaisons tangibles

---

**Synthèse Stratégique :**

Cette stratégie d'inspiration nous permet de :
- ✅ **S'appuyer sur patterns prouvés** (muscle memory utilisateurs, courbe apprentissage réduite)
- ✅ **Différencier FrigoFute** (adaptations contexte food, IA générative, offline-first)
- ✅ **Éviter erreurs communes** (anti-patterns identifiés concurrents)
- ✅ **Aligner patterns avec principes émotionnels** (cohérence design)

## Design System Foundation

### Design System Choice

**Choix : Material Design 3 + iOS Adaptations (Hybrid Approach)**

**Foundation primaire :** Material Design 3 (Material You) via Flutter 3.32 widgets natifs

**Adaptations plateforme :**
- **Android** : Material Design 3 pur (Material widgets Flutter natifs)
- **iOS** : Material Design 3 avec adaptations iOS Human Interface Guidelines (navigation top bar Cupertino, gestures iOS natives, transitions iOS-style)

**Composants Foundation :**
- **Material Design 3 Component Library** : 50+ widgets Flutter natifs
- **Cupertino Widgets sélectifs** : Navigation, date pickers, context menus iOS
- **Flutter Adaptive Widgets** : Material 3 s'adapte automatiquement contexte iOS

### Rationale for Selection

**1. Alignement PRD Technique** : NFR-U4 spécifie "Material Design 3 (Android) et Human Interface Guidelines (iOS)"

**2. Rapidité Développement** : 50+ widgets prêts → Gain 6-8 semaines vs custom design system

**3. Accessibilité Built-In** : WCAG 2.1 compliance automatique (contraste, touch targets 48dp, screen readers)

**4. Multi-Génération Familiarité** : Marie/Sophie/Thomas/Lucas tous reconnaissent patterns Material (Gmail, Google Maps)

**5. Design Tokens Unifiés** : Color System, Typography Scale, Spacing 8dp grid, Elevation standardisés

**6. Performance Mobile** : Widgets natifs optimisés 60fps, cold start <3s respecté

### Implementation Approach

**Phase 1 : Foundation Setup** - Material Design 3 theme configuration, platform-adaptive navigation

**Phase 2 : Component Library** - Scaffold, Cards, Buttons, Navigation, Dialogs Material Design 3

**Phase 3 : Custom Components** - Scan camera overlay, dashboard charts, swipe actions, streaks gamification, rich notifications

### Customization Strategy

**Philosophie : "Customize, Don't Rebuild"**

**Brand Colors** : Seed #4CAF50 (vert éco-responsabilité) → Palette Primary/Secondary/Tertiary/Error générée

**Typography** : Material Type Scale + Mode Senior (+30% texte activable Settings)

**Spacing** : 8dp grid Material (4dp, 8dp, 16dp, 24dp, 32dp), touch targets ≥48dp

**Elevation** : 0-6dp Material Design 3 (hiérarchie visuelle moderne)

**Animations** : Material Motion + Custom (scan success confettis, swipe validation, streaks flame)

**Résultat** : 80% Material natif + 15% theming + 5% custom components = Rapidité + Cohérence + Accessibilité + Familiarité

## Expérience Utilisateur Approfondie

### User Mental Model

**Modèles Mentaux Actuels (Avant FrigoFute) :**

**1. Gestion Frigo Traditionnelle = Système Mental Imparfait**

Les utilisateurs opèrent aujourd'hui avec un **modèle mental fragmenté et défaillant** :

- **Mémoire volatile** : "Je crois avoir du lait... ou pas ?" → Incertitude permanente
- **Inspection visuelle répétitive** : Ouvrir frigo 3-5x/jour pour "vérifier"
- **Liste courses mentale** : Oublis systématiques (40% courses non planifiées = achats impulsifs)
- **Culpabilité post-gaspi** : "J'ai encore jeté des yaourts..." → Sentiment échec personnel

**Métaphore mentale dominante :** Le frigo est une **"boîte noire"** - on y met des choses, on ne sait plus ce qu'il contient, on redécouvre régulièrement produits périmés.

**2. Tentatives Actuelles de Contrôle**

Les utilisateurs développent des **stratégies compensatoires chronophages** :

- **Sophie (famille)** : Post-it magnétiques sur frigo + planning papier hebdo → 45 min/semaine organisation manuelle
- **Thomas (sportif)** : Excel macros + photos frigo + MyFitnessPal → 1h30 dimanche batch cooking
- **Marie (senior)** : Cahier manuscrit "entrées-sorties" produits → Abandon après 2 semaines (trop fastidieux)
- **Lucas (étudiant)** : Chaos total → Commandes Uber Eats récurrentes (budget explosé)

**Frustration commune :** Tous savent qu'un système existe (inventaire, planning) mais l'**effort requis > bénéfice perçu** → Abandon

**3. FrigoFute Change le Modèle Mental**

**Nouveau paradigme : "Frigo Transparent Intelligent"**

FrigoFute transforme le modèle mental vers une **visualisation continue automatisée** :

- **De "Qu'est-ce que j'ai ?" → "Voici ce que tu as"** (inventaire temps réel)
- **De "Qu'est-ce que je cuisine ?" → "Voici 12 recettes possibles"** (suggestions contextuelles)
- **De "Ça va périr ?" → "Ça expire aujourd'hui, cuisine ça"** (notifications proactives)
- **De "Combien je gaspille ?" → "8 kg évités, 24€ économisés"** (métriques tangibles)

**Analogie puissante que les utilisateurs adoptent :**
- "FrigoFute est comme **Google Maps pour mon frigo**" (Thomas)
  - Avant : Conduire sans GPS (mémoire imparfaite, detours, perdu)
  - Après : Navigation guidée (visibilité totale, guidances temps réel, destination optimale)

**Impact Psychologique :**
- **Charge cognitive réduite** : Frigo n'est plus un "problème mental permanent"
- **Contrôle perçu** : Utilisateur sent qu'il maîtrise (même si app fait le travail)
- **Accomplissement tangible** : Dashboard transforme effort invisible en progrès mesurable

**4. Friction Mentale à Surmonter (Onboarding Critique)**

**Barrières psychologiques initiales :**

- **Marie (senior)** : "C'est trop compliqué pour moi" → Besoin rassurance (tutoriel Clara petite-fille)
- **Sophie (famille)** : "Pas le temps d'apprendre nouvelle app" → Besoin aha immédiat (<2 min premier scan)
- **Thomas (sportif)** : "Encore une app qui promet..." → Besoin preuves (précision OCR, macros exactes)
- **Lucas (étudiant)** : "Si c'est pas fun, j'abandonne" → Besoin gamification (badges, leaderboard)

**Stratégie UX pour transformation mentale :**

1. **Onboarding = Démonstration, pas Formation**
   - Montrer valeur en 90 secondes (scan ticket magique)
   - Pas de tutoriel long, juste 3 écrans visuels guidés

2. **Premier Scan = Conversion Mentale**
   - Sophie voit 127 produits classés en 3s → "C'est impossible... mais ça marche !"
   - Cerveau passe de scepticisme → émerveillement → adoption

3. **Première Semaine = Validation Modèle**
   - Dashboard montre impact tangible (8kg évités) → Ancien modèle mental (chaos) vs nouveau (contrôle) comparés
   - Utilisateur ne peut plus revenir en arrière (comme GPS : personne ne retourne aux cartes papier)

### Success Criteria - Core Experience

**Critères de Succès pour l'Interaction Core (Scan Ticket) :**

**Métriques Techniques :**

1. **Performance Scan**
   - ✅ < 3 secondes pour 100+ produits (95e percentile)
   - ✅ Précision OCR ≥ 80% (produits correctement détectés)
   - ✅ Taux succès scan ≥ 85% (scan complète sans erreur totale)
   - ✅ Cold start app < 3s (utilisateur ne doit pas attendre)

2. **Fiabilité**
   - ✅ Fonctionne offline (ML Kit local fallback)
   - ✅ Parse tickets 4 enseignes françaises majeures (Carrefour, Leclerc, Lidl, Auchan)
   - ✅ Gestion erreurs gracieuse (correction facile si reconnaissance partielle)

**Métriques Comportementales :**

3. **Adoption Premier Scan**
   - ✅ ≥ 70% nouveaux utilisateurs scannent ticket dans premières 24h
   - ✅ ≥ 90% complètent onboarding jusqu'au scan (pas d'abandon avant)
   - ✅ Temps moyen premier scan < 5 min (installation → premier scan réussi)

4. **Rétention Post-Scan**
   - ✅ Day 7 retention ≥ 40% (utilisateurs revenus après 1 semaine)
   - ✅ ≥ 60% utilisateurs scannent 2+ tickets premier mois (habitude installée)
   - ✅ Taux désinstallation < 20% première semaine (satisfaction initiale)

**Métriques Qualitatives :**

5. **Perception Utilisateur** (via surveys post-scan)
   - ✅ ≥ 80% disent "c'était plus rapide que prévu"
   - ✅ ≥ 70% utilisent adjectif "magique" / "impressionnant" / "wow"
   - ✅ ≥ 60% recommandent app à proche dans 48h (Net Promoter Score social)
   - ✅ Store reviews mentionnent "scan" dans ≥ 50% commentaires positifs

**Indicateurs d'Échec (Signaux Alerte) :**

❌ Taux abandon onboarding > 40% (friction pré-scan)
❌ Durée moyenne scan > 10s (frustration attente)
❌ Taux re-tentative scan > 30% (premier scan échoue trop souvent)
❌ Mentions "scan ne fonctionne pas" dans reviews ≥ 10%

### Novel vs. Established UX Patterns

**Analyse Pattern Innovation FrigoFute :**

**PATTERNS NOVATEURS (Nécessitent Éducation Utilisateur) :**

**1. Scan Ticket OCR Ultra-Rapide = Innovation Core**

**Niveau Innovation :** 🌟🌟🌟🌟 (Très Novateur)

**Pourquoi novateur :**
- Pas de précédent mainstream en France (apps scan code-barres existent, mais pas tickets entiers)
- Utilisateurs habités à scanner **1 produit à la fois** (Yuka, MyFitnessPal)
- FrigoFute scanne **100+ produits simultanément** → Saut quantitatif perçu comme magique

**Éducation requise :**
- **Tutoriel premier scan** : 3 écrans visuels montrant éclairage optimal, angle ticket, distance caméra
- **Guidances temps réel** : Bordures vertes quand ticket bien cadré (feedback immédiat)
- **Métaphore familière** : "Comme scanner QR code, mais pour tout le ticket" (ancrage mental)

**Risque :**
- Si scan rate → Confusion ("Pourquoi ça marche pas ?")
- **Mitigation** : Fallback ajout manuel simple + tutoriel ré-accessible

**2. Planning IA Génératif Contextuel**

**Niveau Innovation :** 🌟🌟🌟 (Novateur)

**Pourquoi novateur :**
- IA générative (Gemini) crée planning **unique basé inventaire actuel**
- Pas de templates génériques, chaque planning est personnalisé
- Utilisateurs pas habitués à "IA qui cuisine pour moi"

**Éducation requise :**
- **Démonstration valeur** : Essai gratuit 7 jours (expérience directe)
- **Transparence IA** : Montrer comment IA utilise inventaire + profil nutrition
- **Contrôle utilisateur** : Possibilité ajuster contraintes (temps prépa, batch cooking)

**Analogie adoptée :** "ChatGPT pour mes repas" (Thomas comprend immédiatement)

**3. Dashboard Impact Tangible (Gamification Anti-Gaspi)**

**Niveau Innovation :** 🌟🌟 (Modérément Novateur)

**Pourquoi novateur :**
- Transformer comportement écolo (gaspillage) en **jeu avec métriques**
- Leaderboard social opt-in (compétition amicale)
- Badges achievements (débloquer "Zéro Gaspi 7 jours")

**Modèle existant :** Duolingo streaks, Strava segments
- Utilisateurs comprennent pattern (surtout Lucas Gen Z)
- **Twist** : Application à alimentation (pas fitness/langues)

**PATTERNS ÉTABLIS (Exploitent Familiarité) :**

**1. Notifications Push Contextuelles**

**Niveau Familiarité :** ⭐⭐⭐⭐ (Très Familier)

**Pattern connu :**
- Tous les utilisateurs reçoivent notifications quotidiennes (social media, news, etc.)
- Modèle mental : "App me prévient quand action requise"

**Innovation FrigoFute :**
- **Timing intelligent** (soir décision repas, pas 3h matin)
- **Actions directes** (boutons "Cuisiner maintenant", "Marquer consommé")
- **Rich content** (image recette, temps prépa, ingrédients dispo)

**Avantage :** Aucune éducation requise, pattern universellement compris

**2. Inventaire CRUD (Create, Read, Update, Delete)**

**Niveau Familiarité :** ⭐⭐⭐⭐⭐ (Universel)

**Pattern connu :**
- Listes (todolist apps, notes, contacts)
- Ajouter / Éditer / Supprimer = interaction basique toutes apps

**Innovation FrigoFute :**
- Catégorisation automatique (pas de "choisir catégorie")
- Statuts auto-gérés (frais → bientôt périmé → périmé)
- Emplacements suggérés (yaourts → réfrigérateur)

**3. Dashboard Métriques**

**Niveau Familiarité :** ⭐⭐⭐⭐ (Très Familier)

**Pattern connu :**
- Fitness apps (steps, calories), finance apps (budget, dépenses)
- Graphiques évolution = pattern établi iOS Health, Android Fit

**Innovation FrigoFute :**
- **Comparaisons tangibles** : "24€ = 2 burgers Uber Eats" (Lucas comprend immédiatement)
- **Triple impact** : Santé + Économie + Écologie visualisés simultanément
- **Segmentation** : Marie voit CO2, Sophie voit €+temps, Thomas voit macros

**STRATÉGIE PATTERN MIX (80/20) :**

**Principe Design :** **"Innovate on One, Familiarize on Rest"**

- **80% Patterns Établis** → Réduire charge cognitive, adoption rapide
  - Navigation (bottom nav Material Design 3 / iOS tabs)
  - Inputs (forms, switches, sliders standards)
  - Gestures (tap, swipe horizontal, pas de gestures complexes)

- **20% Innovation** → Différenciation compétitive
  - **Scan OCR ultra-rapide** (core differentiator)
  - **Planning IA génératif** (premium wow factor)
  - **Gamification anti-gaspi** (engagement long-terme)

**Allocation Budget UX/UI :**
- **50% effort design** → Perfectionner scan (animations, feedback, tutoriel)
- **30% effort design** → Dashboard impact (visualisations, comparaisons tangibles)
- **20% effort design** → Reste app (patterns standards Material/iOS)

### Experience Mechanics - Détails Techniques

**Mécaniques Détaillées de l'Interaction Core (Scan Ticket) :**

**1. INITIATION (Comment Utilisateur Démarre)**

**Triggers Scan :**

**A. Onboarding (Premier Scan) :**
- Écran 5 onboarding : **"Scannez votre premier ticket pour voir la magie"**
- Bouton CTA proéminent : **"Scanner Ticket Maintenant"** (couleur accent #4CAF50)
- Shortcut visuel : Icône caméra avec badge "1" (indicate première action)

**B. Utilisation Courante (Post-Onboarding) :**
- **Bottom nav** : Icône caméra centrale (position pouce, accès rapide)
- **FAB (Floating Action Button)** : Bouton "+" écran inventaire → menu actions dont "Scanner Ticket"
- **Notification push** : "Retour courses ? Scannez votre ticket !" (envoyée 18h-20h mardi/jeudi/samedi)

**Affordances Visuelles :**
- Icône caméra **universellement comprise** (pas besoin label)
- Animation subtile (pulse effet) premier lancement (invite attention)

**2. INTERACTION (Ce Que Utilisateur Fait Exactement)**

**Étape 1 : Lancement Caméra (< 1s)**

- Tap icône caméra → Transition fluide vers mode scan
- Permission caméra (iOS/Android) : Prompt système standard
  - **Si refusée** : Écran explication "FrigoFute a besoin de la caméra pour scanner" + bouton "Autoriser dans Réglages"
  - **Si accordée** : Caméra s'ouvre immédiatement

**Étape 2 : Cadrage Ticket (2-5s utilisateur)**

**Interface Scan :**
- Header discret : [X] Fermer et [?] Aide
- Zone détection auto avec cadre ticket (OpenCV détecte contours)
- Bordures vertes si bien cadré, rouges si problème
- Instruction simple : "Placez ticket dans cadre"
- Checklist temps réel : ✓ Bon éclairage / ⚠ Rapprochez-vous
- Bouton capture : [📸 Scanner]

**Guidances Temps Réel (ML Kit détection) :**
- **Bordures cadre** : Vertes si ticket bien détecté, rouges si problème
- **Messages contextuels** :
  - ✓ "Parfait ! Tapez Scanner"
  - ⚠ "Trop sombre, déplacez-vous près lumière"
  - ⚠ "Ticket plié, aplatissez-le"
  - ⚠ "Rapprochez-vous" ou "Éloignez-vous"

**Étape 3 : Capture (1 tap)**

- Utilisateur tape bouton **"Scanner"**
- **Feedback haptique** (vibration subtile iOS/Android)
- **Freeze frame** : Image capturée affichée 0.5s (confirmation visuelle)
- **Transition** : Slide up vers écran processing

**3. FEEDBACK (Comment Utilisateur Sait Que Ça Marche)**

**Phase Processing (2-3s) :**

**Écran Processing :**
- Icône animée (rotation) : 🔍 Analyse en cours...
- Progress bar animée : 45% → 78% → 100%
- Compteur temps réel incrémental :
  - "12 produits détectés..."
  - "45 produits détectés..."
  - "89 produits détectés..."
  - "127 produits détectés !" (exclamation finale)
- Bouton [Annuler]

**Mécaniques Feedback :**

1. **Progress Bar Animée** (45% → 78% → 100%)
   - Donne impression vitesse (même si backend async)
   - Animation fluide 60fps

2. **Compteur Produits Incrémental**
   - Incrémente visuellement pour montrer progression
   - Exclamation finale pour célébration

3. **Sounds (Optionnels, Désactivables) :**
   - **Détection produit** : Subtle "ding" chaque groupe 10 produits
   - **Succès final** : Son satisfaisant (iOS/Android haptic feedback)

**4. COMPLETION (Comment Utilisateur Sait Qu'il A Fini)**

**A. Succès Scan ≥ 80% Précision**

**Écran Succès :**
- ✅ Scan Terminé !
- 🎉 127 produits ajoutés (célébration visuelle)
- Liste preview scrollable (5 premiers produits) :
  - ✓ Lait demi-écrémé
  - ✓ Poulet fermier
  - ✓ Yaourts nature
  - ⚠ Puoelt (?) - produit confiance faible
  - ✓ Pâtes complètes
- ⚠ 4 produits nécessitent vérification
- Choix : [Valider Tout] [Vérifier]

**Options Post-Scan :**

1. **"Valider Tout"** → Accepter tous produits détectés (même ceux confiance faible)
   - Utilisateur pressé (Sophie après courses)
   - **Friction minimale** (1 tap → inventaire complet)

2. **"Vérifier"** → Mode validation rapide
   - Liste swipeable : Swipe droite = confirmer, swipe gauche = supprimer
   - Produits "confiance faible" (⚠️) affichés en premier
   - Corrections suggérées si OCR douteux ("Puoelt" → Suggère "Poulet")
   - **Temps moyen** : 30s pour valider 15 produits douteux

**B. Échec Scan < 60% Précision**

**Écran Échec (Gracieux) :**
- ⚠️ Scan Incomplet
- 8 produits détectés (ticket difficile à lire)
- 💡 Conseils :
  - Meilleur éclairage
  - Aplatir ticket
  - Ticket récent (encre lisible)
- Choix : [Réessayer] [Ajouter Manuellement]

**Fallbacks Échec :**
- **Réessayer** : Retour caméra avec conseils affichés
- **Ajout Manuel** : Liste produits détectés (même partiel) + possibilité ajouter manuellement manquants
  - **Principe** : Même scan raté = meilleur que 0 (8 produits auto vs 127 manuels)

**C. Transition Finale → Inventaire**

**Animation Succès :**
- **Confettis subtils** (animation Material Motion 0.8s)
- **Transition slide** : Liste produits → Écran inventaire complet
- **Toast notification** : "127 produits ajoutés à votre inventaire !"

**État Inventaire Mis à Jour :**
- Badge notification sur icône inventaire : "127 nouveaux"
- Produits récents affichés en haut (tri par date ajout)
- Catégorisation automatique déjà appliquée (viande → frais, pâtes → placard)

## Visual Design Foundation

### Color System

**Philosophie Couleur : "Éco-Responsabilité Moderne"**

La palette couleur FrigoFuteV2 communique visuellement le triple impact (santé + économie + écologie) tout en respectant les standards Material Design 3 et l'accessibilité WCAG 2.1 Level A.

**Color Seed & Palette Génération**

**Seed Color :** #4CAF50 (Green 500 - Material Design)
- **Signification symbolique** : Fraîcheur alimentaire, éco-responsabilité, santé, croissance positive
- **Résonance émotionnelle** : Espoir, contrôle, accomplissement (aligné avec "Contrôle Sans Effort")

**Palette Primary (Génération Material Design 3 Dynamic Color) :**

```
Primary Palette (Vert Éco-Responsabilité)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Light Theme:
  Primary:           #4CAF50  (Green 500)
  On Primary:        #FFFFFF  (White - contraste 4.8:1 ✓)
  Primary Container: #C8E6C9  (Green 100)
  On Primary Container: #1B5E20  (Green 900)

Dark Theme:
  Primary:           #81C784  (Green 300)
  On Primary:        #1B5E20  (Green 900 - contraste 5.2:1 ✓)
  Primary Container: #388E3C  (Green 700)
  On Primary Container: #C8E6C9  (Green 100)
```

**Palette Secondary (Complément Fonctionnel) :**

```
Secondary Palette (Orange Vitalité Nutrition)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Seed: #FF9800 (Orange 500 - Énergie alimentaire)

Light Theme:
  Secondary:         #FF9800  (Orange 500)
  On Secondary:      #000000  (Black - contraste 5.1:1 ✓)
  Secondary Container: #FFE0B2  (Orange 100)
  On Secondary Container: #E65100  (Orange 900)

Dark Theme:
  Secondary:         #FFB74D  (Orange 300)
  On Secondary:      #E65100  (Orange 900)
  Secondary Container: #F57C00  (Orange 700)
  On Secondary Container: #FFE0B2  (Orange 100)
```

**Palette Tertiary (Accent Gamification) :**

```
Tertiary Palette (Bleu Intelligence/Tech)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Seed: #2196F3 (Blue 500 - Tech moderne, IA)

Light Theme:
  Tertiary:          #2196F3  (Blue 500)
  On Tertiary:       #FFFFFF  (White - contraste 4.6:1 ✓)
  Tertiary Container: #BBDEFB  (Blue 100)
  On Tertiary Container: #0D47A1  (Blue 900)

Dark Theme:
  Tertiary:          #64B5F6  (Blue 300)
  On Tertiary:       #0D47A1  (Blue 900)
  Tertiary Container: #1976D2  (Blue 700)
  On Tertiary Container: #BBDEFB  (Blue 100)
```

**Couleurs Sémantiques (États & Feedback) :**

```
Success (Action Positive - Produit Sauvé)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Success:           #4CAF50  (Vert Primary - cohérence)
  On Success:        #FFFFFF
  Success Container: #C8E6C9

Error (Alerte Péremption Critique)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Error:             #F44336  (Red 500)
  On Error:          #FFFFFF  (contraste 5.4:1 ✓)
  Error Container:   #FFCDD2  (Red 100)

Warning (Expire Bientôt - 2 jours)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Warning:           #FF9800  (Orange Secondary)
  On Warning:        #000000  (contraste 5.1:1 ✓)
  Warning Container: #FFE0B2

Info (Conseils, Tutoriels)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Info:              #2196F3  (Blue Tertiary)
  On Info:           #FFFFFF  (contraste 4.6:1 ✓)
  Info Container:    #BBDEFB
```

**Surface Colors (Backgrounds, Cards, Dialogs) :**

```
Light Theme Surfaces
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Surface:           #FFFFFF  (White)
  Surface Variant:   #F5F5F5  (Grey 50 - subtle contrast)
  On Surface:        #212121  (Grey 900 - contraste 16.1:1 ✓✓)
  On Surface Variant: #757575  (Grey 600 - texte secondaire)
  Background:        #FAFAFA  (Grey 50)
  On Background:     #212121  (Grey 900)

Dark Theme Surfaces
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Surface:           #1E1E1E  (Material Dark Surface)
  Surface Variant:   #2C2C2C  (Subtle elevation)
  On Surface:        #E0E0E0  (Grey 300 - contraste 12.6:1 ✓)
  On Surface Variant: #9E9E9E  (Grey 500)
  Background:        #121212  (Material Dark Background)
  On Background:     #E0E0E0  (Grey 300)
```

**Color Usage Guidelines (Règles Application) :**

**1. Primary Green (#4CAF50) :**
- CTAs principales (boutons "Scanner Ticket", "Générer Planning")
- Badge notifications (nouveaux produits)
- Icônes succès (produit sauvé, objectif atteint)
- Progress bars (scan en cours)
- Streaks gamification (flamme verte)

**2. Secondary Orange (#FF9800) :**
- Alertes péremption modérées (expire dans 2-3 jours)
- Icônes nutrition (calories, macros)
- Badges premium (fonctionnalités payantes)
- Accents chaleur (recettes, cuisine)

**3. Tertiary Blue (#2196F3) :**
- Icônes IA (planning générateur, coach nutrition)
- Links interactifs
- Informations techniques (tutoriels, aide)
- Badges achievements tech (débloquer fonctionnalité)

**4. Accessibility Compliance :**
- ✅ Contraste minimum 4.5:1 texte standard (WCAG AA)
- ✅ Contraste minimum 3:1 texte large (WCAG AA)
- ✅ Mode Senior : Contraste augmenté automatiquement 7:1 (WCAG AAA)
- ✅ Dark mode : Tous contrastes re-validés (surfaces ajustées)

### Typography System

**Philosophie Typographique : "Clarté Universelle Multi-Génération"**

Le système typographique FrigoFuteV2 équilibre modernité esthétique (Lucas Gen Z) et lisibilité seniors (Marie 67 ans) via Material Type Scale adaptatif.

**Font Families**

**Primary : Roboto (Material Design Default)**

**Justification :**
- Pré-installée Android (99.9% devices) → Performance optimale
- Excellente lisibilité écrans mobiles (conçue Google pour Android)
- Large gamme weights (Thin, Light, Regular, Medium, Bold, Black)
- Support Unicode complet (accents français, émojis nutrition)
- Familiarité universelle (utilisée apps Google : Maps, Gmail, Drive)

**Variants :**
- Roboto Regular (400) : Body text, labels, inputs
- Roboto Medium (500) : Buttons, subtitles, emphasis
- Roboto Bold (700) : Headings, CTAs, alerts

**Secondary : Roboto Condensed (Écrans Densité Informations)**

**Usage spécifique :**
- Dashboard métriques (chiffres compacts : "127 produits")
- Tableaux nutritionnels (macros, calories)
- Liste courses compacte (maximiser produits visibles)

**iOS Adaptive : San Francisco (iOS Platform Font)**

**Implementation :**
```dart
// Flutter adaptive font
fontFamily: Platform.isIOS ? 'SF Pro Text' : 'Roboto'
```

**Justification :**
- Cohérence native iOS (familiarité utilisateurs iPhone)
- Optimisation rendering iOS (smooth anti-aliasing)
- Respect Human Interface Guidelines (NFR-U4)

**Material Type Scale (Base Standard)**

```
Display Large
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Regular (400)
Size:       57sp / 4rem
Line Height: 64sp / 4.5rem
Letter Spacing: -0.25px
Usage:      Écrans onboarding (rarissime mobile)

Display Medium
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Regular (400)
Size:       45sp / 3.125rem
Line Height: 52sp / 3.625rem
Usage:      Onboarding headlines ("Scannez votre premier ticket")

Display Small
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Regular (400)
Size:       36sp / 2.5rem
Line Height: 44sp / 3rem
Usage:      Dashboard métriques principales ("8 kg évités")

Headline Large (H1)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Bold (700)
Size:       32sp / 2.25rem
Line Height: 40sp / 2.75rem
Usage:      Titres écrans ("Inventaire", "Recettes", "Dashboard")

Headline Medium (H2)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Medium (500)
Size:       28sp / 1.95rem
Line Height: 36sp / 2.5rem
Usage:      Sections ("Produits Frais", "Expire Aujourd'hui")

Headline Small (H3)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Medium (500)
Size:       24sp / 1.675rem
Line Height: 32sp / 2.25rem
Usage:      Sous-sections ("Catégories", "Statistiques Semaine")

Title Large
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Medium (500)
Size:       22sp / 1.5rem
Line Height: 28sp / 1.95rem
Usage:      Dialog headers, card titles

Title Medium
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Medium (500)
Size:       16sp / 1.125rem
Line Height: 24sp / 1.675rem
Letter Spacing: 0.15px
Usage:      List item titles ("Lait demi-écrémé 1L")

Title Small
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Medium (500)
Size:       14sp / 0.975rem
Line Height: 20sp / 1.4rem
Letter Spacing: 0.1px
Usage:      Subtitles, small headers

Body Large
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Regular (400)
Size:       16sp / 1.125rem
Line Height: 24sp / 1.675rem
Letter Spacing: 0.5px
Usage:      Body text principal (descriptions recettes)

Body Medium (Default Body)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Regular (400)
Size:       14sp / 0.975rem
Line Height: 20sp / 1.4rem
Letter Spacing: 0.25px
Usage:      Body text standard (instructions, paragraphes)

Body Small
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Regular (400)
Size:       12sp / 0.84rem
Line Height: 16sp / 1.125rem
Letter Spacing: 0.4px
Usage:      Captions, timestamps ("Ajouté il y a 2h")

Label Large
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Medium (500)
Size:       14sp / 0.975rem
Line Height: 20sp / 1.4rem
Letter Spacing: 0.1px
Usage:      Button text, tabs, chips

Label Medium
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Medium (500)
Size:       12sp / 0.84rem
Line Height: 16sp / 1.125rem
Letter Spacing: 0.5px
Usage:      Small buttons, input labels

Label Small
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Font:       Roboto Medium (500)
Size:       11sp / 0.77rem
Line Height: 16sp / 1.125rem
Letter Spacing: 0.5px
Usage:      Badges, tags ("Premium", "Nouveau")
```

**Mode Senior Typography (+30% Scale)**

**Activation :** Settings > Accessibilité > "Mode Senior" toggle

**Scale Multiplier :** 1.3x toutes tailles

**Exemples Transformation :**
```
Body Medium (Standard): 14sp → 18.2sp (~18sp)
Title Large (Standard):  22sp → 28.6sp (~29sp)
Headline Large (Standard): 32sp → 41.6sp (~42sp)
```

**Ligne Height Proportionnelle :** Automatiquement ajustée (ratio 1.4-1.5 maintenu)

**Touch Targets Agrandis :** Minimum 56dp (vs 48dp standard) pour Marie

**Typography Usage Guidelines**

**Hiérarchie Visuelle (Importance Information) :**

1. **Critical Info (Headline Large 32sp Bold)** : "127 produits ajoutés !", "Expire Aujourd'hui"
2. **Important Info (Title Large 22sp Medium)** : Noms produits, recettes
3. **Standard Info (Body Medium 14sp Regular)** : Descriptions, instructions
4. **Secondary Info (Body Small 12sp Regular)** : Timestamps, metadata

**Contraste Typographique (Emphasis) :**

- **Primary Text** : On Surface (#212121 light / #E0E0E0 dark) - alpha 87%
- **Secondary Text** : On Surface Variant (#757575 light / #9E9E9E dark) - alpha 60%
- **Disabled Text** : On Surface - alpha 38%
- **Hint Text** : On Surface - alpha 38% (placeholders inputs)

**Line Length (Lisibilité Optimale) :**

- **Paragraphes** : Max 60-80 caractères/ligne (16sp body)
- **Listes produits** : 1 ligne par item (truncate avec "..." si >40 chars)
- **Recettes** : Max 600px width conteneur (confort lecture)

### Spacing & Layout Foundation

**Philosophie Spacing : "8dp Grid Modulaire"**

FrigoFuteV2 utilise le système 8dp (density-independent pixels) Material Design pour cohérence mathématique et alignement parfait multi-devices.

**Base Spacing Unit : 8dp**

**Rationale :**
- Divisible par 2 (16dp, 24dp, 32dp)
- Compatible résolutions courantes (mdpi, hdpi, xhdpi, xxhdpi)
- Balance densité info (écrans mobiles 5-6") et respiration visuelle
- Standard Material Design (familiarité développeurs + designers)

**Spacing Scale (Système Modulaire)**

```
Spacing Scale FrigoFuteV2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Token        Value   Usage
──────────────────────────────────────
xxs          4dp     Icon padding, badge offset
xs           8dp     Tight spacing, list item internal
sm           12dp    Compact components (chips gap)
md (base)    16dp    Standard spacing (cards, buttons)
lg           24dp    Section spacing, card margins
xl           32dp    Screen margins, major sections
xxl          48dp    Empty states, onboarding screens
xxxl         64dp    Hero sections (rare mobile)
```

**Component-Specific Spacing**

**1. Touch Targets (Accessibilité Critique)**

```
Minimum Touch Target
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Standard:    48dp × 48dp (Material guideline)
Senior Mode: 56dp × 56dp (Marie facilité)

Exemples:
  - Buttons (primary): 48dp height
  - List items: 48dp minimum height
  - Icons tappables: 48dp × 48dp zone (icon 24dp + padding 12dp)
  - Bottom nav icons: 56dp × 56dp (pouce accès)
```

**2. Screen Margins & Padding**

```
Screen Layout Margins
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Horizontal margins (left/right): 16dp
Top safe area (status bar): System insets + 8dp
Bottom safe area (nav bar): System insets + 8dp

Content padding (within containers):
  Cards internal: 16dp all sides
  Dialogs: 24dp all sides
  Bottom sheets: 16dp horizontal, 24dp vertical
```

**3. Vertical Rhythm (Entre Composants)**

```
Component Vertical Spacing
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Between list items:        0dp (dividers 1dp)
Between cards:             16dp
Between sections:          24dp
Between major blocks:      32dp
Above/below headers (H2):  16dp top, 8dp bottom
Paragraph spacing:         12dp
```

**4. Horizontal Rhythm (Inline Elements)**

```
Inline Spacing
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Icon + Text gap:           8dp
Button icon + label:       8dp
Chips gap (tags):          8dp
Badge + text:              4dp
Avatar + text:             12dp
```

**Layout Grid System**

**Mobile Layout (Portrait 360-428dp width)**

```
Grid Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Columns:          4 columns (mobile)
Gutter:           16dp (between columns)
Margin:           16dp (left/right screen edges)

Column width (360dp phone):
  (360dp - 2×16dp margins - 3×16dp gutters) / 4
  = 64dp per column

Usage:
  - Full width content: 4 columns (cards, lists)
  - Half width content: 2 columns (dashboard metrics 2×2)
  - Third width: N/A (4 cols indivisible par 3)
  - Quarter width: 1 column (small icons, badges)
```

**Tablet Layout (600dp+ width) - Future**

```
Tablet Grid (Landscape)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Columns:          8 columns
Gutter:           24dp
Margin:           24dp

Usage:
  - Main content: 6 columns (center)
  - Sidebar: 2 columns (navigation)
```

**Elevation System (Material Design 3)**

```
Elevation Levels (Shadow Depth)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Level 0 (0dp):    Backgrounds, surfaces
Level 1 (1dp):    Cards at rest, app bar
Level 2 (3dp):    Cards raised (hover - desktop only)
Level 3 (6dp):    Dialogs, bottom sheets
Level 4 (8dp):    Navigation drawer
Level 5 (12dp):   Floating Action Button (FAB)
Level 6 (16dp):   Modal overlays, snackbars

Usage FrigoFuteV2:
  - Inventaire cards: 1dp
  - Scan camera overlay: 0dp (fullscreen)
  - Dialogs confirmation: 6dp
  - Bottom nav: 8dp (toujours visible)
  - FAB "Scanner": 12dp (proéminence)
  - Notifications toast: 16dp (attention)
```

**Layout Patterns Par Écran Type**

**1. List Screens (Inventaire, Recettes)**

```
Vertical Layout
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
┌────────────────────────────────┐
│ App Bar (56dp height)          │ ← Header sticky
├────────────────────────────────┤
│ ┌────┬─────────────────────┐  │ ← List item
│ │Icon│ Title               │  │   48dp min height
│ │24dp│ Subtitle            │  │   16dp margins
│ └────┴─────────────────────┘  │   8dp icon-text gap
│                  ↕ 0dp         │   0dp between items
│ ┌────┬─────────────────────┐  │   1dp divider
│ │Icon│ Title               │  │
│ │24dp│ Subtitle            │  │
│ └────┴─────────────────────┘  │
├────────────────────────────────┤
│ Bottom Nav (56dp height)       │ ← Navigation sticky
└────────────────────────────────┘
```

**2. Dashboard (Métriques Grid)**

```
Grid Layout 2×2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
┌────────────────────────────────┐
│ Dashboard                      │ ← Header 32dp title
│                ↕ 16dp          │
│ ┌────────┐  ┌────────┐        │ ← Metric cards
│ │ 8 kg   │  │ 24€    │        │   2 columns
│ │ évités │  │ économ.│        │   16dp gap horizontal
│ └────────┘  └────────┘        │   16dp gap vertical
│                ↕ 16dp          │   16dp padding internal
│ ┌────────┐  ┌────────┐        │
│ │ 127    │  │ 3.2kg  │        │
│ │produits│  │ CO2    │        │
│ └────────┘  └────────┘        │
└────────────────────────────────┘
```

**3. Forms & Inputs**

```
Form Layout
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Label (12sp)
  ↕ 4dp
┌──────────────────────────────┐
│ Input field                  │ ← 48dp height
│ Placeholder text             │   16dp horizontal padding
└──────────────────────────────┘
  ↕ 4dp
Helper text / Error (12sp)
  ↕ 16dp (next field)
```

### Accessibility Considerations

**WCAG 2.1 Level A Compliance (PRD Requirement)**

**1. Color Contrast**

**Text Contrasts :**
- ✅ Normal text (< 18sp) : Minimum 4.5:1 (WCAG AA)
- ✅ Large text (≥ 18sp ou 14sp Bold) : Minimum 3:1 (WCAG AA)
- ✅ Mode Senior : Contraste augmenté 7:1 (WCAG AAA)

**Validations Palette :**
```
Light Theme Validations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Primary (#4CAF50) / White:     4.8:1 ✓ (WCAG AA)
On Surface (#212121) / White:  16.1:1 ✓✓ (WCAG AAA)
Error (#F44336) / White:       5.4:1 ✓ (WCAG AA)
Warning (#FF9800) / Black:     5.1:1 ✓ (WCAG AA)

Dark Theme Validations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Primary (#81C784) / Dark:      5.2:1 ✓ (WCAG AA)
On Surface (#E0E0E0) / Dark:   12.6:1 ✓✓ (WCAG AAA)
```

**2. Non-Color Indicators**

**Principe** : Ne jamais utiliser couleur SEULE pour transmettre information critique

**Applications :**
- ❌ **Mauvais** : Produit expire = texte rouge seulement
- ✅ **Bon** : Produit expire = texte rouge + icône ⚠️ + label "Expire aujourd'hui"

**Exemples :**
```
Statut Produit (Multi-Modal)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Frais:          Couleur Green + Icône ✓ + Label "Frais"
Expire Bientôt: Couleur Orange + Icône ⚠️ + Label "2 jours"
Expiré:         Couleur Red + Icône ❌ + Label "Expiré"
```

**3. Touch Target Sizes**

**Standard :** 48dp × 48dp minimum (Material guideline)
**Senior Mode :** 56dp × 56dp (Marie accessibilité)

**Spacing Entre Targets :** Minimum 8dp gap (éviter taps accidentels)

**4. Screen Reader Support (TalkBack Android / VoiceOver iOS)**

**Semantic Labels :**
```dart
// Exemple Flutter
IconButton(
  icon: Icon(Icons.camera),
  tooltip: 'Scanner ticket de caisse',
  semanticLabel: 'Ouvrir caméra pour scanner ticket',
  onPressed: () => scanTicket(),
)
```

**Navigation Ordre Logique :** Top → Bottom, Left → Right (lecture naturelle française)

**5. Text Scaling (Dynamic Type iOS / Font Scale Android)**

**Support :** 100% - 200% user-defined scale
- Material widgets Flutter supportent nativement
- Layouts flexibles (pas de heights fixes)
- Texte wrapping automatique (multiline labels)

**Test Cases :**
- 100% (default) : Layout standard
- 130% (Marie senior mode) : Buttons + spacing agrandis
- 200% (extreme accessibility) : Single column, large touch targets

**6. Animations & Motion (Accessibility Settings)**

**Respect Preferences Système :**
```dart
// Flutter - Reduce Motion
final bool reduceMotion = MediaQuery.of(context).disableAnimations;

if (reduceMotion) {
  // Instant transitions (no animations)
} else {
  // Smooth Material Motion animations
}
```

**Applications :**
- Scan confettis animation : Skippable si reduce motion
- Dashboard charts : Instant draw vs animated
- Page transitions : Crossfade simple vs slide elaborate

**7. Dark Mode (Préférence Système)**

**Auto-Détection :**
```dart
final brightness = MediaQuery.of(context).platformBrightness;
final bool isDarkMode = (brightness == Brightness.dark);
```

**Avantages Accessibilité :**
- Réduit fatigue oculaire (usage nocturne)
- Meilleur contraste certaines conditions (photophobie)
- Économie batterie OLED (noir absolu)

## Design Direction Decision

### Design Directions Explored

**Approche de Sélection :**

Pour FrigoFuteV2, nous avons exploré plusieurs directions visuelles en nous basant sur les contraintes et objectifs établis : application mobile anti-gaspillage alimentaire multi-générationnelle avec Material Design 3 comme fondation.

**Directions Évaluées :**

**Direction 1 : "Material Pure" - Minimalisme Technique**
- Strict Material Design 3 sans customisation
- Palette monochrome (greys + primary green minimal)
- Densité information élevée (compact lists, small padding)
- Navigation bottom bar standard
- **Avantages :** Familiarité immédiate, performance maximale, développement rapide
- **Inconvénients :** Manque personnalité brand, pas assez chaleureux pour alimentation

**Direction 2 : "Éco-Friendly Organic" - Chaleur Naturelle**
- Rounded corners exagérés (24dp border-radius cards)
- Illustrations custom produits (hand-drawn style)
- Palette étendue verts + terre (browns, beiges)
- Animations organiques (bouncy, playful)
- **Avantages :** Différenciation forte, warmth émo-responsabilité
- **Inconvénients :** Surcharge visuelle, complexité animations, coût illustrations

**Direction 3 : "Data Dashboard" - Analytics-First**
- Focus métriques et graphiques (dashboard-centric)
- Typographie condensée (Roboto Condensed primary)
- Couleurs data viz (multiples teintes graphiques)
- Layout multi-colonnes dense
- **Avantages :** Clarté impact quantitatif, power users (Thomas sportif)
- **Inconvénients :** Intimidant seniors (Marie), manque simplicité

**Direction 4 : "Gamification Fun" - Ludique Engagement**
- Couleurs saturées multiples (badges, achievements proéminents)
- Animations celebration exagérées (confettis, fireworks)
- Mascotte frigo anthropomorphe
- Leaderboards toujours visibles
- **Avantages :** Engagement Gen Z (Lucas), retention long-terme
- **Inconvénients :** Trivialise sujet sérieux (gaspillage écolo), fatigue visuelle

**Direction 5 : "Balanced Hybrid" - Équilibre Multi-Gen ⭐ (CHOISIE)**
- Material Design 3 base + customisations ciblées (20% custom)
- Palette triadique équilibrée (Green primary + Orange secondary + Blue tertiary)
- Illustrations sélectives (onboarding, empty states uniquement)
- Animations subtiles Material Motion + micro-interactions scan
- Navigation adaptative (bottom bar + gestures)
- Densité modulaire (mode senior toggle)
- **Avantages :** Balance familiarité/personnalité, accessibilité multi-gen, scalable
- **Inconvénients :** Nécessite fine-tuning animations

**Direction 6 : "iOS-First Cupertino" - Simplicité Apple**
- Human Interface Guidelines strict (iOS design language)
- Navigation top bar (iOS style)
- Typography SF Pro (iOS native)
- Couleurs pastels douces
- **Avantages :** Cohérence iOS parfaite, élégance minimaliste
- **Inconvénients :** Incohérence Android (NFR-U4 exige Material Design 3)

### Chosen Direction

**Direction Retenue : "Balanced Hybrid" (Direction 5)**

Cette direction équilibre optimalement familiarité universelle, personnalité brand, accessibilité multi-génération, performance technique et développement rapide via Material Design 3 Foundation + Strategic Customizations (80% Material natif + 15% theming + 5% custom components).

## User Journey Flows

### Journey 1 : Premier Scan Ticket (Onboarding Critical)

**Objectif :** Nouveau utilisateur scanne son premier ticket et découvre la valeur core (automatisation inventaire)

**Success Criteria :** Scan réussi ≥80% produits, inventaire créé, aha moment atteint

**Flow Principal :** Onboarding (5 écrans) → Permissions caméra → Premier scan → Processing (compteur incrémental) → Succès (confettis) → Validation produits → Inventaire catégorisé

**Moments Clés :**
- Anxiété (Écran 5/5) → Mitigation : Tutoriel visuel 3 écrans
- Incertitude (Cadrage) → Mitigation : Bordures vertes feedback immédiat
- Attente (Processing) → Mitigation : Compteur incrémental montre activité
- Wow (Succès) → Amplification : Confettis + "127 produits ajoutés !"
- Validation (Inventaire) → Confirmation : Catégories color-coded automatiques

### Journey 2 : Notification Péremption → Action Directe

**Objectif :** Utilisateur reçoit alerte produit expire → Action immédiate (cuisiner ou marquer consommé)

**Success Criteria :** Notification tap → Recette → Cuisine → Produit sauvé (zéro gaspi)

**Flow Principal :** Background monitoring DLC → Trigger notification (timing intelligent 18h-20h) → Rich notification (image recette + actions) → Tap "Cuisiner" → Écran recette (ingrédients check) → Suivi recette → Marquer consommé → Dashboard mis à jour (+1 produit sauvé)

**Moments Clés :**
- Attention (Notification) → Hook : Image recette appétissante
- Décision (Cuisiner vs Marquer) → Facilitation : Temps prépa visible (20 min)
- Confiance (Liste Ingrédients) → Rassurance : Checkmarks verts inventaire
- Accomplissement (Fini) → Validation : Toast "Bravo, Zéro Gaspi!" + dashboard

### Journey 3 : Génération Planning Semaine IA (Premium Conversion)

**Objectif :** Utilisateur gratuit découvre premium (planning IA) → Essai 7j → Conversion payante

**Success Criteria :** Planning généré → Gain 1h30 vs manuel → Conversion 4.99€/mois

**Flow Principal :** Dashboard dimanche soir → Trigger contextuel (inventaire ≥20 produits) → Modal essai 7j sans CB → Configuration (4 questions : macros, temps, batch cooking) → Génération IA 30s → Planning 7 dîners + liste courses → Validation semaine → Jour 6 : Modal fin essai → Tableau comparatif gratuit/premium → Paiement Stripe → Premium activé

**Moments Clés :**
- Découverte (Banner) → Trigger : Inventaire riche = contexte pertinent
- Hésitation (Modal) → Rassurance : Essai 7j sans CB (zéro risque)
- Configuration → Customization : Macros sportif, batch cooking
- Wow (30s) → Différenciation : "30s vs 1h30 manuel !"
- Validation (Semaine) → Preuve : Dashboard temps gagné tangible
- Décision (Fin essai) → Transparence : Bouton "Rester gratuit" aussi visible

### Journey Patterns (Transversaux)

**1. Progressive Disclosure Pattern**
- Principe : Information nécessaire à chaque étape uniquement
- Applications : Onboarding 5 écrans séquentiels, notification titre+image puis détails, planning 4 questions séquentielles

**2. Immediate Feedback Pattern**
- Principe : Feedback instantané aux actions (pas d'attente silencieuse)
- Applications : Bordures vertes cadrage <0.5s, compteur produits incrémental, progress "Génération 7 dîners..."

**3. Contextual Triggers Pattern**
- Principe : Actions proposées QUAND contexte pertinent (pas spam)
- Applications : Notification 18h-20h (décision repas), premium trigger SI inventaire ≥20, rappel unique 2h puis stop

**4. Guided Recovery Pattern**
- Principe : Échecs offrent toujours chemin alternatif (jamais blocage)
- Applications : Scan échec → "Réessayer" OU "Ajout manuel", permission refusée → explication + bouton réglages, produits douteux → validation swipe 30s

**5. Celebration Moments Pattern**
- Principe : Amplifier succès avec micro-célébrations
- Applications : Confettis premier scan, toast "Bravo Zéro Gaspi!", "Bienvenue Premium!" + unlock modules

### Flow Optimization Principles

**1. "2-Minute Rule"** - Valeur perçue <2 min première interaction (premier scan <2 min installation → wow)

**2. "One-Tap Actions"** - Actions critiques 1-tap (notification → recette, FAB scan thumb zone, swipe mark consumed)

**3. "Smart Defaults"** - App fonctionne sans configuration obligatoire (profil suggéré, catégorisation auto, timing optimal défaut)

**4. "Graceful Degradation"** - Features core offline (scan ML Kit local 75%, inventaire Hive), features avancées online OK (planning IA Gemini)

**5. "Progressive Trust"** - Permissions demandées quand nécessaires (caméra écran 5/5, notifications après premier scan, localisation module prix)

**6. "Transparent Pricing"** - Freemium éthique anti-dark patterns ("Rester gratuit" aussi visible, essai sans CB, tableau comparatif clair, pas compte rebours factice)

## Component Strategy

### Design System Components (Material Design 3 - 80%)

**Navigation & Structure :** Scaffold, AppBar, BottomNavigationBar, NavigationRail, Drawer

**Content & Display :** Card, ListTile, Chip, Divider, DataTable

**Inputs & Controls :** TextField, Checkbox, Radio, Switch, Slider, DropdownMenu

**Actions :** FilledButton, OutlinedButton, TextButton, IconButton, FloatingActionButton

**Feedback :** Dialog, SnackBar, BottomSheet, CircularProgressIndicator, LinearProgressIndicator

**Couverture :** ~95% besoins UI standards satisfaits nativement Material Design 3

### Custom Components (5% Spécifiques FrigoFuteV2)

**1. ProductCard** - Card inventaire avec statut péremption multi-modal (couleur + icône + texte), swipe actions (consumed/delete), variants standard/compact/senior

**2. MetricCard** - Dashboard metrics avec animation count-up (0 → value 1.5s), trend indicator (↗ green, ↘ red), contexte tangible ("= 2 repas resto")

**3. ScanCameraOverlay** - Interface scan avec guidances temps réel (borders vertes si OK, rouges si problème), checklist dynamique (éclairage, distance), OpenCV détection contours 30fps

**4. ScanProcessingScreen** - Feedback OCR processing avec progress bar animée + compteur produits incrémental (12 → 89 → 127), status text contextuel

**5. ScanSuccessOverlay** - Confettis celebration (80 particles, 0.8s duration, Material Motion physics), colors primary/secondary/tertiary, respect reduce motion

**6. StatusBadge** - Indicateur statut accessible (Fresh ✓, Expiring ⚠️, Expired ❌, Premium ⭐), always icon + text, WCAG AA contrast

### Component Implementation Strategy

**Approche "Material First, Custom Minimal" :**

**1. Maximiser Material 3 (80%)** - Performance optimisée (widgets built-in GPU rendering), maintenance réduite (Google updates), accessibilité native, documentation extensive

**2. Custom Justifiés (5%)** - Critères : pas d'équivalent Material, valeur différenciante core (scan signature UX), impossible via theming uniquement

**3. Design Tokens Unifiés (15%)** - Tous customs utilisent mêmes tokens Material (colors ColorScheme, spacing 8dp grid, border-radius 12dp, elevation levels) pour cohérence visuelle

**4. Accessibilité Built-In** - Semantic labels (screen readers), touch targets ≥48dp (56dp senior), color + icon + text (multi-modal), keyboard navigation, contrast WCAG AA (AAA senior)

### Implementation Roadmap

**Phase 1 : Core Journey (Semaines 3-4)** - ScanCameraOverlay (3j), ScanProcessingScreen (1j), ScanSuccessOverlay (2j), ProductCard (2j) = 8 jours

**Phase 2 : Dashboard (Semaines 5-6)** - MetricCard (2j), StatusBadge (0.5j) = 2.5 jours

**Phase 3 : Enhancement (Semaines 7-8)** - Swipe actions enhanced (1j), Empty states illustrations (1j) = 2 jours

**Total Effort :** 12.5 jours (~2.5 semaines) développement components custom, validation continue (code review accessibility/performance, user testing scan flow, A/B testing confettis impact)

## UX Consistency Patterns

### Button Hierarchy & Actions

**Principe :** Maximum 3 niveaux par écran (primaire > secondaire > tertiaire)

**Primary (FilledButton)** - Background #4CAF50, 1 seul par écran, action principale ("Scanner Ticket", "Générer Planning")

**Secondary (OutlinedButton)** - Stroke 1dp #4CAF50, alternatives/annulation ("Annuler", "Modifier", "Rester Gratuit")

**Tertiary (TextButton/IconButton)** - Text #2196F3, actions mineures ("En savoir plus", "Aide", icons filtres)

**FAB** - Circle 56dp #4CAF50 elevation 12dp, action core app (scan ticket), position bottom-center docked, 1 seul app-wide

**Accessibility :** Touch targets ≥48dp (56dp senior), labels accessibles (tooltip + semanticLabel), keyboard navigation, focus indicators 2dp primary

### Feedback Patterns

**Success** - Toast #C8E6C9 green + icon ✓ (4s), Dialog ✅ ("Scan terminé ! 127 produits"), inline border 4dp green

**Error** - Toast #FFCDD2 red + icon ❌ (6s), Dialog erreur + solution ("Réessayer" / "Annuler"), inline TextField border 2dp red + helper text

**Warning** - Banner #FFE0B2 orange + icon ⚠️ sticky dismissible ("3 produits expirent aujourd'hui"), inline border 4dp orange

**Info** - Toast #BBDEFB blue + icon ℹ️ ("Astuce : swipez droite"), tooltip contextuel (long press/hover)

**Règle Accessibilité :** Jamais couleur seule, toujours icône + texte, announce screen readers

### Form Patterns & Validation

**TextField Material3 Outlined** - Height 48dp (56dp senior), border 1dp rest / 2dp primary focused / 2dp error invalid, label floating, helper text 12sp

**Validation** - Timing onBlur (pas onChange agressif), success border green + ✓, error border red + helper text + ⚠️, messages spécifiques

**Multi-Steps** - Stepper horizontal (3/5 steps), progress bar, "Précédent" secondary + "Suivant" primary, save draft state, skip optionnel

**Submit Feedback** - Loading (button disabled + spinner 16dp + "Envoi..."), success (toast + navigation), error (scroll first error + focus + shake)

### Navigation Patterns

**Bottom Navigation** - 4 destinations (Inventaire, Recettes, Dashboard, Profil), height 56dp elevation 8dp, active filled icon + pill indicator, badge notifications

**App Bar** - Top 56dp (standard) OU 112dp collapse (large), title + actions, back arrow écrans secondaires

**Drawer** - Width 280dp slide-in left, header avatar + nom, items settings/aide/logout, focus trap, swipe right close

### Modal & Overlay Patterns

**Dialog** - Elevation 6dp, border-radius 12dp, padding 24dp, icon 48dp + title + body + max 2 actions, scrim dismiss (sauf critiques)

**Bottom Sheet** - Slide up, rounded top 12dp, drag handle, swipe dismiss, list actions (edit/share/delete)

**Full-Screen** - Scan camera overlay, onboarding wizard, status bar translucent, close X top-left, minimal UI

### Empty States & Loading

**Empty States** - Icon 120dp grey, titre Headline Medium 28sp, body descriptif, CTA primary ("Scanner Ticket", "Découvrir Recettes")

**Loading** - Skeleton shimmer (preferred), CircularProgressIndicator (>3s), LinearProgressIndicator (progress défini), inline 16dp button, timeout 10s → error

### Search & Filter

**Search Bar** - TextField outlined, leading 🔍, trailing X clear, placeholder, autocomplete suggestions, instantané (300ms debounce), highlight matches

**Filters Chips** - Horizontal scrollable, active filled primary, inactive outlined grey, toggle multi-select, badge count, reset "Effacer filtres"

## Responsive Design & Accessibility

### Responsive Strategy

**Approche : Mobile-First Native (Flutter iOS/Android)**

**Mobile Native (Portrait 360-428dp) - Plateforme Primaire 100%** - Orientation portrait uniquement (lock landscape), bottom nav 56dp + FAB scan, grid 4 columns 16dp margins, density confortable 16dp base (mode senior +25%)

**Tablet (600dp+) - Future Post-MVP** - Layout "mobile agrandi" (pas desktop), grid 8 columns, NavigationRail vertical, 2-3 colonnes inventaire/dashboard, priorité basse (10% TAM)

**Desktop (1024dp+) - Non-Supporté MVP** - Scan caméra mobile-only (webcam insuffisante), future web companion lecture seule (consultation inventaire, planning, analytics)

### Breakpoint Strategy

**Flutter Adaptive Breakpoints (dp) :**
- **Mobile** : < 600dp (MVP focus)
- **Tablet** : 600-840dp (post-MVP)
- **Desktop** : > 1200dp (future web)

**Implementation** : LayoutBuilder responsive, MediaQuery device context, Platform-adaptive widgets (Cupertino iOS / Material Android), orientation locked portrait

### Accessibility Strategy

**Compliance : WCAG 2.1 Level A (Minimum PRD) + Partial AA**

**1. Color Contrast** - Normal text ≥4.5:1 (AA), large text ≥3:1 (AA), mode senior ≥7:1 (AAA opt-in), validations : Primary/White 4.8:1 ✓, On Surface/White 16.1:1 ✓✓

**2. Non-Color Indicators** - Jamais couleur seule : statut produit = couleur + icône (✓ ⚠️ ❌) + texte ("Frais", "2j", "Expiré")

**3. Keyboard Navigation** - Toutes fonctionnalités accessibles clavier (desktop future), focus order logique, skip links

**4. Touch Targets** - Standard ≥48dp × 48dp, senior mode ≥56dp × 56dp, spacing ≥8dp gap

**5. Screen Readers** - Semantic labels Flutter (VoiceOver iOS, TalkBack Android), navigation order, pronunciation française

**6. Text Scaling** - Support 100%-200% (MediaQuery textScaleFactor), mode senior 130% override, layouts flexibles no fixed heights

**7. Animations** - Respect reduce motion preference (disableAnimations), confettis/charts skip si activé

**8. Dark Mode** - Auto-detect system (ThemeMode.system), benefits : eye strain réduit, photophobia users, battery save OLED

### Testing Strategy

**Responsive Testing** - Physical devices : iPhone SE/14 Pro/15 Pro Max, Pixel 6, Galaxy A53/S24, network conditions (4G baseline, 3G degraded, offline ML Kit local)

**Accessibility Testing** - Automated : flutter analyze, contrast checkers (WebAIM), screen readers manuels (VoiceOver, TalkBack), keyboard navigation, color blindness simulation (Protanopia, Deuteranopia)

**User Testing** - Diverse participants : Marie (senior mode), Thomas (dyslexie), Lucas (daltonien), task success rate + qualitative feedback (SUS score)

### Implementation Guidelines

**Responsive** - Use relative dp units (not px), LayoutBuilder adaptive, MediaQuery device context, Platform-adaptive widgets iOS/Android

**Accessibility** - Semantic widgets (screen reader labels), ExcludeSemantics decorative, MergeSemantics groups, keyboard focus management, automated tests (semantic validation, contrast ratios, golden visual regression)
