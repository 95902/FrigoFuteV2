# Story 2.1: Add Product Manually to Inventory

## 📋 Story Metadata

- **Story ID**: 2.1
- **Epic**: Epic 2 - Inventory Management
- **Title**: Add Product Manually to Inventory
- **Story Key**: 2-1-add-product-manually-to-inventory
- **Status**: ready-for-dev
- **Complexity**: 5 (M — Core CRUD with offline-first and dual datasource)
- **Priority**: P0 (Blocker for all Epic 2+ inventory features)
- **Estimated Effort**: 2-3 days
- **Dependencies**:
  - Story 0.1 (Flutter Feature-First project structure)
  - Story 0.2 (Firebase / Firestore configured)
  - Story 0.3 (Hive local database + inventory_box)
  - Story 0.4 (Riverpod state management)
  - Story 0.9 (Offline-first sync architecture — SyncService + SyncQueueBox)
  - Story 0.10 (InputSanitizer, security foundation)
  - Epic 1 (Auth — userId required to scope Firestore collection)
- **Tags**: `inventory`, `hive`, `firestore`, `offline-first`, `crud`, `riverpod`, `clean-architecture`

---

## 📖 User Story

**As a** Marie (senior),
**I want** to add homemade products or items without barcodes manually to my inventory,
**So that** I can track everything I have in my fridge and pantry.

---

## ✅ Acceptance Criteria

### AC1: Manual Product Addition
**Given** I am on the inventory screen
**When** I tap "Ajouter un produit manuellement" and fill in name, category, quantity, expiration date, and storage location
**Then** the product is saved to Hive immediately (optimistic UI)
**And** the product appears instantly in my inventory list
**And** if online, the product syncs to Firestore
**And** if offline, the operation is queued in the sync queue

### AC2: Required Field Validation
**Given** I am on the add product form
**When** I try to submit without filling the product name
**Then** I see an inline error: "Le nom du produit est obligatoire"
**And** the submit button remains disabled

### AC3: Expiration Date Validation
**Given** I am entering an expiration date
**When** I enter a date in the past
**Then** I see a warning: "La date est déjà dépassée — ce produit sera marqué 'Expiré'"
**And** I can still save (expired products are valid entries)
**When** I do not enter any date
**Then** the product is saved with `expirationDate: null` and status `fresh` by default

### AC4: Default Category Assignment
**Given** I add a product and do not specify a category
**When** the product is saved
**Then** the system assigns the default category `autre`
**And** I can change the category from the dropdown at any time before saving

### AC5: Default Storage Location Assignment
**Given** I add a product with category "Produits laitiers", "Viandes & Poissons", or "Fruits & Légumes"
**When** the product is saved with no location specified
**Then** the system auto-assigns location `refrigerateur`
**Given** category is "Surgelés"
**Then** location is auto-assigned `congelateur`
**Given** any other category
**Then** location is auto-assigned `placard`

### AC6: Quantity Validation
**Given** I am filling in the quantity
**When** I enter a value ≤ 0
**Then** I see an inline error: "La quantité doit être supérieure à 0"
**When** I leave the quantity blank
**Then** it defaults to `1`

### AC7: Product Appears in Inventory Immediately (Optimistic UI)
**Given** I confirm adding a product
**When** the save action completes
**Then** the product appears immediately in the inventory list (Hive local write first)
**And** I see a Snackbar confirmation: "Produit ajouté avec succès"
**And** if I am offline, an "En attente de sync" badge is visible on the product

### AC8: Analytics Event Logged
**Given** I successfully add a product
**When** the product is saved
**Then** the analytics event `product_added` is fired with parameters: `method: manual`, `category`, `has_expiry_date: bool`

---

## 🏗️ Technical Specifications

### 1. Product Data Model

#### Domain Entity — `lib/features/inventory/domain/entities/product_entity.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_entity.freezed.dart';

enum ProductStatus { fresh, expiringSoon, expired, consumed }
enum ExpiryType { dlc, ddm }     // DLC = Date Limite Consommation, DDM = Date Durabilité Minimale
enum StorageLocation { refrigerateur, congelateur, placard, gardeManger, comptoir, autre }
enum ProductCategory {
  produitsLaitiers,
  viandesPoissons,
  fruitsLegumes,
  epicerieSucree,
  epicerieSalee,
  surgeles,
  boissons,
  boulangerie,
  platsPrepares,
  saucesCondiments,
  oeufs,
  autre,
}

