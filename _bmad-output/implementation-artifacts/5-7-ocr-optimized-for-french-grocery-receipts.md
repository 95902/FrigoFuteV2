# Story 5.7: OCR Optimized for French Grocery Receipts

Status: ready-for-dev

## Story

As a Sophie (famille),
I want the OCR to accurately recognize French receipt formats from major retailers,
so that my scans work reliably at Carrefour, Leclerc, Auchan, and other stores.

## Acceptance Criteria

1. **Given** I scan receipts from Carrefour, Leclerc, Auchan, Intermarché, Casino, or Lidl
   **Then** the OCR extracts product names and quantities with at least 85% accuracy
   **And** common French product names are recognized correctly (yaourt, baguette, lait…)

2. **Given** OCR processes the raw text
   **Then** non-product lines (totals, payment info, headers, addresses) are filtered out
   **And** product lines are identified by their structure: name + price pattern

3. **Given** a receipt line matches a product
   **Then** quantity is extracted when present (e.g., "2x Yaourt" → quantity=2)
   **And** unit price is extracted from the right column

4. **Given** the OCR text contains abbreviations or truncations common in French receipts
   **Then** common abbreviations are expanded (e.g., "YAO" → "Yaourt", "LAI" → "Lait")

## Tasks / Subtasks

- [ ] **T1**: Créer `FrenchReceiptParser` (AC: 1, 2, 3, 4)
  - [ ] Regex pour détecter lignes produits: `NAME_PATTERN PRICE_PATTERN`
  - [ ] Filtrage lignes non-produits: "TOTAL", "CARTE", "TVA", "MERCI", adresses, dates
  - [ ] Extraction quantité: `(\d+)[xX]\s+` en préfixe de ligne
  - [ ] Dictionnaire abréviations françaises
- [ ] **T2**: Créer configs retailer-specific (AC: 1)
  - [ ] `RetailerConfig` avec patterns spécifiques Carrefour/Leclerc/etc.
  - [ ] Détection enseigne depuis header du ticket
- [ ] **T3**: Créer `FrenchFoodNormalizer` (AC: 4)
  - [ ] Normalisation noms: majuscules → title case
  - [ ] Expansion abréviations (dictionnaire 200+ termes)
  - [ ] Suppression codes internes (ex: "REF 12345")
- [ ] **T4**: Tests unitaires `FrenchReceiptParser` avec vrais extraits de tickets (AC: 1, 2, 3)
  - [ ] Fixtures de tickets Carrefour, Leclerc, Lidl
- [ ] **T5**: Tests unitaires `FrenchFoodNormalizer` (AC: 4)
- [ ] **T6**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### FrenchReceiptParser

```dart
// lib/features/ocr_scan/domain/services/french_receipt_parser.dart

class FrenchReceiptParser {
  // Pattern produit: texte + prix en fin de ligne (ex: "YAOURT NATURE  1.29")
  static final _productLinePattern = RegExp(
    r'^(.+?)\s{2,}(\d+[.,]\d{2})\s*[A-Z]?\s*$',
    multiLine: true,
    caseSensitive: false,
  );

  // Patterns de lignes à ignorer
  static final _ignorePatterns = [
    RegExp(r'^\s*(TOTAL|SOUS.TOTAL|TVA|MONTANT|TICKET|MERCI|CARTE|CB|ESPECES|MONNAIE|RENDU)', caseSensitive: false),
    RegExp(r'^\s*\d{2}[/\-]\d{2}[/\-]\d{4}'),  // dates
    RegExp(r'^\s*\d{2}:\d{2}'),                  // heures
    RegExp(r'^[A-Z\s]{10,}$'),                    // lignes TOUT MAJUSCULES (headers)
    RegExp(r'^\s*www\.'),                         // URLs
    RegExp(r'^\s*Tél\.?|TEL\.?|N°\s*(TICKET|CAISSE)', caseSensitive: false),
  ];

  // Extraction quantité en préfixe (ex: "2x", "3 x")
  static final _quantityPattern = RegExp(r'^(\d+)\s*[xX]\s+(.+)');

  static List<OcrProduct> parseFromText(String rawText) {
    final lines = rawText.split('\n');
    final products = <OcrProduct>[];

    for (final line in lines) {
      if (_shouldIgnore(line)) continue;

      final match = _productLinePattern.firstMatch(line);
      if (match == null) continue;

      var productText = match.group(1)!.trim();
      final price = match.group(2);

      // Extraire quantité si présente
      int quantity = 1;
      final qtyMatch = _quantityPattern.firstMatch(productText);
      if (qtyMatch != null) {
        quantity = int.parse(qtyMatch.group(1)!);
        productText = qtyMatch.group(2)!;
      }

      // Normaliser le nom
      final normalizedName = FrenchFoodNormalizer.normalize(productText);

      if (normalizedName.length < 3) continue;  // Trop court → ignorer

      products.add(OcrProduct(
        id: const Uuid().v4(),
        rawText: line,
        normalizedName: normalizedName,
        confidence: 0.85,  // Confiance de base pour Vision API
        quantity: quantity,
        unitPrice: price,
      ));
    }

    return products;
  }

  static bool _shouldIgnore(String line) {
    return _ignorePatterns.any((p) => p.hasMatch(line.trim()));
  }

  // Version pour Vision API (list of annotation objects)
  static List<OcrProduct> parse(List<Map<String, dynamic>> annotations) {
    // Google Vision retourne le texte complet comme premier annotation
    if (annotations.isEmpty) return [];
    final fullText = annotations.first['description'] as String? ?? '';
    return parseFromText(fullText);
  }
}
```

