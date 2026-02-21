# Story 6.8: View Detailed Recipe Tutorial with Step-by-Step Instructions

Status: ready-for-dev

## Story

As a Lucas (étudiant débutant cuisine),
I want clear, step-by-step instructions for each recipe,
so that I can follow along easily and succeed even as a beginner.

## Acceptance Criteria

1. **Given** I tap on a recipe from the recipes screen
   **When** the recipe detail screen opens
   **Then** I see: recipe image, name, prep time, difficulty, servings, ingredient list, step-by-step instructions

2. **Given** I am following the recipe step-by-step
   **When** I tap on a step
   **Then** the step is marked as completed with a checkmark (local state only, not persisted)

3. **Given** I want to adjust the serving size
   **When** I change the number of servings with +/- buttons
   **Then** all ingredient quantities recalculate proportionally

4. **Given** the recipe has an image
   **Then** it is displayed at the top with `CachedNetworkImage`
   **And** a hero animation from the recipe card to the detail screen

## Tasks / Subtasks

- [ ] **T1**: Créer `RecipeDetailScreen` (AC: 1, 2, 3, 4)
  - [ ] `SliverAppBar` avec image hero + CachedNetworkImage
  - [ ] Section: ingrédients (avec ajustement portions)
  - [ ] Section: instructions (step-by-step numérotées)
  - [ ] `FavoriteButton` dans AppBar actions (Story 6.7)
- [ ] **T2**: Créer `_ServingAdjuster` widget (AC: 3)
  - [ ] `StateProvider<int> servingsProvider` — valeur locale, initialisée depuis `recipe.defaultServings`
  - [ ] Boutons + / - avec limites (1–20)
  - [ ] Recalcul quantités: `adjustedQuantity = baseQuantity * servings / baseServings`
- [ ] **T3**: Créer `_StepList` widget avec checkboxes (AC: 2)
  - [ ] `StateProvider<Set<int>> completedStepsProvider` — local uniquement
  - [ ] `InkWell` sur chaque step → toggle complétion
  - [ ] Style: texte barré + icône check vert si complété
- [ ] **T4**: Hero animation RecipeMatchCard → RecipeDetailScreen (AC: 4)
  - [ ] `Hero(tag: 'recipe_image_${recipe.id}', child: CachedNetworkImage(...))`
- [ ] **T5**: Remplacer route placeholder `/recipes/detail` (Story 6.1) avec vraie implémentation
- [ ] **T6**: Tests widget `RecipeDetailScreen` (AC: 1, 2, 3)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### RecipeDetailScreen

```dart
// lib/features/recipes/presentation/screens/recipe_detail_screen.dart

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late int _servings;
  final Set<int> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    // Chercher la recette dans le cache Hive via recipesStreamProvider
    final recipesAsync = ref.watch(recipesStreamProvider);

    return recipesAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
      data: (recipes) {
        final recipe = recipes.firstWhereOrNull((r) => r.id == widget.recipeId);
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Recette introuvable')),
          );
        }

        _servings = _servings != 0 ? _servings : recipe.defaultServings;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // SliverAppBar avec image hero
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(recipe.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  background: recipe.imageUrl != null
                      ? Hero(
                          tag: 'recipe_image_${recipe.id}',
                          child: CachedNetworkImage(
                            imageUrl: recipe.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(color: Colors.green.shade100,
                          child: const Icon(Icons.restaurant, size: 80, color: Colors.green)),
                ),
                actions: [
                  FavoriteButton(recipeId: recipe.id, size: 28),  // Story 6.7
                ],
              ),

              // Contenu
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Méta-infos
                    _RecipeMetaRow(recipe: recipe),
                    const SizedBox(height: 16),

                    // Ajustement portions
                    _ServingAdjuster(
                      servings: _servings,
                      onChanged: (v) => setState(() => _servings = v),
                    ),
                    const SizedBox(height: 16),

                    // Ingrédients
                    Text('Ingrédients', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...recipe.ingredients.map((ing) => _IngredientRow(
                      ingredient: ing,
                      servings: _servings,
                      baseServings: recipe.defaultServings,
                    )),
                    const Divider(height: 32),

                    // Instructions
                    Text('Préparation', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...recipe.instructions.asMap().entries.map((e) => _StepTile(
                      stepIndex: e.key,
                      text: e.value,
                      isCompleted: _completedSteps.contains(e.key),
                      onTap: () => setState(() {
                        if (_completedSteps.contains(e.key)) {
                          _completedSteps.remove(e.key);
                        } else {
                          _completedSteps.add(e.key);
                        }
                      }),
                    )),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### _ServingAdjuster

```dart
class _ServingAdjuster extends StatelessWidget {
  final int servings;
  final ValueChanged<int> onChanged;

  const _ServingAdjuster({required this.servings, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Portions:', style: Theme.of(context).textTheme.titleSmall),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: servings > 1 ? () => onChanged(servings - 1) : null,
        ),
        Text('$servings', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: servings < 20 ? () => onChanged(servings + 1) : null,
        ),
      ],
    );
  }
}
```

### _IngredientRow avec recalcul portions

```dart
class _IngredientRow extends StatelessWidget {
  final IngredientRef ingredient;
  final int servings;
  final int baseServings;

  const _IngredientRow({required this.ingredient, required this.servings, required this.baseServings});

  @override
  Widget build(BuildContext context) {
    final adjustedQty = ingredient.quantityG * servings / baseServings;
    final qtyText = adjustedQty < 10
        ? adjustedQty.toStringAsFixed(1)
        : adjustedQty.round().toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, size: 8, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(ingredient.name)),
          Text('$qtyText ${ingredient.unit}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

### _StepTile

```dart
class _StepTile extends StatelessWidget {
  final int stepIndex;
  final String text;
  final bool isCompleted;
  final VoidCallback onTap;

  const _StepTile({required this.stepIndex, required this.text, required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text('${stepIndex + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### GoRouter — Remplacer placeholder de Story 6.1

```dart
GoRoute(
  path: 'detail',
  builder: (context, state) {
    final recipeId = state.extra as String;
    return RecipeDetailScreen(recipeId: recipeId);
  },
),
```

### Hero animation depuis RecipeMatchCard

```dart
// Dans RecipeMatchCard (Story 6.1), wrapper l'image avec Hero:
Hero(
  tag: 'recipe_image_${match.recipe.id}',
  child: CachedNetworkImage(...),
),
```

### Project Structure Notes

- `RecipeDetailScreen` remplace le placeholder `/recipes/detail` de Story 6.1
- État `_completedSteps` et `_servings` sont locaux (StatefulWidget) — pas persistés entre sessions
- Hero animation requiert que le tag soit identique dans la card ET le detail screen
- `firstWhereOrNull` → extension de `package:collection`

### References

- [Source: epics.md#Story-6.8]
- RecipeEntity (ingredients, instructions, defaultServings) [Source: Story 6.1]
- FavoriteButton [Source: Story 6.7]
- CachedNetworkImage [Source: Story 6.1]
- recipesStreamProvider [Source: Story 6.1]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