@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    required String id,
    required String userId,
    required String name,
    required ProductCategory category,
    required StorageLocation location,
    required double quantity,
    required String unit,           // "kg", "g", "L", "ml", "unité(s)"
    DateTime? expirationDate,
    @Default(ExpiryType.dlc) ExpiryType expiryType,
    @Default(ProductStatus.fresh) ProductStatus status,
    required DateTime addedDate,
    String? barcode,                // null for manual entries
    String? notes,
    @Default(false) bool isSyncPending,  // true if awaiting Firestore sync
  }) = _ProductEntity;
}
```

#### Data Model — `lib/features/inventory/data/models/product_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// Hive typeId: 1 (reserved for ProductModel — see architecture.md)
@HiveType(typeId: 1)
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    @HiveField(0) required String id,
    @HiveField(1) required String userId,
    @HiveField(2) required String name,
    @HiveField(3) required String category,       // stored as string key
    @HiveField(4) required String location,       // stored as string key
    @HiveField(5) required double quantity,
    @HiveField(6) required String unit,
    @HiveField(7) DateTime? expirationDate,
    @HiveField(8) @Default('dlc') String expiryType,
    @HiveField(9) @Default('fresh') String status,
    @HiveField(10) required DateTime addedDate,
    @HiveField(11) String? barcode,
    @HiveField(12) String? notes,
    @HiveField(13) @Default(false) bool isSyncPending,
    @HiveField(14) @Default(0) int version,       // optimistic locking for sync
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// Convert to Firestore document (camelCase fields, Timestamp for dates)
  static Map<String, dynamic> toFirestore(ProductModel model) => {
    'id': model.id,
    'userId': model.userId,
    'name': model.name,
    'category': model.category,
    'location': model.location,
    'quantity': model.quantity,
    'unit': model.unit,
    'expirationDate': model.expirationDate != null
        ? Timestamp.fromDate(model.expirationDate!)
        : null,
    'expiryType': model.expiryType,
    'status': model.status,
    'addedDate': Timestamp.fromDate(model.addedDate),
    'barcode': model.barcode,
    'notes': model.notes,
    'version': model.version,
    'isSyncPending': false,  // always false when written to Firestore
  };

  /// Parse from Firestore document
  factory ProductModel.fromFirestore(Map<String, dynamic> data) => ProductModel(
    id: data['id'] as String,
    userId: data['userId'] as String,
    name: data['name'] as String,
    category: data['category'] as String? ?? 'autre',
    location: data['location'] as String? ?? 'placard',
    quantity: (data['quantity'] as num?)?.toDouble() ?? 1.0,
    unit: data['unit'] as String? ?? 'unité(s)',
    expirationDate: data['expirationDate'] != null
        ? (data['expirationDate'] as Timestamp).toDate()
        : null,
    expiryType: data['expiryType'] as String? ?? 'dlc',
    status: data['status'] as String? ?? 'fresh',
    addedDate: data['addedDate'] != null
        ? (data['addedDate'] as Timestamp).toDate()
        : DateTime.now(),
    barcode: data['barcode'] as String?,
    notes: data['notes'] as String?,
    version: (data['version'] as int?) ?? 0,
  );
}
```

> ⚠️ **ATTENTION**: After creating `product_model.dart`, run:
> ```bash
> flutter pub run build_runner build --delete-conflicting-outputs
> ```
> This generates `product_model.freezed.dart`, `product_model.g.dart`, and `product_entity.freezed.dart`.

---

### 2. Repository Interface & Implementation

#### Interface — `lib/features/inventory/domain/repositories/inventory_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../entities/product_entity.dart';

abstract class InventoryRepository {
  /// Add a new product (writes to Hive first, then queues Firestore sync)
  Future<Either<AppException, ProductEntity>> addProduct(ProductEntity product);

  /// Get all products for current user (local Hive stream)
  Stream<List<ProductEntity>> watchProducts(String userId);

