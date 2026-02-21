# Story 2.3: Delete Product from Inventory

## 📋 Story Metadata

- **Story ID**: 2.3
- **Epic**: Epic 2 - Inventory Management
- **Title**: Delete Product from Inventory
- **Story Key**: 2-3-delete-product-from-inventory
- **Status**: ready-for-dev
- **Complexity**: 4 (S-M — CRUD delete + undo pattern + Dismissible gesture)
- **Priority**: P1 (Core inventory management)
- **Estimated Effort**: 1-2 days
- **Dependencies**:
  - Story 2.1 (**REQUIS** — `ProductEntity`, `ProductModel`, `InventoryRepository`, `InventoryLocalDatasource`, `inventoryListProvider`)
  - Story 2.2 (`InventoryRepositoryImpl` avec `updateProduct` — patterns établis)
  - Story 0.9 (SyncService — `queueOperation('DELETE', ...)`)
  - Story 0.7 (AnalyticsService — event `product_deleted`)
- **Tags**: `inventory`, `hive`, `firestore`, `offline-first`, `delete`, `undo`, `dismissible`

---

## 📖 User Story

**As a** Lucas (étudiant),
**I want** to remove products I threw away or that are no longer in my inventory,
**So that** my inventory stays clean and accurate.

---

## ✅ Acceptance Criteria

### AC1: Swipe-to-Delete Gesture
**Given** I have products in my inventory list
**When** I swipe left on a product card
**Then** a red delete background with a trash icon appears
**And** releasing the swipe triggers the delete flow (no separate confirmation dialog for swipe — gesture is intentional)

### AC2: Delete from Product Detail / Context Menu
**Given** I am on the product detail screen or a long-press context menu
**When** I tap "Supprimer le produit"
**Then** a confirmation dialog appears: "Supprimer ce produit ?" with "Annuler" and "Supprimer" buttons
**And** tapping "Supprimer" triggers the delete flow
**And** tapping "Annuler" closes the dialog without deleting

### AC3: Optimistic Delete (Immediate Feedback)
**Given** I confirm deletion (via swipe or dialog)
**When** the delete action fires
**Then** the product disappears from the inventory list immediately (Hive-first)
**And** I see a Snackbar: "Produit supprimé" with an "Annuler" action button

### AC4: Undo Within 5 Seconds
**Given** I deleted a product and the Snackbar is visible
**When** I tap "Annuler" within 5 seconds
**Then** the product is restored to the inventory list immediately
**And** the pending Firestore delete operation is cancelled from the sync queue
**And** no Firestore delete is ever sent

### AC5: Permanent Delete After Undo Window
**Given** I deleted a product and did NOT tap "Annuler" within 5 seconds
**When** the 5-second window expires
**Then** the product is permanently removed from Hive storage
**And** a `'DELETE'` operation is queued to the SyncService for Firestore

### AC6: Offline Delete Support
**Given** I have no internet connection
**When** I delete a product
**Then** the product is removed from Hive immediately
**And** the `'DELETE'` operation is queued in the sync queue
**And** when connectivity resumes, the deletion syncs to Firestore automatically

### AC7: Analytics Event
**Given** I permanently delete a product (undo window expired)
**When** the Hive delete completes
**Then** the analytics event `product_deleted` is fired with parameters: `category`, `days_in_inventory: int`

---

## 🏗️ Technical Specifications

### 1. Undo Delete Pattern — Architecture Decision

Le pattern d'annulation utilise une **suppression différée** :

```
User swipes → Product hidden from UI (Hive record kept, marked pending_delete)
             → Snackbar 5s shown
                  ↓ Undo tapped               ↓ Timer expires
             Restore to UI               Hive.delete(id) + SyncService.queue('DELETE')
             Cancel sync op              Analytics event fired
```

