# Story 5.10: Monitor and Display OCR/Barcode Scan Success Rate

Status: ready-for-dev

## Story

As a utilisateur (et l'équipe de développement),
I want the development team to track scan success rates,
so that the app continuously improves and becomes more reliable over time.

## Acceptance Criteria

1. **Given** I scan barcodes and receipts regularly
   **When** the app processes scans
   **Then** scan success/failure events are logged to Firebase Analytics

2. **Given** a scan event is logged
   **Then** metrics include: scan type (barcode/receipt), success (bool), OCR confidence avg, engine used (vision/mlkit), processing time ms

3. **Given** Vision API quota usage increases
   **Then** quota usage is tracked in Hive `ocr_quota_box` (via VisionAPICircuitBreaker, Story 5.3)
   **And** when quota reaches 80% (800/1000 req/month), circuit breaker opens automatically

4. **Given** an analytics event is logged
   **Then** no personal data, user content, or image data is included
   **And** only anonymized metrics (types, counts, timings) are sent

5. **Given** the dev team views Firebase Analytics dashboard
   **Then** they can see: scan success rate (%), average processing time, engine distribution

## Tasks / Subtasks

- [ ] **T1**: Créer `ScanAnalyticsService` (AC: 1, 2, 4)
  - [ ] `logBarcodeScanned(barcode: String, success: bool, processingTimeMs: int)`
  - [ ] `logReceiptScanned(OcrResult result)` → logs `ocr_scan_completed`
  - [ ] `logScanFailed(OcrFailure failure, OcrEngine? engine)`
  - [ ] Aucune donnée personnelle — anonymiser barcode (hash SHA-256)
- [ ] **T2**: Créer `QuotaMonitorService` pour Vision API (AC: 3)
  - [ ] Expose `currentMonthUsage` et `remainingQuota`
  - [ ] Expose `quotaUsagePercent` (0.0–1.0)
  - [ ] Alerter via `FirebaseAnalytics` si >90% quota (pre-warning)
- [ ] **T3**: Créer `ScanStatsProvider` Riverpod (AC: 5)
  - [ ] Agréger depuis Hive: barcode success/fail counts, avg confidence, engine distribution
  - [ ] Accessible dans Settings pour affichage debug (dev mode uniquement)
- [ ] **T4**: Intégrer `ScanAnalyticsService` dans `OcrService` (Story 5.3) et `BarcodeScanScreen` (Story 5.1)
- [ ] **T5**: Page "Statistiques de scan" dans Settings (mode debug) (AC: 5)
  - [ ] Afficher taux succès, quota Vision API, répartition engines
  - [ ] Visible uniquement si `kDebugMode || RemoteConfig.showScanStats`
- [ ] **T6**: Tests unitaires `ScanAnalyticsService` — vérifier anonymisation (AC: 4)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### ScanAnalyticsService

```dart
// lib/features/ocr_scan/data/services/scan_analytics_service.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';  // sha256 pour anonymisation

class ScanAnalyticsService {
  final FirebaseAnalytics _analytics;
  final Box<dynamic> _localStatsBox;  // Hive pour stats locales

  ScanAnalyticsService(this._analytics, this._localStatsBox);

  Future<void> logBarcodeScanned({
    required String barcode,
    required bool success,
    required int processingTimeMs,
    String? failureReason,
  }) async {
    // Anonymiser le barcode par hash — PAS le barcode brut
    final barcodeHash = _hashBarcode(barcode);

    await _analytics.logEvent(
      name: 'barcode_scanned',
      parameters: {
        'barcode_hash': barcodeHash.substring(0, 8),  // 8 chars du hash seulement
        'success': success,
        'processing_time_ms': processingTimeMs,
        if (failureReason != null) 'failure_reason': failureReason,
      },
    );

    // Stats locales
    await _incrementLocalStat(success ? 'barcode_success' : 'barcode_fail');
  }

  Future<void> logReceiptScanned(OcrResult result) async {
    await _analytics.logEvent(
      name: 'ocr_scan_completed',
      parameters: {
        'engine': result.engineUsed.name,       // 'vision' ou 'mlkit'
        'success': true,
        'product_count': result.products.length,
        'processing_time_ms': result.processingTimeMs,
        'avg_confidence': _avgConfidence(result.products),
        // PAS de contenu textuel, PAS d'images
      },
    );

    await _incrementLocalStat('ocr_success');
  }

  Future<void> logScanFailed(OcrFailure failure, OcrEngine? engine) async {
    await _analytics.logEvent(
      name: 'ocr_scan_failed',
      parameters: {
        'error_type': failure.analyticsType,
        'engine_attempted': engine?.name ?? 'none',
        // PAS de contenu personnel
      },
    );

    await _incrementLocalStat('ocr_fail');
  }

  Future<void> logQuotaWarning(int currentUsage, int quota) async {
    if (currentUsage / quota >= 0.90) {
      await _analytics.logEvent(
        name: 'vision_api_quota_warning',
        parameters: {
          'usage_count': currentUsage,
          'quota': quota,
          'usage_percent': (currentUsage / quota * 100).round(),
        },
      );
    }
  }

  String _hashBarcode(String barcode) {
    final bytes = utf8.encode(barcode);
    return sha256.convert(bytes).toString();
  }

  double _avgConfidence(List<OcrProduct> products) {
    if (products.isEmpty) return 0;
    return products.map((p) => p.confidence).reduce((a, b) => a + b) / products.length;
  }

  Future<void> _incrementLocalStat(String key) async {
    final current = (_localStatsBox.get(key) as int?) ?? 0;
    await _localStatsBox.put(key, current + 1);
  }

  // Statistiques locales pour debug
  Map<String, int> getLocalStats() {
    return {
      'barcode_success': (_localStatsBox.get('barcode_success') as int?) ?? 0,
      'barcode_fail': (_localStatsBox.get('barcode_fail') as int?) ?? 0,
      'ocr_success': (_localStatsBox.get('ocr_success') as int?) ?? 0,
      'ocr_fail': (_localStatsBox.get('ocr_fail') as int?) ?? 0,
    };
  }
}
```

### Firebase Analytics — Événements définis

| Événement | Paramètres clés |
|-----------|----------------|
| `barcode_scanned` | `barcode_hash` (8 chars), `success`, `processing_time_ms` |
| `ocr_scan_completed` | `engine`, `product_count`, `processing_time_ms`, `avg_confidence` |
| `ocr_scan_failed` | `error_type`, `engine_attempted` |
| `vision_api_quota_warning` | `usage_count`, `quota`, `usage_percent` |

### QuotaMonitorService

```dart
// lib/features/ocr_scan/domain/services/quota_monitor_service.dart

class QuotaMonitorService {
  static const int _monthlyQuota = 1000;
  final VisionAPICircuitBreaker _circuitBreaker;
  final ScanAnalyticsService _analytics;

  int get currentMonthUsage => _circuitBreaker.currentMonthCount;
  int get remainingQuota => _monthlyQuota - currentMonthUsage;
  double get quotaUsagePercent => currentMonthUsage / _monthlyQuota;

  Future<void> checkAndWarn() async {
    if (quotaUsagePercent >= 0.90) {
      await _analytics.logQuotaWarning(currentMonthUsage, _monthlyQuota);
    }
  }
}
```

### ScanStatsScreen (debug/settings)

```dart
// lib/features/ocr_scan/presentation/screens/scan_stats_screen.dart

class ScanStatsScreen extends ConsumerWidget {
  const ScanStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(scanStatsProvider);
    final quota = ref.watch(quotaMonitorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques de scan (Debug)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            title: 'Code-barres',
            success: stats['barcode_success'] ?? 0,
            fail: stats['barcode_fail'] ?? 0,
          ),
          _StatCard(
            title: 'OCR Tickets',
            success: stats['ocr_success'] ?? 0,
            fail: stats['ocr_fail'] ?? 0,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quota Google Vision API', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: quota.usagePercent,
                    color: quota.usagePercent >= 0.80 ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(height: 4),
                  Text('${quota.used} / ${quota.total} requêtes ce mois'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Packages à ajouter

```yaml
dependencies:
  crypto: ^3.0.0  # Pour SHA-256 anonymisation barcode
```

### Privacy compliance

- Barcode hashé (SHA-256) → 8 premiers caractères seulement (irréversible)
- Aucun texte de produit, aucune image, aucun nom utilisateur dans les analytics
- Conforme RGPD Article 5.1(c) — minimisation des données

### Project Structure Notes

- `ScanAnalyticsService` injecté dans `OcrService` (Story 5.3) et `BarcodeScanScreen` (Story 5.1)
- `scan_stats_box` Hive box (Box<dynamic>) pour compteurs locaux
- Visibilité `ScanStatsScreen`: feature flag `show_scan_stats_debug` via RemoteConfig
- `crypto` package (sha256) est une dépendance de `firebase_core` — déjà probablement présent

### References

- [Source: epics.md#Story-5.10]
- VisionAPICircuitBreaker [Source: Story 5.3]
- Firebase Analytics [Source: architecture.md — Event tracking]
- OcrService [Source: Story 5.3]
- RGPD compliance [Source: architecture.md]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