  /// Get single product by ID
  Future<Either<AppException, ProductEntity?>> getProductById(String id);
}
```

#### Implementation — `lib/features/inventory/data/repositories/inventory_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/data_sync/sync_service.dart';
import '../../../../core/monitoring/analytics_service.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_datasource.dart';
import '../datasources/inventory_remote_datasource.dart';
import '../models/product_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDatasource _local;
  final InventoryRemoteDatasource _remote;
  final SyncService _syncService;
  final AnalyticsService _analytics;
  final _uuid = const Uuid();

  InventoryRepositoryImpl(
    this._local,
    this._remote,
    this._syncService,
    this._analytics,
  );

  @override
  Future<Either<AppException, ProductEntity>> addProduct(ProductEntity product) async {
    try {
      // 1. Generate ID if not provided
      final productWithId = product.copyWith(
        id: product.id.isEmpty ? _uuid.v4() : product.id,
        addedDate: DateTime.now(),
        isSyncPending: true,
      );

      // 2. Compute status based on expiration date
      final withStatus = productWithId.copyWith(
        status: _computeStatus(productWithId.expirationDate),
      );

      // 3. Write to Hive immediately (optimistic UI)
      final model = _toModel(withStatus);
      await _local.saveProduct(model);

      // 4. Queue sync to Firestore
      await _syncService.queueOperation(
        operationType: 'CREATE',
        collection: 'inventory_items',
        documentId: withStatus.id,
        userId: withStatus.userId,
        data: ProductModel.toFirestore(model),
      );

      // 5. Fire analytics event
      _analytics.logEvent(
        name: 'product_added',
        parameters: {
          'method': 'manual',
          'category': withStatus.category.name,
          'has_expiry_date': withStatus.expirationDate != null,
        },
      );

      return Right(withStatus);
    } on HiveException catch (e) {
      return Left(AppException('Erreur stockage local: ${e.message}', 'STORAGE_ERROR', e));
    } catch (e) {
      return Left(AppException('Erreur inattendue: $e', 'UNKNOWN_ERROR', e));
    }
  }

  @override
  Stream<List<ProductEntity>> watchProducts(String userId) {
    return _local.watchProducts(userId).map(
      (models) => models.map(_toEntity).toList()
        ..sort((a, b) {
          // Sort: null dates last, then by expiration date ascending
          if (a.expirationDate == null) return 1;
          if (b.expirationDate == null) return -1;
          return a.expirationDate!.compareTo(b.expirationDate!);
        }),
    );
  }

  @override
  Future<Either<AppException, ProductEntity?>> getProductById(String id) async {
    try {
      final model = await _local.getProductById(id);
      return Right(model != null ? _toEntity(model) : null);
    } catch (e) {
      return Left(AppException('Produit non trouvé', 'NOT_FOUND', e));
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  ProductStatus _computeStatus(DateTime? expirationDate) {
    if (expirationDate == null) return ProductStatus.fresh;
    final now = DateTime.now();
    final daysUntilExpiry = expirationDate.difference(now).inDays;
    if (daysUntilExpiry < 0) return ProductStatus.expired;
    if (daysUntilExpiry <= 2) return ProductStatus.expiringSoon;
    return ProductStatus.fresh;
  }

  ProductModel _toModel(ProductEntity entity) => ProductModel(
    id: entity.id,
    userId: entity.userId,
    name: entity.name,
    category: entity.category.name,
    location: entity.location.name,
    quantity: entity.quantity,
    unit: entity.unit,
    expirationDate: entity.expirationDate,
    expiryType: entity.expiryType.name,
    status: entity.status.name,
    addedDate: entity.addedDate,
    barcode: entity.barcode,
    notes: entity.notes,
    isSyncPending: entity.isSyncPending,
  );

  ProductEntity _toEntity(ProductModel model) => ProductEntity(
    id: model.id,
    userId: model.userId,
    name: model.name,
    category: ProductCategory.values.firstWhere(
      (e) => e.name == model.category,
      orElse: () => ProductCategory.autre,
    ),
    location: StorageLocation.values.firstWhere(
      (e) => e.name == model.location,
      orElse: () => StorageLocation.autre,
    ),
    quantity: model.quantity,
    unit: model.unit,
    expirationDate: model.expirationDate,
    expiryType: ExpiryType.values.firstWhere(
      (e) => e.name == model.expiryType,
      orElse: () => ExpiryType.dlc,
    ),
    status: ProductStatus.values.firstWhere(
      (e) => e.name == model.status,
      orElse: () => ProductStatus.fresh,
    ),
    addedDate: model.addedDate,
    barcode: model.barcode,
    notes: model.notes,
    isSyncPending: model.isSyncPending,
  );
}
```

---

### 3. Datasources

#### Local — `lib/features/inventory/data/datasources/inventory_local_datasource.dart`

```dart
import 'package:hive/hive.dart';
import '../models/product_model.dart';

class InventoryLocalDatasource {
  static const String _boxName = 'inventory_box';

  Box<ProductModel> get _box => Hive.box<ProductModel>(_boxName);

  Future<void> saveProduct(ProductModel product) async {
    await _box.put(product.id, product);
  }

  Stream<List<ProductModel>> watchProducts(String userId) {
    return _box.watch().map((_) => _box.values
        .where((p) => p.userId == userId)
        .toList());
  }

  Future<ProductModel?> getProductById(String id) async {
    return _box.get(id);
  }
}
```

> **IMPORTANT**: `inventory_box` must be opened and registered before use.
> Add in `main.dart` (or Hive initialization in Story 0.3's HiveService):
> ```dart
> Hive.registerAdapter(ProductModelAdapter());   // generated by build_runner
> await Hive.openBox<ProductModel>('inventory_box');
> ```

#### Remote — `lib/features/inventory/data/datasources/inventory_remote_datasource.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class InventoryRemoteDatasource {
  final FirebaseFirestore _firestore;

  InventoryRemoteDatasource(this._firestore);

  Future<void> createProduct(ProductModel product) async {
    await _firestore
        .collection('users')
        .doc(product.userId)
        .collection('inventory_items')
        .doc(product.id)
        .set(ProductModel.toFirestore(product));
  }

  Stream<List<ProductModel>> watchProducts(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('inventory_items')
        .orderBy('expirationDate', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ProductModel.fromFirestore(doc.data()))
            .toList());
  }
}
```

---

### 4. Use Case

#### `lib/features/inventory/domain/usecases/add_product_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/security/input_sanitizer.dart';  // from Story 0.10
import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class AddProductUseCase {
  final InventoryRepository _repository;

  AddProductUseCase(this._repository);

  Future<Either<AppException, ProductEntity>> call(ProductEntity product) async {
    // 1. Validate required fields
    if (product.name.trim().isEmpty) {
      return Left(ValidationException(
        'Le nom du produit est obligatoire',
        {'name': 'required'},
      ));
    }

    if (product.quantity <= 0) {
      return Left(ValidationException(
        'La quantité doit être supérieure à 0',
        {'quantity': 'must_be_positive'},
      ));
    }

    // 2. Sanitize text inputs
    final sanitized = product.copyWith(
      name: InputSanitizer.sanitizeGenericInput(product.name.trim()),
      notes: product.notes != null
          ? InputSanitizer.sanitizeGenericInput(product.notes!)
          : null,
    );

    // 3. Delegate to repository
    return _repository.addProduct(sanitized);
  }
}
```

---

### 5. Riverpod Providers

#### `lib/features/inventory/presentation/providers/inventory_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/inventory_local_datasource.dart';
import '../../data/datasources/inventory_remote_datasource.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/add_product_usecase.dart';

