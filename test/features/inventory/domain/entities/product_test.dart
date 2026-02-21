import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/inventory/domain/entities/product.dart';

void main() {
  group('Product Entity', () {
    test('should create product with all fields', () {
      // Arrange & Act
      final expirationDate = DateTime(2024, 12, 31);
      final product = Product(
        id: '1',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: expirationDate,
        storageLocation: 'fridge',
        status: 'fresh',
      );

      // Assert
      expect(product.id, '1');
      expect(product.name, 'Lait');
      expect(product.category, 'Produits laitiers');
      expect(product.expirationDate, expirationDate);
      expect(product.storageLocation, 'fridge');
      expect(product.status, 'fresh');
    });

    test('should support different product statuses', () {
      final date = DateTime.now();

      final freshProduct = Product(
        id: '1',
        name: 'Product',
        category: 'Category',
        expirationDate: date,
        storageLocation: 'fridge',
        status: 'fresh',
      );

      final expiringProduct = Product(
        id: '2',
        name: 'Product',
        category: 'Category',
        expirationDate: date,
        storageLocation: 'fridge',
        status: 'expiring',
      );

      final expiredProduct = Product(
        id: '3',
        name: 'Product',
        category: 'Category',
        expirationDate: date,
        storageLocation: 'fridge',
        status: 'expired',
      );

      final consumedProduct = Product(
        id: '4',
        name: 'Product',
        category: 'Category',
        expirationDate: date,
        storageLocation: 'fridge',
        status: 'consumed',
      );

      expect(freshProduct.status, 'fresh');
      expect(expiringProduct.status, 'expiring');
      expect(expiredProduct.status, 'expired');
      expect(consumedProduct.status, 'consumed');
    });

    test('should support different storage locations', () {
      final date = DateTime.now();

      final fridgeProduct = Product(
        id: '1',
        name: 'Product',
        category: 'Category',
        expirationDate: date,
        storageLocation: 'fridge',
        status: 'fresh',
      );

      final freezerProduct = Product(
        id: '2',
        name: 'Product',
        category: 'Category',
        expirationDate: date,
        storageLocation: 'freezer',
        status: 'fresh',
      );

      final pantryProduct = Product(
        id: '3',
        name: 'Product',
        category: 'Category',
        expirationDate: date,
        storageLocation: 'pantry',
        status: 'fresh',
      );

      expect(fridgeProduct.storageLocation, 'fridge');
      expect(freezerProduct.storageLocation, 'freezer');
      expect(pantryProduct.storageLocation, 'pantry');
    });

    test('should support various product categories', () {
      final date = DateTime.now();

      final categories = [
        'Produits laitiers',
        'Viandes et poissons',
        'Fruits et légumes',
        'Boulangerie',
        'Snacks',
        'Boissons',
        'Surgelés',
        'Conserves',
      ];

      for (var i = 0; i < categories.length; i++) {
        final product = Product(
          id: '$i',
          name: 'Product $i',
          category: categories[i],
          expirationDate: date,
          storageLocation: 'fridge',
          status: 'fresh',
        );

        expect(product.category, categories[i]);
      }
    });

    test('should handle expiration dates in the past', () {
      final pastDate = DateTime(2020, 1, 1);
      final product = Product(
        id: '1',
        name: 'Expired Product',
        category: 'Category',
        expirationDate: pastDate,
        storageLocation: 'fridge',
        status: 'expired',
      );

      expect(product.expirationDate.isBefore(DateTime.now()), isTrue);
    });

    test('should handle expiration dates in the future', () {
      final futureDate = DateTime.now().add(const Duration(days: 365));
      final product = Product(
        id: '1',
        name: 'Fresh Product',
        category: 'Category',
        expirationDate: futureDate,
        storageLocation: 'fridge',
        status: 'fresh',
      );

      expect(product.expirationDate.isAfter(DateTime.now()), isTrue);
    });

    test('should handle products with same name but different IDs', () {
      final date = DateTime.now();
      final product1 = Product(
        id: '1',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: date,
        storageLocation: 'fridge',
        status: 'fresh',
      );

      final product2 = Product(
        id: '2',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: date,
        storageLocation: 'fridge',
        status: 'fresh',
      );

      expect(product1.id != product2.id, isTrue);
      expect(product1.name == product2.name, isTrue);
    });

    test('should handle long product names', () {
      final product = Product(
        id: '1',
        name: 'Very Long Product Name That Might Be Truncated In Some UIs But Should Be Stored Completely',
        category: 'Category',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      expect(product.name.length, greaterThan(50));
    });

    test('should handle special characters in product name', () {
      final product = Product(
        id: '1',
        name: 'Café & Thé (Spécial) - 100%',
        category: 'Boissons',
        expirationDate: DateTime.now(),
        storageLocation: 'pantry',
        status: 'fresh',
      );

      expect(product.name.contains('&'), isTrue);
      expect(product.name.contains('('), isTrue);
      expect(product.name.contains('%'), isTrue);
    });

    test('should handle emoji in product name', () {
      final product = Product(
        id: '1',
        name: '🥛 Lait Frais 🐄',
        category: 'Produits laitiers',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      expect(product.name.contains('🥛'), isTrue);
      expect(product.name.contains('🐄'), isTrue);
    });

    test('should create copyWith correctly', () {
      final original = Product(
        id: '1',
        name: 'Original',
        category: 'Category',
        expirationDate: DateTime(2024, 12, 31),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      final copied = original.copyWith(
        name: 'Updated',
        status: 'expiring',
      );

      expect(copied.id, original.id);
      expect(copied.name, 'Updated');
      expect(copied.category, original.category);
      expect(copied.status, 'expiring');
    });

    test('should maintain data integrity when copying', () {
      final original = Product(
        id: '123',
        name: 'Test',
        category: 'Test Category',
        expirationDate: DateTime(2024, 6, 15),
        storageLocation: 'freezer',
        status: 'fresh',
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.name, original.name);
      expect(copied.category, original.category);
      expect(copied.expirationDate, original.expirationDate);
      expect(copied.storageLocation, original.storageLocation);
      expect(copied.status, original.status);
    });
  });
}
