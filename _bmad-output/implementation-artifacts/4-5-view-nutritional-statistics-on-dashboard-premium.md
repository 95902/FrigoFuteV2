# Story 4.5: View Nutritional Statistics on Dashboard (Premium)

Status: ready-for-dev

## Story

As a Thomas (sportif premium),
I want to see aggregated nutritional statistics on my dashboard,
so that I can track my dietary balance at a glance.

## Acceptance Criteria

1. **Given** I am a premium user with nutrition tracking enabled (feature flag `nutrition_tracking_enabled`)
   **When** I view the dashboard
   **Then** I see a nutrition widget displaying:
   - % de jours équilibrés cette semaine (macros dans les objectifs)
   - Calories moyennes par jour cette semaine
   - Macros moyens (protéines, glucides, lipides) cette semaine

2. **Given** I am a free user
   **When** I view the dashboard
   **Then** the nutrition widget is hidden or shows a premium teaser

3. **Given** I am premium but nutrition tracking is NOT enabled (Epic 7 Story 7.1 double opt-in)
   **Then** the widget shows a CTA: "Activer le suivi nutritionnel"

4. **Given** the nutrition widget is visible
   **When** I tap it
   **Then** I navigate to the detailed nutrition history screen (`/nutrition/history`)
   **Note**: `/nutrition/history` is implemented in Epic 7 — Story 4.5 creates the widget + route placeholder

## Tasks / Subtasks

- [ ] **T1**: Créer `NutritionSummaryWidget` avec feature flag guard (AC: 1, 2, 3)
  - [ ] Check `nutrition_tracking_enabled` via `RemoteConfigService` (Story 0.8)
  - [ ] Check premium status via `subscriptionProvider` (Epic 15 — placeholder bool pour MVP)
  - [ ] Si pas premium → `PremiumTeaserCard` (placeholder)
  - [ ] Si premium mais tracking OFF → CTA card

- [ ] **T2**: Créer `nutritionWeeklyStatsProvider` (AC: 1)
  - [ ] Lit `nutrition_logs` Hive box (sera peuplé par Epic 7)
  - [ ] Pour Story 4.5 MVP: retourne données vides / mock si box vide

- [ ] **T3**: Créer widget `NutritionStatsCard` (AC: 1, 4)
  - [ ] 3 metrics: jours équilibrés %, calories moy, macros
  - [ ] Tapable → `context.push('/nutrition/history')`

- [ ] **T4**: Ajouter route `/nutrition/history` placeholder dans GoRouter (AC: 4)

- [ ] **T5**: Intégrer `NutritionSummaryWidget` dans `DashboardScreen` (AC: 1, 2)

- [ ] **T6**: Tests widget (AC: 1, 2, 3) — mocking feature flag
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Feature Flag + Premium Guard

```dart
// lib/features/dashboard/presentation/widgets/nutrition_summary_widget.dart

class NutritionSummaryWidget extends ConsumerWidget {
  const NutritionSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNutritionEnabled = ref.watch(featureFlagProvider('nutrition_tracking_enabled'));
    // Epic 15 implémente subscriptionProvider — placeholder bool pour MVP
    final isPremium = ref.watch(isPremiumProvider);

    if (!isPremium) return const _PremiumTeaserCard();
    if (!isNutritionEnabled) return const _EnableNutritionCta();

    final stats = ref.watch(nutritionWeeklyStatsProvider);
    return stats.maybeWhen(
      data: (s) => NutritionStatsCard(stats: s),
      orElse: () => const _EnableNutritionCta(),
    );
  }
}

class _PremiumTeaserCard extends StatelessWidget {
  const _PremiumTeaserCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: const Text('Statistiques nutritionnelles'),
        subtitle: const Text('Fonctionnalité Premium — Passez à Premium pour voir vos stats'),
        trailing: FilledButton(
          onPressed: () => context.push('/settings/premium'),
          child: const Text('Premium'),
        ),
      ),
    );
  }
}

class _EnableNutritionCta extends StatelessWidget {
  const _EnableNutritionCta();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu, color: Colors.green),
        title: const Text('Suivi nutritionnel'),
        subtitle: const Text('Activez le suivi nutritionnel pour voir vos statistiques'),
        trailing: TextButton(
          onPressed: () => context.push('/nutrition/enable'),
          child: const Text('Activer'),
        ),
      ),
    );
  }
}
```

### nutritionWeeklyStatsProvider — Placeholder

```dart
// lib/features/dashboard/presentation/providers/dashboard_providers.dart

@freezed
class NutritionWeeklyStats with _$NutritionWeeklyStats {
  const factory NutritionWeeklyStats({
    required double balancedDaysPercent,  // 0.0–100.0
    required double avgDailyCalories,
    required double avgProteinG,
    required double avgCarbsG,
    required double avgFatsG,
  }) = _NutritionWeeklyStats;

  factory NutritionWeeklyStats.empty() => const NutritionWeeklyStats(
    balancedDaysPercent: 0,
    avgDailyCalories: 0,
    avgProteinG: 0,
    avgCarbsG: 0,
    avgFatsG: 0,
  );
}

// Placeholder — sera implémenté par Epic 7
final nutritionWeeklyStatsProvider = FutureProvider<NutritionWeeklyStats>((ref) async {
  // Epic 7 remplacera ceci avec la vraie implémentation
  // Pour l'instant: retourner empty (box nutrition_logs non encore peuplée)
  return NutritionWeeklyStats.empty();
});

// isPremiumProvider placeholder (Epic 15 implémentera la vraie logique)
final isPremiumProvider = Provider<bool>((_) => false);  // false = free par défaut
```

### GoRouter — Route placeholder

```dart
GoRoute(
  path: '/nutrition/history',
  builder: (_, __) => const Scaffold(
    body: Center(child: Text('Historique nutritionnel — disponible Epic 7')),
  ),
),
GoRoute(
  path: '/nutrition/enable',
  builder: (_, __) => const Scaffold(
    body: Center(child: Text('Activation suivi nutritionnel — Story 7.1')),
  ),
),
```

### Project Structure Notes

- `NutritionWeeklyStats` définie ici mais sera owned par `features/nutrition_tracking/` dans Epic 7
- `isPremiumProvider` = placeholder `false` — Epic 15 le remplacera
- `featureFlagProvider('nutrition_tracking_enabled')` utilise `RemoteConfigService` (Story 0.8)
- Feature flag default = `false` pour le contenu nutritionnel (double opt-in Epic 7)

### References

- [Source: epics.md#Story-4.5]
- Feature flag `nutrition_tracking_enabled` [Source: Story 0.8]
- PremiumFeatureGuard pattern [Source: architecture.md#Premium]
- Epic 7 (nutrition tracking) peuplera `nutritionWeeklyStatsProvider`

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
