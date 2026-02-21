import 'product.dart';

/// Filtre pour la liste de produits
class ProductFilter {
  final String? category;
  final String? storageLocation;
  final String? status;
  final String? searchQuery;

  const ProductFilter({
    this.category,
    this.storageLocation,
    this.status,
    this.searchQuery,
  });

  /// Filtre "tous les produits"
  factory ProductFilter.all() {
    return const ProductFilter();
  }

  /// Filtre par catégorie
  factory ProductFilter.category(String category) {
    return ProductFilter(category: category);
  }

  /// Filtre par lieu de stockage
  factory ProductFilter.storage(String storageLocation) {
    return ProductFilter(storageLocation: storageLocation);
  }

  /// Filtre par statut
  factory ProductFilter.status(String status) {
    return ProductFilter(status: status);
  }

  /// Vérifie si un produit correspond au filtre
  bool matches(Product product) {
    if (category != null && product.category != category) {
      return false;
    }

    if (storageLocation != null &&
        product.storageLocation != storageLocation) {
      return false;
    }

    if (status != null && product.status != status) {
      return false;
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      final nameMatch = product.name.toLowerCase().contains(query);
      final categoryMatch = product.category.toLowerCase().contains(query);
      if (!nameMatch && !categoryMatch) {
        return false;
      }
    }

    return true;
  }

  ProductFilter copyWith({
    String? category,
    String? storageLocation,
    String? status,
    String? searchQuery,
  }) {
    return ProductFilter(
      category: category ?? this.category,
      storageLocation: storageLocation ?? this.storageLocation,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
