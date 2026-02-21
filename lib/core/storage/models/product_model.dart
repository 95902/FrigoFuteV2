import 'package:hive_ce/hive.dart';

part 'product_model.g.dart';

/// ProductModel - Modèle simple pour produits d'inventaire
///
/// Stocké dans: inventory_box (non-chiffré)
/// Hive TypeId: 1
@HiveType(typeId: 1)
class ProductModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime expirationDate;

  @HiveField(4)
  final String storageLocation;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final DateTime? addedAt;

  @HiveField(7)
  final String? barcode;

  @HiveField(8)
  final String? photoUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.expirationDate,
    this.storageLocation = 'fridge',
    this.status = 'fresh',
    this.addedAt,
    this.barcode,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'expirationDate': expirationDate.toIso8601String(),
        'storageLocation': storageLocation,
        'status': status,
        'addedAt': addedAt?.toIso8601String(),
        'barcode': barcode,
        'photoUrl': photoUrl,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        expirationDate: DateTime.parse(json['expirationDate'] as String),
        storageLocation: json['storageLocation'] as String? ?? 'fridge',
        status: json['status'] as String? ?? 'fresh',
        addedAt: json['addedAt'] != null
            ? DateTime.parse(json['addedAt'] as String)
            : null,
        barcode: json['barcode'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );
}
