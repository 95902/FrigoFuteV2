# Story 2.4: Mark Product as Consumed

## 📋 Story Metadata

- **Story ID**: 2.4
- **Epic**: Epic 2 - Inventory Management
- **Title**: Mark Product as Consumed
- **Story Key**: 2-4-mark-product-as-consumed
- **Status**: ready-for-dev
- **Complexity**: 4 (S-M — status update + consumption log + feature flag integration)
- **Priority**: P1 (Core anti-waste metric — feeds Dashboard Epic 4)
- **Estimated Effort**: 1-2 days
- **Dependencies**:
  - Story 2.1 (**REQUIS** — `ProductEntity`, `ProductModel`, `InventoryRepository`, `updateProduct()`)
  - Story 2.3 (**REQUIS** — `InventoryNotifier`, `filteredInventoryProvider`, undo pattern)
  - Story 0.7 (`food_waste_prevented` analytics event prédéfini dans `AnalyticsService`)
  - Story 0.8 (Feature flag `nutrition_tracking_enabled` via `RemoteConfigService`)
  - Story 0.9 (SyncService — `queueOperation('UPDATE', ...)`)
- **Tags**: `inventory`, `consumed`, `analytics`, `feature-flags`, `dashboard-metrics`, `offline-first`

---

## 📖 User Story

**As a** Thomas (sportif),
**I want** to mark products as consumed when I eat them,
**So that** the app can track my consumption and remove them from my active inventory.

---

## ✅ Acceptance Criteria

### AC1: Mark Product as Consumed
**Given** I have products in my inventory
**When** I tap "Marquer comme consommé" on a product (via swipe droit ou bouton detail)
**Then** the product status changes to `consumed`
**And** `consumedAt` timestamp is recorded
**And** the product disappears from the **active** inventory list immediately
**And** the product is NOT deleted — it remains in Hive/Firestore with `status: consumed`

### AC2: Visual Feedback + Undo
**Given** I marked a product as consumed
**When** the action completes
**Then** I see a Snackbar: "✓ [Nom produit] consommé !" with an "Annuler" action
**And** I can tap "Annuler" within 5 seconds to restore the product to active inventory
**And** if I undo, the product's previous status (fresh/expiringSoon/expired) is restored

### AC3: Consumption Contributes to Dashboard Metrics
**Given** I mark a product as consumed
**When** the action is permanently confirmed (after 5s undo window)
**Then** the `food_waste_prevented` analytics event is fired (prédéfini Story 0.7) with:
  - `product_category: String`
  - `days_before_expiry: int` (positif = consommé avant expiration, négatif = expiré)
  - `product_name: String`
**And** the `consumedAt` timestamp in Hive/Firestore enables Dashboard Epic 4 queries

### AC4: Nutrition Tracking Integration (Feature Flag)
**Given** the feature flag `nutrition_tracking_enabled` is `true`
**When** I mark a product as consumed
**Then** after the Snackbar confirmation, I see a secondary prompt:
  "Voulez-vous enregistrer la valeur nutritionnelle ?" with "Oui" / "Plus tard"
**Given** the feature flag `nutrition_tracking_enabled` is `false`
**Then** no nutrition prompt is shown (clean flow)

### AC5: Swipe Right to Consume
**Given** I am on the inventory list
**When** I swipe right on a product card
**Then** a green "consumed" background with a check icon appears
**And** releasing the swipe triggers the consume flow
**Note**: Story 2.3 implements swipe LEFT for delete — swipe RIGHT for consume (bi-directional `Dismissible`)

### AC6: Offline Support
**Given** I have no internet connection
**When** I mark a product as consumed
**Then** the status change is saved to Hive immediately
**And** the `'UPDATE'` operation is queued for Firestore sync
**And** no data is lost

---

## 🏗️ Technical Specifications

### 1. Model Updates — `consumedAt` Field

#### Update `ProductEntity` — `lib/features/inventory/domain/entities/product_entity.dart`

Ajouter le champ optionnel à l'entité existante (Story 2.1) :

