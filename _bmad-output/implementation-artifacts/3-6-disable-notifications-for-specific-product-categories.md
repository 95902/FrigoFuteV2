# Story 3.6: Disable Notifications for Specific Product Categories

Status: ready-for-dev

## Story

As a Marie (senior),
I want to turn off notifications for certain categories (e.g., condiments, spices),
so that I don't get alerts for products that rarely spoil.

## Acceptance Criteria

1. **Given** I am in the notifications settings screen
   **When** I view the "Catégories exclues des alertes" section
   **Then** I see a toggle for each of the 12 `ProductCategory` values
   **And** all categories are enabled by default

2. **Given** I toggle off "Sauces & Condiments" and "Épicerie salée"
   **When** the daily background task checks for products to alert
   **Then** products in those categories are excluded from DLC AND DDM alerts
   **And** all other categories still generate alerts

3. **Given** I re-enable a previously disabled category
   **Then** products in that category generate alerts from the next run

## Tasks / Subtasks

- [ ] **T1**: Étendre `NotificationSettingsRepository` (AC: 1, 2)
  - [ ] `getDisabledCategories()` → `Set<ProductCategory>`
  - [ ] `setDisabledCategories(Set<ProductCategory>)` — sérialiser comme JSON string dans Hive
  - [ ] `toggleCategory(ProductCategory, bool enabled)`

- [ ] **T2**: Ajouter `disabledCategoriesProvider` StateProvider<Set<ProductCategory>> (AC: 1)

- [ ] **T3**: Ajouter section catégories dans `NotificationSettingsScreen` (AC: 1, 3)
  - [ ] Liste des 12 catégories avec `SwitchListTile` par catégorie
  - [ ] Label traduit en français (réutiliser labels de `CategoryFilterBar` Story 2.5)

- [ ] **T4**: Mettre à jour `ExpirationAlertService` (AC: 2)
  - [ ] Dans `getProductsForDlcAlert()` et `getProductsForDdmAlert()`: filtre
    ```dart
    .where((m) => !_settings.getDisabledCategories().contains(m.category))
    ```

- [ ] **T5**: Tests unitaires — catégorie désactivée exclue de l'alerte (AC: 2)
- [ ] **T6**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### NotificationSettingsRepository — getDisabledCategories

```dart
static const String _disabledCatsKey = 'disabled_categories';

Set<ProductCategory> getDisabledCategories() {
  final stored = _box.get(_disabledCatsKey) as String?;
  if (stored == null || stored.isEmpty) return {};
  final names = (jsonDecode(stored) as List<dynamic>).cast<String>();
  return names
      .map((n) => ProductCategory.values.firstWhere(
            (c) => c.name == n,
            orElse: () => ProductCategory.autre,
          ))
      .toSet();
}

Future<void> setDisabledCategories(Set<ProductCategory> categories) async {
  final json = jsonEncode(categories.map((c) => c.name).toList());
  await _box.put(_disabledCatsKey, json);
}

Future<void> toggleCategory(ProductCategory category, bool enabled) async {
  final current = getDisabledCategories();
  if (enabled) {
    current.remove(category);
  } else {
    current.add(category);
  }
  await setDisabledCategories(current);
}
```

### disabledCategoriesProvider

```dart
final disabledCategoriesProvider = StateProvider<Set<ProductCategory>>((ref) {
  return ref.watch(notificationSettingsRepositoryProvider).getDisabledCategories();
});
```

### Section catégories dans NotificationSettingsScreen

```dart
class _CategoryExclusionSection extends ConsumerWidget {
  static const Map<ProductCategory, String> _labels = {
    ProductCategory.produitsLaitiers:  'Produits laitiers',
    ProductCategory.viandesPoissons:   'Viandes & Poissons',
    ProductCategory.fruitsLegumes:     'Fruits & Légumes',
    ProductCategory.epicerieSucree:    'Épicerie sucrée',
    ProductCategory.epicerieSalee:     'Épicerie salée',
    ProductCategory.surgeles:          'Surgelés',
    ProductCategory.boissons:          'Boissons',
    ProductCategory.boulangerie:       'Boulangerie',
    ProductCategory.platsPrepares:     'Plats préparés',
    ProductCategory.saucesCondiments:  'Sauces & Condiments',
    ProductCategory.oeufs:             'Œufs',
    ProductCategory.autre:             'Autre',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabled = ref.watch(disabledCategoriesProvider);
    final repo = ref.read(notificationSettingsRepositoryProvider);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Catégories exclues des alertes',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ...ProductCategory.values.map((cat) {
            final isEnabled = !disabled.contains(cat);
            return SwitchListTile(
              title: Text(_labels[cat] ?? cat.name),
              value: isEnabled,
              onChanged: (enabled) async {
                await repo.toggleCategory(cat, enabled);
                final newSet = repo.getDisabledCategories();
                ref.read(disabledCategoriesProvider.notifier).state = newSet;
              },
            );
          }),
        ],
      ),
    );
  }
}
```

### Project Structure Notes

- `import 'dart:convert'` requis pour `jsonEncode`/`jsonDecode` dans repository
- Réutiliser les labels de catégories de `CategoryFilterBar` (Story 2.5) — envisager extraction dans `lib/core/constants/category_labels.dart` pour éviter duplication

### References

- [Source: epics.md#Story-3.6]
- ProductCategory enum défini Story 2.1
- NotificationSettingsRepository défini Story 3.4

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
