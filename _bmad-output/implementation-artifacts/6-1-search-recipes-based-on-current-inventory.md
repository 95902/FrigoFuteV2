# Story 6.1: Search Recipes Based on Current Inventory

Status: ready-for-dev

## Story

As a Sophie (famille),
I want to find recipes that I can make with the ingredients I already have,
so that I can cook without needing to go shopping.

## Acceptance Criteria

1. **Given** I have products in my inventory
   **When** I navigate to the "Recipes" screen
   **Then** the app displays recipes that match at least 70% of ingredients with my inventory
   **And** recipes are sorted by match percentage (highest first)
   **And** each recipe shows which ingredients I have and which I'm missing

2. **Given** I want to cook with only what I have
   **When** I tap "Seulement ce que j'ai"
   **Then** only recipes with 100% ingredient match are displayed

3. **Given** the recipe list is displayed
   **When** the matching computation completes
   **Then** search results appear in less than 1 second
   **And** no network request blocks the render (recipes cached locally in Hive)

4. **Given** I tap a recipe in the list
   **Then** I navigate to the recipe detail screen (`/recipes/detail`)
   **Note**: Detail screen implemented in Story 6.8 — Story 6.1 creates a placeholder

## Tasks / Subtasks

- [ ] **T1**: Créer `RecipeEntity` (Freezed) + `RecipeModel` (Hive TypeAdapter) (AC: 1)
  - [ ] `id`, `name`, `ingredients` (`List<IngredientRef>`), `instructions`, `prepTimeMinutes`, `difficulty`, `tags`, `imageUrl`, `nutritionPer100g`
  - [ ] `IngredientRef`: `name`, `quantityG`, `unit`, `category`
  - [ ] Hive TypeAdapter avec `hive_ce_generator`
- [ ] **T2**: Créer `RecipeRepository` — chargement depuis Firestore + cache Hive (AC: 3)
  - [ ] `getRecipes()` → StreamProvider depuis `recipes_box` (offline-first)
  - [ ] Background sync depuis `shared/recipes` Firestore
  - [ ] Cache toutes les recettes localement au premier chargement
- [ ] **T3**: Créer `RecipeMatchingService.matchWithInventory()` (AC: 1, 2)
  - [ ] `matchWithInventory(List<RecipeEntity> recipes, List<ProductEntity> inventory)` → `List<RecipeMatch>`
  - [ ] `RecipeMatch`: recette + `matchPercent` (0–100) + `presentIngredients` + `missingIngredients`
  - [ ] Filtrer ≥ 70% match
  - [ ] Normalisation noms: lowercase + suppression accents (réutiliser `_normalize()` de Story 2.11)
- [ ] **T4**: Créer `recipesProvider` et `recipeMatchesProvider` (AC: 1, 3)
  - [ ] `recipeMatchesProvider = Provider<List<RecipeMatch>>` — lit inventory + recipes en local
  - [ ] `onlyFullMatchFilterProvider = StateProvider<bool>((ref) => false)` (AC: 2)
  - [ ] `filteredRecipeMatchesProvider` — applique filtre 100% si activé
- [ ] **T5**: Créer `RecipesScreen` avec `RecipeMatchCard` (AC: 1, 2, 4)
  - [ ] `AppBar` avec titre "Recettes"
  - [ ] Toggle "Seulement ce que j'ai" (Switch ou FilterChip)
  - [ ] `ListView.builder` avec `RecipeMatchCard`
  - [ ] GoRouter route `/recipes`
- [ ] **T6**: Créer `RecipeMatchCard` widget (AC: 1)
  - [ ] `CachedNetworkImage` pour image recette
  - [ ] Badge match % coloré (vert si ≥ 90%, orange si 70–89%)
  - [ ] Liste courte des ingrédients manquants (max 3 affichés, puis "+ X autres")
- [ ] **T7**: Ajouter onglet "Recettes" dans `AppShell` NavigationBar (AC: 1)
- [ ] **T8**: Route `/recipes/detail` placeholder dans GoRouter (AC: 4)
- [ ] **T9**: Packages à ajouter dans pubspec.yaml (AC: 1, 3)
  - [ ] `cached_network_image: ^3.4.0`
  - [ ] `flutter_staggered_grid_view: ^0.7.0` (optionnel — pour grille future)
- [ ] **T10**: Tests unitaires `RecipeMatchingService` (AC: 1, 2)
- [ ] **T11**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### RecipeEntity + IngredientRef

