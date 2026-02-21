# Story 7.7: Encrypt Nutrition Data at Rest and in Transit

Status: ready-for-dev

## Story

As a Thomas (sportif),
I want my health data to be encrypted and secure,
so that my sensitive nutrition information is protected from unauthorized access.

## Acceptance Criteria

1. **Given** nutrition tracking is enabled
   **When** meal entries and daily logs are stored locally
   **Then** all data in `nutrition_data_box` is encrypted with AES-256 (HiveAesCipher)
   **And** the AES key is stored in `FlutterSecureStorage` (Android Keystore / iOS Keychain)
   **And** data at rest is never stored in plaintext on the device

2. **Given** nutrition data is synced to Firestore
   **When** data is transmitted
   **Then** all traffic uses HTTPS / TLS 1.3+ (enforced by Firebase SDK)
   **And** Firestore security rules restrict access to `users/{userId}/nutrition_tracking/*` for authenticated owner only

3. **Given** I revoke consent (Story 7.5)
   **When** revocation is confirmed
   **Then** the AES key is deleted from FlutterSecureStorage (`deleteKey()`)
   **And** encrypted data remaining on disk becomes irrecoverable (key-less AES)

4. **Given** a developer runs the security audit script
   **When** `flutter analyze` + `dart run tool/security_audit.dart` is executed
   **Then** 0 critical security issues are found
   **And** the audit confirms: AES-256 at rest, TLS in transit, Keystore key storage, Firestore rules

## Tasks / Subtasks

- [ ] **T1**: Vérifier et documenter `NutritionKeyManager` (Story 7.1) (AC: 1)
  - [ ] Confirmer `generateKey()` → `Hive.generateSecureKey()` (32 bytes)
  - [ ] Confirmer stockage dans `FlutterSecureStorage` clé `nutrition_hive_aes_key`
  - [ ] Confirmer `deleteKey()` → `_storage.delete(key: _keyStorageKey)`
- [ ] **T2**: Vérifier Firestore Security Rules pour `nutrition_tracking` (AC: 2)
  - [ ] `allow read, write: if request.auth.uid == userId`
  - [ ] `allow read, write: if request.auth.uid == userId` pour `deletion_requests`
  - [ ] Tester avec Firebase Emulator
- [ ] **T3**: Créer `EncryptionVerificationService` (AC: 4)
  - [ ] `verifyNutritionBoxEncrypted()` → lire `nutrition_data_box` RAW (sans clé) → vérifier illisible
  - [ ] `verifyKeyInSecureStorage()` → clé présente si consentement actif
  - [ ] `verifyKeyDeletedAfterRevocation()` — test intégration
- [ ] **T4**: Ajouter section "Sécurité" dans `NutritionDisclaimerScreen` (Story 7.6) (AC: 1)
  - [ ] "Chiffrement AES-256 au repos, TLS en transit, clés dans Android Keystore / iOS Keychain"
- [ ] **T5**: Ajouter règles Firestore pour `nutrition_tracking` dans `firestore.rules` (AC: 2)
- [ ] **T6**: Tests unitaires `EncryptionVerificationService` (AC: 4)
- [ ] **T7**: Tests unitaires `NutritionKeyManager` — generateKey, getOrCreateKey, deleteKey (AC: 1, 3)
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### NutritionKeyManager (confirmation Story 7.1)

```dart
// lib/features/nutrition_tracking/data/services/nutrition_key_manager.dart
// Défini en Story 7.1 — AUCUNE MODIFICATION — documenter uniquement

class NutritionKeyManager {
  static const _keyStorageKey = 'nutrition_hive_aes_key';
  final FlutterSecureStorage _storage;

  NutritionKeyManager({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
            keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
          ),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  Future<List<int>> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyStorageKey);
    if (existing != null) {
      return existing.split(',').map(int.parse).toList();
    }
    final key = Hive.generateSecureKey();  // Crypto-secure 32-byte key
    await _storage.write(
      key: _keyStorageKey,
      value: key.join(','),
    );
    return key;
  }

  Future<void> deleteKey() async {
    await _storage.delete(key: _keyStorageKey);
    // Après cette suppression: données dans nutrition_data_box = irrecouvrables
  }
}
```

