# Story 7.1: Activate Nutrition Tracking with Double Opt-In

Status: ready-for-dev

## Story

As a Thomas (sportif),
I want to explicitly consent to nutrition tracking with clear information,
so that I understand how my health data will be used and stored.

## Acceptance Criteria

1. **Given** I navigate to the nutrition module for the first time (or tracking is not yet enabled)
   **When** the consent screen is displayed
   **Then** I see clearly:
   - Quelles données sont collectées (calories, macros, journaux repas, photos)
   - Comment elles sont utilisées (coaching nutritionnel personnalisé)
   - Comment elles sont stockées (chiffrées AES-256, conformes RGPD)
   - Mes droits (accès, suppression, retrait de consentement)
   **And** un disclaimer "Cette application n'est pas un dispositif médical" est affiché en évidence

2. **Given** I read the consent screen
   **When** I check the checkbox "J'accepte le traitement de mes données de santé"
   **And** I tap "Activer le suivi nutritionnel"
   **Then** mon consentement est enregistré avec timestamp (RGPD Article 9)
   **And** `nutrition_tracking_enabled` est activé dans les préférences locales
   **And** je suis redirigé vers le tableau de bord nutritionnel

3. **Given** I read the consent screen
   **When** I tap "Non merci" ou ferme l'écran sans cocher
   **Then** le suivi nutritionnel reste désactivé
   **And** je peux continuer à utiliser l'app normalement
   **And** aucune donnée de santé n'est collectée

4. **Given** nutrition tracking is enabled
   **When** I view the nutrition module
   **Then** `NutritionConsentRepository.hasConsented()` retourne `true`
   **And** le timestamp de consentement est accessible

## Tasks / Subtasks

- [ ] **T1**: Créer `NutritionConsentRepository` (AC: 2, 3, 4)
  - [ ] `ConsentRecord`: `userId`, `consentedAt` (DateTime), `version` (string, ex: "2026-01")
  - [ ] Stocker dans Hive `settings_box` (non-encrypté — métadonnée, pas donnée santé)
  - [ ] Syncer vers Firestore `users/{userId}/consent_records/nutrition_consent`
  - [ ] `hasConsented()` → `bool`
  - [ ] `recordConsent(String userId)` → `Future<void>`
  - [ ] `revokeConsent(String userId)` → `Future<void>` (Story 7.5)
- [ ] **T2**: Créer `NutritionConsentScreen` (AC: 1, 2, 3)
  - [ ] Scrollable content avec toutes les infos requises RGPD
  - [ ] Disclaimer médical en haut (rouge/orange)
  - [ ] `CheckboxListTile` "J'accepte..." — obligatoire pour activer le bouton
  - [ ] Bouton "Activer" (disabled si checkbox non cochée)
  - [ ] Bouton "Non merci" → ferme l'écran
  - [ ] `AlertDialog(barrierDismissible: false)` — ne peut pas être fermé par tap extérieur
- [ ] **T3**: Créer `nutritionConsentProvider = StreamProvider<bool>` (AC: 4)
  - [ ] Expose `hasConsented()` comme stream
  - [ ] Utilisé dans tout Epic 7 pour gater l'accès aux features
- [ ] **T4**: Créer `NutritionGate` widget (AC: 2, 3)
  - [ ] Si `!hasConsented` → afficher `NutritionConsentScreen` ou CTA
  - [ ] Si `hasConsented` → afficher le contenu enfant
  - [ ] Utilisé dans Stories 7.2, 7.3, etc. pour wrapper le contenu
- [ ] **T5**: Créer `NutritionTrackingModule` — point d'entrée Epic 7 (AC: 2)
  - [ ] Route `/nutrition` → `NutritionGate` → tableau de bord nutritionnel
- [ ] **T6**: Initialiser `nutrition_data_box` (ENCRYPTED) au premier consentement (AC: 2)
  - [ ] `await Hive.openBox<dynamic>('nutrition_data_box', encryptionCipher: HiveAesCipher(key))`
  - [ ] Clé AES-256 dérivée de `FirebaseAuth.instance.currentUser!.uid`
  - [ ] Clé stockée via `flutter_secure_storage` (pas en clair)
