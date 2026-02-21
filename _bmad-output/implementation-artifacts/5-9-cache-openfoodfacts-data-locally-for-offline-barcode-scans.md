# Story 5.9: Cache OpenFoodFacts Data Locally for Offline Barcode Scans

Status: ready-for-dev

## Story

As a Lucas (étudiant),
I want to scan products even when I'm offline,
so that I can add items to my inventory at the store without needing internet.

## Acceptance Criteria

1. **Given** I have previously scanned products that are cached locally
   **When** I scan a barcode while offline
   **Then** if the product is in the local cache, it is added immediately using cached data

2. **Given** I scan a barcode offline and the product is NOT in cache
   **Then** I see: "Produit non trouvé. Ajoutez-le manuellement ou réessayez en ligne."

3. **Given** the local cache contains more than 1,000 products
   **When** a new product is added to cache
   **Then** the least recently used (LRU) product is evicted

4. **Given** a cached product was last updated more than 7 days ago
   **When** I scan it online
   **Then** fresh data is fetched from OpenFoodFacts and the cache is updated

5. **Given** I reconnect after offline scanning
   **When** the app comes online
   **Then** any products added offline without cache data are enriched automatically

## Tasks / Subtasks

- [ ] **T1**: Créer `ProductCacheService` (AC: 1, 2, 3, 4)
  - [ ] Hive box `products_cache_box` avec `ProductCacheEntry` adapter
  - [ ] `get(String barcode)` → vérifie TTL avant retour
  - [ ] `put(String barcode, ProductEntity product)` → LRU eviction si >1000
  - [ ] `isExpired(ProductCacheEntry entry)` → `DateTime.now().isAfter(entry.cachedAt.add(7.days))`
- [ ] **T2**: Créer `ProductCacheEntry` HiveObject (AC: 1, 3, 4)
  - [ ] `barcode`, `product` (JSON), `cachedAt` timestamp, `lastAccessedAt` (pour LRU)
- [ ] **T3**: Intégrer `ProductCacheService` dans `OpenFoodFactsRepository` (AC: 1, 4)
  - [ ] Check cache avant API call
  - [ ] Mise à jour cache après succès API
  - [ ] Bypass cache si TTL expiré → re-fetch
- [ ] **T4**: Créer `ProductCacheRefreshService` — enrichissement auto en background (AC: 5)
  - [ ] Écoute `connectivityProvider` → si online + produits sans nutritionData → fetch
- [ ] **T5**: Exposer `cacheStatsProvider` (count, oldest entry) pour debugging (optionnel)
- [ ] **T6**: Tests unitaires `ProductCacheService` — LRU eviction, TTL expiry (AC: 1, 3, 4)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### ProductCacheEntry HiveObject

```dart
// lib/features/ocr_scan/data/models/product_cache_entry.dart

@HiveType(typeId: 10)  // Vérifier que typeId est unique dans le projet
class ProductCacheEntryHive extends HiveObject {
  @HiveField(0)
  String barcode;

  @HiveField(1)
  String productJson;  // JSON serialized ProductEntity

  @HiveField(2)
  DateTime cachedAt;

  @HiveField(3)
  DateTime lastAccessedAt;

  ProductCacheEntryHive({
    required this.barcode,
    required this.productJson,
    required this.cachedAt,
    required this.lastAccessedAt,
  });
}
```

### ProductCacheService

```dart
// lib/features/ocr_scan/data/services/product_cache_service.dart

class ProductCacheService {
  static const int _maxEntries = 1000;
  static const Duration _ttl = Duration(days: 7);

  final Box<ProductCacheEntryHive> _box;

  ProductCacheService(this._box);

  /// Retourne le produit si en cache ET non expiré, null sinon
  ProductEntity? get(String barcode) {
    final entry = _box.get(barcode);
    if (entry == null) return null;
    if (_isExpired(entry)) {
      _box.delete(barcode);  // Supprimer l'entrée expirée
      return null;
    }
    // Mettre à jour lastAccessedAt pour LRU
    entry.lastAccessedAt = DateTime.now();
    entry.save();
    return _deserialize(entry.productJson);
  }

  Future<void> put(String barcode, ProductEntity product) async {
    // Eviction LRU si dépassement capacité
    if (_box.length >= _maxEntries) {
      await _evictLRU();
    }

    final entry = ProductCacheEntryHive(
      barcode: barcode,
      productJson: jsonEncode(product.toJson()),
      cachedAt: DateTime.now(),
      lastAccessedAt: DateTime.now(),
    );

    await _box.put(barcode, entry);
  }

  bool _isExpired(ProductCacheEntryHive entry) {
    return DateTime.now().isAfter(entry.cachedAt.add(_ttl));
  }

  Future<void> _evictLRU() async {
    // Trouver l'entrée la moins récemment utilisée
    ProductCacheEntryHive? lruEntry;
    for (final entry in _box.values) {
      if (lruEntry == null || entry.lastAccessedAt.isBefore(lruEntry.lastAccessedAt)) {
        lruEntry = entry;
      }
    }
    if (lruEntry != null) {
      await lruEntry.delete();
    }
  }

  ProductEntity? _deserialize(String json) {
    try {
      return ProductEntity.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  int get count => _box.length;

  /// Supprimer toutes les entrées expirées
  Future<void> cleanExpired() async {
    final expiredKeys = _box.values
        .where(_isExpired)
        .map((e) => e.key)
        .toList();
    await _box.deleteAll(expiredKeys);
  }
}
```

