# Story 7.6: View Disclaimer About Non-Medical Device Status

Status: ready-for-dev

## Story

As a utilisateur,
I want to understand that nutrition advice is informational and not medical,
so that I consult a healthcare professional for personalized medical advice.

## Acceptance Criteria

1. **Given** I am in the NutritionConsentScreen (Story 7.1)
   **When** the consent scroll view is displayed
   **Then** I see a prominent disclaimer banner (orange/amber) at the top stating:
   "Cette application n'est pas un dispositif médical. Les informations nutritionnelles sont indicatives et ne remplacent pas l'avis d'un professionnel de santé qualifié."

2. **Given** I am on the NutritionDashboardScreen (Story 7.3)
   **When** the dashboard is loaded
   **Then** I see a compact disclaimer chip/banner at the bottom of the screen
   **And** tapping it navigates to `/settings/nutrition-disclaimer` for the full text

3. **Given** I navigate to Privacy/Nutrition Settings
   **When** the settings screen is displayed
   **Then** I see a "Mentions légales" ListTile leading to the full disclaimer screen
   **And** the full disclaimer screen at `/settings/nutrition-disclaimer` displays the complete RGPD/medical disclaimer text

4. **Given** I view the full disclaimer screen
   **Then** I see the full legal text including:
   - Non-medical device status
   - Data usage and storage explanation
   - Recommendation to consult a doctor/dietitian
   - Contact information for data protection queries (DPO)

## Tasks / Subtasks

- [ ] **T1**: Créer `NutritionDisclaimerBanner` widget réutilisable (AC: 1, 2)
  - [ ] Version longue (`expanded: true`) pour NutritionConsentScreen
  - [ ] Version compacte (`expanded: false`) pour NutritionDashboardScreen (chip/banner tapable)
- [ ] **T2**: Créer `NutritionDisclaimerScreen` (AC: 3, 4)
  - [ ] Route `/settings/nutrition-disclaimer`
  - [ ] Texte légal complet (FR) + possibilité scroll
  - [ ] Bouton retour
- [ ] **T3**: Intégrer `NutritionDisclaimerBanner` dans `NutritionConsentScreen` (AC: 1)
  - [ ] Déjà partiellement fait en Story 7.1 — vérifier et enrichir si nécessaire
- [ ] **T4**: Intégrer bannière compacte dans `NutritionDashboardScreen` (AC: 2)
  - [ ] `InkWell` + `Chip` ou `Banner` au bas du Scaffold
  - [ ] `context.push('/settings/nutrition-disclaimer')` au tap
- [ ] **T5**: Ajouter ListTile "Mentions légales" dans `PrivacySettingsScreen` (Story 7.5) (AC: 3)
- [ ] **T6**: Ajouter route `/settings/nutrition-disclaimer` dans GoRouter (AC: 3)
- [ ] **T7**: Tests widget `NutritionDisclaimerBanner` — vérifier texte affiché (AC: 1)
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### NutritionDisclaimerBanner

