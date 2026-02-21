# Story 5.1: Scan Product Barcode (EAN-13) to Add to Inventory

Status: ready-for-dev

## Story

As a Lucas (étudiant),
I want to quickly scan product barcodes to add them to my inventory,
so that I can avoid tedious manual entry and save time.

## Acceptance Criteria

1. **Given** I am on the "Add product" screen
   **When** I tap "Scan barcode" and point my camera at an EAN-13 barcode
   **Then** the barcode is recognized in less than 500ms
   **And** product information is retrieved from OpenFoodFacts API
   **And** the product is automatically added with name, category, and nutrition data
   **And** I can manually adjust quantity and expiration date before confirming

2. **Given** the barcode is not found in OpenFoodFacts
   **Then** I am prompted to add the product manually
   **And** the barcode value is pre-filled in the form

3. **Given** the barcode was previously scanned and cached
   **When** I scan it again
   **Then** product data is loaded from local cache instantly (no API call)

4. **Given** I confirm the product
   **Then** it is added to inventory via `InventoryRepository.addProduct()`
   **And** the sync queue is updated for Firestore sync

## Tasks / Subtasks

- [ ] **T1**: Ajouter `mobile_scanner: ^5.0.0` dans pubspec.yaml (AC: 1)
- [ ] **T2**: Créer `BarcodeScanScreen` avec `MobileScanner` widget (AC: 1)
  - [ ] Frame overlay visuel (voir Story 5.8 pour guidance avancée)
  - [ ] `onDetect` callback → déclenche `OpenFoodFactsRepository.fetchByBarcode(barcode)`
  - [ ] Vibration + son confirmation au scan réussi (`HapticFeedback.heavyImpact()`)
- [ ] **T3**: Créer `OpenFoodFactsRepository` (AC: 1, 2, 3)
  - [ ] `fetchByBarcode(String barcode)` → `Either<Failure, ProductEntity?>`
  - [ ] HTTP GET `https://world.openfoodfacts.org/api/v0/product/{barcode}.json`
  - [ ] Parse `product.product_name_fr`, `product.categories_tags`, `product.nutriments`
  - [ ] Vérifier cache Hive avant API call (Story 5.9 implémentera le cache complet)
- [ ] **T4**: Créer `ProductFromBarcodeUseCase` (AC: 1, 2)
  - [ ] Appelle `OpenFoodFactsRepository.fetchByBarcode()`
  - [ ] Mappe vers `ProductEntity` avec catégorie via `ProductCategorizationService` (Story 2.8)
  - [ ] Retourne `null` si produit inconnu
- [ ] **T5**: Créer `AddProductFromBarcodeScreen` — formulaire de confirmation (AC: 1, 2)
  - [ ] Pré-remplit nom, catégorie, nutrition depuis OpenFoodFacts
  - [ ] Champs editables: quantité, date expiration, type (DLC/DDM)
  - [ ] Bouton "Ajouter" → `inventoryNotifier.addProduct(product)`
- [ ] **T6**: Ajouter route `/inventory/scan-barcode` dans GoRouter (AC: 1)
- [ ] **T7**: Permissions camera dans AndroidManifest.xml et Info.plist (AC: 1)
- [ ] **T8**: Tests unitaires `OpenFoodFactsRepository` avec mock HTTP (AC: 1, 2)
- [ ] **T9**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Packages à ajouter

```yaml
# pubspec.yaml
dependencies:
  mobile_scanner: ^5.0.0
  # image_picker sera utilisé dans Story 5.2 pour les tickets
```

### OpenFoodFactsRepository

