# Story 3.2: Receive Push Notification for DDM Expiration (5 Days Before)

Status: ready-for-dev

## Story

As a Marie (senior),
I want to receive a reminder 5 days before a product's DDM (Date Durabilité Minimale) expires,
so that I can plan to use it even though it's not urgent.

## Acceptance Criteria

1. **Given** I have products with DDM expiration dates in my inventory
   **When** a product is exactly 5 days away from its DDM expiration date
   **Then** I receive a local notification with the product name and expiration date
   **And** the notification is marked as informational (standard priority, soft sound)

2. **Given** the DDM notification fires
   **When** I see the notification
   **Then** the body text clearly states "Best before" to distinguish from DLC ("Use by")
   **And** the tone is informational, not alarmist

3. **Given** I tap the DDM notification
   **Then** the app navigates to the product details screen (`/inventory/product/{id}`)

4. **Given** I already received a DDM notification for a product today
   **When** the daily background task runs again
   **Then** no duplicate notification is sent (same deduplication as Story 3.1)

5. **Given** DLC and DDM notifications both fire
   **Then** they are visually distinct (different channel, different sound, different icon/title)

## Tasks / Subtasks

- [ ] **T1**: Créer canal Android DDM (AC: 1, 5)
  - [ ] Channel ID: `expiration_ddm_info`, importance `IMPORTANCE_DEFAULT` (vs MAX pour DLC)
  - [ ] Son par défaut (pas de son urgent)

- [ ] **T2**: Implémenter `showDdmExpirationAlert()` dans `LocalNotificationService` (AC: 1, 2)
  - [ ] Titre: `ℹ️ DDM bientôt dépassée`
  - [ ] Corps: `{nom} — "À consommer de préférence avant le {date}". Vérifier avant de consommer.`
  - [ ] NotificationDetails Android: channel `expiration_ddm_info`, priority DEFAULT
  - [ ] Payload: `{"type":"ddm_expiry","productId":"{id}"}`

- [ ] **T3**: Étendre `ExpirationAlertService.getProductsForDdmAlert()` (AC: 1, 4)
  - [ ] Filtre: `expirationDateType == DDM && daysToExpiry == 5 && !consumed`
  - [ ] Déduplication via `notified_today` box (même mécanisme Story 3.1)

- [ ] **T4**: Étendre background task WorkManager (AC: 1)
  - [ ] Appeler `getProductsForDdmAlert()` + `showDdmExpirationAlert()` après le check DLC
  - [ ] Même fonction `expirationCheckBackgroundTask` — ajouter bloc DDM

- [ ] **T5**: Tests unitaires (AC: 1, 4, 5)
  - [ ] `getProductsForDdmAlert()` retourne DDM à 5j uniquement
  - [ ] Ne retourne PAS les DLC
  - [ ] Déduplication fonctionne
- [ ] **T6**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Extension ExpirationAlertService

```dart
static const int _ddmAlertDays = 5;  // Configurable via Story 3.5

List<ProductEntity> getProductsForDdmAlert() {
  final today = DateTime.now().withoutTime;
  final alertDate = today.add(Duration(days: _ddmAlertDays));

  return _inventoryBox.values
      .where((m) => m.expirationDateType == 'ddm')
      .where((m) => m.consumedAt == null && m.deletedAt == null)
      .where((m) {
        final exp = m.expirationDate;
        if (exp == null) return false;
        return DateTime(exp.year, exp.month, exp.day) == alertDate;
      })
      .where((m) => !_wasAlreadyNotifiedToday(m.id, today))
      .map((m) => m.toEntity())
      .toList();
}
```

### showDdmExpirationAlert

```dart
Future<void> showDdmExpirationAlert(ProductEntity product) async {
  await _plugin.show(
    'ddm_${product.id}'.hashCode,
    'ℹ️ DDM bientôt dépassée',
    '${product.name} — à consommer de préférence avant le ${product.formattedExpirationDate}',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'expiration_ddm_info',
        'Alertes DDM Informatives',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.passive,
      ),
    ),
    payload: '{"type":"ddm_expiry","productId":"${product.id}"}',
  );
}
```

### Différence DLC vs DDM

| | DLC (Story 3.1) | DDM (Story 3.2) |
|--|--|--|
| Seuil | 2 jours | 5 jours |
| Android Importance | MAX | DEFAULT |
| iOS InterruptionLevel | active | passive |
| Titre | ⚠️ DLC bientôt expiré ! | ℹ️ DDM bientôt dépassée |
| Ton | Urgent | Informatif |
| Canal | `expiration_dlc_urgent` | `expiration_ddm_info` |

### Project Structure Notes

- Même `LocalNotificationService` que Story 3.1 — ajouter méthode `showDdmExpirationAlert`
- Même `ExpirationAlertService` — ajouter méthode `getProductsForDdmAlert`
- Même background task — ajouter bloc DDM après bloc DLC

### References

- [Source: epics.md#Story-3.2]
- DDM threshold = 5 jours (configurable Story 3.5)
- Différenciation DLC/DDM dans l'UI = Story 3.3

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