```dart
// lib/features/nutrition_tracking/presentation/widgets/nutrition_disclaimer_banner.dart

class NutritionDisclaimerBanner extends StatelessWidget {
  /// expanded: true → version longue pour ConsentScreen
  /// expanded: false → bannière compacte tapable pour Dashboard
  final bool expanded;
  final VoidCallback? onTap;

  const NutritionDisclaimerBanner({
    super.key,
    this.expanded = false,
    this.onTap,
  });

  static const _shortText =
      'ℹ️ Information non médicale — Consulter un professionnel de santé';

  static const _fullText =
      'AVERTISSEMENT MÉDICAL\n\n'
      'Cette application n\'est pas un dispositif médical au sens du Règlement (UE) 2017/745. '
      'Les informations nutritionnelles fournies sont à titre indicatif uniquement et ne constituent '
      'pas un diagnostic, un traitement ou des conseils médicaux personnalisés.\n\n'
      'Elles ne remplacent en aucun cas l\'avis d\'un médecin, d\'un diététicien-nutritionniste '
      'ou de tout autre professionnel de santé qualifié. Consultez un professionnel de santé '
      'avant de modifier significativement votre alimentation, notamment en cas de pathologie '
      '(diabète, maladies cardiovasculaires, troubles du comportement alimentaire, grossesse, etc.).\n\n'
      'Vos données de santé sont traitées conformément au RGPD (Article 9) et chiffrées '
      'avec AES-256. Pour toute question relative à vos données, contactez notre DPO.';

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            border: Border.all(color: Colors.amber.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _shortText,
                  style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, size: 16, color: Colors.amber.shade800),
            ],
          ),
        ),
      );
    }

    // Version longue — ConsentScreen
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.medical_services_outlined, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Text(
              'Avertissement médical important',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
                fontSize: 16,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(
            _fullText,
            style: TextStyle(fontSize: 13, color: Colors.orange.shade900, height: 1.5),
          ),
        ],
      ),
    );
  }
}
```

### NutritionDisclaimerScreen

```dart
// lib/features/nutrition_tracking/presentation/screens/nutrition_disclaimer_screen.dart

class NutritionDisclaimerScreen extends StatelessWidget {
  const NutritionDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentions légales — Nutrition')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NutritionDisclaimerBanner(expanded: true),
            const SizedBox(height: 24),
            _Section(
              title: 'Statut réglementaire',
              content:
                'FrigoFute n\'est pas un dispositif médical au sens du Règlement (UE) 2017/745. '
                'L\'application est un outil de suivi personnel du bien-être alimentaire.',
            ),
            _Section(
              title: 'Données de santé (RGPD Art. 9)',
              content:
                'Vos données nutritionnelles sont des données de santé au sens du RGPD. '
                'Elles sont collectées avec votre consentement explicite, chiffrées avec AES-256, '
                'et stockées conformément aux exigences RGPD. Vous pouvez retirer votre '
                'consentement à tout moment depuis Paramètres > Confidentialité.',
            ),
            _Section(
              title: 'Délégué à la Protection des Données (DPO)',
              content: 'Pour toute question relative à vos données personnelles :\n'
                  'Email : dpo@frigofute.app\n'
                  'Adresse : [Adresse société]\n'
                  'CNIL n° : [Numéro d\'enregistrement]',
            ),
            _Section(
              title: 'Mise à jour',
              content: 'Cette politique a été mise à jour le 1er janvier 2026.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }
}
```

### GoRouter — Ajout route

```dart
// Ajouter dans la configuration GoRouter:
GoRoute(
  path: '/settings/nutrition-disclaimer',
  builder: (_, __) => const NutritionDisclaimerScreen(),
),
```

### Intégration dans NutritionDashboardScreen

```dart
// Ajouter au bas de Scaffold.body (après CustomScrollView):
bottomNavigationBar: Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: NutritionDisclaimerBanner(
    expanded: false,
    onTap: () => context.push('/settings/nutrition-disclaimer'),
  ),
),
```

### Project Structure Notes

- `NutritionDisclaimerBanner` est un widget réutilisable (ConsentScreen + Dashboard + DisclaimerScreen)
- La version compacte utilise un `GestureDetector` avec navigation GoRouter
- Story 7.1 utilise déjà une bannière orange — cette story formalise le composant partagé
- Texte légal en français (communication_language: fr)
- Pas de dépendance externe nouvelle

### References

- [Source: epics.md#Story-7.6]
- NutritionConsentScreen [Source: Story 7.1]
- NutritionDashboardScreen [Source: Story 7.3]
- PrivacySettingsScreen [Source: Story 7.5]
- RGPD Article 9 — données de santé [Source: architecture.md]
- Règlement (UE) 2017/745 — dispositifs médicaux [Source: prd.md]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
