# Story 3.1: Receive Push Notification for DLC Expiration (2 Days Before)

Status: ready-for-dev

## Story

As a Sophie (famille),
I want to receive a notification 2 days before a product's DLC (Date Limite Consommation) expires,
so that I can use it in time and avoid throwing away food.

## Acceptance Criteria

1. **Given** I have products with DLC expiration dates in my inventory
   **When** a product is exactly 2 days away from its DLC expiration date
   **Then** I receive a push notification with the product name and expiration date
   **And** the notification is marked as urgent (high priority) with distinct sound

2. **Given** the notifications feature is enabled (default: on)
   **When** the daily background check runs
   **Then** the notification is delivered with reliability >95% (local) or >99% (FCM future)
   **And** no duplicate notifications for the same product on the same day

3. **Given** I tap the notification
   **Then** the app opens directly to the product details screen (`/inventory/product/{id}`)
   **Or** alternatively to the inventory screen pre-filtered for expiring products

4. **Given** quiet hours are configured (Story 3.7 dependency)
   **When** the notification would fire during quiet hours
   **Then** it is delayed until the end of the quiet window
   **Note**: For Story 3.1 (MVP), quiet hours = not yet configured → all notifications fire immediately

5. **Given** it is my first time receiving an expiration notification
   **Then** I see the legal disclaimer (Story 3.8) before the notification arrives or on first open
   **Note**: Disclaimer implementation delegated to Story 3.8; Story 3.1 ships without disclaimer

## Tasks / Subtasks

- [ ] **T1**: Ajouter packages pubspec.yaml (AC: 1)
  - [ ] `firebase_messaging: ^15.x` (FCM future)
  - [ ] `flutter_local_notifications: ^18.x` (local scheduled)
  - [ ] `workmanager: ^0.5.x` (Android background)
  - [ ] Configurer Android `AndroidManifest.xml` (RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM)
  - [ ] Configurer iOS `Info.plist` (BGTaskSchedulerPermittedIdentifiers)

- [ ] **T2**: Créer architecture notifications feature (AC: 1, 2)
  - [ ] `lib/features/notifications/domain/services/expiration_alert_service.dart`
  - [ ] `lib/features/notifications/data/services/local_notification_service.dart`
  - [ ] `lib/features/notifications/data/services/notification_background_handler.dart`
  - [ ] `lib/features/notifications/presentation/providers/notification_providers.dart`

- [ ] **T3**: Implémenter `ExpirationAlertService` — logique de sélection des produits (AC: 1, 2)
  - [ ] Filtrer produits Hive: `expirationDateType == DLC && daysToExpiry == 2 && !consumed && !deleted`
  - [ ] Déduplication: ne pas notifier si notification déjà envoyée aujourd'hui pour ce produit
  - [ ] Utiliser `ProductStatusService` (Story 2.10) pour calcul de days remaining

- [ ] **T4**: Implémenter `LocalNotificationService` (AC: 1)
  - [ ] Initialisation flutter_local_notifications (Android channel + iOS permissions)
  - [ ] `scheduleExpirationAlert(ProductEntity product)` — notification à 9h00 par défaut
  - [ ] Notification Android: channel `expiration_dlc_urgent`, importance MAX, son personnalisé
  - [ ] Notification iOS: `UNNotificationSound.critical` ou `.default`
  - [ ] Payload: `{"type": "dlc_expiry", "productId": product.id, "productName": product.name}`

- [ ] **T5**: Implémenter background task avec WorkManager (AC: 2)
  - [ ] Enregistrer tâche quotidienne `expiration_check` via WorkManager (Android)
  - [ ] Tâche: ouvre Hive → appelle ExpirationAlertService → planifie notifications
  - [ ] iOS: `BGAppRefreshTask` avec identifier `com.frigofute.expiration-check`
  - [ ] Déclencher tâche initiale au démarrage de l'app

- [ ] **T6**: Implémenter deep link sur tap notification (AC: 3)
  - [ ] Handler `onNotificationTap`: parser payload `productId`
  - [ ] Navigation via GoRouter: `context.push('/inventory/product/$productId')`
  - [ ] Si app fermée: stocker l'intent, naviguer après init