// ── Datasource Providers ─────────────────────────────────────────────────

final inventoryLocalDatasourceProvider = Provider<InventoryLocalDatasource>(
  (_) => InventoryLocalDatasource(),
);

final inventoryRemoteDatasourceProvider = Provider<InventoryRemoteDatasource>(
  (ref) => InventoryRemoteDatasource(FirebaseFirestore.instance),
);

// ── Repository Provider ──────────────────────────────────────────────────

final inventoryRepositoryProvider = Provider<InventoryRepositoryImpl>(
  (ref) => InventoryRepositoryImpl(
    ref.read(inventoryLocalDatasourceProvider),
    ref.read(inventoryRemoteDatasourceProvider),
    ref.read(syncServiceProvider),       // from Story 0.9
    ref.read(analyticsServiceProvider),  // from Story 0.7
  ),
);

// ── UseCase Providers ────────────────────────────────────────────────────

final addProductUseCaseProvider = Provider<AddProductUseCase>(
  (ref) => AddProductUseCase(ref.read(inventoryRepositoryProvider)),
);

// ── State Providers ──────────────────────────────────────────────────────

final inventoryListProvider = StreamProvider<List<ProductEntity>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ref.read(inventoryRepositoryProvider).watchProducts(userId);
});
```

---

### 6. UI — Add Product Screen

#### `lib/features/inventory/presentation/screens/add_product_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/inventory_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  static const routeName = '/inventory/add';

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.autre;
  StorageLocation _selectedLocation = StorageLocation.placard;
  String _selectedUnit = 'unité(s)';
  ExpiryType _selectedExpiryType = ExpiryType.dlc;
  DateTime? _expirationDate;
  bool _isLoading = false;

  static const List<String> _units = ['unité(s)', 'kg', 'g', 'L', 'ml', 'bouteille(s)'];

  // Category → default location mapping (AC5)
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
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
                  hintText: 'Ex: Lait demi-écrémé',
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
                items: ProductCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(_categoryLabel(cat)),
                  );
                }).toList(),
                onChanged: (cat) {
                  if (cat == null) return;
                  setState(() {
                    _selectedCategory = cat;
                    // Auto-assign default location
                    _selectedLocation = _categoryDefaultLocation[cat] ?? StorageLocation.placard;
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
                items: StorageLocation.values.map((loc) {
                  return DropdownMenuItem(
                    value: loc,
                    child: Text(_locationLabel(loc)),
                  );
                }).toList(),
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final qty = double.tryParse(v ?? '');
                        if (qty == null || qty <= 0) {
                          return 'Doit être > 0';
                        }
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
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
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
                              : 'Optionnelle',
                          style: TextStyle(
                            color: _expirationDate != null
                                ? (_isExpired(_expirationDate!) ? Colors.red : null)
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
                      onChanged: (t) => setState(() => _selectedExpiryType = t!),
                    ),
                  ],
                ],
              ),
              // Expired date warning
              if (_expirationDate != null && _isExpired(_expirationDate!))
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    'La date est déjà dépassée — ce produit sera marqué "Expiré"',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // ── Notes (optional) ─────────────────────────────────
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'Ex: Ouvert le 18/02',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // ── Submit Button ────────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ajouter le produit'),
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
      initialDate: DateTime.now().add(const Duration(days: 7)),
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

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);

    final product = ProductEntity(
      id: '',  // generated in repository
      userId: userId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      location: _selectedLocation,
      quantity: double.parse(_quantityController.text),
      unit: _selectedUnit,
      expirationDate: _expirationDate,
      expiryType: _selectedExpiryType,
      addedDate: DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final result = await ref.read(addProductUseCaseProvider).call(product);

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit ajouté avec succès ✓')),
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

### 7. Hive Box Registration

In `lib/core/storage/hive_service.dart` (Story 0.3), add the inventory box initialization:

```dart
// Add to HiveService.initialize():
Hive.registerAdapter(ProductModelAdapter());  // generated by build_runner
await Hive.openBox<ProductModel>('inventory_box');
```

**Hive TypeId Registry** (to avoid collisions):

| TypeId | Model | Box |
|--------|-------|-----|
| 0 | SyncQueueItem | sync_queue_box |
| 1 | ProductModel | inventory_box |
| 2+ | Reserved for future models | — |

---

### 8. Firestore Collection Structure

```
users/{userId}/
└── inventory_items/           ← Scoped per user (Security Rules enforce this)
    └── {productId}            ← UUID v4 generated client-side
        ├── id: string
        ├── userId: string
        ├── name: string
        ├── category: string   ← enum key (e.g., "produitsLaitiers")
        ├── location: string   ← enum key (e.g., "refrigerateur")
        ├── quantity: number
        ├── unit: string
        ├── expirationDate: Timestamp | null
        ├── expiryType: string ("dlc" | "ddm")
        ├── status: string     ("fresh" | "expiringSoon" | "expired" | "consumed")
        ├── addedDate: Timestamp
        ├── barcode: string | null
        ├── notes: string | null
        └── version: number    ← incremented on each update (optimistic locking)
```

**Firestore Indexes** (needed for Story 2.5-2.7 filters):
- Composite index: `category ASC + expirationDate ASC`
- Composite index: `status ASC + expirationDate ASC`
- Composite index: `location ASC + expirationDate ASC`

> Add these in `firestore.indexes.json` (see Story 0.2 for pattern).

---

## 📝 Implementation Tasks

### Phase 1: Domain Layer (Day 1)

- [ ] **T1.1**: Create `ProductEntity`, `ProductCategory`, `StorageLocation`, `ProductStatus`, `ExpiryType` enums in `lib/features/inventory/domain/entities/product_entity.dart`
- [ ] **T1.2**: Create `InventoryRepository` abstract interface
- [ ] **T1.3**: Create `AddProductUseCase` with input validation and InputSanitizer integration
- [ ] **T1.4**: Write unit tests for `AddProductUseCase` — valid inputs, missing name, quantity ≤ 0

### Phase 2: Data Layer (Day 1-2)

- [ ] **T2.1**: Create `ProductModel` (Freezed + HiveType typeId: 1 + JSON serialization + Firestore helpers)
- [ ] **T2.2**: Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] **T2.3**: Create `InventoryLocalDatasource` (Hive CRUD + watchProducts stream)
- [ ] **T2.4**: Register `ProductModelAdapter()` and open `inventory_box` in `HiveService`
- [ ] **T2.5**: Create `InventoryRemoteDatasource` (Firestore CRUD)
- [ ] **T2.6**: Implement `InventoryRepositoryImpl` (Hive-first write + SyncService queue)
- [ ] **T2.7**: Write unit tests for `InventoryRepositoryImpl` (mocked datasources + SyncService)
- [ ] **T2.8**: Write unit tests for `ProductModel` — JSON serialization roundtrip, Firestore toFirestore/fromFirestore