```dart
// lib/features/ocr_scan/data/repositories/open_food_facts_repository.dart

class OpenFoodFactsRepositoryImpl implements OpenFoodFactsRepository {
  final Dio _dio;
  final ProductCacheService _cache;  // Story 5.9

  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';

  @override
  Future<Either<Failure, ProductEntity?>> fetchByBarcode(String barcode) async {
    // 1. Vérifier cache local
    final cached = _cache.get(barcode);
    if (cached != null) return Right(cached);

    try {
      final response = await _dio.get('$_baseUrl/$barcode.json');
      if (response.data['status'] == 0) return const Right(null); // produit inconnu

      final product = response.data['product'] as Map<String, dynamic>;
      final entity = _mapToEntity(barcode, product);

      // Mettre en cache pour les scans futurs
      await _cache.put(barcode, entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'OpenFoodFacts unreachable'));
    }
  }

  ProductEntity _mapToEntity(String barcode, Map<String, dynamic> product) {
    final nameFr = product['product_name_fr'] as String?;
    final nameEn = product['product_name'] as String?;
    final name = (nameFr?.isNotEmpty == true ? nameFr : nameEn) ?? 'Produit inconnu';

    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    final nutrition = NutritionData(
      caloriesKcal: (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
      proteinG: (nutriments['proteins_100g'] as num?)?.toDouble(),
      carbsG: (nutriments['carbohydrates_100g'] as num?)?.toDouble(),
      fatsG: (nutriments['fat_100g'] as num?)?.toDouble(),
    );

    return ProductEntity(
      id: const Uuid().v4(),
      barcode: barcode,
      name: name,
      category: ProductCategory.autre,  // Será catégorisé via ProductCategorizationService
      nutritionData: nutrition,
      addedDate: DateTime.now(),
      quantity: 1,
    );
  }
}
```

### BarcodeScanScreen

```dart
// lib/features/ocr_scan/presentation/screens/barcode_scan_screen.dart

class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un code-barres')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onBarcodeDetected,
          ),
          // Cadre de guidage (voir Story 5.8 pour guidage avancé)
          Center(
            child: Container(
              width: 250,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0, right: 0,
            child: Text(
              'Pointez la caméra sur le code-barres',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    final result = await ref.read(productFromBarcodeUseCaseProvider).execute(barcode);
    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${failure.message}')),
        );
        setState(() => _isProcessing = false);
      },
      (product) {
        context.push('/inventory/add-from-barcode', extra: {
          'product': product,
          'barcode': barcode,
        });
      },
    );
  }
}
```

### NutritionData entity

```dart
// lib/features/ocr_scan/domain/entities/nutrition_data.dart
// (sera partagée par Epic 7 — nutrition_tracking)

@freezed
class NutritionData with _$NutritionData {
  const factory NutritionData({
    double? caloriesKcal,
    double? proteinG,
    double? carbsG,
    double? fatsG,
  }) = _NutritionData;

  factory NutritionData.fromJson(Map<String, dynamic> json) =>
      _$NutritionDataFromJson(json);
}
```

### AndroidManifest.xml additions

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### Info.plist additions

```xml
<key>NSCameraUsageDescription</key>
<string>FrigoFuté a besoin d'accéder à votre caméra pour scanner les codes-barres et tickets de caisse.</string>
```

### GoRouter route

```dart
GoRoute(
  path: '/inventory/scan-barcode',
  builder: (_, __) => const BarcodeScanScreen(),
),
GoRoute(
  path: '/inventory/add-from-barcode',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>;
    return AddProductFromBarcodeScreen(
      product: extra['product'] as ProductEntity?,
      barcode: extra['barcode'] as String,
    );
  },
),
```

### Project Structure Notes

- `lib/features/ocr_scan/` — module principal Epic 5
- `lib/features/ocr_scan/domain/entities/` — `NutritionData`, `OcrProduct`, `ProductCache`
- `lib/features/ocr_scan/domain/repositories/` — `OpenFoodFactsRepository` (interface)
- `lib/features/ocr_scan/data/repositories/` — `OpenFoodFactsRepositoryImpl`
- `lib/features/ocr_scan/presentation/screens/` — `BarcodeScanScreen`, `AddProductFromBarcodeScreen`
- OpenFoodFacts API v0: status 0 = produit inconnu, status 1 = trouvé
- `mobile_scanner` requiert minimum Android API 21, iOS 13.0

### References

- [Source: epics.md#Story-5.1]
- OpenFoodFacts API [Source: architecture.md]
- ProductCategorizationService [Source: 2-8]
- ProductCacheService (cache) [Source: Story 5.9]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
