# Story 5.8: Barcode Scan with Visual Guidance for Correct Positioning

Status: ready-for-dev

## Story

As a Marie (senior),
I want clear visual guidance when scanning barcodes,
so that I know how to position the camera correctly for successful scans.

## Acceptance Criteria

1. **Given** I am on the barcode scan screen
   **When** I point my camera at a barcode
   **Then** I see a visual frame overlay indicating the scan area
   **And** I see real-time feedback text below the frame

2. **Given** the camera detects a barcode in frame
   **Then** the frame turns green and I see "Code-barres détecté !"
   **And** I hear a confirmation beep and feel a haptic vibration
   **And** the scan completes automatically

3. **Given** the barcode is too far
   **Then** I see the text "Rapprochez-vous du code-barres"

4. **Given** the barcode scan screen is open
   **Then** the torch/flash button is available for low-light conditions
   **And** I can toggle it on/off

5. **Given** the interface is designed for all users including seniors
   **Then** all text is at minimum 16sp, buttons are minimum 48dp touch targets
   **And** instructions are clear and simple

## Tasks / Subtasks

- [ ] **T1**: Améliorer `BarcodeScanScreen` avec overlay guidage (AC: 1, 2, 3)
  - [ ] `CustomPainter` pour frame d'overlay avec coins arrondis
  - [ ] Animation pulse verte quand code détecté
  - [ ] Texte feedback en temps réel sous le frame
- [ ] **T2**: Implémenter analyse taille barcode → feedback distance (AC: 3)
  - [ ] Si `BarcodeCapture.barcodes.first.size` < seuil → "Rapprochez-vous"
  - [ ] Sinon → "Centrez le code-barres"
- [ ] **T3**: Son de confirmation au scan réussi (AC: 2)
  - [ ] `SystemSound.play(SystemSoundType.click)` ou fichier audio custom
  - [ ] `HapticFeedback.heavyImpact()` vibration
- [ ] **T4**: Bouton torche (AC: 4)
  - [ ] `MobileScanner.toggleTorch()` via `MobileScannerController`
  - [ ] Icône `Icons.flashlight_on` / `Icons.flashlight_off`
- [ ] **T5**: Vérification accessibilité — tailles minimales (AC: 5)
  - [ ] Texte ≥ 16sp, boutons ≥ 48dp
- [ ] **T6**: Tests widget `BarcodeScanScreen` avec mock scanner (AC: 1, 4)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### BarcodeScanScreen amélioré (Story 5.8)

```dart
// lib/features/ocr_scan/presentation/screens/barcode_scan_screen.dart
// Extension de la version Story 5.1

class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  bool _torchEnabled = false;
  _ScanFeedback _feedback = _ScanFeedback.searching;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner un code-barres', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          // Bouton torche
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flashlight_on : Icons.flashlight_off,
              color: Colors.white,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Lampe torche',
            iconSize: 28,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay sombre avec zone de scan transparente
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ScanOverlayPainter(
              detected: _feedback == _ScanFeedback.detected,
              pulseValue: _pulseController.value,
            ),
          ),

          // Texte de guidage en bas
          Positioned(
            bottom: 80,
            left: 24, right: 24,
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _feedback.message,
                    key: ValueKey(_feedback),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _feedback == _ScanFeedback.detected ? Colors.green : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Bouton annuler (48dp minimum)
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ),
              ],
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

    setState(() {
      _isProcessing = true;
      _feedback = _ScanFeedback.detected;
    });

    _pulseController.forward();
    HapticFeedback.heavyImpact();
    // Son de confirmation
    await SystemSound.play(SystemSoundType.click);

    // Petite pause pour l'animation visuelle
    await Future.delayed(const Duration(milliseconds: 500));

    final result = await ref.read(productFromBarcodeUseCaseProvider).execute(barcode);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isProcessing = false;
          _feedback = _ScanFeedback.searching;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message ?? 'Erreur inconnue')),
        );
      },
      (product) => context.push('/inventory/add-from-barcode', extra: {
        'product': product,
        'barcode': barcode,
      }),
    );
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}
```

### ScanFeedback states

```dart
enum _ScanFeedback {
  searching(message: 'Pointez la caméra sur le code-barres'),
  tooFar(message: 'Rapprochez-vous du code-barres'),
  detected(message: '✓ Code-barres détecté !'),
  processing(message: 'Recherche du produit…');

  final String message;
  const _ScanFeedback({required this.message});
}
```

### CustomPainter pour overlay scan

```dart
class _ScanOverlayPainter extends CustomPainter {
  final bool detected;
  final double pulseValue;

  static const double _frameWidth = 260;
  static const double _frameHeight = 130;
  static const double _cornerRadius = 12;
  static const double _cornerLength = 30;

  const _ScanOverlayPainter({required this.detected, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final frameRect = Rect.fromCenter(
      center: center,
      width: _frameWidth + (detected ? pulseValue * 10 : 0),
      height: _frameHeight + (detected ? pulseValue * 5 : 0),
    );

    // Zone sombre autour du frame
    final dimPaint = Paint()..color = Colors.black54;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(_cornerRadius)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, dimPaint);

    // Coins du cadre
    final cornerPaint = Paint()
      ..color = detected ? Colors.green : Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 4 coins: top-left, top-right, bottom-left, bottom-right
    final corners = [
      (frameRect.topLeft, false, false),
      (frameRect.topRight, false, true),
      (frameRect.bottomLeft, true, false),
      (frameRect.bottomRight, true, true),
    ];

    for (final (origin, isBottom, isRight) in corners) {
      final dx = isRight ? -_cornerLength : _cornerLength;
      final dy = isBottom ? -_cornerLength : _cornerLength;

      canvas.drawLine(origin, origin.translate(dx, 0), cornerPaint);
      canvas.drawLine(origin, origin.translate(0, dy), cornerPaint);
    }
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) =>
      oldDelegate.detected != detected || oldDelegate.pulseValue != pulseValue;
}
```

### Project Structure Notes

- `MobileScannerController` doit être `dispose()`d dans `State.dispose()`
- Feedback "trop loin": `capture.barcodes.first.size?.width < 100` (pixels dans le frame)
- `SystemSound.play` ne fonctionne qu'avec les sons système — pour un beep custom, utiliser `audioplayers` package
- Accessibilité: `Semantics(label: 'Scanner actif, pointez vers un code-barres')` sur la camera view

### References

- [Source: epics.md#Story-5.8]
- mobile_scanner package [Source: Story 5.1]
- HapticFeedback [Flutter SDK docs]
- Accessibilité Flutter (Material guidelines: 48dp touch targets)

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