- [ ] **T7**: Demande permission notifications au premier lancement (AC: 2)
  - [ ] Dialog permission iOS (flutter_local_notifications)
  - [ ] POST_NOTIFICATIONS permission Android 13+ (via permission_handler ou flutter_local_notifications)

- [ ] **T8**: Tests unitaires `ExpirationAlertService` (AC: 1, 2)
- [ ] **T9**: Tests intégration notification scheduling + deep link (AC: 3)
- [ ] **T10**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Packages à ajouter

```yaml
# pubspec.yaml — AJOUTER:
dependencies:
  firebase_messaging: ^15.0.0        # FCM (requis pour background iOS, future server-push)
  flutter_local_notifications: ^18.0.0  # Local scheduled notifications
  workmanager: ^0.5.0                # Background tasks Android

  # Déjà présent — utiliser pour relatif time dans notification body:
  timeago: ^3.7.0  # "dans 2 jours"
```

> **Note**: `firebase_messaging` est requis même pour notifications locales iOS car le plugin flutter_local_notifications l'utilise pour les permissions iOS 10+ et pour background processing. FirebaseMessaging.instance.requestPermission() est nécessaire.

### Feature Directory Structure

```
lib/features/notifications/
├── domain/
│   ├── entities/
│   │   └── expiration_notification.dart    # Value object (productId, scheduledAt, type)
│   └── services/
│       ├── expiration_alert_service.dart   # Interface: getProductsRequiringDlcAlert()
│       └── i_notification_service.dart     # Interface: scheduleAlert(), cancelAlert()
├── data/
│   ├── services/
│   │   ├── local_notification_service.dart # Impl flutter_local_notifications
│   │   └── notification_background_handler.dart  # WorkManager callback (top-level fn)
│   └── repositories/
│       └── notification_settings_repository.dart  # Hive: délais, quiet hours, disabled cats
└── presentation/
    ├── providers/
    │   └── notification_providers.dart
    └── screens/
        └── notification_settings_screen.dart  # (Story 3.4/3.5/3.6/3.7)
```

### ExpirationAlertService — Logique de sélection

```dart
// lib/features/notifications/domain/services/expiration_alert_service.dart

class ExpirationAlertService {
  final Box<ProductModel> _inventoryBox;
  final Box<String> _notifiedTodayBox;  // key: "productId_YYYYMMDD" → "sent"

  static const int _dlcAlertDays = 2;  // Configurable via Story 3.4

  ExpirationAlertService(this._inventoryBox, this._notifiedTodayBox);

  List<ProductEntity> getProductsForDlcAlert() {
    final today = DateTime.now().withoutTime;
    final alertDate = today.add(Duration(days: _dlcAlertDays));

    return _inventoryBox.values
        .where((model) => model.expirationDateType == 'dlc')
        .where((model) => model.consumedAt == null)
        .where((model) => model.deletedAt == null)
        .where((model) {
          final exp = model.expirationDate;
          if (exp == null) return false;
          final expiryDay = DateTime(exp.year, exp.month, exp.day);
          return expiryDay == alertDate;  // Exactly 2 days from today
        })
        .where((model) => !_wasAlreadyNotifiedToday(model.id, today))
        .map((model) => model.toEntity())
        .toList();
  }

  bool _wasAlreadyNotifiedToday(String productId, DateTime today) {
    final key = '${productId}_${today.toIso8601String().substring(0, 10)}';
    return _notifiedTodayBox.containsKey(key);
  }

  Future<void> markAsNotified(String productId) async {
    final today = DateTime.now().withoutTime;
    final key = '${productId}_${today.toIso8601String().substring(0, 10)}';
    await _notifiedTodayBox.put(key, 'sent');
    // Cleanup entries older than 7 days to avoid box bloat
    await _cleanupOldEntries(today);
  }

  Future<void> _cleanupOldEntries(DateTime today) async {
    final cutoff = today.subtract(const Duration(days: 7));
    final keysToDelete = _notifiedTodayBox.keys.cast<String>().where((k) {
      final dateStr = k.split('_').last;
      final date = DateTime.tryParse(dateStr);
      return date != null && date.isBefore(cutoff);
    }).toList();
    await _notifiedTodayBox.deleteAll(keysToDelete);
  }
}
```

