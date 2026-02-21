import '../entities/product.dart';

/// Repository abstrait pour l'inventaire
/// Clean Architecture: Domain layer ne connaît pas l'implémentation
abstract class InventoryRepository {
  /// Récupérer tous les produits de l'inventaire local
  Future<List<Product>> getAll();

  /// Récupérer un produit par son ID
  Future<Product?> getById(String id);

  /// Ajouter un produit
  Future<void> add(Product product);

  /// Mettre à jour un produit
  Future<void> update(Product product);

  /// Supprimer un produit
  Future<void> delete(String id);

  /// Stream de tous les produits (pour real-time updates)
  Stream<List<Product>> watchAll();
}
