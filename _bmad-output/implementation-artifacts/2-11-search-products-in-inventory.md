# Story 2.11: Search Products in Inventory

## 📋 Story Metadata

- **Story ID**: 2.11 | **Complexity**: 2 (XS — même pattern filtres 2.5/2.6/2.7 + SearchBar widget)
- **Story Key**: 2-11-search-products-in-inventory
- **Status**: ready-for-dev | **Effort**: 0.5 day
- **Dependencies**: Story 2.5, 2.6, 2.7 (`combinedFilteredInventoryProvider`)

---

## 📖 User Story

**As a** Lucas (étudiant),
**I want** to search for specific products by name in my inventory,
**So that** I can quickly find what I'm looking for without scrolling.

---

## ✅ Acceptance Criteria

### AC1: Barre de recherche
**Given** je suis sur l'écran inventaire
**When** je tape dans la barre de recherche
**Then** la liste filtre en temps réel (latence < 50ms)
**And** la recherche est insensible à la casse
**And** la recherche est insensible aux accents ("toma" trouve "Tomates")
**And** la recherche est partielle ("tom" trouve "Tomates rôties")

### AC2: Clear search
**Given** j'ai tapé une recherche
**When** je tape la croix (clear) ou efface tout le texte
**Then** tous les produits sont de nouveau affichés
**And** les autres filtres actifs (catégorie, emplacement, statut) restent en place

### AC3: Empty state dédié
**Given** la recherche ne correspond à aucun produit
**Then** j'affiche: "Aucun produit correspond à \"[query]\""
**And** un bouton "Effacer la recherche" est visible

### AC4: Performance
**Given** j'ai 1000 produits dans mon inventaire
**When** je tape caractère par caractère
**Then** la liste se met à jour sans lag perceptible
**And** le filtre est debounced 300ms pour les grosses listes

### AC5: Combiné avec les autres filtres
**Given** catégorie + emplacement + statut + recherche sont tous actifs
**Then** seuls les produits correspondant à TOUS les critères sont affichés

---

## 🏗️ Technical Specifications

### Extension de `combinedFilteredInventoryProvider`

```dart
// Ajouter dans inventory_filter_providers.dart

/// Search query — empty string = no search filter
final searchQueryProvider = StateProvider<String>((_) => '');

/// Updated combinedFilteredInventoryProvider — add search filter (4th dimension)
final combinedFilteredInventoryProvider =
    Provider<AsyncValue<List<ProductEntity>>>((ref) {
  final baseProducts = ref.watch(filteredInventoryProvider);
  final selectedCategories = ref.watch(categoryFilterProvider);
  final selectedLocations = ref.watch(locationFilterProvider);
  final selectedStatuses = ref.watch(statusFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);

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
    if (selectedStatuses.isNotEmpty) {
      filtered = filtered
          .where((p) => selectedStatuses.contains(p.status))
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      final normalizedQuery = _normalize(searchQuery);
      filtered = filtered
          .where((p) => _normalize(p.name).contains(normalizedQuery))
          .toList();
    }

    return filtered;
  });
});

String _normalize(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[àâä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[îï]'), 'i')
      .replaceAll(RegExp(r'[ôö]'), 'o')
      .replaceAll(RegExp(r'[ùûü]'), 'u')
      .replaceAll(RegExp(r'[ç]'), 'c');
}
```

> **Note**: La fonction `_normalize` peut être extraite dans un utility file partagé avec `ProductCategorizationService` (Story 2.8).

### InventorySearchBar Widget

```dart
// lib/features/inventory/presentation/widgets/inventory_search_bar.dart

class InventorySearchBar extends ConsumerStatefulWidget {
  const InventorySearchBar({super.key});

  @override
  ConsumerState<InventorySearchBar> createState() => _InventorySearchBarState();
}

class _InventorySearchBarState extends ConsumerState<InventorySearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value.trim();
    });
  }

  void _onClear() {
    _controller.clear();
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher un produit...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _onClear,
                )
              : null,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
```

### InventoryListScreen — Mise à jour