### LocalNotificationService — Android Channel + iOS

```dart
// lib/features/notifications/data/services/local_notification_service.dart

class LocalNotificationService {
  static const String _dlcChannelId = 'expiration_dlc_urgent';
  static const String _dlcChannelName = 'Alertes DLC Urgentes';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,  // Demander manuellement
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    // Créer le canal Android
    const channel = AndroidNotificationChannel(
      _dlcChannelId,
      _dlcChannelName,
      description: 'Alertes urgentes pour produits DLC bientôt expirés',
      importance: Importance.max,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermission() async {
    // iOS
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    return granted;
  }

  Future<void> showDlcExpirationAlert(ProductEntity product) async {
    final daysText = '2 jours';  // Hardcoded for 3.1; Story 3.4 makes configurable
    await _plugin.show(
      product.id.hashCode,  // Notification ID (stable per product)
      '⚠️ DLC bientôt expiré !',
      '${product.name} expire dans $daysText (${product.formattedExpirationDate})',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _dlcChannelId,
          _dlcChannelName,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Alerte DLC',
          styleInformation: BigTextStyleInformation(
            '${product.name} expire dans $daysText. Pensez à le consommer rapidement !',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'dlc_expiry',
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      payload: '{"type":"dlc_expiry","productId":"${product.id}"}',
    );
  }
}

// Top-level callback (requis par flutter_local_notifications pour background)
@pragma('vm:entry-point')
void _onBackgroundNotificationTap(NotificationResponse response) {
  // Stocker le payload dans shared_preferences pour traitement au prochain open
  _storeNotificationPayload(response.payload);
}

void _onNotificationTap(NotificationResponse response) {
  final payload = response.payload;
  if (payload != null) {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final productId = data['productId'] as String?;
    if (productId != null) {
      // Navigation via GoRouter
      navigatorKey.currentContext?.push('/inventory/product/$productId');
    }
  }
}
```

### WorkManager Background Task (Android)

```dart
// lib/features/notifications/data/services/notification_background_handler.dart

// ⚠️ DOIT être une top-level function (pas une méthode de classe)
@pragma('vm:entry-point')
Future<bool> expirationCheckBackgroundTask() async {
  // Initialiser les dépendances (Hive, etc.) sans Flutter
  await Hive.initFlutter();
  // ... ouvrir les boxes nécessaires
  final alertService = ExpirationAlertService(inventoryBox, notifiedBox);
  final notifService = LocalNotificationService();
  await notifService.initialize();

  final products = alertService.getProductsForDlcAlert();
  for (final product in products) {
    await notifService.showDlcExpirationAlert(product);
    await alertService.markAsNotified(product.id);
  }
  return true;
}

// Enregistrement au démarrage de l'app
Future<void> registerBackgroundTasks() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    'expiration_check',
    'expiration_check',
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(minutes: 5),
    constraints: Constraints(networkType: NetworkType.not_required),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'expiration_check') {
      return expirationCheckBackgroundTask();
    }
    return true;
  });
}
```

### iOS Background Task

```swift
// ios/Runner/AppDelegate.swift — ajouter dans application(_:didFinishLaunchingWithOptions:)
BGTaskScheduler.shared.register(
    forTaskWithIdentifier: "com.frigofute.expiration-check",
    using: nil
) { task in
    self.handleExpirationCheck(task: task as! BGAppRefreshTask)
}
```

```dart
// lib/features/notifications/data/services/notification_background_handler.dart
// Pour iOS via flutter_background_service ou AppRefreshTask via platform channel
// Pour Story 3.1 MVP: utiliser firebase_messaging background handler comme alternative iOS
```

### AndroidManifest.xml ajouts

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Dans <application> : -->
<receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    </intent-filter>
</receiver>
```

### iOS Info.plist ajouts

```xml
<!-- ios/Runner/Info.plist -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.frigofute.expiration-check</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### Riverpod Providers

