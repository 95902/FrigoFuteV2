# Story 1.7: Set Dietary Preferences and Allergies

## Metadata
```yaml
story_id: 1-7-set-dietary-preferences-and-allergies
epic_id: epic-1
epic_name: User Authentication & Profile Management
story_name: Set Dietary Preferences and Allergies
story_points: 13
priority: high
status: ready-for-dev
created_date: 2026-02-15
updated_date: 2026-02-15
assigned_to: dev-team
sprint: epic-1-sprint-3
dependencies:
  - 0-2-configure-firebase-services-integration
  - 0-3-set-up-hive-local-database-for-offline-storage
  - 1-5-complete-adaptive-onboarding-flow
  - 1-6-configure-personal-profile-with-physical-characteristics
tags:
  - dietary-preferences
  - allergies
  - allergen-management
  - openfoodfacts
  - rgpd-article-9
  - health-data
  - recipe-filtering
  - product-scanning
```

## User Story

**As a** user who completed onboarding with dietary preferences
**I want to** update my dietary restrictions and manage my allergies
**So that I** receive accurate recipe suggestions and warnings about products containing allergens

### Business Value
- **User Safety**: Prevents allergic reactions by warning users about allergens in scanned products
- **Personalization**: Filters recipes and meals to match user's dietary lifestyle (vegetarian, vegan, gluten-free, etc.)
- **Trust Building**: Demonstrates app's commitment to user health and safety
- **Recipe Compatibility**: Increases recipe adoption by showing only compatible options
- **Competitive Differentiation**: Comprehensive allergen tracking sets app apart from competitors
- **RGPD Compliance**: Proper handling of sensitive health data (Article 9)

### User Personas
- **Primary**: Users with food allergies (nut, dairy, gluten) requiring strict avoidance
- **Secondary**: Users following dietary lifestyles (vegan, vegetarian, keto, paleo)
- **Tertiary**: Users with religious dietary restrictions (halal, kosher)

---

## Acceptance Criteria

### AC1: View Current Dietary Restrictions
**Given** I am on the Dietary Preferences screen
**When** the screen loads
**Then** I see my current dietary restrictions displayed as chips
**And** I see a count "X restrictions active"
**And** I see an "Edit Restrictions" button

### AC2: Edit Dietary Restrictions - Multi-Select
**Given** I tap "Edit Restrictions"
**When** the edit screen loads
**Then** I see 10 predefined dietary restriction chips:
  - Vegetarian 🥬
  - Vegan 🌱
  - Gluten-Free 🌾
  - Dairy-Free 🥛
  - Nut-Free 🥜
  - Halal 🕌
  - Kosher ✡️
  - Low FODMAP 🥕
  - Paleo 🥩
  - Keto 🧈
**And** I can select/deselect multiple restrictions by tapping chips
**And** selected chips show with filled background and checkmark
**And** unselected chips show with outlined border

### AC3: Add Custom Dietary Restriction
**Given** I am on the dietary restrictions edit screen
**When** I enter a custom restriction name (e.g., "Low Histamine") and tap "Add"
**Then** a new chip appears with my custom restriction
**And** it is saved with prefix "custom_low_histamine"
**And** I can delete it by tapping the X icon on the chip
**And** custom restrictions show with a "custom" badge

### AC4: Warning for Conflicting Restrictions
**Given** I select both "Vegetarian" and "Paleo"
**When** I review my selections
**Then** I see a warning message "Conflicting restrictions detected. Paleo excludes legumes and grains, which are common vegetarian protein sources. You may have limited recipe options."
**And** I can choose "Edit Restrictions" or "Continue Anyway"

### AC5: Save Dietary Restrictions
**Given** I made changes to my dietary restrictions
**When** I tap "Save" button
**Then** my changes are saved to encrypted Hive box (health_profiles_box)
**And** changes are synced to Firestore (users/{userId}/healthProfile)
**And** I see a success message "Restrictions updated"
**And** I return to the main Dietary Preferences screen
**And** recipe suggestions refresh to match new restrictions

### AC6: View Current Allergens List
**Given** I am on the Dietary Preferences screen
**When** I scroll to the Allergens section
**Then** I see my registered allergens displayed as cards
**And** each card shows:
  - Allergen name (e.g., "Peanuts")
  - Severity badge (Mild/Moderate/Severe/Life-threatening) with color coding
  - Severity icon (⚠️ warning → 🆘 emergency)
  - Custom note (if exists, truncated to 1 line)
  - Delete button (X icon)
**And** I see an "Add Allergen" button

### AC7: Add Allergen with OpenFoodFacts Validation
**Given** I tap "Add Allergen"
**When** the allergen form opens
**Then** I see a search field "Search or add allergen"
**And** as I type, I see autocomplete suggestions from OpenFoodFacts taxonomy
**And** I can select an allergen from suggestions OR enter a custom name
**And** I select a severity level (Mild/Moderate/Severe/Life-threatening)
**And** I can optionally add a custom note (max 200 chars)
**And** tapping "Add" validates the allergen name against OpenFoodFacts API
**And** if found, it stores the OFF code (e.g., "en:peanuts")
**And** if not found, it offers to add as custom allergen (isCustom: true, offCode: null)

