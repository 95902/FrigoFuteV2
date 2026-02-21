import '../repositories/inventory_repository.dart';

/// UseCase pour supprimer un produit de l'inventaire
///
/// Clean Architecture: Use case encapsule la logique métier
/// Story 0.4: Basic implementation
class DeleteProductUseCase {
  final InventoryRepository _repository;

  DeleteProductUseCase(this._repository);

  /// Execute: Supprimer un produit
  ///
  /// Returns: `Future<void>`
  /// Throws: Exception si la suppression échoue
  Future<void> call(String productId) async {
    // Validation
    if (productId.trim().isEmpty) {
      throw Exception('ID du produit invalide');
    }

    // Vérifier que le produit existe
    final existing = await _repository.getById(productId);
    if (existing == null) {
      throw Exception('Produit non trouvé: $productId');
    }

    // Déléguer au repository
    await _repository.delete(productId);
  }
}