```dart
// lib/features/notifications/presentation/providers/notification_providers.dart

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});

final expirationAlertServiceProvider = Provider<ExpirationAlertService>((ref) {
  final inventoryBox = Hive.box<ProductModel>('inventory_items');
  final notifiedBox = Hive.box<String>('notified_today');
  return ExpirationAlertService(inventoryBox, notifiedBox);
});

// Initialisation dans app startup
final notificationInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(localNotificationServiceProvider);
  await service.initialize();
  await service.requestPermission();
  await registerBackgroundTasks();
});
```

### Deep Link — GoRouter route

```dart
// lib/core/routing/app_router.dart — ajouter route produit
GoRoute(
  path: '/inventory/product/:id',
  builder: (context, state) {
    final productId = state.pathParameters['id']!;
    return ProductDetailScreen(productId: productId);
  },
),
```

### Hive Box Registration

```dart
// Ajouter dans HiveInitializer:
await Hive.openBox<String>('notified_today');
```

### Testing

```dart
group('ExpirationAlertService', () {
  test('returns DLC product expiring in exactly 2 days', () {
    final product = ProductEntity(
      expirationDate: DateTime.now().add(const Duration(days: 2)),
      expirationDateType: ExpirationDateType.dlc,
      consumedAt: null,
    );
    // ... setup Hive mock boxes
    expect(service.getProductsForDlcAlert(), [product]);
  });

  test('does NOT return DDM products', () { ... });
  test('does NOT return products expiring in 1 day (not today\'s threshold)', () { ... });
  test('does NOT return products expiring in 3 days', () { ... });
  test('does NOT return consumed products', () { ... });
  test('deduplication: product already notified today is skipped', () { ... });
  test('markAsNotified persists in Hive box', () { ... });
  test('cleanupOldEntries removes entries older than 7 days', () { ... });
});

group('LocalNotificationService', () {
  test('showDlcExpirationAlert calls plugin.show with correct channel', () async {
    // Mock FlutterLocalNotificationsPlugin
    ...
  });
});
```

### Project Structure Notes

- **Feature path**: `lib/features/notifications/` — non créé, à initialiser en T2
- **Clean Architecture**: même pattern que `lib/features/inventory/` (domain/data/presentation)
- **HiveField**: `notified_today` box utilise `String` (typeId non requis pour String)
- **Top-level functions**: WorkManager callback et notification handlers DOIVENT être des fonctions top-level (Dart isolate constraint) — ne PAS les mettre dans une classe
- **Navigator Key**: Créer un `GlobalKey<NavigatorState> navigatorKey` dans `app_router.dart` ou `main.dart` pour la navigation depuis les notification callbacks (sans BuildContext)
- **iOS workaround**: WorkManager ne supporte pas iOS nativement → utiliser `firebase_messaging` background handler + `flutter_local_notifications` pour déclencher depuis FCM en arrière-plan

### Anti-Patterns à Éviter

```dart
// ❌ Utiliser FirebaseMessaging seul pour les notifications locales (nécessite serveur)
// ✅ flutter_local_notifications pour la fiabilité offline

// ❌ Planifier via Timer dans le widget (tué quand app en arrière-plan)
// ✅ WorkManager (Android) pour tâches background fiables

// ❌ Notification ID fixe (écrase la précédente si plusieurs produits)
// ✅ product.id.hashCode comme notification ID (stable, unique par produit)

// ❌ Appeler context.push() directement depuis un callback top-level (no BuildContext)
// ✅ NavigatorKey global ou stocker payload + naviguer au prochain open de l'app
```

### References

- Architecture: notifications module `lib/features/notifications/` [Source: architecture.md#Feature-Modules]
- Deep links: `frigofute://inventory/product/{id}` [Source: architecture.md#Navigation]
- WorkManager/BackgroundTasks [Source: architecture.md#Offline-Sync]
- ProductStatusService (Story 2.10) pour calcul daysRemaining
- ExpirationDateType DLC threshold = 2 days [Source: epics.md#Story-3.1]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
