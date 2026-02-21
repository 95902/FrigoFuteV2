import 'package:hive_ce/hive.dart';

part 'recipe_model.g.dart';

/// RecipeModel - Modèle simple pour recettes
///
/// Stocké dans: recipes_box (non-chiffré)
/// Hive TypeId: 2
@HiveType(typeId: 2)
class RecipeModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<String> ingredients;

  @HiveField(3)
  final List<String> instructions;

  @HiveField(4)
  final String difficulty;

  @HiveField(5)
  final int preparationTime;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final String? photoUrl;

  @HiveField(8)
  final int? calories;

  RecipeModel({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.difficulty,
    required this.preparationTime,
    this.tags = const [],
    this.photoUrl,
    this.calories,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'ingredients': ingredients,
        'instructions': instructions,
        'difficulty': difficulty,
        'preparationTime': preparationTime,
        'tags': tags,
        'photoUrl': photoUrl,
        'calories': calories,
      };

  factory RecipeModel.fromJson(Map<String, dynamic> json) => RecipeModel(
        id: json['id'] as String,
        title: json['title'] as String,
        ingredients: List<String>.from(json['ingredients'] as List),
        instructions: List<String>.from(json['instructions'] as List),
        difficulty: json['difficulty'] as String,
        preparationTime: json['preparationTime'] as int,
        tags: json['tags'] != null
            ? List<String>.from(json['tags'] as List)
            : const [],
        photoUrl: json['photoUrl'] as String?,
        calories: json['calories'] as int?,
      );
}