```dart
@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    required String id,
    required String userId,
    required String name,
    required ProductCategory category,
    required StorageLocation location,
    required double quantity,
    required String unit,
    DateTime? expirationDate,
    @Default(ExpiryType.dlc) ExpiryType expiryType,
    @Default(ProductStatus.fresh) ProductStatus status,
    required DateTime addedDate,
    String? barcode,
    String? notes,
    @Default(false) bool isSyncPending,
    DateTime? consumedAt,  // ← AJOUTER (null si non consommé)
  }) = _ProductEntity;
}
```

#### Update `ProductModel` — `lib/features/inventory/data/models/product_model.dart`

```dart
@HiveType(typeId: 1)
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    @HiveField(0)  required String id,
    @HiveField(1)  required String userId,
    @HiveField(2)  required String name,
    @HiveField(3)  required String category,
    @HiveField(4)  required String location,
    @HiveField(5)  required double quantity,
    @HiveField(6)  required String unit,
    @HiveField(7)  DateTime? expirationDate,
    @HiveField(8)  @Default('dlc') String expiryType,
    @HiveField(9)  @Default('fresh') String status,
    @HiveField(10) required DateTime addedDate,
    @HiveField(11) String? barcode,
    @HiveField(12) String? notes,
    @HiveField(13) @Default(false) bool isSyncPending,
    @HiveField(14) @Default(0) int version,
    @HiveField(15) DateTime? consumedAt,  // ← AJOUTER
  }) = _ProductModel;

  // ...toFirestore() et fromFirestore() mis à jour pour inclure consumedAt
}
```

**Mise à jour `toFirestore()`** :
```dart
static Map<String, dynamic> toFirestore(ProductModel model) => {
  // ... champs existants ...
  'consumedAt': model.consumedAt != null
      ? Timestamp.fromDate(model.consumedAt!)
      : null,
};
```

**Mise à jour `fromFirestore()`** :
```dart
consumedAt: data['consumedAt'] != null
    ? (data['consumedAt'] as Timestamp).toDate()
    : null,
```

> ⚠️ **IMPORTANT** : Après modification du modèle, régénérer le code :
> ```bash
> flutter pub run build_runner build --delete-conflicting-outputs
> ```
> Le `HiveField(15)` est additionnel et rétro-compatible — les enregistrements existants sans ce champ retourneront `null`.

---

### 2. Use Case — `lib/features/inventory/domain/usecases/mark_as_consumed_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class MarkAsConsumedUseCase {
  final InventoryRepository _repository;

  MarkAsConsumedUseCase(this._repository);

  Future<Either<AppException, ProductEntity>> call(ProductEntity product) async {
    if (product.status == ProductStatus.consumed) {
      // Idempotent: already consumed — no-op
      return Right(product);
    }

    final consumed = product.copyWith(
      status: ProductStatus.consumed,
      consumedAt: DateTime.now(),
      isSyncPending: true,
    );

    // Reuses updateProduct() — same offline-first pattern
    return _repository.updateProduct(consumed);
  }
}

/// Reverses a consume action — used for undo
class UndoConsumeUseCase {
  final InventoryRepository _repository;

  UndoConsumeUseCase(this._repository);

  Future<Either<AppException, ProductEntity>> call(ProductEntity originalProduct) async {
    // Restore original status (before consume) and clear consumedAt
    final restored = originalProduct.copyWith(
      consumedAt: null,
      isSyncPending: true,
    );
    return _repository.updateProduct(restored);
  }
}
```

---

### 3. InventoryNotifier Extension

Étendre `InventoryNotifier` de Story 2.3 pour gérer le consume avec undo :

```dart
// Dans lib/features/inventory/presentation/providers/inventory_notifier.dart

/// State: Set<String> = productIds currently in pending-deletion undo window
/// Extended state needs to also track pending-consume undo window.
/// Solution: Use a separate StateNotifier for consume, or extend state.

/// Simplest approach: separate consumed pending set
class InventoryConsumeNotifier extends StateNotifier<Set<String>> {
  final MarkAsConsumedUseCase _consumeUseCase;
  final UndoConsumeUseCase _undoConsumeUseCase;
  final AnalyticsService _analytics;
  final RemoteConfigService _remoteConfig;  // for nutrition feature flag

