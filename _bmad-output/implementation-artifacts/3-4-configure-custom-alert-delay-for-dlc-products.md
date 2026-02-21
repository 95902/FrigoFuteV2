# Story 3.4: Configure Custom Alert Delay for DLC Products

Status: ready-for-dev

## Story

As a Thomas (sportif),
I want to adjust when I receive alerts for DLC products (e.g., 3 days instead of 2),
so that I have more flexibility based on my meal prep schedule.

## Acceptance Criteria

1. **Given** I am in the notifications settings screen
   **When** I view the DLC alert delay setting
   **Then** I see a slider/picker with values 1–7 days
   **And** the current value defaults to 2 days if never configured
   **And** a preview shows "Vous serez alerté X jour(s) avant la DLC"

2. **Given** I change the DLC delay to 3 days and save
   **When** the daily background task runs
   **Then** DLC products expiring in exactly 3 days trigger notifications
   **And** not in 2 days (old threshold)

3. **Given** I tap "Remettre par défaut"
   **Then** the DLC delay resets to 2 days
   **And** a confirmation snackbar appears

## Tasks / Subtasks

- [ ] **T1**: Créer `NotificationSettingsRepository` (Hive) (AC: 1, 2)
  - [ ] `lib/features/notifications/data/repositories/notification_settings_repository.dart`
  - [ ] `getDlcAlertDays()` → int (default: 2)
  - [ ] `setDlcAlertDays(int days)` — persiste dans Hive box `notification_settings`
  - [ ] `resetDlcAlertDays()` → remet à 2

- [ ] **T2**: Créer Riverpod providers (AC: 1, 2)
  - [ ] `dlcAlertDaysProvider` — StateProvider<int> initialisé depuis Hive
  - [ ] `notificationSettingsRepositoryProvider`

- [ ] **T3**: Créer `NotificationSettingsScreen` (AC: 1, 3)
  - [ ] `lib/features/notifications/presentation/screens/notification_settings_screen.dart`
  - [ ] Section DLC: Slider (1–7) + label "X jour(s) avant la DLC" + bouton reset
  - [ ] AppBar: "Paramètres des alertes"
  - [ ] GoRouter route: `/settings/notifications`

- [ ] **T4**: Mettre à jour `ExpirationAlertService` (AC: 2)
  - [ ] `_dlcAlertDays` lu depuis `NotificationSettingsRepository` (non plus constante)
  - [ ] `getProductsForDlcAlert()` utilise valeur dynamique

- [ ] **T5**: Tests unitaires (AC: 1, 2)
- [ ] **T6**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### NotificationSettingsRepository

```dart
// lib/features/notifications/data/repositories/notification_settings_repository.dart

class NotificationSettingsRepository {
  static const String _dlcDaysKey = 'dlc_alert_days';
  static const int _dlcDefault = 2;

  final Box<dynamic> _box;  // Hive box 'notification_settings'

  NotificationSettingsRepository(this._box);

  int getDlcAlertDays() => (_box.get(_dlcDaysKey) as int?) ?? _dlcDefault;

  Future<void> setDlcAlertDays(int days) async {
    assert(days >= 1 && days <= 7, 'DLC delay must be 1-7 days');
    await _box.put(_dlcDaysKey, days);
  }

  Future<void> resetDlcAlertDays() => setDlcAlertDays(_dlcDefault);
}
```

### Riverpod Providers

```dart
final notificationSettingsBoxProvider = Provider<Box<dynamic>>((ref) {
  return Hive.box<dynamic>('notification_settings');
});

final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepository(
    ref.watch(notificationSettingsBoxProvider),
  );
});

final dlcAlertDaysProvider = StateProvider<int>((ref) {
  return ref.watch(notificationSettingsRepositoryProvider).getDlcAlertDays();
});
```

### NotificationSettingsScreen — Section DLC

```dart
class _DlcAlertSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(dlcAlertDaysProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.red),
                const SizedBox(width: 8),
                Text('Alerte DLC', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text('Vous serez alerté $days jour(s) avant la DLC'),
            Slider(
              value: days.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              label: '$days j',
              onChanged: (v) {
                final newDays = v.round();
                ref.read(dlcAlertDaysProvider.notifier).state = newDays;
                ref.read(notificationSettingsRepositoryProvider)
                    .setDlcAlertDays(newDays);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(notificationSettingsRepositoryProvider).resetDlcAlertDays();
                    ref.read(dlcAlertDaysProvider.notifier).state = 2;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Délai DLC remis à 2 jours')),
                    );
                  },
                  child: const Text('Remettre par défaut'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### ExpirationAlertService — mise à jour

```dart
// Remplacer constante par valeur dynamique
class ExpirationAlertService {
  final NotificationSettingsRepository _settings;

  List<ProductEntity> getProductsForDlcAlert() {
    final dlcDays = _settings.getDlcAlertDays();  // Dynamique
    final alertDate = DateTime.now().withoutTime.add(Duration(days: dlcDays));
    // ... reste identique
  }
}
```

### Hive Box Registration

```dart
await Hive.openBox<dynamic>('notification_settings');
```

### GoRouter Route

```dart
GoRoute(
  path: '/settings/notifications',
  builder: (_, __) => const NotificationSettingsScreen(),
),
```

### Project Structure Notes

- `NotificationSettingsScreen` hébergera aussi Story 3.5, 3.6, 3.7 (sections supplémentaires)
- Route `/settings/notifications` accessible depuis les Settings généraux de l'app
- Hive box `notification_settings` ouverte en mode `Box<dynamic>` pour stocker int, bool, String

### References

- [Source: epics.md#Story-3.4]
- DLC threshold default = 2 jours [Source: epics.md#Story-3.1]
- ExpirationAlertService défini Story 3.1

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
