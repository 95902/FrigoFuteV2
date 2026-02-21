import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/storage/models/product_model.dart';

void main() {
  group('ProductModel Tests', () {
    late ProductModel testProduct;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 12, 31);
      testProduct = ProductModel(
        id: '123',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: testDate,
        storageLocation: 'fridge',
        status: 'fresh',
        addedAt: DateTime(2024, 1, 1),
        barcode: '1234567890123',
        photoUrl: 'https://example.com/photo.jpg',
      );
    });

    group('Constructor', () {
      test('should create product with all fields', () {
        expect(testProduct.id, '123');
        expect(testProduct.name, 'Lait');
        expect(testProduct.category, 'Produits laitiers');
        expect(testProduct.expirationDate, testDate);
        expect(testProduct.storageLocation, 'fridge');
        expect(testProduct.status, 'fresh');
        expect(testProduct.addedAt, DateTime(2024, 1, 1));
        expect(testProduct.barcode, '1234567890123');
        expect(testProduct.photoUrl, 'https://example.com/photo.jpg');
      });

      test('should create product with default values', () {
        final product = ProductModel(
          id: '1',
          name: 'Test',
          category: 'Category',
          expirationDate: testDate,
        );

        expect(product.storageLocation, 'fridge');
        expect(product.status, 'fresh');
        expect(product.addedAt, isNull);
        expect(product.barcode, isNull);
        expect(product.photoUrl, isNull);
      });

      test('should create product with custom storage location', () {
        final product = ProductModel(
          id: '1',
          name: 'Test',
          category: 'Category',
          expirationDate: testDate,
          storageLocation: 'freezer',
        );

        expect(product.storageLocation, 'freezer');
      });

      test('should create product with custom status', () {
        final product = ProductModel(
          id: '1',
          name: 'Test',
          category: 'Category',
          expirationDate: testDate,
          status: 'expired',
        );

        expect(product.status, 'expired');
      });
    });

    group('toJson', () {
      test('should convert product to JSON with all fields', () {
        final json = testProduct.toJson();

        expect(json['id'], '123');
        expect(json['name'], 'Lait');
        expect(json['category'], 'Produits laitiers');
        expect(json['expirationDate'], '2024-12-31T00:00:00.000');
        expect(json['storageLocation'], 'fridge');
        expect(json['status'], 'fresh');
        expect(json['addedAt'], '2024-01-01T00:00:00.000');
        expect(json['barcode'], '1234567890123');
        expect(json['photoUrl'], 'https://example.com/photo.jpg');
      });

      test('should convert product to JSON with null optional fields', () {
        final product = ProductModel(
          id: '1',
          name: 'Test',
          category: 'Category',
          expirationDate: testDate,
        );

        final json = product.toJson();

        expect(json['id'], '1');
        expect(json['name'], 'Test');
        expect(json['addedAt'], isNull);
        expect(json['barcode'], isNull);
        expect(json['photoUrl'], isNull);
      });

      test('should handle special characters in strings', () {
        final product = ProductModel(
          id: '1',
          name: 'Café & Thé',
          category: 'Boissons',
          expirationDate: testDate,
        );

        final json = product.toJson();

        expect(json['name'], 'Café & Thé');
      });
    });

    group('fromJson', () {
      test('should create product from JSON with all fields', () {
        final json = {
          'id': '123',
          'name': 'Lait',
          'category': 'Produits laitiers',
          'expirationDate': '2024-12-31T00:00:00.000',
          'storageLocation': 'fridge',
          'status': 'fresh',
          'addedAt': '2024-01-01T00:00:00.000',
          'barcode': '1234567890123',
          'photoUrl': 'https://example.com/photo.jpg',
        };

        final product = ProductModel.fromJson(json);

        expect(product.id, '123');
        expect(product.name, 'Lait');
        expect(product.category, 'Produits laitiers');
        expect(product.expirationDate, DateTime(2024, 12, 31));
        expect(product.storageLocation, 'fridge');
        expect(product.status, 'fresh');
        expect(product.addedAt, DateTime(2024, 1, 1));
        expect(product.barcode, '1234567890123');
        expect(product.photoUrl, 'https://example.com/photo.jpg');
      });

      test('should create product from JSON with null optional fields', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'category': 'Category',
          'expirationDate': '2024-12-31T00:00:00.000',
        };

        final product = ProductModel.fromJson(json);

        expect(product.id, '1');
        expect(product.name, 'Test');
        expect(product.storageLocation, 'fridge');
        expect(product.status, 'fresh');
        expect(product.addedAt, isNull);
        expect(product.barcode, isNull);
        expect(product.photoUrl, isNull);
      });

      test('should use default values when fields are null in JSON', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'category': 'Category',
          'expirationDate': '2024-12-31T00:00:00.000',
          'storageLocation': null,
          'status': null,
        };

        final product = ProductModel.fromJson(json);

        expect(product.storageLocation, 'fridge');
        expect(product.status, 'fresh');
      });

      test('should handle ISO8601 date strings correctly', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'category': 'Category',
          'expirationDate': '2024-06-15T14:30:00.000Z',
        };

        final product = ProductModel.fromJson(json);

        expect(product.expirationDate.year, 2024);
        expect(product.expirationDate.month, 6);
        expect(product.expirationDate.day, 15);
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('should preserve all data in roundtrip', () {
        final json = testProduct.toJson();
        final product = ProductModel.fromJson(json);

        expect(product.id, testProduct.id);
        expect(product.name, testProduct.name);
        expect(product.category, testProduct.category);
        expect(product.expirationDate, testProduct.expirationDate);
        expect(product.storageLocation, testProduct.storageLocation);
        expect(product.status, testProduct.status);
        expect(product.addedAt, testProduct.addedAt);
        expect(product.barcode, testProduct.barcode);
        expect(product.photoUrl, testProduct.photoUrl);
      });

      test('should handle multiple roundtrips', () {
        var json = testProduct.toJson();
        for (var i = 0; i < 5; i++) {
          final product = ProductModel.fromJson(json);
          json = product.toJson();
        }

        final finalProduct = ProductModel.fromJson(json);
        expect(finalProduct.id, testProduct.id);
        expect(finalProduct.name, testProduct.name);
      });
    });

    group('Edge cases', () {
      test('should handle empty strings', () {
        final product = ProductModel(
          id: '',
          name: '',
          category: '',
          expirationDate: testDate,
        );

        expect(product.id, '');
        expect(product.name, '');
        expect(product.category, '');
      });

      test('should handle very long strings', () {
        final longString = 'a' * 1000;
        final product = ProductModel(
          id: '1',
          name: longString,
          category: 'Category',
          expirationDate: testDate,
        );

        expect(product.name.length, 1000);
      });

      test('should handle special date values', () {
        final veryOldDate = DateTime(1970, 1, 1);
        final product = ProductModel(
          id: '1',
          name: 'Test',
          category: 'Category',
          expirationDate: veryOldDate,
        );

        expect(product.expirationDate, veryOldDate);
      });

      test('should handle Unicode characters', () {
        final product = ProductModel(
          id: '1',
          name: 'Café français 🥛',
          category: 'Produits laitiers',
          expirationDate: testDate,
        );

        final json = product.toJson();
        final restored = ProductModel.fromJson(json);

        expect(restored.name, 'Café français 🥛');
      });
    });
  });
}
