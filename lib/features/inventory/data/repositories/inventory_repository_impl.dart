import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../../../core/data_sync/models/sync_queue_item.dart';
import '../../../../core/data_sync/sync_collections.dart';
import '../../../../core/data_sync/sync_queue_manager.dart';
import '../../../../core/storage/models/product_model.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/inventory_repository.dart';

/// Implémentation du repository inventory avec sync offline-first
/// Story 0.4: Local-first avec Hive
/// Story 0.9 Phase 5: Sync bidirectionnel Hive ↔ Firestore
///
/// Architecture:
/// - Writes: Hive (local) + SyncQueue (for Firestore sync)
/// - Reads: Hive only (local-first)
/// - Bidirectional: Firestore listener → Hive updates
class InventoryRepositoryImpl implements InventoryRepository {
  final Box<ProductModel> _inventoryBox;
  final SyncQueueManager _syncQueueManager;
  final String _userId;

  final StreamController<List<Product>> _inventoryStreamController =
      StreamController<List<Product>>.broadcast();

  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  InventoryRepositoryImpl({
    required Box<ProductModel> inventoryBox,
    required SyncQueueManager syncQueueManager,
    required String userId,
  })  : _inventoryBox = inventoryBox,
        _syncQueueManager = syncQueueManager,
        _userId = userId {
    _initializeFirestoreListener();
    _emitCurrentState();
  }

  /// Initialize Firestore listener for bidirectional sync (Firestore → Hive)
  void _initializeFirestoreListener() {
    final collection = SyncCollections.userCollection(
      _userId,
      SyncCollections.inventoryItems,
    );

    _firestoreSubscription = FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .listen(
      (snapshot) async {
        if (kDebugMode) {
          debugPrint(
              '📥 InventoryRepository: Received ${snapshot.docChanges.length} changes from Firestore');
        }

        for (final change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null) continue;

          final productId = change.doc.id;

          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              // Update local Hive with remote changes
              final model = _firestoreDataToModel(productId, data);
              await _inventoryBox.put(productId, model);

              if (kDebugMode) {
                debugPrint(
                    '✅ InventoryRepository: Updated local product $productId from Firestore');
              }
              break;

            case DocumentChangeType.removed:
              // Delete from local Hive
              await _inventoryBox.delete(productId);

              if (kDebugMode) {
                debugPrint(
                    '🗑️ InventoryRepository: Deleted local product $productId (removed in Firestore)');
              }
              break;
          }
        }

        // Emit updated state
        _emitCurrentState();
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('❌ InventoryRepository: Firestore listener error: $error');
        }
      },
    );
  }

  /// Emit current Hive state to stream
  void _emitCurrentState() {
    final products =
        _inventoryBox.values.map(_modelToEntity).toList();
    _inventoryStreamController.add(products);
  }

  @override
  Future<List<Product>> getAll() async {
    final models = _inventoryBox.values.toList();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<Product?> getById(String id) async {
    final model = _inventoryBox.get(id);
    if (model == null) return null;
    return _modelToEntity(model);
  }

  @override
  Future<void> add(Product product) async {
    // 1. Write to Hive (local-first)
    final model = _entityToModel(product);
    await _inventoryBox.put(product.id, model);

    if (kDebugMode) {
      debugPrint('✅ InventoryRepository: Added product ${product.id} to Hive');
    }

    // 2. Enqueue for Firestore sync
    await _syncQueueManager.enqueue(
      operation: SyncOperation.create,
      collection: SyncCollections.userCollection(
        _userId,
        SyncCollections.inventoryItems,
      ),
      documentId: product.id,
      data: _modelToFirestoreData(model),
    );

    if (kDebugMode) {
      debugPrint('📤 InventoryRepository: Enqueued CREATE for ${product.id}');
    }

    // 3. Emit updated state
    _emitCurrentState();
  }

  @override
  Future<void> update(Product product) async {
    // 1. Write to Hive (local-first)
    final model = _entityToModel(product);
    await _inventoryBox.put(product.id, model);

    if (kDebugMode) {
      debugPrint('✅ InventoryRepository: Updated product ${product.id} in Hive');
    }

    // 2. Enqueue for Firestore sync
    await _syncQueueManager.enqueue(
      operation: SyncOperation.update,
      collection: SyncCollections.userCollection(
        _userId,
        SyncCollections.inventoryItems,
      ),
      documentId: product.id,
      data: _modelToFirestoreData(model),
    );

    if (kDebugMode) {
      debugPrint('📤 InventoryRepository: Enqueued UPDATE for ${product.id}');
    }

    // 3. Emit updated state
    _emitCurrentState();
  }

  @override
  Future<void> delete(String id) async {
    // 1. Delete from Hive (local-first)
    await _inventoryBox.delete(id);

    if (kDebugMode) {
      debugPrint('✅ InventoryRepository: Deleted product $id from Hive');
    }

    // 2. Enqueue for Firestore sync
    await _syncQueueManager.enqueue(
      operation: SyncOperation.delete,
      collection: SyncCollections.userCollection(
        _userId,
        SyncCollections.inventoryItems,
      ),
      documentId: id,
      data: {}, // Empty data for delete operations
    );

    if (kDebugMode) {
      debugPrint('📤 InventoryRepository: Enqueued DELETE for $id');
    }

    // 3. Emit updated state
    _emitCurrentState();
  }

  @override
  Stream<List<Product>> watchAll() {
    // Return broadcast stream that emits whenever Hive or Firestore changes
    return _inventoryStreamController.stream;
  }

  /// Convert ProductModel (data layer) to Product entity (domain layer)
  Product _modelToEntity(ProductModel model) {
    return Product(
      id: model.id,
      name: model.name,
      category: model.category,
      expirationDate: model.expirationDate,
      storageLocation: model.storageLocation,
      status: model.status,
      addedAt: model.addedAt,
      barcode: model.barcode,
      photoUrl: model.photoUrl,
    );
  }

  /// Convert Product entity (domain layer) to ProductModel (data layer)
  ProductModel _entityToModel(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      expirationDate: entity.expirationDate,
      storageLocation: entity.storageLocation,
      status: entity.status,
      addedAt: entity.addedAt,
      barcode: entity.barcode,
      photoUrl: entity.photoUrl,
    );
  }

  /// Convert ProductModel to Firestore data (with version and updatedAt)
  Map<String, dynamic> _modelToFirestoreData(ProductModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'category': model.category,
      'expirationDate': Timestamp.fromDate(model.expirationDate),
      'storageLocation': model.storageLocation,
      'status': model.status,
      'addedAt': model.addedAt != null
          ? Timestamp.fromDate(model.addedAt!)
          : FieldValue.serverTimestamp(),
      if (model.barcode != null) 'barcode': model.barcode,
      if (model.photoUrl != null) 'photoUrl': model.photoUrl,
      'version': 1, // Initial version (will be incremented by ConflictResolver)
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert Firestore data to ProductModel
  ProductModel _firestoreDataToModel(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProductModel(
      id: id,
      name: data['name'] as String,
      category: data['category'] as String,
      expirationDate: (data['expirationDate'] as Timestamp).toDate(),
      storageLocation: data['storageLocation'] as String? ?? 'fridge',
      status: data['status'] as String? ?? 'fresh',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
      barcode: data['barcode'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  /// Dispose resources
  void dispose() {
    _firestoreSubscription?.cancel();
    _inventoryStreamController.close();

    if (kDebugMode) {
      debugPrint('🔄 InventoryRepository disposed');
    }
  }
}