### Intégration dans OpenFoodFactsRepositoryImpl

```dart
@override
Future<Either<Failure, ProductEntity?>> fetchByBarcode(String barcode) async {
  // 1. Vérifier cache (TTL inclus)
  final cached = _cache.get(barcode);
  if (cached != null) return Right(cached);

  // 2. Vérifier connectivité
  if (!await _connectivity.isOnline()) {
    // Cache miss + offline → message informatif
    return const Left(NetworkFailure('Produit non trouvé hors ligne'));
  }

  // 3. Appel API
  try {
    final response = await _dio.get('$_baseUrl/$barcode.json');
    if (response.data['status'] == 0) return const Right(null);

    final product = _mapToEntity(barcode, response.data['product']);

    // 4. Mettre en cache pour usage futur
    await _cache.put(barcode, product);
    return Right(product);

  } on DioException catch (e) {
    return Left(NetworkFailure(e.message ?? 'Erreur réseau'));
  }
}
```

### Provider Riverpod

```dart
// lib/features/ocr_scan/presentation/providers/ocr_providers.dart

final productCacheBoxProvider = Provider<Box<ProductCacheEntryHive>>((ref) {
  return Hive.box<ProductCacheEntryHive>('products_cache_box');
});

final productCacheServiceProvider = Provider<ProductCacheService>((ref) {
  return ProductCacheService(ref.watch(productCacheBoxProvider));
});

final openFoodFactsRepositoryProvider = Provider<OpenFoodFactsRepository>((ref) {
  return OpenFoodFactsRepositoryImpl(
    dio: ref.watch(dioProvider),
    cache: ref.watch(productCacheServiceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});
```

### Hive Box Registration dans main.dart

```dart
// Dans initHive() ou setupDependencies():
Hive.registerAdapter(ProductCacheEntryHiveAdapter());
await Hive.openBox<ProductCacheEntryHive>('products_cache_box');
```

### ProductCacheRefreshService (AC: 5)

```dart
// lib/features/ocr_scan/data/services/product_cache_refresh_service.dart

class ProductCacheRefreshService {
  final ConnectivityService _connectivity;
  final OpenFoodFactsRepository _repository;
  final InventoryRepository _inventory;

  Future<void> enrichOfflineProducts() async {
    if (!await _connectivity.isOnline()) return;

    // Chercher produits sans nutrition data (ajoutés offline sans cache)
    final allProducts = await _inventory.getAllProducts();
    final toEnrich = allProducts.where((p) =>
        p.barcode != null && (p.nutritionData?.isEmpty ?? true)
    ).toList();

    for (final product in toEnrich) {
      final result = await _repository.fetchByBarcode(product.barcode!);
      result.fold(
        (_) => null,  // Ignorer les erreurs d'enrichissement
        (enriched) async {
          if (enriched?.nutritionData != null) {
            await _inventory.updateProduct(
              product.copyWith(nutritionData: enriched!.nutritionData)
            );
          }
        },
      );
    }
  }
}
```

### Project Structure Notes

- `products_cache_box` est une `Box<ProductCacheEntryHive>` (typée, pas `Box<dynamic>`)
- LRU implémenté en O(n) sur le box Hive — acceptable pour max 1000 entrées
- `cleanExpired()` peut être appelé au démarrage app pour nettoyer le cache
- TypeId Hive: vérifier disponibilité avec les autres adapters du projet

### References

- [Source: epics.md#Story-5.9]
- OpenFoodFactsRepository [Source: Story 5.1]
- ConnectivityService [Source: Story 0.9]
- architecture.md — cache strategies: OpenFoodFacts TTL 7j LRU 1000 produits

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
