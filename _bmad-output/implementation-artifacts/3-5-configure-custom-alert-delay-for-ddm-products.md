# Story 3.5: Configure Custom Alert Delay for DDM Products

Status: ready-for-dev

## Story

As a Sophie (famille),
I want to adjust when I receive alerts for DDM products,
so that I can balance reducing waste with not getting too many notifications.

## Acceptance Criteria

1. **Given** I am in the notifications settings screen (créé Story 3.4)
   **When** I view the DDM alert delay setting
   **Then** I see a slider/picker with values 3–14 days
   **And** the current value defaults to 5 days if never configured

2. **Given** I change the DDM delay to 7 days
   **When** the daily background task runs
   **Then** DDM products expiring in exactly 7 days trigger notifications
   **And** not in 5 days (old threshold)

3. **Given** I tap "Remettre par défaut"
   **Then** the DDM delay resets to 5 days

## Tasks / Subtasks

- [ ] **T1**: Étendre `NotificationSettingsRepository` (Story 3.4) (AC: 1, 2)
  - [ ] `getDdmAlertDays()` → int (default: 5)
  - [ ] `setDdmAlertDays(int days)` — range 3–14
  - [ ] `resetDdmAlertDays()`

- [ ] **T2**: Ajouter `ddmAlertDaysProvider` StateProvider (AC: 1)

- [ ] **T3**: Ajouter section DDM dans `NotificationSettingsScreen` (Story 3.4) (AC: 1, 3)
  - [ ] Slider 3–14 jours + label + reset button
  - [ ] Section sous la section DLC

- [ ] **T4**: Mettre à jour `ExpirationAlertService.getProductsForDdmAlert()` (AC: 2)
  - [ ] `_ddmAlertDays` lu depuis `NotificationSettingsRepository`

- [ ] **T5**: Tests unitaires + flutter analyze 0 erreurs

## Dev Notes

### NotificationSettingsRepository extension

```dart
static const String _ddmDaysKey = 'ddm_alert_days';
static const int _ddmDefault = 5;

int getDdmAlertDays() => (_box.get(_ddmDaysKey) as int?) ?? _ddmDefault;

Future<void> setDdmAlertDays(int days) async {
  assert(days >= 3 && days <= 14);
  await _box.put(_ddmDaysKey, days);
}

Future<void> resetDdmAlertDays() => setDdmAlertDays(_ddmDefault);
```

### ddmAlertDaysProvider

```dart
final ddmAlertDaysProvider = StateProvider<int>((ref) {
  return ref.watch(notificationSettingsRepositoryProvider).getDdmAlertDays();
});
```

### Section DDM dans NotificationSettingsScreen

```dart
class _DdmAlertSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(ddmAlertDaysProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Alerte DDM', style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 8),
            Text('Vous serez alerté $days jour(s) avant la DDM'),
            Slider(
              value: days.toDouble(),
              min: 3,
              max: 14,
              divisions: 11,
              label: '$days j',
              onChanged: (v) {
                final newDays = v.round();
                ref.read(ddmAlertDaysProvider.notifier).state = newDays;
                ref.read(notificationSettingsRepositoryProvider)
                    .setDdmAlertDays(newDays);
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ref.read(notificationSettingsRepositoryProvider).resetDdmAlertDays();
                  ref.read(ddmAlertDaysProvider.notifier).state = 5;
                },
                child: const Text('Remettre par défaut (5 j)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### References

- [Source: epics.md#Story-3.5]
- Même pattern que Story 3.4 — même écran, même repository
- DDM default = 5 jours [Source: epics.md#Story-3.2]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
