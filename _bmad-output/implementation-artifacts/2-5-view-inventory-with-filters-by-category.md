# Story 2.5: View Inventory with Filters by Category

## 📋 Story Metadata

- **Story ID**: 2.5
- **Epic**: Epic 2 - Inventory Management
- **Title**: View Inventory with Filters by Category
- **Story Key**: 2-5-view-inventory-with-filters-by-category
- **Status**: ready-for-dev
- **Complexity**: 3 (S — client-side filter over existing Hive stream)
- **Priority**: P1 (Core UX — inventory navigation)
- **Estimated Effort**: 1 day
- **Dependencies**:
  - Story 2.1 (**REQUIS** — `ProductEntity`, `ProductCategory` enum, `filteredInventoryProvider`)
  - Story 2.3/2.4 (`filteredInventoryProvider` already excludes deleted/consumed)
- **Tags**: `inventory`, `filter`, `category`, `riverpod`, `ui`

---

## 📖 User Story

**As a** Sophie (famille),
**I want** to filter my inventory by food category (dairy, vegetables, meat, etc.),
**So that** I can quickly see what I have in each category and plan my meals.

---

## ✅ Acceptance Criteria

### AC1: Category Filter Chips
**Given** I am on the inventory screen
**When** I view the filter bar
**Then** I see filter chips for each category that has ≥ 1 active product
**And** each chip shows the category name and product count (e.g., "Produits laitiers (3)")
**And** an "Tous" chip is shown first, selected by default

### AC2: Single and Multi-Category Filter
**Given** I tap one or more category chips
**When** a chip is selected
**Then** the inventory list shows only products matching ANY selected category (OR logic)
**And** selected chips are visually highlighted (filled style)
**And** I can select multiple categories simultaneously

### AC3: Clear Filters
**Given** one or more category filters are active
**When** I tap "Tous" or tap the last active chip to deselect it
**Then** all category filters are cleared
**And** the full active inventory is displayed

### AC4: Filter State Preserved on Navigation
**Given** I have category filters applied
**When** I navigate to a product detail and come back
**Then** the same filters are still applied
**And** the inventory list reflects the current filter state

### AC5: Empty State When No Results
**Given** I have selected categories that match no products
**When** the filtered list is empty
**Then** I see a message: "Aucun produit dans cette catégorie"
**And** I see a "Effacer les filtres" button

### AC6: Count Badge Reflects Active Products Only
**Given** some products are consumed or deleted
**When** I view category chip counts
**Then** counts include only active (non-consumed, non-deleted) products

---

## 🏗️ Technical Specifications

### 1. Filter State — Riverpod

```dart
// lib/features/inventory/presentation/providers/inventory_filter_providers.dart

/// Selected category filters — empty set = "Tous" (no filter)
final categoryFilterProvider = StateProvider<Set<ProductCategory>>(
  (_) => const {},
);

/// Products filtered by selected categories (builds on filteredInventoryProvider)
final categoryFilteredInventoryProvider =
    Provider<AsyncValue<List<ProductEntity>>>((ref) {
  final baseProducts = ref.watch(filteredInventoryProvider);
  final selectedCategories = ref.watch(categoryFilterProvider);

  if (selectedCategories.isEmpty) return baseProducts;

  return baseProducts.whenData(
    (products) => products
        .where((p) => selectedCategories.contains(p.category))
        .toList(),
  );
});

/// Count of active products per category
final categoryCountsProvider = Provider<Map<ProductCategory, int>>((ref) {
  final asyncProducts = ref.watch(filteredInventoryProvider);
  return asyncProducts.maybeWhen(
    data: (products) {
      final counts = <ProductCategory, int>{};
      for (final p in products) {
        counts[p.category] = (counts[p.category] ?? 0) + 1;
      }
      return counts;
    },
    orElse: () => {},
  );
});
```

---

### 2. UI — Category Filter Bar Widget

```dart
// lib/features/inventory/presentation/widgets/category_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/inventory_filter_providers.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategories = ref.watch(categoryFilterProvider);
    final categoryCounts = ref.watch(categoryCountsProvider);

    // Only show categories that have products
    final availableCategories = categoryCounts.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList()
      ..sort((a, b) => _categoryLabel(a).compareTo(_categoryLabel(b)));

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "Tous" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Tous'),
              selected: selectedCategories.isEmpty,
              onSelected: (_) =>
                  ref.read(categoryFilterProvider.notifier).state = {},
            ),
          ),
          // Category chips
          ...availableCategories.map((cat) {
            final count = categoryCounts[cat] ?? 0;
            final isSelected = selectedCategories.contains(cat);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${_categoryLabel(cat)} ($count)'),
                selected: isSelected,
                onSelected: (selected) {
                  final current =
                      Set<ProductCategory>.from(selectedCategories);
                  if (selected) {
                    current.add(cat);
                  } else {
                    current.remove(cat);
                  }
                  ref.read(categoryFilterProvider.notifier).state = current;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _categoryLabel(ProductCategory cat) {
    const labels = {
      ProductCategory.produitsLaitiers: 'Produits laitiers',
      ProductCategory.viandesPoissons: 'Viandes & Poissons',
      ProductCategory.fruitsLegumes: 'Fruits & Légumes',
      ProductCategory.epicerieSucree: 'Épicerie sucrée',
      ProductCategory.epicerieSalee: 'Épicerie salée',
      ProductCategory.surgeles: 'Surgelés',
      ProductCategory.boissons: 'Boissons',
      ProductCategory.boulangerie: 'Boulangerie',
      ProductCategory.platsPrepares: 'Plats préparés',
      ProductCategory.saucesCondiments: 'Sauces & Condiments',
      ProductCategory.oeufs: 'Œufs',
      ProductCategory.autre: 'Autre',
    };
    return labels[cat] ?? cat.name;
  }
}
```

