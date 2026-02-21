# Story 7.8: View Aggregated Nutritional Statistics on Dashboard

Status: ready-for-dev

## Story

As a Sophie (famille),
I want to see how balanced my eating has been overall,
so that I can celebrate successes and identify areas for improvement.

## Acceptance Criteria

1. **Given** I have tracked nutrition for at least 1 day
   **When** I view the nutrition dashboard statistics section
   **Then** I see aggregated stats:
   - % of balanced days (macros within 80–110% of targets)
   - Average daily calories (this week / this month)
   - Average daily macros: protein, carbs, fats (this week / this month)

2. **Given** the statistics are displayed
   **Then** I can filter by time period: Cette semaine / Ce mois / 3 derniers mois
   **And** the stats update instantly when I change the period filter

3. **Given** I have a good percentage of balanced days (≥ 70%)
   **Then** I see an encouraging message, e.g. "80% de jours équilibrés cette semaine — Excellent !"
   **And** the message is color-coded: vert (≥70%), orange (40–69%), rouge (<40%)

4. **Given** I have fewer than 3 days of data for the selected period
   **Then** I see "Pas encore assez de données — continuez à enregistrer vos repas !"
   **And** no charts are displayed to avoid misleading statistics

## Tasks / Subtasks

- [ ] **T1**: Créer `NutritionStatsService` (AC: 1, 3)
  - [ ] `computeStats(Map<DateTime, DayNutritionLog> history, NutritionTargets targets, StatsPeriod period)` → `NutritionStats`
  - [ ] `isBalancedDay(DayNutritionLog log, NutritionTargets targets)` → bool (80–110% calories + macros)
  - [ ] `averageCalories(List<DayNutritionLog>)` → double
  - [ ] `averageMacros(List<DayNutritionLog>)` → `MacroAverages`
- [ ] **T2**: Créer `NutritionStats` entity (AC: 1)
  - [ ] `balancedDaysPercent`, `avgCalories`, `avgProteinG`, `avgCarbsG`, `avgFatsG`, `totalDays`, `period`
- [ ] **T3**: Créer `StatsPeriod` enum (AC: 2)
  - [ ] `thisWeek` (7j), `thisMonth` (30j), `last3Months` (90j)
- [ ] **T4**: Créer `nutritionStatsProvider` (AC: 1, 2)
  - [ ] `StateProvider<StatsPeriod>` pour le filtre période
  - [ ] `Provider<NutritionStats>` calculé depuis `nutritionHistoryProvider` + `nutritionTargetsProvider`
- [ ] **T5**: Créer `NutritionStatsSection` widget (AC: 1, 2, 3, 4)
  - [ ] `StatsPeriodSelector` — 3 boutons (SegmentedButton)
  - [ ] `_BalancedDaysCard` — % équilibrés + message encourageant
  - [ ] `_AverageCaloriesCard` — moyenne calories (fl_chart LineChart ou simple Text)
  - [ ] `_MacroAveragesCard` — 3 barres moyennes (protéines, glucides, lipides)
  - [ ] `_InsufficientDataCard` — si < 3 jours de données (AC: 4)
- [ ] **T6**: Intégrer `NutritionStatsSection` dans `NutritionHistoryScreen` (Story 7.4) (AC: 1)
  - [ ] Ajouter section en-dessous du calendrier mensuel
- [ ] **T7**: Tests unitaires `NutritionStatsService` (AC: 1, 3, 4)
  - [ ] `isBalancedDay` avec edge cases (0 calories, dépassement objectif)
  - [ ] `computeStats` avec données insuffisantes (< 3 jours)
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### NutritionStats + StatsPeriod

