# Story 7.4: View Weekly and Monthly Nutrition History

Status: ready-for-dev

## Story

As a Sophie (famille),
I want to see my nutrition trends over time,
so that I can understand my eating patterns and make adjustments.

## Acceptance Criteria

1. **Given** I navigate to "Historique nutritionnel"
   **When** the screen opens
   **Then** I see a calendar view with daily summaries (colored dots per day)
   **And** I can switch between weekly and monthly views

2. **Given** I view the history
   **Then** each day shows: total calories, macro balance, and goal achievement %
   **And** days are color-coded: vert (objectifs atteints), orange (partiel), gris (aucun log)

3. **Given** I tap a specific day
   **Then** I see the detailed meal log for that day (entries from Story 7.2)

4. **Given** I view the weekly summary
   **Then** I see charts showing average calories and macro distribution over the week

## Tasks / Subtasks

- [ ] **T1**: Créer `NutritionHistoryScreen` avec `TableCalendar` ou calendrier custom (AC: 1, 2)
  - [ ] `table_calendar: ^3.1.0` package (ou simple GridView de semaines)
  - [ ] Charger les logs disponibles depuis `nutrition_data_box`
  - [ ] Color-code chaque jour selon achievement %
- [ ] **T2**: Créer `nutritionHistoryProvider` (AC: 1, 2)
  - [ ] Lit toutes les clés `log_*` de `nutrition_data_box`
  - [ ] Retourne `Map<DateTime, DayNutritionLog>` pour les 90 derniers jours
- [ ] **T3**: Créer `DayDetailSheet` — bottom sheet pour tap sur un jour (AC: 3)
  - [ ] `showModalBottomSheet` avec `MealLogListSection` (Story 7.3)
- [ ] **T4**: Créer `WeeklySummaryCard` avec mini-charts (AC: 4)
  - [ ] Moyenne calories sur 7 jours
  - [ ] `fl_chart LineChart` (déjà utilisé Epic 4) — réutiliser pattern Story 4.4
- [ ] **T5**: Ajouter route `/nutrition/history` (AC: 1)
- [ ] **T6**: Tests unitaires `nutritionHistoryProvider` (AC: 2)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### nutritionHistoryProvider

```dart
// lib/features/nutrition_tracking/presentation/providers/nutrition_providers.dart

final nutritionHistoryProvider = FutureProvider<Map<DateTime, DayNutritionLog>>((ref) async {
  final box = await ref.watch(nutritionBoxProvider.future);
  final result = <DateTime, DayNutritionLog>{};
  final now = DateTime.now();

  // Chercher les 90 derniers jours
  for (int i = 0; i < 90; i++) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final key = 'log_${DateFormat('yyyyMMdd').format(date)}';
    final raw = box.get(key);
    if (raw != null) {
      result[date] = DayNutritionLog.fromJson(Map<String, dynamic>.from(raw as Map));
    }
  }
  return result;
});
```

### NutritionHistoryScreen

```dart
class NutritionHistoryScreen extends ConsumerStatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  ConsumerState<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends ConsumerState<NutritionHistoryScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(nutritionHistoryProvider);
    final targets = ref.watch(nutritionTargetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique nutritionnel')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (history) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Calendrier mensuel
            _MonthCalendar(
              focusedMonth: _focusedMonth,
              history: history,
              targets: targets,
              selectedDay: _selectedDay,
              onDaySelected: (day) {
                setState(() => _selectedDay = day);
                if (history.containsKey(day)) {
                  _showDayDetail(context, history[day]!);
                }
              },
              onMonthChanged: (month) => setState(() => _focusedMonth = month),
            ),
            const Divider(height: 32),

            // Résumé semaine courante
            WeeklySummaryCard(history: history, targets: targets),
          ],
        ),
      ),
    );
  }

  void _showDayDetail(BuildContext context, DayNutritionLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DayDetailSheet(log: log),
    );
  }
}
```

### _MonthCalendar (simple GridView sans lib externe)

```dart
class _MonthCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final Map<DateTime, DayNutritionLog> history;
  final NutritionTargets targets;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  Color _dayColor(DateTime day) {
    final log = history[day];
    if (log == null) return Colors.grey.shade200;
    final caloriePercent = log.totalCalories / targets.dailyCalorieTarget;
    if (caloriePercent >= 0.8 && caloriePercent <= 1.1) return Colors.green.shade300;
    if (caloriePercent >= 0.5) return Colors.orange.shade300;
    return Colors.red.shade200;
  }

  @override
  Widget build(BuildContext context) {
    // Calendrier simple - implémentation basique sans lib externe
    // TODO: remplacer par table_calendar si disponible
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onMonthChanged(DateTime(focusedMonth.year, focusedMonth.month - 1)),
            ),
            Text(DateFormat('MMMM yyyy', 'fr_FR').format(focusedMonth),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onMonthChanged(DateTime(focusedMonth.year, focusedMonth.month + 1)),
            ),
          ],
        ),
        // Jours de la semaine
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemCount: 42,  // 6 semaines × 7 jours
          itemBuilder: (context, index) {
            // Calculer la date pour cet index
            final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
            final startOffset = firstDayOfMonth.weekday - 1;  // 0 = lundi
            final dayNumber = index - startOffset + 1;

            if (dayNumber < 1 || dayNumber > DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month)) {
              return const SizedBox.shrink();
            }

            final day = DateTime(focusedMonth.year, focusedMonth.month, dayNumber);
            final isSelected = selectedDay == day;
            final color = _dayColor(day);

            return GestureDetector(
              onTap: () => onDaySelected(day),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
```

### Packages à ajouter (optionnel)

```yaml
# optionnel — alternative au calendrier custom ci-dessus
# dependencies:
#   table_calendar: ^3.1.0
```

### Project Structure Notes

- Historique stocké dans `nutrition_data_box` — clés `log_YYYYMMDD`
- Pas de requête Firestore pour l'historique — tout est local (offline-first)
- `WeeklySummaryCard` réutilise `fl_chart` (déjà dans pubspec depuis Story 4.4)
- `DateFormat` → `intl` package (déjà dans pubspec)

### References

- [Source: epics.md#Story-7.4]
- DayNutritionLog [Source: Story 7.2]
- fl_chart [Source: Story 4.4]
- nutritionBoxProvider [Source: Story 7.1]
- NutritionTargets [Source: Story 7.3]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
