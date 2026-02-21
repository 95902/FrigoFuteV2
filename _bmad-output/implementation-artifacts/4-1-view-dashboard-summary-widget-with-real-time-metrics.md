# Story 4.1: View Dashboard Summary Widget with Real-Time Metrics

Status: ready-for-dev

## Story

As a Sophie (famille),
I want to see a quick summary of my anti-waste impact when I open the app,
so that I feel motivated and proud of my progress.

## Acceptance Criteria

1. **Given** I open the dashboard screen
   **When** the screen is rendered
   **Then** I see a summary widget with three metrics:
   - Total food waste avoided (kg) this month
   - Money saved (€) this month
   - CO2 emissions avoided (kg CO2eq) this month
   **And** the widget loads and displays within 1 second

2. **Given** I mark a product as consumed (Story 2.4)
   **When** I navigate to the dashboard
   **Then** the metrics update to reflect the consumed product

3. **Given** I tap the summary widget
   **Then** I navigate to the detailed metrics screen (`/dashboard/details`)
   **Note**: Story 4.2 and 4.3 implement the details screen — for 4.1, the route exists but shows a placeholder

4. **Given** I have zero consumed products
   **Then** the summary widget shows zeros with a motivational empty state:
   "Commencez à consommer des produits pour voir votre impact anti-gaspi !"

5. **Given** the app is offline
   **Then** the dashboard shows the last computed metrics from Hive cache
   **And** no error or spinner is displayed

## Tasks / Subtasks

- [ ] **T1**: Créer `WasteMetricsService` avec tables d'estimation (AC: 1, 2)
  - [ ] `lib/features/dashboard/domain/services/waste_metrics_service.dart`
  - [ ] Tables statiques: poids moyen (kg) + prix moyen (€) + CO2 factor par `ProductCategory`
  - [ ] `computeMetrics(List<ProductEntity> consumedProducts, {required DateRange range})`
  - [ ] Retourne `WasteMetrics(wasteKgAvoided, moneySavedEuros, co2EqKgAvoided)`

- [ ] **T2**: Créer `WasteMetrics` entity (AC: 1)
  - [ ] `lib/features/dashboard/domain/entities/waste_metrics.dart`
  - [ ] Freezed: `double wasteKgAvoided`, `double moneySavedEuros`, `double co2EqKgAvoided`
  - [ ] `WasteMetrics.zero()` factory

- [ ] **T3**: Créer `dashboardMetricsProvider` Riverpod (AC: 1, 2, 5)
  - [ ] Écoute `consumedInventoryProvider` (Story 2.4)
  - [ ] Calcule `WasteMetrics` pour le mois courant
  - [ ] Cache résultat dans Hive box `dashboard_cache` (key: `metrics_YYYY_MM`)

- [ ] **T4**: Créer `DashboardScreen` (AC: 1, 4, 5)
  - [ ] `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
  - [ ] AppBar: "Mon Impact"
  - [ ] `DashboardSummaryCard` widget avec les 3 métriques
  - [ ] Empty state si wasteKgAvoided == 0

- [ ] **T5**: Créer `DashboardSummaryCard` widget (AC: 1, 3)
  - [ ] 3 `MetricTile` (kg, €, CO2)
  - [ ] Tapable → `context.push('/dashboard/details')`
  - [ ] Affichage arrondi: `1.23 kg`, `4,56 €`, `0.78 kg CO2`

- [ ] **T6**: Créer route `/dashboard` dans GoRouter (AC: 1)
  - [ ] Ajouter tab "Dashboard" dans ShellRoute (bottom navigation)
  - [ ] Route `/dashboard/details` placeholder (Stories 4.2/4.3)

- [ ] **T7**: Mettre à jour ShellRoute — ajouter tab Dashboard (AC: 1)

- [ ] **T8**: Tests unitaires `WasteMetricsService` (AC: 1, 2)
- [ ] **T9**: Tests widget `DashboardSummaryCard` (AC: 1, 4)
- [ ] **T10**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### WasteMetrics Entity

```dart
// lib/features/dashboard/domain/entities/waste_metrics.dart

