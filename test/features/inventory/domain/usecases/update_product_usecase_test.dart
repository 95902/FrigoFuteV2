import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/inventory/domain/entities/product.dart';
import 'package:frigofute_v2/features/inventory/domain/usecases/update_product_usecase.dart';
import 'add_product_usecase_test.dart'; // Import MockInventoryRepository

void main() {
  group('UpdateProductUseCase', () {
    late MockInventoryRepository mockRepository;
    late UpdateProductUseCase useCase;

    setUp(() {
      mockRepository = MockInventoryRepository();
      useCase = UpdateProductUseCase(mockRepository);
    });

    test('should update existing product successfully', () async {
      // Arrange: Add initial product
      final initialProduct = Product(
        id: '1',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: DateTime(2024, 12, 31),
        storageLocation: 'fridge',
        status: 'fresh',
      );
      await mockRepository.add(initialProduct);

      // Act: Update product
      final updatedProduct = Product(
        id: '1',
        name: 'Lait Bio',
        category: 'Produits laitiers',
        expirationDate: DateTime(2024, 12, 31),
        storageLocation: 'fridge',
        status: 'fresh',
      );
      await useCase.call(updatedProduct);

      // Assert
      final result = await mockRepository.getById('1');
      expect(result, isNotNull);
      expect(result!.name, 'Lait Bio');
    });

    test('should throw exception for empty name', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: '',
        category: 'Produits laitiers',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      // Act & Assert
      expect(
        () => useCase.call(product),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception for empty category', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Lait',
        category: '',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      // Act & Assert
      expect(
        () => useCase.call(product),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception for non-existent product', () async {
      // Arrange: Product not in repository
      final product = Product(
        id: 'non-existent',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      // Act & Assert
      expect(
        () => useCase.call(product),
        throwsA(isA<Exception>()),
      );
    });

    test('should update product status', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
        storageLocation: 'fridge',
        status: 'fresh',
      );
      await mockRepository.add(product);

      // Act: Update to expired
      final expiredProduct = Product(
        id: '1',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
        storageLocation: 'fridge',
        status: 'expired',
      );
      await useCase.call(expiredProduct);

      // Assert
      final result = await mockRepository.getById('1');
      expect(result!.status, 'expired');
    });

    test('should update storage location', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Chocolat',
        category: 'Snacks',
        expirationDate: DateTime.now().add(const Duration(days: 30)),
        storageLocation: 'fridge',
        status: 'fresh',
      );
      await mockRepository.add(product);

      // Act: Move to pantry
      final movedProduct = Product(
        id: '1',
        name: 'Chocolat',
        category: 'Snacks',
        expirationDate: DateTime.now().add(const Duration(days: 30)),
        storageLocation: 'pantry',
        status: 'fresh',
      );
      await useCase.call(movedProduct);

      // Assert
      final result = await mockRepository.getById('1');
      expect(result!.storageLocation, 'pantry');
    });

    test('should handle whitespace-only name', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: '   ',
        category: 'Category',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      // Act & Assert
      expect(
        () => useCase.call(product),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle whitespace-only category', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Product',
        category: '   ',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      // Act & Assert
      expect(
        () => useCase.call(product),
        throwsA(isA<Exception>()),
      );
    });
  });
}
