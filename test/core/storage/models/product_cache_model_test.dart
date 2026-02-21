import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/storage/models/product_cache_model.dart';

void main() {
  group('ProductCacheModel Tests', () {
    late ProductCacheModel testCache;
    late DateTime testDate;
    late Map<String, dynamic> testNutrition;

    setUp(() {
      testDate = DateTime(2026, 2, 15, 14, 30);
      testNutrition = {
        'calories': 150,
        'proteins': 12.0,
        'carbs': 8.0,
        'fats': 8.5,
      };

      testCache = ProductCacheModel(
        barcode: '3017620425035',
        productName: 'Nutella 750g',
        brand: 'Ferrero',
        nutritionData: testNutrition,
        cachedAt: testDate,
      );
    });

    group('Constructor', () {
      test('should create cache with all fields', () {
        expect(testCache.barcode, '3017620425035');
        expect(testCache.productName, 'Nutella 750g');
        expect(testCache.brand, 'Ferrero');
        expect(testCache.nutritionData?['calories'], 150);
        expect(testCache.cachedAt, testDate);
      });

      test('should create cache without optional fields', () {
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Generic Product',
          cachedAt: testDate,
        );

        expect(cache.brand, isNull);
        expect(cache.nutritionData, isNull);
      });

      test('should handle different barcode formats', () {
        final ean13 = ProductCacheModel(
          barcode: '3017620425035',
          productName: 'EAN-13 Product',
          cachedAt: testDate,
        );

        final upc = ProductCacheModel(
          barcode: '012345678905',
          productName: 'UPC Product',
          cachedAt: testDate,
        );

        expect(ean13.barcode.length, 13);
        expect(upc.barcode.length, 12);
      });

      test('should handle empty nutrition data', () {
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'No Nutrition',
          cachedAt: testDate,
          nutritionData: {},
        );

        expect(cache.nutritionData, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert to JSON with all fields', () {
        final json = testCache.toJson();

        expect(json['barcode'], '3017620425035');
        expect(json['productName'], 'Nutella 750g');
        expect(json['brand'], 'Ferrero');
        expect(
          (json['nutritionData'] as Map<String, dynamic>)['calories'],
          150,
        );
        expect(json['cachedAt'], testDate.toIso8601String());
      });

      test('should convert to JSON with null optional fields', () {
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Generic',
          cachedAt: testDate,
        );

        final json = cache.toJson();

        expect(json['brand'], isNull);
        expect(json['nutritionData'], isNull);
      });

      test('should preserve nutrition data structure', () {
        final nutrition = {
          'energy_kcal': 500,
          'proteins_g': 25.0,
          'carbs_g': 60.0,
          'fats_g': 15.0,
          'fiber_g': 5.0,
          'sodium_mg': 300,
        };

        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Detailed Product',
          cachedAt: testDate,
          nutritionData: nutrition,
        );

        final json = cache.toJson();

        final nutritionData = json['nutritionData'] as Map<String, dynamic>;
        expect(nutritionData['energy_kcal'] as int, 500);
        expect(nutritionData['fiber_g'] as double, 5.0);
      });
    });

    group('fromJson', () {
      test('should create from JSON with all fields', () {
        final json = {
          'barcode': '3017620425035',
          'productName': 'Nutella 750g',
          'brand': 'Ferrero',
          'nutritionData': {'calories': 150, 'proteins': 12.0},
          'cachedAt': '2026-02-15T14:30:00.000',
        };

        final cache = ProductCacheModel.fromJson(json);

        expect(cache.barcode, '3017620425035');
        expect(cache.productName, 'Nutella 750g');
        expect(cache.brand, 'Ferrero');
        expect(cache.nutritionData?['calories'], 150);
        expect(cache.cachedAt, DateTime(2026, 2, 15, 14, 30));
      });

      test('should create from JSON with null optional fields', () {
        final json = {
          'barcode': '1234567890123',
          'productName': 'Generic',
          'brand': null,
          'nutritionData': null,
          'cachedAt': '2026-02-15T14:30:00.000',
        };

        final cache = ProductCacheModel.fromJson(json);

        expect(cache.brand, isNull);
        expect(cache.nutritionData, isNull);
      });

      test('should parse ISO8601 dates correctly', () {
        final json = {
          'barcode': '1234567890123',
          'productName': 'Test',
          'cachedAt': '2026-02-15T14:30:45.123Z',
        };

        final cache = ProductCacheModel.fromJson(json);

        expect(cache.cachedAt.year, 2026);
        expect(cache.cachedAt.month, 2);
        expect(cache.cachedAt.day, 15);
        expect(cache.cachedAt.hour, 14);
        expect(cache.cachedAt.minute, 30);
      });

      test('should handle complex nutrition data', () {
        final json = {
          'barcode': '1234567890123',
          'productName': 'Complex',
          'cachedAt': '2026-02-15T14:30:00.000',
          'nutritionData': {
            'energy': {'kcal': 500, 'kj': 2100},
            'macros': {'proteins': 25.0, 'carbs': 60.0},
          },
        };

        final cache = ProductCacheModel.fromJson(json);

        expect(
          (cache.nutritionData?['energy'] as Map<String, dynamic>)['kcal'],
          500,
        );
        expect(
          (cache.nutritionData?['macros'] as Map<String, dynamic>)['proteins'],
          25.0,
        );
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('should preserve all data in roundtrip', () {
        final json = testCache.toJson();
        final restored = ProductCacheModel.fromJson(json);

        expect(restored.barcode, testCache.barcode);
        expect(restored.productName, testCache.productName);
        expect(restored.brand, testCache.brand);
        expect(restored.nutritionData, testCache.nutritionData);
        expect(restored.cachedAt, testCache.cachedAt);
      });

      test('should preserve null fields in roundtrip', () {
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Test',
          cachedAt: testDate,
        );

        final json = cache.toJson();
        final restored = ProductCacheModel.fromJson(json);

        expect(restored.brand, isNull);
        expect(restored.nutritionData, isNull);
      });

      test('should handle multiple roundtrips', () {
        var json = testCache.toJson();

        for (var i = 0; i < 5; i++) {
          final cache = ProductCacheModel.fromJson(json);
          json = cache.toJson();
        }

        final finalCache = ProductCacheModel.fromJson(json);
        expect(finalCache.barcode, testCache.barcode);
        expect(finalCache.productName, testCache.productName);
      });
    });

    group('Cache expiry logic', () {
      test('should handle recent cache (cached today)', () {
        final now = DateTime.now();
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Fresh Cache',
          cachedAt: now,
        );

        final age = now.difference(cache.cachedAt);
        expect(age.inHours, lessThan(24));
      });

      test('should handle old cache (cached 30 days ago)', () {
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Old Cache',
          cachedAt: thirtyDaysAgo,
        );

        final age = DateTime.now().difference(cache.cachedAt);
        expect(age.inDays, greaterThanOrEqualTo(30));
      });

      test('should handle very old cache (cached 1 year ago)', () {
        final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Very Old Cache',
          cachedAt: oneYearAgo,
        );

        final age = DateTime.now().difference(cache.cachedAt);
        expect(age.inDays, greaterThanOrEqualTo(365));
      });
    });

    group('Edge cases', () {
      test('should handle very long product names', () {
        final longName = 'A' * 500;
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: longName,
          cachedAt: testDate,
        );

        expect(cache.productName.length, 500);
      });

      test('should handle special characters in product name', () {
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Produit & Marque (Spécial) - 100%',
          cachedAt: testDate,
        );

        expect(cache.productName.contains('&'), isTrue);
        expect(cache.productName.contains('%'), isTrue);
      });

      test('should handle Unicode in product name', () {
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Café français 🥐',
          brand: 'Boulangerie™',
          cachedAt: testDate,
        );

        final json = cache.toJson();
        final restored = ProductCacheModel.fromJson(json);

        expect(restored.productName, 'Café français 🥐');
        expect(restored.brand, 'Boulangerie™');
      });

      test('should handle empty strings', () {
        final cache = ProductCacheModel(
          barcode: '',
          productName: '',
          brand: '',
          cachedAt: testDate,
        );

        expect(cache.barcode, '');
        expect(cache.productName, '');
        expect(cache.brand, '');
      });

      test('should handle dates far in the past', () {
        final oldDate = DateTime(2015, 1, 1);
        final cache = ProductCacheModel(
          barcode: '1234567890123',
          productName: 'Old Cache',
          cachedAt: oldDate,
        );

        expect(cache.cachedAt, oldDate);
      });
    });
  });
}