@freezed
class WasteMetrics with _$WasteMetrics {
  const factory WasteMetrics({
    required double wasteKgAvoided,
    required double moneySavedEuros,
    required double co2EqKgAvoided,
  }) = _WasteMetrics;

  factory WasteMetrics.zero() => const WasteMetrics(
        wasteKgAvoided: 0.0,
        moneySavedEuros: 0.0,
        co2EqKgAvoided: 0.0,
      );
}
```

### WasteMetricsService — Tables d'estimation

```dart
// lib/features/dashboard/domain/services/waste_metrics_service.dart

class WasteMetricsService {
  // Poids moyen par catégorie (kg) — estimation pour un "produit typique"
  static const Map<ProductCategory, double> _avgWeightKg = {
    ProductCategory.produitsLaitiers:  0.500,  // 500g (yaourt, fromage)
    ProductCategory.viandesPoissons:   0.350,  // 350g (poulet, poisson)
    ProductCategory.fruitsLegumes:     0.400,  // 400g
    ProductCategory.epicerieSucree:    0.300,  // 300g (biscuits, confiture)
    ProductCategory.epicerieSalee:     0.500,  // 500g (pâtes, riz)
    ProductCategory.surgeles:          0.400,  // 400g
    ProductCategory.boissons:          1.000,  // 1L
    ProductCategory.boulangerie:       0.300,  // 300g (pain)
    ProductCategory.platsPrepares:     0.350,  // 350g
    ProductCategory.saucesCondiments:  0.200,  // 200g
    ProductCategory.oeufs:             0.060,  // 60g (1 oeuf, adapté par quantité)
    ProductCategory.autre:             0.300,
  };

  // Prix moyen par catégorie (€) — estimation INSEE alimentaire France 2024
  static const Map<ProductCategory, double> _avgPriceEuros = {
    ProductCategory.produitsLaitiers:  1.80,
    ProductCategory.viandesPoissons:   4.50,
    ProductCategory.fruitsLegumes:     1.50,
    ProductCategory.epicerieSucree:    2.20,
    ProductCategory.epicerieSalee:     1.80,
    ProductCategory.surgeles:          3.00,
    ProductCategory.boissons:          1.50,
    ProductCategory.boulangerie:       1.50,
    ProductCategory.platsPrepares:     3.50,
    ProductCategory.saucesCondiments:  2.00,
    ProductCategory.oeufs:             0.25,   // par oeuf
    ProductCategory.autre:             2.00,
  };

  // Facteur CO2eq (kg CO2 par kg de nourriture perdue) — source: ADEME 2022
  static const Map<ProductCategory, double> _co2FactorPerKg = {
    ProductCategory.produitsLaitiers:  3.2,
    ProductCategory.viandesPoissons:   12.0,  // viande rouge plus élevé
    ProductCategory.fruitsLegumes:     1.5,
    ProductCategory.epicerieSucree:    2.0,
    ProductCategory.epicerieSalee:     1.8,
    ProductCategory.surgeles:          2.5,
    ProductCategory.boissons:          0.5,
    ProductCategory.boulangerie:       1.6,
    ProductCategory.platsPrepares:     3.0,
    ProductCategory.saucesCondiments:  1.5,
    ProductCategory.oeufs:             4.5,
    ProductCategory.autre:             2.0,
  };

