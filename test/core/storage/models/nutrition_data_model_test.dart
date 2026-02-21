import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/storage/models/nutrition_data_model.dart';

void main() {
  group('NutritionDataModel Tests', () {
    late NutritionDataModel testData;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2026, 2, 15, 12, 30);
      testData = NutritionDataModel(
        id: '123',
        date: testDate,
        mealType: 'lunch',
        calories: 650,
        proteins: 35.5,
        carbs: 75.2,
        fats: 22.8,
        photoUrl: 'https://example.com/meal.jpg',
      );
    });

    group('Constructor', () {
      test('should create nutrition data with all fields', () {
        expect(testData.id, '123');
        expect(testData.date, testDate);
        expect(testData.mealType, 'lunch');
        expect(testData.calories, 650);
        expect(testData.proteins, 35.5);
        expect(testData.carbs, 75.2);
        expect(testData.fats, 22.8);
        expect(testData.photoUrl, 'https://example.com/meal.jpg');
      });

      test('should create nutrition data without photo', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'breakfast',
          calories: 300,
          proteins: 15.0,
          carbs: 40.0,
          fats: 10.0,
        );

        expect(data.photoUrl, isNull);
      });

      test('should support different meal types', () {
        final breakfast = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'breakfast',
          calories: 300,
          proteins: 15.0,
          carbs: 40.0,
          fats: 10.0,
        );

        final dinner = NutritionDataModel(
          id: '2',
          date: testDate,
          mealType: 'dinner',
          calories: 700,
          proteins: 40.0,
          carbs: 80.0,
          fats: 25.0,
        );

        expect(breakfast.mealType, 'breakfast');
        expect(dinner.mealType, 'dinner');
      });

      test('should handle zero values', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'snack',
          calories: 0,
          proteins: 0.0,
          carbs: 0.0,
          fats: 0.0,
        );

        expect(data.calories, 0);
        expect(data.proteins, 0.0);
        expect(data.carbs, 0.0);
        expect(data.fats, 0.0);
      });
    });

    group('toJson', () {
      test('should convert to JSON with all fields', () {
        final json = testData.toJson();

        expect(json['id'], '123');
        expect(json['date'], testDate.toIso8601String());
        expect(json['mealType'], 'lunch');
        expect(json['calories'], 650);
        expect(json['proteins'], 35.5);
        expect(json['carbs'], 75.2);
        expect(json['fats'], 22.8);
        expect(json['photoUrl'], 'https://example.com/meal.jpg');
      });

      test('should convert to JSON with null photo', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'breakfast',
          calories: 300,
          proteins: 15.0,
          carbs: 40.0,
          fats: 10.0,
        );

        final json = data.toJson();

        expect(json['photoUrl'], isNull);
      });

      test('should preserve decimal precision', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'lunch',
          calories: 500,
          proteins: 25.123,
          carbs: 60.456,
          fats: 15.789,
        );

        final json = data.toJson();

        expect(json['proteins'], 25.123);
        expect(json['carbs'], 60.456);
        expect(json['fats'], 15.789);
      });
    });

    group('fromJson', () {
      test('should create from JSON with all fields', () {
        final json = {
          'id': '123',
          'date': '2026-02-15T12:30:00.000',
          'mealType': 'lunch',
          'calories': 650,
          'proteins': 35.5,
          'carbs': 75.2,
          'fats': 22.8,
          'photoUrl': 'https://example.com/meal.jpg',
        };

        final data = NutritionDataModel.fromJson(json);

        expect(data.id, '123');
        expect(data.date, DateTime(2026, 2, 15, 12, 30));
        expect(data.mealType, 'lunch');
        expect(data.calories, 650);
        expect(data.proteins, 35.5);
        expect(data.carbs, 75.2);
        expect(data.fats, 22.8);
        expect(data.photoUrl, 'https://example.com/meal.jpg');
      });

      test('should create from JSON with null photo', () {
        final json = {
          'id': '1',
          'date': '2026-02-15T08:00:00.000',
          'mealType': 'breakfast',
          'calories': 300,
          'proteins': 15.0,
          'carbs': 40.0,
          'fats': 10.0,
          'photoUrl': null,
        };

        final data = NutritionDataModel.fromJson(json);

        expect(data.photoUrl, isNull);
      });

      test('should handle integer values for double fields', () {
        final json = {
          'id': '1',
          'date': '2026-02-15T12:00:00.000',
          'mealType': 'lunch',
          'calories': 500,
          'proteins': 30, // int instead of double
          'carbs': 60, // int instead of double
          'fats': 15, // int instead of double
        };

        final data = NutritionDataModel.fromJson(json);

        expect(data.proteins, 30.0);
        expect(data.carbs, 60.0);
        expect(data.fats, 15.0);
      });

      test('should parse ISO8601 dates correctly', () {
        final json = {
          'id': '1',
          'date': '2026-02-15T14:30:45.123Z',
          'mealType': 'snack',
          'calories': 150,
          'proteins': 5.0,
          'carbs': 20.0,
          'fats': 3.0,
        };

        final data = NutritionDataModel.fromJson(json);

        expect(data.date.year, 2026);
        expect(data.date.month, 2);
        expect(data.date.day, 15);
        expect(data.date.hour, 14);
        expect(data.date.minute, 30);
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('should preserve all data in roundtrip', () {
        final json = testData.toJson();
        final restored = NutritionDataModel.fromJson(json);

        expect(restored.id, testData.id);
        expect(restored.date, testData.date);
        expect(restored.mealType, testData.mealType);
        expect(restored.calories, testData.calories);
        expect(restored.proteins, testData.proteins);
        expect(restored.carbs, testData.carbs);
        expect(restored.fats, testData.fats);
        expect(restored.photoUrl, testData.photoUrl);
      });

      test('should preserve decimal precision in roundtrip', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'lunch',
          calories: 500,
          proteins: 25.123456,
          carbs: 60.789012,
          fats: 15.345678,
        );

        final json = data.toJson();
        final restored = NutritionDataModel.fromJson(json);

        expect(restored.proteins, 25.123456);
        expect(restored.carbs, 60.789012);
        expect(restored.fats, 15.345678);
      });

      test('should handle multiple roundtrips', () {
        var json = testData.toJson();

        for (var i = 0; i < 5; i++) {
          final data = NutritionDataModel.fromJson(json);
          json = data.toJson();
        }

        final finalData = NutritionDataModel.fromJson(json);
        expect(finalData.calories, testData.calories);
        expect(finalData.proteins, testData.proteins);
      });
    });

    group('Macro calculations', () {
      test('should support macro percentage calculations', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'lunch',
          calories: 600,
          proteins: 30.0, // 120 kcal (4 kcal/g)
          carbs: 60.0, // 240 kcal (4 kcal/g)
          fats: 20.0, // 180 kcal (9 kcal/g)
        );

        // Total from macros: 120 + 240 + 180 = 540 kcal
        expect(data.proteins * 4, 120);
        expect(data.carbs * 4, 240);
        expect(data.fats * 9, 180);
      });

      test('should handle high protein meals', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'lunch',
          calories: 500,
          proteins: 50.0,
          carbs: 30.0,
          fats: 15.0,
        );

        expect(data.proteins, greaterThan(data.carbs));
        expect(data.proteins, greaterThan(data.fats));
      });

      test('should handle low carb meals', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'dinner',
          calories: 600,
          proteins: 40.0,
          carbs: 10.0,
          fats: 35.0,
        );

        expect(data.carbs, lessThan(data.proteins));
        expect(data.carbs, lessThan(data.fats));
      });
    });

    group('Edge cases', () {
      test('should handle very high calorie values', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'cheat_meal',
          calories: 5000,
          proteins: 100.0,
          carbs: 500.0,
          fats: 200.0,
        );

        expect(data.calories, 5000);
      });

      test('should handle fractional macro values', () {
        final data = NutritionDataModel(
          id: '1',
          date: testDate,
          mealType: 'snack',
          calories: 100,
          proteins: 2.5,
          carbs: 15.7,
          fats: 3.3,
        );

        expect(data.proteins, 2.5);
        expect(data.carbs, 15.7);
        expect(data.fats, 3.3);
      });

      test('should handle dates far in the past', () {
        final oldDate = DateTime(2020, 1, 1);
        final data = NutritionDataModel(
          id: '1',
          date: oldDate,
          mealType: 'breakfast',
          calories: 300,
          proteins: 15.0,
          carbs: 40.0,
          fats: 10.0,
        );

        expect(data.date, oldDate);
      });

      test('should handle dates in the future', () {
        final futureDate = DateTime(2030, 12, 31);
        final data = NutritionDataModel(
          id: '1',
          date: futureDate,
          mealType: 'dinner',
          calories: 700,
          proteins: 40.0,
          carbs: 80.0,
          fats: 25.0,
        );

        expect(data.date, futureDate);
      });
    });
  });
}
