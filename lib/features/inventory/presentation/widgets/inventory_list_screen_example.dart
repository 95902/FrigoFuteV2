import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_providers.dart';
import '../../domain/entities/product.dart';

/// Exemple ConsumerWidget - StatelessWidget avec WidgetRef
/// Pattern: ref.watch() pour rebuild automatique
class InventoryListScreenExample extends ConsumerWidget {
  const InventoryListScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers - rebuild automatique quand state change
    final products = ref.watch(inventoryListProvider);
    final productCount = ref.watch(productCountProvider);
    final expiringSoon = ref.watch(expiringSoonProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventaire ($productCount)'),
        actions: [
          if (expiringSoon.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${expiringSoon.length}'),
                child: const Icon(Icons.warning_amber),
              ),
              onPressed: () {
                // Navigate to expiring products
              },
            ),
        ],
      ),
      body: products.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun produit dans l\'inventaire',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductTileExample(product: product);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add product screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Tile pour afficher un produit
class ProductTileExample extends ConsumerWidget {
  final Product product;

  const ProductTileExample({required this.product, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysUntilExpiration = product.expirationDate
        .difference(DateTime.now())
        .inDays;
    final isExpiringSoon = daysUntilExpiration <= 3 && daysUntilExpiration >= 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isExpiringSoon ? Colors.orange : Colors.green,
        child: Text(
          product.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(product.name),
      subtitle: Text('${product.category} • ${product.storageLocation}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$daysUntilExpiration j',
            style: TextStyle(
              color: isExpiringSoon ? Colors.orange : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            product.status,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: () {
        // Navigate to product details
        ref.read(selectedProductIdProvider.notifier).state = product.id;
      },
      onLongPress: () {
        _showDeleteDialog(context, ref);
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Voulez-vous supprimer "${product.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              // ref.read() pour actions ponctuelles (pas de rebuild)
              await ref
                  .read(inventoryListProvider.notifier)
                  .removeProduct(product.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