  WasteMetrics computeMetrics(
    List<ProductEntity> consumedProducts, {
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    final inRange = consumedProducts.where((p) {
      final consumed = p.consumedAt;
      if (consumed == null) return false;
      return consumed.isAfter(rangeStart) && consumed.isBefore(rangeEnd);
    }).toList();

    double totalKg = 0;
    double totalEuros = 0;
    double totalCo2 = 0;

    for (final product in inRange) {
      final cat = product.category;
      final kg = _avgWeightKg[cat] ?? 0.3;
      final price = _avgPriceEuros[cat] ?? 2.0;
      final co2 = _co2FactorPerKg[cat] ?? 2.0;

      totalKg += kg;
      totalEuros += price;
      totalCo2 += kg * co2;
    }

    return WasteMetrics(
      wasteKgAvoided: double.parse(totalKg.toStringAsFixed(2)),
      moneySavedEuros: double.parse(totalEuros.toStringAsFixed(2)),
      co2EqKgAvoided: double.parse(totalCo2.toStringAsFixed(2)),
    );
  }

  /// Range helpers
  static (DateTime start, DateTime end) currentMonth() {
    final now = DateTime.now();
    return (
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 1),
    );
  }
}
```

### Riverpod Provider

```dart
// lib/features/dashboard/presentation/providers/dashboard_providers.dart

final wasteMetricsServiceProvider = Provider<WasteMetricsService>(
  (_) => WasteMetricsService(),
);

final currentMonthMetricsProvider = Provider<WasteMetrics>((ref) {
  final consumed = ref.watch(consumedInventoryProvider);
  final service = ref.read(wasteMetricsServiceProvider);

  return consumed.maybeWhen(
    data: (products) {
      final (start, end) = WasteMetricsService.currentMonth();
      return service.computeMetrics(
        products,
        rangeStart: start,
        rangeEnd: end,
      );
    },
    orElse: () => WasteMetrics.zero(),
  );
});
```

> **Note**: Le provider est synchrone (`Provider<WasteMetrics>`) car `consumedInventoryProvider` est un `Provider<AsyncValue<List>>` déjà résolu depuis Hive. Pas de FutureProvider nécessaire pour Story 4.1.

### DashboardScreen

```dart
// lib/features/dashboard/presentation/screens/dashboard_screen.dart

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(currentMonthMetricsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Impact')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ce mois-ci',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            DashboardSummaryCard(metrics: metrics),
            // Stories 4.2/4.3/4.4 ajouteront des widgets ici
          ],
        ),
      ),
    );
  }
}
```

### DashboardSummaryCard

```dart
// lib/features/dashboard/presentation/widgets/dashboard_summary_card.dart

class DashboardSummaryCard extends StatelessWidget {
  final WasteMetrics metrics;

  const DashboardSummaryCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final isZero = metrics.wasteKgAvoided == 0 &&
        metrics.moneySavedEuros == 0;

    if (isZero) return _emptyState(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/dashboard/details'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('Impact anti-gaspi',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricTile(
                    icon: Icons.scale,
                    value: '${metrics.wasteKgAvoided} kg',
                    label: 'Gaspillage évité',
                    color: Colors.green,
                  ),
                  _MetricTile(
                    icon: Icons.euro,
                    value: '${metrics.moneySavedEuros} €',
                    label: 'Économisé',
                    color: Colors.blue,
                  ),
                  _MetricTile(
                    icon: Icons.cloud_off,
                    value: '${metrics.co2EqKgAvoided} kg',
                    label: 'CO2 évité',
                    color: Colors.teal,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.eco_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Commencez à consommer des produits pour voir votre impact anti-gaspi !',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey)),
      ],
    );
  }
}
```

### GoRouter — Mise à jour avec ShellRoute

```dart
// lib/core/routing/app_router.dart
// Ajouter dans ShellRoute (navigation tabs):

