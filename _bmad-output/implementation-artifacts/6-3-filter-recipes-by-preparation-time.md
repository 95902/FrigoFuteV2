# Story 6.3: Filter Recipes by Preparation Time

Status: ready-for-dev

## Story

As a Thomas (sportif),
I want to filter recipes by preparation time (e.g., < 20 minutes),
so that I can cook quick meals on busy days.

## Acceptance Criteria

1. **Given** I am browsing recipes
   **When** I apply the "Preparation time" filter and select "< 20 min"
   **Then** only recipes that can be prepared in less than 20 minutes are displayed
   **And** preparation time is clearly displayed on each recipe card

2. **Given** I select a time filter
   **Then** I can choose from predefined time ranges: <15 min, <30 min, <45 min, <1h, >1h
   **And** filter state is preserved across sessions

## Tasks / Subtasks

- [ ] **T1**: Créer `PrepTimeFilter` enum + `prepTimeFilterProvider` (AC: 1, 2)
  - [ ] `PrepTimeFilter { any, under15, under30, under45, under60, over60 }` avec `maxMinutes`
  - [ ] `prepTimeFilterProvider = StateProvider<PrepTimeFilter>((_) => PrepTimeFilter.any)`
  - [ ] Persister dans Hive `settings_box` (key: `recipe_preptime_filter`)
- [ ] **T2**: Étendre `filteredRecipeMatchesProvider` avec filtre temps (AC: 1)
  - [ ] Filtrer `match.recipe.prepTimeMinutes` selon `PrepTimeFilter` sélectionné
  - [ ] Chaîner avec filtres Story 6.1 + 6.2
- [ ] **T3**: Ajouter `PrepTimeFilterRow` dans `RecipesScreen` (AC: 2)
  - [ ] `ChoiceChip` group: Tous / <15 min / <30 min / <45 min / <1h / >1h
- [ ] **T4**: Vérifier affichage `prepTimeMinutes` dans `RecipeMatchCard` (AC: 1)
  - [ ] Déjà ajouté en Story 6.1 — vérifier que la ligne est correcte
- [ ] **T5**: Tests unitaires filtre temps (AC: 1)
- [ ] **T6**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### PrepTimeFilter enum

```dart
// lib/features/recipes/domain/enums/prep_time_filter.dart

enum PrepTimeFilter {
  any(label: 'Tous', maxMinutes: null),
  under15(label: '< 15 min', maxMinutes: 15),
  under30(label: '< 30 min', maxMinutes: 30),
  under45(label: '< 45 min', maxMinutes: 45),
  under60(label: '< 1h', maxMinutes: 60),
  over60(label: '> 1h', maxMinutes: null, minMinutes: 60);

  final String label;
  final int? maxMinutes;
  final int minMinutes;

  const PrepTimeFilter({required this.label, this.maxMinutes, this.minMinutes = 0});

  bool matches(int prepTime) {
    if (maxMinutes != null && prepTime > maxMinutes!) return false;
    if (prepTime < minMinutes) return false;
    return true;
  }
}
```

### Extension du provider chaîné

```dart
// Mise à jour filteredRecipeMatchesProvider dans recipe_providers.dart

final prepTimeFilterProvider = StateProvider<PrepTimeFilter>((_) => PrepTimeFilter.any);

// filteredRecipeMatchesProvider (cumulative — Story 6.1 + 6.2 + 6.3):
final filteredRecipeMatchesProvider = Provider<AsyncValue<List<RecipeMatch>>>((ref) {
  final matchesAsync = ref.watch(recipeMatchesProvider);
  final onlyFull = ref.watch(onlyFullMatchProvider);
  final budget = ref.watch(budgetFilterProvider);
  final prepTime = ref.watch(prepTimeFilterProvider);

  return matchesAsync.whenData((matches) {
    var filtered = onlyFull ? matches.where((m) => m.isFullMatch).toList() : matches;
    if (budget != RecipeBudget.all) {
      filtered = filtered.where((m) => budget.matches(m.recipe.costPerPortionEuros)).toList();
    }
    if (prepTime != PrepTimeFilter.any) {
      filtered = filtered.where((m) => prepTime.matches(m.recipe.prepTimeMinutes)).toList();
    }
    return filtered;
  });
});
```

### Project Structure Notes

- `PrepTimeFilter` dans `lib/features/recipes/domain/enums/`
- `PrepTimeFilterRow` dans `lib/features/recipes/presentation/widgets/`
- `filteredRecipeMatchesProvider` est mis à jour à chaque story — provider cumulatif
- Ordre des filtres dans RecipesScreen: MatchFull (toggle) → Budget (row) → PrepTime (row) → Difficulty (6.4) → Diet (6.5)

### References

- [Source: epics.md#Story-6.3]
- filteredRecipeMatchesProvider [Source: Story 6.1, 6.2]
- RecipeEntity.prepTimeMinutes [Source: Story 6.1]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
