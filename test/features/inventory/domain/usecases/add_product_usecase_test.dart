import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/inventory/domain/entities/product.dart';
import 'package:frigofute_v2/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:frigofute_v2/features/inventory/domain/repositories/inventory_repository.dart';

// Mock repository simple
class MockInventoryRepository implements InventoryRepository {
  final List<Product> _products = [];

  @override
  Future<void> add(Product product) async {
    _products.add(product);
  }

  @override
  Future<void> delete(String id) async {
    _products.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<Product>> getAll() async {
    return _products;
  }

  @override
  Future<Product?> getById(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> update(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  @override
  Stream<List<Product>> watchAll() {
    return Stream.value(_products);
  }
}

void main() {
  group('AddProductUseCase - Story 0.4', () {
    late MockInventoryRepository mockRepository;
    late AddProductUseCase useCase;

    setUp(() {
      mockRepository = MockInventoryRepository();
      useCase = AddProductUseCase(mockRepository);
    });

    test('should add valid product successfully', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: DateTime.now().add(const Duration(days: 7)),
        storageLocation: 'fridge',
        status: 'fresh',
      );

      // Act
      await useCase.call(product);

      // Assert
      final products = await mockRepository.getAll();
      expect(products.length, 1);
      expect(products.first.name, 'Lait');
    });

    test('should throw exception for empty product name', () async {
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

    test('should trim whitespace in validation', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: '   ',
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
  });
}