```dart
// Ajouter InventorySearchBar en tête du body Column
// Mettre à jour _EmptyState pour afficher le message de recherche

body: Column(
  children: [
    const InventorySearchBar(),     // ← AJOUTER en premier
    const CategoryFilterBar(),
    const LocationFilterBar(),
    const StatusFilterBar(),
    Expanded(
      child: ref.watch(combinedFilteredInventoryProvider).when(
        data: (products) {
          if (products.isEmpty) {
            return _EmptyState(
              hasFilters: _hasActiveFilters(ref),
              searchQuery: ref.watch(searchQueryProvider),
              onClearSearch: () =>
                  ref.read(searchQueryProvider.notifier).state = '',
              onClearFilters: _clearAllFilters,
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

bool _hasActiveFilters(WidgetRef ref) {
  return ref.watch(categoryFilterProvider).isNotEmpty ||
      ref.watch(locationFilterProvider).isNotEmpty ||
      ref.watch(statusFilterProvider).isNotEmpty ||
      ref.watch(searchQueryProvider).isNotEmpty;
}
```

### Mise à jour _EmptyState

```dart
class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final String searchQuery;
  final VoidCallback onClearSearch;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilters,
    required this.searchQuery,
    required this.onClearSearch,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty
                ? 'Aucun produit correspond à "$searchQuery"'
                : hasFilters
                    ? 'Aucun produit dans cette sélection'
                    : 'Votre inventaire est vide',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClearSearch,
              child: const Text('Effacer la recherche'),
            ),
          ] else if (hasFilters) ...[
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

- [ ] **T1**: Ajouter `searchQueryProvider` dans `inventory_filter_providers.dart`
- [ ] **T2**: Mettre à jour `combinedFilteredInventoryProvider` → 4ème filtre (search)
- [ ] **T3**: Extraire `_normalize()` en util partagé (`lib/core/utils/string_utils.dart`)
- [ ] **T4**: Créer `InventorySearchBar` widget (debounce 300ms)
- [ ] **T5**: Mettre à jour `InventoryListScreen` — ajouter `InventorySearchBar`, update `_EmptyState`
- [ ] **T6**: Tests unitaires `combinedFilteredInventoryProvider` — recherche partielle, insensible casse/accents
- [ ] **T7**: Tests widget `InventorySearchBar` — debounce, clear, provider update
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

---

## 🧪 Testing Strategy

```dart
group('combinedFilteredInventoryProvider — search', () {
  test('search "tom" finds "Tomates cerises"', ...);
  test('search "LAIT" finds "lait entier" (case-insensitive)', ...);
  test('search "creme" finds "Crème fraîche" (diacritics-insensitive)', ...);
  test('empty search returns all products', ...);
  test('search + category filter = intersection', ...);
});

group('InventorySearchBar', () {
  testWidgets('shows clear button when query is not empty', (tester) async { ... });
  testWidgets('clear button resets searchQueryProvider', (tester) async { ... });
  testWidgets('typing updates provider after debounce', (tester) async {
    // pump + timer 300ms
  });
});
```

---

## ⚠️ Anti-Patterns à Éviter

```dart
// ❌ Mettre à jour le provider à chaque frappe sans debounce
onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v;  // ❌ rebuild excessif

// ✅ Debounce 300ms via Timer
_debounce = Timer(const Duration(milliseconds: 300), () {
  ref.read(searchQueryProvider.notifier).state = value;  // ✅
});

// ❌ Chercher dans Firestore pour chaque caractère tapé
// ✅ Filter client-side sur le stream Hive (offline-first, instantané)
```

---

## 🔗 Points d'Intégration

- **Story 2.5/2.6/2.7** : `combinedFilteredInventoryProvider` étendu (4ème dimension)
- **Story 2.8** : `_normalize()` partagé entre categorization et search
- **Story 2.12** : La recherche fonctionne offline par défaut (filtre client-side Hive)

---

## ✅ Definition of Done

- [ ] `searchQueryProvider` + `combinedFilteredInventoryProvider` mis à jour
- [ ] `InventorySearchBar` avec debounce 300ms + clear
- [ ] `_EmptyState` mis à jour avec message de recherche contextuel
- [ ] `_normalize()` extrait en util partagé
- [ ] Recherche partielle + insensible casse + accents
- [ ] `flutter analyze` 0 erreurs | couverture ≥ 75%

---

**Story Created**: 2026-02-21 | **Ready for Dev**: ✅ Oui