### FrenchFoodNormalizer

```dart
// lib/features/ocr_scan/domain/services/french_food_normalizer.dart

class FrenchFoodNormalizer {
  // Abréviations courantes sur tickets français
  static const Map<String, String> _abbreviations = {
    'YAO': 'Yaourt',
    'YAOUF': 'Yaourt',
    'LAI': 'Lait',
    'BEU': 'Beurre',
    'FRO': 'Fromage',
    'JAM': 'Jambon',
    'POU': 'Poulet',
    'BOE': 'Bœuf',
    'SAU': 'Saumon',
    'TOM': 'Tomates',
    'CAR': 'Carottes',
    'POM': 'Pommes',
    'ORA': 'Oranges',
    'BAN': 'Bananes',
    'PAI': 'Pain',
    'BAG': 'Baguette',
    'CEL': 'Céleri',
    'EPI': 'Épinards',
    'COC': 'Courgettes',
    'AUB': 'Aubergines',
    'CHP': 'Champignons',
    'OEU': 'Œufs',
    'OIG': 'Oignons',
    'AIL': 'Ail',
    'CIT': 'Citrons',
    'RAI': 'Raisins',
    'FRA': 'Fraises',
    'ANA': 'Ananas',
    'MAN': 'Mangue',
    'JUS': 'Jus',
    'EAU': 'Eau',
    'VIN': 'Vin',
    'BIE': 'Bière',
    'CAF': 'Café',
    'THE': 'Thé',
    'CHO': 'Chocolat',
    'BIS': 'Biscuits',
    'GAt': 'Gâteau',
    'PAT': 'Pâtes',
    'RIZ': 'Riz',
    'FAR': 'Farine',
    'SUC': 'Sucre',
    'SEL': 'Sel',
  };

  // Mots à supprimer (codes internes, références)
  static final _removePatterns = [
    RegExp(r'\b\d{4,}\b'),                    // Codes numériques longs (>4 chiffres)
    RegExp(r'\bREF\b|\bART\b|\bCOD\b', caseSensitive: false),  // Mots-codes
    RegExp(r'\s{2,}'),                         // Espaces multiples
  ];

  static String normalize(String raw) {
    var text = raw.trim().toUpperCase();

    // Chercher et remplacer abréviations
    for (final entry in _abbreviations.entries) {
      text = text.replaceAll(RegExp('\\b${entry.key}\\b'), entry.value.toUpperCase());
    }

    // Supprimer patterns indésirables
    for (final pattern in _removePatterns) {
      text = text.replaceAll(pattern, ' ');
    }

    // Title case (première lettre de chaque mot en majuscule)
    text = text.split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');

    return text.trim();
  }
}
```

### RetailerConfig (détection enseigne)

```dart
// lib/features/ocr_scan/domain/services/retailer_config.dart

enum FrenchRetailer {
  carrefour,
  leclerc,
  auchan,
  intermarch,
  casino,
  lidl,
  unknown,
}

class RetailerConfig {
  final FrenchRetailer retailer;
  final RegExp headerPattern;
  final double baseConfidenceBoost;  // Certaines enseignes → meilleure précision

  const RetailerConfig({
    required this.retailer,
    required this.headerPattern,
    this.baseConfidenceBoost = 0.0,
  });

  static const List<RetailerConfig> all = [
    RetailerConfig(
      retailer: FrenchRetailer.carrefour,
      headerPattern: _carrefourHeader,
      baseConfidenceBoost: 0.05,
    ),
    RetailerConfig(
      retailer: FrenchRetailer.leclerc,
      headerPattern: _leclerc,
    ),
    RetailerConfig(retailer: FrenchRetailer.lidl, headerPattern: _lidl),
    RetailerConfig(retailer: FrenchRetailer.auchan, headerPattern: _auchan),
  ];

  static final _carrefourHeader = RegExp('CARREFOUR', caseSensitive: false);
  static final _leclerc = RegExp('E[\\.\\.\\s]LECLERC|LECLERC', caseSensitive: false);
  static final _lidl = RegExp('LIDL', caseSensitive: false);
  static final _auchan = RegExp('AUCHAN', caseSensitive: false);

  static FrenchRetailer detectRetailer(String receiptText) {
    for (final config in all) {
      if (config.headerPattern.hasMatch(receiptText.substring(0, min(200, receiptText.length)))) {
        return config.retailer;
      }
    }
    return FrenchRetailer.unknown;
  }
}
```

### Test fixtures (exemples de tickets)

```dart
// test/features/ocr_scan/fixtures/carrefour_receipt.txt
// CARREFOUR MARKET
// 2026-01-15  14:32
// ---
// YAOURT NATURE X4      1.89 A
// LAIT DEMI ECREME      0.95 A
// PAIN DE MIE          2.49 A
// 3x TOMATES EN GRAPPES 4.47 A
// TOTAL                 9.80
// CARTE VISA XXXX       9.80
```

### Project Structure Notes

- `FrenchReceiptParser.parse()` est appelé par DEUX engines: Vision API (annotations JSON) et ML Kit (texte brut)
- Cibles d'exactitude: 85% → nécessitera tests avec vrais tickets et ajustements itératifs
- Le dictionnaire d'abréviations grandira avec les retours utilisateurs et les logs Firebase Analytics

### References

- [Source: epics.md#Story-5.7]
- OcrService dual-engine [Source: Story 5.3]
- Analytics pour monitorer précision [Source: Story 5.10]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
