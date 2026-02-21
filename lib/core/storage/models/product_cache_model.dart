import 'package:hive_ce/hive.dart';

part 'product_cache_model.g.dart';

/// ProductCacheModel - Modèle simple pour cache OpenFoodFacts
///
/// Stocké dans: products_cache_box (non-chiffré)
/// Hive TypeId: 7
@HiveType(typeId: 7)
class ProductCacheModel {
  @HiveField(0)
  final String barcode;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String? brand;

  @HiveField(3)
  final Map<String, dynamic>? nutritionData;

  @HiveField(4)
  final DateTime cachedAt;

  ProductCacheModel({
    required this.barcode,
    required this.productName,
    required this.cachedAt,
    this.brand,
    this.nutritionData,
  });

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'productName': productName,
        'brand': brand,
        'nutritionData': nutritionData,
        'cachedAt': cachedAt.toIso8601String(),
      };

  factory ProductCacheModel.fromJson(Map<String, dynamic> json) =>
      ProductCacheModel(
        barcode: json['barcode'] as String,
        productName: json['productName'] as String,
        brand: json['brand'] as String?,
        nutritionData: json['nutritionData'] != null
            ? Map<String, dynamic>.from(json['nutritionData'] as Map)
            : null,
        cachedAt: DateTime.parse(json['cachedAt'] as String),
      );
}
