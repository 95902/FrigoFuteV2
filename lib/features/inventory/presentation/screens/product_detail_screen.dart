import 'package:flutter/material.dart';

/// Product Detail Screen
/// Story 0.5: Nested route /inventory/detail/:productId
class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({
    required this.productId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du Produit'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Product ID: $productId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Placeholder - Full implementation in Epic 2',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