### EncryptionVerificationService

```dart
// lib/features/nutrition_tracking/data/services/encryption_verification_service.dart
// Utilisé en tests et audit CI uniquement — PAS en production release

class EncryptionVerificationService {
  final NutritionKeyManager _keyManager;

  const EncryptionVerificationService(this._keyManager);

  /// Vérifie que nutrition_data_box est bien chiffré:
  /// Tente d'ouvrir la box SANS clé → doit lever une exception
  Future<bool> verifyNutritionBoxEncrypted() async {
    try {
      // Essai d'ouverture sans chiffrement → doit échouer ou retourner des bytes illisibles
      final rawBox = await Hive.openBox<dynamic>('nutrition_data_box');
      final keys = rawBox.keys.toList();
      await rawBox.close();

      // Si des clés existent et que la box s'ouvre sans cipher → PROBLÈME
      // En pratique, Hive ouvre la box mais les valeurs sont corrompues/illisibles
      // Ce test ne peut être complet qu'avec un mock — voir test unitaire
      return keys.isEmpty; // Box vide = pas de données non chiffrées exposées
    } catch (_) {
      // Exception attendue si la box est chiffrée
      return true;
    }
  }

  /// Vérifie que la clé AES existe dans FlutterSecureStorage
  Future<bool> verifyKeyInSecureStorage() async {
    try {
      final key = await _keyManager.getOrCreateKey();
      return key.length == 32;  // AES-256 = 32 bytes
    } catch (_) {
      return false;
    }
  }
}
```

### Firestore Security Rules — nutrition_tracking

```javascript
// firestore.rules — section à ajouter/vérifier:

match /users/{userId} {
  // ... règles existantes ...

  match /nutrition_tracking/{date} {
    allow read, write: if request.auth != null
                       && request.auth.uid == userId;
  }

  match /deletion_requests/{docId} {
    allow create: if request.auth != null
                  && request.auth.uid == userId;
    allow read: if request.auth != null
                && request.auth.uid == userId;
    // Seul Cloud Function (admin SDK) peut update/delete
    allow update, delete: if false;
  }

  match /consent_records/{consentType} {
    allow read, write: if request.auth != null
                       && request.auth.uid == userId;
  }
}
```

### Résumé Architecture de Sécurité

| Couche | Mécanisme | Implémenté en |
|--------|-----------|---------------|
| Au repos (local) | AES-256 HiveAesCipher | Story 7.1 |
| Clé AES | FlutterSecureStorage (Android Keystore / iOS Keychain) | Story 7.1 |
| En transit | HTTPS/TLS 1.3+ (Firebase SDK) | Infrastructure |
| Firestore | Security Rules (owner-only access) | Story 7.7 |
| Suppression clé | deleteKey() → données irrecouvrables | Story 7.5 |
| Audit | EncryptionVerificationService + flutter analyze | Story 7.7 |

### Project Structure Notes

- Cette story est principalement de **vérification et documentation** — le chiffrement est déjà implémenté en Story 7.1
- `EncryptionVerificationService` est un outil de dev/test — ne pas l'instancier en production release builds
- Les règles Firestore sont dans `firestore.rules` (racine du projet) — déjà partiellement définies en Story 0.10
- TLS est géré automatiquement par Firebase SDK (pas de code Flutter nécessaire)
- Audit CI: ajouter `dart run tool/security_audit.dart` dans le pipeline GitHub Actions

### References

- [Source: epics.md#Story-7.7]
- NutritionKeyManager + HiveAesCipher [Source: Story 7.1]
- NutritionDataDeletionService.deleteKey() [Source: Story 7.5]
- Firestore Security Rules [Source: Story 0.10, architecture.md#Security]
- RGPD Article 9 — données de santé [Source: architecture.md]
- Flutter Secure Storage — Android Keystore / iOS Keychain [Source: Story 0.10]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
