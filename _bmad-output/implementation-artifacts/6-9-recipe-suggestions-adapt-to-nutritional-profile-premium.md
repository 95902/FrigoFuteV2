# Story 6.9: Recipe Suggestions Adapt to Nutritional Profile (Premium)

Status: ready-for-dev

## Story

As a Thomas (sportif premium),
I want recipe suggestions to prioritize high-protein meals that match my macros,
so that I can hit my fitness goals while enjoying varied meals.

## Acceptance Criteria

1. **Given** I am a premium user with a nutritional profile configured (e.g., "Athlete - Muscle Gain")
   **When** I browse recipes or receive suggestions
   **Then** recipes are ranked to prioritize those matching my macro targets (high protein)
   **And** each recipe displays macros per serving (calories, protein, carbs, fats)

2. **Given** a recipe matches my nutritional goals well
   **Then** it shows a badge "Correspond à vos objectifs" (green badge)

3. **Given** I am a free user
   **Then** this feature is hidden or shows a premium teaser

4. **Given** I toggle "Adapter à mon profil" in recipes settings
   **Then** the ranking adapts accordingly, and the toggle state is preserved

## Tasks / Subtasks

- [ ] **T1**: Créer `NutritionalRankingService` (AC: 1, 2)
  - [ ] `rankByNutritionalFit(List<RecipeMatch>, NutritionProfile)` → `List<RecipeMatch>` (réordonné)
  - [ ] Score: `(recipe.nutritionPer100g.proteinG / profile.proteinTargetG) * weight`
  - [ ] Badge "Correspond à vos objectifs" si score ≥ 80%
- [ ] **T2**: Créer `nutritionalAdaptFilterProvider = StateProvider<bool>` (AC: 4)
  - [ ] Default `false` — optionnel par l'utilisateur
- [ ] **T3**: Étendre `filteredRecipeMatchesProvider` avec ranking nutritionnel (AC: 1)
  - [ ] Si `isPremium && nutritionalAdaptFilter` → ré-ordonner via `NutritionalRankingService`
  - [ ] Sinon → ordre normal
- [ ] **T4**: Afficher macros par portion dans `RecipeDetailScreen` (AC: 1)
  - [ ] Section "Valeurs nutritionnelles" avec calories, protéines, glucides, lipides
  - [ ] Multiplié par `servings / baseServings` (ajustement portions Story 6.8)
- [ ] **T5**: Badge "Correspond à vos objectifs" dans `RecipeMatchCard` (AC: 2)
  - [ ] Badge vert visible uniquement si `isPremium && nutritionalAdaptFilter && scoreMatch`
- [ ] **T6**: `PremiumTeaserCard` si non-premium (AC: 3)
  - [ ] Réutiliser pattern `_PremiumTeaserCard` de Story 4.5
- [ ] **T7**: Tests unitaires `NutritionalRankingService` (AC: 1)
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### NutritionalRankingService

```dart
// lib/features/recipes/domain/services/nutritional_ranking_service.dart

class NutritionalRankingService {
  /// Score: à quel point la recette correspond au profil nutritionnel
  /// Score 0.0 – 1.0 (1.0 = correspondance parfaite)
  double _computeScore(RecipeEntity recipe, NutritionProfile profile) {
    final nutrition = recipe.nutritionPer100g;
    if (nutrition == null || nutrition.isEmpty) return 0.5;  // Score neutre si pas de données

    double score = 0;
    int factors = 0;

    // Protéines (poids fort si profil muscle gain)
    if (nutrition.proteinG != null && profile.proteinTargetGPerDay != null) {
      final proteinScore = (nutrition.proteinG! / 30).clamp(0, 1);  // 30g/100g = max score
      score += proteinScore * (profile.prioritizesProtein ? 2 : 1);
      factors += profile.prioritizesProtein ? 2 : 1;
    }

    // Calories (proche de la cible)
    if (nutrition.caloriesKcal != null && profile.dailyCalorieTarget != null) {
      final mealTarget = profile.dailyCalorieTarget! / 3;  // 3 repas/jour
      final diff = (nutrition.caloriesKcal! - mealTarget / 3).abs();
      final calScore = (1 - diff / mealTarget).clamp(0, 1);
      score += calScore;
      factors++;
    }

    return factors > 0 ? (score / factors) : 0.5;
  }

  /// Ré-ordonne les recettes par score de correspondance nutritionnelle
  List<RecipeMatch> rankByNutritionalFit(
    List<RecipeMatch> matches,
    NutritionProfile profile,
  ) {
    final scored = matches.map((m) => (
      match: m,
      score: _computeScore(m.recipe, profile),
    )).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((s) => s.match).toList();
  }

  /// Détermine si une recette "correspond aux objectifs" (badge)
  bool meetsGoals(RecipeEntity recipe, NutritionProfile profile) {
    return _computeScore(recipe, profile) >= 0.80;
  }
}
```

### NutritionProfile placeholder (Epic 8)

```dart
// lib/core/shared/models/nutrition_profile.dart
// Placeholder — Epic 8 implémentera les 12 profils complets

@freezed
class NutritionProfile with _$NutritionProfile {
  const factory NutritionProfile({
    required String name,              // ex: "Athlète - Prise de masse"
    double? dailyCalorieTarget,        // ex: 2500
    double? proteinTargetGPerDay,      // ex: 150
    @Default(false) bool prioritizesProtein,
  }) = _NutritionProfile;

  factory NutritionProfile.empty() => const NutritionProfile(name: 'Aucun');
}

// Placeholder provider — Epic 8 le remplacera
final nutritionProfileProvider = Provider<NutritionProfile>(
  (_) => NutritionProfile.empty(),
);
```

### Provider avec ranking nutritionnel

```dart
final nutritionalAdaptFilterProvider = StateProvider<bool>((_) => false);

// Dans filteredRecipeMatchesProvider (ajout cumulative):
final isPremium = ref.watch(isPremiumProvider);  // Story 4.5
final adaptToProfile = ref.watch(nutritionalAdaptFilterProvider);
final nutritionProfile = ref.watch(nutritionProfileProvider);

// ...après les autres filtres:
if (isPremium && adaptToProfile) {
  filtered = NutritionalRankingService().rankByNutritionalFit(filtered, nutritionProfile);
}
```

### Badge "Correspond à vos objectifs"

```dart
// Dans RecipeMatchCard, ajouter conditionnellement:
if (isPremium && adaptToProfile && meetsGoals)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.green.shade100,
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 12),
        SizedBox(width: 4),
        Text('Vos objectifs', style: TextStyle(color: Colors.green, fontSize: 10)),
      ],
    ),
  ),
```

### Project Structure Notes

- `NutritionProfile` est dans `lib/core/shared/models/` — partagé entre Epic 6 et Epic 8
- `isPremiumProvider` défini en Story 4.5 (`Provider<bool>((_) => false)` — placeholder)
- Epic 8 remplacera `nutritionProfileProvider` avec les 12 profils réels
- `recipe.nutritionPer100g` est de type `NutritionData?` (Story 5.5) — peut être null

### References

- [Source: epics.md#Story-6.9]
- isPremiumProvider placeholder [Source: Story 4.5]
- NutritionData entity [Source: Story 5.5]
- NutritionProfile (12 profils) [Source: Epic 8]
- filteredRecipeMatchesProvider [Source: Stories 6.1–6.5]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
