# Story 5.2: Scan Receipt via OCR to Add Multiple Products

Status: ready-for-dev

## Story

As a Sophie (famille),
I want to scan my grocery receipt and have all products added automatically,
so that I can inventory 100+ items in seconds instead of typing each one.

## Acceptance Criteria

1. **Given** I am on the "Add product" screen
   **When** I tap "Scan receipt" and take a photo of my grocery receipt
   **Then** the OCR engine processes the image in less than 2 seconds
   **And** products are extracted automatically with names and quantities

2. **Given** the OCR processing completes
   **Then** extracted products are displayed in a review list for confirmation
   **And** each product shows name, quantity, and confidence score
   **And** I can edit or remove incorrectly detected products

3. **Given** I confirm the final list
   **Then** all products are added to my inventory in batch
   **And** the "moment magique" wow effect is shown (success animation)

4. **Given** I am on the review screen
   **When** I tap "Ajouter un produit manquant"
   **Then** I can manually add a product not detected by OCR

## Tasks / Subtasks

- [ ] **T1**: Ajouter `image_picker: ^1.1.0` dans pubspec.yaml (AC: 1)
- [ ] **T2**: Créer `ReceiptScanScreen` avec sélection d'image (AC: 1)
  - [ ] Bouton "Prendre une photo" → `ImagePicker().pickImage(source: ImageSource.camera)`
  - [ ] Bouton "Choisir depuis la galerie" → `ImageSource.gallery`
  - [ ] Afficher indicateur de chargement pendant traitement OCR
- [ ] **T3**: Créer `OcrService.processReceipt(File image)` (AC: 1)
  - [ ] Logique dual-engine (Story 5.3) — appel transparent pour cette story
  - [ ] Retourne `List<OcrProduct>` avec confidence scores
- [ ] **T4**: Créer `OcrReviewScreen` — liste de révision (AC: 2, 3, 4)
  - [ ] `ListView` avec `OcrProductTile` pour chaque produit extrait
  - [ ] Swipe-to-delete sur chaque item
  - [ ] Tap → `EditOcrProductDialog` pour modifier nom/quantité/catégorie
  - [ ] FAB "Ajouter un produit" → `AddProductManuallyScreen`
  - [ ] Bouton "Confirmer tout" → `inventoryNotifier.addProductsBatch(products)`
- [ ] **T5**: Créer `inventoryNotifier.addProductsBatch()` (AC: 3)
  - [ ] Itère sur `List<ProductEntity>` et appelle `addProduct()` pour chacun
  - [ ] Retourne count de produits ajoutés
- [ ] **T6**: Animation "moment magique" après confirmation (AC: 3)
  - [ ] `ConfettiWidget` ou `Lottie` animation — 🎉 X produits ajoutés !
- [ ] **T7**: Tests widget `OcrReviewScreen` (AC: 2, 4)
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Packages à ajouter

```yaml
dependencies:
  image_picker: ^1.1.0
  # lottie: ^3.0.0  # optionnel pour animation wow effect
```

### OcrProduct entity

```dart
// lib/features/ocr_scan/domain/entities/ocr_product.dart

@freezed
class OcrProduct with _$OcrProduct {
  const factory OcrProduct({
    required String id,
    required String rawText,          // Texte brut extrait du ticket
    required String normalizedName,   // Nom nettoyé
    required double confidence,       // 0.0 – 1.0
    @Default(1) int quantity,
    ProductCategory? category,
    String? unitPrice,
  }) = _OcrProduct;
}
```

### ReceiptScanScreen

```dart
// lib/features/ocr_scan/presentation/screens/receipt_scan_screen.dart

class ReceiptScanScreen extends ConsumerWidget {
  const ReceiptScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(ocrLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un ticket de caisse')),
      body: Center(
        child: isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyse en cours...', style: TextStyle(fontSize: 16)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 80, color: Colors.green),
                  const SizedBox(height: 24),
                  const Text(
                    'Scannez votre ticket de caisse',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tous vos produits seront ajoutés automatiquement',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(context, ref, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Prendre une photo'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(context, ref, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choisir depuis la galerie'),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 90,    // Bonne qualité pour OCR
      maxWidth: 2000,      // Limiter taille pour API
    );

    if (image == null || !context.mounted) return;

    final notifier = ref.read(ocrNotifierProvider.notifier);
    final products = await notifier.processReceipt(File(image.path));

    if (context.mounted) {
      context.push('/inventory/ocr-review', extra: products);
    }
  }
}
```

### OcrReviewScreen

```dart
// lib/features/ocr_scan/presentation/screens/ocr_review_screen.dart

class OcrReviewScreen extends ConsumerStatefulWidget {
  final List<OcrProduct> ocrProducts;

  const OcrReviewScreen({super.key, required this.ocrProducts});

  @override
  ConsumerState<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends ConsumerState<OcrReviewScreen> {
  late List<OcrProduct> _products;

  @override
  void initState() {
    super.initState();
    _products = List.from(widget.ocrProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_products.length} produits détectés'),
        actions: [
          TextButton(
            onPressed: _confirmAll,
            child: const Text('Confirmer tout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return OcrProductTile(
            product: _products[index],
            onDelete: () => setState(() => _products.removeAt(index)),
            onEdit: (updated) => setState(() => _products[index] = updated),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/add-manually'),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter manuellement'),
      ),
    );
  }

  Future<void> _confirmAll() async {
    final products = _products.map((o) => o.toProductEntity()).toList();
    await ref.read(inventoryNotifierProvider.notifier).addProductsBatch(products);

    if (mounted) {
      // Animation wow effect
      _showSuccessAnimation(products.length);
    }
  }

  void _showSuccessAnimation(int count) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              '🎉 $count produits ajoutés !',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/inventory');
            },
            child: const Text('Voir l\'inventaire'),
          ),
        ],
      ),
    );
  }
}
```

### GoRouter routes

```dart
GoRoute(
  path: '/inventory/scan-receipt',
  builder: (_, __) => const ReceiptScanScreen(),
),
GoRoute(
  path: '/inventory/ocr-review',
  builder: (context, state) {
    final products = state.extra as List<OcrProduct>;
    return OcrReviewScreen(ocrProducts: products);
  },
),
```

### Project Structure Notes

- `ReceiptScanScreen` → appelle `OcrService` (Story 5.3) pour le dual-engine
- `OcrProduct.toProductEntity()` convertit vers `ProductEntity` via `ProductCategorizationService`
- Lot d'ajout: `addProductsBatch()` doit être atomique (Hive transaction)
- Image compression avant envoi API: `imageQuality: 90`, `maxWidth: 2000`

### References

- [Source: epics.md#Story-5.2]
- OcrService dual-engine [Source: Story 5.3]
- OcrProduct entity (partagée avec Stories 5.3, 5.4)
- inventoryNotifier [Source: Story 2.1]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