  final Map<String, Timer> _pendingConsumeTimers = {};
  final Map<String, ProductEntity> _pendingConsumeProducts = {};     // state before consume
  final Map<String, ProductEntity> _pendingConsumedVersions = {};    // state after consume

  InventoryConsumeNotifier(
    this._consumeUseCase,
    this._undoConsumeUseCase,
    this._analytics,
    this._remoteConfig,
  ) : super({});

  /// Initiates consume with 5-second undo window.
  /// Returns the ProductEntity BEFORE consume (for undo reference).
  Future<ProductEntity?> initiateConsume(ProductEntity product) async {
    // Immediately update status in Hive
    final result = await _consumeUseCase.call(product);

    return result.fold(
      (error) => null,
      (consumed) {
        // Add to pending set (hides from active inventory via filter)
        // Note: filteredInventoryProvider already filters consumed status
        // The undo window tracks which consumed items can still be undone
        state = {...state, product.id};

        _pendingConsumeTimers[product.id] = Timer(
          const Duration(seconds: 5),
          () => _permanentlyConsume(product, consumed),
        );
        _pendingConsumeProducts[product.id] = product;        // pre-consume
        _pendingConsumedVersions[product.id] = consumed;      // post-consume

        return product;
      },
    );
  }

  /// Undo consume — called from Snackbar action
  Future<void> undoConsume(String productId) async {
    _pendingConsumeTimers[productId]?.cancel();
    _pendingConsumeTimers.remove(productId);

    final original = _pendingConsumeProducts.remove(productId);
    _pendingConsumedVersions.remove(productId);
    state = state.where((id) => id != productId).toSet();

    if (original != null) {
      await _undoConsumeUseCase.call(original);
    }
  }

  /// Called when undo window expires — fire analytics
  Future<void> _permanentlyConsume(
      ProductEntity original, ProductEntity consumed) async {
    _pendingConsumeTimers.remove(original.id);
    _pendingConsumeProducts.remove(original.id);
    _pendingConsumedVersions.remove(original.id);
    state = state.where((id) => id != original.id).toSet();

    // Fire food_waste_prevented analytics event (prédéfini Story 0.7)
    final daysBeforeExpiry = original.expirationDate != null
        ? original.expirationDate!.difference(DateTime.now()).inDays
        : 0;

    _analytics.logFoodWastePrevented(
      productCategory: original.category.name,
      daysBeforeExpiry: daysBeforeExpiry,
      productName: original.name,
    );
  }

  bool isUndoable(String productId) => state.contains(productId);

  bool get isNutritionTrackingEnabled =>
      _remoteConfig.getFeatureConfig().nutritionTrackingEnabled;

  @override
  void dispose() {
    for (final t in _pendingConsumeTimers.values) t.cancel();
    _pendingConsumeTimers.clear();
    super.dispose();
  }
}
```

---

### 4. Analytics — `food_waste_prevented`

L'événement `food_waste_prevented` est **prédéfini** dans `AnalyticsService` (Story 0.7). Ajouter la méthode helper si elle n'existe pas encore :

```dart
// Dans lib/core/monitoring/analytics_service.dart
// Méthode déjà prévue dans Story 0.7 — vérifier si implémentée ou ajouter :

void logFoodWastePrevented({
  required String productCategory,
  required int daysBeforeExpiry,
  required String productName,
}) {
  logEvent(
    name: 'food_waste_prevented',
    parameters: {
      'product_category': productCategory,
      'days_before_expiry': daysBeforeExpiry,
      'product_name': productName,
    },
  );
}
```

---

### 5. Feature Flag — Nutrition Prompt

```dart
// Vérification du feature flag après consume confirmé
// Dans la présentation layer après initiateConsume()

final notifier = ref.read(inventoryConsumeNotifierProvider.notifier);
await notifier.initiateConsume(product);

// Snackbar avec undo
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('✓ "${product.name}" consommé !'),
    duration: const Duration(seconds: 5),
    action: SnackBarAction(
      label: 'Annuler',
      onPressed: () => notifier.undoConsume(product.id),
    ),
  ),
);