### Phase 3: Riverpod Providers (Day 2)

- [ ] **T3.1**: Create all inventory providers (`inventoryLocalDatasourceProvider`, `inventoryRemoteDatasourceProvider`, `inventoryRepositoryProvider`, `addProductUseCaseProvider`, `inventoryListProvider`)
- [ ] **T3.2**: Write unit tests for providers using `ProviderContainer`

### Phase 4: UI (Day 2-3)

- [ ] **T4.1**: Create `AddProductScreen` with all form fields (name, category, location, quantity, unit, expiration date, expiry type, notes)
- [ ] **T4.2**: Implement category-to-location auto-assignment (AC5)
- [ ] **T4.3**: Implement expiration date picker with DLC/DDM toggle
- [ ] **T4.4**: Implement expired date warning banner (AC3)
- [ ] **T4.5**: Implement loading state + success Snackbar + error Snackbar
- [ ] **T4.6**: Add route to GoRouter: `/inventory/add`
- [ ] **T4.7**: Write widget tests for `AddProductScreen`

### Phase 5: Firestore Indexes (Day 3)

- [ ] **T5.1**: Add composite indexes to `firestore.indexes.json`
- [ ] **T5.2**: Deploy Firestore indexes: `firebase deploy --only firestore:indexes`

### Phase 6: Testing & Coverage (Day 3)