### AC8: Allergen Severity Color Coding
**Given** I added an allergen with severity "Life-threatening"
**When** I view the allergen card
**Then** the card displays with:
  - Red background (deepOrange)
  - Emergency icon (🆘)
  - Text in white for contrast
**And** for "Severe": orange background, danger icon
**And** for "Moderate": yellow background, warning icon
**And** for "Mild": grey background, info icon

### AC9: Prevent Duplicate Allergen
**Given** I already have "Peanuts" registered
**When** I try to add "peanuts" again (case-insensitive)
**Then** I see a dialog "Allergen Already Added"
**And** the dialog says "Peanuts is already in your allergen list. Tap to update severity or note."
**And** I can choose "Update" or "Cancel"
**And** if I choose "Update", I modify the existing allergen (not create duplicate)

### AC10: Delete Allergen with Confirmation
**Given** I tap the delete (X) button on a "Severe" or "Life-threatening" allergen
**When** the confirmation dialog appears
**Then** I see:
  "Delete Life-Threatening Allergen?"
  "You're about to remove [Allergen Name] from your profile.
   You will no longer receive warnings when:
   • Scanning products containing this allergen
   • Planning meals with this allergen
   • Viewing recipes with this allergen
   Are you sure?"
**And** I can choose "Cancel" or "Delete Anyway"
**And** if I choose "Delete Anyway", the allergen is removed from Hive and Firestore

**Given** I delete a "Mild" allergen
**Then** I see a simpler confirmation "Remove [Allergen Name]?"

### AC11: Recipe Filtering by Dietary Restrictions
**Given** I have dietary restriction "Vegetarian" active
**When** I navigate to Recipes screen
**Then** I see only recipes tagged as vegetarian-compatible
**And** recipes containing meat, fish, or poultry are filtered out
**And** each recipe shows a compatibility badge:
  - ✅ "Suitable" (green) if compatible
  - ⚠️ "Contains [ingredient]" (orange) if has allergen but matches restrictions
  - ❌ "Contains meat" (red) if incompatible with restrictions

### AC12: Recipe Filtering by Allergens
**Given** I have allergen "Milk" registered
**When** I view recipes
**Then** recipes containing dairy products are filtered out
**And** only dairy-free recipes are shown
**And** if a recipe has milk but user hasn't registered it, it shows normally

### AC13: Product Scanning Allergen Warning
**Given** I have allergen "Peanuts" registered as "Life-threatening"
**When** I scan a product barcode that contains peanuts (per OpenFoodFacts data)
**Then** I immediately see a prominent RED warning dialog:
  "⚠️ ALLERGEN WARNING"
  "This product contains PEANUTS
   Severity: Life-threatening"
  "You registered this as a life-threatening allergen.
   Exercise caution or use an alternative product."
