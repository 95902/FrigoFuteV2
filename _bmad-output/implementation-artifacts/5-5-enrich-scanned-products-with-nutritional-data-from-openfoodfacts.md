# Story 5.5: Enrich Scanned Products with Nutritional Data from OpenFoodFacts

Status: ready-for-dev

## Story

As a Thomas (sportif),
I want scanned products to automatically include nutritional information,
so that I can track my macros and calories without looking them up manually.

## Acceptance Criteria

1. **Given** I scan a barcode
   **When** the product is recognized in OpenFoodFacts
   **Then** nutritional data (calories, protein, carbs, fats per 100g) is fetched automatically
   **And** displayed in the product confirmation screen

2. **Given** nutritional data is unavailable from OpenFoodFacts
   **Then** the product is still added with a "Données nutritionnelles non disponibles" label
   **And** I can manually enter nutritional values via an edit form

3. **Given** the product has been previously scanned
   **When** I scan it again within 7 days
   **Then** nutritional data is loaded from local cache (no API call)

4. **Given** I view product details
   **Then** nutritional data is displayed per 100g with macros breakdown
   **And** a "Source: OpenFoodFacts" attribution is shown

## Tasks / Subtasks

- [ ] **T1**: Étendre `NutritionData` entity avec champs complets (AC: 1, 4)
  - [ ] `caloriesKcal`, `proteinG`, `carbsG`, `fatsG`, `fibersG`, `saltG`
  - [ ] `per100g: true` flag pour indiquer la référence
- [ ] **T2**: Améliorer parsing OpenFoodFacts dans `OpenFoodFactsRepository` (AC: 1, 2)
  - [ ] Parser `nutriments` → `NutritionData`
  - [ ] Gérer champs manquants avec null safety
  - [ ] Retourner `NutritionData.empty()` si aucune donnée
- [ ] **T3**: Créer `NutritionDataCard` widget (AC: 1, 4)
  - [ ] Afficher calories en grand, puis barre macros (protéines/glucides/lipides)
  - [ ] Attribution "Source: OpenFoodFacts" en bas
  - [ ] Si `isEmpty` → afficher CTA "Ajouter les données nutritionnelles"
- [ ] **T4**: Créer `EditNutritionDataDialog` (AC: 2)
  - [ ] Formulaire: calories, protéines, glucides, lipides
  - [ ] Valider que calories ≈ (protéines×4 + glucides×4 + lipides×9)
- [ ] **T5**: Intégrer `NutritionDataCard` dans `AddProductFromBarcodeScreen` (AC: 1)
- [ ] **T6**: Tests unitaires parsing `NutritionData` depuis OpenFoodFacts JSON (AC: 1, 2)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### NutritionData entity complète

```dart
// lib/features/ocr_scan/domain/entities/nutrition_data.dart

@freezed
class NutritionData with _$NutritionData {
  const factory NutritionData({
    double? caloriesKcal,  // kcal pour 100g
    double? proteinG,      // grammes pour 100g
    double? carbsG,        // grammes pour 100g
    double? fatsG,         // grammes pour 100g
    double? fibersG,       // grammes pour 100g
    double? saltG,         // grammes pour 100g
    @Default(true) bool per100g,  // true = valeurs pour 100g
  }) = _NutritionData;

  factory NutritionData.empty() => const NutritionData();

  factory NutritionData.fromJson(Map<String, dynamic> json) =>
      _$NutritionDataFromJson(json);

  const NutritionData._();

  bool get isEmpty =>
      caloriesKcal == null &&
      proteinG == null &&
      carbsG == null &&
      fatsG == null;
}
```

### Parsing depuis OpenFoodFacts API

```dart
// Exemple JSON OpenFoodFacts nutriments:
// {
//   "energy-kcal_100g": 250.0,
//   "proteins_100g": 8.5,
//   "carbohydrates_100g": 42.0,
//   "fat_100g": 5.0,
//   "fiber_100g": 3.2,
//   "salt_100g": 1.1
// }

NutritionData _parseNutriments(Map<String, dynamic> nutriments) {
  return NutritionData(
    caloriesKcal: (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
    proteinG: (nutriments['proteins_100g'] as num?)?.toDouble(),
    carbsG: (nutriments['carbohydrates_100g'] as num?)?.toDouble(),
    fatsG: (nutriments['fat_100g'] as num?)?.toDouble(),
    fibersG: (nutriments['fiber_100g'] as num?)?.toDouble(),
    saltG: (nutriments['salt_100g'] as num?)?.toDouble(),
  );
}
```

### NutritionDataCard widget

```dart
// lib/features/ocr_scan/presentation/widgets/nutrition_data_card.dart

class NutritionDataCard extends StatelessWidget {
  final NutritionData nutrition;
  final VoidCallback? onEditTap;

  const NutritionDataCard({super.key, required this.nutrition, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    if (nutrition.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.grey),
          title: const Text('Données nutritionnelles non disponibles'),
          trailing: onEditTap != null
              ? TextButton(
                  onPressed: onEditTap,
                  child: const Text('Ajouter'),
                )
              : null,
        ),
      );
    }

    final calories = nutrition.caloriesKcal;
    final protein = nutrition.proteinG;
    final carbs = nutrition.carbsG;
    final fats = nutrition.fatsG;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valeurs nutritionnelles (pour 100g)',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            if (calories != null)
              _NutrientRow(label: 'Énergie', value: '${calories.round()} kcal'),
            if (protein != null)
              _NutrientRow(label: 'Protéines', value: '${protein.toStringAsFixed(1)} g'),
            if (carbs != null)
              _NutrientRow(label: 'Glucides', value: '${carbs.toStringAsFixed(1)} g'),
            if (fats != null)
              _NutrientRow(label: 'Lipides', value: '${fats.toStringAsFixed(1)} g'),
            if (nutrition.fibersG != null)
              _NutrientRow(label: 'Fibres', value: '${nutrition.fibersG!.toStringAsFixed(1)} g'),
            const SizedBox(height: 8),
            const Text(
              'Source: OpenFoodFacts (openfoodfacts.org)',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            if (onEditTap != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onEditTap,
                child: const Text('Modifier les valeurs'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutrientRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
        ],
      ),
    );
  }
}
```

### Intégration dans ProductEntity

```dart
// Étendre ProductEntity pour inclure NutritionData
// lib/features/inventory/domain/entities/product_entity.dart

@HiveType(typeId: 1)
@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    // ... champs existants ...
    @HiveField(12) NutritionData? nutritionData,  // Ajouter ce champ
  }) = _ProductEntity;
}
```

### Project Structure Notes

- `NutritionData` définie dans `lib/features/ocr_scan/domain/entities/` pour maintenant
- Epic 7 (nutrition_tracking) prendra ownership de `NutritionData` et l'utilisera pour tracking
- L'attribution "Source: OpenFoodFacts" est requise par les conditions d'utilisation de l'API
- OpenFoodFacts est open source et libre d'accès (pas d'API key requise)

### References

- [Source: epics.md#Story-5.5]
- OpenFoodFacts API [Source: architecture.md — GET https://world.openfoodfacts.org/api/v0/product/{barcode}.json]
- ProductCacheService (TTL 7j) [Source: Story 5.9]
- NutritionData (réutilisée par Epic 7)

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