- [ ] **T7**: Vérifier feature flag `nutrition_tracking_enabled` (RemoteConfig) (AC: 1)
  - [ ] Si flag = false → afficher "Cette fonctionnalité arrive bientôt !"
  - [ ] Utiliser `featureFlagProvider('nutrition_tracking_enabled')` (Story 0.8)
- [ ] **T8**: Tests unitaires `NutritionConsentRepository` (AC: 2, 3, 4)
- [ ] **T9**: Tests widget `NutritionConsentScreen` — checkbox obligatoire (AC: 1, 2)
- [ ] **T10**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### ConsentRecord entity

```dart
// lib/features/nutrition_tracking/domain/entities/consent_record.dart

@freezed
class ConsentRecord with _$ConsentRecord {
  const factory ConsentRecord({
    required String userId,
    required DateTime consentedAt,
    required String version,           // ex: "2026-01" — pour tracer les versions de CGU
    @Default(false) bool revoked,
    DateTime? revokedAt,
  }) = _ConsentRecord;

  factory ConsentRecord.fromJson(Map<String, dynamic> json) =>
      _$ConsentRecordFromJson(json);
}
```

### NutritionConsentRepository

```dart
// lib/features/nutrition_tracking/data/repositories/nutrition_consent_repository.dart

class NutritionConsentRepositoryImpl implements NutritionConsentRepository {
  static const String _consentKey = 'nutrition_consent';
  static const String _currentVersion = '2026-01';

  final Box<dynamic> _settingsBox;        // Hive 'settings_box' — NON encrypté
  final FirebaseFirestore _firestore;
  final AuthService _auth;

  @override
  bool hasConsented() {
    final json = _settingsBox.get(_consentKey) as Map?;
    if (json == null) return false;
    final record = ConsentRecord.fromJson(Map<String, dynamic>.from(json));
    return !record.revoked;
  }

  @override
  Future<void> recordConsent() async {
    final userId = _auth.currentUserId;
    if (userId == null) throw AuthException('User not authenticated');

    final record = ConsentRecord(
      userId: userId,
      consentedAt: DateTime.now(),
      version: _currentVersion,
    );

    // Sauvegarder localement
    await _settingsBox.put(_consentKey, record.toJson());

    // Syncer vers Firestore (audit trail RGPD)
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('consent_records')
        .doc('nutrition_consent')
        .set({
      ...record.toJson(),
      'consentedAt': FieldValue.serverTimestamp(),  // Timestamp serveur pour audit
    });
  }

  @override
  Future<void> revokeConsent() async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    final existing = _settingsBox.get(_consentKey) as Map?;
    if (existing == null) return;

    final record = ConsentRecord.fromJson(Map<String, dynamic>.from(existing))
        .copyWith(revoked: true, revokedAt: DateTime.now());

    await _settingsBox.put(_consentKey, record.toJson());

    // Firestore audit
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('consent_records')
        .doc('nutrition_consent')
        .update({'revoked': true, 'revokedAt': FieldValue.serverTimestamp()});
  }
}
```

### NutritionConsentScreen

