import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/inventory/domain/entities/product.dart';
import 'package:frigofute_v2/features/inventory/domain/usecases/delete_product_usecase.dart';
import 'add_product_usecase_test.dart'; // Import MockInventoryRepository

void main() {
  group('DeleteProductUseCase', () {
    late MockInventoryRepository mockRepository;
    late DeleteProductUseCase useCase;

    setUp(() {
      mockRepository = MockInventoryRepository();
      useCase = DeleteProductUseCase(mockRepository);
    });

    test('should delete existing product successfully', () async {
      // Arrange: Add product first
      final product = Product(
        id: '1',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );
      await mockRepository.add(product);

      // Verify product exists
      var allProducts = await mockRepository.getAll();
      expect(allProducts.length, 1);

      // Act: Delete product
      await useCase.call('1');

      // Assert: Product no longer exists
      allProducts = await mockRepository.getAll();
      expect(allProducts.length, 0);
    });

    test('should throw exception for empty ID', () async {
      // Act & Assert
      expect(
        () => useCase.call(''),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception for whitespace-only ID', () async {
      // Act & Assert
      expect(
        () => useCase.call('   '),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception for non-existent product ID', () async {
      // Act & Assert
      expect(
        () => useCase.call('non-existent-id'),
        throwsA(isA<Exception>()),
      );
    });

    test('should verify product exists before deletion', () async {
      // Arrange: Repository is empty
      // Act & Assert
      expect(
        () => useCase.call('123'),
        throwsA(isA<Exception>()),
      );
    });

    test('should delete correct product when multiple exist', () async {
      // Arrange: Add multiple products
      final product1 = Product(
        id: '1',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );
      final product2 = Product(
        id: '2',
        name: 'Pain',
        category: 'Boulangerie',
        expirationDate: DateTime.now(),
        storageLocation: 'pantry',
        status: 'fresh',
      );
      final product3 = Product(
        id: '3',
        name: 'Fromage',
        category: 'Produits laitiers',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      await mockRepository.add(product1);
      await mockRepository.add(product2);
      await mockRepository.add(product3);

      // Act: Delete middle product
      await useCase.call('2');

      // Assert: Only product 2 is deleted
      final allProducts = await mockRepository.getAll();
      expect(allProducts.length, 2);
      expect(allProducts.any((p) => p.id == '1'), isTrue);
      expect(allProducts.any((p) => p.id == '2'), isFalse);
      expect(allProducts.any((p) => p.id == '3'), isTrue);
    });

    test('should handle deletion of last product', () async {
      // Arrange: Add single product
      final product = Product(
        id: 'last-one',
        name: 'Last Product',
        category: 'Category',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );
      await mockRepository.add(product);

      // Act
      await useCase.call('last-one');

      // Assert: Repository is empty
      final allProducts = await mockRepository.getAll();
      expect(allProducts, isEmpty);
    });

    test('should handle special characters in ID', () async {
      // Arrange
      final product = Product(
        id: 'product-123-abc_def',
        name: 'Special ID Product',
        category: 'Category',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );
      await mockRepository.add(product);

      // Act
      await useCase.call('product-123-abc_def');

      // Assert
      final allProducts = await mockRepository.getAll();
      expect(allProducts, isEmpty);
    });

    test('should handle UUID-style IDs', () async {
      // Arrange
      final product = Product(
        id: '550e8400-e29b-41d4-a716-446655440000',
        name: 'UUID Product',
        category: 'Category',
        expirationDate: DateTime.now(),
        storageLocation: 'fridge',
        status: 'fresh',
      );
      await mockRepository.add(product);

      // Act
      await useCase.call('550e8400-e29b-41d4-a716-446655440000');

      // Assert
      final result = await mockRepository.getById('550e8400-e29b-41d4-a716-446655440000');
      expect(result, isNull);
    });
  });
}
