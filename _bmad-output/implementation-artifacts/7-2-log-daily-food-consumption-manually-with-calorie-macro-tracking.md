# Story 7.2: Log Daily Food Consumption Manually with Calorie/Macro Tracking

Status: ready-for-dev

## Story

As a Sophie (famille),
I want to log meals I eat each day and see calories and macros automatically,
so that I can track my nutrition without complicated calculations.

## Acceptance Criteria

1. **Given** I have enabled nutrition tracking (Story 7.1 consent)
   **When** I tap "Ajouter un repas"
   **Then** I can select meal type (petit-déjeuner, déjeuner, dîner, collation)
   **And** add food items from my inventory or by searching
   **And** adjust portion sizes and servings

2. **Given** I add a food item with nutritional data (from OpenFoodFacts)
   **Then** calories, protein, carbs, and fats are calculated automatically
   **And** daily totals are updated immediately

3. **Given** I have logged meals today
   **Then** all entries are saved in the encrypted `nutrition_data_box` (Hive AES-256)
   **And** synced to Firestore `users/{userId}/nutrition_tracking/{date}/meals`

4. **Given** I want to remove a meal entry
   **When** I swipe to delete a meal item
   **Then** the item is removed and totals recalculate instantly

## Tasks / Subtasks

- [ ] **T1**: Créer `MealLog` + `MealEntry` entities (Freezed) (AC: 1, 2)
  - [ ] `MealType` enum: `breakfast`, `lunch`, `dinner`, `snack`
  - [ ] `MealEntry`: `id`, `productName`, `portionG`, `mealType`, `loggedAt`, `nutritionData`
  - [ ] `DayNutritionLog`: `date`, `entries: List<MealEntry>`, computed `totalCalories`, `totalProteinG`, etc.
- [ ] **T2**: Créer `NutritionLogRepository` (AC: 3)
  - [ ] Écrire dans `nutrition_data_box` (ENCRYPTED via `nutritionBoxProvider`)
  - [ ] Clé Hive: `log_{date_yyyyMMdd}` ex: `log_20260221`
  - [ ] Sync vers Firestore `users/{userId}/nutrition_tracking/{date}`
  - [ ] `watchDayLog(DateTime date)` → Stream<DayNutritionLog>
  - [ ] `addMealEntry(MealEntry entry)` → Future<void>
  - [ ] `deleteMealEntry(String entryId)` → Future<void>
- [ ] **T3**: Créer `dayNutritionLogProvider(DateTime date)` (AC: 2, 4)
  - [ ] `StreamProvider.family<DayNutritionLog, DateTime>`
  - [ ] Expose totaux calculés (calories, protéines, glucides, lipides)
- [ ] **T4**: Créer `AddMealScreen` (AC: 1)
  - [ ] Sélecteur `MealType` (SegmentedButton ou ChoiceChip)
  - [ ] Recherche produit: depuis inventaire (`inventoryStreamProvider`) OU recherche manuelle
  - [ ] Champ quantité (grammes) avec recalcul live
  - [ ] Bouton "Ajouter" → `nutritionLogRepository.addMealEntry()`
- [ ] **T5**: Créer `MealLogListSection` dans le daily dashboard (AC: 2, 4)
  - [ ] Groupé par `MealType` (4 sections)
  - [ ] `Dismissible` swipe-to-delete sur chaque `MealEntry`
  - [ ] Sous-total calories par section
- [ ] **T6**: Tests unitaires `DayNutritionLog` computed totals (AC: 2)
- [ ] **T7**: Tests unitaires `NutritionLogRepository` avec mock Hive (AC: 3)
- [ ] **T8**: `flutter analyze` 0 erreurs | couverture ≥ 75%

## Dev Notes

### MealType + Entities

```dart
// lib/features/nutrition_tracking/domain/entities/meal_log.dart

enum MealType {
  breakfast(label: 'Petit-déjeuner', icon: Icons.free_breakfast),
  lunch(label: 'Déjeuner', icon: Icons.lunch_dining),
  dinner(label: 'Dîner', icon: Icons.dinner_dining),
  snack(label: 'Collation', icon: Icons.cookie);

  final String label;
  final IconData icon;
  const MealType({required this.label, required this.icon});
}

@freezed
class MealEntry with _$MealEntry {
  const factory MealEntry({
    required String id,
    required String productName,
    required MealType mealType,
    required double portionG,
    required DateTime loggedAt,
    NutritionData? nutritionData,     // Per 100g (Story 5.5)
    String? productId,                 // Référence inventaire optionnelle
  }) = _MealEntry;

  const MealEntry._();

  // Calories pour cette portion (portionG)
  double get portionCalories =>
      (nutritionData?.caloriesKcal ?? 0) * portionG / 100;

  double get portionProteinG =>
      (nutritionData?.proteinG ?? 0) * portionG / 100;

  double get portionCarbsG =>
      (nutritionData?.carbsG ?? 0) * portionG / 100;

  double get portionFatsG =>
      (nutritionData?.fatsG ?? 0) * portionG / 100;
}

@freezed
class DayNutritionLog with _$DayNutritionLog {
  const factory DayNutritionLog({
    required DateTime date,
    @Default([]) List<MealEntry> entries,
  }) = _DayNutritionLog;

  const DayNutritionLog._();

  double get totalCalories => entries.fold(0, (sum, e) => sum + e.portionCalories);
  double get totalProteinG => entries.fold(0, (sum, e) => sum + e.portionProteinG);
  double get totalCarbsG => entries.fold(0, (sum, e) => sum + e.portionCarbsG);
  double get totalFatsG => entries.fold(0, (sum, e) => sum + e.portionFatsG);

  List<MealEntry> entriesFor(MealType type) =>
      entries.where((e) => e.mealType == type).toList();

  DayNutritionLog.empty(DateTime date)
      : this(date: date, entries: const []);
}
```