- [ ] **T6.1**: Full test coverage ≥ 75% for all new files
- [ ] **T6.2**: Test AC1-AC8 manually on device/emulator
- [ ] **T6.3**: Test offline scenario: add product without network → verify Hive save + sync queue
- [ ] **T6.4**: Run `flutter analyze` → 0 errors

---

## 🧪 Testing Strategy

### Unit Tests

**`test/features/inventory/domain/usecases/add_product_usecase_test.dart`**:
```dart
group('AddProductUseCase', () {
  test('should save product with valid inputs', ...);
  test('should return ValidationException when name is empty', ...);
  test('should return ValidationException when quantity is 0', ...);
  test('should sanitize product name before saving', ...);
  test('should auto-assign status based on expiration date', ...);
});
```

**`test/features/inventory/data/models/product_model_test.dart`**:
```dart
group('ProductModel', () {
  test('fromJson / toJson roundtrip preserves all fields', ...);
  test('fromFirestore parses Timestamp correctly', ...);
  test('toFirestore converts DateTime to Timestamp', ...);
  test('defaults apply when fields are null', ...);
});
```

**`test/features/inventory/data/repositories/inventory_repository_impl_test.dart`**:
```dart
group('InventoryRepositoryImpl', () {
  test('addProduct writes to Hive first (optimistic)', ...);
  test('addProduct queues SyncService operation', ...);
  test('addProduct fires analytics product_added event', ...);
  test('watchProducts returns sorted list by expirationDate', ...);
  test('watchProducts puts null-date products last', ...);
});
```

