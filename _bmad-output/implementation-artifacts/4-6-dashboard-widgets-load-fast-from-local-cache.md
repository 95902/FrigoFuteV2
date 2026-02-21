# Story 4.6: Dashboard Widgets Load Fast from Local Cache

Status: ready-for-dev

## Story

As a Lucas (étudiant),
I want the dashboard to load instantly even on slow connections,
so that I can check my stats quickly without waiting.

## Acceptance Criteria

1. **Given** I open the app dashboard
   **When** the screen renders
   **Then** all widgets display within 1 second using local Hive cache
   **And** no network request is blocking the initial render

2. **Given** I am online
   **When** the dashboard loads from cache
   **Then** fresh data from Firestore is fetched in the background (stale-while-revalidate)
   **And** if updated data is available, widgets update smoothly (no jarring flicker)

3. **Given** I am offline
   **Then** I see the last synced data with "Mis à jour il y a X heures/jours" timestamp
   **And** no error screen or spinner is displayed (data shows normally)

4. **Given** the cached metrics are computed from Hive consumed products
   **Then** they are always available offline without any network call
   **And** load time is <100ms (synchronous Hive read)

## Tasks / Subtasks

- [ ] **T1**: Auditer `currentMonthMetricsProvider` (Story 4.1) — confirmer que lecture est Hive-only synchrone (AC: 1, 4)
  - [ ] `consumedInventoryProvider` → Hive StreamProvider (pas de Firestore blocking)
  - [ ] Aucune FutureProvider Firestore dans la chaîne de computation

- [ ] **T2**: Ajouter cache Hive des métriques pré-calculées (AC: 1, 2)
  - [ ] `DashboardCacheService.saveMetrics(WasteMetrics, DateTime lastUpdated)`
  - [ ] `DashboardCacheService.loadCachedMetrics()` → `(WasteMetrics, DateTime)?`
  - [ ] Hive box `dashboard_cache`, clé `metrics_current_month`

- [ ] **T3**: Afficher indicateur "Mis à jour il y a X" dans DashboardScreen (AC: 3)
  - [ ] `timeago` package (déjà dans pubspec.yaml)
  - [ ] Affichage sous-titre discret dans AppBar ou sous le SummaryCard

- [ ] **T4**: Implémenter refresh Firestore en background (AC: 2)
  - [ ] `DashboardSyncService.triggerBackgroundRefresh()` après rendu initial
  - [ ] WidgetsBinding.instance.addPostFrameCallback → sync si online
  - [ ] Mise à jour cache si données fraîches disponibles

- [ ] **T5**: Tests de performance — vérifier que render initial est synchrone (AC: 1, 4)
- [ ] **T6**: Tests widget dashboard offline (AC: 3)
- [ ] **T7**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### Analyse de la chaîne de dépendance

```
DashboardScreen
  └─ currentMonthMetricsProvider (Provider<WasteMetrics>)
       └─ consumedInventoryProvider (Provider<AsyncValue<List<ProductEntity>>>)
            └─ inventoryListProvider (StreamProvider — Hive box watch)
                 └─ Hive.box('inventory_items') — LOCAL, synchrone, offline-first ✅
```

**Conclusion**: La chaîne est déjà Hive-first. Aucune requête Firestore ne bloque le render initial. Story 4.6 = validation + cache explicite + timestamp.

### DashboardCacheService

```dart
// lib/features/dashboard/data/services/dashboard_cache_service.dart

class DashboardCacheService {
  static const String _metricsKey = 'metrics_current_month';
  static const String _lastUpdatedKey = 'metrics_last_updated';

  final Box<dynamic> _box;  // Hive box 'dashboard_cache'

  DashboardCacheService(this._box);

  Future<void> saveMetrics(WasteMetrics metrics) async {
    await _box.put(_metricsKey, {
      'wasteKg': metrics.wasteKgAvoided,
      'euros': metrics.moneySavedEuros,
      'co2': metrics.co2EqKgAvoided,
    });
    await _box.put(_lastUpdatedKey, DateTime.now().toIso8601String());
  }

  (WasteMetrics, DateTime)? loadCachedMetrics() {
    final data = _box.get(_metricsKey) as Map?;
    final dateStr = _box.get(_lastUpdatedKey) as String?;
    if (data == null || dateStr == null) return null;
    return (
      WasteMetrics(
        wasteKgAvoided: (data['wasteKg'] as num).toDouble(),
        moneySavedEuros: (data['euros'] as num).toDouble(),
        co2EqKgAvoided: (data['co2'] as num).toDouble(),
      ),
      DateTime.parse(dateStr),
    );
  }
}
```

### lastUpdatedProvider + lastUpdatedText

```dart
final dashboardLastUpdatedProvider = StateProvider<DateTime?>((ref) {
  final cacheService = ref.read(dashboardCacheServiceProvider);
  return cacheService.loadCachedMetrics()?.$2;
});

// Dans DashboardScreen:
Consumer(
  builder: (context, ref, _) {
    final lastUpdated = ref.watch(dashboardLastUpdatedProvider);
    if (lastUpdated == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'Mis à jour ${timeago.format(lastUpdated, locale: 'fr')}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
    );
  },
),
```

### Background Firestore sync

```dart
// Dans DashboardScreen.build():
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Déclencher sync background après le premier frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      ref.read(dashboardSyncServiceProvider).triggerBackgroundRefresh();
    }
  });
  // ... reste du build
}

// DashboardSyncService — déclenche resync des consumed products depuis Firestore
class DashboardSyncService {
  final ConnectivityService _connectivity;
  final SyncService _syncService;

  Future<void> triggerBackgroundRefresh() async {
    if (!await _connectivity.isOnline()) return;
    // Force re-fetch des consumed products depuis Firestore
    // SyncService gère déjà les conflits (LWW timestamp)
    await _syncService.syncCollection('inventory_items');
  }
}
```

### Hive Box Registration

```dart
await Hive.openBox<dynamic>('dashboard_cache');
```

### ConnectivityBanner réutilisée

Le `ConnectivityBanner` de Story 2.12 peut être réutilisé dans `DashboardScreen` pour indiquer le mode offline:

```dart
body: Column(
  children: [
    const ConnectivityBanner(),  // Story 2.12 — réutiliser
    Expanded(child: _dashboardContent()),
  ],
),
```

### Tests

```dart
group('DashboardCacheService', () {
  test('saveMetrics → loadCachedMetrics returns same values', () async { ... });
  test('loadCachedMetrics returns null when cache empty', () { ... });
});

testWidgets('DashboardScreen shows last updated text', (tester) async {
  // Mock cache with old date
  // Verify timeago text appears
});

testWidgets('DashboardScreen renders without network', (tester) async {
  // Mock connectivity = offline
  // Verify widget renders with cached data (no spinner, no error)
});
```

### Project Structure Notes

- `DashboardCacheService` dans `lib/features/dashboard/data/services/`
- `timeago` package déjà dans pubspec.yaml — utiliser avec `locale: 'fr'`
  Ajouter locale FR: `timeago.setLocaleMessages('fr', timeago.FrMessages());`
- Story 4.6 valide l'architecture plutôt que d'ajouter de nouvelles features — si l'audit T1 confirme que la chaîne est déjà Hive-first, le travail principal est le cache explicite + timestamp

### References

- [Source: epics.md#Story-4.6]
- `timeago` package [Source: pubspec.yaml]
- ConnectivityBanner [Source: 2-12-inventory-works-fully-offline.md]
- SyncService [Source: Story 0.9]
- Offline-first architecture [Source: architecture.md#Offline-Sync]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
