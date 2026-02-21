# Story 6.10: Access Recipe Database of 10,000+ Recipes with Fast Search

Status: ready-for-dev

## Story

As a Sophie (famille),
I want access to a large variety of recipes with fast search,
so that I never run out of cooking inspiration.

## Acceptance Criteria

1. **Given** the app has a recipe database with 10,000+ recipes
   **When** I search for a recipe by name or ingredient (e.g., "poulet", "pâtes")
   **Then** search results appear in less than 1 second
   **And** search handles typos gracefully with fuzzy matching

2. **Given** I type in the search bar
   **Then** results update in real-time with 300ms debounce
   **And** I can search by recipe name, ingredient, or cuisine type (via tags)

3. **Given** the database has 10,000+ recipes
   **Then** local Hive cache stores the complete database after first sync
   **And** search runs locally (no network request during search)

4. **Given** I search with a typo (e.g., "pouelt" instead of "poulet")
   **Then** relevant results still appear (fuzzy matching)

## Tasks / Subtasks

- [ ] **T1**: Créer `RecipeSearchService` avec full-text local search (AC: 1, 2, 3, 4)
  - [ ] `search(String query, List<RecipeEntity> recipes)` → `List<RecipeEntity>`
  - [ ] Normalisation query (lowercase + accents)
  - [ ] Match sur: `name`, `ingredients[].name`, `tags`
  - [ ] Fuzzy matching: Levenshtein distance ≤ 2 pour mots ≥ 4 chars
  - [ ] Tri par pertinence: nom exact > nom partiel > ingrédient > tag
- [ ] **T2**: Créer `recipeSearchQueryProvider = StateProvider<String>` (AC: 2)
  - [ ] Debounce 300ms via `ref.debounce()` ou `Timer`
- [ ] **T3**: Créer `searchedRecipesProvider` (AC: 1, 2)
  - [ ] Si query vide → retourner tous les matches (Story 6.1)
  - [ ] Si query non vide → retourner résultats de `RecipeSearchService`
  - [ ] Combiné avec filtres 6.1–6.5
- [ ] **T4**: Ajouter `RecipeSearchBar` dans `RecipesScreen` (AC: 2)
  - [ ] `TextField` avec `InputDecoration` (icône loupe)
  - [ ] Clear button si query non vide
  - [ ] Debounce 300ms
- [ ] **T5**: Implémenter sync complète `shared/recipes` → Hive (AC: 3)
  - [ ] Pagination Firestore: charger par lots de 500 (`limit(500)`)
  - [ ] Progress indicator pendant sync initiale
  - [ ] `recipes_sync_done` flag dans settings_box
- [ ] **T6**: Tests unitaires `RecipeSearchService` — pertinence + fuzzy (AC: 1, 4)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### RecipeSearchService

```dart
// lib/features/recipes/domain/services/recipe_search_service.dart

class RecipeSearchService {
  static const int _maxLevenshtein = 2;  // Tolérance typos

  List<RecipeEntity> search(String query, List<RecipeEntity> recipes) {
    if (query.trim().isEmpty) return recipes;

    final normalizedQuery = _normalize(query);
    final queryWords = normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList();

    final scored = <({RecipeEntity recipe, int score})>[];

    for (final recipe in recipes) {
      final normalizedName = _normalize(recipe.name);
      final ingredientNames = recipe.ingredients.map((i) => _normalize(i.name)).toList();
      final tagNames = recipe.tags.map(_normalize).toList();

      int score = 0;

      for (final word in queryWords) {
        // Match exact sur nom de recette → score maximal
        if (normalizedName == word) {
          score += 100;
        } else if (normalizedName.contains(word)) {
          score += 50;
        }

        // Match sur ingrédients
        for (final ingName in ingredientNames) {
          if (ingName.contains(word) || word.contains(ingName)) {
            score += 30;
            break;
          }
        }

        // Match sur tags (cuisine type etc.)
        for (final tag in tagNames) {
          if (tag.contains(word)) {
            score += 20;
            break;
          }
        }

        // Fuzzy matching si aucun match exact (Levenshtein)
        if (score == 0 && word.length >= 4) {
          for (final word2 in normalizedName.split(' ')) {
            if (_levenshtein(word, word2) <= _maxLevenshtein) {
              score += 10;
              break;
            }
          }
        }
      }

      if (score > 0) {
        scored.add((recipe: recipe, score: score));
      }
    }

    // Trier par score décroissant
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((s) => s.recipe).toList();
  }

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

  /// Distance de Levenshtein entre deux chaînes
  int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => j == 0 ? i : (i == 0 ? j : 0)),
    );

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }
}
```

