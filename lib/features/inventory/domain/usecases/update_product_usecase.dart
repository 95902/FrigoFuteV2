import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

/// UseCase pour mettre à jour un produit dans l'inventaire
///
/// Clean Architecture: Use case encapsule la logique métier
/// Story 0.4: Basic implementation
class UpdateProductUseCase {
  final InventoryRepository _repository;

  UpdateProductUseCase(this._repository);

  /// Execute: Mettre à jour un produit
  ///
  /// Returns: `Future<void>`
  /// Throws: Exception si la mise à jour échoue
  Future<void> call(Product product) async {
    // Validation métier
    if (product.name.trim().isEmpty) {
      throw Exception('Le nom du produit ne peut pas être vide');
    }

    if (product.category.trim().isEmpty) {
      throw Exception('La catégorie ne peut pas être vide');
    }

    // Vérifier que le produit existe
    final existing = await _repository.getById(product.id);
    if (existing == null) {
      throw Exception('Produit non trouvé: ${product.id}');
    }

    // Déléguer au repository
    await _repository.update(product);
  }
}
