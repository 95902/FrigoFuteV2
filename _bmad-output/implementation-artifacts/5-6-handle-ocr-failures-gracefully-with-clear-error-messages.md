# Story 5.6: Handle OCR Failures Gracefully with Clear Error Messages

Status: ready-for-dev

## Story

As a Lucas (étudiant),
I want helpful error messages if my receipt scan fails,
so that I know what to do to fix the problem.

## Acceptance Criteria

1. **Given** I scan a receipt with poor image quality
   **Then** I see the message: "Qualité d'image insuffisante. Prenez une photo plus nette dans un bon éclairage."
   **And** I am offered options: "Reprendre une photo" ou "Ajouter manuellement"

2. **Given** the OCR does not recognize the receipt format
   **Then** I see: "Format de ticket non reconnu. Essayez un ticket différent ou ajoutez des produits manuellement."
   **And** same action buttons as AC 1

3. **Given** both OCR engines are unavailable (API error + ML Kit error)
   **Then** I see: "Service OCR temporairement indisponible. Réessayez plus tard ou ajoutez des produits manuellement."
   **And** a "Réessayer" button attempts again

4. **Given** an OCR failure occurs
   **Then** the error type and context are logged anonymously to Firebase Analytics
   **And** no personal data or image content is sent in the error log

## Tasks / Subtasks

- [ ] **T1**: Définir `OcrFailure` sealed class avec types (AC: 1, 2, 3)
  - [ ] `OcrFailure.poorImageQuality()`
  - [ ] `OcrFailure.formatNotRecognized()`
  - [ ] `OcrFailure.bothEnginesFailed()`
  - [ ] `OcrFailure.apiError(String details)`
- [ ] **T2**: Créer `OcrErrorScreen` widget (AC: 1, 2, 3)
  - [ ] Icône + message contextuel selon type d'erreur
  - [ ] Boutons d'action: Reprendre photo / Réessayer / Ajouter manuellement
- [ ] **T3**: Logger failure events `ocr_scan_failed` vers Firebase Analytics (AC: 4)
  - [ ] Paramètres: `error_type`, `engine_attempted`, aucune donnée personnelle
- [ ] **T4**: Détecter mauvaise qualité d'image avant envoi API (AC: 1)
  - [ ] Vérifier résolution minimale (> 800×600 px)
  - [ ] Vérifier taille fichier (> 10KB = image non vide)
- [ ] **T5**: Tests unitaires `OcrFailure` → message mapping (AC: 1, 2, 3)
- [ ] **T6**: Tests widget `OcrErrorScreen` (AC: 1, 2)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### OcrFailure sealed class

```dart
// lib/features/ocr_scan/domain/failures/ocr_failure.dart

sealed class OcrFailure {
  const OcrFailure();

  const factory OcrFailure.poorImageQuality() = PoorImageQualityFailure;
  const factory OcrFailure.formatNotRecognized() = FormatNotRecognizedFailure;
  const factory OcrFailure.bothEnginesFailed() = BothEnginesFailedFailure;
  const factory OcrFailure.apiError(String details) = ApiErrorFailure;

  String get userMessage {
    return switch (this) {
      PoorImageQualityFailure() =>
        'Qualité d\'image insuffisante. Prenez une photo plus nette dans un bon éclairage.',
      FormatNotRecognizedFailure() =>
        'Format de ticket non reconnu. Essayez un ticket différent ou ajoutez des produits manuellement.',
      BothEnginesFailedFailure() =>
        'Service OCR temporairement indisponible. Réessayez plus tard ou ajoutez des produits manuellement.',
      ApiErrorFailure() =>
        'Une erreur technique s\'est produite. Réessayez ou ajoutez des produits manuellement.',
    };
  }

  String get analyticsType {
    return switch (this) {
      PoorImageQualityFailure() => 'poor_image_quality',
      FormatNotRecognizedFailure() => 'format_not_recognized',
      BothEnginesFailedFailure() => 'both_engines_failed',
      ApiErrorFailure() => 'api_error',
    };
  }

  bool get canRetry {
    return switch (this) {
      PoorImageQualityFailure() => false,  // Reprendre photo, pas réessayer
      FormatNotRecognizedFailure() => false,
      BothEnginesFailedFailure() => true,  // Peut réessayer si service revient
      ApiErrorFailure() => true,
    };
  }
}

final class PoorImageQualityFailure extends OcrFailure {
  const PoorImageQualityFailure();
}

final class FormatNotRecognizedFailure extends OcrFailure {
  const FormatNotRecognizedFailure();
}

final class BothEnginesFailedFailure extends OcrFailure {
  const BothEnginesFailedFailure();
}

final class ApiErrorFailure extends OcrFailure {
  final String details;
  const ApiErrorFailure(this.details);
}
```

