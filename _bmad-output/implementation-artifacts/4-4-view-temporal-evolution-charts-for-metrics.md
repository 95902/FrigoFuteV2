# Story 4.4: View Temporal Evolution Charts for Metrics

Status: ready-for-dev

## Story

As a Sophie (famille),
I want to see graphs showing how my anti-waste metrics evolve over time,
so that I can track my progress and see trends.

## Acceptance Criteria

1. **Given** I scroll to the charts section of the dashboard details screen
   **When** the charts render
   **Then** I see line charts for:
   - Food waste avoided (kg) per week over the last 3 months
   - Money saved (€) per week over the last 3 months
   - CO2eq avoided (kg) per week over the last 3 months
   **And** charts load within 2 seconds

2. **Given** I view a chart
   **Then** axes are labeled (weeks on X, values on Y)
   **And** I can tap a data point to see the exact value for that week

3. **Given** I switch view mode (weekly / monthly / yearly)
   **Then** the charts re-aggregate data for the selected granularity

4. **Given** I have less than 2 weeks of data
   **Then** I see a placeholder: "Continuez à utiliser l'app pour voir votre évolution !"

## Tasks / Subtasks

- [ ] **T1**: Ajouter package de charts (AC: 1)
  - [ ] `fl_chart: ^0.70.0` dans pubspec.yaml
  - [ ] Alternative: `syncfusion_flutter_charts` (premium) ou `graphic` — préférer `fl_chart` (open source)

- [ ] **T2**: Créer `WasteMetricsService.computeWeeklyTimeSeries()` (AC: 1, 3)
  - [ ] `computeTimeSeries(products, granularity, period)` → `List<MetricsDataPoint>`
  - [ ] `MetricsDataPoint(DateTime weekStart, WasteMetrics metrics)`
  - [ ] Agréger par semaine ou mois selon `granularity`

- [ ] **T3**: Créer `timeSeriesProvider` Provider<List<MetricsDataPoint>> (AC: 1, 3)
  - [ ] Écoute `consumedInventoryProvider` + `periodFilterProvider` (Story 4.2)

- [ ] **T4**: Créer `_MetricsLineChart` widget avec fl_chart (AC: 1, 2)
  - [ ] `LineChart` avec 3 séries (kg, €, CO2) sur onglets séparés ou superposées
  - [ ] Touch response → tooltip avec valeur exacte
  - [ ] Labels semaines en français (ex: "S1 Jan", "S2 Jan")

- [ ] **T5**: Intégrer dans `DashboardDetailsScreen` (AC: 1, 4)
  - [ ] Placeholder si < 2 points de données

- [ ] **T6**: Tests unitaires `computeTimeSeries` (AC: 1, 3)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Package à ajouter

```yaml
# pubspec.yaml
dependencies:
  fl_chart: ^0.70.0  # Open source Flutter chart library
```

### MetricsDataPoint entity

```dart
// lib/features/dashboard/domain/entities/metrics_data_point.dart

@freezed
class MetricsDataPoint with _$MetricsDataPoint {
  const factory MetricsDataPoint({
    required DateTime periodStart,
    required WasteMetrics metrics,
  }) = _MetricsDataPoint;
}
```

### computeTimeSeries

```dart
enum ChartGranularity { weekly, monthly }

List<MetricsDataPoint> computeTimeSeries(
  List<ProductEntity> consumedProducts, {
  required ChartGranularity granularity,
  int periodCount = 12,  // dernières 12 semaines ou 12 mois
}) {
  final now = DateTime.now();
  final points = <MetricsDataPoint>[];

  for (int i = periodCount - 1; i >= 0; i--) {
    final DateTime start;
    final DateTime end;

    if (granularity == ChartGranularity.weekly) {
      start = now.subtract(Duration(days: (i + 1) * 7));
      end = now.subtract(Duration(days: i * 7));
    } else {
      start = DateTime(now.year, now.month - i, 1);
      end = DateTime(now.year, now.month - i + 1, 1);
    }

    final metrics = computeMetrics(consumedProducts, rangeStart: start, rangeEnd: end);
    points.add(MetricsDataPoint(periodStart: start, metrics: metrics));
  }

  return points;
}
```

### Riverpod Provider

```dart
final chartGranularityProvider = StateProvider<ChartGranularity>((_) => ChartGranularity.weekly);

final timeSeriesProvider = Provider<List<MetricsDataPoint>>((ref) {
  final consumed = ref.watch(consumedInventoryProvider);
  final granularity = ref.watch(chartGranularityProvider);
  final service = ref.read(wasteMetricsServiceProvider);
  return consumed.maybeWhen(
    data: (p) => service.computeTimeSeries(p, granularity: granularity),
    orElse: () => [],
  );
});
```

### _MetricsLineChart Widget

```dart
class _MetricsLineChart extends ConsumerWidget {
  final String metricLabel;
  final Color color;
  final double Function(WasteMetrics) valueExtractor;

  const _MetricsLineChart({
    required this.metricLabel,
    required this.color,
    required this.valueExtractor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeSeries = ref.watch(timeSeriesProvider);

    if (timeSeries.length < 2) {
      return const Center(
        child: Text('Continuez à utiliser l\'app pour voir votre évolution !'),
      );
    }

    final spots = timeSeries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), valueExtractor(e.value.metrics));
    }).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < timeSeries.length) {
                    final date = timeSeries[idx].periodStart;
                    return Text(
                      DateFormat('d/M').format(date),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                return LineTooltipItem(
                  '${s.y.toStringAsFixed(2)} $metricLabel',
                  TextStyle(color: color),
                );
              }).toList(),
            ),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
```

### Intégration dans DashboardDetailsScreen

```dart
// Section charts avec onglets
DefaultTabController(
  length: 3,
  child: Column(
    children: [
      const TabBar(tabs: [
        Tab(text: 'Kg évités'),
        Tab(text: '€ économisés'),
        Tab(text: 'CO2'),
      ]),
      SizedBox(
        height: 250,
        child: TabBarView(children: [
          _MetricsLineChart(
            metricLabel: 'kg',
            color: Colors.green,
            valueExtractor: (m) => m.wasteKgAvoided,
          ),
          _MetricsLineChart(
            metricLabel: '€',
            color: Colors.blue,
            valueExtractor: (m) => m.moneySavedEuros,
          ),
          _MetricsLineChart(
            metricLabel: 'kg CO2',
            color: Colors.teal,
            valueExtractor: (m) => m.co2EqKgAvoided,
          ),
        ]),
      ),
    ],
  ),
),
```

### Project Structure Notes

- `fl_chart` est la librairie standard Flutter pour les graphiques (open source, pub.dev 5000+ likes)
- Les graphiques sont calculés côté client depuis Hive — aucune requête Firestore nécessaire
- `ChartGranularity` séparé de `MetricsPeriod` (Story 4.2) — granularité vs étendue temporelle

### References

- [Source: epics.md#Story-4.4]
- fl_chart documentation: https://pub.dev/packages/fl_chart
- periodFilterProvider, filteredMetricsProvider [Source: 4-2]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