**Implémentation** : Utiliser un `Timer` de 5 secondes dans le Notifier. Pendant la fenêtre, le produit est filtré de la liste mais reste dans Hive (marqué `isSyncPending: true` avec flag temporaire dans le state Riverpod).

> **Alternative rejetée** : Soft-delete field (`isDeleted: true`) dans Hive — ajoute de la complexité au modèle et aux queries. Préférer le state Riverpod pour gérer la fenêtre d'annulation.

---

### 2. Domain Layer Extension

#### Mise à jour interface — `lib/features/inventory/domain/repositories/inventory_repository.dart`

Ajouter :
```dart
/// Delete a product permanently from local and remote storage.
/// The undo window is managed at the presentation layer.
Future<Either<AppException, Unit>> deleteProduct(String productId, String userId);

/// Restore a product that was pending deletion (undo action).
/// No-op if product was already permanently deleted.
Future<Either<AppException, Unit>> restoreProduct(ProductEntity product);
```

#### Use Case — `lib/features/inventory/domain/usecases/delete_product_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../repositories/inventory_repository.dart';

class DeleteProductUseCase {
  final InventoryRepository _repository;

  DeleteProductUseCase(this._repository);

  Future<Either<AppException, Unit>> call(String productId, String userId) async {
    if (productId.isEmpty) {
      return Left(ValidationException('ID produit invalide', {'id': 'required'}));
    }
    return _repository.deleteProduct(productId, userId);
  }
}
```

#### Use Case Restore — `lib/features/inventory/domain/usecases/restore_product_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class RestoreProductUseCase {
  final InventoryRepository _repository;

  RestoreProductUseCase(this._repository);

  Future<Either<AppException, Unit>> call(ProductEntity product) async {
    return _repository.restoreProduct(product);
  }
}
```

---

### 3. Repository Implementation

Ajouter dans `lib/features/inventory/data/repositories/inventory_repository_impl.dart` :

```dart
@override
Future<Either<AppException, Unit>> deleteProduct(
    String productId, String userId) async {
  try {
    // 1. Delete from Hive
    await _local.deleteProduct(productId);

    // 2. Queue DELETE operation for Firestore sync
    await _syncService.queueOperation(
      operationType: 'DELETE',
      collection: 'inventory_items',
      documentId: productId,
      userId: userId,
      data: {'id': productId},  // minimal payload for delete
    );

    return const Right(unit);
  } on HiveException catch (e) {
    return Left(AppException(
        'Erreur suppression locale: ${e.message}', 'STORAGE_ERROR', e));
  } catch (e) {
    return Left(AppException('Erreur inattendue: $e', 'UNKNOWN_ERROR', e));
  }
}

