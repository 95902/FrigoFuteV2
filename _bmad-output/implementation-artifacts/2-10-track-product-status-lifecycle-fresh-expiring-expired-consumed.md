# Story 2.10: Track Product Status Lifecycle (Fresh → Expiring → Expired → Consumed)

## 📋 Story Metadata

- **Story ID**: 2.10 | **Complexity**: 3 (S — getter calculé + badge widget + refresh midnight)
- **Story Key**: 2-10-track-product-status-lifecycle-fresh-expiring-expired-consumed
- **Status**: ready-for-dev | **Effort**: 1 day
- **Dependencies**: Story 2.1 (`ProductEntity`, `ExpirationDateType`), Story 2.4 (`consumedAt` field, HiveField 15)
- **Référencé par**: Story 2.3 (`_StatusBadge`), Story 2.7 (`statusFilterProvider`, `p.status`)

---

## 📖 User Story

**As a** utilisateur,
**I want** to see the current status of each product visually,
**So that** I can quickly identify what needs to be used soon and what is still fresh.

---

## ✅ Acceptance Criteria

### AC1: Calcul du statut par produit
**Given** un produit a une `expirationDate` et `expirationDateType`
**When** son statut est évalué
**Then** le statut est calculé comme suit:
- `consumedAt != null` → `ProductStatus.consumed`
- `expirationDate < DateTime.now()` → `ProductStatus.expired`
- `expirationDate ≤ now + threshold(type)` → `ProductStatus.expiringSoon`
  - DLC: threshold = 2 jours (configurable Story 3.4)
  - DDM: threshold = 5 jours (configurable Story 3.5)
- Sinon → `ProductStatus.fresh`

### AC2: Badge visuel dans la liste
**Given** je vois un produit dans `InventoryListScreen`
**When** je regarde la carte produit (ProductCard)
**Then** un badge coloré est visible:
- `fresh` → badge vert (🟢) + texte ex. "Frais · 12j"
- `expiringSoon` → badge orange (🟡) + texte ex. "Expire dans 2j"
- `expired` → badge rouge (🔴) + texte "Expiré"
- `consumed` → badge gris + texte "Consommé"

### AC3: Refresh automatique à minuit
**Given** l'application est en foreground ou se réouvre
**When** la date change (minuit)
**Then** les statuts sont recalculés automatiquement
**And** les badges dans la liste se mettent à jour
**And** si un produit passe à `expired` ou `expiringSoon`, cela trigger les providers concernés

### AC4: Threshold configurable (préparation Stories 3.4/3.5)
**Given** le calcul du statut
**When** `expirationDateType = DLC`
**Then** le seuil "expiringSoon" est 2 jours (valeur par défaut lue depuis `RemoteConfigService`)
**When** `expirationDateType = DDM`
**Then** le seuil "expiringSoon" est 5 jours (valeur par défaut lue depuis `RemoteConfigService`)

---

## 🏗️ Technical Specifications

### ProductStatus enum

```dart
// lib/features/inventory/domain/entities/product_entity.dart
// (ou lib/features/inventory/domain/enums/product_status.dart)

enum ProductStatus {
  fresh,
  expiringSoon,
  expired,
  consumed,
}
```

### ProductStatusService

```dart
// lib/features/inventory/domain/services/product_status_service.dart

class ProductStatusService {
  /// Seuils par défaut (jours avant expiration)
  static const int _dlcThresholdDays = 2;   // configurable Story 3.4
  static const int _ddmThresholdDays = 5;   // configurable Story 3.5

  ProductStatus computeStatus(ProductEntity product) {
    // 1. Consommé
    if (product.consumedAt != null) return ProductStatus.consumed;

    // 2. Pas de date d'expiration → fresh par défaut
    final expDate = product.expirationDate;
    if (expDate == null) return ProductStatus.fresh;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(expDate.year, expDate.month, expDate.day);
    final daysRemaining = expiryDay.difference(today).inDays;

    // 3. Expiré
    if (daysRemaining < 0) return ProductStatus.expired;

    // 4. Expire bientôt
    final threshold = product.expirationDateType == ExpirationDateType.ddm
        ? _ddmThresholdDays
        : _dlcThresholdDays;
    if (daysRemaining <= threshold) return ProductStatus.expiringSoon;

    // 5. Frais
    return ProductStatus.fresh;
  }

  /// Texte descriptif pour le badge
  String statusLabel(ProductEntity product) {
    final expDate = product.expirationDate;
    final status = computeStatus(product);

    switch (status) {
      case ProductStatus.consumed:
        return 'Consommé';
      case ProductStatus.expired:
        return 'Expiré';
      case ProductStatus.expiringSoon:
        if (expDate == null) return 'Expire bientôt';
        final daysRemaining = DateTime(expDate.year, expDate.month, expDate.day)
            .difference(DateTime.now().withoutTime)
            .inDays;
        return daysRemaining == 0
            ? "Expire aujourd'hui"
            : 'Expire dans ${daysRemaining}j';
      case ProductStatus.fresh:
        if (expDate == null) return 'Frais';
        final daysRemaining = DateTime(expDate.year, expDate.month, expDate.day)
            .difference(DateTime.now().withoutTime)
            .inDays;
        return 'Frais · ${daysRemaining}j';
    }
  }
}

extension DateTimeX on DateTime {
  DateTime get withoutTime => DateTime(year, month, day);
}
```