### Providers

```dart
// lib/features/recipes/presentation/providers/recipe_providers.dart

final recipeSearchQueryProvider = StateProvider<String>((_) => '');

// Résultats de recherche + filtres combinés
final searchedAndFilteredRecipesProvider = Provider<AsyncValue<List<RecipeMatch>>>((ref) {
  final filteredAsync = ref.watch(filteredRecipeMatchesProvider);  // Stories 6.1–6.5
  final query = ref.watch(recipeSearchQueryProvider);
  final searchService = RecipeSearchService();

  if (query.isEmpty) return filteredAsync;

  return filteredAsync.whenData((matches) {
    final recipeResults = searchService.search(
      query,
      matches.map((m) => m.recipe).toList(),
    );
    final resultIds = recipeResults.map((r) => r.id).toSet();
    // Préserver l'ordre de la recherche
    return recipeResults
        .map((r) => matches.firstWhere((m) => m.recipe.id == r.id))
        .toList();
  });
});
```

### RecipeSearchBar avec debounce

```dart
// lib/features/recipes/presentation/widgets/recipe_search_bar.dart

class RecipeSearchBar extends ConsumerStatefulWidget {
  const RecipeSearchBar({super.key});

  @override
  ConsumerState<RecipeSearchBar> createState() => _RecipeSearchBarState();
}

class _RecipeSearchBarState extends ConsumerState<RecipeSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Rechercher recettes, ingrédients...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(recipeSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onChanged: (value) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 300), () {
            ref.read(recipeSearchQueryProvider.notifier).state = value;
          });
          setState(() {});  // Rebuild pour suffixIcon
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
```

### Sync Firestore → Hive (10,000+ recettes)

```dart
// lib/features/recipes/data/repositories/recipe_repository_impl.dart

@override
Future<void> syncFromFirestore() async {
  if (!await _connectivity.isOnline()) return;

  // Vérifier si sync initiale déjà faite
  final syncDone = Hive.box('settings_box').get('recipes_sync_done', defaultValue: false) as bool;
  if (syncDone && _box.isNotEmpty) return;

  // Sync paginée (10,000+ recettes en lots de 500)
  DocumentSnapshot? lastDoc;
  int totalSynced = 0;

  do {
    Query query = _firestore.collection('recipes').limit(500);
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) break;

    for (final doc in snapshot.docs) {
      final model = RecipeModel.fromFirestore(doc);
      await _box.put(model.id, model);
    }

    totalSynced += snapshot.docs.length;
    lastDoc = snapshot.docs.last;

    debugPrint('Synced $totalSynced recipes...');
  } while (lastDoc != null);

  // Marquer sync complète
  await Hive.box('settings_box').put('recipes_sync_done', true);
  debugPrint('Recipe sync complete: $totalSynced recipes');
}
```

### Performance 10,000+ recettes

- **Hive Box**: Lecture synchrone de 10K entrées ≈ 200–500ms (Box<RecipeModel> avec index)
- **RecipeSearchService**: Search O(n×m) où n=10K recettes, m=mots query → ≈ 50–100ms
- **Debounce 300ms**: Évite recherches intempestives pendant frappe
- **Résultat total**: < 500ms pour une recherche complète — objectif <1s atteint

### Project Structure Notes

- `searchedAndFilteredRecipesProvider` remplace `filteredRecipeMatchesProvider` dans `RecipesScreen`
- `RecipeSearchBar` intégré dans `RecipesScreen` body (sous AppBar, au-dessus des filtres)
- Sync initiale: 10K recettes peut prendre 30-60s (dépend du débit Firestore) → afficher `LinearProgressIndicator`
- Levenshtein O(n²) limité aux mots ≥ 4 chars — pas de problème perf pour des mots courts

### References

- [Source: epics.md#Story-6.10]
- RecipeSearchService pattern [Source: Story 2.11 — normalize(), SearchBar debounce]
- Firestore pagination [Source: architecture.md]
- RecipeRepository.syncFromFirestore [Source: Story 6.1]
- filteredRecipeMatchesProvider (chaîné) [Source: Stories 6.1–6.9]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
