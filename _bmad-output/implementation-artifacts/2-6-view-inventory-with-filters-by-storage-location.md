# Story 2.6: View Inventory with Filters by Storage Location

## 📋 Story Metadata

- **Story ID**: 2.6
- **Epic**: Epic 2 - Inventory Management
- **Title**: View Inventory with Filters by Storage Location
- **Story Key**: 2-6-view-inventory-with-filters-by-storage-location
- **Status**: ready-for-dev
- **Complexity**: 2 (XS — même pattern que Story 2.5, différent enum)
- **Priority**: P1
- **Estimated Effort**: 0.5 day
- **Dependencies**:
  - Story 2.5 (**REQUIS** — `inventory_filter_providers.dart`, `CategoryFilterBar` pattern, `InventoryListScreen`)
- **Tags**: `inventory`, `filter`, `location`, `riverpod`, `ui`

---

## 📖 User Story

**As a** Marie (senior),
**I want** to filter my inventory by storage location (fridge, freezer, pantry),
**So that** I can see exactly what is in each location when I'm organizing my kitchen.

---

## ✅ Acceptance Criteria

### AC1: Location Filter Chips
**Given** I am on the inventory screen
**When** I view the filter bar
**Then** I see location filter chips for each location that has ≥ 1 active product
**And** each chip shows the location icon + name + count (e.g., "🧊 Réfrigérateur (5)")

### AC2: Multi-Location Filter (OR Logic)
**Given** I select one or more location chips
**Then** only products from the selected locations are shown
**And** I can combine location filter with category filter (AND between filter types)

### AC3: Filter Persistence and Clear
**Given** location filters are active
**When** I navigate away and return
**Then** the filters are still applied
**When** I tap "Tous" chip
**Then** location filters are cleared

### AC4: Combined Filters (Category AND Location)
**Given** I have both category AND location filters active
**When** the list is computed
**Then** only products matching BOTH the selected category AND the selected location are shown

---

## 🏗️ Technical Specifications

### Filter Providers Extension

Ajouter dans `lib/features/inventory/presentation/providers/inventory_filter_providers.dart` :

```dart
/// Selected location filters — empty = no location filter
final locationFilterProvider = StateProvider<Set<StorageLocation>>(
  (_) => const {},
);

/// Count of active products per location
final locationCountsProvider = Provider<Map<StorageLocation, int>>((ref) {
  final asyncProducts = ref.watch(filteredInventoryProvider);
  return asyncProducts.maybeWhen(
    data: (products) {
      final counts = <StorageLocation, int>{};
      for (final p in products) {
        counts[p.location] = (counts[p.location] ?? 0) + 1;
      }
      return counts;
    },
    orElse: () => {},
  );
});

/// Combined filter: category AND location AND (future: status, search)
final combinedFilteredInventoryProvider =
    Provider<AsyncValue<List<ProductEntity>>>((ref) {
  final baseProducts = ref.watch(filteredInventoryProvider);
  final selectedCategories = ref.watch(categoryFilterProvider);
  final selectedLocations = ref.watch(locationFilterProvider);

  return baseProducts.whenData((products) {
    var filtered = products;
    if (selectedCategories.isNotEmpty) {
      filtered = filtered
          .where((p) => selectedCategories.contains(p.category))
          .toList();
    }
    if (selectedLocations.isNotEmpty) {
      filtered = filtered
          .where((p) => selectedLocations.contains(p.location))
          .toList();
    }
    return filtered;
  });
});
```

> **IMPORTANT**: Remplacer `categoryFilteredInventoryProvider` par `combinedFilteredInventoryProvider` dans `InventoryListScreen` (Story 2.5). Le provider combiné gère tous les filtres actifs.

### Location Filter Bar Widget