### OcrErrorScreen

```dart
// lib/features/ocr_scan/presentation/screens/ocr_error_screen.dart

class OcrErrorScreen extends StatelessWidget {
  final OcrFailure failure;
  final VoidCallback onRetakePhoto;
  final VoidCallback onAddManually;
  final VoidCallback? onRetry;

  const OcrErrorScreen({
    super.key,
    required this.failure,
    required this.onRetakePhoto,
    required this.onAddManually,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur de scan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconForFailure(failure),
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              failure.userMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            if (failure.canRetry && onRetry != null) ...[
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: onRetakePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Reprendre une photo'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onAddManually,
              icon: const Icon(Icons.edit),
              label: const Text('Ajouter manuellement'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForFailure(OcrFailure failure) {
    return switch (failure) {
      PoorImageQualityFailure() => Icons.image_not_supported,
      FormatNotRecognizedFailure() => Icons.receipt_long,
      BothEnginesFailedFailure() => Icons.cloud_off,
      ApiErrorFailure() => Icons.error_outline,
    };
  }
}
```

### Validation qualité image avant API

```dart
// lib/features/ocr_scan/domain/services/image_quality_validator.dart

class ImageQualityValidator {
  static const int _minFileSizeBytes = 10 * 1024;   // 10KB
  static const int _minWidthPx = 800;
  static const int _minHeightPx = 600;

  /// Retourne null si OK, sinon OcrFailure.poorImageQuality()
  Future<OcrFailure?> validate(File imageFile) async {
    // Vérification taille fichier
    final fileSize = await imageFile.length();
    if (fileSize < _minFileSizeBytes) {
      return const OcrFailure.poorImageQuality();
    }

    // Vérification résolution (via dart:ui Image)
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final img = frame.image;

    if (img.width < _minWidthPx || img.height < _minHeightPx) {
      return const OcrFailure.poorImageQuality();
    }

    return null;  // Image valide
  }
}
```

### Analytics logging

```dart
// Dans OcrService, après chaque échec:
Future<void> _logFailure(OcrFailure failure, OcrEngine? engineAttempted) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'ocr_scan_failed',
    parameters: {
      'error_type': failure.analyticsType,
      'engine_attempted': engineAttempted?.name ?? 'none',
      // AUCUNE donnée personnelle ni contenu d'image
    },
  );
}
```

### Integration dans ReceiptScanScreen

```dart
// Dans _pickImage() de ReceiptScanScreen:
final products = await notifier.processReceipt(File(image.path));
// processReceipt retourne Either<OcrFailure, OcrResult>
result.fold(
  (failure) {
    context.push('/inventory/ocr-error', extra: {
      'failure': failure,
    });
  },
  (result) {
    context.push('/inventory/ocr-review', extra: result.products);
  },
);
```

### Project Structure Notes

- `OcrFailure` est un `sealed class` Dart 3.0 — exhaustif, pas de `else` requis
- `ImageQualityValidator` vérifie avant envoi API pour économiser quota Vision
- Analytics: aucune donnée personnelle ou contenu d'image — uniquement type d'erreur

### References

- [Source: epics.md#Story-5.6]
- OcrService dual-engine [Source: Story 5.3]
- Firebase Analytics logging pattern [Source: Story 5.10]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