### NutritionLogRepository

```dart
// lib/features/nutrition_tracking/data/repositories/nutrition_log_repository_impl.dart

class NutritionLogRepositoryImpl implements NutritionLogRepository {
  final Box<dynamic> _nutritionBox;    // ENCRYPTED AES-256
  final FirebaseFirestore _firestore;
  final AuthService _auth;

  String _dayKey(DateTime date) => 'log_${DateFormat('yyyyMMdd').format(date)}';

  @override
  Stream<DayNutritionLog> watchDayLog(DateTime date) {
    final key = _dayKey(date);
    return _nutritionBox.watch(key: key).map((_) => _loadDay(date))
        .startWith(_loadDay(date));
  }

  DayNutritionLog _loadDay(DateTime date) {
    final raw = _nutritionBox.get(_dayKey(date));
    if (raw == null) return DayNutritionLog(date: date);
    final json = Map<String, dynamic>.from(raw as Map);
    return DayNutritionLog.fromJson(json);
  }

  @override
  Future<void> addMealEntry(MealEntry entry) async {
    final date = DateTime(entry.loggedAt.year, entry.loggedAt.month, entry.loggedAt.day);
    final existing = _loadDay(date);
    final updated = existing.copyWith(entries: [...existing.entries, entry]);
    await _save(updated);
  }

  @override
  Future<void> deleteMealEntry(String entryId, DateTime date) async {
    final existing = _loadDay(date);
    final updated = existing.copyWith(
      entries: existing.entries.where((e) => e.id != entryId).toList(),
    );
    await _save(updated);
  }

  Future<void> _save(DayNutritionLog log) async {
    final key = _dayKey(log.date);
    // Hive ENCRYPTED write
    await _nutritionBox.put(key, log.toJson());

    // Firestore sync (non-blocking)
    final userId = _auth.currentUserId;
    if (userId != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(log.date);
      _firestore
          .collection('users').doc(userId)
          .collection('nutrition_tracking').doc(dateStr)
          .set(log.toJson(), SetOptions(merge: true))
          .ignore();  // Fire and forget — sync non-critique
    }
  }
}
```

### Provider family

```dart
// lib/features/nutrition_tracking/presentation/providers/nutrition_providers.dart

final dayNutritionLogProvider = StreamProvider.family<DayNutritionLog, DateTime>((ref, date) {
  return ref.watch(nutritionLogRepositoryProvider).watchDayLog(date);
});
```

### AddMealScreen (simplifié)

```dart
class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({super.key});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  MealType _selectedMealType = MealType.lunch;
  ProductEntity? _selectedProduct;
  double _portionG = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un repas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélecteur type de repas
            SegmentedButton<MealType>(
              segments: MealType.values.map((t) => ButtonSegment(
                value: t,
                label: Text(t.label, style: const TextStyle(fontSize: 11)),
                icon: Icon(t.icon, size: 16),
              )).toList(),
              selected: {_selectedMealType},
              onSelectionChanged: (v) => setState(() => _selectedMealType = v.first),
            ),
            const SizedBox(height: 16),

            // Sélection produit (depuis inventaire)
            // TODO: remplacer par vrai sélecteur de produit
            const Text('Produit:', style: TextStyle(fontWeight: FontWeight.bold)),
            // ... sélecteur

            // Quantité
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Quantité (g):'),
                const SizedBox(width: 16),
                Expanded(child: Slider(
                  value: _portionG,
                  min: 10, max: 1000,
                  divisions: 99,
                  label: '${_portionG.round()}g',
                  onChanged: (v) => setState(() => _portionG = v),
                )),
                Text('${_portionG.round()}g'),
              ],
            ),

            const Spacer(),
            FilledButton(
              onPressed: _selectedProduct != null ? _addMeal : null,
              child: const Text('Ajouter au journal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMeal() async {
    final entry = MealEntry(
      id: const Uuid().v4(),
      productName: _selectedProduct!.name,
      mealType: _selectedMealType,
      portionG: _portionG,
      loggedAt: DateTime.now(),
      nutritionData: _selectedProduct!.nutritionData,
      productId: _selectedProduct!.id,
    );
    await ref.read(nutritionLogRepositoryProvider).addMealEntry(entry);
    if (mounted) context.pop();
  }
}
```

### Project Structure Notes

- `nutrition_data_box` DOIT être ouvert via `nutritionBoxProvider` (toujours chiffré)
- `DayNutritionLog.toJson()` → JSON stocké chiffré dans Hive
- Clé Hive par date: `log_20260221` (format yyyyMMdd)
- Firestore sync: fire-and-forget (non-bloquant), la source de vérité est Hive local
- `NutritionData` est la même entité que Story 5.5 (per 100g)

### References

- [Source: epics.md#Story-7.2]
- NutritionGate [Source: Story 7.1]
- nutrition_data_box encrypted [Source: Story 7.1, architecture.md]
- NutritionData per 100g [Source: Story 5.5]
- inventoryStreamProvider [Source: Story 2.1]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
