# Story 6.4: Filter Recipes by Difficulty (Easy, Medium, Hard)

Status: ready-for-dev

## Story

As a Marie (senior),
I want to filter recipes by difficulty to find simple recipes I can manage,
so that I don't get overwhelmed with complicated techniques.

## Acceptance Criteria

1. **Given** I am browsing recipes
   **When** I apply the "Difficulty" filter and select "Facile"
   **Then** only easy recipes are displayed
   **And** difficulty is clearly indicated on each recipe card (stars or label)

2. **Given** I select difficulty filters
   **Then** I can select multiple difficulty levels simultaneously (multiselect)

3. **Given** I navigate away and return
   **Then** my difficulty filter selection is preserved

## Tasks / Subtasks

- [ ] **T1**: Créer `difficultyFilterProvider` avec multiselect (AC: 1, 2)
  - [ ] `difficultyFilterProvider = StateProvider<Set<RecipeDifficulty>>((_) => {})`
  - [ ] Set vide = "Tous" (pas de filtre)
- [ ] **T2**: Étendre `filteredRecipeMatchesProvider` avec filtre difficulté (AC: 1, 2)
  - [ ] Si set non vide: filtrer `match.recipe.difficulty in selectedDifficulties`
- [ ] **T3**: Ajouter `DifficultyFilterRow` dans `RecipesScreen` (AC: 1, 2)
  - [ ] `FilterChip` multiselect: Facile / Moyen / Difficile (tous sélectionnables simultanément)
- [ ] **T4**: Afficher difficulté dans `RecipeMatchCard` avec étoiles (AC: 1)
  - [ ] 1 étoile = Facile, 2 étoiles = Moyen, 3 étoiles = Difficile
  - [ ] `Icon(Icons.star, size: 12)` répété N fois
- [ ] **T5**: Tests unitaires filtre difficulté (AC: 1, 2)
- [ ] **T6**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Provider multiselect

```dart
// lib/features/recipes/presentation/providers/recipe_providers.dart

final difficultyFilterProvider = StateProvider<Set<RecipeDifficulty>>((_) => {});

// filteredRecipeMatchesProvider étendu (cumulative 6.1 + 6.2 + 6.3 + 6.4):
// ...
if (difficultySet.isNotEmpty) {
  filtered = filtered.where((m) => difficultySet.contains(m.recipe.difficulty)).toList();
}
```

### DifficultyFilterRow

```dart
class DifficultyFilterRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(difficultyFilterProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: RecipeDifficulty.values.map((d) => FilterChip(
        label: Text(_label(d)),
        selected: selected.contains(d),
        avatar: Icon(_icon(d), size: 16),
        onSelected: (v) {
          final notifier = ref.read(difficultyFilterProvider.notifier);
          final current = Set<RecipeDifficulty>.from(notifier.state);
          if (v) current.add(d); else current.remove(d);
          notifier.state = current;
        },
      )).toList(),
    );
  }

  String _label(RecipeDifficulty d) => switch (d) {
    RecipeDifficulty.easy => 'Facile',
    RecipeDifficulty.medium => 'Moyen',
    RecipeDifficulty.hard => 'Difficile',
  };

  IconData _icon(RecipeDifficulty d) => switch (d) {
    RecipeDifficulty.easy => Icons.sentiment_satisfied,
    RecipeDifficulty.medium => Icons.sentiment_neutral,
    RecipeDifficulty.hard => Icons.sentiment_dissatisfied,
  };
}
```

### Étoiles difficulté dans RecipeMatchCard

```dart
Row(
  children: List.generate(
    switch (recipe.difficulty) {
      RecipeDifficulty.easy => 1,
      RecipeDifficulty.medium => 2,
      RecipeDifficulty.hard => 3,
    },
    (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
  ),
),
```

### Project Structure Notes

- `difficultyFilterProvider` utilise `Set<RecipeDifficulty>` (multiselect) — contraste avec budget/preptime (single select)
- `RecipeDifficulty` est déjà défini en Story 6.1 — pas de redéfinition

### References

- [Source: epics.md#Story-6.4]
- RecipeDifficulty enum [Source: Story 6.1]
- filteredRecipeMatchesProvider pattern [Source: Stories 6.1, 6.2, 6.3]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
