# Story 7.5: Withdraw Consent and Delete All Nutrition Data

Status: ready-for-dev

## Story

As a Marie (senior),
I want to stop nutrition tracking and delete all my health data if I change my mind,
so that I have full control over my sensitive information.

## Acceptance Criteria

1. **Given** I have previously consented to nutrition tracking
   **When** I navigate to Privacy Settings and tap "Révoquer le consentement nutritionnel"
   **Then** I see a confirmation dialog explaining all nutrition data will be deleted
   **And** deletion is scheduled within 30 days (RGPD compliance)

2. **Given** I confirm revocation
   **Then** nutrition features are immediately disabled in the app
   **And** local `nutrition_data_box` is cleared immediately
   **And** Firestore deletion is queued/scheduled

3. **Given** revocation is complete
   **Then** `nutritionConsentProvider` returns `false`
   **And** next time I navigate to `/nutrition`, I see the consent screen again

4. **Given** I want to re-enable nutrition tracking
   **Then** I can complete the double opt-in again (Story 7.1)
   **And** I start with a clean slate (no previous data)

## Tasks / Subtasks

- [ ] **T1**: Implémenter `NutritionConsentRepository.revokeConsent()` (AC: 1, 2)
  - [ ] Déjà défini dans Story 7.1 — vérifier l'implémentation
  - [ ] Marquer `revoked: true` dans settings_box + Firestore
- [ ] **T2**: Créer `NutritionDataDeletionService` (AC: 2)
  - [ ] `deleteAllLocalData()` → vider `nutrition_data_box` + fermer la box
  - [ ] `scheduleFirestoreDeletion()` → appeler Cloud Function ou marquer pour suppression dans 30j
  - [ ] Supprimer la clé AES depuis `flutter_secure_storage`
- [ ] **T3**: Créer `WithdrawConsentDialog` (AC: 1)
  - [ ] `AlertDialog(barrierDismissible: false)` — 2 étapes de confirmation
  - [ ] Étape 1: Explication + bouton "Confirmer la révocation"
  - [ ] Étape 2: "Êtes-vous sûr ? Cette action est irréversible (dans les 30 jours)"
- [ ] **T4**: Ajouter section "Confidentialité" dans Settings (AC: 1)
  - [ ] `ListTile` "Révoquer le consentement nutritionnel" → `WithdrawConsentDialog`
  - [ ] Route `/settings/privacy`
- [ ] **T5**: Invalider `nutritionConsentProvider` après révocation (AC: 3)
- [ ] **T6**: Tests unitaires `NutritionDataDeletionService` (AC: 2)
- [ ] **T7**: Tests widget `WithdrawConsentDialog` (AC: 1)
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### NutritionDataDeletionService

```dart
// lib/features/nutrition_tracking/data/services/nutrition_data_deletion_service.dart

class NutritionDataDeletionService {
  final NutritionConsentRepository _consentRepo;
  final NutritionKeyManager _keyManager;
  final FirebaseFirestore _firestore;
  final AuthService _auth;

  Future<void> revokeAndDelete() async {
    // 1. Révoquer le consentement
    await _consentRepo.revokeConsent();

    // 2. Vider et fermer nutrition_data_box (données locales)
    if (Hive.isBoxOpen('nutrition_data_box')) {
      final box = Hive.box<dynamic>('nutrition_data_box');
      await box.clear();   // Supprimer toutes les entrées
      await box.close();   // Fermer la box
    }

    // 3. Supprimer la clé AES (rend les données irrécupérables)
    await _keyManager.deleteKey();

    // 4. Programmer suppression Firestore (30 jours RGPD)
    await _scheduleFirestoreDeletion();
  }

  Future<void> _scheduleFirestoreDeletion() async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    // Marquer pour suppression via Cloud Function ou flag Firestore
    await _firestore
        .collection('users').doc(userId)
        .collection('deletion_requests')
        .add({
      'type': 'nutrition_data',
      'requestedAt': FieldValue.serverTimestamp(),
      'scheduledFor': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 30)),
      ),
      'status': 'pending',
    });
  }
}
```

### NutritionKeyManager — ajout deleteKey()

```dart
// Ajouter à NutritionKeyManager (Story 7.1):
Future<void> deleteKey() async {
  await _storage.delete(key: _keyStorageKey);
}
```

### WithdrawConsentDialog

```dart
// lib/features/nutrition_tracking/presentation/widgets/withdraw_consent_dialog.dart

class WithdrawConsentDialog extends ConsumerStatefulWidget {
  const WithdrawConsentDialog({super.key});

  @override
  ConsumerState<WithdrawConsentDialog> createState() => _WithdrawConsentDialogState();
}

class _WithdrawConsentDialogState extends ConsumerState<WithdrawConsentDialog> {
  bool _isLoading = false;
  int _step = 1;  // 2 étapes de confirmation

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: const [
        Icon(Icons.warning, color: Colors.red),
        SizedBox(width: 8),
        Text('Révoquer le consentement'),
      ]),
      content: _step == 1
          ? const Text(
              'Vous êtes sur le point de révoquer votre consentement au suivi nutritionnel.\n\n'
              '• Toutes vos données nutritionnelles seront supprimées de votre appareil immédiatement\n'
              '• Les données sur nos serveurs seront supprimées dans 30 jours (RGPD)\n'
              '• Vous pourrez ré-activer le suivi plus tard avec un nouveau consentement',
            )
          : const Text(
              'Êtes-vous CERTAIN de vouloir supprimer toutes vos données nutritionnelles ?\n\n'
              'Cette action supprimera :\n'
              '• Tous vos journaux de repas\n'
              '• Votre historique nutritionnel\n'
              '• Vos statistiques de suivi',
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _isLoading ? null : () async {
            if (_step == 1) {
              setState(() => _step = 2);
              return;
            }
            // Étape 2 — confirmation finale
            setState(() => _isLoading = true);
            try {
              await ref.read(nutritionDataDeletionServiceProvider).revokeAndDelete();
              ref.invalidate(nutritionConsentProvider);
              if (context.mounted) Navigator.pop(context, true);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
          child: _isLoading
              ? const SizedBox(height: 16, width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_step == 1 ? 'Continuer' : 'Confirmer la suppression'),
        ),
      ],
    );
  }
}
```

### Settings Privacy Section

```dart
// lib/features/settings/presentation/screens/privacy_settings_screen.dart

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNutritionConsent = ref.watch(nutritionConsentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Confidentialité')),
      body: ListView(
        children: [
          if (hasNutritionConsent)
            ListTile(
              leading: const Icon(Icons.no_food, color: Colors.red),
              title: const Text('Révoquer le consentement nutritionnel'),
              subtitle: const Text('Supprime toutes vos données de santé'),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const WithdrawConsentDialog(),
                );
                if (confirmed == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Données nutritionnelles supprimées')),
                  );
                }
              },
            ),
          // Autres paramètres privacy...
        ],
      ),
    );
  }
}
```

### Project Structure Notes

- 2 étapes de confirmation obligatoires (irreversible action — RGPD)
- Suppression locale IMMÉDIATE (Hive clear + clé AES effacée)
- Suppression Firestore DIFFÉRÉE 30 jours (RGPD Art. 17 — droit à l'effacement)
- Après révocation: `nutritionConsentProvider` retourne `false` → `NutritionGate` réaffiche le consentement

### References

- [Source: epics.md#Story-7.5]
- NutritionConsentRepository.revokeConsent() [Source: Story 7.1]
- NutritionKeyManager [Source: Story 7.1]
- nutrition_data_box [Source: Story 7.1]
- RGPD droit à l'effacement Article 17 [Source: architecture.md]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
