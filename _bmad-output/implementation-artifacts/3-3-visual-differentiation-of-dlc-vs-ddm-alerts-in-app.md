# Story 3.3: Visual Differentiation of DLC vs DDM Alerts in App

Status: ready-for-dev

## Story

As a Lucas (étudiant),
I want to easily distinguish critical DLC alerts from informational DDM alerts,
so that I know which products absolutely must be consumed first.

## Acceptance Criteria

1. **Given** I have both DLC and DDM products expiring soon
   **When** I view alerts in the app (inventory list or notifications screen)
   **Then** DLC alerts are displayed with **red** background and **"URGENT"** label
   **And** DDM alerts are displayed with **yellow/orange** background and **"INFO"** label

2. **Given** a DLC product has expired
   **Then** it shows a red "EXPIRÉ — Ne pas consommer" warning
   **And** DDM expired product shows "Qualité peut être réduite — Vérifiez avant de consommer"

3. **Given** I see a DLC or DDM badge
   **When** I tap the info icon (ⓘ) next to the badge
   **Then** a bottom sheet/tooltip explains the difference:
   - DLC = "Date Limite de Consommation" — produit peut être dangereux après cette date
   - DDM = "Date de Durabilité Minimale" — qualité peut baisser mais consommable

4. **Given** the AlertTypeBadge widget is used in ProductCard (Story 2.1/2.10)
   **Then** it replaces or complements the existing `StatusBadge` from Story 2.10
   **And** shows both status (fresh/expiringSoon/expired) AND type (DLC/DDM)

## Tasks / Subtasks

- [ ] **T1**: Créer `AlertTypeBadge` widget (AC: 1, 2)
  - [ ] `lib/features/notifications/presentation/widgets/alert_type_badge.dart`
  - [ ] Afficher label DLC/DDM avec couleur et urgence différenciées
  - [ ] Cas expired DLC: texte "EXPIRÉ ⛔"
  - [ ] Cas expired DDM: texte "DDM DÉPASSÉE ⚠️"

- [ ] **T2**: Créer `ExpirationTypeInfoSheet` bottom sheet (AC: 3)
  - [ ] Icône ⓘ tapable → affiche `showModalBottomSheet`
  - [ ] Explication claire DLC vs DDM en français
  - [ ] Lien vers disclaimer (Story 3.8)

- [ ] **T3**: Intégrer dans `ProductCard` / `_StatusBadge` (Story 2.10) (AC: 4)
  - [ ] Afficher `AlertTypeBadge` sous ou à côté du `StatusBadge` existant
  - [ ] Visible uniquement si `expiringSoon` ou `expired`

- [ ] **T4**: Tests widget (AC: 1, 2, 3)
- [ ] **T5**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### AlertTypeBadge Widget

```dart
// lib/features/notifications/presentation/widgets/alert_type_badge.dart

class AlertTypeBadge extends StatelessWidget {
  final ProductEntity product;

  const AlertTypeBadge({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final status = product.status;

    // N'afficher que si expire bientôt ou expiré
    if (status == ProductStatus.fresh || status == ProductStatus.consumed) {
      return const SizedBox.shrink();
    }

    final isDLC = product.expirationDateType == ExpirationDateType.dlc;
    final isExpired = status == ProductStatus.expired;

    final String label;
    final Color color;
    final IconData icon;

    if (isExpired && isDLC) {
      label = 'EXPIRÉ ⛔';
      color = Colors.red.shade900;
      icon = Icons.block;
    } else if (isExpired && !isDLC) {
      label = 'DDM dépassée ⚠️';
      color = Colors.orange.shade800;
      icon = Icons.warning_amber;
    } else if (isDLC) {
      label = 'DLC · URGENT';
      color = Colors.red;
      icon = Icons.priority_high;
    } else {
      label = 'DDM · INFO';
      color = Colors.orange;
      icon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: () => _showInfoSheet(context, isDLC: isDLC),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.info_outline, size: 10, color: color.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context, {required bool isDLC}) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ExpirationTypeInfoSheet(isDLC: isDLC),
    );
  }
}
```

### ExpirationTypeInfoSheet

```dart
class ExpirationTypeInfoSheet extends StatelessWidget {
  final bool isDLC;

  const ExpirationTypeInfoSheet({super.key, required this.isDLC});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DLC vs DDM', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _InfoRow(
            color: Colors.red,
            icon: Icons.priority_high,
            title: 'DLC — Date Limite de Consommation',
            body: 'Indication de sécurité. Le produit peut présenter un risque sanitaire après cette date. '
                'Ex: viandes, poissons, laitages frais.',
            highlighted: isDLC,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            color: Colors.orange,
            icon: Icons.info_outline,
            title: 'DDM — Date de Durabilité Minimale',
            body: '"À consommer de préférence avant le...". Qualité peut baisser mais le produit reste '
                'consommable. Ex: pâtes, conserves, biscuits.',
            highlighted: !isDLC,
          ),
          const SizedBox(height: 16),
          Text(
            '⚠️ FrigoFute ne garantit pas la fraîcheur des produits. Vérifiez toujours visuellement.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
```

### Intégration dans ProductCard

```dart
// Dans ProductCard (lib/features/inventory/presentation/widgets/product_card.dart)
// Ajouter sous StatusBadge :
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    StatusBadge(product: product),     // Story 2.10
    const SizedBox(height: 4),
    AlertTypeBadge(product: product),  // Story 3.3 ← AJOUTER
  ],
),
```

### Project Structure Notes

- Widget dans `lib/features/notifications/presentation/widgets/` (feature notifications)
- Import croisé: accède à `ProductEntity` de `features/inventory/`
- La dépendance croisée features est acceptable via domain entities (pas de dépendance UI vers UI)

### References

- [Source: epics.md#Story-3.3]
- StatusBadge établi dans Story 2.10
- ProductEntity.expirationDateType défini dans Story 2.1

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