```dart
// lib/features/nutrition_tracking/domain/entities/nutrition_stats.dart

enum StatsPeriod {
  thisWeek(label: 'Cette semaine', days: 7),
  thisMonth(label: 'Ce mois', days: 30),
  last3Months(label: '3 derniers mois', days: 90);

  final String label;
  final int days;
  const StatsPeriod({required this.label, required this.days});
}

class NutritionStats {
  final double balancedDaysPercent;  // 0.0 – 100.0
  final double avgCalories;
  final double avgProteinG;
  final double avgCarbsG;
  final double avgFatsG;
  final int totalDaysWithData;
  final StatsPeriod period;

  const NutritionStats({
    required this.balancedDaysPercent,
    required this.avgCalories,
    required this.avgProteinG,
    required this.avgCarbsG,
    required this.avgFatsG,
    required this.totalDaysWithData,
    required this.period,
  });

  bool get hasEnoughData => totalDaysWithData >= 3;

  /// Message d'encouragement basé sur le % de jours équilibrés
  String get encouragementMessage {
    if (!hasEnoughData) return 'Pas encore assez de données — continuez à enregistrer vos repas !';
    if (balancedDaysPercent >= 70) return '${balancedDaysPercent.round()}% de jours équilibrés — Excellent !';
    if (balancedDaysPercent >= 40) return '${balancedDaysPercent.round()}% de jours équilibrés — Continuez !';
    return '${balancedDaysPercent.round()}% de jours équilibrés — Vous pouvez faire mieux !';
  }

  Color get encouragementColor {
    if (!hasEnoughData) return Colors.grey;
    if (balancedDaysPercent >= 70) return Colors.green;
    if (balancedDaysPercent >= 40) return Colors.orange;
    return Colors.red;
  }
}
```

### NutritionStatsService

```dart
// lib/features/nutrition_tracking/domain/services/nutrition_stats_service.dart

class NutritionStatsService {
  NutritionStats computeStats(
    Map<DateTime, DayNutritionLog> history,
    NutritionTargets targets,
    StatsPeriod period,
  ) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: period.days));

    // Filtrer les jours dans la période
    final logsInPeriod = history.entries
        .where((e) => !e.key.isBefore(cutoff))
        .map((e) => e.value)
        .toList();

    if (logsInPeriod.isEmpty) {
      return NutritionStats(
        balancedDaysPercent: 0,
        avgCalories: 0,
        avgProteinG: 0,
        avgCarbsG: 0,
        avgFatsG: 0,
        totalDaysWithData: 0,
        period: period,
      );
    }

    final balancedCount = logsInPeriod
        .where((log) => isBalancedDay(log, targets))
        .length;

    final avg = (double Function(DayNutritionLog) getter) =>
        logsInPeriod.fold(0.0, (sum, log) => sum + getter(log)) / logsInPeriod.length;

    return NutritionStats(
      balancedDaysPercent: balancedCount / logsInPeriod.length * 100,
      avgCalories: avg((l) => l.totalCalories),
      avgProteinG: avg((l) => l.totalProteinG),
      avgCarbsG: avg((l) => l.totalCarbsG),
      avgFatsG: avg((l) => l.totalFatsG),
      totalDaysWithData: logsInPeriod.length,
      period: period,
    );
  }

  /// Jour "équilibré" = calories ET macros dans 80–110% de la cible
  bool isBalancedDay(DayNutritionLog log, NutritionTargets targets) {
    bool inRange(double current, double target) {
      if (target == 0) return true;
      final ratio = current / target;
      return ratio >= 0.8 && ratio <= 1.1;
    }
    return inRange(log.totalCalories, targets.dailyCalorieTarget)
        && inRange(log.totalProteinG, targets.proteinTargetG)
        && inRange(log.totalCarbsG, targets.carbsTargetG)
        && inRange(log.totalFatsG, targets.fatsTargetG);
  }
}
```

### Providers

```dart
// lib/features/nutrition_tracking/presentation/providers/nutrition_providers.dart

// Filtre période (interactif)
final statsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.thisWeek);

// Stats calculées
final nutritionStatsProvider = Provider<NutritionStats>((ref) {
  final historyAsync = ref.watch(nutritionHistoryProvider);
  final targets = ref.watch(nutritionTargetsProvider);
  final period = ref.watch(statsPeriodProvider);
  final service = NutritionStatsService();

  return historyAsync.when(
    data: (history) => service.computeStats(history, targets, period),
    loading: () => NutritionStats(
      balancedDaysPercent: 0, avgCalories: 0,
      avgProteinG: 0, avgCarbsG: 0, avgFatsG: 0,
      totalDaysWithData: 0, period: period,
    ),
    error: (_, __) => NutritionStats(
      balancedDaysPercent: 0, avgCalories: 0,
      avgProteinG: 0, avgCarbsG: 0, avgFatsG: 0,
      totalDaysWithData: 0, period: period,
    ),
  );
});
```