```dart
// lib/features/nutrition_tracking/presentation/screens/nutrition_consent_screen.dart

class NutritionConsentScreen extends ConsumerStatefulWidget {
  final VoidCallback onConsentGiven;
  final VoidCallback onDeclined;

  const NutritionConsentScreen({
    super.key,
    required this.onConsentGiven,
    required this.onDeclined,
  });

  @override
  ConsumerState<NutritionConsentScreen> createState() => _NutritionConsentScreenState();
}

class _NutritionConsentScreenState extends ConsumerState<NutritionConsentScreen> {
  bool _consentChecked = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi nutritionnel')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🚨 Disclaimer médical — OBLIGATOIRE, visible en premier
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Avis médical important',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ]),
                          SizedBox(height: 8),
                          Text(
                            'FrigoFuté n\'est pas un dispositif médical. '
                            'Les informations nutritionnelles sont indicatives et ne remplacent pas '
                            'les conseils d\'un professionnel de santé qualifié. '
                            'Consultez un médecin ou diététicien pour des conseils nutritionnels médicaux personnalisés.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Titre
                    Text(
                      'Activer le suivi nutritionnel',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Section: données collectées
                    _ConsentSection(
                      icon: Icons.data_usage,
                      title: 'Données collectées',
                      items: const [
                        'Journaux de repas (calories, macros)',
                        'Objectifs nutritionnels personnels',
                        'Photos de repas (optionnel, avec consentement supplémentaire)',
                        'Historique de consommation alimentaire',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section: utilisation
                    _ConsentSection(
                      icon: Icons.insights,
                      title: 'Utilisation de vos données',
                      items: const [
                        'Calcul de votre bilan nutritionnel quotidien',
                        'Suggestions de recettes adaptées à vos objectifs',
                        'Statistiques de progression personnalisées',
                        'Amélioration du service (données anonymisées)',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section: stockage sécurisé
                    _ConsentSection(
                      icon: Icons.lock,
                      title: 'Sécurité et stockage',
                      items: const [
                        'Chiffrement AES-256 sur votre appareil',
                        'Transmission sécurisée TLS 1.3+',
                        'Stockage dans l\'Union Européenne',
                        'Conformité RGPD Article 9 (données de santé)',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section: vos droits
                    _ConsentSection(
                      icon: Icons.gavel,
                      title: 'Vos droits',
                      items: const [
                        'Accès à vos données à tout moment',
                        'Retrait du consentement avec suppression des données dans 30 jours',
                        'Portabilité des données (export JSON/PDF)',
                        'Rectification et opposition',
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Checkbox consentement — OBLIGATOIRE (double opt-in)
                    CheckboxListTile(
                      value: _consentChecked,
                      onChanged: (v) => setState(() => _consentChecked = v ?? false),
                      title: const Text(
                        'J\'accepte le traitement de mes données de santé conformément à la politique de confidentialité de FrigoFuté.',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Boutons d'action
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _consentChecked && !_isLoading ? _giveConsent : null,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Activer le suivi nutritionnel'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : widget.onDeclined,
                    child: const Text('Non merci, continuer sans suivi nutritionnel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _giveConsent() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(nutritionConsentRepositoryProvider).recordConsent();
      await _initializeEncryptedBox();
      widget.onConsentGiven();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement du consentement: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeEncryptedBox() async {
    // Générer/récupérer la clé AES-256 depuis flutter_secure_storage
    final keyManager = ref.read(nutritionKeyManagerProvider);
    final key = await keyManager.getOrCreateKey();

    if (!Hive.isBoxOpen('nutrition_data_box')) {
      await Hive.openBox<dynamic>(
        'nutrition_data_box',
        encryptionCipher: HiveAesCipher(key),
      );
    }
  }
}
```

### NutritionKeyManager — AES-256 key via flutter_secure_storage

```dart
// lib/features/nutrition_tracking/data/services/nutrition_key_manager.dart

class NutritionKeyManager {
  static const String _keyStorageKey = 'nutrition_hive_aes_key';
  final FlutterSecureStorage _storage;

  NutritionKeyManager(this._storage);

  Future<List<int>> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyStorageKey);
    if (existing != null) {
      return base64Decode(existing).cast<int>();
    }

    // Générer nouvelle clé AES-256 (32 bytes)
    final key = Hive.generateSecureKey();
    await _storage.write(
      key: _keyStorageKey,
      value: base64Encode(key),
    );
    return key;
  }
}
```

### NutritionGate widget

```dart
// lib/features/nutrition_tracking/presentation/widgets/nutrition_gate.dart

class NutritionGate extends ConsumerWidget {
  final Widget child;

  const NutritionGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Feature flag check (RemoteConfig)
    final featureEnabled = ref.watch(featureFlagProvider('nutrition_tracking_enabled'));
    if (!featureEnabled) {
      return const Scaffold(
        body: Center(child: Text('Le suivi nutritionnel arrive bientôt ! 🚀')),
      );
    }

    // Consent check
    final hasConsented = ref.watch(nutritionConsentProvider);
    if (!hasConsented) {
      return NutritionConsentScreen(
        onConsentGiven: () => ref.invalidate(nutritionConsentProvider),
        onDeclined: () => context.pop(),
      );
    }

    return child;
  }
}
```

