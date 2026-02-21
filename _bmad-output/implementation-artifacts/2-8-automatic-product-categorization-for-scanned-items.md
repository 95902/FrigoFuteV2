# Story 2.8: Automatic Product Categorization for Scanned Items

## 📋 Story Metadata

- **Story ID**: 2.8 | **Complexity**: 3 (S — service métier + keyword map + corrections Hive)
- **Story Key**: 2-8-automatic-product-categorization-for-scanned-items
- **Status**: ready-for-dev | **Effort**: 1 day
- **Dependencies**: Story 2.1 (`ProductCategory` enum, `ProductEntity`), Story 0.3 (Hive)
- **Consommé par**: Epic 5 (OCR/Barcode scanner), Story 2.9 (location suggestion uses category)

---

## 📖 User Story

**As a** Thomas (sportif),
**I want** scanned products to be automatically categorized,
**So that** I don't have to manually organize every item I add.

---

## ✅ Acceptance Criteria

### AC1: Catégorisation automatique par nom
**Given** un nom de produit est fourni (saisie manuelle, OCR, ou barcode)
**When** le service de catégorisation est appelé
**Then** il retourne une des 12 `ProductCategory` basée sur keyword matching
**And** précision ≥ 85% pour les produits alimentaires français courants

### AC2: Override manuel persistant
**Given** un produit avec barcode connu a été recatégorisé manuellement
**When** le même barcode est détecté à nouveau
**Then** la catégorie corrigée est utilisée à la place du keyword matching
**And** la correction est stockée dans Hive (`category_corrections` box)

### AC3: Fallback category
**Given** aucun keyword ne correspond au nom du produit
**Then** le produit est assigné à `ProductCategory.autre`
**And** le champ catégorie dans le formulaire est pré-rempli mais non verrouillé

### AC4: Intégration AddProductScreen
**Given** je saisis un nom de produit dans le formulaire d'ajout
**When** le champ name change (onChanged)
**Then** le champ catégorie se pré-remplit automatiquement via le service
**And** si je modifie manuellement la catégorie, la détection automatique cesse pour ce champ
**And** un indicateur visuel montre "Catégorie détectée automatiquement"

---

## 🏗️ Technical Specifications

### ProductCategorizationService

