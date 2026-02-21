# Story 2.12: Inventory Works Fully Offline

## 📋 Story Metadata

- **Story ID**: 2.12 | **Complexity**: 2 (XS — validation + indicateur offline, infra 0.9 déjà en place)
- **Story Key**: 2-12-inventory-works-fully-offline
- **Status**: ready-for-dev | **Effort**: 0.5 day
- **Dependencies**: Story 0.9 (offline-first sync), Story 0.3 (Hive), Stories 2.1–2.4 (CRUD already Hive-first)

---

## 📖 User Story

**As a** Marie (senior),
**I want** to manage my inventory even when I have no internet connection,
**So that** I can use the app anywhere without worrying about connectivity.

---

## ✅ Acceptance Criteria

### AC1: CRUD offline — aucune perte de données
**Given** je n'ai pas de connexion internet
**When** j'ajoute, modifie, supprime ou marque un produit comme consommé
**Then** l'opération est sauvegardée immédiatement dans Hive
**And** l'UI répond instantanément (< 100ms)
**And** aucune erreur réseau n'est affichée à l'utilisateur
**And** l'opération est queued dans `SyncService` pour sync future

### AC2: Indicateur "Hors ligne"
**Given** je n'ai pas de connexion internet
**When** j'ouvre l'écran inventaire
**Then** un bandeau ou icône "Hors ligne" est visible dans l'AppBar
**And** quand la connexion revient, l'indicateur disparaît

### AC3: Auto-sync à la reconnexion
**Given** j'ai effectué des opérations offline (adds, edits, deletes, consumes)
**When** la connexion internet est rétablie
**Then** le `SyncService` synchronise automatiquement toutes les opérations en attente
**And** aucune donnée n'est perdue ou dupliquée
**And** un feedback visuel confirme la sync ("Synchronisation réussie" ou spinner)

### AC4: Gestion des conflits (simple)
**Given** le même produit a été modifié localement et en cloud (autre device)
**When** la sync se produit
**Then** la version la plus récente (`updatedAt` timestamp) gagne
**And** l'utilisateur n'est pas bloqué par un écran de conflit

### AC5: Lecture offline
**Given** je n'ai pas de connexion internet
**When** j'ouvre l'app et navigue vers l'inventaire
**Then** mes données Hive sont affichées immédiatement
**And** pas de spinner infini ni d'erreur de timeout

---

## 🏗️ Technical Specifications

### Validation de l'architecture existante (Story 0.9)

Story 2.12 valide que les stories 2.1–2.4 utilisent correctement le pattern offline-first:

```dart
// Pattern correct (Stories 2.1–2.4 doivent toutes suivre ce pattern):
Future<Either<Failure, void>> addProduct(ProductEntity product) async {
  // 1. Write to Hive FIRST (offline-safe)
  await _hiveBox.put(product.id, ProductModel.fromEntity(product));

  // 2. Queue for Firestore sync (non-blocking)
  _syncService.queueOperation(SyncOperation(
    type: 'CREATE',
    collection: 'inventory_items',
    documentId: product.id,
    data: ProductModel.fromEntity(product).toJson(),
  ));

  return const Right(null);
}
```

> **Checklist**: Vérifier que toutes les méthodes dans `InventoryRepositoryImpl` suivent ce pattern (Stories 2.1-2.4).

### ConnectivityBanner Widget

```dart
// lib/core/widgets/connectivity_banner.dart

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isOnline
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('offline-banner'),
              width: double.infinity,
              color: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.wifi_off, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Hors ligne — modifications sauvegardées localement',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }
}
```

### Connectivity Provider (utilise Story 0.9)

```dart
// lib/core/providers/connectivity_provider.dart

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((result) => result != ConnectivityResult.none);
});
```

### SyncStatusBadge — Feedback dans AppBar

```dart
// lib/features/inventory/presentation/screens/inventory_list_screen.dart

AppBar(
  title: const Text('Mon Inventaire'),
  actions: [
    const _SyncStatusIcon(),
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => context.push('/inventory/add'),
    ),
  ],
)

class _SyncStatusIcon extends ConsumerWidget {
  const _SyncStatusIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
    final pendingCount = ref.watch(syncQueueCountProvider);

    if (!isOnline) {
      return const Icon(Icons.cloud_off, color: Colors.orange);
    }
    if (pendingCount > 0) {
      return Stack(
        children: [
          const Icon(Icons.sync),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Text('$pendingCount',
                  style: const TextStyle(fontSize: 8, color: Colors.white)),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
```

