import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/data_sync/sync_providers.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/storage/models/product_model.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../repositories/inventory_repository_impl.dart';

/// Inventory repository provider with sync integration
/// Story 0.9 Phase 5: Repository Integration
///
/// Provides InventoryRepository with:
/// - Hive box for local storage
/// - SyncQueueManager for offline-first sync
/// - User ID from auth state
///
/// Example:
/// ```dart
/// final repository = ref.read(inventoryRepositoryProvider);
/// await repository.add(product); // Writes to Hive + enqueues for sync
/// ```
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  // Get Hive box
  final inventoryBox = Hive.box<ProductModel>(HiveService.inventoryBoxName);

  // Get sync queue manager
  final syncQueueManager = ref.watch(syncQueueManagerProvider);

  // Get current user ID from auth state
  final authState = ref.watch(authStateProvider);
  final userId = authState.maybeWhen(
    data: (user) => user?.uid ?? 'anonymous',
    orElse: () => 'anonymous',
  );

  final repository = InventoryRepositoryImpl(
    inventoryBox: inventoryBox,
    syncQueueManager: syncQueueManager,
    userId: userId,
  );

  // Dispose repository when provider is disposed
  ref.onDispose(() => repository.dispose());

  return repository;
});