### Extension sur ProductEntity — computed `status` getter

```dart
// lib/features/inventory/domain/entities/product_entity.dart
// Ajouter extension (ou méthode dans la classe Freezed)

extension ProductEntityStatusX on ProductEntity {
  ProductStatus get status {
    // Utilise ProductStatusService de façon statique (ou injection si nécessaire)
    return const ProductStatusService().computeStatus(this);
  }
}
```

> **Note**: Le getter `status` est calculé (non persisté dans Hive). Cela garantit qu'il est toujours à jour sans sync.

### Riverpod Provider

```dart
// lib/features/inventory/presentation/providers/inventory_providers.dart

final productStatusServiceProvider = Provider<ProductStatusService>(
  (_) => const ProductStatusService(),
);
```

### _StatusBadge Widget (référencé Story 2.3)

```dart
// lib/features/inventory/presentation/widgets/status_badge.dart

class StatusBadge extends StatelessWidget {
  final ProductEntity product;

  const StatusBadge({super.key, required this.product});

  static const Map<ProductStatus, Color> _colors = {
    ProductStatus.fresh:        Color(0xFF4CAF50),  // green
    ProductStatus.expiringSoon: Color(0xFFFF9800),  // orange
    ProductStatus.expired:      Color(0xFFF44336),  // red
    ProductStatus.consumed:     Color(0xFF9E9E9E),  // grey
  };

  static const Map<ProductStatus, IconData> _icons = {
    ProductStatus.fresh:        Icons.check_circle_outline,
    ProductStatus.expiringSoon: Icons.access_time,
    ProductStatus.expired:      Icons.error_outline,
    ProductStatus.consumed:     Icons.check_circle,
  };

  @override
  Widget build(BuildContext context) {
    final service = const ProductStatusService();
    final status = service.computeStatus(product);
    final label = service.statusLabel(product);
    final color = _colors[status]!;
    final icon = _icons[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Midnight Refresh — StatusRefreshService

```dart
// lib/features/inventory/domain/services/status_refresh_service.dart

/// Invalide les providers inventory à minuit pour forcer un recalcul des statuts.
class StatusRefreshService {
  Timer? _timer;
  final Ref _ref;

  StatusRefreshService(this._ref);

  void start() {
    _scheduleNextMidnight();
  }

