# Story 6.6: Receive Recipe Suggestions for Products Expiring Soon

Status: ready-for-dev

## Story

As a Marie (senior),
I want to receive recipe suggestions when products are about to expire,
so that I can use them in time and avoid waste.

## Acceptance Criteria

1. **Given** I have products expiring within 2 days in my inventory
   **When** I view my dashboard
   **Then** I see suggested recipes that prioritize using the expiring products
   **And** suggestions are contextual: "Utilisez vos tomates qui expirent bientôt dans cette recette !"

2. **Given** I receive an expiration notification (Story 3.1)
   **When** I tap "Voir les recettes suggérées"
   **Then** I navigate to the recipes screen pre-filtered to show recipes using the expiring product

3. **Given** the dashboard shows expiring product suggestions
   **When** I tap a suggested recipe
   **Then** I navigate to the recipe detail screen

4. **Given** there are no products expiring within 2 days
   **Then** the suggestions section is hidden

## Tasks / Subtasks

- [ ] **T1**: Créer `ExpiringProductsRecipeSuggester` service (AC: 1)
  - [ ] `getSuggestionsForExpiringProducts(List<ProductEntity>, List<RecipeEntity>)` → `List<ExpirationRecipeSuggestion>`
  - [ ] `ExpirationRecipeSuggestion`: recipe + expiringProductName + contextMessage
  - [ ] Filtrer produits expirant dans ≤ 2 jours (DLC) ou ≤ 5 jours (DDM)
  - [ ] Matcher ces produits avec les ingrédients des recettes (même logique que Story 6.1)
- [ ] **T2**: Créer `expiringRecipeSuggestionsProvider` (AC: 1, 4)
  - [ ] Lit `inventoryStreamProvider` + `recipesStreamProvider`
  - [ ] Retourne `List<ExpirationRecipeSuggestion>` (max 3 suggestions)
- [ ] **T3**: Créer `ExpiringSuggestionCard` widget pour Dashboard (AC: 1, 3)
  - [ ] Section "À cuisiner avant qu'il ne soit trop tard !"
  - [ ] Max 3 recettes affichées horizontalement (HorizontalRecipeList)
  - [ ] Cachée si liste vide (AC: 4)
- [ ] **T4**: Intégrer dans `DashboardScreen` (AC: 1)
  - [ ] Sous le `DashboardSummaryCard` de Story 4.1
- [ ] **T5**: Modifier notification deep link (Story 3.1) pour pre-filtrer les recettes (AC: 2)
  - [ ] Deep link: `frigofute://recipes?expiringProduct={productName}`
  - [ ] `RecipesScreen` lit le query param et pre-filtre
- [ ] **T6**: Tests unitaires `ExpiringProductsRecipeSuggester` (AC: 1)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### ExpirationRecipeSuggestion entity

```dart
// lib/features/recipes/domain/entities/expiration_recipe_suggestion.dart

@freezed
class ExpirationRecipeSuggestion with _$ExpirationRecipeSuggestion {
  const factory ExpirationRecipeSuggestion({
    required RecipeEntity recipe,
    required String expiringProductName,
    required int daysUntilExpiry,
    required String contextMessage,  // Message contextuel pour l'UI
  }) = _ExpirationRecipeSuggestion;

  const ExpirationRecipeSuggestion._();

  String get urgencyEmoji => daysUntilExpiry <= 1 ? '🚨' : '⚠️';
}
```

### ExpiringProductsRecipeSuggester

```dart
// lib/features/recipes/domain/services/expiring_products_recipe_suggester.dart

class ExpiringProductsRecipeSuggester {
  static const int _dlcThresholdDays = 2;
  static const int _ddmThresholdDays = 5;
  static const int _maxSuggestions = 3;

  List<ExpirationRecipeSuggestion> getSuggestions(
    List<ProductEntity> inventory,
    List<RecipeEntity> recipes,
  ) {
    final now = DateTime.now();
    final suggestions = <ExpirationRecipeSuggestion>[];

    // Produits expirant bientôt
    final expiring = inventory.where((p) {
      if (p.expirationDate == null) return false;
      if (p.status == ProductStatus.consumed || p.status == ProductStatus.expired) return false;
      final daysLeft = p.expirationDate!.difference(now).inDays;
      final threshold = p.expiryType == ExpiryType.dlc ? _dlcThresholdDays : _ddmThresholdDays;
      return daysLeft <= threshold && daysLeft >= 0;
    }).toList();

    if (expiring.isEmpty) return [];

    // Pour chaque produit expirant, trouver une recette qui l'utilise
    final normalizer = RecipeMatchingService();  // Pour normalisation noms
    for (final product in expiring) {
      if (suggestions.length >= _maxSuggestions) break;

      final productName = product.name.toLowerCase();
      for (final recipe in recipes) {
        final usesProduct = recipe.ingredients.any((ing) {
          final ingName = ing.name.toLowerCase();
          return ingName.contains(productName) || productName.contains(ingName);
        });

        if (usesProduct) {
          final daysLeft = product.expirationDate!.difference(now).inDays;
          suggestions.add(ExpirationRecipeSuggestion(
            recipe: recipe,
            expiringProductName: product.name,
            daysUntilExpiry: daysLeft,
            contextMessage: 'Utilisez vos ${product.name} qui expirent dans $daysLeft jour(s) !',
          ));
          break;  // Une recette par produit expirant
        }
      }
    }

    return suggestions;
  }
}
```

### Provider

```dart
// lib/features/recipes/presentation/providers/recipe_providers.dart

final expiringRecipeSuggestionsProvider = Provider<List<ExpirationRecipeSuggestion>>((ref) {
  final inventory = ref.watch(inventoryStreamProvider).valueOrNull ?? [];
  final recipes = ref.watch(recipesStreamProvider).valueOrNull ?? [];
  return ExpiringProductsRecipeSuggester().getSuggestions(inventory, recipes);
});
```

### ExpiringSuggestionSection dans DashboardScreen

```dart
// lib/features/dashboard/presentation/screens/dashboard_screen.dart

// Ajouter dans DashboardScreen.build():
Consumer(
  builder: (context, ref, _) {
    final suggestions = ref.watch(expiringRecipeSuggestionsProvider);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '🍳 À cuisiner avant qu\'il soit trop tard !',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: suggestions.length,
            itemBuilder: (context, i) => _SuggestionCard(suggestion: suggestions[i]),
          ),
        ),
      ],
    );
  },
),
```

### Project Structure Notes

- `expiringRecipeSuggestionsProvider` utilise `inventoryStreamProvider` via shared providers
- Cross-feature: Dashboard utilise le provider recipes → doit passer par shared provider (pas import direct)
- Exposer `expiringRecipeSuggestionsProvider` dans `lib/core/shared/providers/recipe_shared_providers.dart`

### References

- [Source: epics.md#Story-6.6]
- ProductStatus.expiringSoon [Source: Story 2.10]
- ExpiryType DLC/DDM thresholds [Source: Story 3.4, 3.5]
- DashboardScreen [Source: Story 4.1]
- inventoryStreamProvider [Source: Story 2.1, shared]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