// Nutrition prompt (feature flag)
if (notifier.isNutritionTrackingEnabled && mounted) {
  await Future.delayed(const Duration(milliseconds: 500));
  if (mounted) {
    _showNutritionPrompt(context, product);
  }
}
```

```dart
void _showNutritionPrompt(BuildContext context, ProductEntity product) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Voulez-vous enregistrer la valeur nutritionnelle ?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pour "${product.name}"',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Plus tard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Navigate to nutrition logging (Epic 7)
                    // context.push('/nutrition/log', extra: product);
                    // Note: route non implémentée jusqu'à Epic 7
                  },
                  child: const Text('Oui'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
```

---

### 6. UI — Bi-directional Dismissible (Swipe Right = Consume)

Mettre à jour `ProductCard` (Story 2.3) pour gérer les deux directions :

```dart
// Dans lib/features/inventory/presentation/widgets/product_card_widget.dart

return Dismissible(
  key: ValueKey(product.id),
  // Swipe LEFT = delete (rouge) — Story 2.3
  // Swipe RIGHT = consume (vert) — Story 2.4
  background: Container(   // LEFT swipe background (consume — RIGHT)
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(left: 20),
    color: Colors.green,
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
        SizedBox(height: 4),
        Text('Consommé', style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  ),
  secondaryBackground: Container(  // RIGHT swipe background (delete — LEFT)
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    color: Colors.red,
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.delete_outline, color: Colors.white, size: 28),
        SizedBox(height: 4),
        Text('Supprimer', style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  ),
  onDismissed: (direction) {
    if (direction == DismissDirection.startToEnd) {
      _handleConsume(context, ref);  // swipe RIGHT → consume
    } else {
      _handleDelete(context, ref);   // swipe LEFT → delete (Story 2.3)
    }
  },
  child: _ProductCardContent(product: product),
);
```

---

### 7. Updated `filteredInventoryProvider`

Mettre à jour dans `inventory_providers.dart` (créé en Story 2.3) :

```dart
/// Active inventory: excludes products pending deletion AND consumed products
final filteredInventoryProvider = Provider<AsyncValue<List<ProductEntity>>>((ref) {
  final allProducts = ref.watch(inventoryListProvider);
  final pendingDeletionIds = ref.watch(inventoryNotifierProvider);

  return allProducts.whenData(
    (products) => products
        .where((p) => !pendingDeletionIds.contains(p.id))
        .where((p) => p.status != ProductStatus.consumed)  // ← AJOUTER
        .toList(),
  );
});

/// Consumed products list (for history/dashboard)
final consumedInventoryProvider = Provider<AsyncValue<List<ProductEntity>>>((ref) {
  final allProducts = ref.watch(inventoryListProvider);
  return allProducts.whenData(
    (products) => products
        .where((p) => p.status == ProductStatus.consumed)
        .toList()
        ..sort((a, b) =>
            (b.consumedAt ?? b.addedDate).compareTo(a.consumedAt ?? a.addedDate)),
  );
});
```

---

### 8. Providers à Ajouter

```dart
final markAsConsumedUseCaseProvider = Provider<MarkAsConsumedUseCase>(
  (ref) => MarkAsConsumedUseCase(ref.read(inventoryRepositoryProvider)),
);

final undoConsumeUseCaseProvider = Provider<UndoConsumeUseCase>(
  (ref) => UndoConsumeUseCase(ref.read(inventoryRepositoryProvider)),
);

final inventoryConsumeNotifierProvider =
    StateNotifierProvider<InventoryConsumeNotifier, Set<String>>(
  (ref) => InventoryConsumeNotifier(
    ref.read(markAsConsumedUseCaseProvider),
    ref.read(undoConsumeUseCaseProvider),
    ref.read(analyticsServiceProvider),
    ref.read(remoteConfigServiceProvider),
  ),
);
```

---

## 📝 Implementation Tasks

### Phase 1 : Mise à jour modèles (Jour 1)

- [ ] **T1.1** : Ajouter `consumedAt: DateTime?` à `ProductEntity` (domain)
- [ ] **T1.2** : Ajouter `@HiveField(15) DateTime? consumedAt` à `ProductModel` (data)
- [ ] **T1.3** : Mettre à jour `toFirestore()` et `fromFirestore()` pour `consumedAt`
- [ ] **T1.4** : Régénérer le code : `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] **T1.5** : Tests unitaires `ProductModel` — `consumedAt` roundtrip JSON + Firestore

### Phase 2 : Domain Layer (Jour 1)

- [ ] **T2.1** : Créer `MarkAsConsumedUseCase` (idempotent si déjà consumed)
- [ ] **T2.2** : Créer `UndoConsumeUseCase`
- [ ] **T2.3** : Tests unitaires `MarkAsConsumedUseCase` — already consumed → no-op, sets consumedAt

### Phase 3 : State Management (Jour 1)

- [ ] **T3.1** : Créer `InventoryConsumeNotifier` avec `initiateConsume()`, `undoConsume()`, `_permanentlyConsume()`
- [ ] **T3.2** : Ajouter `markAsConsumedUseCaseProvider`, `undoConsumeUseCaseProvider`, `inventoryConsumeNotifierProvider`
- [ ] **T3.3** : Mettre à jour `filteredInventoryProvider` → exclure `ProductStatus.consumed`
- [ ] **T3.4** : Créer `consumedInventoryProvider` (pour Epic 4 Dashboard)
- [ ] **T3.5** : Tests unitaires `InventoryConsumeNotifier` — undo avant 5s, analytics après 5s, feature flag

### Phase 4 : UI (Jour 1-2)

- [ ] **T4.1** : Mettre à jour `ProductCard` Dismissible → bi-directionnel (droite=consume, gauche=delete)
- [ ] **T4.2** : Implémenter Snackbar "consommé" avec action "Annuler" (5s)
- [ ] **T4.3** : Implémenter `_showNutritionPrompt()` conditionnel au feature flag `nutrition_tracking_enabled`
- [ ] **T4.4** : Ajouter bouton "Marquer comme consommé" dans `ProductDetailScreen`
- [ ] **T4.5** : Tests widget `ProductCard` — swipe droit déclenche consume flow

### Phase 5 : Tests & Couverture (Jour 2)

- [ ] **T5.1** : Couverture ≥ 75% sur tous les nouveaux fichiers
- [ ] **T5.2** : Test manuel — consume → undo → produit restauré dans la liste active
- [ ] **T5.3** : Test manuel — consume → attendre 5s → `food_waste_prevented` analytics fired
- [ ] **T5.4** : Test feature flag — nutrition prompt visible si `nutrition_tracking_enabled: true`
- [ ] **T5.5** : `flutter analyze` 0 erreurs

---

## 🧪 Testing Strategy

### Unit Tests

```dart
group('MarkAsConsumedUseCase', () {
  test('sets status to consumed and consumedAt timestamp', () async {
    final product = ProductEntity(..., status: ProductStatus.fresh);
    final result = await useCase.call(product);
    result.fold(
      (_) => fail('should succeed'),
      (p) {
        expect(p.status, ProductStatus.consumed);
        expect(p.consumedAt, isNotNull);
      },
    );
  });

  test('is idempotent when already consumed', () async {
    final consumed = ProductEntity(..., status: ProductStatus.consumed,
        consumedAt: DateTime.now());
    final result = await useCase.call(consumed);
    result.fold(
      (_) => fail('should succeed'),
      (p) => expect(p, equals(consumed)),  // no change
    );
    verifyNever(() => mockRepository.updateProduct(any()));
  });
});

group('InventoryConsumeNotifier', () {
  test('initiateConsume adds id to pending set', () async {
    await notifier.initiateConsume(mockProduct);
    expect(state, contains(mockProduct.id));
  });

  test('undoConsume removes from pending and calls undoConsumeUseCase', () async {
    await notifier.initiateConsume(mockProduct);
    await notifier.undoConsume(mockProduct.id);
    expect(state, isNot(contains(mockProduct.id)));
    verify(() => mockUndoUseCase.call(mockProduct)).called(1);
  });

  test('fires food_waste_prevented analytics after 5s', () async {
    await notifier.initiateConsume(mockProduct);
    await Future.delayed(const Duration(seconds: 6));
    verify(() => mockAnalytics.logFoodWastePrevented(
      productCategory: any(named: 'productCategory'),
      daysBeforeExpiry: any(named: 'daysBeforeExpiry'),
      productName: any(named: 'productName'),
    )).called(1);
  });

  test('undo before 5s cancels timer — analytics NOT fired', () async {
    await notifier.initiateConsume(mockProduct);
    await notifier.undoConsume(mockProduct.id);
    await Future.delayed(const Duration(seconds: 6));
    verifyNever(() => mockAnalytics.logFoodWastePrevented(
      productCategory: any(named: 'productCategory'),
      daysBeforeExpiry: any(named: 'daysBeforeExpiry'),
      productName: any(named: 'productName'),
    ));
  });
});
```

### Widget Tests

```dart
group('ProductCard — consume swipe', () {
  testWidgets('swipe right shows green consumed background', (tester) async {
    await tester.pumpWidget(buildTestWidget(ProductCard(product: mockProduct)));
    await tester.drag(find.byType(Dismissible), const Offset(300, 0));
    await tester.pump();
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('completing right swipe shows success Snackbar', (tester) async {
    await tester.pumpWidget(buildTestWidget(ProductCard(product: mockProduct)));
    await tester.fling(find.byType(Dismissible), const Offset(500, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.textContaining('consommé'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);
  });
});
```

---

## ⚠️ Anti-Patterns à Éviter

### ❌ Confondre Consumed et Deleted

```dart
// ❌ INTERDIT — delete supprime définitivement, consume conserve l'historique
onConsumed: (_) => _repository.deleteProduct(product.id, product.userId);

// ✅ CORRECT — updateProduct avec status: consumed
onConsumed: (_) => _consumeUseCase.call(product);
```

### ❌ Déclencher `food_waste_prevented` immédiatement (sans attendre la fin du undo window)

```dart
// ❌ L'utilisateur annule → l'event analytics est déjà parti
_analytics.logFoodWastePrevented(...);  // juste après initiateConsume()
await _consumeUseCase.call(product);

// ✅ Déclencher seulement dans _permanentlyConsume() après 5s
Future<void> _permanentlyConsume(ProductEntity product, ...) async {
  // ...
  _analytics.logFoodWastePrevented(...);  // ✅ après confirmation
}
```

### ❌ Afficher le nutrition prompt avant la fin du Snackbar

```dart
// ❌ Le prompt s'affiche par-dessus le Snackbar — mauvaise UX
_showNutritionPrompt(context, product);
ScaffoldMessenger.of(context).showSnackBar(...);

// ✅ Attendre un court délai + vérifier que le Snackbar est visible
ScaffoldMessenger.of(context).showSnackBar(...);
await Future.delayed(const Duration(milliseconds: 500));
if (mounted && notifier.isNutritionTrackingEnabled) {
  _showNutritionPrompt(context, product);
}
```

### ❌ Oublier que `filteredInventoryProvider` doit exclure les consumed

```dart
// ❌ Les produits consommés restent visibles dans la liste active
final products = ref.watch(inventoryListProvider);

// ✅ filteredInventoryProvider exclut deleted pending ET consumed
final products = ref.watch(filteredInventoryProvider);
```

---

## 🔗 Points d'Intégration

### Story 2.3 (Delete — REQUIS)
- `InventoryConsumeNotifier` est un notifier **séparé** de `InventoryNotifier` (delete)
- Le `filteredInventoryProvider` doit combiner les filtres des deux notifiers
- `ProductCard.Dismissible` : `background` = consommé (droite), `secondaryBackground` = supprimé (gauche)

### Story 0.7 (AnalyticsService)
- `food_waste_prevented` est un des 7 événements prédéfinis de Story 0.7
- Vérifier que `logFoodWastePrevented()` est déjà implémenté dans `AnalyticsService`
- Si non, l'ajouter avec les paramètres définis ici

### Story 0.8 (Feature Flags)
- `remoteConfigServiceProvider` → `getFeatureConfig().nutritionTrackingEnabled`
- Si `false` (défaut pour les utilisateurs gratuits) → pas de nutrition prompt
- Le `PremiumFeatureGuard` de Story 0.8 n'est pas utilisé ici (le prompt est optionnel, pas bloquant)

### Epic 4 (Dashboard)
- `consumedInventoryProvider` expose la liste des produits consommés avec `consumedAt`
- Les métriques Dashboard utiliseront ce provider pour calculer : kg évités, économies, CO2
- Le champ `consumedAt` est la clé pour les graphiques temporels

### Epic 7 (Nutrition Tracking)
- Le bouton "Oui" du nutrition prompt naviguera vers `/nutrition/log` (non implémenté avant Epic 7)
- Pour l'instant, le bouton peut juste fermer le modal avec une log analytics `nutrition_log_prompted`

---

## 📚 Dev Notes

### Décisions de Design

1. **Pourquoi consumed ≠ deleted ?**
   - Consumed garde un historique pour les métriques anti-gaspi (Epic 4 Dashboard)
   - Deleted est une correction ("j'ai jeté ce produit / erreur de saisie")
   - Consumed contribue aux statistiques `food_waste_prevented`, deleted non
   - Distinction importante pour RGPD : les données nutritionnelles liées à la consommation sont des données santé à conserver/exporter

2. **Pourquoi deux StateNotifiers séparés (delete / consume) ?**
   Responsabilité unique. Les flux sont différents : delete = suppression permanente Hive, consume = update status Hive. Un seul notifier gérant les deux deviendrait difficile à tester.

3. **Pourquoi l'analytics `food_waste_prevented` seulement après 5s ?**
   Cohérence : si l'utilisateur annule, aucun produit n'a vraiment été consommé. Déclencher analytics sur l'action réelle (pas l'intention).