### Widget Tests

**`test/features/inventory/presentation/screens/add_product_screen_test.dart`**:
```dart
group('AddProductScreen', () {
  testWidgets('renders all form fields', ...);
  testWidgets('shows error when name is empty on submit', ...);
  testWidgets('auto-assigns Réfrigérateur when category is Produits laitiers', ...);
  testWidgets('shows expired warning when past date is selected', ...);
  testWidgets('submit button disabled during loading', ...);
  testWidgets('shows success Snackbar after successful add', ...);
});
```

---

## ⚠️ Anti-Patterns à Éviter

### ❌ Muter le state Riverpod directement

```dart
// ❌ INTERDIT
class InventoryNotifier extends StateNotifier<List<ProductEntity>> {
  void add(ProductEntity p) {
    state.add(p); // mutation directe
  }
}

// ✅ CORRECT
class InventoryNotifier extends StateNotifier<List<ProductEntity>> {
  void add(ProductEntity p) {
    state = [...state, p]; // nouvelle liste immuable
  }
}
```

### ❌ Écrire sur Firestore avant Hive

```dart
// ❌ INTERDIT — Firestore en premier casse le offline-first
await _remote.createProduct(model);
await _local.saveProduct(model);

// ✅ CORRECT — Hive d'abord, sync ensuite
await _local.saveProduct(model);
await _syncService.queueOperation(...);
```

### ❌ Stocker enum en int dans Hive

```dart
// ❌ FRAGILE — L'ordre des enums peut changer
@HiveField(3) required int categoryIndex;

// ✅ ROBUSTE — Stocker le nom en string
@HiveField(3) required String category;  // "produitsLaitiers"
```

### ❌ Ne pas enregistrer le TypeAdapter avant d'ouvrir la box

```dart
// ❌ Lance HiveError: "Cannot write, unknown type"
await Hive.openBox<ProductModel>('inventory_box');
Hive.registerAdapter(ProductModelAdapter()); // trop tard

// ✅ CORRECT — enregistrer avant d'ouvrir
Hive.registerAdapter(ProductModelAdapter());
await Hive.openBox<ProductModel>('inventory_box');
```

---

## 🔗 Points d'Intégration

### Story 0.3 (Hive)
- Utiliser `HiveService` existant pour enregistrer l'adapter et ouvrir `inventory_box`
- Ne pas dupliquer l'initialisation Hive

### Story 0.9 (SyncService)
- `_syncService.queueOperation(operationType: 'CREATE', ...)` dans le repository
- Le SyncService gère la logique de retry et de connexion
- Ne pas appeler Firestore directement depuis le repository — passer par le sync queue

### Story 0.10 (InputSanitizer)
- `InputSanitizer.sanitizeGenericInput(name)` dans le use case
- Validation regex pour barcode EAN-13 si barcode fourni (non requis dans 2.1)

### Story 0.7 (AnalyticsService)
- Event `product_added` avec paramètres: `method`, `category`, `has_expiry_date`
- Déjà implémenté dans `AnalyticsService` — appeler `_analytics.logEvent(...)`

### Story 0.4 (Riverpod)
- Utiliser `authStateProvider` existant pour obtenir `userId`
- `ref.watch(authStateProvider).value?.uid`

### Epic 2 (Stories suivantes)
- **Story 2.2** (Edit): `UpdateProductUseCase` réutilisera `InventoryRepository` et `ProductModel`
- **Story 2.3** (Delete): `deleteProduct(String id)` à ajouter à `InventoryRepository`
- **Story 2.5-2.7** (Filters): Les indexes Firestore créés ici sont prérequis
- **Story 2.10** (Status lifecycle): `_computeStatus()` du repository sera extrait en service partagé
- **Story 2.12** (Offline): Architecture déjà prête (Hive-first + SyncService)

