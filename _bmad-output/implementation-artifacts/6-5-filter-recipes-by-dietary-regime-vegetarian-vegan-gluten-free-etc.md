# Story 6.5: Filter Recipes by Dietary Regime (Vegetarian, Vegan, Gluten-Free, etc.)

Status: ready-for-dev

## Story

As a Sophie (famille végane),
I want to filter recipes by dietary regime,
so that I only see recipes that match my family's dietary restrictions.

## Acceptance Criteria

1. **Given** I am browsing recipes
   **When** I apply the "Diet" filter and select "Vegan"
   **Then** only vegan recipes are displayed
   **And** available diet options include: Végétarien, Vegan, Sans gluten, Sans lactose, Keto, Paleo

2. **Given** I have dietary preferences set in my profile (Story 1.7)
   **Then** recipes automatically exclude those containing my allergens
   **And** my dietary preferences pre-select the relevant filters

3. **Given** I select multiple diet filters
   **Then** recipes must match ALL selected filters (logical AND)

## Tasks / Subtasks

- [ ] **T1**: Créer `DietaryTag` enum (AC: 1)
  - [ ] `vegetarian`, `vegan`, `glutenFree`, `lactoseFree`, `keto`, `paleo`
  - [ ] Tags stockés dans `RecipeEntity.tags` (List<String>) — ex: `['vegan', 'gluten-free']`
- [ ] **T2**: Créer `dietaryFilterProvider` avec multiselect (AC: 1, 3)
  - [ ] `dietaryFilterProvider = StateProvider<Set<DietaryTag>>((_) => {})`
  - [ ] Initialiser depuis profil utilisateur (Story 1.7) si préférences définies
- [ ] **T3**: Créer `allergenExclusionProvider` (AC: 2)
  - [ ] Lire les allergènes depuis `userProfileProvider` (Story 1.7)
  - [ ] Filtrer recettes contenant des tags allergènes
- [ ] **T4**: Étendre `filteredRecipeMatchesProvider` avec filtres dietary + allergens (AC: 1, 2, 3)
  - [ ] Tags dietary: `recipe.tags.containsAll(selectedDietTags)`
  - [ ] Allergens exclusion: `!recipe.tags.any(allergens.contains)`
- [ ] **T5**: Ajouter `DietaryFilterRow` dans `RecipesScreen` (AC: 1, 3)
  - [ ] `FilterChip` multiselect scrollable horizontalement
- [ ] **T6**: Tests unitaires filtre dietary + exclusion allergens (AC: 1, 2, 3)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### DietaryTag enum

```dart
// lib/features/recipes/domain/enums/dietary_tag.dart

enum DietaryTag {
  vegetarian(label: 'Végétarien', tag: 'vegetarian'),
  vegan(label: 'Vegan', tag: 'vegan'),
  glutenFree(label: 'Sans gluten', tag: 'gluten-free'),
  lactoseFree(label: 'Sans lactose', tag: 'lactose-free'),
  keto(label: 'Keto', tag: 'keto'),
  paleo(label: 'Paleo', tag: 'paleo');

  final String label;
  final String tag;  // Valeur dans RecipeEntity.tags

  const DietaryTag({required this.label, required this.tag});
}
```

### Tags dans RecipeEntity

```dart
// RecipeEntity.tags est List<String> — tags stockés en lowercase
// Exemples de valeurs: ['vegan', 'gluten-free', 'rapide', 'ete', 'soupe']
// Le filtre dietary cherche des tags EXACTS dans cette liste
```

### Extension filteredRecipeMatchesProvider

```dart
final dietaryFilterProvider = StateProvider<Set<DietaryTag>>((_) => {});

// Dans filteredRecipeMatchesProvider:
final dietTags = ref.watch(dietaryFilterProvider);
final allergens = ref.watch(userAllergenTagsProvider);  // depuis Story 1.7

// ...filtered appliqué:
if (dietTags.isNotEmpty) {
  filtered = filtered.where((m) {
    final recipeTags = m.recipe.tags;
    return dietTags.every((d) => recipeTags.contains(d.tag));
  }).toList();
}
// Exclusion allergens
if (allergens.isNotEmpty) {
  filtered = filtered.where((m) {
    return !m.recipe.tags.any((t) => allergens.contains(t));
  }).toList();
}
```

### userAllergenTagsProvider (placeholder — Story 1.7)

```dart
// lib/core/shared/providers/user_profile_providers.dart

// Placeholder en attendant Story 1.7 (dietary preferences)
final userAllergenTagsProvider = Provider<Set<String>>((_) => {});
// Story 1.7 remplacera ce provider avec les vrais allergènes du profil utilisateur
```

### DietaryFilterRow

```dart
class DietaryFilterRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(dietaryFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: DietaryTag.values.map((tag) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(tag.label),
            selected: selected.contains(tag),
            onSelected: (v) {
              final notifier = ref.read(dietaryFilterProvider.notifier);
              final current = Set<DietaryTag>.from(notifier.state);
              if (v) current.add(tag); else current.remove(tag);
              notifier.state = current;
            },
          ),
        )).toList(),
      ),
    );
  }
}
```

### Project Structure Notes

- `DietaryTag.tag` correspond EXACTEMENT aux valeurs dans `RecipeEntity.tags` (normalisées lowercase)
- `userAllergenTagsProvider` est dans `lib/core/shared/providers/` — cross-feature safe
- Vegan implique aussi végétarien → en théorie les tags devraient inclure les deux, mais c'est la responsabilité des données Firestore
- Story 1.7 alimentera `userAllergenTagsProvider` avec les vraies préférences

### References

- [Source: epics.md#Story-6.5]
- RecipeEntity.tags [Source: Story 6.1]
- filteredRecipeMatchesProvider [Source: Stories 6.1–6.4]
- userDietaryPreferences [Source: Story 1.7 — placeholder pour MVP]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