```dart
// lib/features/inventory/domain/services/product_categorization_service.dart

class ProductCategorizationService {
  final Box<String> _correctionsBox; // key: barcode | normalizedName → category.name

  ProductCategorizationService(this._correctionsBox);

  // ===== Keyword rules — French grocery items =====
  static const Map<String, ProductCategory> _keywordRules = {
    // Produits laitiers
    'lait':       ProductCategory.produitsLaitiers,
    'fromage':    ProductCategory.produitsLaitiers,
    'yaourt':     ProductCategory.produitsLaitiers,
    'yogourt':    ProductCategory.produitsLaitiers,
    'yoghurt':    ProductCategory.produitsLaitiers,
    'beurre':     ProductCategory.produitsLaitiers,
    'creme':      ProductCategory.produitsLaitiers,
    'margarine':  ProductCategory.produitsLaitiers,
    'kefir':      ProductCategory.produitsLaitiers,
    'ricotta':    ProductCategory.produitsLaitiers,
    // Viandes & Poissons
    'poulet':     ProductCategory.viandesPoissons,
    'boeuf':      ProductCategory.viandesPoissons,
    'steak':      ProductCategory.viandesPoissons,
    'porc':       ProductCategory.viandesPoissons,
    'agneau':     ProductCategory.viandesPoissons,
    'saumon':     ProductCategory.viandesPoissons,
    'thon':       ProductCategory.viandesPoissons,
    'crevettes':  ProductCategory.viandesPoissons,
    'cabillaud':  ProductCategory.viandesPoissons,
    'jambon':     ProductCategory.viandesPoissons,
    'saucisse':   ProductCategory.viandesPoissons,
    'lardons':    ProductCategory.viandesPoissons,
    // Fruits & Légumes
    'pomme':      ProductCategory.fruitsLegumes,
    'banane':     ProductCategory.fruitsLegumes,
    'tomate':     ProductCategory.fruitsLegumes,
    'carotte':    ProductCategory.fruitsLegumes,
    'salade':     ProductCategory.fruitsLegumes,
    'courgette':  ProductCategory.fruitsLegumes,
    'citron':     ProductCategory.fruitsLegumes,
    'fraise':     ProductCategory.fruitsLegumes,
    'raisin':     ProductCategory.fruitsLegumes,
    'poivron':    ProductCategory.fruitsLegumes,
    'oignon':     ProductCategory.fruitsLegumes,
    // Surgelés
    'surgele':    ProductCategory.surgeles,
    'glace':      ProductCategory.surgeles,
    'congelé':    ProductCategory.surgeles,
    // Boissons
    'jus':        ProductCategory.boissons,
    'eau':        ProductCategory.boissons,
    'lemonade':   ProductCategory.boissons,
    'soda':       ProductCategory.boissons,
    'biere':      ProductCategory.boissons,
    'vin':        ProductCategory.boissons,
    'cafe':       ProductCategory.boissons,
    'the ':       ProductCategory.boissons, // 'thé' with trailing space to avoid 'thérapie'
    // Boulangerie
    'pain':       ProductCategory.boulangerie,
    'brioche':    ProductCategory.boulangerie,
    'baguette':   ProductCategory.boulangerie,
    'croissant':  ProductCategory.boulangerie,
    'gateau':     ProductCategory.boulangerie,
    'biscuit':    ProductCategory.boulangerie,
    'cookie':     ProductCategory.boulangerie,
    // Épicerie sucrée
    'confiture':  ProductCategory.epicerieSucree,
    'miel':       ProductCategory.epicerieSucree,
    'chocolat':   ProductCategory.epicerieSucree,
    'sucre':      ProductCategory.epicerieSucree,
    'cereales':   ProductCategory.epicerieSucree,
    'compote':    ProductCategory.epicerieSucree,
    // Épicerie salée
    'pates':      ProductCategory.epicerieSalee,
    'riz':        ProductCategory.epicerieSalee,
    'lentilles':  ProductCategory.epicerieSalee,
    'haricots':   ProductCategory.epicerieSalee,
    'farine':     ProductCategory.epicerieSalee,
    'sel':        ProductCategory.epicerieSalee,
    'huile':      ProductCategory.epicerieSalee,
    'vinaigre':   ProductCategory.epicerieSalee,
    // Sauces & Condiments
    'ketchup':    ProductCategory.saucesCondiments,
    'mayonnaise': ProductCategory.saucesCondiments,
    'moutarde':   ProductCategory.saucesCondiments,
    'sauce':      ProductCategory.saucesCondiments,
    'pesto':      ProductCategory.saucesCondiments,
    // Œufs
    'oeuf':       ProductCategory.oeufs,
    'oeufs':      ProductCategory.oeufs,
    // Plats préparés
    'pizza':      ProductCategory.platsPrepares,
    'lasagne':    ProductCategory.platsPrepares,
    'quiche':     ProductCategory.platsPrepares,
    'soupe':      ProductCategory.platsPrepares,
    'ravioli':    ProductCategory.platsPrepares,
  };

  /// Catégorise un produit à partir de son nom et/ou barcode.
  /// Priorité: correction manuelle > keyword matching > autre
  ProductCategory categorize({String? barcode, required String productName}) {
    // 1. Check saved correction by barcode
    if (barcode != null && barcode.isNotEmpty) {
      final savedByBarcode = _correctionsBox.get('barcode_$barcode');
      if (savedByBarcode != null) {
        return ProductCategory.values.firstWhere(
          (c) => c.name == savedByBarcode,
          orElse: () => ProductCategory.autre,
        );
      }
    }

    // 2. Check saved correction by normalized name
    final normalizedName = _normalize(productName);
    final savedByName = _correctionsBox.get('name_$normalizedName');
    if (savedByName != null) {
      return ProductCategory.values.firstWhere(
        (c) => c.name == savedByName,
        orElse: () => ProductCategory.autre,
      );
    }

    // 3. Keyword matching
    for (final entry in _keywordRules.entries) {
      if (normalizedName.contains(entry.key)) return entry.value;
    }

    return ProductCategory.autre;
  }

  /// Sauvegarde une correction manuelle (persiste dans Hive)
  Future<void> saveCorrection({
    String? barcode,
    required String productName,
    required ProductCategory category,
  }) async {
    if (barcode != null && barcode.isNotEmpty) {
      await _correctionsBox.put('barcode_$barcode', category.name);
    }
    final normalizedName = _normalize(productName);
    if (normalizedName.isNotEmpty) {
      await _correctionsBox.put('name_$normalizedName', category.name);
    }
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .trim();
  }
}
```