```dart
// lib/features/recipes/domain/entities/recipe_entity.dart

@freezed
class RecipeEntity with _$RecipeEntity {
  const factory RecipeEntity({
    required String id,
    required String name,
    required List<IngredientRef> ingredients,
    required List<String> instructions,
    required int prepTimeMinutes,
    required RecipeDifficulty difficulty,
    @Default([]) List<String> tags,        // ex: ['vegan', 'gluten-free', 'rapide']
    String? imageUrl,
    NutritionData? nutritionPer100g,       // NutritionData de Epic 5
    @Default(0) double costPerPortionEuros,
    @Default(1) int defaultServings,
  }) = _RecipeEntity;

  factory RecipeEntity.fromJson(Map<String, dynamic> json) =>
      _$RecipeEntityFromJson(json);
}

@freezed
class IngredientRef with _$IngredientRef {
  const factory IngredientRef({
    required String name,               // "tomates cerises"
    required double quantityG,          // en grammes
    @Default('g') String unit,          // 'g', 'ml', 'pièce(s)'
    ProductCategory? category,          // pour matching avec inventory
  }) = _IngredientRef;

  factory IngredientRef.fromJson(Map<String, dynamic> json) =>
      _$IngredientRefFromJson(json);
}

enum RecipeDifficulty { easy, medium, hard }
```

### RecipeModel (Hive)

```dart
// lib/features/recipes/data/models/recipe_model.dart
// IMPORTANT: Ne pas importer recipe_model depuis d'autres features — shared via providers

@HiveType(typeId: 20)  // Vérifier disponibilité typeId dans le projet
class RecipeModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) List<String> ingredientNames;    // Noms pour matching rapide
  @HiveField(3) String ingredientsJson;          // JSON complet IngredientRef[]
  @HiveField(4) List<String> instructions;
  @HiveField(5) int prepTimeMinutes;
  @HiveField(6) int difficultyIndex;             // RecipeDifficulty.index
  @HiveField(7) List<String> tags;
  @HiveField(8) String? imageUrl;
  @HiveField(9) double costPerPortionEuros;

  RecipeModel({
    required this.id,
    required this.name,
    required this.ingredientNames,
    required this.ingredientsJson,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.difficultyIndex,
    required this.tags,
    this.imageUrl,
    this.costPerPortionEuros = 0,
  });

  RecipeEntity toEntity() => RecipeEntity(
    id: id,
    name: name,
    ingredients: (jsonDecode(ingredientsJson) as List)
        .map((e) => IngredientRef.fromJson(e as Map<String, dynamic>))
        .toList(),
    instructions: instructions,
    prepTimeMinutes: prepTimeMinutes,
    difficulty: RecipeDifficulty.values[difficultyIndex],
    tags: tags,
    imageUrl: imageUrl,
    costPerPortionEuros: costPerPortionEuros,
  );
}
```

### RecipeMatch entity

```dart
// lib/features/recipes/domain/entities/recipe_match.dart

@freezed
class RecipeMatch with _$RecipeMatch {
  const factory RecipeMatch({
    required RecipeEntity recipe,
    required double matchPercent,           // 0.0 – 100.0
    required List<IngredientRef> presentIngredients,
    required List<IngredientRef> missingIngredients,
  }) = _RecipeMatch;

  const RecipeMatch._();

  bool get isFullMatch => missingIngredients.isEmpty;
  bool get isMostlyMatch => matchPercent >= 70;
}
```

### RecipeMatchingService

```dart
// lib/features/recipes/domain/services/recipe_matching_service.dart

class RecipeMatchingService {
  /// Match les recettes avec l'inventaire courant
  /// Retourne seulement les recettes avec ≥ 70% de match, triées par match%
  List<RecipeMatch> matchWithInventory(
    List<RecipeEntity> recipes,
    List<ProductEntity> inventory,
  ) {
    // Normaliser les noms d'inventaire pour comparaison
    final inventoryNames = inventory
        .where((p) => p.status != ProductStatus.consumed)
        .map((p) => _normalize(p.name))
        .toSet();

    final matches = <RecipeMatch>[];

    for (final recipe in recipes) {
      if (recipe.ingredients.isEmpty) continue;

      final present = <IngredientRef>[];
      final missing = <IngredientRef>[];

      for (final ingredient in recipe.ingredients) {
        final normalizedIngredient = _normalize(ingredient.name);
        // Fuzzy matching: vérifier si un produit inventory contient le nom de l'ingrédient
        final found = inventoryNames.any((invName) =>
            invName.contains(normalizedIngredient) ||
            normalizedIngredient.contains(invName));

        if (found) {
          present.add(ingredient);
        } else {
          missing.add(ingredient);
        }
      }

      final matchPercent = (present.length / recipe.ingredients.length) * 100;

      if (matchPercent >= 70) {
        matches.add(RecipeMatch(
          recipe: recipe,
          matchPercent: matchPercent,
          presentIngredients: present,
          missingIngredients: missing,
        ));
      }
    }

    // Trier par match% décroissant
    matches.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    return matches;
  }

  /// Normaliser: lowercase, suppression accents
  /// Réutilise le même pattern que Story 2.11 _normalize()
  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâã]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ôõ]'), 'o')
        .replaceAll(RegExp(r'[ùúû]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim();
  }
}
```