@override
Future<Either<AppException, Unit>> restoreProduct(ProductEntity product) async {
  try {
    // Re-save product to Hive (restore from pending delete state)
    final model = _toModel(product.copyWith(isSyncPending: false));
    await _local.saveProduct(model);
    return const Right(unit);
  } catch (e) {
    return Left(AppException('Erreur restauration: $e', 'RESTORE_ERROR', e));
  }
}
```

#### Local Datasource — ajouter dans `InventoryLocalDatasource`

```dart
Future<void> deleteProduct(String productId) async {
  await _box.delete(productId);
}
```

---

### 4. Inventory Notifier avec Undo Pattern

#### `lib/features/inventory/presentation/providers/inventory_notifier.dart`

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/restore_product_usecase.dart';
import '../../../../core/monitoring/analytics_service.dart';

/// Tracks products currently in the 5-second undo window
class InventoryNotifier extends StateNotifier<Set<String>> {
  final DeleteProductUseCase _deleteUseCase;
  final RestoreProductUseCase _restoreUseCase;
  final AnalyticsService _analytics;

  /// Map of productId → Timer (for cancellation on undo)
  final Map<String, Timer> _pendingDeleteTimers = {};
  /// Map of productId → ProductEntity (for restore on undo)
  final Map<String, ProductEntity> _pendingDeleteProducts = {};

  InventoryNotifier(
    this._deleteUseCase,
    this._restoreUseCase,
    this._analytics,
  ) : super({});

  /// Initiates delete with 5-second undo window.
  /// Returns the product for the Snackbar undo callback.
  ProductEntity initiateDelete(ProductEntity product) {
    // Add to pending set (hides from UI via provider filter)
    state = {...state, product.id};

    // Schedule permanent delete after 5 seconds
    _pendingDeleteTimers[product.id] = Timer(
      const Duration(seconds: 5),
      () => _permanentlyDelete(product),
    );
    _pendingDeleteProducts[product.id] = product;

    return product;
  }

  /// Called when user taps "Annuler" in Snackbar
  Future<void> undoDelete(String productId) async {
    // Cancel the pending timer
    _pendingDeleteTimers[productId]?.cancel();
    _pendingDeleteTimers.remove(productId);

    final product = _pendingDeleteProducts.remove(productId);

    // Remove from pending set (restores to UI)
    state = state.where((id) => id != productId).toSet();

    // Restore to Hive (it was never deleted — just hidden)
    if (product != null) {
      await _restoreUseCase.call(product);
    }
  }

  /// Called after 5-second window expires
  Future<void> _permanentlyDelete(ProductEntity product) async {
    _pendingDeleteTimers.remove(product.id);
    _pendingDeleteProducts.remove(product.id);
    state = state.where((id) => id != product.id).toSet();

    // Now actually delete from Hive + queue Firestore DELETE
    final result = await _deleteUseCase.call(product.id, product.userId);

    result.fold(
      (error) {
        // If delete failed, product stays in pending — could notify user
        // For now, silent failure (offline scenarios handled by SyncService)
      },
      (_) {
        // Fire analytics only after permanent delete
        final daysInInventory =
            DateTime.now().difference(product.addedDate).inDays;
        _analytics.logEvent(
          name: 'product_deleted',
          parameters: {
            'category': product.category.name,
            'days_in_inventory': daysInInventory,
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Cancel all pending timers on dispose
    for (final timer in _pendingDeleteTimers.values) {
      timer.cancel();
    }
    _pendingDeleteTimers.clear();
    super.dispose();
  }
}
```

---

### 5. Updated Providers

Ajouter dans `lib/features/inventory/presentation/providers/inventory_providers.dart` :

```dart
final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>(
  (ref) => DeleteProductUseCase(ref.read(inventoryRepositoryProvider)),
);

final restoreProductUseCaseProvider = Provider<RestoreProductUseCase>(
  (ref) => RestoreProductUseCase(ref.read(inventoryRepositoryProvider)),
);

/// Tracks product IDs currently in the undo window (hidden from list)
final inventoryNotifierProvider =
    StateNotifierProvider<InventoryNotifier, Set<String>>(
  (ref) => InventoryNotifier(
    ref.read(deleteProductUseCaseProvider),
    ref.read(restoreProductUseCaseProvider),
    ref.read(analyticsServiceProvider),
  ),
);

/// Filtered inventory list — excludes products pending deletion
final filteredInventoryProvider = Provider<AsyncValue<List<ProductEntity>>>((ref) {
  final allProducts = ref.watch(inventoryListProvider);
  final pendingDeletionIds = ref.watch(inventoryNotifierProvider);

  return allProducts.whenData(
    (products) => products
        .where((p) => !pendingDeletionIds.contains(p.id))
        .toList(),
  );
});
```

> **IMPORTANT**: Les écrans d'inventaire doivent utiliser `filteredInventoryProvider` (pas `inventoryListProvider` directement) pour que les produits en cours de suppression disparaissent de l'UI.

---

### 6. UI — Swipe-to-Delete dans la liste

