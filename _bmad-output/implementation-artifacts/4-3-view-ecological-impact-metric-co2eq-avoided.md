# Story 4.3: View Ecological Impact Metric (CO2eq Avoided)

Status: ready-for-dev

## Story

As a Thomas (sportif eco-responsable),
I want to see my environmental impact in terms of CO2 emissions avoided,
so that I can understand the broader ecological benefit of reducing food waste.

## Acceptance Criteria

1. **Given** I view the detailed metrics screen
   **When** I scroll to the CO2 section
   **Then** I see "CO2eq évité" in kg CO2eq
   **And** the calculation = waste_kg_avoided × CO2_factor_per_category (Story 4.1 tables)

2. **Given** I see the CO2 metric
   **When** I tap the ⓘ tooltip icon
   **Then** a bottom sheet explains: "CO2eq inclut la production, le transport et le traitement des déchets alimentaires évités. Source: ADEME 2022."

3. **Given** I filter by period (Story 4.2's periodFilterProvider)
   **Then** the CO2 metric updates immediately to reflect the selected period

4. **Given** I view the CO2 section
   **Then** I see an equivalent in relatable terms, e.g.:
   - "= X km en voiture évités" (1 km voiture ≈ 0.21 kg CO2)
   - "= X arbres plantés pour 1 an" (1 arbre ≈ 25 kg CO2/an)

## Tasks / Subtasks

- [ ] **T1**: Créer `_Co2ImpactSection` widget dans `DashboardDetailsScreen` (AC: 1, 2, 3, 4)
  - [ ] Afficher total CO2 en kg avec icône `Icons.cloud_off`
  - [ ] Bouton ⓘ → `showModalBottomSheet` explication ADEME
  - [ ] Équivalences contextuelles (km voiture + arbres)
  - [ ] Écoute `periodFilterProvider` (partagé avec Story 4.2)

- [ ] **T2**: Implémenter calcul équivalences (AC: 4)
  - [ ] `Co2EquivalenceService.getEquivalences(double co2Kg)` → `List<String>`
  - [ ] km voiture: `(co2Kg / 0.21).round()`
  - [ ] arbres: `(co2Kg / 25).toStringAsFixed(1)`

- [ ] **T3**: Tests unitaires `Co2EquivalenceService` (AC: 4)
- [ ] **T4**: Tests widget section CO2 (AC: 1, 2)
- [ ] **T5**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Co2EquivalenceService

```dart
// lib/features/dashboard/domain/services/co2_equivalence_service.dart

class Co2EquivalenceService {
  static const double _co2PerKmCar = 0.21;       // kg CO2/km (voiture moyenne)
  static const double _co2PerTreePerYear = 25.0;  // kg CO2/arbre/an — ADEME

  List<String> getEquivalences(double co2Kg) {
    if (co2Kg <= 0) return [];
    final results = <String>[];

    final kmCar = (co2Kg / _co2PerKmCar).round();
    if (kmCar > 0) results.add('≈ $kmCar km en voiture évités');

    final trees = co2Kg / _co2PerTreePerYear;
    if (trees >= 0.01) {
      results.add('≈ ${trees.toStringAsFixed(2)} arbre(s) planté(s) pendant 1 an');
    }

    return results;
  }
}
```

### _Co2ImpactSection widget

```dart
class _Co2ImpactSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(filteredMetricsProvider);  // Story 4.2
    final equivService = Co2EquivalenceService();
    final equivalences = equivService.getEquivalences(metrics.co2EqKgAvoided);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.teal),
            const SizedBox(width: 8),
            Text('Impact CO2', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showAdemeInfo(context),
              child: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${metrics.co2EqKgAvoided.toStringAsFixed(2)} kg CO2eq évités',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.teal),
        ),
        if (equivalences.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...equivalences.map((e) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.arrow_right, size: 16, color: Colors.teal),
                Text(e, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          )),
        ],
      ],
    );
  }

  void _showAdemeInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('À propos du CO2eq', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 12),
            Text(
              'CO2eq (équivalent CO2) inclut les émissions de gaz à effet de serre liées à '
              'la production agricole, le transport, la transformation et le traitement des '
              'déchets alimentaires évités.\n\nSource: ADEME — "Empreinte carbone des aliments", 2022.',
            ),
          ],
        ),
      ),
    );
  }
}
```

### Intégration dans DashboardDetailsScreen

```dart
// Ajouter _Co2ImpactSection dans le Column de DashboardDetailsScreen:
Column(
  children: [
    _PeriodFilterChips(),      // Story 4.2
    const SizedBox(height: 16),
    _WasteKgEurosSection(),    // Story 4.2
    const Divider(height: 32),
    _Co2ImpactSection(),       // Story 4.3 ← AJOUTER
    const Divider(height: 32),
    // _ChartsSection()         // Story 4.4
  ],
),
```

### Project Structure Notes

- `Co2EquivalenceService` dans `lib/features/dashboard/domain/services/`
- `filteredMetricsProvider` partagé depuis Story 4.2 — pas de nouvelle computation ici
- Source ADEME doit apparaître dans l'UI (conformité légale / honnêteté)

### References

- [Source: epics.md#Story-4.3]
- CO2 factors per category [Source: 4-1 WasteMetricsService]
- periodFilterProvider [Source: 4-2]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
