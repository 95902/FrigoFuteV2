# Story 2.9: Automatic Storage Location Assignment for Added Products

## 📋 Story Metadata

- **Story ID**: 2.9 | **Complexity**: 1 (XS — pure static mapping, 12 catégories → 6 emplacements)
- **Story Key**: 2-9-automatic-storage-location-assignment-for-added-products
- **Status**: ready-for-dev | **Effort**: 0.25 day
- **Dependencies**: Story 2.1 (`ProductCategory`, `StorageLocation`), Story 2.8 (catégorie auto-détectée)

---

## 📖 User Story

**As a** Sophie (famille),
**I want** new products to be assigned a default storage location automatically,
**So that** I don't have to specify it every time unless I want to.

---

## ✅ Acceptance Criteria

### AC1: Location suggérée par catégorie
**Given** je sélectionne ou détecte une catégorie produit
**When** l'AddProductScreen calcule la location par défaut
**Then** la location suggérée est:
- `produitsLaitiers`, `viandesPoissons`, `fruitsLegumes`, `oeufs` → `StorageLocation.refrigerateur`
- `surgeles` → `StorageLocation.congelateur`
- `epicerieSalee`, `epicerieSucree`, `saucesCondiments`, `boissons` → `StorageLocation.placard`
- `boulangerie`, `platsPrepares` → `StorageLocation.comptoir`
- `autre` → `StorageLocation.autre`

### AC2: Override manuel
**Given** la location est pré-remplie automatiquement
**When** je change manuellement la location
**Then** ma sélection est conservée et n'est plus écrasée par la détection automatique
**And** aucune correction n'est sauvegardée (la règle statique s'applique toujours)

### AC3: Mise à jour en cascade avec la catégorie
**Given** l'auto-détection de catégorie (Story 2.8) est active
**When** la catégorie change (via typing ou correction)
**Then** la location suggérée se met à jour automatiquement
**And** seulement si l'utilisateur n'a pas encore overridé la location manuellement

---

## 🏗️ Technical Specifications

### StorageLocationSuggestionService

```dart
// lib/features/inventory/domain/services/storage_location_suggestion_service.dart

class StorageLocationSuggestionService {
  /// Règles statiques: catégorie → emplacement par défaut
  static const Map<ProductCategory, StorageLocation> _categoryToLocation = {
    ProductCategory.produitsLaitiers:  StorageLocation.refrigerateur,
    ProductCategory.viandesPoissons:   StorageLocation.refrigerateur,
    ProductCategory.fruitsLegumes:     StorageLocation.refrigerateur,
    ProductCategory.oeufs:             StorageLocation.refrigerateur,
    ProductCategory.surgeles:          StorageLocation.congelateur,
    ProductCategory.epicerieSalee:     StorageLocation.placard,
    ProductCategory.epicerieSucree:    StorageLocation.placard,
    ProductCategory.saucesCondiments:  StorageLocation.placard,
    ProductCategory.boissons:          StorageLocation.placard,
    ProductCategory.boulangerie:       StorageLocation.comptoir,
    ProductCategory.platsPrepares:     StorageLocation.comptoir,
    ProductCategory.autre:             StorageLocation.autre,
  };

  /// Retourne la location suggérée pour une catégorie donnée.
  StorageLocation suggest(ProductCategory category) {
    return _categoryToLocation[category] ?? StorageLocation.autre;
  }
}
```

### Riverpod Provider

```dart
// lib/features/inventory/presentation/providers/inventory_providers.dart

final storageLocationSuggestionServiceProvider =
    Provider<StorageLocationSuggestionService>(
  (_) => StorageLocationSuggestionService(),
);
```

### Intégration dans AddProductScreen

```dart
// Mise à jour de AddProductScreen (Story 2.1)
// Logique: quand catégorie change → suggérer la location (si pas d'override manuel)

bool _locationManuallySet = false;

// Quand la catégorie change (auto ou manuelle):
void _onCategoryChanged(ProductCategory category) {
  setState(() {
    _selectedCategory = category;
  });
  if (!_locationManuallySet) {
    final suggested = ref
        .read(storageLocationSuggestionServiceProvider)
        .suggest(category);
    setState(() {
      _selectedLocation = suggested;
    });
  }
}

// Quand l'utilisateur change manuellement la location:
void _onLocationChanged(StorageLocation location) {
  setState(() {
    _selectedLocation = location;
    _locationManuallySet = true;
  });
}
```

---

## 📝 Implementation Tasks

- [ ] **T1**: Créer `StorageLocationSuggestionService` (pure mapping, pas de Hive)
- [ ] **T2**: Créer `storageLocationSuggestionServiceProvider`
- [ ] **T3**: Mettre à jour `AddProductScreen` — cascade category→location + flag `_locationManuallySet`
- [ ] **T4**: Tests unitaires — les 12 catégories → bonne location
- [ ] **T5**: Test intégration AddProductScreen — cascade fonctionne, override respecté
- [ ] **T6**: `flutter analyze` 0 erreurs | couverture ≥ 75%

---

## 🧪 Testing Strategy

```dart
group('StorageLocationSuggestionService', () {
  final service = StorageLocationSuggestionService();

  test('produitsLaitiers → refrigerateur', () {
    expect(service.suggest(ProductCategory.produitsLaitiers),
        StorageLocation.refrigerateur);
  });
  test('surgeles → congelateur', () {
    expect(service.suggest(ProductCategory.surgeles),
        StorageLocation.congelateur);
  });
  test('epicerieSalee → placard', () {
    expect(service.suggest(ProductCategory.epicerieSalee),
        StorageLocation.placard);
  });
  test('boulangerie → comptoir', () {
    expect(service.suggest(ProductCategory.boulangerie),
        StorageLocation.comptoir);
  });
  test('autre → autre', () {
    expect(service.suggest(ProductCategory.autre), StorageLocation.autre);
  });
  test('all 12 categories have a mapping', () {
    for (final cat in ProductCategory.values) {
      expect(service.suggest(cat), isNotNull);
    }
  });
});
```

---

## ⚠️ Anti-Patterns à Éviter

```dart
// ❌ Stocker les suggestions dans Hive/Firestore (c'est statique, pas besoin)
// ✅ Pure function — pas de side effects, testable sans setup

// ❌ Logique de suggestion dans le widget (impossible à tester unitairement)
// ✅ Service injecté via Riverpod
```

---

## 🔗 Points d'Intégration

- **Story 2.1** : `AddProductScreen` consomme le service pour pré-remplir le champ location
- **Story 2.8** : Quand `ProductCategorizationService` détecte une catégorie, déclenche la suggestion de location
- **Epic 5** : Lors d'un scan barcode/OCR, catégorie ET location sont auto-remplies avant présentation à l'utilisateur

---

## ✅ Definition of Done

- [ ] `StorageLocationSuggestionService` avec les 12 mappings
- [ ] Intégration `AddProductScreen` — cascade category→location
- [ ] Override manuel respecté (flag `_locationManuallySet`)
- [ ] 12/12 mappings testés unitairement
- [ ] `flutter analyze` 0 erreurs

---

**Story Created**: 2026-02-20 | **Ready for Dev**: ✅ Oui
