# Story 6.7: Mark Recipes as Favorites for Quick Access

Status: ready-for-dev

## Story

As a Thomas (sportif),
I want to save my favorite recipes,
so that I can quickly find and cook them again without searching.

## Acceptance Criteria

1. **Given** I am viewing a recipe
   **When** I tap the heart icon
   **Then** the recipe is added to my "Favoris" collection
   **And** the heart icon turns red to indicate the recipe is saved

2. **Given** I tap the heart icon on a recipe already in favorites
   **Then** the recipe is removed from favorites
   **And** the heart icon returns to its empty/outline state

3. **Given** I navigate to the "Favoris" tab in the recipes screen
   **Then** I see all my favorite recipes listed

4. **Given** I am online
   **Then** favorites sync to Firestore (`users/{userId}/favorites`)
   **And** accessible on multiple devices

5. **Given** I am offline
   **Then** favorites are accessible from local Hive cache
   **And** toggling favorites works offline and syncs when back online

## Tasks / Subtasks

- [ ] **T1**: Créer `FavoriteRepository` (AC: 1, 2, 4, 5)
  - [ ] Hive box `favorites_box` (Box<String> — liste de recipeIds)
  - [ ] Firestore `users/{userId}/favorites` collection
  - [ ] Offline-first: écrire Hive → queue sync
  - [ ] `toggleFavorite(String recipeId)` → add/remove
  - [ ] `watchFavoriteIds()` → Stream<Set<String>>
- [ ] **T2**: Créer `favoriteIdsProvider = StreamProvider<Set<String>>` (AC: 1, 2, 3)
  - [ ] `isFavoriteProvider(String recipeId) = Provider<bool>` — derive de favoriteIdsProvider
- [ ] **T3**: Créer `FavoriteButton` widget (AC: 1, 2)
  - [ ] `IconButton` avec `Icons.favorite` (rouge) / `Icons.favorite_border` (gris)
  - [ ] `AnimatedSwitcher` pour transition fluide
- [ ] **T4**: Ajouter `FavoriteButton` dans `RecipeMatchCard` et `RecipeDetailScreen` (AC: 1)
- [ ] **T5**: Ajouter onglet "Favoris" dans `RecipesScreen` (AC: 3)
  - [ ] `DefaultTabController` + `TabBar` (Suggestions | Favoris)
  - [ ] `FavoritesTab` — filtre recettes par `favoriteIdsProvider`
- [ ] **T6**: Tests unitaires `FavoriteRepository` + offline (AC: 4, 5)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### FavoriteRepository

```dart
// lib/features/recipes/data/repositories/favorite_repository_impl.dart

class FavoriteRepositoryImpl implements FavoriteRepository {
  final Box<String> _box;  // Hive 'favorites_box' — stocke recipeIds
  final FirebaseFirestore _firestore;
  final AuthService _auth;
  final SyncService _sync;

  @override
  Stream<Set<String>> watchFavoriteIds() {
    return _box.watch().map((_) => _box.values.toSet())
        .startWith(_box.values.toSet());
  }

  @override
  Future<void> toggleFavorite(String recipeId) async {
    if (_box.containsKey(recipeId)) {
      await _box.delete(recipeId);
      // Queue sync removal
      await _sync.queueOperation(
        type: SyncOperationType.delete,
        collection: 'users/${_auth.currentUserId}/favorites',
        documentId: recipeId,
      );
    } else {
      await _box.put(recipeId, recipeId);
      // Queue sync add
      await _sync.queueOperation(
        type: SyncOperationType.create,
        collection: 'users/${_auth.currentUserId}/favorites',
        documentId: recipeId,
        data: {'recipeId': recipeId, 'addedAt': DateTime.now().toIso8601String()},
      );
    }
  }

  @override
  bool isFavorite(String recipeId) => _box.containsKey(recipeId);
}
```

### Providers

```dart
// lib/features/recipes/presentation/providers/recipe_providers.dart

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl(
    box: Hive.box<String>('favorites_box'),
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(authServiceProvider),
    sync: ref.watch(syncServiceProvider),
  );
});

final favoriteIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(favoriteRepositoryProvider).watchFavoriteIds();
});

// Provider famille: est-ce que cette recette est en favoris?
final isFavoriteProvider = Provider.family<bool, String>((ref, recipeId) {
  final favorites = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
  return favorites.contains(recipeId);
});

// Liste de recettes favorites (filtrées)
final favoriteRecipesProvider = Provider<AsyncValue<List<RecipeEntity>>>((ref) {
  final favIds = ref.watch(favoriteIdsProvider);
  final recipesAsync = ref.watch(recipesStreamProvider);

  return favIds.when(
    data: (ids) => recipesAsync.whenData((recipes) =>
      recipes.where((r) => ids.contains(r.id)).toList()
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});
```

### FavoriteButton widget

```dart
// lib/features/recipes/presentation/widgets/favorite_button.dart

class FavoriteButton extends ConsumerWidget {
  final String recipeId;
  final double size;

  const FavoriteButton({super.key, required this.recipeId, this.size = 24});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(recipeId));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: IconButton(
        key: ValueKey(isFav),
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red : Colors.grey,
          size: size,
        ),
        onPressed: () {
          ref.read(favoriteRepositoryProvider).toggleFavorite(recipeId);
        },
        tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
      ),
    );
  }
}
```

### RecipesScreen avec onglets

```dart
// Modifier RecipesScreen (Story 6.1) pour ajouter onglets:

class RecipesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recettes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Suggestions'),
              Tab(icon: Icon(Icons.favorite), text: 'Favoris'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SuggestionsTab(),  // Story 6.1–6.5 filtres
            _FavoritesTab(),    // Story 6.7
          ],
        ),
      ),
    );
  }
}
```

### Hive box registration

```dart
await Hive.openBox<String>('favorites_box');
```

### Project Structure Notes

- `favorites_box` est une `Box<String>` simple (recipeIds) — pas de TypeAdapter nécessaire
- `isFavoriteProvider.family` est un Provider.family — ne PAS utiliser comme StreamProvider (synchrone)
- Firestore sync via `SyncService.queueOperation()` (pattern Story 0.9) — offline-first

### References

- [Source: epics.md#Story-6.7]
- SyncService queueOperation [Source: Story 0.9]
- Hive offline-first pattern [Source: Story 2.1, 2.12]
- favoriteIdsProvider → cross-feature via shared providers si besoin

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
