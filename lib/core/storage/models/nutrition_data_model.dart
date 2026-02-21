import 'package:hive_ce/hive.dart';

part 'nutrition_data_model.g.dart';

/// NutritionDataModel - Modèle simple pour données nutritionnelles
///
/// Stocké dans: nutrition_data_box (CHIFFRÉ AES-256)
/// Hive TypeId: 4
@HiveType(typeId: 4)
class NutritionDataModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String mealType;

  @HiveField(3)
  final int calories;

  @HiveField(4)
  final double proteins;

  @HiveField(5)
  final double carbs;

  @HiveField(6)
  final double fats;

  @HiveField(7)
  final String? photoUrl;

  NutritionDataModel({
    required this.id,
    required this.date,
    required this.mealType,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mealType': mealType,
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
        'fats': fats,
        'photoUrl': photoUrl,
      };

  factory NutritionDataModel.fromJson(Map<String, dynamic> json) =>
      NutritionDataModel(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mealType: json['mealType'] as String,
        calories: json['calories'] as int,
        proteins: (json['proteins'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fats: (json['fats'] as num).toDouble(),
        photoUrl: json['photoUrl'] as String?,
      );
}
