import 'package:flutter/material.dart';

/// Scan Result Screen
/// Story 0.5: Nested route /ocr-scan/result/:scanId
class ScanResultScreen extends StatelessWidget {
  final String scanId;

  const ScanResultScreen({
    required this.scanId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du Scan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Scan ID: $scanId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Placeholder - Full implementation in Epic 5',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