### Hive Box Registration

```dart
// Dans HiveInitializer (Story 0.3) ou main.dart :
await Hive.openBox<String>('category_corrections');
```

### Riverpod Provider

```dart
// lib/features/inventory/presentation/providers/inventory_providers.dart

final productCategorizationServiceProvider = Provider<ProductCategorizationService>((ref) {
  final box = Hive.box<String>('category_corrections');
  return ProductCategorizationService(box);
});
```

### Intégration dans AddProductScreen

```dart
// Dans AddProductScreen (Story 2.1) — mise à jour du champ name

bool _categoryAutoDetected = false;

// TextFormField pour le nom du produit:
onChanged: (name) {
  if (!_categoryManuallySet) {
    final service = ref.read(productCategorizationServiceProvider);
    final detected = service.categorize(
      barcode: widget.barcode,  // null si saisie manuelle
      productName: name,
    );
    setState(() {
      _selectedCategory = detected;
      _categoryAutoDetected = detected != ProductCategory.autre;
    });
  }
},

// Indicateur visuel :
if (_categoryAutoDetected)
  Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        const Icon(Icons.auto_fix_high, size: 14, color: Colors.blue),
        const SizedBox(width: 4),
        Text(
          'Catégorie détectée automatiquement',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue),
        ),
      ],
    ),
  ),

// Quand l'utilisateur change manuellement la catégorie :
onCategoryChanged: (category) {
  setState(() {
    _selectedCategory = category;
    _categoryManuallySet = true;
    _categoryAutoDetected = false;
  });
  // Sauvegarder la correction si barcode fourni
  if (widget.barcode != null) {
    ref.read(productCategorizationServiceProvider).saveCorrection(
      barcode: widget.barcode,
      productName: _nameController.text,
      category: category,
    );
  }
},
```

---

## 📝 Implementation Tasks

- [ ] **T1**: Créer `ProductCategorizationService` avec keyword map complète (50+ keywords)
- [ ] **T2**: Ouvrir `category_corrections` HiveBox dans l'init
- [ ] **T3**: Créer `productCategorizationServiceProvider`
- [ ] **T4**: Intégrer dans `AddProductScreen` — auto-detect + indicateur visuel + save correction
- [ ] **T5**: Tests unitaires — keyword matching, corrections, normalize, fallback
- [ ] **T6**: Tests intégration — correction persistée et réutilisée
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

---

## 🧪 Testing Strategy

```dart
group('ProductCategorizationService', () {
  test('categorizes "lait entier" → produitsLaitiers', ...);
  test('categorizes "Poulet rôti" → viandesPoissons (case-insensitive)', ...);
  test('categorizes "unknown xyz" → autre', ...);
  test('uses barcode correction over keyword matching', ...);
  test('uses name correction when barcode null', ...);
  test('normalize removes diacritics: "Éœufs" → "oeufs"', ...);
  test('saveCorrection persists and is returned next call', ...);
});
```

---

## ⚠️ Anti-Patterns à Éviter

```dart
// ❌ Appel API externe pour chaque catégorisation
await http.post('https://api.openai.com/...', body: {'name': productName});  // ❌ lent, offline-unsafe

// ✅ Keyword map locale, synchrone, offline-first
final category = service.categorize(productName: name);  // ✅ instantané

// ❌ Stocker les corrections dans Firestore (sync requise)
// ✅ Hive local pour les corrections (disponible offline, sync non-critique)
```

---

## 🔗 Points d'Intégration

- **Story 2.1** : Mise à jour `AddProductScreen` pour auto-detect catégorie
- **Story 2.9** : `suggestLocation()` utilise la catégorie retournée par ce service
- **Epic 5 (Story 5.1)** : `ProductCategorizationService.categorize(barcode: ean13, productName: openFoodFactsName)` appelé lors de l'ajout par scan barcode
- **Epic 5 (Story 5.2)** : même service appelé avec le nom extrait par OCR

---

## ✅ Definition of Done

- [ ] `ProductCategorizationService` avec 50+ keywords couvrant les 12 catégories
- [ ] Corrections manuelles persistées dans Hive
- [ ] Intégration `AddProductScreen` — auto-detect + indicateur + save correction
- [ ] `productCategorizationServiceProvider` Riverpod
- [ ] Couverture ≥ 75% | `flutter analyze` 0 erreurs

---

**Story Created**: 2026-02-20 | **Ready for Dev**: ✅ Oui
