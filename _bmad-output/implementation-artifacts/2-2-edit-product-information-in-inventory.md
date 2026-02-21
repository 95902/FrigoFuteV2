# Story 2.2: Edit Product Information in Inventory

## 📋 Story Metadata

- **Story ID**: 2.2
- **Epic**: Epic 2 - Inventory Management
- **Title**: Edit Product Information in Inventory
- **Story Key**: 2-2-edit-product-information-in-inventory
- **Status**: ready-for-dev
- **Complexity**: 4 (S-M — CRUD update, réutilise l'infrastructure de Story 2.1)
- **Priority**: P1 (Core inventory management)
- **Estimated Effort**: 1-2 days
- **Dependencies**:
  - Story 2.1 (**REQUIS** — `ProductEntity`, `ProductModel`, `InventoryRepository`, `InventoryLocalDatasource`, providers Riverpod)
  - Story 0.9 (SyncService — `queueOperation('UPDATE', ...)`)
  - Story 0.10 (InputSanitizer)
  - Story 0.7 (AnalyticsService — event `product_edited`)
- **Tags**: `inventory`, `hive`, `firestore`, `offline-first`, `crud`, `riverpod`, `edit`

---

## 📖 User Story

**As a** Sophie (famille),
**I want** to modify product details like quantity or expiration date,
**So that** I can keep my inventory accurate when I use part of a product or find a different date.

---

## ✅ Acceptance Criteria

### AC1: Edit Product Fields
**Given** I have products in my inventory
**When** I tap on a product and select "Modifier"
**Then** a form opens pre-filled with all current product values (name, category, location, quantity, unit, expiration date, expiry type, notes)
**And** I can modify any field

### AC2: Save Changes — Hive-First (Optimistic UI)
**Given** I have modified one or more fields
**When** I tap "Enregistrer"
**Then** the changes are saved to Hive immediately
**And** the updated product appears instantly in the inventory list
**And** if online, the update syncs to Firestore
**And** if offline, the operation is queued in the sync queue with `operationType: 'UPDATE'`

### AC3: Status Recalculated on Date Change
**Given** I change the expiration date
**When** the product is saved
**Then** the product status (fresh / expiringSoon / expired) is automatically recalculated based on the new date
**And** the status badge in the inventory list reflects the new status immediately

### AC4: Version Increment for Sync Conflict Detection
**Given** I save an edited product
**When** the Hive record is updated
**Then** the `version` field is incremented by 1
**And** the new version is included in the Firestore sync payload

### AC5: Validation on Edit
**Given** I am editing a product
**When** I clear the product name
**Then** I see an inline error: "Le nom du produit est obligatoire"
**And** the "Enregistrer" button is disabled
**When** I set quantity ≤ 0
**Then** I see an inline error: "La quantité doit être supérieure à 0"

### AC6: Cancel Edit Without Saving
**Given** I am on the edit form
**When** I tap "Annuler" or press the back button
**Then** no changes are saved
**And** I return to the inventory list with the original data intact

### AC7: Analytics Event Logged
**Given** I successfully save a product edit
**When** the save completes
**Then** the analytics event `product_edited` is fired with parameters: `fields_changed: List<String>`, `category`

---

## 🏗️ Technical Specifications

### 1. Domain Layer Extensions

#### Update Repository Interface — `lib/features/inventory/domain/repositories/inventory_repository.dart`

Ajouter la méthode suivante à l'interface existante (créée en Story 2.1) :

```dart
/// Update an existing product (writes to Hive first, then queues Firestore sync)
Future<Either<AppException, ProductEntity>> updateProduct(ProductEntity product);
```

#### Use Case — `lib/features/inventory/domain/usecases/update_product_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/security/input_sanitizer.dart';
import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class UpdateProductUseCase {
  final InventoryRepository _repository;

  UpdateProductUseCase(this._repository);

  Future<Either<AppException, ProductEntity>> call({
    required ProductEntity original,
    required ProductEntity updated,
  }) async {
    // 1. Validate required fields
    if (updated.name.trim().isEmpty) {
      return Left(ValidationException(
        'Le nom du produit est obligatoire',
        {'name': 'required'},
      ));
    }

    if (updated.quantity <= 0) {
      return Left(ValidationException(
        'La quantité doit être supérieure à 0',
        {'quantity': 'must_be_positive'},
      ));
    }

    // 2. Sanitize text inputs
    final sanitized = updated.copyWith(
      name: InputSanitizer.sanitizeGenericInput(updated.name.trim()),
      notes: updated.notes != null
          ? InputSanitizer.sanitizeGenericInput(updated.notes!)
          : null,
    );

    // 3. Track changed fields for analytics
    final changedFields = _detectChangedFields(original, sanitized);

    // 4. Delegate to repository
    return _repository.updateProduct(
      sanitized.copyWith(
        // Pass changed fields as metadata via notes or separately — tracked in analytics call
      ),
    );
  }

  /// Returns list of field names that changed between original and updated
  List<String> detectChangedFields(ProductEntity original, ProductEntity updated) =>
      _detectChangedFields(original, updated);

  List<String> _detectChangedFields(ProductEntity original, ProductEntity updated) {
    final changed = <String>[];
    if (original.name != updated.name) changed.add('name');
    if (original.category != updated.category) changed.add('category');
    if (original.location != updated.location) changed.add('location');
    if (original.quantity != updated.quantity) changed.add('quantity');
    if (original.unit != updated.unit) changed.add('unit');
    if (original.expirationDate != updated.expirationDate) changed.add('expirationDate');
    if (original.expiryType != updated.expiryType) changed.add('expiryType');
    if (original.notes != updated.notes) changed.add('notes');
    return changed;
  }
}
```

---

### 2. Repository Implementation Update

Ajouter à `lib/features/inventory/data/repositories/inventory_repository_impl.dart` :

```dart
@override
Future<Either<AppException, ProductEntity>> updateProduct(ProductEntity product) async {
  try {
    // 1. Recompute status in case expiration date changed
    final withUpdatedStatus = product.copyWith(
      status: _computeStatus(product.expirationDate),
      isSyncPending: true,
    );

    // 2. Fetch current version from Hive for increment
    final existing = await _local.getProductById(product.id);
    final currentVersion = existing?.version ?? 0;

    final model = _toModel(withUpdatedStatus).copyWith(
      version: currentVersion + 1,  // Increment version (AC4)
    );

    // 3. Write to Hive immediately (optimistic UI)
    await _local.saveProduct(model);  // put() overwrites existing key

    // 4. Queue sync to Firestore
    await _syncService.queueOperation(
      operationType: 'UPDATE',
      collection: 'inventory_items',
      documentId: product.id,
      userId: product.userId,
      data: ProductModel.toFirestore(model),
    );

    // 5. Analytics (called from use case or presentation layer — see providers)
    _analytics.logEvent(
      name: 'product_edited',
      parameters: {
        'category': product.category.name,
      },
    );

    return Right(_toEntity(model));
  } on HiveException catch (e) {
    return Left(AppException('Erreur stockage local: ${e.message}', 'STORAGE_ERROR', e));
  } catch (e) {
    return Left(AppException('Erreur inattendue: $e', 'UNKNOWN_ERROR', e));
  }
}
```

> **NOTE**: `_local.saveProduct(model)` utilise `_box.put(model.id, model)` qui est idempotent — le même pattern que la création Story 2.1.

---

### 3. Riverpod Provider Update

Ajouter dans `lib/features/inventory/presentation/providers/inventory_providers.dart` :

```dart
final updateProductUseCaseProvider = Provider<UpdateProductUseCase>(
  (ref) => UpdateProductUseCase(ref.read(inventoryRepositoryProvider)),
);
```

---

### 4. UI — Edit Product Screen

#### `lib/features/inventory/presentation/screens/edit_product_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/inventory_providers.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final ProductEntity product;  // Passed via GoRouter extra

  const EditProductScreen({super.key, required this.product});

  static const routeName = '/inventory/edit';

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  late ProductCategory _selectedCategory;
  late StorageLocation _selectedLocation;
  late String _selectedUnit;
  late ExpiryType _selectedExpiryType;
  late DateTime? _expirationDate;
  bool _isLoading = false;

  static const List<String> _units = ['unité(s)', 'kg', 'g', 'L', 'ml', 'bouteille(s)'];

  /// Auto-assign location based on category (same mapping as AddProductScreen)
  static const Map<ProductCategory, StorageLocation> _categoryDefaultLocation = {
    ProductCategory.produitsLaitiers: StorageLocation.refrigerateur,
    ProductCategory.viandesPoissons: StorageLocation.refrigerateur,
    ProductCategory.fruitsLegumes: StorageLocation.refrigerateur,
    ProductCategory.surgeles: StorageLocation.congelateur,
    ProductCategory.boissons: StorageLocation.placard,
    ProductCategory.epicerieSalee: StorageLocation.placard,
    ProductCategory.epicerieSucree: StorageLocation.placard,
    ProductCategory.boulangerie: StorageLocation.placard,
    ProductCategory.platsPrepares: StorageLocation.refrigerateur,
    ProductCategory.saucesCondiments: StorageLocation.placard,
    ProductCategory.oeufs: StorageLocation.refrigerateur,
    ProductCategory.autre: StorageLocation.placard,
  };

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing product values (AC1)
    final p = widget.product;
    _nameController = TextEditingController(text: p.name);
    _quantityController = TextEditingController(text: p.quantity.toString());
    _notesController = TextEditingController(text: p.notes ?? '');
    _selectedCategory = p.category;
    _selectedLocation = p.location;
    _selectedUnit = _units.contains(p.unit) ? p.unit : 'unité(s)';
    _selectedExpiryType = p.expiryType;
    _expirationDate = p.expirationDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le produit'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Product Name ─────────────────────────────────────
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Le nom du produit est obligatoire'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),

              // ── Category ─────────────────────────────────────────
              DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: ProductCategory.values.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(_categoryLabel(cat)),
                )).toList(),
                onChanged: (cat) {
                  if (cat == null) return;
                  setState(() {
                    _selectedCategory = cat;
                    _selectedLocation =
                        _categoryDefaultLocation[cat] ?? StorageLocation.placard;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── Storage Location ─────────────────────────────────
              DropdownButtonFormField<StorageLocation>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                  labelText: 'Emplacement de stockage',
                  prefixIcon: Icon(Icons.kitchen_outlined),
                ),
                items: StorageLocation.values.map((loc) => DropdownMenuItem(
                  value: loc,
                  child: Text(_locationLabel(loc)),
                )).toList(),
                onChanged: (loc) => setState(() => _selectedLocation = loc!),
              ),
              const SizedBox(height: 16),

              // ── Quantity & Unit ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final qty = double.tryParse(v ?? '');
                        if (qty == null || qty <= 0) return 'Doit être > 0';
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unité'),
                      items: _units
                          .map((u) =>
                              DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (u) => setState(() => _selectedUnit = u!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Expiration Date ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickExpirationDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date d\'expiration',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          _expirationDate != null
                              ? DateFormat('dd/MM/yyyy').format(_expirationDate!)
                              : 'Aucune date',
                          style: TextStyle(
                            color: _expirationDate != null
                                ? (_isExpired(_expirationDate!)
                                    ? Colors.red
                                    : null)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_expirationDate != null) ...[
                    const SizedBox(width: 8),
                    DropdownButton<ExpiryType>(
                      value: _selectedExpiryType,
                      items: const [
                        DropdownMenuItem(value: ExpiryType.dlc, child: Text('DLC')),
                        DropdownMenuItem(value: ExpiryType.ddm, child: Text('DDM')),
                      ],
                      onChanged: (t) =>
                          setState(() => _selectedExpiryType = t!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Supprimer la date',
                      onPressed: () => setState(() => _expirationDate = null),
                    ),
                  ],
                ],
              ),
              if (_expirationDate != null && _isExpired(_expirationDate!))
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    'Date déjà dépassée — statut "Expiré" sera appliqué',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // ── Notes ─────────────────────────────────────────────
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // ── Submit ────────────────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2099),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) setState(() => _expirationDate = picked);
  }

  bool _isExpired(DateTime date) =>
      date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final useCase = ref.read(updateProductUseCaseProvider);
    final updated = widget.product.copyWith(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      location: _selectedLocation,
      quantity: double.parse(_quantityController.text),
      unit: _selectedUnit,
      expirationDate: _expirationDate,
      expiryType: _selectedExpiryType,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    // Detect changed fields for analytics
    final changedFields = useCase.detectChangedFields(widget.product, updated);

    final result = await useCase.call(
      original: widget.product,
      updated: updated,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
        ),
      ),
      (_) {
        // Log analytics with fields changed
        ref.read(analyticsServiceProvider).logEvent(
          name: 'product_edited',
          parameters: {
            'fields_changed': changedFields.join(','),
            'category': updated.category.name,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit mis à jour ✓')),
        );
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Label helpers ─────────────────────────────────────────────────────

  String _categoryLabel(ProductCategory cat) {
    const labels = {
      ProductCategory.produitsLaitiers: 'Produits laitiers',
      ProductCategory.viandesPoissons: 'Viandes & Poissons',
      ProductCategory.fruitsLegumes: 'Fruits & Légumes',
      ProductCategory.epicerieSucree: 'Épicerie sucrée',
      ProductCategory.epicerieSalee: 'Épicerie salée',
      ProductCategory.surgeles: 'Surgelés',
      ProductCategory.boissons: 'Boissons',
      ProductCategory.boulangerie: 'Boulangerie',
      ProductCategory.platsPrepares: 'Plats préparés',
      ProductCategory.saucesCondiments: 'Sauces & Condiments',
      ProductCategory.oeufs: 'Œufs',
      ProductCategory.autre: 'Autre',
    };
    return labels[cat] ?? cat.name;
  }

  String _locationLabel(StorageLocation loc) {
    const labels = {
      StorageLocation.refrigerateur: '🧊 Réfrigérateur',
      StorageLocation.congelateur: '❄️ Congélateur',
      StorageLocation.placard: '🗄️ Placard',
      StorageLocation.gardeManger: '🏠 Garde-manger',
      StorageLocation.comptoir: '🍽️ Comptoir',
      StorageLocation.autre: '📦 Autre',
    };
    return labels[loc] ?? loc.name;
  }
}
```

---

### 5. GoRouter Integration

Dans la configuration GoRouter (Story 0.5), ajouter la route d'édition :

```dart
GoRoute(
  path: '/inventory/edit',
  name: 'editProduct',
  builder: (context, state) {
    final product = state.extra as ProductEntity;
    return EditProductScreen(product: product);
  },
),
```

**Navigation depuis l'inventaire** :

```dart
// Dans ProductCard ou ProductDetailScreen
context.push('/inventory/edit', extra: product);
```

---

## 📝 Implementation Tasks

### Phase 1: Domain Layer (Jour 1)

- [ ] **T1.1**: Ajouter `updateProduct(ProductEntity)` à l'interface `InventoryRepository`
- [ ] **T1.2**: Créer `UpdateProductUseCase` avec validation + `detectChangedFields()`
- [ ] **T1.3**: Tests unitaires `UpdateProductUseCase` — nom vide, quantité ≤ 0, champs changés détectés

### Phase 2: Data Layer (Jour 1)

- [ ] **T2.1**: Implémenter `updateProduct()` dans `InventoryRepositoryImpl` — Hive put + version++ + SyncService `'UPDATE'`
- [ ] **T2.2**: Tests unitaires `InventoryRepositoryImpl.updateProduct()` — vérifier version incrémentée, SyncService appelé avec `'UPDATE'`, status recalculé

### Phase 3: Providers (Jour 1)

- [ ] **T3.1**: Ajouter `updateProductUseCaseProvider` dans `inventory_providers.dart`

### Phase 4: UI (Jour 1-2)

- [ ] **T4.1**: Créer `EditProductScreen` avec pré-remplissage des champs depuis `ProductEntity` passé en paramètre
- [ ] **T4.2**: Implémenter bouton "Annuler" → `Navigator.pop()` sans sauvegarde (AC6)
- [ ] **T4.3**: Implémenter bouton "Supprimer la date" pour effacer `expirationDate`
- [ ] **T4.4**: Ajouter route `/inventory/edit` dans GoRouter avec `extra: ProductEntity`
- [ ] **T4.5**: Ajouter point d'entrée "Modifier" depuis `ProductCard` / `ProductDetailScreen` (long press ou bouton édition)
- [ ] **T4.6**: Tests widget `EditProductScreen`

### Phase 5: Tests & Couverture (Jour 2)

- [ ] **T5.1**: Couverture ≥ 75% sur tous les nouveaux fichiers
- [ ] **T5.2**: Test manuel — modifier un produit hors ligne → vérifier Hive + queue sync
- [ ] **T5.3**: `flutter analyze` → 0 erreurs

---

## 🧪 Testing Strategy

### Unit Tests

**`test/features/inventory/domain/usecases/update_product_usecase_test.dart`**:
```dart
group('UpdateProductUseCase', () {
  test('should update product with valid inputs', ...);
  test('should return error when name is empty', ...);
  test('should return error when quantity is 0', ...);
  test('should detect changed fields correctly', () {
    final original = ProductEntity(..., name: 'Lait', quantity: 1.0);
    final updated  = ProductEntity(..., name: 'Lait demi-écrémé', quantity: 0.5);
    final changed  = useCase.detectChangedFields(original, updated);
    expect(changed, containsAll(['name', 'quantity']));
    expect(changed, isNot(contains('category')));
  });
  test('should sanitize name input', ...);
});
```

**`test/features/inventory/data/repositories/inventory_repository_update_test.dart`**:
```dart
group('InventoryRepositoryImpl.updateProduct', () {
  test('should increment version field', () async {
    // Arrange: existing product with version 3
    final existing = ProductModel(..., version: 3);
    when(() => mockLocal.getProductById(any())).thenAnswer((_) async => existing);

    // Act
    await repo.updateProduct(productEntity);

    // Assert: saved with version 4
    final captured = verify(() => mockLocal.saveProduct(captureAny())).captured.first as ProductModel;
    expect(captured.version, 4);
  });
  test('should queue SyncService with operationType UPDATE', ...);
  test('should recalculate status when expirationDate changes', ...);
  test('should write to Hive before queuing sync', ...);
});
```

### Widget Tests

**`test/features/inventory/presentation/screens/edit_product_screen_test.dart`**:
```dart
group('EditProductScreen', () {
  testWidgets('pre-fills all form fields from ProductEntity', (tester) async {
    final product = ProductEntity(
      id: '1', name: 'Lait', category: ProductCategory.produitsLaitiers, ...
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(home: EditProductScreen(product: product)),
    ));
    expect(find.text('Lait'), findsOneWidget);
  });
  testWidgets('Cancel button returns without saving', ...);
  testWidgets('shows error when name cleared on submit', ...);
  testWidgets('shows success Snackbar after save', ...);
  testWidgets('clear date button sets expirationDate to null', ...);
});
```

---

## ⚠️ Anti-Patterns à Éviter

### ❌ Créer un nouvel objet sans conserver l'ID existant

```dart
// ❌ INTERDIT — génère un nouvel ID, perd la référence Hive/Firestore
final updated = ProductEntity(
  id: const Uuid().v4(),  // ❌ nouveau UUID à chaque édition
  ...
);

// ✅ CORRECT — conserver l'ID original
final updated = widget.product.copyWith(
  name: _nameController.text,
  // id, userId, addedDate préservés automatiquement
);
```

### ❌ Oublier d'incrémenter le `version`

```dart
// ❌ Pas de détection de conflit possible en sync LWW
await _local.saveProduct(model);  // version reste à 0

// ✅ Incrémenter à chaque UPDATE
final model = _toModel(product).copyWith(version: currentVersion + 1);
await _local.saveProduct(model);
```

### ❌ Appeler `addProduct` au lieu de `updateProduct`

```dart
// ❌ Crée un doublon dans l'inventaire (même nom, ID différent)
await _repository.addProduct(editedProduct);

// ✅ Utiliser updateProduct qui préserve l'ID existant
await _repository.updateProduct(editedProduct);
```

### ❌ Partager le même écran Add/Edit avec flag booléen

```dart
// ❌ Complexité inutile, difficulté de test, violation SRP
class AddEditProductScreen extends StatefulWidget {
  final bool isEditing;  // ❌ double responsabilité
  ...
}

// ✅ Deux écrans séparés avec responsabilité unique
// AddProductScreen — création
// EditProductScreen — modification
```

---

## 🔗 Points d'Intégration

### Story 2.1 (AddProduct — REQUIS)
- `ProductEntity`, `ProductModel`, `InventoryRepository` (interface) déjà définis
- `InventoryLocalDatasource.saveProduct()` est idempotent → même appel pour create et update
- `_computeStatus()` dans `InventoryRepositoryImpl` → réutiliser sans duplication
- `_categoryDefaultLocation` dans AddProductScreen → extraire en constante partagée si besoin

### Story 0.9 (SyncService)
- `queueOperation(operationType: 'UPDATE', ...)` — même API que `'CREATE'`
- Le SyncService gère les conflits LWW côté serveur

### Story 2.3 (Delete — Story suivante)
- `ProductDetailScreen` (ou `ProductCard`) contiendra les actions Edit + Delete
- Si `ProductDetailScreen` n'est pas encore créé dans 2.1, à créer dans 2.2 ou 2.3

### Story 2.10 (Status Lifecycle)
- `_computeStatus()` sera extrait en `ProductStatusService` partagé dans Story 2.10
- Pour l'instant, dupliquer dans `updateProduct()` est acceptable

---

## 📚 Dev Notes

### Décisions de Design

1. **Pourquoi deux écrans séparés `Add` et `Edit` ?**
   Responsabilité unique (SRP). Les deux flows ont des subtilités différentes : Add génère un UUID et initialise `addedDate`, Edit préserve ces champs et incrémente `version`. Un seul écran avec `isEditing` devient difficile à tester et à maintenir.

2. **Pourquoi `extra: ProductEntity` dans GoRouter plutôt que `productId` ?**
   Évite un aller-retour Hive pour recharger le produit. Le `ProductEntity` est déjà en mémoire dans le `InventoryNotifier`. Si la navigation vient d'une liste Riverpod, l'objet est disponible immédiatement.

3. **Pourquoi détecter les `changedFields` dans le UseCase ?**
   Analytics plus riches : savoir quels champs les utilisateurs modifient le plus (quantité ? date ?) guide les décisions UX futures.

### Pièges Communs

1. **Ne pas appeler `copyWith` sur `widget.product`** → risque de perdre `id`, `userId`, `addedDate`
2. **Oublier le bouton "Supprimer la date"** → sinon impossible de retirer une date une fois entrée
3. **Ne pas tester le cancel** → scénario AC6 souvent omis dans les tests

---

## ✅ Definition of Done

### Fonctionnel
- [ ] Formulaire pré-rempli avec les données existantes du produit
- [ ] Tous les champs modifiables (nom, catégorie, emplacement, quantité, unité, date, type, notes)
- [ ] Recalcul statut si date modifiée
- [ ] Version incrémentée dans Hive et payload sync
- [ ] Annulation sans sauvegarde fonctionnelle
- [ ] Snackbar succès/erreur

### Non-Fonctionnel
- [ ] Mise à jour Hive < 50ms
- [ ] UI réactive offline
- [ ] `flutter analyze` 0 erreurs

### Qualité Code
- [ ] Couverture ≥ 75% sur nouveaux fichiers
- [ ] Tests unitaires UseCase + Repository
- [ ] Tests widget EditProductScreen
- [ ] `InventoryRepository` interface mise à jour avec `updateProduct()`

### Intégration
- [ ] Route `/inventory/edit` ajoutée dans GoRouter
- [ ] Point d'entrée "Modifier" depuis ProductCard/Detail
- [ ] `updateProductUseCaseProvider` déclaré

---

## 📎 Références

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.2]
- [Source: _bmad-output/planning-artifacts/architecture.md#Patterns d'Implémentation — State Management]
- [Source: _bmad-output/planning-artifacts/architecture.md#Stratégie Synchronisation — version field]
- [Source: _bmad-output/implementation-artifacts/2-1-add-product-manually-to-inventory.md]

---

## 🤖 Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

*(à remplir par le Dev Agent)*

### Completion Notes List

*(à remplir par le Dev Agent)*

### File List

*(à remplir par le Dev Agent)*

---

**Story Created**: 2026-02-20
**Last Updated**: 2026-02-20
**Ready for Dev**: ✅ Oui
