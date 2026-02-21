# Story 5.4: Display OCR Confidence Score and Allow Manual Correction

Status: ready-for-dev

## Story

As a Marie (senior),
I want to see how confident the app is about the scanned products,
so that I can review and correct any mistakes before adding them to my inventory.

## Acceptance Criteria

1. **Given** I have scanned a receipt via OCR
   **When** the extracted products are displayed for review
   **Then** each product shows a confidence score visually (badge coloré)
   **And** products with low confidence (<70%) are highlighted in orange for review

2. **Given** I tap a product in the review list
   **Then** an edit dialog opens with fields: name, quantity, category
   **And** I can save changes that update the product in the review list

3. **Given** I swipe a product left in the review list
   **Then** a delete confirmation appears
   **And** I can remove incorrectly detected products

4. **Given** I want to add a product missed by OCR
   **Then** a "+" button allows me to manually add it
   **And** it appears at the bottom of the review list

5. **Given** I confirm the final list
   **Then** only the validated (not deleted) products are added to inventory

## Tasks / Subtasks

- [ ] **T1**: Améliorer `OcrProductTile` avec badge de confiance (AC: 1)
  - [ ] Badge vert si confidence ≥ 0.85
  - [ ] Badge orange si 0.70 ≤ confidence < 0.85 (highlight card)
  - [ ] Badge rouge si confidence < 0.70 (highlight + icône avertissement)
- [ ] **T2**: Créer `EditOcrProductDialog` (AC: 2)
  - [ ] Champs: `TextFormField` nom, quantité (`int`), `DropdownButton<ProductCategory>` catégorie
  - [ ] Bouton "Enregistrer" → retourne `OcrProduct` modifié
- [ ] **T3**: Swipe-to-delete sur `OcrProductTile` (AC: 3)
  - [ ] `Dismissible` widget avec direction `DismissDirection.endToStart`
  - [ ] Confirmation `showDialog` avant suppression
- [ ] **T4**: Bouton "Ajouter manuellement" dans `OcrReviewScreen` (AC: 4)
  - [ ] FAB ou bouton dans AppBar → ouvre `AddManualOcrProductDialog`
  - [ ] Produit ajouté avec `confidence: 1.0` (ajout manuel = 100%)
- [ ] **T5**: Tests widget `OcrProductTile` — confidence levels (AC: 1)
- [ ] **T6**: Tests widget `EditOcrProductDialog` (AC: 2)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### OcrProductTile avec confidence badge

```dart
// lib/features/ocr_scan/presentation/widgets/ocr_product_tile.dart

class OcrProductTile extends StatelessWidget {
  final OcrProduct product;
  final VoidCallback onDelete;
  final ValueChanged<OcrProduct> onEdit;

  const OcrProductTile({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        color: _cardColor(product.confidence),
        child: ListTile(
          title: Text(product.normalizedName),
          subtitle: Text('Quantité: ${product.quantity}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ConfidenceBadge(confidence: product.confidence),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openEditDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _cardColor(double confidence) {
    if (confidence < 0.70) return Colors.red.shade50;
    if (confidence < 0.85) return Colors.orange.shade50;
    return null;
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer ce produit ?'),
      content: Text('Voulez-vous supprimer "${product.normalizedName}" ?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx, true);
            onDelete();
          },
          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  Future<void> _openEditDialog(BuildContext context) async {
    final updated = await showDialog<OcrProduct>(
      context: context,
      builder: (_) => EditOcrProductDialog(product: product),
    );
    if (updated != null) onEdit(updated);
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).round();
    final color = confidence >= 0.85
        ? Colors.green
        : confidence >= 0.70
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
```

### EditOcrProductDialog

```dart
// lib/features/ocr_scan/presentation/widgets/edit_ocr_product_dialog.dart

class EditOcrProductDialog extends StatefulWidget {
  final OcrProduct product;

  const EditOcrProductDialog({super.key, required this.product});

  @override
  State<EditOcrProductDialog> createState() => _EditOcrProductDialogState();
}

class _EditOcrProductDialogState extends State<EditOcrProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late ProductCategory _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.normalizedName);
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
    _category = widget.product.category ?? ProductCategory.autre;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le produit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom du produit'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantité'),
          ),
          const SizedBox(height: 12),
          DropdownButton<ProductCategory>(
            value: _category,
            isExpanded: true,
            items: ProductCategory.values.map((c) => DropdownMenuItem(
              value: c,
              child: Text(c.displayName),
            )).toList(),
            onChanged: (c) => setState(() => _category = c ?? _category),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final updated = widget.product.copyWith(
              normalizedName: _nameController.text.trim(),
              quantity: int.tryParse(_quantityController.text) ?? widget.product.quantity,
              category: _category,
              confidence: 1.0,  // Correction manuelle = 100%
            );
            Navigator.pop(context, updated);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
```

### Seuils de confiance

| Confidence | Couleur | Signification |
|------------|---------|---------------|
| ≥ 85% | Vert | Haute confiance — pas de review nécessaire |
| 70–85% | Orange | Confiance moyenne — review recommandée |
| < 70% | Rouge | Faible confiance — review obligatoire |

### Project Structure Notes

- `OcrProductTile` réutilisé dans `OcrReviewScreen` (Story 5.2)
- `EditOcrProductDialog` accessible par tap ET par bouton édition dans le tile
- Produit corrigé manuellement → `confidence: 1.0` (pleine confiance)
- `ProductCategory.displayName` extension (défini en Story 2.1)

### References

- [Source: epics.md#Story-5.4]
- OcrProduct entity [Source: Story 5.2]
- OcrReviewScreen [Source: Story 5.2]
- ProductCategory [Source: Story 2.8]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