### Riverpod Providers

```dart
// lib/features/recipes/presentation/providers/recipe_providers.dart

// Provider source: toutes les recettes depuis Hive (offline-first)
final recipesStreamProvider = StreamProvider<List<RecipeEntity>>((ref) {
  return ref.watch(recipeRepositoryProvider).watchRecipes();
});

// Filtre "seulement ce que j'ai"
final onlyFullMatchProvider = StateProvider<bool>((_) => false);

// RecipeMatches calculés en local (synchrone, <1s)
final recipeMatchesProvider = Provider<AsyncValue<List<RecipeMatch>>>((ref) {
  final recipesAsync = ref.watch(recipesStreamProvider);
  final inventoryAsync = ref.watch(inventoryStreamProvider);

  return recipesAsync.when(
    data: (recipes) => inventoryAsync.when(
      data: (inventory) {
        final service = RecipeMatchingService();
        final matches = service.matchWithInventory(recipes, inventory);
        return AsyncValue.data(matches);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// Matches filtrés selon toggle "seulement ce que j'ai"
final filteredRecipeMatchesProvider = Provider<AsyncValue<List<RecipeMatch>>>((ref) {
  final matchesAsync = ref.watch(recipeMatchesProvider);
  final onlyFull = ref.watch(onlyFullMatchProvider);

  return matchesAsync.whenData((matches) =>
    onlyFull ? matches.where((m) => m.isFullMatch).toList() : matches
  );
});
```

### RecipesScreen

```dart
// lib/features/recipes/presentation/screens/recipes_screen.dart

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(filteredRecipeMatchesProvider);
    final onlyFull = ref.watch(onlyFullMatchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recettes'),
        actions: [
          // Toggle filtre
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Ce que j\'ai'),
              selected: onlyFull,
              onSelected: (v) => ref.read(onlyFullMatchProvider.notifier).state = v,
            ),
          ),
        ],
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (matches) {
          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    onlyFull
                        ? 'Aucune recette réalisable avec votre inventaire actuel'
                        : 'Aucune recette disponible.\nAjoutez des produits à votre inventaire !',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: matches.length,
            itemBuilder: (context, index) => RecipeMatchCard(
              match: matches[index],
              onTap: () => context.push('/recipes/detail', extra: matches[index].recipe.id),
            ),
          );
        },
      ),
    );
  }
}
```

### RecipeMatchCard widget

```dart
// lib/features/recipes/presentation/widgets/recipe_match_card.dart

class RecipeMatchCard extends StatelessWidget {
  final RecipeMatch match;
  final VoidCallback onTap;

  const RecipeMatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final percent = match.matchPercent.round();
    final badgeColor = percent >= 90 ? Colors.green : Colors.orange;
    final missing = match.missingIngredients;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image recette
            if (match.recipe.imageUrl != null)
              CachedNetworkImage(
                imageUrl: match.recipe.imageUrl!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 100, height: 100,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 100, height: 100, color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
              )
            else
              Container(
                width: 100, height: 100, color: Colors.grey.shade200,
                child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
              ),

            // Infos recette
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre + badge match%
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            match.recipe.name,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            border: Border.all(color: badgeColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$percent%',
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Temps + difficulté
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${match.recipe.prepTimeMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.bar_chart, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _difficultyLabel(match.recipe.difficulty),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    // Ingrédients manquants
                    if (missing.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Manquants: ${_missingText(missing)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _difficultyLabel(RecipeDifficulty d) => switch (d) {
    RecipeDifficulty.easy => 'Facile',
    RecipeDifficulty.medium => 'Moyen',
    RecipeDifficulty.hard => 'Difficile',
  };

  String _missingText(List<IngredientRef> missing) {
    final names = missing.take(3).map((i) => i.name).join(', ');
    return missing.length > 3 ? '$names +${missing.length - 3}' : names;
  }
}
```

### RecipeRepository