4. **Pourquoi `daysBeforeExpiry` peut être négatif ?**
   Si un produit expiré est consommé quand même (DDM = "meilleur avant" souvent encore comestible), la valeur est négative. Cela est une information utile pour les statistiques.

### Pièges Communs

1. **Oublier d'ajouter `HiveField(15)` et de régénérer** → Hive ignore le champ silencieusement
2. **`filteredInventoryProvider` ne filtre pas les consumed** → les produits consommés restent dans la liste active
3. **Nutrition prompt bloque le Snackbar undo** → toujours afficher le prompt avec un délai
4. **Swipe direction invertie** → `background` = action pour swipe RIGHT (startToEnd), `secondaryBackground` = swipe LEFT (endToStart)

---

## ✅ Definition of Done

### Fonctionnel
- [ ] Swipe droit sur ProductCard déclenche le consume flow
- [ ] Bouton "Marquer comme consommé" dans ProductDetail
- [ ] Produit disparaît de la liste active immédiatement
- [ ] Snackbar "consommé" avec "Annuler" fonctionnel (5s)
- [ ] Undo restaure le produit dans la liste active avec son status original
- [ ] `food_waste_prevented` analytics fired après 5s (pas sur undo)
- [ ] Nutrition prompt affiché si feature flag `nutrition_tracking_enabled: true`
- [ ] Fonctionne offline

### Non-Fonctionnel
- [ ] Update Hive < 50ms
- [ ] `flutter analyze` 0 erreurs

### Qualité Code
- [ ] `consumedAt` ajouté à `ProductEntity` + `ProductModel` (HiveField 15)
- [ ] Couverture ≥ 75% sur tous les nouveaux fichiers
- [ ] Tests unitaires `MarkAsConsumedUseCase` + `InventoryConsumeNotifier`
- [ ] Tests widget swipe droit ProductCard
- [ ] `filteredInventoryProvider` exclut `ProductStatus.consumed`
- [ ] `consumedInventoryProvider` créé pour Epic 4

---

## 📎 Références

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.4]
- [Source: _bmad-output/planning-artifacts/architecture.md#Analytics Events Naming]
- [Source: _bmad-output/implementation-artifacts/2-1-add-product-manually-to-inventory.md]
- [Source: _bmad-output/implementation-artifacts/2-3-delete-product-from-inventory.md]
- Material Design — Dismissible bi-directionnel : https://api.flutter.dev/flutter/widgets/Dismissible-class.html

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
