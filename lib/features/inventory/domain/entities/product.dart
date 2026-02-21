/// Product entity - Domain layer
/// Clean Architecture: Entity indépendante des frameworks
class Product {
  final String id;
  final String name;
  final String category;
  final DateTime expirationDate;
  final String storageLocation;
  final String status;
  final DateTime? addedAt;
  final String? barcode;
  final String? photoUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.expirationDate,
    required this.storageLocation,
    required this.status,
    this.addedAt,
    this.barcode,
    this.photoUrl,
  });

  /// Create a copy with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? category,
    DateTime? expirationDate,
    String? storageLocation,
    String? status,
    DateTime? addedAt,
    String? barcode,
    String? photoUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      expirationDate: expirationDate ?? this.expirationDate,
      storageLocation: storageLocation ?? this.storageLocation,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      barcode: barcode ?? this.barcode,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
