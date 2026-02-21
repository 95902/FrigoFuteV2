# Story 3.8: View Disclaimer About Expiration Alert Responsibility

Status: ready-for-dev

## Story

As a utilisateur,
I want to understand that I am responsible for verifying product freshness visually,
so that I use the app as a helpful tool but make my own final decisions.

## Acceptance Criteria

1. **Given** I use the expiration alerts feature for the first time
   **When** I open the notifications settings screen or receive my first DLC notification
   **Then** I see a clear disclaimer dialog/screen before continuing
   **And** the disclaimer text reads exactly:
   > "Les alertes d'expiration sont indicatives et basées sur les dates que vous avez saisies. FrigoFute ne garantit pas la fraîcheur des produits. Vérifiez toujours visuellement et par l'odorat avant de consommer. Vous êtes responsable de votre sécurité alimentaire."

2. **Given** I see the disclaimer
   **Then** I must tap "J'ai compris et j'accepte" to proceed
   **And** tapping "Annuler" closes the feature and returns to the previous screen

3. **Given** I have already acknowledged the disclaimer
   **When** I open notifications settings or receive subsequent notifications
   **Then** the disclaimer is NOT shown again
   **And** the disclaimer is accessible via a "Voir le disclaimer" link in settings

4. **Given** the disclaimer was shown and acknowledged
   **When** I check the notification settings screen
   **Then** I see a "✅ Disclaimer accepté le {date}" indication
   **And** a link "Relire le disclaimer" shows it again (read-only, no re-acceptance needed)

## Tasks / Subtasks

- [ ] **T1**: Créer `DisclaimerRepository` (Hive) (AC: 1, 3)
  - [ ] `isDisclaimerAcknowledged()` → bool (Hive `notification_settings` box)
  - [ ] `acknowledgeDisclaimer()` — sauvegarde date de l'acknowledgement
  - [ ] `getAcknowledgementDate()` → DateTime?

- [ ] **T2**: Créer `ExpirationDisclaimerDialog` widget (AC: 1, 2)
  - [ ] AlertDialog avec texte disclaimer complet
  - [ ] Bouton "J'ai compris et j'accepte" (primary)
  - [ ] Bouton "Annuler" (secondary)
  - [ ] Non dismissible en tapant à côté (barrierDismissible: false)

- [ ] **T3**: Afficher le disclaimer au premier accès (AC: 1, 2)
  - [ ] Dans `NotificationSettingsScreen.initState()` ou via FutureProvider
  - [ ] Si `!isDisclaimerAcknowledged()` → `showDialog(ExpirationDisclaimerDialog)`
  - [ ] Si refus → `context.pop()` pour quitter le settings screen

- [ ] **T4**: Ajouter section disclaimer dans `NotificationSettingsScreen` (AC: 3, 4)
  - [ ] "✅ Disclaimer accepté le {date}" si acknowledged
  - [ ] TextButton "Relire le disclaimer" → `showDialog` en mode lecture seule

- [ ] **T5**: Tests widget disclaimer (AC: 1, 2, 3)
- [ ] **T6**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### DisclaimerRepository

```dart
// lib/features/notifications/data/repositories/disclaimer_repository.dart

class DisclaimerRepository {
  static const String _acknowledgedKey = 'disclaimer_acknowledged_date';

  final Box<dynamic> _box;

  DisclaimerRepository(this._box);

  bool isDisclaimerAcknowledged() => _box.containsKey(_acknowledgedKey);

  Future<void> acknowledgeDisclaimer() async {
    await _box.put(_acknowledgedKey, DateTime.now().toIso8601String());
  }

  DateTime? getAcknowledgementDate() {
    final stored = _box.get(_acknowledgedKey) as String?;
    return stored != null ? DateTime.parse(stored) : null;
  }
}
```

### ExpirationDisclaimerDialog

```dart
// lib/features/notifications/presentation/widgets/expiration_disclaimer_dialog.dart

class ExpirationDisclaimerDialog extends ConsumerWidget {
  final bool readOnly;

  const ExpirationDisclaimerDialog({super.key, this.readOnly = false});

  static const String _disclaimerText =
      'Les alertes d\'expiration sont indicatives et basées sur les dates '
      'que vous avez saisies. FrigoFute ne garantit pas la fraîcheur des produits. '
      'Vérifiez toujours visuellement et par l\'odorat avant de consommer. '
      'Vous êtes responsable de votre sécurité alimentaire.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.gpp_maybe, color: Colors.orange),
          SizedBox(width: 8),
          Text('Avertissement important'),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(_disclaimerText),
      ),
      actions: [
        if (!readOnly) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(disclaimerRepositoryProvider)
                  .acknowledgeDisclaimer();
              if (context.mounted) Navigator.of(context).pop(true);
            },
            child: const Text('J\'ai compris et j\'accepte'),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ],
    );
  }
}
```

### Affichage au premier accès (NotificationSettingsScreen)

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final repo = ref.read(disclaimerRepositoryProvider);
    if (!repo.isDisclaimerAcknowledged()) {
      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const ExpirationDisclaimerDialog(),
      );
      if (accepted != true && mounted) {
        context.pop();  // GoRouter — retour si refus
      }
    }
  });
}
```

### Section disclaimer dans NotificationSettingsScreen

```dart
class _DisclaimerSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(disclaimerRepositoryProvider);
    final date = repo.getAcknowledgementDate();
    final dateStr = date != null
        ? DateFormat('dd/MM/yyyy', 'fr_FR').format(date)
        : '';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.verified_user_outlined, color: Colors.green),
        title: Text('✅ Disclaimer accepté le $dateStr'),
        subtitle: const Text('Vous avez accepté les conditions d\'utilisation des alertes'),
        trailing: TextButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ExpirationDisclaimerDialog(readOnly: true),
          ),
          child: const Text('Relire'),
        ),
      ),
    );
  }
}
```

### Riverpod Provider

```dart
final disclaimerRepositoryProvider = Provider<DisclaimerRepository>((ref) {
  return DisclaimerRepository(ref.watch(notificationSettingsBoxProvider));
});
```

### Project Structure Notes

- `DisclaimerRepository` utilise la même Hive box `notification_settings` que `NotificationSettingsRepository`
- `ExpirationDisclaimerDialog` dans `lib/features/notifications/presentation/widgets/`
- `barrierDismissible: false` est OBLIGATOIRE — l'utilisateur doit choisir explicitement
- Utiliser `DateFormat` du package `intl` déjà dans pubspec.yaml

### References

- [Source: epics.md#Story-3.8]
- Texte disclaimer exact requis (legal compliance)
- Voir Epic 16 (Story 16.3) pour le disclaimer général sur les alertes d'expiration

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
