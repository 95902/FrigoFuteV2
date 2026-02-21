import 'package:flutter/material.dart';

/// OCR Scan Screen - Story 0.5 Placeholder
/// Full implementation: Epic 5
class OcrScanScreen extends StatelessWidget {
  const OcrScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'OCR Scan Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Story 0.5 Placeholder'),
            SizedBox(height: 8),
            Text('Full implementation: Epic 5'),
          ],
        ),
      ),
    );
  }
}