---

## 📚 Dev Notes

### Décisions de Design

1. **Pourquoi stocker l'enum comme string dans Hive ?**
   Stocker l'index entier est fragile : si l'ordre des valeurs enum change, toutes les données locales sont corrompues. Le string `"produitsLaitiers"` est stable.

2. **Pourquoi UUID v4 côté client plutôt qu'auto-ID Firestore ?**
   L'ID est créé hors ligne dans Hive avant la sync. Utiliser un UUID permet d'avoir un ID stable dans les deux stores (Hive + Firestore) sans round-trip réseau.

3. **Pourquoi Hive d'abord et non Firestore ?**
   Offline-first décision de l'architecture (Story 0.9). L'UI réagit instantanément (<100ms), même sans réseau.

4. **Pourquoi DLC vs DDM sur le formulaire ?**
   - DLC = Date Limite Consommation (alerte 2 jours avant, critique)
   - DDM = Date Durabilité Minimale (alerte 5 jours avant, informatif)
   Ce choix affecte directement Epic 3 (notifications).

### Pièges Communs

1. **Oublier `flutter pub run build_runner build`** après modification des modèles Freezed/Hive
2. **Oublier d'ajouter la route `/inventory/add` dans GoRouter** (Story 0.5)
3. **TypeId Hive dupliqué** — vérifier le registre TypeId ci-dessus avant de créer de nouveaux adapters
4. **`isSyncPending: false` dans toFirestore()** — ne jamais écrire `true` dans Firestore, c'est un flag local uniquement

---

## ✅ Definition of Done

### Fonctionnel
- [ ] Formulaire d'ajout avec nom, catégorie, emplacement, quantité, unité, date d'expiration (DLC/DDM), notes
- [ ] Auto-assignation catégorie par défaut: `autre`
- [ ] Auto-assignation emplacement basé sur catégorie (AC5)
- [ ] Produit visible immédiatement dans l'inventaire (Hive-first)
- [ ] Snackbar succès/erreur après soumission
- [ ] Event analytics `product_added` déclenché

### Non-Fonctionnel
- [ ] Écriture Hive < 50ms
- [ ] UI réactive même sans réseau
- [ ] Aucune mutation directe du state Riverpod
- [ ] 0 erreurs `flutter analyze`

### Qualité Code
- [ ] Couverture tests ≥ 75% sur tous les nouveaux fichiers
- [ ] Tests unitaires pour UseCase + Repository + Model
- [ ] Tests widget pour AddProductScreen
- [ ] Conforme Clean Architecture (domain ne dépend pas de data)
- [ ] Freezed models régénérés avec `build_runner`

### Intégration
- [ ] `inventory_box` enregistré et ouvert dans HiveService
- [ ] Route `/inventory/add` ajoutée dans GoRouter
- [ ] SyncService reçoit bien les opérations CREATE
- [ ] Indexes Firestore déployés

---

## 📎 Références

### Dépendances pubspec.yaml (déjà présentes depuis Epic 0/1)

```yaml
dependencies:
  cloud_firestore: ^5.6.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_riverpod: ^2.6.1
  freezed_annotation: ^2.4.4
  dartz: ^0.10.1
  uuid: ^4.5.1
  intl: ^0.19.0

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  hive_generator: ^2.0.1
  mocktail: ^1.0.4
```

### Sources Architecture
- [Source: _bmad-output/planning-artifacts/architecture.md#Patterns d'Implémentation]
- [Source: _bmad-output/planning-artifacts/architecture.md#Modélisation Données — Product Entity]
- [Source: _bmad-output/planning-artifacts/architecture.md#Firestore Real-Time Listeners]
- [Source: _bmad-output/planning-artifacts/epics.md#Epic 2 — Stories 2.1 à 2.12]

---

## 🤖 Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

*(à remplir par le Dev Agent lors de l'implémentation)*

### Completion Notes List

*(à remplir par le Dev Agent lors de l'implémentation)*

### File List

*(à remplir par le Dev Agent — liste des fichiers créés/modifiés)*

---

**Story Created**: 2026-02-20
**Last Updated**: 2026-02-20
**Ready for Dev**: ✅ Oui
