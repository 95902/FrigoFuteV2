# Story 6.2: Filter Recipes by Budget (Cheap, Moderate, Expensive)

Status: ready-for-dev

## Story

As a Lucas (étudiant),
I want to filter recipes by budget so I only see affordable options,
so that I can cook delicious meals without overspending.

## Acceptance Criteria

1. **Given** I am browsing recipes
   **When** I apply the "Budget" filter and select "Bon marché" (< 3€/portion)
   **Then** only recipes within the selected budget range are displayed
   **And** each recipe shows the estimated cost per portion

2. **Given** I adjust the budget filter
   **Then** filter state is preserved when I navigate away and return to the recipes screen

3. **Given** I view a recipe card
   **Then** cost per portion is displayed with a currency icon

## Tasks / Subtasks

- [ ] **T1**: Créer `RecipeBudget` enum + `budgetFilterProvider` (AC: 1, 2)
  - [ ] `RecipeBudget { cheap, moderate, expensive, all }` avec ranges (cheap: <3€, moderate: 3–7€, expensive: >7€)
  - [ ] `budgetFilterProvider = StateProvider<RecipeBudget>((_) => RecipeBudget.all)`
  - [ ] Persister dans Hive `settings_box` pour survivre aux navigations (AC: 2)
- [ ] **T2**: Étendre `filteredRecipeMatchesProvider` avec filtre budget (AC: 1)
  - [ ] Filtrer `match.recipe.costPerPortionEuros` selon `RecipeBudget` sélectionné
  - [ ] Chaîner avec filtre `onlyFullMatchProvider` de Story 6.1
- [ ] **T3**: Ajouter `BudgetFilterChip` dans `RecipesScreen` (AC: 1, 3)
  - [ ] `ChoiceChip` group: Tous / Bon marché / Moyen / Cher
  - [ ] Afficher dans une `SingleChildScrollView` horizontale sous l'AppBar
- [ ] **T4**: Afficher coût/portion dans `RecipeMatchCard` (AC: 3)
  - [ ] `Icon(Icons.euro)` + `${cost.toStringAsFixed(2)} €/portion`
- [ ] **T5**: Tests unitaires filtre budget (AC: 1)
- [ ] **T6**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### RecipeBudget enum

```dart
// lib/features/recipes/domain/enums/recipe_budget.dart

enum RecipeBudget {
  all(label: 'Tous', minEuros: 0, maxEuros: double.infinity),
  cheap(label: 'Bon marché', minEuros: 0, maxEuros: 3.0),
  moderate(label: 'Moyen', minEuros: 3.0, maxEuros: 7.0),
  expensive(label: 'Cher', minEuros: 7.0, maxEuros: double.infinity);

  final String label;
  final double minEuros;
  final double maxEuros;

  const RecipeBudget({required this.label, required this.minEuros, required this.maxEuros});

  bool matches(double costPerPortion) =>
      costPerPortion >= minEuros && costPerPortion < maxEuros;
}
```

### Provider mise à jour (chaînage filtres)

```dart
// Ajouter dans recipe_providers.dart

final budgetFilterProvider = StateProvider<RecipeBudget>((_) => RecipeBudget.all);

// Remplacer filteredRecipeMatchesProvider de Story 6.1 par version étendue:
final filteredRecipeMatchesProvider = Provider<AsyncValue<List<RecipeMatch>>>((ref) {
  final matchesAsync = ref.watch(recipeMatchesProvider);
  final onlyFull = ref.watch(onlyFullMatchProvider);
  final budget = ref.watch(budgetFilterProvider);

  return matchesAsync.whenData((matches) {
    var filtered = onlyFull ? matches.where((m) => m.isFullMatch).toList() : matches;
    if (budget != RecipeBudget.all) {
      filtered = filtered.where((m) => budget.matches(m.recipe.costPerPortionEuros)).toList();
    }
    return filtered;
  });
});
```

### BudgetFilterRow widget

```dart
// lib/features/recipes/presentation/widgets/budget_filter_row.dart

class BudgetFilterRow extends ConsumerWidget {
  const BudgetFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(budgetFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: RecipeBudget.values.map((budget) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(budget.label),
            selected: selected == budget,
            onSelected: (_) => ref.read(budgetFilterProvider.notifier).state = budget,
          ),
        )).toList(),
      ),
    );
  }
}
```

### Persistance filtre dans settings_box

```dart
// Sauvegarder dans Hive settings_box:
// key: 'recipe_budget_filter', value: RecipeBudget.index (int)
// Charger au démarrage:
final savedIndex = Hive.box('settings_box').get('recipe_budget_filter', defaultValue: 0) as int;
final initial = RecipeBudget.values[savedIndex];
```

### Project Structure Notes

- `RecipeBudget` dans `lib/features/recipes/domain/enums/`
- `BudgetFilterRow` dans `lib/features/recipes/presentation/widgets/`
- Intégrer `BudgetFilterRow` dans `RecipesScreen.body` (sous AppBar, au-dessus de la ListView)
- `costPerPortionEuros` est déjà dans `RecipeEntity` (Story 6.1) — pas de migration nécessaire

### References

- [Source: epics.md#Story-6.2]
- RecipeEntity.costPerPortionEuros [Source: Story 6.1]
- filteredRecipeMatchesProvider [Source: Story 6.1]
- Hive settings_box [Source: architecture.md]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
