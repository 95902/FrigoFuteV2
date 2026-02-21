import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/inventory/domain/entities/product.dart';
import 'package:frigofute_v2/features/inventory/domain/entities/product_filter.dart';

void main() {
  group('ProductFilter Tests', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: '1',
        name: 'Lait',
        category: 'Produits laitiers',
        expirationDate: DateTime.now().add(const Duration(days: 7)),
        storageLocation: 'fridge',
        status: 'fresh',
      );
    });

    group('Factory constructors', () {
      test('all() should create empty filter', () {
        final filter = ProductFilter.all();

        expect(filter.category, isNull);
        expect(filter.storageLocation, isNull);
        expect(filter.status, isNull);
        expect(filter.searchQuery, isNull);
      });

      test('category() should create category filter', () {
        final filter = ProductFilter.category('Produits laitiers');

        expect(filter.category, 'Produits laitiers');
        expect(filter.storageLocation, isNull);
        expect(filter.status, isNull);
        expect(filter.searchQuery, isNull);
      });

      test('storage() should create storage filter', () {
        final filter = ProductFilter.storage('fridge');

        expect(filter.storageLocation, 'fridge');
        expect(filter.category, isNull);
        expect(filter.status, isNull);
        expect(filter.searchQuery, isNull);
      });

      test('status() should create status filter', () {
        final filter = ProductFilter.status('fresh');

        expect(filter.status, 'fresh');
        expect(filter.category, isNull);
        expect(filter.storageLocation, isNull);
        expect(filter.searchQuery, isNull);
      });
    });

    group('matches - single criteria', () {
      test('all() filter should match any product', () {
        final filter = ProductFilter.all();

        expect(filter.matches(testProduct), true);
      });

      test('should match product by category', () {
        final filter = ProductFilter.category('Produits laitiers');

        expect(filter.matches(testProduct), true);
      });

      test('should not match product with different category', () {
        final filter = ProductFilter.category('Viandes');

        expect(filter.matches(testProduct), false);
      });

      test('should match product by storage location', () {
        final filter = ProductFilter.storage('fridge');

        expect(filter.matches(testProduct), true);
      });

      test('should not match product with different storage', () {
        final filter = ProductFilter.storage('freezer');

        expect(filter.matches(testProduct), false);
      });

      test('should match product by status', () {
        final filter = ProductFilter.status('fresh');

        expect(filter.matches(testProduct), true);
      });

      test('should not match product with different status', () {
        final filter = ProductFilter.status('expired');

        expect(filter.matches(testProduct), false);
      });
    });

    group('matches - search query', () {
      test('should match product by name (exact)', () {
        const filter = ProductFilter(searchQuery: 'Lait');

        expect(filter.matches(testProduct), true);
      });

      test('should match product by name (partial)', () {
        const filter = ProductFilter(searchQuery: 'Lai');

        expect(filter.matches(testProduct), true);
      });

      test('should match product by name (case insensitive)', () {
        const filter = ProductFilter(searchQuery: 'lait');

        expect(filter.matches(testProduct), true);
      });

      test('should match product by category search', () {
        const filter = ProductFilter(searchQuery: 'laitiers');

        expect(filter.matches(testProduct), true);
      });

      test('should not match product with unrelated query', () {
        const filter = ProductFilter(searchQuery: 'viande');

        expect(filter.matches(testProduct), false);
      });

      test('should match with empty search query', () {
        const filter = ProductFilter(searchQuery: '');

        expect(filter.matches(testProduct), true);
      });

      test('should handle special characters in search', () {
        final product = Product(
          id: '2',
          name: 'Café & Thé',
          category: 'Boissons',
          expirationDate: DateTime.now(),
          storageLocation: 'pantry',
          status: 'fresh',
        );

        const filter = ProductFilter(searchQuery: '&');

        expect(filter.matches(product), true);
      });
    });

    group('matches - multiple criteria', () {
      test('should match product with all criteria', () {
        const filter = ProductFilter(
          category: 'Produits laitiers',
          storageLocation: 'fridge',
          status: 'fresh',
        );

        expect(filter.matches(testProduct), true);
      });

      test('should not match if one criterion fails', () {
        const filter = ProductFilter(
          category: 'Produits laitiers',
          storageLocation: 'freezer', // Wrong storage
          status: 'fresh',
        );

        expect(filter.matches(testProduct), false);
      });

      test('should combine category and search query', () {
        const filter = ProductFilter(
          category: 'Produits laitiers',
          searchQuery: 'Lait',
        );

        expect(filter.matches(testProduct), true);
      });

      test('should fail if search matches but category doesnt', () {
        const filter = ProductFilter(
          category: 'Viandes',
          searchQuery: 'Lait',
        );

        expect(filter.matches(testProduct), false);
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final original = ProductFilter.category('Test');
        final copy = original.copyWith();

        expect(copy.category, original.category);
        expect(copy.storageLocation, original.storageLocation);
        expect(copy.status, original.status);
        expect(copy.searchQuery, original.searchQuery);
      });

      test('should update category', () {
        final original = ProductFilter.category('Old');
        final updated = original.copyWith(category: 'New');

        expect(updated.category, 'New');
      });

      test('should update storageLocation', () {
        final original = ProductFilter.storage('fridge');
        final updated = original.copyWith(storageLocation: 'freezer');

        expect(updated.storageLocation, 'freezer');
      });

      test('should update status', () {
        final original = ProductFilter.status('fresh');
        final updated = original.copyWith(status: 'expired');

        expect(updated.status, 'expired');
      });

      test('should update searchQuery', () {
        const original = ProductFilter(searchQuery: 'old');
        final updated = original.copyWith(searchQuery: 'new');

        expect(updated.searchQuery, 'new');
      });

      test('should update multiple fields', () {
        final original = ProductFilter.all();
        final updated = original.copyWith(
          category: 'Category',
          storageLocation: 'Storage',
          status: 'Status',
          searchQuery: 'Query',
        );

        expect(updated.category, 'Category');
        expect(updated.storageLocation, 'Storage');
        expect(updated.status, 'Status');
        expect(updated.searchQuery, 'Query');
      });
    });

    group('Edge cases', () {
      test('should handle null values', () {
        const filter = ProductFilter(
          category: null,
          storageLocation: null,
          status: null,
          searchQuery: null,
        );

        expect(filter.matches(testProduct), true);
      });

      test('should handle product with minimal data', () {
        final product = Product(
          id: '1',
          name: 'Test',
          category: 'Cat',
          expirationDate: DateTime.now(),
          storageLocation: 'loc',
          status: 'stat',
        );

        final filter = ProductFilter.all();

        expect(filter.matches(product), true);
      });

      test('should handle Unicode in search', () {
        final product = Product(
          id: '1',
          name: 'Café français',
          category: 'Boissons',
          expirationDate: DateTime.now(),
          storageLocation: 'pantry',
          status: 'fresh',
        );

        const filter = ProductFilter(searchQuery: 'français');

        expect(filter.matches(product), true);
      });

      test('should handle emoji in search', () {
        final product = Product(
          id: '1',
          name: 'Lait 🥛',
          category: 'Dairy',
          expirationDate: DateTime.now(),
          storageLocation: 'fridge',
          status: 'fresh',
        );

        const filter = ProductFilter(searchQuery: '🥛');

        expect(filter.matches(product), true);
      });
    });
  });
}
