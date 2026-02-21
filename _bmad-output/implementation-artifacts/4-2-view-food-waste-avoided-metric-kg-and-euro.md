# Story 4.2: View Food Waste Avoided Metric (kg and €)

Status: ready-for-dev

## Story

As a Marie (senior),
I want to see exactly how much food I've saved from waste in kilograms and euros,
so that I can quantify my anti-waste efforts.

## Acceptance Criteria

1. **Given** I tap the summary widget on the dashboard (Story 4.1)
   **When** I arrive on the detailed metrics screen
   **Then** I see "Gaspillage évité" displayed in kg AND €
   **And** the calculation includes products marked as consumed before DLC/DDM expiration

2. **Given** I view the detailed metrics
   **Then** I can filter by time period: "Cette semaine", "Ce mois", "Cette année", "Tout"
   **And** the metric updates immediately when I change the period

3. **Given** the metric is displayed
   **Then** I see a breakdown by category (e.g., "Viandes & Poissons: 1.2 kg / 5,40 €")
   **And** categories with 0 consumption are hidden

4. **Given** the metric updates in real-time
   **When** I mark a product as consumed in another screen and return
   **Then** the metric reflects the change without requiring a page refresh

## Tasks / Subtasks

- [ ] **T1**: Étendre `WasteMetricsService` — métriques par période + breakdown catégories (AC: 1, 2, 3)
  - [ ] `computeByCategory(products, rangeStart, rangeEnd)` → `Map<ProductCategory, WasteMetrics>`
  - [ ] Enum `MetricsPeriod` (week, month, year, allTime)
  - [ ] Helper `dateRangeForPeriod(MetricsPeriod)` → `(DateTime start, DateTime end)`

- [ ] **T2**: Créer `periodFilterProvider` StateProvider<MetricsPeriod> (AC: 2)

- [ ] **T3**: Implémenter `DashboardDetailsScreen` (story 4.1 placeholder) (AC: 1, 2, 3, 4)
  - [ ] `lib/features/dashboard/presentation/screens/dashboard_details_screen.dart`
  - [ ] `_PeriodFilterChips` horizontal (Cette semaine / Ce mois / Cette année / Tout)
  - [ ] `_WasteKgEurosSection` avec totaux + liste par catégorie

- [ ] **T4**: Tests unitaires `computeByCategory` (AC: 3)
- [ ] **T5**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### MetricsPeriod enum + dateRange helper

```dart
// lib/features/dashboard/domain/services/waste_metrics_service.dart — extension

enum MetricsPeriod { week, month, year, allTime }

extension MetricsPeriodX on MetricsPeriod {
  String get label => switch (this) {
    MetricsPeriod.week    => 'Cette semaine',
    MetricsPeriod.month   => 'Ce mois',
    MetricsPeriod.year    => 'Cette année',
    MetricsPeriod.allTime => 'Tout',
  };

  (DateTime start, DateTime end) get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      MetricsPeriod.week    => (today.subtract(const Duration(days: 7)), now),
      MetricsPeriod.month   => (DateTime(now.year, now.month, 1), now),
      MetricsPeriod.year    => (DateTime(now.year, 1, 1), now),
      MetricsPeriod.allTime => (DateTime(2020, 1, 1), now),
    };
  }
}
```

### computeByCategory

```dart
Map<ProductCategory, WasteMetrics> computeByCategory(
  List<ProductEntity> consumedProducts, {
  required DateTime rangeStart,
  required DateTime rangeEnd,
}) {
  final result = <ProductCategory, WasteMetrics>{};
  final inRange = consumedProducts.where((p) {
    final c = p.consumedAt;
    return c != null && c.isAfter(rangeStart) && c.isBefore(rangeEnd);
  });

  for (final product in inRange) {
    final cat = product.category;
    final kg = _avgWeightKg[cat] ?? 0.3;
    final price = _avgPriceEuros[cat] ?? 2.0;
    final co2 = _co2FactorPerKg[cat] ?? 2.0;
    final existing = result[cat] ?? WasteMetrics.zero();
    result[cat] = WasteMetrics(
      wasteKgAvoided: existing.wasteKgAvoided + kg,
      moneySavedEuros: existing.moneySavedEuros + price,
      co2EqKgAvoided: existing.co2EqKgAvoided + kg * co2,
    );
  }
  return result;
}
```

### Riverpod providers

```dart
final periodFilterProvider = StateProvider<MetricsPeriod>((_) => MetricsPeriod.month);

final filteredMetricsProvider = Provider<WasteMetrics>((ref) {
  final consumed = ref.watch(consumedInventoryProvider);
  final period = ref.watch(periodFilterProvider);
  final service = ref.read(wasteMetricsServiceProvider);
  final (start, end) = period.dateRange;
  return consumed.maybeWhen(
    data: (p) => service.computeMetrics(p, rangeStart: start, rangeEnd: end),
    orElse: () => WasteMetrics.zero(),
  );
});

final categoryBreakdownProvider = Provider<Map<ProductCategory, WasteMetrics>>((ref) {
  final consumed = ref.watch(consumedInventoryProvider);
  final period = ref.watch(periodFilterProvider);
  final service = ref.read(wasteMetricsServiceProvider);
  final (start, end) = period.dateRange;
  return consumed.maybeWhen(
    data: (p) => service.computeByCategory(p, rangeStart: start, rangeEnd: end),
    orElse: () => {},
  );
});
```

### DashboardDetailsScreen — Section kg/€

```dart
class _WasteKgEurosSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(filteredMetricsProvider);
    final breakdown = ref.watch(categoryBreakdownProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gaspillage évité', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _BigMetric(value: '${metrics.wasteKgAvoided} kg', icon: Icons.scale, color: Colors.green),
            const SizedBox(width: 16),
            _BigMetric(value: '${metrics.moneySavedEuros} €', icon: Icons.euro, color: Colors.blue),
          ],
        ),
        const SizedBox(height: 16),
        Text('Par catégorie', style: Theme.of(context).textTheme.titleSmall),
        ...breakdown.entries
            .where((e) => e.value.wasteKgAvoided > 0)
            .map((e) => ListTile(
              leading: const Icon(Icons.label_outline),
              title: Text(_categoryLabel(e.key)),
              trailing: Text(
                '${e.value.wasteKgAvoided.toStringAsFixed(2)} kg · ${e.value.moneySavedEuros.toStringAsFixed(2)} €',
              ),
            )),
      ],
    );
  }
}
```

### Project Structure Notes

- `DashboardDetailsScreen` était placeholder dans Story 4.1 — remplacée ici
- `periodFilterProvider` partagé entre Stories 4.2, 4.3, 4.4
- Imports `_categoryLabel` depuis `lib/core/constants/category_labels.dart` (ou dupliquer si pas encore extrait)

### References

- [Source: epics.md#Story-4.2]
- WasteMetricsService défini Story 4.1
- consumedInventoryProvider [Source: 2-4-mark-product-as-consumed.md]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
