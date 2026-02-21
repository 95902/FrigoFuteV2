# Story 0.8: Configure Feature Flags via Firebase Remote Config

Status: ready-for-dev

## Story

En tant qu'utilisateur,
je veux accéder graduellement aux nouvelles fonctionnalités au fur et à mesure qu'elles sont testées et perfectionnées,
afin que j'aie toujours une expérience stable tout en bénéficiant de l'innovation.

## Acceptance Criteria

1. **Given** l'application nécessite un basculement dynamique de fonctionnalités pour freemium et A/B testing
2. **When** Firebase Remote Config est intégré avec des valeurs par défaut
3. **Then** Les feature flags sont définis pour les 14 modules (6 gratuits, 8 premium)
4. **And** Remote Config récupère et active au démarrage de l'app (avec cache)
5. **And** Les valeurs de feature flags peuvent être mises à jour côté serveur sans release app
6. **And** Les widgets guard premium (PremiumFeatureGuard) sont implémentés
7. **And** Le timeout de fetch est configuré à 5 secondes avec fallback sur le cache

## Tasks / Subtasks

- [ ] Créer RemoteConfigService (AC: #2, #4, #7)
  - [ ] Créer `lib/core/feature_flags/remote_config_service.dart`
  - [ ] Singleton pattern pour RemoteConfigService
  - [ ] Méthode `initialize()` avec setDefaults()
  - [ ] Fetch avec timeout 5 secondes
  - [ ] Fetch avec cache duration 12 heures
  - [ ] ConfigStream pour updates temps réel

- [ ] Définir feature flags pour 14 modules (AC: #3)
  - [ ] Flag: `inventory_enabled` (FREE - default: true)
  - [ ] Flag: `ocr_scan_enabled` (FREE - default: true)
  - [ ] Flag: `notifications_enabled` (FREE - default: true)
  - [ ] Flag: `recipes_enabled` (FREE - default: true)
  - [ ] Flag: `dashboard_enabled` (FREE - default: true)
  - [ ] Flag: `auth_profile_enabled` (FREE - default: true)
  - [ ] Flag: `meal_planning_enabled` (PREMIUM - default: false)
  - [ ] Flag: `ai_coach_enabled` (PREMIUM - default: false)
  - [ ] Flag: `price_comparator_enabled` (PREMIUM - default: false)
  - [ ] Flag: `gamification_enabled` (PREMIUM - default: false)
  - [ ] Flag: `export_sharing_enabled` (PREMIUM - default: false)
  - [ ] Flag: `family_sharing_enabled` (PREMIUM - default: false)
  - [ ] Flag: `shopping_list_enabled` (PREMIUM - default: false)
  - [ ] Flag: `nutrition_tracking_enabled` (PREMIUM - default: false)
  - [ ] List JSON: `premium_features` (array of premium module IDs)

- [ ] Créer FeatureConfig model (AC: #3)
  - [ ] Créer `lib/core/feature_flags/models/feature_config.dart`
  - [ ] Freezed model avec 14 boolean flags
  - [ ] Property: `premiumFeatures` (List<String>)
  - [ ] Property computed: `isPremium` getter
  - [ ] Factory: `fromRemoteConfig(FirebaseRemoteConfig)`
  - [ ] Générer code: `flutter pub run build_runner build`

- [ ] Créer Riverpod providers feature flags (AC: #4, #5)
  - [ ] Créer `lib/core/feature_flags/feature_flag_providers.dart`
  - [ ] Provider: `remoteConfigServiceProvider`
  - [ ] StreamProvider: `featureFlagsProvider` (updates temps réel)
  - [ ] Provider: `isPremiumProvider` (derived from featureFlagsProvider)
  - [ ] Provider.family: `featureEnabledProvider(featureId)`

- [ ] Créer SubscriptionStatus model et provider (AC: #6)
  - [ ] Model: `SubscriptionStatus` (isPremium, activePremiumFeatures, trialEndDate)
  - [ ] StreamProvider: `subscriptionStatusProvider` (from Firestore)
  - [ ] StreamProvider.family: `userSubscriptionProvider(userId)`
  - [ ] Intégration avec authStateProvider (Story 0.4)

- [ ] Implémenter PremiumFeatureGuard widget (AC: #6)
  - [ ] Créer `lib/core/shared/widgets/organisms/premium_feature_guard.dart`
  - [ ] ConsumerWidget avec featureId et child
  - [ ] Fallback: PaywallWidget si feature non disponible
  - [ ] Loading state pendant fetch subscription
  - [ ] Error state si fetch échoue

- [ ] Créer PaywallWidget (AC: #6)
  - [ ] Créer `lib/core/shared/widgets/organisms/paywall_widget.dart`
  - [ ] Afficher feature bloquée et benefits premium
  - [ ] Bouton "Essai gratuit 7 jours"
  - [ ] Bouton "Voir les plans"
  - [ ] Intégration analytics (view_premium_paywall event)

- [ ] Configurer Remote Config dans Firebase Console (AC: #3, #5)
  - [ ] Projet dev: créer parameters dans Console
  - [ ] Projet staging: créer parameters dans Console
  - [ ] Projet prod: créer parameters dans Console
  - [ ] Valeurs par défaut: free modules = true, premium = false
  - [ ] Documenter comment modifier les flags sans release

- [ ] Intégrer dans main.dart (AC: #2, #4)
  - [ ] Ajouter `await RemoteConfigService().initialize()` après Firebase
  - [ ] Timeout 5 secondes avec try/catch
  - [ ] Fallback sur defaults si fetch échoue
  - [ ] Log initialisation réussie

- [ ] Intégrer avec GoRouter guards (Story 0.5) (AC: #6)
  - [ ] Modifier route guards pour vérifier subscriptionStatusProvider
  - [ ] Redirect vers /paywall si premium feature non accessible
  - [ ] Tester navigation bloquée pour free users

- [ ] Créer tests feature flags (AC: #3, #4, #6, #7)
  - [ ] `test/core/feature_flags/remote_config_service_test.dart`
  - [ ] Test: initialize() sets defaults
  - [ ] Test: fetch() respects 5 second timeout
  - [ ] Test: isFeatureEnabled() returns correct value
  - [ ] Test: fallback to cache on fetch failure
  - [ ] `test/core/feature_flags/premium_feature_guard_test.dart`
  - [ ] Test: shows child when feature enabled
  - [ ] Test: shows paywall when feature disabled

- [ ] Documenter feature flags (AC: #5)
  - [ ] README: Liste des 14 feature flags
  - [ ] README: Comment mettre à jour flags dans Firebase Console
  - [ ] README: Pattern PremiumFeatureGuard usage
  - [ ] README: Environnements (dev/staging/prod)

- [ ] Vérifier l'intégration (AC: #2, #3, #4, #5, #6, #7)
  - [ ] App démarre avec Remote Config fetch < 5s
  - [ ] Flags free accessibles sans subscription
  - [ ] Flags premium bloqués sans subscription
  - [ ] PaywallWidget s'affiche correctement
  - [ ] Modifier flag dans Console → app se met à jour
  - [ ] Mode offline → fallback sur cache fonctionne
  - [ ] Tests passent: `flutter test test/core/feature_flags/`

## Dev Notes

### 🎯 Objectif de cette Story

Story 0.8 établit le système de feature flags pour le modèle freemium de FrigoFuteV2. Elle configure:
- Firebase Remote Config pour toggle dynamique de features
- 14 feature flags (6 free + 8 premium)
- Widget guards pour bloquer accès premium
- Subscription status tracking depuis Firestore
- Paywall UI pour conversion free → premium
- Foundation pour A/B testing (futur)

### 📋 Contexte - Ce qui a été fait dans Stories précédentes

**Story 0.2 - Firebase Remote Config SDK DÉJÀ installé:**
```yaml
# pubspec.yaml (Story 0.1/0.2)
firebase_remote_config: ^6.1.4
```

**Story 0.4 - Riverpod providers pattern:**
```dart
// Pattern global providers déjà établi
final featureFlagsProvider = StreamProvider<FeatureConfig>((ref) {
  return RemoteConfigService().configStream;
});

final isPremiumProvider = Provider<bool>((ref) {
  final flags = ref.watch(featureFlagsProvider);
  return flags.maybeWhen(
    data: (config) => config.isPremium,
    orElse: () => false,
  );
});
```

**Story 0.5 - GoRouter avec route guards:**
```dart
// Route guards déjà configurés (Story 0.5)
// Story 0.8 ajoute PremiumGuard
redirect: (context, state) {
  final subscription = ref.watch(subscriptionStatusProvider);
  // Check if premium feature accessible
}
```

### 🏗️ Architecture Feature Flags - 14 Modules

**6 Modules Gratuits (Free):**
```
1. inventory         - Gestion inventaire alimentaire
2. ocr_scan          - Scan code-barres et tickets basique
3. notifications     - Alertes expiration
4. recipes           - Suggestions recettes
5. dashboard         - Dashboard métriques basique
6. auth_profile      - Authentification et profil
```

**8 Modules Premium (4.99€/mois):**
```
7. meal_planning         - Planning repas IA (Gemini)
8. ai_coach              - Coach nutrition IA
9. price_comparator      - Comparateur prix avancé
10. gamification         - Achievements & badges
11. export_sharing       - Export PDF et partage
12. family_sharing       - Inventaire partagé famille
13. shopping_list        - Liste courses optimisée
14. nutrition_tracking   - Suivi nutrition complet
```

**Mapping Feature Flags:**
```dart
// Format: {module_id}_enabled
'inventory_enabled': true,              // Free
'ocr_scan_enabled': true,               // Free
'notifications_enabled': true,          // Free
'recipes_enabled': true,                // Free
'dashboard_enabled': true,              // Free
'auth_profile_enabled': true,           // Free
'meal_planning_enabled': false,         // Premium
'ai_coach_enabled': false,              // Premium
'price_comparator_enabled': false,      // Premium
'gamification_enabled': false,          // Premium
'export_sharing_enabled': false,        // Premium
'family_sharing_enabled': false,        // Premium
'shopping_list_enabled': false,         // Premium
'nutrition_tracking_enabled': false,    // Premium

// Liste premium modules
'premium_features': jsonEncode([
  'meal_planning',
  'ai_coach',
  'price_comparator',
  'gamification',
  'export_sharing',
  'family_sharing',
  'shopping_list',
  'nutrition_tracking',
])
```

### 🔧 RemoteConfigService Implementation

**Fichier: `lib/core/feature_flags/remote_config_service.dart`**

```dart
import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'models/feature_config.dart';

/// Singleton service for Firebase Remote Config
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() => _instance;

  RemoteConfigService._internal();

  late FirebaseRemoteConfig _remoteConfig;
  final _configStreamController = StreamController<FeatureConfig>.broadcast();

  /// Stream of feature config updates
  Stream<FeatureConfig> get configStream => _configStreamController.stream;

  /// Initialize Remote Config with defaults and fetch
  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    // Configure settings
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5), // AC: 5 second timeout
        minimumFetchInterval: const Duration(hours: 12), // Cache duration
      ),
    );

    // Set default values (AC: default values)
    await _remoteConfig.setDefaults(_defaultValues);

    // Fetch and activate
    try {
      await _remoteConfig.fetchAndActivate().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
            print('⚠️ Remote Config fetch timeout - using cached values');
          }
          return false;
        },
      );

      if (kDebugMode) {
        print('✅ Remote Config initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Remote Config fetch failed: $e - using default values');
      }
    }

    // Listen for config updates
    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
      _configStreamController.add(getFeatureConfig());
    });

    // Emit initial config
    _configStreamController.add(getFeatureConfig());
  }

  /// Get current feature configuration
  FeatureConfig getFeatureConfig() {
    return FeatureConfig.fromRemoteConfig(_remoteConfig);
  }

  /// Check if specific feature is enabled
  bool isFeatureEnabled(String featureId) {
    return _remoteConfig.getBool('${featureId}_enabled');
  }

  /// Get list of premium features
  List<String> getPremiumFeatures() {
    try {
      final json = _remoteConfig.getString('premium_features');
      return List<String>.from(jsonDecode(json) as List);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing premium_features: $e');
      }
      return _defaultPremiumFeatures;
    }
  }

  /// Dispose resources
  void dispose() {
    _configStreamController.close();
  }

  /// Default values for all feature flags
  static const Map<String, dynamic> _defaultValues = {
    // Free modules - enabled by default
    'inventory_enabled': true,
    'ocr_scan_enabled': true,
    'notifications_enabled': true,
    'recipes_enabled': true,
    'dashboard_enabled': true,
    'auth_profile_enabled': true,

    // Premium modules - disabled by default
    'meal_planning_enabled': false,
    'ai_coach_enabled': false,
    'price_comparator_enabled': false,
    'gamification_enabled': false,
    'export_sharing_enabled': false,
    'family_sharing_enabled': false,
    'shopping_list_enabled': false,
    'nutrition_tracking_enabled': false,

    // Premium features list
    'premium_features': jsonEncode(_defaultPremiumFeatures),
  };

  static const List<String> _defaultPremiumFeatures = [
    'meal_planning',
    'ai_coach',
    'price_comparator',
    'gamification',
    'export_sharing',
    'family_sharing',
    'shopping_list',
    'nutrition_tracking',
  ];
}
```

### 📊 FeatureConfig Model

**Fichier: `lib/core/feature_flags/models/feature_config.dart`**

```dart
import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

part 'feature_config.freezed.dart';
part 'feature_config.g.dart';

@freezed
class FeatureConfig with _$FeatureConfig {
  const FeatureConfig._();

  const factory FeatureConfig({
    // Free modules
    required bool inventoryEnabled,
    required bool ocrScanEnabled,
    required bool notificationsEnabled,
    required bool recipesEnabled,
    required bool dashboardEnabled,
    required bool authProfileEnabled,

    // Premium modules
    required bool mealPlanningEnabled,
    required bool aiCoachEnabled,
    required bool priceComparatorEnabled,
    required bool gamificationEnabled,
    required bool exportSharingEnabled,
    required bool familySharingEnabled,
    required bool shoppingListEnabled,
    required bool nutritionTrackingEnabled,

    // Premium features list
    required List<String> premiumFeatures,
  }) = _FeatureConfig;

  /// Check if user has premium access
  bool get isPremium => premiumFeatures.isNotEmpty;

  /// Check if specific feature is enabled
  bool isEnabled(String featureId) {
    switch (featureId) {
      case 'inventory':
        return inventoryEnabled;
      case 'ocr_scan':
        return ocrScanEnabled;
      case 'notifications':
        return notificationsEnabled;
      case 'recipes':
        return recipesEnabled;
      case 'dashboard':
        return dashboardEnabled;
      case 'auth_profile':
        return authProfileEnabled;
      case 'meal_planning':
        return mealPlanningEnabled;
      case 'ai_coach':
        return aiCoachEnabled;
      case 'price_comparator':
        return priceComparatorEnabled;
      case 'gamification':
        return gamificationEnabled;
      case 'export_sharing':
        return exportSharingEnabled;
      case 'family_sharing':
        return familySharingEnabled;
      case 'shopping_list':
        return shoppingListEnabled;
      case 'nutrition_tracking':
        return nutritionTrackingEnabled;
      default:
        return false;
    }
  }

  /// Create from Firebase Remote Config
  factory FeatureConfig.fromRemoteConfig(FirebaseRemoteConfig config) {
    return FeatureConfig(
      // Free modules
      inventoryEnabled: config.getBool('inventory_enabled'),
      ocrScanEnabled: config.getBool('ocr_scan_enabled'),
      notificationsEnabled: config.getBool('notifications_enabled'),
      recipesEnabled: config.getBool('recipes_enabled'),
      dashboardEnabled: config.getBool('dashboard_enabled'),
      authProfileEnabled: config.getBool('auth_profile_enabled'),

      // Premium modules
      mealPlanningEnabled: config.getBool('meal_planning_enabled'),
      aiCoachEnabled: config.getBool('ai_coach_enabled'),
      priceComparatorEnabled: config.getBool('price_comparator_enabled'),
      gamificationEnabled: config.getBool('gamification_enabled'),
      exportSharingEnabled: config.getBool('export_sharing_enabled'),
      familySharingEnabled: config.getBool('family_sharing_enabled'),
      shoppingListEnabled: config.getBool('shopping_list_enabled'),
      nutritionTrackingEnabled: config.getBool('nutrition_tracking_enabled'),

      // Premium features list
      premiumFeatures: _parsePremiumFeatures(config.getString('premium_features')),
    );
  }

  static List<String> _parsePremiumFeatures(String json) {
    try {
      return List<String>.from(jsonDecode(json) as List);
    } catch (e) {
      return [];
    }
  }

  factory FeatureConfig.fromJson(Map<String, dynamic> json) =>
      _$FeatureConfigFromJson(json);
}
```

### 🎯 Riverpod Providers Feature Flags

**Fichier: `lib/core/feature_flags/feature_flag_providers.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'remote_config_service.dart';
import 'models/feature_config.dart';

/// Remote Config service singleton provider
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

/// Feature flags configuration stream provider
final featureFlagsProvider = StreamProvider<FeatureConfig>((ref) {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.configStream;
});

/// Check if user has premium access
final isPremiumProvider = Provider<bool>((ref) {
  final config = ref.watch(featureFlagsProvider);
  return config.maybeWhen(
    data: (config) => config.isPremium,
    orElse: () => false,
  );
});

/// Check if specific feature is enabled (family provider)
final featureEnabledProvider = Provider.family<bool, String>((ref, featureId) {
  final config = ref.watch(featureFlagsProvider);
  return config.maybeWhen(
    data: (config) => config.isEnabled(featureId),
    orElse: () => false,
  );
});
```

### 👤 SubscriptionStatus Model

**Fichier: `lib/core/feature_flags/models/subscription_status.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';
part 'subscription_status.g.dart';

@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const SubscriptionStatus._();

  const factory SubscriptionStatus({
    required bool isPremium,
    required List<String> activePremiumFeatures,
    DateTime? trialEndDate,
    DateTime? subscriptionEndDate,
    String? planId,
  }) = _SubscriptionStatus;

  /// Free user with no premium access
  factory SubscriptionStatus.free() {
    return const SubscriptionStatus(
      isPremium: false,
      activePremiumFeatures: [],
    );
  }

  /// Loading state
  factory SubscriptionStatus.loading() {
    return const SubscriptionStatus(
      isPremium: false,
      activePremiumFeatures: [],
    );
  }

  /// Check if user has access to specific premium feature
  bool hasFeature(String featureId) {
    return activePremiumFeatures.contains(featureId);
  }

  /// Check if trial is active
  bool get isTrialActive {
    if (trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusFromJson(json);
}
```

**Provider Subscription Status:**

```dart
// lib/core/feature_flags/subscription_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_providers.dart';
import 'models/subscription_status.dart';

/// Subscription status for current user
final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(SubscriptionStatus.free());
      }

      // Fetch from Firestore users/{userId}/subscription
      return ref.watch(userSubscriptionProvider(user.uid));
    },
    loading: () => Stream.value(SubscriptionStatus.loading()),
    error: (_, __) => Stream.value(SubscriptionStatus.free()),
  );
});

/// User subscription from Firestore (family provider)
final userSubscriptionProvider = StreamProvider.family<SubscriptionStatus, String>(
  (ref, userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return SubscriptionStatus.free();
      }

      final data = doc.data()!;
      return SubscriptionStatus(
        isPremium: data['isPremium'] as bool? ?? false,
        activePremiumFeatures: List<String>.from(
          data['premiumFeatures'] as List? ?? [],
        ),
        trialEndDate: (data['trialEndDate'] as Timestamp?)?.toDate(),
        subscriptionEndDate: (data['subscriptionEndDate'] as Timestamp?)?.toDate(),
        planId: data['planId'] as String?,
      );
    });
  },
);
```

### 🛡️ PremiumFeatureGuard Widget

**Fichier: `lib/core/shared/widgets/organisms/premium_feature_guard.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../feature_flags/subscription_providers.dart';
import 'paywall_widget.dart';

/// Guard widget that checks if user has access to premium feature
class PremiumFeatureGuard extends ConsumerWidget {
  final String featureId;
  final Widget child;
  final Widget? fallback;

  const PremiumFeatureGuard({
    required this.featureId,
    required this.child,
    this.fallback,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionStatusProvider);

    return subscription.when(
      data: (status) {
        // Check if user has access to this feature
        if (status.hasFeature(featureId)) {
          return child;
        } else {
          // Show paywall or custom fallback
          return fallback ??
              PaywallWidget(
                featureId: featureId,
                featureName: _getFeatureName(featureId),
              );
        }
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Erreur: ${error.toString()}'),
      ),
    );
  }

  String _getFeatureName(String featureId) {
    const Map<String, String> featureNames = {
      'meal_planning': 'Planning Repas IA',
      'ai_coach': 'Coach Nutrition IA',
      'price_comparator': 'Comparateur Prix',
      'gamification': 'Gamification',
      'export_sharing': 'Export & Partage',
      'family_sharing': 'Partage Famille',
      'shopping_list': 'Liste Courses',
      'nutrition_tracking': 'Suivi Nutrition',
    };
    return featureNames[featureId] ?? featureId;
  }
}
```

### 💰 PaywallWidget

**Fichier: `lib/core/shared/widgets/organisms/paywall_widget.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../monitoring/analytics_service.dart';

class PaywallWidget extends ConsumerWidget {
  final String featureId;
  final String featureName;

  const PaywallWidget({
    required this.featureId,
    required this.featureName,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Log analytics event
    ref.read(analyticsServiceProvider).logViewPremiumPaywall(
          feature: featureId,
        );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                '$featureName est une fonctionnalité Premium',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Débloquez toutes les fonctionnalités premium avec un essai gratuit de 7 jours.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildBenefitsList(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _startTrial(context, ref),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text('Essai Gratuit 7 Jours'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/premium/plans'),
                child: const Text('Voir les Plans'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _BenefitItem(text: 'Planning repas IA personnalisé'),
        _BenefitItem(text: 'Coach nutrition intelligent'),
        _BenefitItem(text: 'Comparateur prix et optimisation'),
        _BenefitItem(text: 'Gamification et défis'),
        _BenefitItem(text: 'Partage famille et export PDF'),
      ],
    );
  }

  Future<void> _startTrial(BuildContext context, WidgetRef ref) async {
    // Navigate to trial signup flow
    if (context.mounted) {
      context.push('/premium/trial-signup?feature=$featureId');
    }
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;

  const _BenefitItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
```

### 🔄 Integration main.dart

**Modifier `lib/main.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options_dev.dart';
import 'core/storage/hive_service.dart';
import 'core/feature_flags/remote_config_service.dart'; // Story 0.8
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Story 0.2)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Crashlytics (Story 0.7)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Initialize Hive (Story 0.3)
  await HiveService.init();

  // Initialize Remote Config (Story 0.8)
  try {
    await RemoteConfigService().initialize().timeout(
      const Duration(seconds: 5),
    );
  } catch (e) {
    print('⚠️ Remote Config initialization failed: $e');
    // Continue with default values
  }

  runApp(const ProviderScope(child: FrigoFuteApp()));
}

class FrigoFuteApp extends ConsumerWidget {
  const FrigoFuteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'FrigoFute V2',
      routerConfig: goRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
    );
  }
}
```

### 🗺️ GoRouter Integration (Story 0.5)

**Modifier routes premium dans `lib/core/routing/app_router.dart`:**

```dart
// Premium route avec guard
GoRoute(
  path: '/meal-planning',
  name: 'meal-planning',
  redirect: (BuildContext context, GoRouterState state) {
    final ref = ProviderScope.containerOf(context);
    final subscription = ref.read(subscriptionStatusProvider).value;

    if (subscription == null || !subscription.hasFeature('meal_planning')) {
      return '/paywall?feature=meal_planning';
    }
    return null; // Allow navigation
  },
  builder: (context, state) => const MealPlanningScreen(),
),
```

### 🧪 Testing Strategy

**Test Structure:**
```
test/core/feature_flags/
├── remote_config_service_test.dart
├── feature_config_test.dart
├── subscription_providers_test.dart
└── premium_feature_guard_test.dart
```

**Example Test: RemoteConfigService**

```dart
// test/core/feature_flags/remote_config_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  group('RemoteConfigService', () {
    late RemoteConfigService service;
    late MockFirebaseRemoteConfig mockConfig;

    setUp(() {
      mockConfig = MockFirebaseRemoteConfig();
      service = RemoteConfigService(); // Inject mock in real implementation
    });

    test('initialize sets default values', () async {
      when(() => mockConfig.setDefaults(any())).thenAnswer((_) async {});
      when(() => mockConfig.fetchAndActivate()).thenAnswer((_) async => true);

      await service.initialize();

      verify(() => mockConfig.setDefaults(any())).called(1);
    });

    test('fetch respects 5 second timeout', () async {
      when(() => mockConfig.fetchAndActivate()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 10), () => true),
      );

      // Should timeout and fallback to defaults
      await expectLater(
        service.initialize(),
        completes,
      );
    });

    test('isFeatureEnabled returns correct value', () {
      when(() => mockConfig.getBool('inventory_enabled')).thenReturn(true);
      when(() => mockConfig.getBool('meal_planning_enabled')).thenReturn(false);

      expect(service.isFeatureEnabled('inventory'), true);
      expect(service.isFeatureEnabled('meal_planning'), false);
    });

    test('fallback to cache on fetch failure', () async {
      when(() => mockConfig.fetchAndActivate()).thenThrow(Exception('Network error'));
      when(() => mockConfig.setDefaults(any())).thenAnswer((_) async {});

      // Should not throw, use defaults instead
      await expectLater(
        service.initialize(),
        completes,
      );
    });
  });
}
```

**Widget Test: PremiumFeatureGuard**

```dart
// test/core/feature_flags/premium_feature_guard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('PremiumFeatureGuard', () {
    testWidgets('shows child when feature enabled', (tester) async {
      final subscription = SubscriptionStatus(
        isPremium: true,
        activePremiumFeatures: ['meal_planning'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionStatusProvider.overrideWith(
              (ref) => Stream.value(subscription),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PremiumFeatureGuard(
                featureId: 'meal_planning',
                child: Text('Premium Content'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Premium Content'), findsOneWidget);
    });

    testWidgets('shows paywall when feature disabled', (tester) async {
      final subscription = SubscriptionStatus.free();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionStatusProvider.overrideWith(
              (ref) => Stream.value(subscription),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PremiumFeatureGuard(
                featureId: 'meal_planning',
                child: Text('Premium Content'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(PaywallWidget), findsOneWidget);
    });
  });
}
```

### 🚨 Anti-Patterns à ÉVITER

#### ❌ Anti-Pattern 1: Hardcoded premium checks
```dart
// ❌ BAD: Hardcoded logic
if (user.isPremium) {
  return MealPlanningScreen();
}

// ✅ CORRECT: Use subscription provider
final subscription = ref.watch(subscriptionStatusProvider);
return subscription.when(
  data: (status) => status.hasFeature('meal_planning')
    ? MealPlanningScreen()
    : PaywallWidget(),
  // ...
);
```

#### ❌ Anti-Pattern 2: Direct Firebase Remote Config access
```dart
// ❌ BAD: Tight coupling
final config = FirebaseRemoteConfig.instance;
final isEnabled = config.getBool('feature_enabled');

// ✅ CORRECT: Use RemoteConfigService + Provider
final config = ref.watch(featureFlagsProvider);
```

#### ❌ Anti-Pattern 3: No timeout handling
```dart
// ❌ BAD: Could hang app startup
await remoteConfig.fetch();

// ✅ CORRECT: 5 second timeout with fallback
await remoteConfig.fetch().timeout(
  const Duration(seconds: 5),
  onTimeout: () => false, // Use cached/default values
);
```

#### ❌ Anti-Pattern 4: Forgetting default values
```dart
// ❌ BAD: Feature disabled if fetch fails
final isEnabled = remoteConfig.getBool('feature_enabled');

// ✅ CORRECT: Always set defaults first
await remoteConfig.setDefaults({'feature_enabled': true});
```

#### ❌ Anti-Pattern 5: UI tightly coupled to flags
```dart
// ❌ BAD: Direct flag checks everywhere
if (remoteConfig.getBool('meal_planning_enabled')) {
  return MealPlanningScreen();
}

// ✅ CORRECT: Use guard widgets
PremiumFeatureGuard(
  featureId: 'meal_planning',
  child: MealPlanningScreen(),
);
```

### 🔗 Integration Points

**Dépend de:**
- ✅ **Story 0.2**: Firebase Remote Config SDK installé
- ✅ **Story 0.4**: Riverpod providers pattern (REQUIRED)
- **Story 0.5**: GoRouter route guards

**Requis pour:**
- **All premium feature modules (7-14)**: Use PremiumFeatureGuard
- **Story 1.x+**: Auth flows avec subscription status
- **Story 9.x+**: Meal planning premium features

### 📋 Validation Réussite

**Checklist finale Story 0.8:**

1. ✅ RemoteConfigService créé avec singleton
2. ✅ 14 feature flags définis (6 free + 8 premium)
3. ✅ FeatureConfig model avec freezed
4. ✅ featureFlagsProvider (StreamProvider)
5. ✅ subscriptionStatusProvider (from Firestore)
6. ✅ PremiumFeatureGuard widget créé
7. ✅ PaywallWidget créé
8. ✅ Remote Config initialisé dans main.dart
9. ✅ Timeout 5 secondes configuré
10. ✅ Default values configurés
11. ✅ GoRouter guards intégrés
12. ✅ Firebase Console parameters configurés
13. ✅ Tests feature flags passent
14. ✅ Free features accessibles sans subscription
15. ✅ Premium features bloquées sans subscription

**Commandes de validation:**

```bash
# Tests
flutter test test/core/feature_flags/

# Analyse
flutter analyze

# Generate freezed code
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Test manual:
# 1. Launch app → verify Remote Config fetch < 5s
# 2. Navigate to free feature → accessible
# 3. Navigate to premium feature → paywall shown
# 4. Modify flag in Firebase Console → app updates
# 5. Turn off network → fallback to cache works
```

### 📚 Références Techniques

**Firebase Remote Config:**
- [Remote Config Flutter](https://firebase.google.com/docs/remote-config/get-started?platform=flutter)
- [Remote Config Best Practices](https://firebase.google.com/docs/remote-config/loading)

**Freezed:**
- [Freezed Documentation](https://pub.dev/packages/freezed)

**Riverpod:**
- [Riverpod Providers](https://riverpod.dev/docs/concepts/providers)

### Références Sources Documentation

**[Source: epics.md, lignes 741-756]** - Story 0.8 détaillée

**[Source: architecture.md]** - Feature flags architecture, freemium model

**[Source: 0-2-configure-firebase-services-integration.md]** - Firebase Remote Config SDK

**[Source: 0-4-implement-riverpod-state-management-foundation.md]** - Riverpod providers pattern

**[Source: 0-5-configure-gorouter-for-navigation-and-deep-linking.md]** - Route guards

## Dev Agent Record

### Agent Model Used

*À remplir par le dev agent*

### Debug Log References

*À remplir par le dev agent*

### Completion Notes List

*À remplir par le dev agent après implémentation*

### File List

*À remplir par le dev agent après implémentation*
