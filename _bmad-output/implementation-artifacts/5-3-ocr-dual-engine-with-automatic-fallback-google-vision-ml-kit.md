# Story 5.3: OCR Dual-Engine with Automatic Fallback (Google Vision + ML Kit)

Status: ready-for-dev

## Story

As a Thomas (sportif),
I want the app to use the best OCR engine available to ensure high accuracy,
so that my receipt scans are reliable and I don't have to correct many errors.

## Acceptance Criteria

1. **Given** I scan a receipt via OCR
   **When** the OCR processing starts
   **Then** Google Cloud Vision API is attempted first (higher accuracy)
   **And** if Vision API fails or times out (>2s), ML Kit is used as fallback in less than 500ms
   **And** if both engines are unavailable, I see an error message with retry option

2. **Given** the circuit breaker is open (Vision API >80% quota used)
   **Then** ML Kit is used directly without attempting Vision API
   **And** circuit breaker status is reset after 1 hour

3. **Given** OCR processing completes
   **Then** the chosen engine (vision/mlkit) is logged to Firebase Analytics
   **And** processing time is logged for performance monitoring

4. **Given** I am offline
   **Then** ML Kit local engine is used automatically
   **And** Vision API is not attempted

## Tasks / Subtasks

- [ ] **T1**: Ajouter `google_mlkit_text_recognition: ^0.13.0` dans pubspec.yaml (AC: 1)
- [ ] **T2**: Créer `OcrService` avec stratégie dual-engine (AC: 1, 2, 3, 4)
  - [ ] `processReceipt(File image)` → `Either<OcrFailure, List<OcrProduct>>`
  - [ ] Tenter Vision API → fallback ML Kit si échec/timeout
- [ ] **T3**: Créer `VisionApiOcrEngine` — Cloud Function proxy (AC: 1)
  - [ ] POST `{cloudFunctionsBaseUrl}/processOcrTicket`
  - [ ] Body: image base64, Content-Type multipart
  - [ ] Timeout: 2000ms
- [ ] **T4**: Créer `MlKitOcrEngine` — on-device (AC: 1, 4)
  - [ ] `google_mlkit_text_recognition` RecognizedText
  - [ ] Parser FR (Story 5.7) appliqué en post-processing
- [ ] **T5**: Créer `VisionAPICircuitBreaker` (AC: 2)
  - [ ] Compteur requêtes dans Hive `ocr_quota_box`
  - [ ] Seuil: 800 requêtes/mois (80% du free tier 1000)
  - [ ] État `open`/`closed` — reset automatique 1er du mois
- [ ] **T6**: Logger analytics `ocr_scan_completed` event (AC: 3)
  - [ ] Paramètres: `engine` (vision/mlkit), `success`, `processing_time_ms`, `product_count`
- [ ] **T7**: Tests unitaires `OcrService` avec mocks engines (AC: 1, 2, 4)
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Packages à ajouter

```yaml
dependencies:
  google_mlkit_text_recognition: ^0.13.0
```

### OcrEngine enum + OcrResult

```dart
// lib/features/ocr_scan/domain/services/ocr_service.dart

enum OcrEngine { vision, mlkit }

class OcrResult {
  final List<OcrProduct> products;
  final OcrEngine engineUsed;
  final int processingTimeMs;

  const OcrResult({
    required this.products,
    required this.engineUsed,
    required this.processingTimeMs,
  });
}
```

### OcrService — Dual-Engine Orchestrator