**And** I can choose:
  - "Cancel" (don't add product)
  - "Find Alternative" (search for substitute)
  - "Add Anyway" (add with warning badge)

### AC14: Custom Allergen Limitation Notice
**Given** I add a custom allergen "Sulfites" that's not in OpenFoodFacts taxonomy
**When** the allergen is saved as custom (offCode: null)
**Then** I see a notice:
  "Custom allergen added. Note: Custom allergens won't be automatically checked against product databases."
**And** the allergen card shows a "custom" badge
**And** product scans don't cross-reference this allergen (only works for OFF-validated allergens)

### AC15: OpenFoodFacts Allergen Autocomplete
**Given** I am typing in the allergen search field
**When** I type "pea"
**Then** I see autocomplete suggestions:
  - Peanuts (en:peanuts)
  - Peas (en:peas)
**And** suggestions show the OpenFoodFacts code in parentheses
**And** tapping a suggestion auto-fills the allergen name

### AC16: Allergen Note Field
**Given** I am adding an allergen
**When** I fill the optional "Notes" field with "Causes stomach cramps and hives"
**Then** the note is saved with the allergen
**And** it displays below the allergen name on the card
**And** long notes are truncated with "..." and show full text on tap

### AC17: RGPD Consent for Health Data
**Given** I am adding my first allergen
**When** the allergen form opens
**Then** I see a consent notice:
  "Your allergy information is health data protected under GDPR Article 9.
   We use it to filter recipes and warn you about allergens in products.
   Your data is encrypted and never shared with third parties.
   [I consent to storing my allergy data]"
**And** I must check the consent box before adding allergens
**And** consent is timestamped and saved to Firestore

### AC18: Offline Mode
**Given** I am offline (no internet connection)
**When** I update dietary restrictions or add allergens
**Then** changes are saved to Hive immediately
**And** I see a message "Saved locally (sync pending)"
**And** when I reconnect, changes automatically sync to Firestore
**And** OpenFoodFacts validation is skipped (allergen added as custom if offline)

### AC19: Meal Planning Integration
**Given** I have dietary restrictions "Vegan" and allergen "Soy"
**When** I navigate to Meal Planning
**Then** suggested meals are filtered to:
  - Exclude all animal products (vegan)
  - Exclude soy-containing meals
**And** incompatible meals don't appear in suggestions
**And** if I manually add an incompatible meal, I see a warning

### AC20: Recipe Substitution Suggestions
**Given** I have allergen "Milk" and I'm viewing a recipe containing dairy
**When** the recipe details load
**Then** I see a "Substitutions" section showing:
  - "Milk → Oat milk, Almond milk, Coconut milk"
  - "Butter → Vegan butter, Coconut oil"
**And** substitutions are auto-generated based on my allergen profile
**And** I can tap to view more details about each substitution

---

## Technical Specifications

### Architecture
```
Presentation Layer
├── DietaryPreferencesScreen (View)
├── DietaryPreferencesEditScreen (Edit restrictions)
├── AllergenManagementScreen (Manage allergens)
├── AllergenFormDialog (Add/edit allergen)
└── Widgets
    ├── DietaryRestrictionChip
    ├── AllergenCard
    ├── RecipeCompatibilityBadge
    └── AllergenWarningDialog

Domain Layer
├── UseCases
│   ├── UpdateDietaryRestrictionsUseCase
│   ├── AddAllergenUseCase
│   ├── DeleteAllergenUseCase
│   ├── FilterRecipesByDietaryRestrictionsUseCase
│   ├── CheckProductAllergensUseCase
│   └── SuggestRecipeSubstitutionsUseCase

Data Layer
├── Models
│   ├── AllergenModel (Hive TypeId 7)
│   ├── AllergenSeverity (enum)
│   └── HealthProfileModel (extended)
├── Repositories
│   ├── HealthProfileRepository
│   └── AllergenRepository
├── DataSources
│   ├── HealthProfileLocalDataSource (Hive)
│   ├── HealthProfileRemoteDataSource (Firestore)
│   └── OpenFoodFactsAllergenService (API)

Infrastructure
├── Services
│   ├── OpenFoodFactsAllergenService
│   ├── AllergenCrossReferenceService
│   └── RecipeFilterService
```

### Dependencies
```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.6.1
  hive: ^2.8.0
  cloud_firestore: ^4.15.0
  dio: ^5.4.0                    # HTTP client for OpenFoodFacts API
  logger: ^2.0.2                 # Logging
  uuid: ^4.3.3                   # Generate allergen IDs
```

### Data Models

#### AllergenModel
```dart
// lib/core/storage/models/allergen_model.dart
import 'package:hive/hive.dart';

part 'allergen_model.g.dart';

enum AllergenSeverity {
  mild,              // Discomfort, localized symptoms
  moderate,          // Significant symptoms, antihistamine needed
  severe,            // Anaphylaxis risk, epinephrine needed
  lifeThreatening,   // Must avoid completely
}

@HiveType(typeId: 7)
class AllergenModel extends HiveObject {
  @HiveField(0)
  final String id;  // UUID

  @HiveField(1)
  final String name;  // User-friendly name (e.g., "Peanuts")

  @HiveField(2)
  final String? offCode;  // OpenFoodFacts code (e.g., "en:peanuts")

  @HiveField(3)
  final AllergenSeverity severity;

  @HiveField(4)
  final String? customNote;  // User's custom notes

  @HiveField(5)
  final DateTime addedAt;

  @HiveField(6)
  final bool isCustom;  // true if not from OpenFoodFacts

  AllergenModel({
    required this.id,
    required this.name,
    this.offCode,
    required this.severity,
    this.customNote,
    required this.addedAt,
    this.isCustom = false,
  });

  Color get severityColor {
    return switch (severity) {
      AllergenSeverity.mild => Colors.yellow,
      AllergenSeverity.moderate => Colors.orange,
      AllergenSeverity.severe => Colors.red,
      AllergenSeverity.lifeThreatening => Colors.deepOrange,
    };
  }

  IconData get severityIcon {
    return switch (severity) {
      AllergenSeverity.mild => Icons.warning_amber,
      AllergenSeverity.moderate => Icons.warning,
      AllergenSeverity.severe => Icons.dangerous,
      AllergenSeverity.lifeThreatening => Icons.emergency,
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'offCode': offCode,
        'severity': severity.name,
        'customNote': customNote,
        'addedAt': addedAt.toIso8601String(),
        'isCustom': isCustom,
      };

  factory AllergenModel.fromJson(Map<String, dynamic> json) => AllergenModel(
        id: json['id'] as String,
        name: json['name'] as String,
        offCode: json['offCode'] as String?,
        severity: AllergenSeverity.values.byName(json['severity'] as String),
        customNote: json['customNote'] as String?,
        addedAt: DateTime.parse(json['addedAt'] as String),
        isCustom: json['isCustom'] as bool? ?? false,
      );
}
```

#### Extended HealthProfileModel
```dart
// lib/core/storage/models/health_profile_model.dart
// Add new field to existing model

@HiveField(7)
final List<AllergenModel>? allergenDetails;  // NEW: Structured allergen data

@HiveField(8)
final DateTime? lastUpdated;  // NEW: Track last modification

// Constructor parameter
HealthProfileModel({
  // ... existing parameters ...
  this.allergenDetails,
  this.lastUpdated,
});

// copyWith method
HealthProfileModel copyWith({
  // ... existing parameters ...
  List<AllergenModel>? allergenDetails,
  DateTime? lastUpdated,
}) {
  return HealthProfileModel(
    // ... existing fields ...
    allergenDetails: allergenDetails ?? this.allergenDetails,
    lastUpdated: lastUpdated ?? DateTime.now(),
  );
}
```

#### DietaryRestriction (constant data)
```dart
// lib/features/nutrition_profiles/domain/models/dietary_restriction.dart

class DietaryRestriction {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color color;

  const DietaryRestriction({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
  });
}

const dietaryRestrictionsList = [
  DietaryRestriction(
    id: 'vegetarian',
    name: 'Vegetarian',
    description: 'Excludes meat, fish, poultry',
    emoji: '🥬',
    color: Color(0xFF4CAF50),
  ),
  DietaryRestriction(
    id: 'vegan',
    name: 'Vegan',
    description: 'Excludes all animal products',
    emoji: '🌱',
    color: Color(0xFF66BB6A),
  ),
  DietaryRestriction(
    id: 'gluten_free',
    name: 'Gluten-Free',
    description: 'Excludes wheat, barley, rye',
    emoji: '🌾',
    color: Color(0xFFFFA726),
  ),
  DietaryRestriction(
    id: 'dairy_free',
    name: 'Dairy-Free',
    description: 'Excludes milk, cheese, yogurt',
    emoji: '🥛',
    color: Color(0xFFEF5350),
  ),
  DietaryRestriction(
    id: 'nut_free',
    name: 'Nut-Free',
    description: 'Excludes tree nuts and peanuts',
    emoji: '🥜',
    color: Color(0xFFAB47BC),
  ),
  DietaryRestriction(
    id: 'halal',
    name: 'Halal',
    description: 'Complies with Islamic dietary laws',
    emoji: '🕌',
    color: Color(0xFF29B6F6),
  ),
  DietaryRestriction(
    id: 'kosher',
    name: 'Kosher',
    description: 'Complies with Jewish dietary laws',
    emoji: '✡️',
    color: Color(0xFF5C6BC0),
  ),
  DietaryRestriction(
    id: 'low_fodmap',
    name: 'Low FODMAP',
    description: 'Excludes fermentable carbohydrates',
    emoji: '🥕',
    color: Color(0xFFEC407A),
  ),
  DietaryRestriction(
    id: 'paleo',
    name: 'Paleo',
    description: 'Excludes grains, legumes, dairy',
    emoji: '🥩',
    color: Color(0xFF8D6E63),
  ),
  DietaryRestriction(
    id: 'keto',
    name: 'Keto',
    description: 'High-fat, low-carb (<20g carbs/day)',
    emoji: '🧈',
    color: Color(0xFFFFB74D),
  ),
];
```

### OpenFoodFacts Allergen Service

```dart
// lib/core/services/openfoodfacts_allergen_service.dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class OpenFoodFactsAllergenService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';

  final Dio _dio;
  final Logger _logger;

  Map<String, dynamic>? _allergenCache;
  DateTime? _allergenCacheTime;

  OpenFoodFactsAllergenService({
    required Dio dio,
    required Logger logger,
  })  : _dio = dio,
        _logger = logger;

  /// Fetch allergen taxonomy from OpenFoodFacts (cached 24h)
  Future<Map<String, dynamic>> fetchAllergenTaxonomy() async {
    try {
      // Check cache first (24-hour TTL)
      if (_allergenCache != null && _allergenCacheTime != null) {
        final age = DateTime.now().difference(_allergenCacheTime!);
        if (age.inHours < 24) {
          return _allergenCache!;
        }
      }

      final response = await _dio.get(
        '$_baseUrl/allergens.json',
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        _allergenCache = response.data as Map<String, dynamic>?;
        _allergenCacheTime = DateTime.now();
        _logger.i('Fetched OFF allergen taxonomy: ${_allergenCache?.length} entries');
        return _allergenCache ?? {};
      }

      throw Exception('Failed to fetch allergen taxonomy: ${response.statusCode}');
    } catch (e) {
      _logger.e('Error fetching OFF allergen taxonomy', error: e);
      return {}; // Return empty on error (offline mode)
    }
  }

  /// Validate if allergen name exists in OFF taxonomy
  /// Returns OFF code if found (e.g., "en:peanuts"), null otherwise
  Future<String?> validateAllergenName(String allergenName) async {
    try {
      final taxonomy = await fetchAllergenTaxonomy();
      final normalizedInput = allergenName.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

      for (final entry in taxonomy.entries) {
        final code = entry.key as String;
        final data = entry.value as Map<String, dynamic>?;

        if (data == null) continue;

        // Check name
        final name = (data['name'] as String?)?.toLowerCase() ?? '';
        if (name.replaceAll(RegExp(r'\s+'), '_') == normalizedInput) {
          return code;
        }

        // Check synonyms
        final synonyms = data['synonyms'] as List?;
        if (synonyms != null) {
          for (final syn in synonyms) {
            if ((syn as String).toLowerCase().replaceAll(RegExp(r'\s+'), '_') == normalizedInput) {
              return code;
            }
          }
        }
      }

      _logger.w('Allergen not found in OFF taxonomy: $allergenName');
      return null;
    } catch (e) {
      _logger.e('Error validating allergen name', error: e);
      return null;
    }
  }

  /// Search allergens by partial name match
  Future<List<String>> searchAllergens(String query) async {
    try {
      final taxonomy = await fetchAllergenTaxonomy();
      final normalizedQuery = query.toLowerCase();
      final matches = <String>[];

      for (final entry in taxonomy.entries) {
        final code = entry.key as String;
        final data = entry.value as Map<String, dynamic>?;

        if (data == null) continue;

        final name = (data['name'] as String?)?.toLowerCase() ?? '';
        if (name.contains(normalizedQuery)) {
          matches.add(code);
        }
      }

      return matches;
    } catch (e) {
      _logger.e('Error searching allergens', error: e);
      return [];
    }
  }

  /// Get allergen by OFF code
  Future<Map<String, dynamic>?> getAllergenByCode(String code) async {
    try {
      final taxonomy = await fetchAllergenTaxonomy();
      return taxonomy[code] as Map<String, dynamic>?;
    } catch (e) {
      _logger.e('Error fetching allergen by code: $code', error: e);
      return null;
    }
  }
}
```

### Allergen Cross-Reference Service

```dart
// lib/core/services/allergen_cross_reference_service.dart

class AllergenCrossReferenceService {
  /// Check if product contains user's allergens
  List<({AllergenModel allergen, bool foundInProduct})> checkProductAllergens(
    List<String> productAllergenCodes,
    List<AllergenModel> userAllergens,
  ) {
    final results = <({AllergenModel allergen, bool foundInProduct})>[];

    for (final userAllergen in userAllergens) {
      final offCode = userAllergen.offCode;

      if (offCode == null) {
        // Custom allergen - cannot cross-reference
        results.add((allergen: userAllergen, foundInProduct: false));
      } else {
        // Check if product contains this allergen
        final found = productAllergenCodes.contains(offCode);
        results.add((allergen: userAllergen, foundInProduct: found));
      }
    }

    return results;
  }

  /// Generate warning message for product
  String generateAllergenWarning(
    List<({AllergenModel allergen, bool foundInProduct})> matches,
  ) {
    final foundAllergens = matches
        .where((m) => m.foundInProduct)
        .map((m) => m.allergen.name)
        .toList();

    if (foundAllergens.isEmpty) {
      return 'No allergens detected';
    }

    if (foundAllergens.length == 1) {
      return 'WARNING: Contains ${foundAllergens.first}!';
    }

    final last = foundAllergens.removeLast();
    return 'WARNING: Contains ${foundAllergens.join(', ')} and $last!';
  }
}
```

### Filter Recipes UseCase

```dart
// lib/features/recipes/domain/usecases/filter_recipes_by_dietary_restrictions_usecase.dart

class FilterRecipesByDietaryRestrictionsUseCase {
  final RecipeRepository _recipeRepository;

  FilterRecipesByDietaryRestrictionsUseCase(this._recipeRepository);

  Future<Either<Failure, List<RecipeModel>>> call(
    HealthProfileModel userProfile,
  ) async {
    try {
      final allRecipes = await _recipeRepository.getAllRecipes();

      // Filter by dietary restrictions
      var filtered = _filterByDietaryRestrictions(
        allRecipes,
        userProfile.dietaryRestrictions,
      );

      // Filter by allergens
      filtered = _filterByAllergens(
        filtered,
        userProfile.allergenDetails ?? [],
      );

      return Right(filtered);
    } catch (e) {
      return Left(RepositoryFailure(message: e.toString()));
    }
  }

  List<RecipeModel> _filterByDietaryRestrictions(
    List<RecipeModel> recipes,
    List<String> restrictions,
  ) {
    if (restrictions.isEmpty) return recipes;

    return recipes.where((recipe) {
      for (final restriction in restrictions) {
        if (!_isRecipeCompatibleWithRestriction(recipe, restriction)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  bool _isRecipeCompatibleWithRestriction(
    RecipeModel recipe,
    String restriction,
  ) {
    final excludedTags = _getExcludedIngredientsForRestriction(restriction);

    for (final ingredient in recipe.ingredients ?? []) {
      final ingredientLower = ingredient.toLowerCase();

      for (final excluded in excludedTags) {
        if (ingredientLower.contains(excluded)) {
          return false;
        }
      }
    }

    for (final tag in recipe.tags ?? []) {
      if (excludedTags.contains(tag.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  List<String> _getExcludedIngredientsForRestriction(String restriction) {
    return switch (restriction) {
      'vegetarian' => [
        'beef',
        'pork',
        'chicken',
        'turkey',
        'lamb',
        'fish',
        'seafood',
        'shrimp',
        'crab',
        'meat',
        'poultry'
      ],
      'vegan' => [
        'beef',
        'pork',
        'chicken',
        'turkey',
        'lamb',
        'fish',
        'seafood',
        'milk',
        'cheese',
        'butter',
        'cream',
        'yogurt',
        'egg',
        'honey',
        'whey',
        'gelatin'
      ],
      'gluten_free' => ['wheat', 'barley', 'rye', 'gluten'],
      'dairy_free' => ['milk', 'cheese', 'butter', 'cream', 'yogurt', 'whey', 'lactose'],
      'nut_free' => [
        'almond',
        'walnut',
        'hazelnut',
        'cashew',
        'pistachio',
        'peanut',
        'nut',
        'sesame'
      ],
      'halal' => ['pork', 'alcohol', 'non-halal'],
      'kosher' => ['pork', 'shellfish', 'rabbit'],
      'low_fodmap' => [
        'onion',
        'garlic',
        'wheat',
        'high-fructose',
        'bean',
        'lentil',
        'avocado'
      ],
      'paleo' => ['grain', 'legume', 'bean', 'lentil', 'dairy', 'processed', 'sugar', 'rice'],
      'keto' => ['grain', 'sugar', 'potato', 'rice', 'bean', 'fruit'],
      _ => [], // Custom restriction: no filtering
    };
  }

  List<RecipeModel> _filterByAllergens(
    List<RecipeModel> recipes,
    List<AllergenModel> userAllergens,
  ) {
    if (userAllergens.isEmpty) return recipes;

    return recipes.where((recipe) {
      for (final allergen in userAllergens) {
        if (allergen.offCode != null && _recipeContainsAllergen(recipe, allergen)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  bool _recipeContainsAllergen(RecipeModel recipe, AllergenModel allergen) {
    final offCode = allergen.offCode ?? '';

    for (final allergenTag in recipe.allergens ?? []) {
      if (allergenTag.toLowerCase().contains(offCode.toLowerCase())) {
        return true;
      }
    }

    final allergenName = allergen.name.toLowerCase();
    for (final ingredient in recipe.ingredients ?? []) {
      if (ingredient.toLowerCase().contains(allergenName)) {
        return true;
      }
    }

    return false;
  }
}
```

### Riverpod Providers

```dart
// lib/features/nutrition_profiles/presentation/providers/dietary_preferences_providers.dart

// Current dietary restrictions being edited
final dietaryRestrictionsEditProvider = StateProvider<List<String>>((ref) => []);

// Current allergens being edited
final allergenDetailsEditProvider = StateProvider<List<AllergenModel>>((ref) => []);

// Allergen search input
final allergenSearchInputProvider = StateProvider<String>((ref) => '');

// Load current health profile
final loadHealthProfileProvider = FutureProvider<HealthProfileModel?>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.getHealthProfile();
});

// Search allergens in OFF taxonomy
final searchAllergensProvider = FutureProvider.family<List<String>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];

    final offService = ref.watch(openFoodFactsAllergenServiceProvider);
    return await offService.searchAllergens(query);
  },
);

// Validate allergen name
final validateAllergenNameProvider = FutureProvider.family<String?, String>(
  (ref, allergenName) async {
    final offService = ref.watch(openFoodFactsAllergenServiceProvider);
    return await offService.validateAllergenName(allergenName);
  },
);

// Check for conflicting restrictions
final hasConflictingRestrictionsProvider = Provider<bool>((ref) {
  final restrictions = ref.watch(dietaryRestrictionsEditProvider);

  final conflictingPairs = [
    {'vegetarian', 'paleo'},
    {'vegan', 'keto'},
  ];

  for (final pair in conflictingPairs) {
    if (pair.every((r) => restrictions.contains(r))) {
      return true;
    }
  }

  return false;
});

// OpenFoodFacts service provider
final openFoodFactsAllergenServiceProvider = Provider<OpenFoodFactsAllergenService>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return OpenFoodFactsAllergenService(dio: dio, logger: logger);
});
```

### Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Health profile with RGPD Article 9 compliance
    match /users/{userId}/healthProfile {
      allow read: if request.auth.uid == userId;

      // Allow write only if user consented to health data processing
      allow write: if request.auth.uid == userId
        && get(/databases/$(database)/documents/users/$(userId)).data.consentedToHealthData == true;
    }
  }
}
```

### Firestore Data Structure

```javascript
// /users/{userId}/healthProfile
{
  id: "profile-uuid",
  profileType: "all",
  dietaryRestrictions: [
    "vegetarian",
    "gluten_free",
    "custom_low_histamine"
  ],
  allergenDetails: [
    {
      id: "allergen-uuid-1",
      name: "Peanuts",
      offCode: "en:peanuts",
      severity: "lifeThreatening",
      customNote: "Anaphylaxis, carries EpiPen",
      addedAt: "2026-02-15T10:30:00Z",
      isCustom: false
    },
    {
      id: "allergen-uuid-2",
      name: "Sulfites",
      offCode: null,
      severity: "moderate",
      customNote: "Triggers headaches",
      addedAt: "2026-02-15T10:35:00Z",
      isCustom: true
    }
  ],
  lastUpdated: "2026-02-15T10:40:00Z",
  allergyConsentGiven: true,
  allergyConsentDate: "2026-02-15T10:29:00Z",
  allergyConsentVersion: "1.0"
}
```

---

## Implementation Tasks

### Task 1: Create AllergenModel
- [ ] Create allergen_model.dart with Hive annotations
- [ ] Define AllergenSeverity enum
- [ ] Add color and icon getters
- [ ] Generate Hive adapter: `flutter pub run build_runner build`

**Estimated Time**: 1 hour

### Task 2: Extend HealthProfileModel
- [ ] Add allergenDetails field (List<AllergenModel>?)
- [ ] Add lastUpdated field (DateTime?)
- [ ] Update copyWith method
- [ ] Regenerate Hive adapter

**Estimated Time**: 30 minutes

### Task 3: Create OpenFoodFactsAllergenService
- [ ] Implement fetchAllergenTaxonomy() with 24h cache
- [ ] Implement validateAllergenName()
- [ ] Implement searchAllergens()
- [ ] Implement getAllergenByCode()
- [ ] Write unit tests

**Estimated Time**: 3 hours

### Task 4: Create AllergenCrossReferenceService
- [ ] Implement checkProductAllergens()
- [ ] Implement generateAllergenWarning()
- [ ] Write unit tests

**Estimated Time**: 1 hour

### Task 5: Create DietaryRestriction Constants
- [ ] Define dietaryRestrictionsList with 10 predefined restrictions
- [ ] Add emoji, color, description for each
- [ ] Create getDietaryRestrictionById() helper

**Estimated Time**: 30 minutes

### Task 6: Create FilterRecipesByDietaryRestrictionsUseCase
- [ ] Implement _filterByDietaryRestrictions()
- [ ] Implement _filterByAllergens()
- [ ] Define excluded ingredients for each restriction
- [ ] Write unit tests (95%+ coverage)

**Estimated Time**: 4 hours

### Task 7: Create Riverpod Providers
- [ ] Add dietaryRestrictionsEditProvider
- [ ] Add allergenDetailsEditProvider
- [ ] Add allergenSearchInputProvider
- [ ] Add searchAllergensProvider (FutureProvider.family)
- [ ] Add validateAllergenNameProvider (FutureProvider.family)
- [ ] Add hasConflictingRestrictionsProvider

**Estimated Time**: 1.5 hours

### Task 8: Build DietaryPreferencesScreen (View)
- [ ] Display current restrictions as chips
- [ ] Display allergens as cards with severity badges
- [ ] Add "Edit Restrictions" button
- [ ] Add "Add Allergen" button

**Estimated Time**: 2 hours

### Task 9: Build DietaryPreferencesEditScreen
- [ ] Display 10 predefined restriction chips
- [ ] Implement multi-select chip logic
- [ ] Add custom restriction input field
- [ ] Show warning for conflicting restrictions
- [ ] Implement save logic

**Estimated Time**: 3 hours

### Task 10: Build AllergenManagementScreen
- [ ] Add allergen search field with autocomplete
- [ ] Display recommended allergens as chips
- [ ] Show current allergens list
- [ ] Implement delete with confirmation

**Estimated Time**: 3 hours

### Task 11: Build AllergenFormDialog
- [ ] Allergen name field (pre-filled or input)
- [ ] Severity radio buttons (4 levels)
- [ ] Custom note field (optional, max 200 chars)
- [ ] Validation and duplicate check
- [ ] RGPD consent notice (first allergen only)

**Estimated Time**: 2 hours

### Task 12: Build AllergenCard Widget
- [ ] Display allergen name
- [ ] Show severity badge with color coding
- [ ] Display custom note (truncated)
- [ ] Add delete button

**Estimated Time**: 1.5 hours

### Task 13: Integrate with Recipe Filtering
- [ ] Update RecipesScreen to watch dietary restrictions
- [ ] Apply FilterRecipesByDietaryRestrictionsUseCase
- [ ] Display RecipeCompatibilityBadge on recipe cards
- [ ] Test filtering logic

**Estimated Time**: 2 hours

### Task 14: Integrate with Product Scanning
- [ ] Update OcrScanScreen to check allergens after scan
- [ ] Display AllergenWarningDialog if allergen found
- [ ] Add warning badge to product inventory item
- [ ] Test with sample products

**Estimated Time**: 2.5 hours

### Task 15: Integrate with Meal Planning
- [ ] Filter meal suggestions by dietary restrictions
- [ ] Filter meals by allergens
- [ ] Display compatibility warnings

**Estimated Time**: 1.5 hours

### Task 16: Implement RGPD Consent Flow
- [ ] Create consent dialog for first allergen
- [ ] Save consent timestamp and version to Firestore
- [ ] Check consent before saving allergens
- [ ] Add consent revocation option

**Estimated Time**: 2 hours

### Task 17: Update Firestore Security Rules
- [ ] Add rules for healthProfile document
- [ ] Add RGPD consent check
- [ ] Test rules with Firebase Emulator

**Estimated Time**: 30 minutes

### Task 18: Write Unit Tests
- [ ] Test AllergenModel
- [ ] Test OpenFoodFactsAllergenService
- [ ] Test AllergenCrossReferenceService
- [ ] Test FilterRecipesByDietaryRestrictionsUseCase
- [ ] Test dietary restriction filtering logic

**Estimated Time**: 4 hours

### Task 19: Write Widget Tests
- [ ] Test DietaryPreferencesEditScreen chip selection
- [ ] Test AllergenCard rendering
- [ ] Test AllergenFormDialog validation
- [ ] Test RecipeCompatibilityBadge display

**Estimated Time**: 3 hours

### Task 20: Write Integration Tests
- [ ] Test full flow: add restrictions, save, verify in recipes
- [ ] Test allergen warning when scanning product
- [ ] Test duplicate allergen prevention
- [ ] Test offline mode

**Estimated Time**: 2 hours

### Task 21: Manual Testing
- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Test offline mode
- [ ] Test all 10 dietary restrictions
- [ ] Test allergen severity levels
- [ ] Test OpenFoodFacts API integration

**Estimated Time**: 2 hours

---

## Testing Strategy

### Unit Tests
```dart
// test/features/nutrition_profiles/domain/usecases/filter_recipes_test.dart
void main() {
  group('FilterRecipesByDietaryRestrictionsUseCase', () {
    test('vegetarian filter removes meat recipes', () async {
      final recipe = RecipeModel(
        id: '1',
        name: 'Chicken Stir Fry',
        ingredients: ['chicken', 'soy sauce'],
      );

      final profile = HealthProfileModel(
        dietaryRestrictions: ['vegetarian'],
      );

      final result = await useCase(profile);

      expect(result.fold((l) => false, (r) => r.isEmpty), true);
    });

    test('allergen filter removes dairy recipes', () async {
      // Similar pattern
    });
  });
}
```

### Integration Tests
```dart
// integration_test/dietary_preferences_test.dart
void main() {
  testWidgets('Complete dietary preferences flow', (tester) async {
    // Navigate to dietary preferences
    // Add restrictions
    // Add allergen
    // Save
    // Verify in recipes
    // Scan product with allergen
    // Verify warning appears
  });
}
```

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Not Validating Against OpenFoodFacts
**Problem**: Accepting any allergen name without validation leads to typos and inconsistencies.

**Solution**: Always validate against OFF taxonomy first.

```dart
// ❌ WRONG
await saveAllergen(AllergenModel(name: userInput));

