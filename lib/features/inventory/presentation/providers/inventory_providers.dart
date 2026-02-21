import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/data_sync/sync_providers.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../data/repositories/inventory_repository_impl.dart';

// ============================================================================
// REPOSITORY
// ============================================================================

/// Repository pour l'inventaire
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final inventoryBox = ref.watch(inventoryBoxProvider);
  final syncQueueManager = ref.watch(syncQueueManagerProvider);
  final userId = ref.watch(currentUserIdProvider) ?? '';
  return InventoryRepositoryImpl(
    inventoryBox: inventoryBox,
    syncQueueManager: syncQueueManager,
    userId: userId,
  );
});

// ============================================================================
// USE CASES
// ============================================================================

/// UseCase pour ajouter un produit
final addProductUseCaseProvider = Provider<AddProductUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return AddProductUseCase(repository);
});

/// UseCase pour mettre à jour un produit
final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return UpdateProductUseCase(repository);
});

/// UseCase pour supprimer un produit
final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return DeleteProductUseCase(repository);
});

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

/// Liste de produits (StateNotifier pour mutations locales)
/// Story 0.4: Injecte UseCases pour Clean Architecture
final inventoryListProvider =
    StateNotifierProvider<InventoryNotifier, List<Product>>((ref) {
      final repository = ref.watch(inventoryRepositoryProvider);
      final addUseCase = ref.watch(addProductUseCaseProvider);
      final updateUseCase = ref.watch(updateProductUseCaseProvider);
      final deleteUseCase = ref.watch(deleteProductUseCaseProvider);

      return InventoryNotifier(
        repository,
        addUseCase,
        updateUseCase,
        deleteUseCase,
      );
    });

/// Notifier pour gérer l'état de l'inventaire
/// Story 0.4: Utilise UseCases pour respecter Clean Architecture
class InventoryNotifier extends StateNotifier<List<Product>> {
  final InventoryRepository _repository;
  final AddProductUseCase _addProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  InventoryNotifier(
    this._repository,
    this._addProductUseCase,
    this._updateProductUseCase,
    this._deleteProductUseCase,
  ) : super([]) {
    _loadInitialData();
  }

  /// Charger données initiales depuis Hive (offline-first)
  Future<void> _loadInitialData() async {
    final products = await _repository.getAll();
    state = products;
  }

  /// Ajouter produit (optimistic UI + UseCase)
  Future<void> addProduct(Product product) async {
    // 1. Update local state immediately (optimistic)
    state = [...state, product];

    try {
      // 2. Execute UseCase (validation métier + write to repository)
      await _addProductUseCase.call(product);
    } catch (e) {
      // Rollback on error
      state = state.where((p) => p.id != product.id).toList();
      rethrow;
    }
  }

  /// Supprimer produit (optimistic UI + UseCase)
  Future<void> removeProduct(String productId) async {
    // Save previous state for rollback
    final previousState = state;

    // Optimistic update
    state = state.where((p) => p.id != productId).toList();

    try {
      // Execute UseCase
      await _deleteProductUseCase.call(productId);
    } catch (e) {
      // Rollback on error
      state = previousState;
      rethrow;
    }
  }

  /// Mettre à jour produit (optimistic UI + UseCase)
  Future<void> updateProduct(Product updated) async {
    // Save previous state for rollback
    final previousState = state;

    // Find and replace (immutable)
    state = [
      for (final product in state)
        if (product.id == updated.id) updated else product,
    ];

    try {
      // Execute UseCase
      await _updateProductUseCase.call(updated);
    } catch (e) {
      // Rollback on error
      state = previousState;
      rethrow;
    }
  }

  /// Rafraîchir les données depuis le repository
  Future<void> refresh() async {
    final products = await _repository.getAll();
    state = products;
  }
}

// ============================================================================
// UI STATE
// ============================================================================

/// ID du produit sélectionné (pour détails)
final selectedProductIdProvider = StateProvider<String?>((ref) => null);

/// Filtre actif sur la liste
final inventoryFilterProvider = StateProvider<ProductFilter>((ref) {
  return ProductFilter.all();
});

/// Liste filtrée (computed state)
final filteredProductsProvider = Provider.autoDispose<List<Product>>((ref) {
  final allProducts = ref.watch(inventoryListProvider);
  final filter = ref.watch(inventoryFilterProvider);
  return allProducts.where((p) => filter.matches(p)).toList();
});

/// Produit par ID (family provider)
final productByIdProvider = Provider.family<Product?, String>((ref, productId) {
  final products = ref.watch(inventoryListProvider);
  try {
    return products.firstWhere((p) => p.id == productId);
  } catch (e) {
    return null;
  }
});

/// Nombre total de produits
final productCountProvider = Provider<int>((ref) {
  return ref.watch(inventoryListProvider).length;
});

/// Produits par catégorie (groupés)
final productsByCategoryProvider = Provider<Map<String, List<Product>>>((ref) {
  final products = ref.watch(inventoryListProvider);
  final grouped = <String, List<Product>>{};

  for (final product in products) {
    if (!grouped.containsKey(product.category)) {
      grouped[product.category] = [];
    }
    grouped[product.category]!.add(product);
  }

  return grouped;
});

/// Produits expirant bientôt (dans les 3 prochains jours)
final expiringSoonProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(inventoryListProvider);
  final now = DateTime.now();
  final threshold = now.add(const Duration(days: 3));

  return products.where((p) {
    return p.expirationDate.isBefore(threshold) &&
        p.expirationDate.isAfter(now) &&
        p.status != 'consumed';
  }).toList();
});
