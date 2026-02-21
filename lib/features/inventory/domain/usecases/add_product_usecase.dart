import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

/// UseCase pour ajouter un produit à l'inventaire
///
/// Clean Architecture: Use case encapsule la logique métier
/// Story 0.4: Basic implementation
class AddProductUseCase {
  final InventoryRepository _repository;

  AddProductUseCase(this._repository);

  /// Execute: Ajouter un produit
  ///
  /// Returns: `Future<void>`
  /// Throws: Exception si l'ajout échoue
  Future<void> call(Product product) async {
    // Validation métier
    if (product.name.trim().isEmpty) {
      throw Exception('Le nom du produit ne peut pas être vide');
    }

    if (product.category.trim().isEmpty) {
      throw Exception('La catégorie ne peut pas être vide');
    }

    // Déléguer au repository
    await _repository.add(product);
  }
}
