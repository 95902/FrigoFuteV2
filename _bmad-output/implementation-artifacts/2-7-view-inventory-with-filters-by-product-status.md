# Story 2.7: View Inventory with Filters by Product Status

## 📋 Story Metadata

- **Story ID**: 2.7 | **Complexity**: 2 (XS — même pattern filtres 2.5/2.6)
- **Story Key**: 2-7-view-inventory-with-filters-by-product-status
- **Status**: ready-for-dev | **Effort**: 0.5 day
- **Dependencies**: Story 2.5, 2.6 (`combinedFilteredInventoryProvider`)

---

## 📖 User Story

**As a** Lucas (étudiant),
**I want** to filter my inventory by product status (fresh, expiring soon, expired),
**So that** I can prioritize what to use first and avoid waste.

---

## ✅ Acceptance Criteria

### AC1: Status Filter Chips
**Given** I am on the inventory screen
**When** I view the status filter section
**Then** I see chips: "Tous", "🟢 Frais", "🟡 Expire bientôt", "🔴 Expiré"
**And** each chip shows the count of products with that status

### AC2: Status Filter Logic
**Given** I select "Expire bientôt"
**Then** only products with `ProductStatus.expiringSoon` are shown
**And** "Expiring soon" threshold = configured alert window (default 2 days DLC / 5 days DDM)

### AC3: Expired Products Highlighted
**Given** the "Expiré" filter is selected OR no filter active
**Then** expired products show a red visual indicator (already handled by `_StatusBadge` Story 2.3)

### AC4: Combined with Category + Location
**Given** status + category + location filters are all active
**Then** only products matching ALL three filter types are shown

---

## 🏗️ Technical Specifications

### Extension de `combinedFilteredInventoryProvider`

```dart
// Ajouter dans inventory_filter_providers.dart

/// Selected status filters
final statusFilterProvider = StateProvider<Set<ProductStatus>>(
  (_) => const {},
);

/// Updated combinedFilteredInventoryProvider — add status filter
final combinedFilteredInventoryProvider =
    Provider<AsyncValue<List<ProductEntity>>>((ref) {
  final baseProducts = ref.watch(filteredInventoryProvider);
  final selectedCategories = ref.watch(categoryFilterProvider);
  final selectedLocations = ref.watch(locationFilterProvider);
  final selectedStatuses = ref.watch(statusFilterProvider);  // ← AJOUTER

  return baseProducts.whenData((products) {
    var filtered = products;
    if (selectedCategories.isNotEmpty) {
      filtered = filtered.where((p) => selectedCategories.contains(p.category)).toList();
    }
    if (selectedLocations.isNotEmpty) {
      filtered = filtered.where((p) => selectedLocations.contains(p.location)).toList();
    }
    if (selectedStatuses.isNotEmpty) {
      filtered = filtered.where((p) => selectedStatuses.contains(p.status)).toList();
    }
    return filtered;
  });
});

/// Count per status
final statusCountsProvider = Provider<Map<ProductStatus, int>>((ref) {
  final asyncProducts = ref.watch(filteredInventoryProvider);
  return asyncProducts.maybeWhen(
    data: (products) {
      final counts = <ProductStatus, int>{};
      for (final p in products) {
        counts[p.status] = (counts[p.status] ?? 0) + 1;
      }
      return counts;
    },
    orElse: () => {},
  );
});
```

### Status Filter Bar Widget

```dart
// lib/features/inventory/presentation/widgets/status_filter_bar.dart

class StatusFilterBar extends ConsumerWidget {
  const StatusFilterBar({super.key});

  static const Map<ProductStatus, (String, Color)> _statusConfig = {
    ProductStatus.fresh:        ('🟢 Frais', Colors.green),
    ProductStatus.expiringSoon: ('🟡 Expire bientôt', Colors.orange),
    ProductStatus.expired:      ('🔴 Expiré', Colors.red),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(statusFilterProvider);
    final counts = ref.watch(statusCountsProvider);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Tous'),
              selected: selected.isEmpty,
              onSelected: (_) =>
                  ref.read(statusFilterProvider.notifier).state = {},
            ),
          ),
          ..._statusConfig.entries.map((entry) {
            final status = entry.key;
            final (label, color) = entry.value;
            final count = counts[status] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('$label ($count)'),
                selected: selected.contains(status),
                selectedColor: color.withOpacity(0.2),
                onSelected: (isSelected) {
                  final current = Set<ProductStatus>.from(selected);
                  isSelected ? current.add(status) : current.remove(status);
                  ref.read(statusFilterProvider.notifier).state = current;
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

### InventoryListScreen — Add StatusFilterBar

```dart
// Ajouter après LocationFilterBar dans InventoryListScreen
const StatusFilterBar(),
```

---

## 📝 Implementation Tasks

- [ ] **T1**: Ajouter `statusFilterProvider`, `statusCountsProvider` dans `inventory_filter_providers.dart`
- [ ] **T2**: Mettre à jour `combinedFilteredInventoryProvider` → inclure status filter
- [ ] **T3**: Créer `StatusFilterBar` widget
- [ ] **T4**: Ajouter `StatusFilterBar` dans `InventoryListScreen`
- [ ] **T5**: Tests unitaires filter status dans `combinedFilteredInventoryProvider`
- [ ] **T6**: Tests widget `StatusFilterBar`
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

---

## ✅ Definition of Done

- [ ] Chips statut (Frais/Expire bientôt/Expiré) avec counts
- [ ] Filtre tri-dimensionnel (catégorie + emplacement + statut)
- [ ] `StatusFilterBar` dans `InventoryListScreen`
- [ ] Couverture ≥ 75%

---

**Story Created**: 2026-02-20 | **Ready for Dev**: ✅ Oui