#### Pattern `Dismissible` — `lib/features/inventory/presentation/widgets/product_card_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/inventory_providers.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,  // swipe left only
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Supprimer',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        // No confirmation dialog for swipe (gesture is intentional — AC1)
        return true;
      },
      onDismissed: (_) => _handleDelete(context, ref),
      child: _ProductCardContent(product: product),
    );
  }

  void _handleDelete(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(inventoryNotifierProvider.notifier);
    notifier.initiateDelete(product);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${product.name}" supprimé'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () =>
                ref.read(inventoryNotifierProvider.notifier).undoDelete(product.id),
          ),
        ),
      );
  }
}

class _ProductCardContent extends StatelessWidget {
  final ProductEntity product;
  const _ProductCardContent({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Product display content (to be expanded in Story 2.5+)
      title: Text(product.name),
      subtitle: Text(_formatSubtitle()),
      leading: _StatusBadge(status: product.status),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  String _formatSubtitle() {
    final parts = <String>[
      '${product.quantity} ${product.unit}',
      _locationShort(product.location),
    ];
    if (product.expirationDate != null) {
      final days = product.expirationDate!.difference(DateTime.now()).inDays;
      if (days < 0) parts.add('Expiré');
      else if (days == 0) parts.add("Expire aujourd'hui");
      else parts.add('Expire dans $days j.');
    }
    return parts.join(' · ');
  }

  String _locationShort(StorageLocation loc) {
    const short = {
      StorageLocation.refrigerateur: 'Frigo',
      StorageLocation.congelateur: 'Congélo',
      StorageLocation.placard: 'Placard',
      StorageLocation.gardeManger: 'Garde-manger',
      StorageLocation.comptoir: 'Comptoir',
      StorageLocation.autre: 'Autre',
    };
    return short[loc] ?? loc.name;
  }
}

class _StatusBadge extends StatelessWidget {
  final ProductStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      ProductStatus.fresh        => (Colors.green, Icons.check_circle),
      ProductStatus.expiringSoon => (Colors.orange, Icons.warning_amber),
      ProductStatus.expired      => (Colors.red, Icons.cancel),
      ProductStatus.consumed     => (Colors.grey, Icons.done_all),
    };
    return Icon(icon, color: color, size: 28);
  }
}
```

#### Dialog de confirmation (depuis ProductDetail) — `lib/features/inventory/presentation/widgets/delete_confirmation_dialog.dart`

```dart
import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String productName;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.productName,
    required this.onConfirm,
  });

  static Future<bool?> show(BuildContext context, String productName) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le produit ?'),
        content: Text(
          '"$productName" sera définitivement supprimé de votre inventaire.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx, true);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

**Usage depuis `ProductDetailScreen`** :

```dart
final confirmed = await DeleteConfirmationDialog.show(context, product.name);
if (confirmed == true && mounted) {
  ref.read(inventoryNotifierProvider.notifier).initiateDelete(product);
  // Show Snackbar with undo
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('"${product.name}" supprimé'),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Annuler',
        onPressed: () =>
          ref.read(inventoryNotifierProvider.notifier).undoDelete(product.id),
      ),
    ),
  );
  Navigator.of(context).pop();  // Fermer le detail screen
}
```

---

## 📝 Implementation Tasks

### Phase 1 : Domain Layer (Jour 1)

- [ ] **T1.1** : Ajouter `deleteProduct(String id, String userId)` + `restoreProduct(ProductEntity)` à l'interface `InventoryRepository`
- [ ] **T1.2** : Créer `DeleteProductUseCase`
- [ ] **T1.3** : Créer `RestoreProductUseCase`
- [ ] **T1.4** : Tests unitaires `DeleteProductUseCase` — ID vide, succès

### Phase 2 : Data Layer (Jour 1)

- [ ] **T2.1** : Ajouter `deleteProduct(String id)` dans `InventoryLocalDatasource` (`_box.delete(id)`)
- [ ] **T2.2** : Implémenter `deleteProduct()` dans `InventoryRepositoryImpl` (Hive delete + SyncService `'DELETE'`)
- [ ] **T2.3** : Implémenter `restoreProduct()` dans `InventoryRepositoryImpl` (re-save to Hive)
- [ ] **T2.4** : Tests unitaires repository — delete, restore, queue DELETE operation

### Phase 3 : State Management (Jour 1)

- [ ] **T3.1** : Créer `InventoryNotifier` (StateNotifier<Set<String>>) avec `initiateDelete()`, `undoDelete()`, Timer 5s, `_permanentlyDelete()`
- [ ] **T3.2** : Ajouter `deleteProductUseCaseProvider`, `restoreProductUseCaseProvider`, `inventoryNotifierProvider`, `filteredInventoryProvider`
- [ ] **T3.3** : Tests unitaires `InventoryNotifier` — undo avant 5s, permanentDelete après 5s, timer annulé sur undo
- [ ] **T3.4** : **Mettre à jour tous les widgets de la liste d'inventaire pour utiliser `filteredInventoryProvider`** (pas `inventoryListProvider` directement)

### Phase 4 : UI (Jour 1-2)

- [ ] **T4.1** : Créer/mettre à jour `ProductCard` avec `Dismissible` (swipe gauche, fond rouge, icône poubelle)
- [ ] **T4.2** : Implémenter Snackbar avec action "Annuler" (5 secondes)
- [ ] **T4.3** : Créer `DeleteConfirmationDialog` pour suppression depuis ProductDetail
- [ ] **T4.4** : Intégrer le bouton "Supprimer" dans `ProductDetailScreen` avec dialog + Snackbar
- [ ] **T4.5** : Tests widget `ProductCard` — swipe déclenche delete flow

### Phase 5 : Tests & Couverture (Jour 2)

- [ ] **T5.1** : Couverture ≥ 75% sur tous les nouveaux fichiers
- [ ] **T5.2** : Test intégration — swipe → undo → produit restauré dans la liste
- [ ] **T5.3** : Test intégration — swipe → attendre 5s → produit absent + SyncService appelé
- [ ] **T5.4** : `flutter analyze` 0 erreurs

---

## 🧪 Testing Strategy

### Unit Tests — InventoryNotifier

```dart
group('InventoryNotifier', () {
  test('initiateDelete adds productId to pending set', () {
    notifier.initiateDelete(mockProduct);
    expect(state, contains(mockProduct.id));
  });

  test('undoDelete removes productId from pending set', () async {
    notifier.initiateDelete(mockProduct);
    await notifier.undoDelete(mockProduct.id);
    expect(state, isNot(contains(mockProduct.id)));
  });

  test('undoDelete cancels the timer — deleteUseCase NOT called', () async {
    notifier.initiateDelete(mockProduct);
    await notifier.undoDelete(mockProduct.id);
    await Future.delayed(const Duration(seconds: 6));
    verifyNever(() => mockDeleteUseCase.call(any(), any()));
  });

  test('permanentlyDelete calls deleteUseCase after 5s', () async {
    notifier.initiateDelete(mockProduct);
    await Future.delayed(const Duration(seconds: 6));
    verify(() => mockDeleteUseCase.call(mockProduct.id, mockProduct.userId)).called(1);
  });

  test('dispose cancels all pending timers', () {
    notifier.initiateDelete(mockProduct);
    notifier.dispose();
    // No exception thrown, no timer firing after dispose
  });
});
```

### Widget Tests — ProductCard Dismissible

```dart
group('ProductCard', () {
  testWidgets('swipe left shows delete background', (tester) async {
    await tester.pumpWidget(buildTestWidget(ProductCard(product: mockProduct)));
    await tester.drag(find.byType(Dismissible), const Offset(-300, 0));
    await tester.pump();
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('completing swipe calls initiateDelete', (tester) async {
    await tester.pumpWidget(buildTestWidget(ProductCard(product: mockProduct)));
    await tester.fling(find.byType(Dismissible), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();
    verify(() => mockNotifier.initiateDelete(mockProduct)).called(1);
  });

  testWidgets('Snackbar shows with Annuler action', (tester) async {
    // After swipe
    expect(find.text('"${mockProduct.name}" supprimé'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);
  });
});
```

---

## ⚠️ Anti-Patterns à Éviter

### ❌ Supprimer de Hive immédiatement (sans fenêtre d'annulation)

```dart
// ❌ Aucun moyen d'annuler — perte de données potentielle
onDismissed: (_) async {
  await _local.deleteProduct(product.id);  // suppression immédiate ❌
}

// ✅ Masquer de l'UI, supprimer de Hive seulement après 5s
onDismissed: (_) {
  notifier.initiateDelete(product);  // Timer + pending state ✅
}
```

### ❌ Utiliser un champ `isDeleted` dans le modèle pour le soft delete

```dart
// ❌ Complexifie les queries Hive/Firestore, les filtres, le modèle
// et laisse des données zombies dans la base

// ✅ État de suppression en attente géré exclusivement dans le Notifier Riverpod
// Le modèle reste propre — pas de champ isDeleted
```

### ❌ Montrer un dialog de confirmation AUSSI pour le swipe

```dart
// ❌ Double friction inutile — l'utilisateur a déjà swipé intentionnellement
confirmDismiss: (_) async {
  return await showDialog(...);  // ❌ frustrant pour le swipe
}

// ✅ Swipe = sans dialog (geste intentionnel) + Snackbar undo
// Dialog de confirmation uniquement pour le bouton "Supprimer" du detail screen
```

### ❌ Utiliser `inventoryListProvider` au lieu de `filteredInventoryProvider`

```dart
// ❌ L'utilisateur voit le produit revenir dans la liste pendant la fenêtre d'annulation
final products = ref.watch(inventoryListProvider);  // ❌ pas filtré

// ✅ Utiliser le provider filtré qui exclut les produits en attente de suppression
final products = ref.watch(filteredInventoryProvider);  // ✅
```

### ❌ Timer non annulé dans dispose()

```dart
// ❌ Memory leak et exceptions après dispose
class InventoryNotifier extends StateNotifier<Set<String>> {
  final Map<String, Timer> _timers = {};
  // ❌ Oublier d'appeler timer.cancel() dans dispose()
}

// ✅ Toujours annuler dans dispose()
@override
void dispose() {
  for (final t in _pendingDeleteTimers.values) t.cancel();
  super.dispose();
}
```

---

## 🔗 Points d'Intégration

### Story 2.1 (AddProduct)
- `InventoryLocalDatasource.saveProduct()` → ajouter `deleteProduct(String id)` dans le même fichier
- `inventoryListProvider` → créer `filteredInventoryProvider` qui le wrap avec le filtre

### Story 2.2 (EditProduct)
- `InventoryRepository` interface → ajouter `deleteProduct` et `restoreProduct`
- `EditProductScreen` : si l'utilisateur supprime depuis le detail screen, fermer la page après confirmation

### Story 0.9 (SyncService)
- `queueOperation('DELETE', ...)` — payload minimal `{'id': productId}`
- Si le produit n'existe pas dans Firestore (jamais synced), le DELETE peut être ignoré côté serveur

### Story 2.4 (Mark as Consumed — Story suivante)
- "Consumed" ≠ "Deleted" : consumed conserve l'historique pour les métriques dashboard
- `ProductStatus.consumed` utilise `updateProduct()` (pas `deleteProduct()`)
- `InventoryNotifier` sera réutilisé ou étendu pour la consommation

### Epic 4 (Dashboard)
- Les produits supprimés ne contribuent PAS aux métriques (contrairement aux "consumed")
- Pas de log dashboard pour les supprimés — seulement analytics Firebase

---

## 📚 Dev Notes

### Décisions de Design

1. **Pourquoi pas de soft-delete dans le modèle ?**
   Le soft-delete pollue le schéma Hive/Firestore et complique toutes les queries futures. L'état "en attente de suppression" est de la logique UI pure, gérable dans le Notifier Riverpod sans toucher au modèle.

2. **Pourquoi 5 secondes (pas 3, pas 10) ?**
   Material Design recommande 4-10s pour les Snackbars d'action. 5s est le standard reconnu (Gmail, Google Drive). Suffisamment long pour permettre l'annulation, suffisamment court pour ne pas bloquer l'UI.

3. **Pourquoi pas de dialog pour le swipe ?**
   Le swipe est un geste explicite, directionnel, intentionnel. Ajouter un dialog de confirmation après un swipe crée une friction inutile (pattern reconnu : iOS Mail, Gmail). La Snackbar undo est la protection suffisante. Le dialog est réservé aux actions par bouton (moins intentionnelles visuellement).

4. **Pourquoi `Dismissible.key = ValueKey(product.id)` et pas index ?**
   Si la liste se réordonne pendant la suppression, les clés basées sur l'index causent des bugs de Dismissible. `ValueKey(id)` est stable même si la position change.

### Pièges Communs

1. **Oublier de remplacer `inventoryListProvider` par `filteredInventoryProvider`** dans les widgets existants
2. **Ne pas appeler `ScaffoldMessenger.hideCurrentSnackBar()`** avant d'afficher le nouveau Snackbar — sinon plusieurs Snackbars s'empilent si l'utilisateur supprime rapidement plusieurs produits
3. **`Navigator.pop()` depuis le ProductDetailScreen** après delete — sinon l'utilisateur reste sur un écran de détail d'un produit supprimé

---

## ✅ Definition of Done

### Fonctionnel
- [ ] Swipe gauche sur ProductCard déclenche le delete flow
- [ ] Bouton "Supprimer" depuis ProductDetail avec dialog de confirmation
- [ ] Produit disparaît immédiatement de l'UI (optimistic)
- [ ] Snackbar "Annuler" fonctionnel pendant 5 secondes
- [ ] Undo restaure le produit dans la liste
- [ ] Suppression permanente après 5s (Hive + SyncService `'DELETE'`)
- [ ] Fonctionne offline

### Non-Fonctionnel
- [ ] Suppression Hive < 50ms
- [ ] Snackbar visible 5 secondes exactement
- [ ] `flutter analyze` 0 erreurs

### Qualité Code
- [ ] Couverture ≥ 75% sur tous les nouveaux fichiers
- [ ] Tests unitaires `InventoryNotifier` (undo, timer, permanentDelete)
- [ ] Tests widget `ProductCard` Dismissible
- [ ] Timer correctement annulé dans `dispose()`
- [ ] `filteredInventoryProvider` utilisé partout (pas `inventoryListProvider` directement)

### Intégration
- [ ] `InventoryRepository` interface mise à jour avec `deleteProduct` + `restoreProduct`
- [ ] `filteredInventoryProvider` créé et utilisé dans tous les écrans d'inventaire
- [ ] Analytics `product_deleted` déclenché uniquement après suppression permanente

---

## 📎 Références

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.3]
- [Source: _bmad-output/planning-artifacts/architecture.md#State Management Riverpod — IMMUTABILITÉ STRICTE]
- [Source: _bmad-output/implementation-artifacts/2-1-add-product-manually-to-inventory.md]
- [Source: _bmad-output/implementation-artifacts/2-2-edit-product-information-in-inventory.md]
- Material Design — Snackbars : https://m3.material.io/components/snackbar/guidelines

---

## 🤖 Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

*(à remplir par le Dev Agent)*

### Completion Notes List

*(à remplir par le Dev Agent)*

### File List

*(à remplir par le Dev Agent)*

---

**Story Created**: 2026-02-20
**Last Updated**: 2026-02-20
**Ready for Dev**: ✅ Oui