```dart
class OcrService {
  final VisionApiOcrEngine _visionEngine;
  final MlKitOcrEngine _mlKitEngine;
  final VisionAPICircuitBreaker _circuitBreaker;
  final ConnectivityService _connectivity;
  final ScanAnalyticsService _analytics;  // Story 5.10

  OcrService(
    this._visionEngine,
    this._mlKitEngine,
    this._circuitBreaker,
    this._connectivity,
    this._analytics,
  );

  Future<Either<OcrFailure, OcrResult>> processReceipt(File image) async {
    final stopwatch = Stopwatch()..start();

    // 1. Offline → ML Kit direct
    if (!await _connectivity.isOnline()) {
      return _runMlKit(image, stopwatch);
    }

    // 2. Circuit breaker ouvert → ML Kit direct
    if (_circuitBreaker.isOpen) {
      return _runMlKit(image, stopwatch);
    }

    // 3. Tenter Vision API (primary)
    try {
      final visionResult = await _visionEngine
          .processReceipt(image)
          .timeout(const Duration(milliseconds: 2000));

      _circuitBreaker.recordSuccess();
      stopwatch.stop();

      final result = OcrResult(
        products: visionResult,
        engineUsed: OcrEngine.vision,
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
      _analytics.logScanCompleted(result);
      return Right(result);

    } on TimeoutException {
      _circuitBreaker.recordFailure();
      return _runMlKit(image, stopwatch);

    } on OcrFailure catch (e) {
      _circuitBreaker.recordFailure();
      // Vision a échoué → fallback ML Kit
      return _runMlKit(image, stopwatch);
    }
  }

  Future<Either<OcrFailure, OcrResult>> _runMlKit(File image, Stopwatch stopwatch) async {
    try {
      final mlkitResult = await _mlKitEngine.processReceipt(image);
      stopwatch.stop();

      final result = OcrResult(
        products: mlkitResult,
        engineUsed: OcrEngine.mlkit,
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
      _analytics.logScanCompleted(result);
      return Right(result);

    } catch (e) {
      stopwatch.stop();
      return Left(OcrFailure.bothEnginesFailed());
    }
  }
}
```

### VisionAPICircuitBreaker

```dart
// lib/features/ocr_scan/domain/services/vision_api_circuit_breaker.dart

class VisionAPICircuitBreaker {
  static const int _monthlyQuota = 1000;
  static const double _circuitBreakerThreshold = 0.80;  // 80%

  final Box<dynamic> _box;  // Hive 'ocr_quota_box'

  VisionAPICircuitBreaker(this._box);

  bool get isOpen {
    final count = _getMonthlyCount();
    return count >= (_monthlyQuota * _circuitBreakerThreshold).round();  // >= 800
  }

  int _getMonthlyCount() {
    final key = _monthKey();
    return (_box.get(key) as int?) ?? 0;
  }

  void recordSuccess() => _incrementCount();
  void recordFailure() => _incrementCount();

  void _incrementCount() {
    final key = _monthKey();
    final current = (_box.get(key) as int?) ?? 0;
    _box.put(key, current + 1);
  }

  String _monthKey() {
    final now = DateTime.now();
    return 'quota_${now.year}_${now.month}';
  }
}
```

### VisionApiOcrEngine

```dart
// lib/features/ocr_scan/data/datasources/vision_api_ocr_engine.dart

class VisionApiOcrEngine {
  final Dio _dio;
  final String _cloudFunctionUrl;  // Depuis RemoteConfig ou env config

  Future<List<OcrProduct>> processReceipt(File image) async {
    // Compression image avant envoi
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await _dio.post(
      '$_cloudFunctionUrl/processOcrTicket',
      data: {'imageBase64': base64Image, 'language': 'fr'},
      options: Options(
        contentType: 'application/json',
        receiveTimeout: const Duration(milliseconds: 2000),
      ),
    );

    return _parseVisionResponse(response.data);
  }

  List<OcrProduct> _parseVisionResponse(Map<String, dynamic> data) {
    // Cloud Function retourne liste de {text, confidence, boundingBox}
    final annotations = data['textAnnotations'] as List? ?? [];
    return FrenchReceiptParser.parse(annotations.cast<Map<String, dynamic>>());
  }
}
```

### MlKitOcrEngine

```dart
// lib/features/ocr_scan/data/datasources/mlkit_ocr_engine.dart

class MlKitOcrEngine {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<OcrProduct>> processReceipt(File image) async {
    final inputImage = InputImage.fromFile(image);
    final recognized = await textRecognizer.processImage(inputImage);
    return FrenchReceiptParser.parseFromText(recognized.text);
  }

  void dispose() => textRecognizer.close();
}
```

### Hive Box Registration

```dart
await Hive.openBox<dynamic>('ocr_quota_box');
```

### Project Structure Notes

- Cloud Function URL: configuré via `RemoteConfigService` ou variable d'env
- `FrenchReceiptParser` est partagé entre Vision et ML Kit — implémenté en Story 5.7
- `OcrFailure` hierarchy: `bothEnginesFailed`, `poorImageQuality`, `notFrenchReceipt`, `apiError`
- Circuit breaker compteur reset par clé mensuelle (pas besoin de timer background)

### References

- [Source: epics.md#Story-5.3]
- VisionAPICircuitBreaker [Source: architecture.md — circuit breaker custom 80% quota]
- Cloud Function proxy [Source: architecture.md — `/processOcrTicket`]
- FrenchReceiptParser [Source: Story 5.7]
- ConnectivityService [Source: Story 0.9]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
