import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_providers.dart';
import '../../domain/entities/product.dart';

/// Exemple ConsumerStatefulWidget - StatefulWidget avec WidgetRef
/// Pattern: Pour forms avec controllers locaux + Riverpod state
class AddProductFormExample extends ConsumerStatefulWidget {
  const AddProductFormExample({super.key});

  @override
  ConsumerState<AddProductFormExample> createState() =>
      _AddProductFormExampleState();
}

class _AddProductFormExampleState extends ConsumerState<AddProductFormExample> {
  // Local state (controllers)
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _selectedStorage = 'fridge';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty || _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        expirationDate: _selectedDate,
        storageLocation: _selectedStorage,
        status: 'fresh',
        addedAt: DateTime.now(),
      );

      // ref.read() pour actions ponctuelles (pas de rebuild)
      // .notifier pour accéder au StateNotifier
      await ref.read(inventoryListProvider.notifier).addProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Produit ajouté ✅')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen() pour side effects (ex: snackbar sur erreur)
    ref.listen<List<Product>>(inventoryListProvider, (previous, next) {
      // Optionnel: réagir aux changements de la liste
      debugPrint('Inventory updated: ${next.length} products');
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un produit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du produit',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              textCapitalization: TextCapitalization.words,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedStorage,
              decoration: const InputDecoration(
                labelText: 'Lieu de stockage',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.kitchen),
              ),
              items: const [
                DropdownMenuItem(value: 'fridge', child: Text('Réfrigérateur')),
                DropdownMenuItem(value: 'freezer', child: Text('Congélateur')),
                DropdownMenuItem(value: 'pantry', child: Text('Garde-manger')),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _selectedStorage = value);
                      }
                    },
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey),
              ),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date d\'expiration'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _isLoading ? null : _selectDate,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ajouter', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