### NutritionStatsSection Widget

```dart
// lib/features/nutrition_tracking/presentation/widgets/nutrition_stats_section.dart

class NutritionStatsSection extends ConsumerWidget {
  const NutritionStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(nutritionStatsProvider);
    final period = ref.watch(statsPeriodProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Statistiques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),

        // Sélecteur période
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<StatsPeriod>(
            segments: StatsPeriod.values
                .map((p) => ButtonSegment(value: p, label: Text(p.label, style: const TextStyle(fontSize: 11))))
                .toList(),
            selected: {period},
            onSelectionChanged: (v) => ref.read(statsPeriodProvider.notifier).state = v.first,
          ),
        ),
        const SizedBox(height: 16),

        if (!stats.hasEnoughData)
          _InsufficientDataCard()
        else ...[
          _BalancedDaysCard(stats: stats),
          const SizedBox(height: 12),
          _AverageNutritionCard(stats: stats),
        ],
      ],
    );
  }
}

class _BalancedDaysCard extends StatelessWidget {
  final NutritionStats stats;
  const _BalancedDaysCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Grand pourcentage
            Text(
              '${stats.balancedDaysPercent.round()}%',
              style: TextStyle(
                fontSize: 48, fontWeight: FontWeight.bold,
                color: stats.encouragementColor,
              ),
            ),
            const Text('de jours équilibrés', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            // Message encourageant
            Text(
              stats.encouragementMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: stats.encouragementColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Sur ${stats.totalDaysWithData} jours enregistrés',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _AverageNutritionCard extends StatelessWidget {
  final NutritionStats stats;
  const _AverageNutritionCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Moyennes journalières', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _StatRow(label: 'Calories', value: '${stats.avgCalories.round()} kcal', color: Colors.deepOrange),
            const SizedBox(height: 6),
            _StatRow(label: 'Protéines', value: '${stats.avgProteinG.toStringAsFixed(1)}g', color: Colors.blue),
            const SizedBox(height: 6),
            _StatRow(label: 'Glucides', value: '${stats.avgCarbsG.toStringAsFixed(1)}g', color: Colors.orange),
            const SizedBox(height: 6),
            _StatRow(label: 'Lipides', value: '${stats.avgFatsG.toStringAsFixed(1)}g', color: Colors.yellow.shade700),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label),
        ]),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InsufficientDataCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Pas encore assez de données\nContinuez à enregistrer vos repas !',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Intégration dans NutritionHistoryScreen

```dart
// Dans NutritionHistoryScreen — ajouter à la ListView après WeeklySummaryCard:
const Divider(height: 32),
const NutritionStatsSection(),
const SizedBox(height: 24),
```

### Project Structure Notes

- `NutritionStatsService` est un service de domaine pur (pas de dépendance Flutter)
- `statsPeriodProvider` est un `StateProvider` — pas de persistance (reset à chaque session)
- Calcul synchrone depuis `nutritionHistoryProvider` (Map déjà chargé en Story 7.4)
- Pas de `fl_chart` pour les stats agrégées (cards textuelles suffisent) — économise les performances
- `isBalancedDay`: toutes les macros dans 80–110% — critère strict RGPD/santé
- `NutritionStatsSection` s'intègre dans `NutritionHistoryScreen` (Story 7.4) — pas une nouvelle route

### References

- [Source: epics.md#Story-7.8]
- nutritionHistoryProvider [Source: Story 7.4]
- NutritionTargets + nutritionTargetsProvider [Source: Story 7.3]
- DayNutritionLog computed totals [Source: Story 7.2]
- fl_chart [Source: Story 4.4]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
