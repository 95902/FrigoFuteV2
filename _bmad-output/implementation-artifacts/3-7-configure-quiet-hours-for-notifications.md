# Story 3.7: Configure Quiet Hours for Notifications

Status: ready-for-dev

## Story

As a Lucas (étudiant),
I want to set quiet hours (e.g., 10 PM - 8 AM) when I don't receive notifications,
so that I can sleep without being disturbed by food alerts.

## Acceptance Criteria

1. **Given** I am in the notifications settings screen
   **When** I enable "Heures calmes"
   **Then** I see time pickers for start time and end time
   **And** defaults are 22:00 (start) and 08:00 (end) if never configured

2. **Given** quiet hours are enabled (e.g., 22:00–08:00)
   **When** the background task would schedule a notification during quiet hours
   **Then** the notification is delayed until the end of the quiet window (08:00 next day)
   **And** the notification still fires — it's delayed, not cancelled

3. **Given** quiet hours are enabled with "override DLC critique le jour J"
   **When** a DLC product expires TODAY (daysRemaining == 0)
   **Then** the DLC notification fires immediately regardless of quiet hours

4. **Given** I disable quiet hours
   **Then** notifications fire at the normal scheduled time immediately

## Tasks / Subtasks

- [ ] **T1**: Étendre `NotificationSettingsRepository` (AC: 1, 2)
  - [ ] `isQuietHoursEnabled()` → bool (default: false)
  - [ ] `getQuietHoursStart()` → `TimeOfDay` (default: 22:00)
  - [ ] `getQuietHoursEnd()` → `TimeOfDay` (default: 08:00)
  - [ ] `setQuietHours({bool enabled, TimeOfDay start, TimeOfDay end})`
  - [ ] Sérialiser TimeOfDay comme `{hour: int, minute: int}` JSON dans Hive

- [ ] **T2**: Ajouter `quietHoursProvider` StateProvider (AC: 1)

- [ ] **T3**: Ajouter section quiet hours dans `NotificationSettingsScreen` (AC: 1, 4)
  - [ ] `SwitchListTile` pour enable/disable
  - [ ] Deux `TimePickerButton` (heure début, heure fin) visibles si enabled
  - [ ] Toggle "Autoriser alertes DLC critiques malgré les heures calmes"

- [ ] **T4**: Implémenter `QuietHoursChecker` utility (AC: 2, 3)
  - [ ] `isInQuietHours(DateTime now)` → bool
  - [ ] `nextAllowedTime(DateTime now)` → DateTime (fin de quiet hours)

- [ ] **T5**: Mettre à jour `LocalNotificationService.showDlcExpirationAlert()` (AC: 2, 3)
  - [ ] Si quiet hours actif ET dans fenêtre ET pas override → utiliser `zonedSchedule` à `nextAllowedTime`
  - [ ] Si override critique → `show()` immédiatement

- [ ] **T6**: Tests unitaires `QuietHoursChecker` (AC: 2, 3)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### QuietHoursChecker

```dart
// lib/features/notifications/domain/services/quiet_hours_checker.dart

class QuietHoursChecker {
  final NotificationSettingsRepository _settings;

  QuietHoursChecker(this._settings);

  bool isCurrentlyInQuietHours() {
    if (!_settings.isQuietHoursEnabled()) return false;
    final now = TimeOfDay.now();
    return _isInWindow(now, _settings.getQuietHoursStart(), _settings.getQuietHoursEnd());
  }

  bool _isInWindow(TimeOfDay now, TimeOfDay start, TimeOfDay end) {
    final nowMins = now.hour * 60 + now.minute;
    final startMins = start.hour * 60 + start.minute;
    final endMins = end.hour * 60 + end.minute;

    // Window crosses midnight (e.g., 22:00–08:00)
    if (startMins > endMins) {
      return nowMins >= startMins || nowMins < endMins;
    }
    // Window within same day (e.g., 12:00–14:00)
    return nowMins >= startMins && nowMins < endMins;
  }

  /// Returns next DateTime when notifications are allowed again
  DateTime nextAllowedTime() {
    final endTime = _settings.getQuietHoursEnd();
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
    // If end time is in the past today, it's tomorrow
    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
```

### LocalNotificationService — check quiet hours

```dart
Future<void> showDlcExpirationAlert(ProductEntity product, {bool criticalOverride = false}) async {
  final quietChecker = QuietHoursChecker(_settings);

  if (!criticalOverride && quietChecker.isCurrentlyInQuietHours()) {
    // Utiliser zonedSchedule pour planifier à la fin des heures calmes
    final allowedTime = quietChecker.nextAllowedTime();
    await _plugin.zonedSchedule(
      product.id.hashCode,
      '⚠️ DLC bientôt expiré !',
      '${product.name} — vérifier avant de consommer',
      tz.TZDateTime.from(allowedTime, tz.local),
      NotificationDetails(android: _dlcNotificationDetails, iOS: _iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '{"type":"dlc_expiry","productId":"${product.id}"}',
    );
  } else {
    // Show immediately
    await _plugin.show(product.id.hashCode, '⚠️ DLC bientôt expiré !', ...);
  }
}
```

> **Note**: `zonedSchedule` requiert le package `timezone` → ajouter à pubspec.yaml:
> ```yaml
> timezone: ^0.9.0
> ```
> Et initialiser: `await tz.initializeTimeZones();` au démarrage.

### NotificationSettingsRepository — TimeOfDay serialization

```dart
static const String _quietHoursEnabledKey = 'quiet_hours_enabled';
static const String _quietHoursStartKey = 'quiet_hours_start';
static const String _quietHoursEndKey = 'quiet_hours_end';

bool isQuietHoursEnabled() => (_box.get(_quietHoursEnabledKey) as bool?) ?? false;

TimeOfDay getQuietHoursStart() {
  final stored = _box.get(_quietHoursStartKey) as String?;
  if (stored == null) return const TimeOfDay(hour: 22, minute: 0);
  final map = jsonDecode(stored) as Map<String, dynamic>;
  return TimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int);
}

TimeOfDay getQuietHoursEnd() {
  final stored = _box.get(_quietHoursEndKey) as String?;
  if (stored == null) return const TimeOfDay(hour: 8, minute: 0);
  final map = jsonDecode(stored) as Map<String, dynamic>;
  return TimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int);
}

Future<void> setQuietHoursEnabled(bool enabled) async =>
    _box.put(_quietHoursEnabledKey, enabled);

Future<void> setQuietHoursStart(TimeOfDay time) async =>
    _box.put(_quietHoursStartKey, jsonEncode({'hour': time.hour, 'minute': time.minute}));

Future<void> setQuietHoursEnd(TimeOfDay time) async =>
    _box.put(_quietHoursEndKey, jsonEncode({'hour': time.hour, 'minute': time.minute}));
```

### Tests QuietHoursChecker

```dart
group('QuietHoursChecker', () {
  test('22:00-08:00 window: 23:30 is inside', () { ... });
  test('22:00-08:00 window: 07:59 is inside', () { ... });
  test('22:00-08:00 window: 08:01 is outside', () { ... });
  test('nextAllowedTime returns tomorrow 08:00 when now is 23:00', () { ... });
  test('quiet hours disabled → isCurrentlyInQuietHours returns false', () { ... });
});
```

### References

- [Source: epics.md#Story-3.7]
- `timezone` package requis pour `zonedSchedule`
- TimeOfDay est de `package:flutter/material.dart` — safe to use in data layer via import

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