```dart
// lib/features/inventory/presentation/widgets/location_filter_bar.dart

class LocationFilterBar extends ConsumerWidget {
  const LocationFilterBar({super.key});

  static const Map<StorageLocation, String> _locationLabels = {
    StorageLocation.refrigerateur: '🧊 Réfrigérateur',
    StorageLocation.congelateur: '❄️ Congélateur',
    StorageLocation.placard: '🗄️ Placard',
    StorageLocation.gardeManger: '🏠 Garde-manger',
    StorageLocation.comptoir: '🍽️ Comptoir',
    StorageLocation.autre: '📦 Autre',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocations = ref.watch(locationFilterProvider);
    final locationCounts = ref.watch(locationCountsProvider);

    final availableLocations = locationCounts.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();

    if (availableLocations.isEmpty) return const SizedBox.shrink();

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
              selected: selectedLocations.isEmpty,
              onSelected: (_) =>
                  ref.read(locationFilterProvider.notifier).state = {},
            ),
          ),
          ...availableLocations.map((loc) {
            final count = locationCounts[loc] ?? 0;
            final isSelected = selectedLocations.contains(loc);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${_locationLabels[loc] ?? loc.name} ($count)'),
                selected: isSelected,
                onSelected: (selected) {
                  final current = Set<StorageLocation>.from(selectedLocations);
                  selected ? current.add(loc) : current.remove(loc);
                  ref.read(locationFilterProvider.notifier).state = current;
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

### InventoryListScreen — Update for Combined Filters

```dart
// Mise à jour de InventoryListScreen (Story 2.5) :
// 1. Ajouter LocationFilterBar en dessous de CategoryFilterBar
// 2. Utiliser combinedFilteredInventoryProvider

body: Column(
  children: [
    const CategoryFilterBar(),
    const LocationFilterBar(),   // ← AJOUTER
    Expanded(
      child: ref.watch(combinedFilteredInventoryProvider).when(  // ← remplacer
        ...
      ),
    ),
  ],
),
```

---

## 📝 Implementation Tasks

- [ ] **T1**: Ajouter `locationFilterProvider`, `locationCountsProvider`, `combinedFilteredInventoryProvider` dans `inventory_filter_providers.dart`
- [ ] **T2**: Créer `LocationFilterBar` widget
- [ ] **T3**: Mettre à jour `InventoryListScreen` → `LocationFilterBar` + `combinedFilteredInventoryProvider`
- [ ] **T4**: Tester combinaison catégorie + emplacement (AC4)
- [ ] **T5**: Tests unitaires `combinedFilteredInventoryProvider`
- [ ] **T6**: Tests widget `LocationFilterBar`
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

---

## 🧪 Testing Strategy

```dart
group('combinedFilteredInventoryProvider', () {
  test('applies category AND location filters (intersection)', ...);
  test('no filter = all active products', ...);
  test('location only filter works', ...);
  test('category + location = strict intersection', ...);
});
```

---

## ⚠️ Anti-Patterns à Éviter

```dart
// ❌ Deux providers séparés (categoryFilteredInventoryProvider ET locationFilteredInventoryProvider)
// Cela crée une ambiguïté sur lequel utiliser dans l'UI

// ✅ Un seul combinedFilteredInventoryProvider gérant tous les filtres actifs
// Facilement extensible pour Story 2.7 (status) et 2.11 (search)
```

---

## 🔗 Points d'Intégration

- **Story 2.5** : `categoryFilteredInventoryProvider` → remplacer par `combinedFilteredInventoryProvider`
- **Story 2.7** : ajouter `statusFilterProvider` dans `combinedFilteredInventoryProvider`
- **Story 2.11** : ajouter `searchQueryProvider` dans `combinedFilteredInventoryProvider`

---

## ✅ Definition of Done

- [ ] Location chips avec icônes et counts
- [ ] Filtre combiné catégorie + emplacement (AND logic inter-types)
- [ ] `combinedFilteredInventoryProvider` remplace `categoryFilteredInventoryProvider`
- [ ] `LocationFilterBar` dans `InventoryListScreen`
- [ ] Couverture ≥ 75% | `flutter analyze` 0 erreurs

---

**Story Created**: 2026-02-20 | **Ready for Dev**: ✅ Oui