### SyncQueueCountProvider (Story 0.9)

```dart
// À ajouter dans sync providers si pas déjà présent
final syncQueueCountProvider = Provider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.pendingOperationsCount;
});
```

### Intégration dans InventoryListScreen

```dart
// Ajouter ConnectivityBanner en tête de body Column:
body: Column(
  children: [
    const ConnectivityBanner(),      // ← AJOUTER (visible seulement si offline)
    const InventorySearchBar(),
    const CategoryFilterBar(),
    const LocationFilterBar(),
    const StatusFilterBar(),
    Expanded(child: ...),
  ],
),
```

---

## 📝 Implementation Tasks

- [ ] **T1**: Auditer `InventoryRepositoryImpl` — vérifier que toutes les méthodes suivent le pattern Hive-first + SyncService.queue
- [ ] **T2**: Créer `ConnectivityBanner` widget
- [ ] **T3**: Créer/vérifier `connectivityProvider` (Story 0.9)
- [ ] **T4**: Ajouter `syncQueueCountProvider`
- [ ] **T5**: Intégrer `ConnectivityBanner` + `_SyncStatusIcon` dans `InventoryListScreen`
- [ ] **T6**: Tests d'intégration offline — add/edit/delete/consume sans connectivity
- [ ] **T7**: Test auto-sync — simuler reconnexion, vérifier queue vidée
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

---

## 🧪 Testing Strategy

```dart
group('InventoryRepository — offline operations', () {
  setUp(() {
    // Mock ConnectivityService → offline
    when(mockConnectivity.isOnline).thenReturn(false);
  });

  test('addProduct writes to Hive and queues sync op', () async {
    await repository.addProduct(testProduct);
    // Hive box contains product
    expect(hiveBox.get(testProduct.id), isNotNull);
    // SyncService has 1 queued operation
    expect(syncService.pendingOperationsCount, 1);
  });

  test('deleteProduct removes from Hive and queues DELETE', () async {
    await repository.deleteProduct(testProduct.id);
    expect(hiveBox.get(testProduct.id), isNull);
    verify(syncService.queueOperation(argThat(
      predicate<SyncOperation>((op) => op.type == 'DELETE'),
    ))).called(1);
  });
});

group('ConnectivityBanner', () {
  testWidgets('shows banner when offline', (tester) async { ... });
  testWidgets('hides banner when online', (tester) async { ... });
  testWidgets('animates transition between states', (tester) async { ... });
});
```

---

## ⚠️ Anti-Patterns à Éviter

```dart
// ❌ Écrire dans Firestore AVANT Hive (bloque si offline)
await firestoreRef.set(data);  // ❌ throws si offline
await hiveBox.put(id, model);

// ✅ Hive FIRST, Firestore via SyncService queue (non-bloquant)
await hiveBox.put(id, model);  // ✅ toujours disponible offline
syncService.queueOperation(...);  // ✅ fire-and-forget

// ❌ Afficher une erreur réseau à l'utilisateur lors d'une opération offline
// ✅ Opération silencieuse avec indicateur d'état offline dans l'AppBar

// ❌ Désactiver l'UI entière en mode offline
// ✅ L'UI est 100% fonctionnelle offline, l'indicateur est informatif seulement
```

---

## 🔗 Points d'Intégration

- **Story 0.3** (Hive) : `InventoryRepositoryImpl` utilise Hive comme source de vérité locale
- **Story 0.9** (SyncService) : Queue offline operations → sync à la reconnexion
- **Stories 2.1–2.4** : Validation que le pattern Hive-first est bien implémenté dans chaque repo method
- **Story 1.8** (Multi-device sync) : Conflit resolution `updatedAt` timestamp déjà présent sur `ProductEntity`
- **Epic 3** (Notifications) : Les notifications fonctionnent également offline (calcul local via `ProductStatusService`)

---

## ✅ Definition of Done

- [ ] Audit et correction de `InventoryRepositoryImpl` — pattern Hive-first confirmé
- [ ] `ConnectivityBanner` dans `InventoryListScreen`
- [ ] `_SyncStatusIcon` dans AppBar
- [ ] Tests offline CRUD — Hive écrit + sync queued
- [ ] Test auto-sync à la reconnexion
- [ ] `flutter analyze` 0 erreurs | couverture ≥ 75%

---

**Story Created**: 2026-02-21 | **Ready for Dev**: ✅ Oui