  void _scheduleNextMidnight() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);

    _timer = Timer(duration, () {
      // Invalide le provider racine — déclenche recalcul de tous les statuts
      _ref.invalidate(inventoryStreamProvider);
      _scheduleNextMidnight(); // Re-planifie pour le lendemain
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Provider
final statusRefreshServiceProvider = Provider<StatusRefreshService>((ref) {
  final service = StatusRefreshService(ref);
  service.start();
  ref.onDispose(service.dispose);
  return service;
});
```

> **Usage**: `ref.watch(statusRefreshServiceProvider)` dans `InventoryListScreen` ou dans `main.dart` pour activer le timer.

---

## 📝 Implementation Tasks

- [ ] **T1**: Définir `ProductStatus` enum (fresh, expiringSoon, expired, consumed)
- [ ] **T2**: Créer `ProductStatusService.computeStatus()` + `statusLabel()`
- [ ] **T3**: Ajouter extension `status` getter sur `ProductEntity`
- [ ] **T4**: Créer `StatusBadge` widget (icône + texte coloré)
- [ ] **T5**: Intégrer `StatusBadge` dans `ProductCard` (Story 2.1)
- [ ] **T6**: Créer `StatusRefreshService` + provider (timer midnight)
- [ ] **T7**: Activer `statusRefreshServiceProvider` dans `InventoryListScreen`
- [ ] **T8**: Tests unitaires `ProductStatusService` — tous les cas limites
- [ ] **T9**: Tests widget `StatusBadge` — badge correct par statut
- [ ] **T10**: `flutter analyze` 0 erreurs | couverture ≥ 75%

---

## 🧪 Testing Strategy

```dart
group('ProductStatusService', () {
  final service = ProductStatusService();

  test('consumed product → consumed status', () {
    final product = ProductEntity(..., consumedAt: DateTime.now());
    expect(service.computeStatus(product), ProductStatus.consumed);
  });

  test('DLC expired yesterday → expired', () {
    final product = ProductEntity(...,
      expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      expirationDateType: ExpirationDateType.dlc,
    );
    expect(service.computeStatus(product), ProductStatus.expired);
  });

  test('DLC expires in 1 day → expiringSoon (threshold=2)', () {
    final product = ProductEntity(...,
      expirationDate: DateTime.now().add(const Duration(days: 1)),
      expirationDateType: ExpirationDateType.dlc,
    );
    expect(service.computeStatus(product), ProductStatus.expiringSoon);
  });

  test('DDM expires in 4 days → expiringSoon (threshold=5)', () {
    final product = ProductEntity(...,
      expirationDate: DateTime.now().add(const Duration(days: 4)),
      expirationDateType: ExpirationDateType.ddm,
    );
    expect(service.computeStatus(product), ProductStatus.expiringSoon);
  });

  test('DLC expires in 10 days → fresh', () {
    final product = ProductEntity(...,
      expirationDate: DateTime.now().add(const Duration(days: 10)),
      expirationDateType: ExpirationDateType.dlc,
    );
    expect(service.computeStatus(product), ProductStatus.fresh);
  });

  test('null expirationDate → fresh', () {
    final product = ProductEntity(..., expirationDate: null);
    expect(service.computeStatus(product), ProductStatus.fresh);
  });

  test('statusLabel for expiringSoon 2 days → "Expire dans 2j"', () {
    final product = ProductEntity(...,
      expirationDate: DateTime.now().add(const Duration(days: 2)),
      expirationDateType: ExpirationDateType.dlc,
    );
    expect(service.statusLabel(product), 'Expire dans 2j');
  });
});

group('StatusBadge widget', () {
  testWidgets('shows green badge for fresh product', (tester) async { ... });
  testWidgets('shows orange badge for expiringSoon product', (tester) async { ... });
  testWidgets('shows red badge for expired product', (tester) async { ... });
});
```

---

## ⚠️ Anti-Patterns à Éviter

```dart
// ❌ Stocker le status dans Hive (devient stale sans sync quotidienne)
HiveField(16) final ProductStatus status;  // ❌

// ✅ Calculer à la volée dans un getter — toujours frais, 0 storage
extension ProductEntityStatusX on ProductEntity {
  ProductStatus get status => const ProductStatusService().computeStatus(this);  // ✅
}

// ❌ Timer.periodic(Duration(hours: 1), ...) — trop fréquent pour rien
// ✅ Timer ciblé vers le prochain minuit — refresh précis, économe en batterie
```

---

## 🔗 Points d'Intégration

- **Story 2.3** : `_StatusBadge` dans `ProductCard` — utilisé pour l'indicateur rouge des produits expirés
- **Story 2.4** : `consumedAt != null` → `ProductStatus.consumed` — `filteredInventoryProvider` exclut les consumed
- **Story 2.7** : `statusFilterProvider` filtre sur `p.status` — dépend de ce getter
- **Epic 3** : `StatusRefreshService` invalide les providers → les notification providers réagissent
- **Stories 3.4/3.5** : Threshold DLC/DDM sera lu depuis Riverpod providers configurables (actuellement constante)

---

## ✅ Definition of Done

- [ ] `ProductStatus` enum défini
- [ ] `ProductStatusService` avec logique DLC/DDM + labels
- [ ] Extension `status` getter sur `ProductEntity`
- [ ] `StatusBadge` widget intégré dans `ProductCard`
- [ ] `StatusRefreshService` — refresh automatique à minuit
- [ ] Tests edge cases (consumed, expired, expiringSoon DLC/DDM, fresh, null date)
- [ ] `flutter analyze` 0 erreurs | couverture ≥ 75%

---

**Story Created**: 2026-02-21 | **Ready for Dev**: ✅ Oui