---

### 3. UI — Inventory List Screen Integration

```dart
// lib/features/inventory/presentation/screens/inventory_list_screen.dart

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(categoryFilteredInventoryProvider);
    final selectedCategories = ref.watch(categoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Inventaire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/inventory/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          const CategoryFilterBar(),
          Expanded(
            child: asyncProducts.when(
              data: (products) {
                if (products.isEmpty) {
                  return _EmptyState(
                    hasFilters: selectedCategories.isNotEmpty,
                    onClearFilters: () =>
                        ref.read(categoryFilterProvider.notifier).state = {},
                  );
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (_, i) => ProductCard(product: products[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyState({required this.hasFilters, required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? 'Aucun produit dans cette catégorie'
                : 'Votre inventaire est vide',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClearFilters,
              child: const Text('Effacer les filtres'),
            ),
          ] else ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.push('/inventory/add'),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un produit'),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 📝 Implementation Tasks

- [ ] **T1**: Créer `inventory_filter_providers.dart` avec `categoryFilterProvider`, `categoryFilteredInventoryProvider`, `categoryCountsProvider`
- [ ] **T2**: Créer `CategoryFilterBar` widget (FilterChip horizontal scrollable)
- [ ] **T3**: Créer/compléter `InventoryListScreen` avec `CategoryFilterBar` + `categoryFilteredInventoryProvider`
- [ ] **T4**: Ajouter route `/inventory` dans GoRouter
- [ ] **T5**: Tests unitaires providers — filtre par catégorie, clear filtre, counts
- [ ] **T6**: Tests widget `CategoryFilterBar` — sélection, multi-sélection, clear
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

---

## 🧪 Testing Strategy

```dart
group('categoryFilteredInventoryProvider', () {
  test('returns all products when no filter selected', ...);
  test('returns only matching products when filter active', ...);
  test('returns union when multiple categories selected', ...);
  test('returns empty list when no products match filter', ...);
});

group('categoryCountsProvider', () {
  test('counts only active (non-consumed) products', ...);
  test('excludes categories with 0 products', ...);
});

group('CategoryFilterBar', () {
  testWidgets('shows Tous chip selected by default', ...);
  testWidgets('shows chips only for categories with products', ...);
  testWidgets('tapping chip adds to selected set', ...);
  testWidgets('tapping Tous clears all filters', ...);
  testWidgets('chip shows correct product count', ...);
});
```

---

## ⚠️ Anti-Patterns à Éviter

```dart
// ❌ Filtrer dans Firestore (requête réseau pour chaque filtre)
FirebaseFirestore.instance.collection('inventory_items')
    .where('category', isEqualTo: 'produitsLaitiers')  // ❌ réseau

// ✅ Filtrer côté client sur le stream Hive (instantané, offline-first)
final products = ref.watch(filteredInventoryProvider);
final filtered = products.where((p) => selectedCategories.contains(p.category));

// ❌ Recréer la liste à chaque rebuild sans Provider
// ✅ Utiliser categoryFilteredInventoryProvider (mémoïsé par Riverpod)
```

---

## 🔗 Points d'Intégration

- **Story 2.6** (Filters by Location) : `locationFilterProvider` sera ajouté en parallèle — combiner avec `categoryFilterProvider` dans un `combinedFilterProvider`
- **Story 2.7** (Filters by Status) : même pattern — tri-filter combiné
- **Story 2.11** (Search) : `searchQueryProvider` s'ajoutera à la chaîne de filtres
- **Architecture** : les indexes Firestore composites (category + expirationDate) créés en Story 2.1 sont utilisés pour les futures queries Firestore de l'Epic 4 Dashboard, pas pour le filtre client-side ici

---

## ✅ Definition of Done

- [ ] Chips de filtre visibles avec counts corrects (actifs seulement)
- [ ] Multi-sélection fonctionnelle (OR logic)
- [ ] "Tous" efface tous les filtres
- [ ] État filtre préservé à la navigation
- [ ] Empty state correct avec/sans filtre actif
- [ ] Route `/inventory` dans GoRouter
- [ ] Couverture ≥ 75% | `flutter analyze` 0 erreurs

---

## 📎 Références

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.5]
- [Source: _bmad-output/implementation-artifacts/2-1-add-product-manually-to-inventory.md — ProductCategory enum]
- [Source: _bmad-output/implementation-artifacts/2-3-delete-product-from-inventory.md — filteredInventoryProvider]

---

## 🤖 Dev Agent Record

### Agent Model Used
claude-sonnet-4-6

### Debug Log References
*(à remplir)*

### Completion Notes List
*(à remplir)*

### File List
*(à remplir)*

---

**Story Created**: 2026-02-20 | **Ready for Dev**: ✅ Oui