ShellRoute(
  builder: (context, state, child) => AppShell(child: child),
  routes: [
    GoRoute(
      path: '/inventory',
      builder: (_, __) => const InventoryListScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const DashboardScreen(),
      routes: [
        GoRoute(
          path: 'details',
          builder: (_, __) => const DashboardDetailsScreen(),  // placeholder Stories 4.2/4.3
        ),
      ],
    ),
    // ... autres tabs
  ],
),
```

### AppShell — Bottom Navigation Bar

```dart
// lib/core/widgets/app_shell.dart

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    (path: '/inventory', icon: Icons.inventory_2, label: 'Inventaire'),
    (path: '/dashboard', icon: Icons.eco, label: 'Impact'),
    // (path: '/settings', icon: Icons.settings, label: 'Paramètres')
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t.path));

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon),
          label: t.label,
        )).toList(),
      ),
    );
  }
}
```

### DashboardDetailsScreen — Placeholder

```dart
// lib/features/dashboard/presentation/screens/dashboard_details_screen.dart
// Placeholder pour Stories 4.2/4.3/4.4

class DashboardDetailsScreen extends StatelessWidget {
  const DashboardDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Métriques détaillées')),
      body: const Center(
        child: Text('Détails disponibles dans les Stories 4.2/4.3/4.4'),
      ),
    );
  }
}
```

### Tests

```dart
group('WasteMetricsService', () {
  final service = WasteMetricsService();
  final thisMonth = WasteMetricsService.currentMonth();

  test('zero metrics for empty list', () {
    final result = service.computeMetrics([], rangeStart: thisMonth.$1, rangeEnd: thisMonth.$2);
    expect(result, WasteMetrics.zero());
  });

  test('counts only products consumed within range', () {
    final lastMonth = ProductEntity(
      consumedAt: DateTime.now().subtract(const Duration(days: 40)),
      category: ProductCategory.fruitsLegumes, ...
    );
    final thisMonthProduct = ProductEntity(
      consumedAt: DateTime.now(),
      category: ProductCategory.fruitsLegumes, ...
    );
    final result = service.computeMetrics(
      [lastMonth, thisMonthProduct],
      rangeStart: thisMonth.$1, rangeEnd: thisMonth.$2,
    );
    // Only thisMonthProduct counted
    expect(result.wasteKgAvoided, 0.4);  // fruitsLegumes avg weight
  });

  test('computes CO2 as weight × factor', () {
    final product = ProductEntity(
      consumedAt: DateTime.now(),
      category: ProductCategory.viandesPoissons, ...
    );
    final result = service.computeMetrics(
      [product], rangeStart: thisMonth.$1, rangeEnd: thisMonth.$2,
    );
    // 0.35 kg × 12.0 CO2/kg = 4.2
    expect(result.co2EqKgAvoided, 4.20);
  });
});

group('DashboardSummaryCard', () {
  testWidgets('shows empty state when metrics are zero', (tester) async { ... });
  testWidgets('shows metrics when products consumed', (tester) async { ... });
  testWidgets('tapping navigates to /dashboard/details', (tester) async { ... });
});
```

### Project Structure Notes

- Feature directory: `lib/features/dashboard/` — non créé, à initialiser
- `consumedInventoryProvider` importé depuis `features/inventory/` → dépendance cross-feature via domain providers (acceptable)
- `WasteMetricsService` est pure (stateless, no injected deps) → facilement testable
- Freezed annotation sur `WasteMetrics` → `flutter pub run build_runner build`
- `DashboardDetailsScreen` = placeholder pour Stories 4.2-4.4 — ne pas investir dans son implémentation
- AppShell bottom nav: pour l'instant 2 tabs (inventory + dashboard) — extensible
- Les valeurs de poids/prix/CO2 sont des estimations — ajouter une note de source dans l'UI (tooltip ou footnote)

### References

- `consumedInventoryProvider` [Source: 2-4-mark-product-as-consumed.md]
- `ProductCategory` enum [Source: 2-1-add-product-manually-to-inventory.md]
- ShellRoute navigation pattern [Source: architecture.md#Navigation]
- CO2eq facteurs ADEME 2022 (estimation, non contractuel)
- Performance <1s: Hive-first via `consumedInventoryProvider` synchrone [Source: epics.md#Story-4.1]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