```dart
// lib/features/recipes/data/repositories/recipe_repository_impl.dart

class RecipeRepositoryImpl implements RecipeRepository {
  final Box<RecipeModel> _box;  // Hive 'recipes_box'
  final FirebaseFirestore _firestore;
  final ConnectivityService _connectivity;

  @override
  Stream<List<RecipeEntity>> watchRecipes() {
    return _box.watch().map((_) =>
        _box.values.map((m) => m.toEntity()).toList()
    ).startWith(_box.values.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> syncFromFirestore() async {
    if (!await _connectivity.isOnline()) return;

    // Charger toutes les recettes si box vide (premier lancement)
    if (_box.isEmpty) {
      final snapshot = await _firestore.collection('recipes').get();
      for (final doc in snapshot.docs) {
        final model = RecipeModel.fromFirestore(doc);
        await _box.put(model.id, model);
      }
    }
    // Sync incrémentale: charger recettes modifiées depuis dernier sync
    // À implémenter en Story 6.10 avec full-text search
  }
}
```

### GoRouter routes à ajouter

```dart
GoRoute(
  path: '/recipes',
  builder: (_, __) => const RecipesScreen(),
  routes: [
    GoRoute(
      path: 'detail',
      builder: (context, state) {
        final recipeId = state.extra as String;
        return Scaffold(
          body: Center(child: Text('Détail recette $recipeId — Story 6.8')),
        );
      },
    ),
  ],
),
```

### AppShell NavigationBar — Ajouter onglet Recettes

```dart
// Modifier lib/core/presentation/app_shell.dart (Story 4.1)
// Ajouter destination Recettes:

NavigationDestination(
  icon: const Icon(Icons.restaurant_menu_outlined),
  selectedIcon: const Icon(Icons.restaurant_menu),
  label: 'Recettes',
),
```

### Packages à ajouter

```yaml
dependencies:
  cached_network_image: ^3.4.0
  # flutter_staggered_grid_view: ^0.7.0  # pour grille (future Stories 6.x)
```

### Hive Box Registration

```dart
// Dans initHive():
Hive.registerAdapter(RecipeModelAdapter());
await Hive.openBox<RecipeModel>('recipes_box');
```

### Firestore structure

```
shared/recipes/{recipeId}  ← Collection globale partagée (pas user-specific)
  - id: String
  - name: String
  - ingredients: [{name, quantityG, unit, category}]
  - instructions: [String]
  - prepTimeMinutes: int
  - difficulty: String ('easy'|'medium'|'hard')
  - tags: [String]
  - imageUrl: String?
  - costPerPortionEuros: double
```

### IMPORTANT — Cross-feature rules

```dart
// ❌ INTERDIT — Ne JAMAIS importer directement depuis recipes dans d'autres features:
import 'package:frigofute_v2/features/recipes/domain/entities/recipe_entity.dart';

// ✅ CORRECT — Utiliser shared providers dans lib/core/shared/providers/:
final selectedRecipeProvider = StateProvider<String?>((ref) => null);
```

### Project Structure Notes

- `lib/features/recipes/` — module principal Epic 6
- `lib/features/recipes/domain/entities/` — `RecipeEntity`, `IngredientRef`, `RecipeMatch`
- `lib/features/recipes/domain/services/` — `RecipeMatchingService`
- `lib/features/recipes/data/models/` — `RecipeModel` (Hive)
- `lib/features/recipes/data/repositories/` — `RecipeRepositoryImpl`
- `lib/features/recipes/presentation/screens/` — `RecipesScreen`
- `lib/features/recipes/presentation/widgets/` — `RecipeMatchCard`
- `lib/features/recipes/presentation/providers/` — `recipeMatchesProvider`, `filteredRecipeMatchesProvider`
- Firestore `shared/recipes` est une collection partagée (pas sous `users/{userId}/`)
- 10,000+ recettes = sync initial peut être long → faire uniquement si box vide, puis delta sync
- `inventoryStreamProvider` est exposé depuis `lib/core/shared/providers/` pour cross-feature access

### References

- [Source: epics.md#Story-6.1]
- Recipe Entity structure [Source: architecture.md — Recipe Entity]
- Hive box `recipes_box` [Source: architecture.md — Hive boxes]
- Firestore `shared/recipes` [Source: architecture.md — Structure collections]
- Cross-feature isolation rules [Source: architecture.md — ❌ INTERDIT]
- `_normalize()` function [Source: Story 2.11 — search-products-in-inventory]
- `cached_network_image` [Source: architecture.md — Performance]
- NutritionData entity [Source: Story 5.5]
- AppShell NavigationBar [Source: Story 4.1]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
