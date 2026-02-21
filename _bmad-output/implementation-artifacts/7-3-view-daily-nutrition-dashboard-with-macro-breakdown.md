# Story 7.3: View Daily Nutrition Dashboard with Macro Breakdown

Status: ready-for-dev

## Story

As a Thomas (sportif),
I want to see my daily calories and macros at a glance,
so that I can track my progress toward my nutritional goals.

## Acceptance Criteria

1. **Given** I have logged meals today
   **When** I view the nutrition dashboard
   **Then** I see my daily totals: calories, protein, carbs, fats
   **And** visual progress bars showing current intake vs targets (from NutritionProfile)
   **And** macros color-coded: vert si dans les objectifs, orange si proche, rouge si dépassé

2. **Given** the dashboard is displayed
   **Then** I see a circular progress indicator for calories (% de l'objectif journalier)
   **And** three linear progress bars for macros (protéines, glucides, lipides)
   **And** percentage of daily goals achieved

3. **Given** I add a new meal (Story 7.2)
   **Then** the dashboard updates in real-time (StreamProvider)

4. **Given** I navigate to the nutrition module
   **Then** this dashboard is the home screen (`/nutrition`)
   **And** it's wrapped by `NutritionGate` (Story 7.1)

## Tasks / Subtasks

- [ ] **T1**: Créer `NutritionDashboardScreen` (AC: 1, 2, 4)
  - [ ] Wrapped par `NutritionGate`
  - [ ] `dayNutritionLogProvider(today)` — StreamProvider (Story 7.2)
  - [ ] `CalorieRingWidget` — cercle avec % calories
  - [ ] `MacroProgressBar` × 3 (protéines, glucides, lipides)
  - [ ] Section journaux repas groupés par MealType
  - [ ] FAB "Ajouter" → `/nutrition/add-meal`
- [ ] **T2**: Créer `CalorieRingWidget` (AC: 2)
  - [ ] `CustomPainter` arc circulaire — couleur selon % (vert/orange/rouge)
  - [ ] Valeur centrale: "X kcal / Y kcal"
  - [ ] Sous-texte: "X% de l'objectif"
- [ ] **T3**: Créer `MacroProgressBar` widget (AC: 1)
  - [ ] Label (ex: "Protéines"), valeur actuelle (g), cible (g)
  - [ ] `LinearProgressIndicator` coloré selon completion %
  - [ ] Couleur: vert (80–110% cible), orange (60–80%), rouge (<60% ou >120%)
- [ ] **T4**: Créer `nutritionTargetsProvider` (AC: 1)
  - [ ] Lit les objectifs depuis `nutritionProfileProvider` (Story 6.9 placeholder, Epic 8 réel)
  - [ ] Valeurs par défaut si pas de profil: 2000 kcal, 150g protéines, 250g glucides, 67g lipides
- [ ] **T5**: Remplacer placeholder `/nutrition` route avec `NutritionDashboardScreen` (AC: 4)
- [ ] **T6**: Tests widget `NutritionDashboardScreen` avec mock data (AC: 1, 2, 3)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### NutritionTargets

```dart
// lib/features/nutrition_tracking/domain/entities/nutrition_targets.dart

@freezed
class NutritionTargets with _$NutritionTargets {
  const factory NutritionTargets({
    @Default(2000) double dailyCalorieTarget,
    @Default(150) double proteinTargetG,
    @Default(250) double carbsTargetG,
    @Default(67) double fatsTargetG,
  }) = _NutritionTargets;

  const NutritionTargets._();

  // % atteint pour chaque macro (0.0 – 1.5+)
  double caloriePercent(double current) => current / dailyCalorieTarget;
  double proteinPercent(double current) => current / proteinTargetG;
  double carbsPercent(double current) => current / carbsTargetG;
  double fatsPercent(double current) => current / fatsTargetG;

  Color statusColor(double percent) {
    if (percent >= 0.8 && percent <= 1.1) return Colors.green;
    if (percent >= 0.6 || percent <= 1.2) return Colors.orange;
    return Colors.red;
  }
}
```

### Provider nutritionTargets

```dart
// Placeholder — Epic 8 (NutritionProfile) alimentera les vraies cibles
final nutritionTargetsProvider = Provider<NutritionTargets>((ref) {
  final profile = ref.watch(nutritionProfileProvider);  // Story 6.9 / Epic 8
  if (profile.name == 'Aucun') return const NutritionTargets();
  // Epic 8 remplacera avec le vrai calcul TDEE/BMR
  return NutritionTargets(
    dailyCalorieTarget: profile.dailyCalorieTarget ?? 2000,
    proteinTargetG: profile.proteinTargetGPerDay ?? 150,
  );
});
```

### NutritionDashboardScreen

```dart
// lib/features/nutrition_tracking/presentation/screens/nutrition_dashboard_screen.dart

class NutritionDashboardScreen extends ConsumerWidget {
  const NutritionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final logAsync = ref.watch(dayNutritionLogProvider(
      DateTime(today.year, today.month, today.day),
    ));
    final targets = ref.watch(nutritionTargetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition du jour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/nutrition/history'),  // Story 7.4
            tooltip: 'Historique',
          ),
        ],
      ),
      body: logAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (log) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Cercle calories
                    CalorieRingWidget(
                      current: log.totalCalories,
                      target: targets.dailyCalorieTarget,
                    ),
                    const SizedBox(height: 24),

                    // Barres macros
                    MacroProgressBar(
                      label: 'Protéines',
                      currentG: log.totalProteinG,
                      targetG: targets.proteinTargetG,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    MacroProgressBar(
                      label: 'Glucides',
                      currentG: log.totalCarbsG,
                      targetG: targets.carbsTargetG,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    MacroProgressBar(
                      label: 'Lipides',
                      currentG: log.totalFatsG,
                      targetG: targets.fatsTargetG,
                      color: Colors.yellow.shade700,
                    ),
                    const Divider(height: 32),
                  ],
                ),
              ),
            ),

            // Journal repas par type
            ...MealType.values.map((mealType) {
              final entries = log.entriesFor(mealType);
              if (entries.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverToBoxAdapter(
                child: _MealTypeSection(mealType: mealType, entries: entries),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/nutrition/add-meal'),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
```

### CalorieRingWidget (CustomPainter)

```dart
// lib/features/nutrition_tracking/presentation/widgets/calorie_ring_widget.dart

class CalorieRingWidget extends StatelessWidget {
  final double current;
  final double target;

  const CalorieRingWidget({super.key, required this.current, required this.target});

  @override
  Widget build(BuildContext context) {
    final percent = (current / target).clamp(0.0, 1.5);
    final color = percent >= 0.8 && percent <= 1.1
        ? Colors.green
        : percent >= 0.6 ? Colors.orange : Colors.red;

    return SizedBox(
      width: 180, height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(180, 180),
            painter: _RingPainter(percent: percent.clamp(0, 1), color: color),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${current.round()}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text('/ ${target.round()} kcal',
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(
                '${(percent * 100).round()}% objectif',
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;

  const _RingPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Background ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi, false,
      Paint()..color = Colors.grey.shade200..strokeWidth = 12..style = PaintingStyle.stroke,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi * percent, false,
      Paint()
        ..color = color
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percent != percent || old.color != color;
}
```

### MacroProgressBar

```dart
class MacroProgressBar extends StatelessWidget {
  final String label;
  final double currentG;
  final double targetG;
  final Color color;

  const MacroProgressBar({super.key, required this.label, required this.currentG,
    required this.targetG, required this.color});

  @override
  Widget build(BuildContext context) {
    final percent = (currentG / targetG).clamp(0.0, 1.5);
    final displayColor = percent >= 0.8 && percent <= 1.1 ? Colors.green
        : percent >= 0.6 ? Colors.orange : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${currentG.toStringAsFixed(1)}g / ${targetG.round()}g',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent.clamp(0, 1),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(displayColor),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
```

### GoRouter — Remplacer placeholder `/nutrition`

```dart
GoRoute(
  path: '/nutrition',
  builder: (_, __) => const NutritionGate(
    child: NutritionDashboardScreen(),
  ),
  routes: [
    GoRoute(
      path: 'add-meal',
      builder: (_, __) => const NutritionGate(child: AddMealScreen()),
    ),
    GoRoute(
      path: 'history',
      builder: (_, __) => const NutritionGate(
        child: Scaffold(body: Center(child: Text('Historique — Story 7.4'))),
      ),
    ),
  ],
),
```

### Project Structure Notes

- `NutritionDashboardScreen` est la home de `/nutrition` (remplace placeholder Story 7.1)
- `CalorieRingWidget` requiert `dart:math` pour `math.pi`
- `NutritionTargets` utilise les valeurs par défaut jusqu'à ce qu'Epic 8 soit implémenté
- StreamProvider réactif: update temps réel lors ajout de repas (Story 7.2)

### References

- [Source: epics.md#Story-7.3]
- DayNutritionLog + dayNutritionLogProvider [Source: Story 7.2]
- NutritionTargets [Source: Epic 8 — placeholders pour MVP]
- NutritionGate [Source: Story 7.1]
- nutritionProfileProvider [Source: Story 6.9, Epic 8]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
