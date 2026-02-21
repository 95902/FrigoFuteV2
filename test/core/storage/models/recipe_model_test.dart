import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/storage/models/recipe_model.dart';

void main() {
  group('RecipeModel Tests', () {
    late RecipeModel testRecipe;

    setUp(() {
      testRecipe = RecipeModel(
        id: '123',
        title: 'Tarte aux pommes',
        ingredients: ['Pommes', 'Farine', 'Sucre', 'Beurre'],
        instructions: ['Étape 1', 'Étape 2', 'Étape 3'],
        difficulty: 'medium',
        preparationTime: 45,
        tags: ['dessert', 'français', 'automne'],
        photoUrl: 'https://example.com/tarte.jpg',
        calories: 350,
      );
    });

    group('Constructor', () {
      test('should create recipe with all fields', () {
        expect(testRecipe.id, '123');
        expect(testRecipe.title, 'Tarte aux pommes');
        expect(testRecipe.ingredients.length, 4);
        expect(testRecipe.instructions.length, 3);
        expect(testRecipe.difficulty, 'medium');
        expect(testRecipe.preparationTime, 45);
        expect(testRecipe.tags.length, 3);
        expect(testRecipe.photoUrl, 'https://example.com/tarte.jpg');
        expect(testRecipe.calories, 350);
      });

      test('should create recipe with empty tags by default', () {
        final recipe = RecipeModel(
          id: '1',
          title: 'Test',
          ingredients: ['Ingredient 1'],
          instructions: ['Step 1'],
          difficulty: 'easy',
          preparationTime: 10,
        );

        expect(recipe.tags, isEmpty);
        expect(recipe.photoUrl, isNull);
        expect(recipe.calories, isNull);
      });

      test('should handle empty ingredient and instruction lists', () {
        final recipe = RecipeModel(
          id: '1',
          title: 'Test',
          ingredients: [],
          instructions: [],
          difficulty: 'easy',
          preparationTime: 0,
        );

        expect(recipe.ingredients, isEmpty);
        expect(recipe.instructions, isEmpty);
      });

      test('should support different difficulty levels', () {
        final easy = RecipeModel(
          id: '1',
          title: 'Easy Recipe',
          ingredients: ['A'],
          instructions: ['1'],
          difficulty: 'easy',
          preparationTime: 10,
        );

        final hard = RecipeModel(
          id: '2',
          title: 'Hard Recipe',
          ingredients: ['A'],
          instructions: ['1'],
          difficulty: 'hard',
          preparationTime: 120,
        );

        expect(easy.difficulty, 'easy');
        expect(hard.difficulty, 'hard');
      });
    });

    group('toJson', () {
      test('should convert recipe to JSON with all fields', () {
        final json = testRecipe.toJson();

        expect(json['id'], '123');
        expect(json['title'], 'Tarte aux pommes');
        expect(json['ingredients'], ['Pommes', 'Farine', 'Sucre', 'Beurre']);
        expect(json['instructions'], ['Étape 1', 'Étape 2', 'Étape 3']);
        expect(json['difficulty'], 'medium');
        expect(json['preparationTime'], 45);
        expect(json['tags'], ['dessert', 'français', 'automne']);
        expect(json['photoUrl'], 'https://example.com/tarte.jpg');
        expect(json['calories'], 350);
      });

      test('should convert recipe to JSON with null optional fields', () {
        final recipe = RecipeModel(
          id: '1',
          title: 'Test',
          ingredients: ['A'],
          instructions: ['1'],
          difficulty: 'easy',
          preparationTime: 10,
        );

        final json = recipe.toJson();

        expect(json['tags'], isEmpty);
        expect(json['photoUrl'], isNull);
        expect(json['calories'], isNull);
      });

      test('should preserve list order in JSON', () {
        final recipe = RecipeModel(
          id: '1',
          title: 'Test',
          ingredients: ['First', 'Second', 'Third'],
          instructions: ['Step 1', 'Step 2', 'Step 3'],
          difficulty: 'easy',
          preparationTime: 10,
        );

        final json = recipe.toJson();

        final ingredients = json['ingredients'] as List<dynamic>;
        expect(ingredients[0], 'First');
        expect(ingredients[1], 'Second');
        expect(ingredients[2], 'Third');
      });
    });

    group('fromJson', () {
      test('should create recipe from JSON with all fields', () {
        final json = {
          'id': '123',
          'title': 'Tarte aux pommes',
          'ingredients': ['Pommes', 'Farine', 'Sucre', 'Beurre'],
          'instructions': ['Étape 1', 'Étape 2', 'Étape 3'],
          'difficulty': 'medium',
          'preparationTime': 45,
          'tags': ['dessert', 'français', 'automne'],
          'photoUrl': 'https://example.com/tarte.jpg',
          'calories': 350,
        };

        final recipe = RecipeModel.fromJson(json);

        expect(recipe.id, '123');
        expect(recipe.title, 'Tarte aux pommes');
        expect(recipe.ingredients.length, 4);
        expect(recipe.instructions.length, 3);
        expect(recipe.difficulty, 'medium');
        expect(recipe.preparationTime, 45);
        expect(recipe.tags.length, 3);
        expect(recipe.photoUrl, 'https://example.com/tarte.jpg');
        expect(recipe.calories, 350);
      });

      test('should create recipe from JSON with null tags', () {
        final json = {
          'id': '1',
          'title': 'Test',
          'ingredients': ['A'],
          'instructions': ['1'],
          'difficulty': 'easy',
          'preparationTime': 10,
          'tags': null,
        };

        final recipe = RecipeModel.fromJson(json);

        expect(recipe.tags, isEmpty);
      });

      test('should handle empty lists in JSON', () {
        final json = {
          'id': '1',
          'title': 'Test',
          'ingredients': [],
          'instructions': [],
          'difficulty': 'easy',
          'preparationTime': 10,
          'tags': [],
        };

        final recipe = RecipeModel.fromJson(json);

        expect(recipe.ingredients, isEmpty);
        expect(recipe.instructions, isEmpty);
        expect(recipe.tags, isEmpty);
      });

      test('should preserve list order from JSON', () {
        final json = {
          'id': '1',
          'title': 'Test',
          'ingredients': ['First', 'Second', 'Third'],
          'instructions': ['Step 1', 'Step 2'],
          'difficulty': 'easy',
          'preparationTime': 10,
        };

        final recipe = RecipeModel.fromJson(json);

        expect(recipe.ingredients[0], 'First');
        expect(recipe.ingredients[1], 'Second');
        expect(recipe.ingredients[2], 'Third');
        expect(recipe.instructions[0], 'Step 1');
        expect(recipe.instructions[1], 'Step 2');
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('should preserve all data in roundtrip', () {
        final json = testRecipe.toJson();
        final recipe = RecipeModel.fromJson(json);

        expect(recipe.id, testRecipe.id);
        expect(recipe.title, testRecipe.title);
        expect(recipe.ingredients, testRecipe.ingredients);
        expect(recipe.instructions, testRecipe.instructions);
        expect(recipe.difficulty, testRecipe.difficulty);
        expect(recipe.preparationTime, testRecipe.preparationTime);
        expect(recipe.tags, testRecipe.tags);
        expect(recipe.photoUrl, testRecipe.photoUrl);
        expect(recipe.calories, testRecipe.calories);
      });

      test('should preserve list contents in roundtrip', () {
        final recipe = RecipeModel(
          id: '1',
          title: 'Test',
          ingredients: ['A', 'B', 'C'],
          instructions: ['1', '2', '3'],
          difficulty: 'easy',
          preparationTime: 10,
          tags: ['tag1', 'tag2'],
        );

        final json = recipe.toJson();
        final restored = RecipeModel.fromJson(json);

        expect(restored.ingredients, ['A', 'B', 'C']);
        expect(restored.instructions, ['1', '2', '3']);
        expect(restored.tags, ['tag1', 'tag2']);
      });

      test('should handle multiple roundtrips', () {
        var json = testRecipe.toJson();

        for (var i = 0; i < 5; i++) {
          final recipe = RecipeModel.fromJson(json);
          json = recipe.toJson();
        }

        final finalRecipe = RecipeModel.fromJson(json);
        expect(finalRecipe.id, testRecipe.id);
        expect(finalRecipe.title, testRecipe.title);
        expect(finalRecipe.ingredients, testRecipe.ingredients);
      });
    });

    group('Edge cases', () {
      test('should handle very long ingredient lists', () {
        final ingredients = List.generate(100, (i) => 'Ingredient $i');
        final recipe = RecipeModel(
          id: '1',
          title: 'Complex Recipe',
          ingredients: ingredients,
          instructions: ['Mix everything'],
          difficulty: 'hard',
          preparationTime: 300,
        );

        expect(recipe.ingredients.length, 100);
      });

      test('should handle very long instruction lists', () {
        final instructions = List.generate(50, (i) => 'Step $i');
        final recipe = RecipeModel(
          id: '1',
          title: 'Complex Recipe',
          ingredients: ['A'],
          instructions: instructions,
          difficulty: 'hard',
          preparationTime: 300,
        );

        expect(recipe.instructions.length, 50);
      });

      test('should handle Unicode characters in title and ingredients', () {
        final recipe = RecipeModel(
          id: '1',
          title: 'Crème brûlée 🍮',
          ingredients: ['Œufs', 'Crème fraîche', 'Sucre'],
          instructions: ['Mélanger'],
          difficulty: 'medium',
          preparationTime: 30,
        );

        final json = recipe.toJson();
        final restored = RecipeModel.fromJson(json);

        expect(restored.title, 'Crème brûlée 🍮');
        expect(restored.ingredients[0], 'Œufs');
      });

      test('should handle zero preparation time', () {
        final recipe = RecipeModel(
          id: '1',
          title: 'Instant Recipe',
          ingredients: ['Ready-made'],
          instructions: ['Serve'],
          difficulty: 'easy',
          preparationTime: 0,
        );

        expect(recipe.preparationTime, 0);
      });

      test('should handle very high calorie values', () {
        final recipe = RecipeModel(
          id: '1',
          title: 'High Calorie',
          ingredients: ['A'],
          instructions: ['1'],
          difficulty: 'easy',
          preparationTime: 10,
          calories: 9999,
        );

        expect(recipe.calories, 9999);
      });

      test('should handle special characters in tags', () {
        final recipe = RecipeModel(
          id: '1',
          title: 'Test',
          ingredients: ['A'],
          instructions: ['1'],
          difficulty: 'easy',
          preparationTime: 10,
          tags: ['vegan+', 'gluten-free', 'low_carb'],
        );

        expect(recipe.tags.contains('vegan+'), true);
        expect(recipe.tags.contains('gluten-free'), true);
        expect(recipe.tags.contains('low_carb'), true);
      });
    });
  });
}