### Providers

```dart
// lib/features/nutrition_tracking/presentation/providers/nutrition_providers.dart

final nutritionConsentRepositoryProvider = Provider<NutritionConsentRepository>((ref) {
  return NutritionConsentRepositoryImpl(
    settingsBox: Hive.box<dynamic>('settings_box'),
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(authServiceProvider),
  );
});

final nutritionConsentProvider = Provider<bool>((ref) {
  return ref.watch(nutritionConsentRepositoryProvider).hasConsented();
});

final nutritionKeyManagerProvider = Provider<NutritionKeyManager>((ref) {
  return NutritionKeyManager(const FlutterSecureStorage());
});

// Provider: nutrition_data_box ouvert et chiffré
final nutritionBoxProvider = FutureProvider<Box<dynamic>>((ref) async {
  if (Hive.isBoxOpen('nutrition_data_box')) {
    return Hive.box<dynamic>('nutrition_data_box');
  }
  final key = await ref.watch(nutritionKeyManagerProvider).getOrCreateKey();
  return Hive.openBox<dynamic>('nutrition_data_box', encryptionCipher: HiveAesCipher(key));
});
```

### GoRouter route

```dart
GoRoute(
  path: '/nutrition',
  builder: (_, __) => const NutritionGate(child: NutritionDashboardScreen()),
),
// NutritionDashboardScreen = placeholder pour Story 7.3
```

### 🔑 CRITIQUE — Sécurité données santé

```
RGPD Article 9: données de santé = catégorie spéciale → double opt-in OBLIGATOIRE
Architecture encryption:
  1. NutritionKeyManager → clé AES-256 (32 bytes) via Hive.generateSecureKey()
  2. Clé stockée dans FlutterSecureStorage (Android Keystore / iOS Keychain)
  3. nutrition_data_box ouvert avec HiveAesCipher(key)
  4. JAMAIS stocker la clé en clair dans SharedPreferences ou Hive non-encrypté
  5. Si l'user logout → fermer et vider nutrition_data_box, supprimer la clé
```

### Packages requis

```yaml
dependencies:
  flutter_secure_storage: ^9.2.0  # Déjà probablement présent (Story 0.10)
  hive_ce: ^2.9.0                 # Déjà présent — HiveAesCipher inclus
```

### ConsentRecord Firestore structure

```
users/{userId}/consent_records/nutrition_consent:
  userId: String
  consentedAt: Timestamp (serverTimestamp)
  version: String ("2026-01")
  revoked: bool
  revokedAt: Timestamp? (null si non révoqué)
```

### _ConsentSection helper widget

```dart
class _ConsentSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _ConsentSection({required this.icon, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: Colors.green)),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 14))),
            ],
          ),
        )),
      ],
    );
  }
}
```

### Project Structure Notes

- `lib/features/nutrition_tracking/` — module principal Epic 7
- `lib/features/nutrition_tracking/domain/entities/` — `ConsentRecord`, `MealLog`, `NutritionDayLog`
- `lib/features/nutrition_tracking/domain/repositories/` — `NutritionConsentRepository`
- `lib/features/nutrition_tracking/data/services/` — `NutritionKeyManager`
- `lib/features/nutrition_tracking/presentation/screens/` — `NutritionConsentScreen`, `NutritionGate`
- `nutrition_data_box` **TOUJOURS** ouvert avec `HiveAesCipher` — JAMAIS sans chiffrement
- Consentement = métadonnée → `settings_box` (non encrypté) + Firestore audit trail
- `NutritionGate` est le wrapper de TOUTES les screens Epic 7

### References

- [Source: epics.md#Story-7.1]
- RGPD Article 9 [Source: architecture.md — Données Santé]
- Encrypted Hive boxes [Source: architecture.md — `nutrition_data_box`, `health_profiles_box` avec HiveAesCipher]
- flutter_secure_storage [Source: architecture.md — Story 0.10]
- `featureFlagProvider` [Source: Story 0.8]
- `HiveAesCipher` [hive_ce docs — Encryption]
- ConsentManager [Source: architecture.md — lib/core/presentation/consent_manager.dart]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