// ✅ CORRECT
final offCode = await offService.validateAllergenName(userInput);
if (offCode != null) {
  await saveAllergen(AllergenModel(name: userInput, offCode: offCode));
} else {
  showCustomAllergenDialog();
}
```

### ❌ Anti-Pattern 2: Storing Allergens in Plain Text
**Problem**: Allergens are RGPD Article 9 health data, must be encrypted.

**Solution**: Use encrypted Hive box.

```dart
// ❌ WRONG
final box = Hive.box('allergens');

// ✅ CORRECT
final box = await Hive.openBox(
  'health_profiles_box',
  encryptionCipher: HiveAesCipher(encryptionKey),
);
```

### ❌ Anti-Pattern 3: Not Checking RGPD Consent
**Problem**: Saving health data without consent violates RGPD.

**Solution**: Check consent flag before Firestore write.

```dart
// ❌ WRONG
await firestore.collection('users').doc(userId).update(allergens);

// ✅ CORRECT
if (userConsented) {
  await firestore.collection('users').doc(userId).update(allergens);
} else {
  throw RGPDException('Consent required');
}
```

---

## Integration Points

### Upstream Dependencies
- **Story 1.5**: Onboarding created initial dietary restrictions
- **Story 1.6**: HealthProfileModel structure established

### Downstream Consumers
- **Story 5.2**: OCR receipt scanning checks allergens
- **Story 5.5**: Barcode enrichment validates allergens
- **Story 6.1**: Recipe suggestions filtered by restrictions
- **Story 9.1**: Meal planning filtered by restrictions/allergens

---

## Dev Notes

### The 14 EU Allergens
1. Gluten (wheat, barley, rye, oats)
2. Crustaceans
3. Eggs
4. Fish
5. Peanuts
6. Soybeans
7. Milk
8. Tree nuts
9. Celery
10. Mustard
11. Sesame
12. Sulphites
13. Lupin
14. Molluscs

### RGPD Article 9 Compliance
- **Legal Basis**: Explicit consent (Article 9(2)(a))
- **Encryption**: AES-256 at rest, TLS 1.3 in transit
- **Data Minimization**: Only collect name, severity, note
- **Purpose Limitation**: Only for recipe/product filtering
- **Right to Deletion**: Implemented in Story 1.10

### OpenFoodFacts Caching
- **TTL**: 24 hours
- **Size**: ~500 allergen entries
- **Fallback**: Empty map on error (offline mode)

---

## Definition of Done

### Code Complete
- [ ] AllergenModel created with Hive adapter
- [ ] HealthProfileModel extended
- [ ] OpenFoodFactsAllergenService implemented
- [ ] FilterRecipesByDietaryRestrictionsUseCase implemented
- [ ] All screens and widgets created
- [ ] Riverpod providers configured
- [ ] RGPD consent flow implemented

### Testing Complete
- [ ] Unit tests 95%+ coverage
- [ ] Widget tests for all screens
- [ ] Integration test: full flow
- [ ] Manual test: all 10 restrictions
- [ ] Manual test: allergen severity levels
- [ ] Manual test: offline mode

### Integration Complete
- [ ] Recipe filtering works
- [ ] Product scanning warnings work
- [ ] Meal planning filtering works
- [ ] Firestore sync works offline-first

### Documentation Complete
- [ ] README updated
- [ ] RGPD compliance documented
- [ ] 14 EU allergens documented

### Deployment Ready
- [ ] All 20 Acceptance Criteria verified
- [ ] Firestore Security Rules deployed
- [ ] No critical bugs
- [ ] Code reviewed

---

## References

- [OpenFoodFacts Allergen Taxonomy](https://wiki.openfoodfacts.org/Global_allergens_taxonomy)
- [GDPR Article 9](https://gdpr-info.eu/art-9-gdpr/)
- [EU Allergen Regulation](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32011L0091)

---

## Changelog

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-02-15 | 1.0 | Dev Team | Initial story creation for Epic 1 Sprint 3 |

---

**Story Status**: ✅ Ready for Development
**Epic Progress**: Epic 1 - Story 7 of 10 (70% planned)
**Next Story**: 1-8-synchronize-data-across-multiple-devices
**Blocked By**: None
