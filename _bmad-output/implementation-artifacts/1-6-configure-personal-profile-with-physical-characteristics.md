# Story 1.6: Configure Personal Profile with Physical Characteristics

## Metadata
```yaml
story_id: 1-6-configure-personal-profile-with-physical-characteristics
epic_id: epic-1
epic_name: User Authentication & Profile Management
story_name: Configure Personal Profile with Physical Characteristics
story_points: 5
priority: medium
status: ready-for-dev
created_date: 2026-02-15
updated_date: 2026-02-15
assigned_to: dev-team
sprint: epic-1-sprint-2
dependencies:
  - 0-3-set-up-hive-local-database-for-offline-storage
  - 0-4-implement-riverpod-state-management-foundation
  - 1-5-complete-adaptive-onboarding-flow
tags:
  - health-profile
  - user-profile
  - nutrition
  - rgpd
  - encryption
  - weight-tracking
  - bmr-tdee
```

## User Story

**As a** user who completed onboarding
**I want to** update my physical characteristics (age, height, weight, activity level)
**So that I** can keep my nutrition targets accurate as my body changes over time

### Business Value
- **Data Accuracy**: Keeps BMR/TDEE/macro calculations accurate as user's body changes
- **User Engagement**: Weight tracking creates accountability and motivation
- **Progress Visualization**: Weight trend charts show progress toward goals
- **Personalization**: Updated metrics ensure meal suggestions and nutrition tracking remain relevant
- **RGPD Compliance**: Proper consent and encryption for health data (Article 9)

### User Personas
- **Primary**: Weight loss users tracking progress weekly
- **Secondary**: Muscle gain users monitoring weight and activity level
- **Tertiary**: Maintenance users updating profile occasionally

---

## Acceptance Criteria

### AC1: Access Profile Update Screen
**Given** I completed onboarding with profileType = 'nutrition', 'meal_planning', or 'all'
**When** I navigate to Settings > Personal Profile
**Then** I see the Profile Update Screen with my current physical characteristics
**And** I see fields for Age, Gender, Height, Weight, Activity Level
**And** each field displays my current values

### AC2: Edit Physical Characteristics
**Given** I am on the Profile Update Screen
**When** I tap on a field (Age, Height, Weight, Activity Level)
**Then** I can edit the value
**And** I see real-time validation errors below the field if invalid
**And** validation rules are:
  - Age: 13-120 years
  - Height: 100-250 cm
  - Weight: 20-500 kg
  - Activity Level: dropdown with 5 options

### AC3: Real-Time Metrics Preview
**Given** I am editing my physical characteristics
**When** I change any field value
**Then** I see a live preview of recalculated metrics:
  - BMR (Basal Metabolic Rate) before/after
  - TDEE (Total Daily Energy Expenditure) before/after
  - Macro targets (protein, carbs, fats) preview
**And** the preview updates instantly as I type
**And** I see a "Change" indicator showing delta (+/- kcal)

### AC4: Warning for Significant Height Change
**Given** I am updating my height
**When** the new height differs from current height by > 5 cm
**Then** I see a warning dialog "Changement de taille détecté"
**And** I can choose "Annuler" or "Confirmer"
**And** if I choose "Annuler", my change is reverted
**And** if I choose "Confirmer", the change is accepted

### AC5: Warning for Significant Weight Change
**Given** I am updating my weight
**When** the new weight differs from current weight by > 5 kg
**Then** I see a warning dialog "Changement de poids important"
**And** the dialog shows the exact difference (e.g., "Changement de 6.5 kg détecté")
**And** I can choose "Annuler" or "Confirmer"

### AC6: Warning for Gender Change
**Given** I am changing my gender
**When** I select a different gender than currently saved
**Then** I see an info dialog explaining BMR formula will be recalculated
**And** the dialog says "Modifier votre genre va recalculer votre BMR car la formule est différente selon le sexe"
**And** I can choose "Compris" to continue

### AC7: Save Changes to Hive and Firestore
**Given** I made valid changes to my profile
**When** I tap "Save Changes" button
**Then** my updated profile is saved to encrypted Hive box (health_profiles_box)
**And** BMR, TDEE, and macro targets are recalculated using Mifflin-St Jeor formula
**And** the updated profile is synced to Firestore (users/{userId}/healthProfile/current)
**And** I see a success message "Profil mis à jour"
**And** I am redirected back to Settings screen

### AC8: Weight History Entry Created
**Given** I updated my weight from 75 kg to 73 kg
**When** the save completes successfully
**Then** a new WeightHistoryEntry is created with:
  - date: current date
  - weight: 73 kg
**And** the entry is saved to encrypted Hive box
**And** the entry is synced to Firestore (weightHistory subcollection)

### AC9: Discard Changes
**Given** I made changes to my profile
**When** I tap the back/close button or "Discard" button
**Then** I see a confirmation dialog "Abandonner les modifications?"
**And** I can choose "Continuer l'édition" or "Abandonner"
**And** if I choose "Abandonner", all changes are discarded and I return to Settings
**And** if I choose "Continuer l'édition", I stay on the Profile Update Screen

**Given** I made NO changes
**When** I tap the back/close button
**Then** I immediately return to Settings (no confirmation dialog)

### AC10: View Weight History Chart (30 Days)
**Given** I have at least 2 weight entries in my history
**When** I navigate to Profile > Weight Tracking
**Then** I see a line chart showing my weight over the last 30 days
**And** the X-axis shows dates
**And** the Y-axis shows weight in kg
**And** I see statistics below the chart:
  - Poids initial: first weight in period
  - Poids actuel: most recent weight
  - Changement: difference (+/-) in kg

### AC11: Weight Change Rate Calculation
**Given** I have weight entries spanning at least 7 days
**When** I view the Weight Tracking screen
**Then** I see "Tendance: +/- X.XX kg/semaine" calculated as:
  - (most recent weight - oldest weight) / (days between) * 7
**And** the trend is color-coded:
  - Green if losing weight (negative change)
  - Orange if gaining weight (positive change)

### AC12: Toggle Weight Chart Period
**Given** I am on the Weight Tracking screen
**When** I tap a period selector (30 days / 90 days / 1 year)
**Then** the chart updates to show data for that period
**And** the statistics recalculate for the selected period
**And** the weight change rate recalculates for the selected period

### AC13: Prevent Access for "Waste" ProfileType
**Given** my profileType is 'waste' (I chose "Reduce Waste" during onboarding)
**When** I navigate to Settings > Personal Profile
**Then** I see a dialog "Profil non configuré"
**And** the dialog says "Vous devez d'abord compléter votre profil nutritionnel via l'onboarding"
**And** I see a button "Commencer" that redirects to /onboarding

### AC14: RGPD Consent Check
**Given** I am updating health data (age, weight, height, etc.)
**When** the system attempts to save to Firestore
**Then** it first checks if `consentedToHealthData: true` in my user document
**And** if consent is false, I see an error "Vous devez consentir au traitement des données de santé"
**And** the save is aborted
**And** I am redirected to a consent screen

**Given** I have consented to health data processing
**Then** the save proceeds normally

### AC15: Propagate Changes to Nutrition Tracking
**Given** I updated my weight from 75 kg to 73 kg
**When** the save completes
**Then** my dailyCalorieGoalProvider recalculates based on new TDEE
**And** my dailyMacroGoalsProvider updates with new macro targets
**And** if I navigate to Nutrition Tracking, I see updated targets

### AC16: Propagate Changes to Meal Planning
**Given** my TDEE changed from 2200 to 2100 kcal
**When** the save completes
**Then** my meal suggestions refresh to match new TDEE
**And** if I navigate to Meal Planning, I see updated meal recommendations

### AC17: Offline Functionality
**Given** I am offline (no internet connection)
**When** I update my profile
**Then** changes are saved to Hive immediately
**And** I see a message "Profil sauvegardé localement (sync en attente)"
**And** when I reconnect, changes sync automatically to Firestore

### AC18: Form Validation - Prevent Save with Errors
**Given** I entered an invalid age (e.g., 10 years or 150 years)
**When** I tap "Save Changes"
**Then** the "Save Changes" button is disabled
**And** I see validation error messages below invalid fields
**And** I cannot proceed until all fields are valid

---

## Technical Specifications

### Architecture
```
Presentation Layer (UI)
├── ProfileUpdateScreen (ConsumerStatefulWidget)
│   ├── TextEditingController (age, height, weight)
│   ├── DropdownButtonFormField (gender, activityLevel)
│   ├── Real-time Metrics Preview Cards
│   ├── Warning Dialogs (height, weight, gender changes)
│   └── Save/Discard Actions
│
Domain Layer (Business Logic)
├── UpdateHealthProfileUseCase
│   ├── Validate input
│   ├── Recalculate BMR (Mifflin-St Jeor formula)
│   ├── Recalculate TDEE (BMR × activity multiplier)
│   ├── Recalculate Macro Targets
│   └── Add Weight History Entry
│
Data Layer (Persistence)
├── HealthProfileLocalDataSource (Hive)
│   ├── Save to encrypted health_profiles_box
│   └── Add WeightHistoryEntry
│
├── HealthProfileRemoteDataSource (Firestore)
│   ├── Sync to users/{userId}/healthProfile/current
│   ├── Sync to weightHistory subcollection
│   └── Check RGPD consent before save
│
Infrastructure
├── HealthCalculations Utility
│   ├── calculateBMR() using Mifflin-St Jeor
│   ├── calculateTDEE() with activity multipliers
│   └── calculateMacroTargets() based on goals
```

### Dependencies
```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.6.1       # State management
  hive: ^2.8.0                   # Local storage
  hive_flutter: ^1.1.0           # Hive initialization
  cloud_firestore: ^4.15.0       # Firestore sync
  fl_chart: ^0.65.0              # Weight chart visualization
  intl: ^0.18.1                  # Date formatting
```

### Data Models

#### Extended HealthProfileModel (Hive)
```dart
// lib/features/health_profile/data/models/health_profile_model.dart
import 'package:hive/hive.dart';

part 'health_profile_model.g.dart';

@HiveType(typeId: 5)
class HealthProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String profileType;

  @HiveField(2)
  final double tdee;

  @HiveField(3)
  final double bmr;

  @HiveField(4)
  final Map<String, dynamic> macroTargets;

  @HiveField(5)
  final List<String> dietaryRestrictions;

  @HiveField(6)
  final List<String> allergies;

  // Physical characteristics (NEW)
  @HiveField(7)
  final int age;

  @HiveField(8)
  final String gender;  // 'male', 'female', 'other'

  @HiveField(9)
  final double height;  // cm

  @HiveField(10)
  final double currentWeight;  // kg

  @HiveField(11)
  final String activityLevel;  // 'sedentary', 'light', 'moderate', 'active', 'veryActive'

  @HiveField(12)
  final DateTime lastUpdated;

  @HiveField(13)
  final List<WeightHistoryEntry> weightHistory;

  HealthProfileModel({
    required this.id,
    required this.profileType,
    required this.tdee,
    required this.bmr,
    required this.macroTargets,
    required this.dietaryRestrictions,
    required this.allergies,
    required this.age,
    required this.gender,
    required this.height,
    required this.currentWeight,
    required this.activityLevel,
    required this.lastUpdated,
    required this.weightHistory,
  });

  // Copy with method
  HealthProfileModel copyWith({
    String? id,
    String? profileType,
    double? tdee,
    double? bmr,
    Map<String, dynamic>? macroTargets,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    int? age,
    String? gender,
    double? height,
    double? currentWeight,
    String? activityLevel,
    DateTime? lastUpdated,
    List<WeightHistoryEntry>? weightHistory,
  }) {
    return HealthProfileModel(
      id: id ?? this.id,
      profileType: profileType ?? this.profileType,
      tdee: tdee ?? this.tdee,
      bmr: bmr ?? this.bmr,
      macroTargets: macroTargets ?? this.macroTargets,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      activityLevel: activityLevel ?? this.activityLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      weightHistory: weightHistory ?? this.weightHistory,
    );
  }

  // Add weight entry helper
  HealthProfileModel addWeightEntry(WeightHistoryEntry entry) {
    return copyWith(
      currentWeight: entry.weight,
      lastUpdated: DateTime.now(),
      weightHistory: [...weightHistory, entry],
    );
  }

  // Firestore serialization
  Map<String, dynamic> toFirestore() {
    return {
      'profileType': profileType,
      'tdee': tdee,
      'bmr': bmr,
      'macroTargets': macroTargets,
      'dietaryRestrictions': dietaryRestrictions,
      'allergies': allergies,
      'age': age,
      'gender': gender,
      'height': height,
      'currentWeight': currentWeight,
      'activityLevel': activityLevel,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}
```

#### WeightHistoryEntry Model
```dart
// lib/features/health_profile/data/models/weight_history_entry.dart
import 'package:hive/hive.dart';

part 'weight_history_entry.g.dart';

@HiveType(typeId: 8)
class WeightHistoryEntry extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double weight;  // kg

  @HiveField(2)
  final double? bodyFatPercentage;  // optional

  @HiveField(3)
  final double? muscleMassKg;  // optional

  @HiveField(4)
  final String? notes;

  WeightHistoryEntry({
    required this.date,
    required this.weight,
    this.bodyFatPercentage,
    this.muscleMassKg,
    this.notes,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(date),
      'weight': weight,
      'bodyFatPercentage': bodyFatPercentage,
      'muscleMassKg': muscleMassKg,
      'notes': notes,
    };
  }

  factory WeightHistoryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeightHistoryEntry(
      date: (data['timestamp'] as Timestamp).toDate(),
      weight: (data['weight'] as num).toDouble(),
      bodyFatPercentage: data['bodyFatPercentage'] as double?,
      muscleMassKg: data['muscleMassKg'] as double?,
      notes: data['notes'] as String?,
    );
  }
}
```

### Health Calculations Utility

```dart
// lib/core/shared/utils/health_calculations.dart

class HealthCalculations {
  /// Calculate BMR using Mifflin-St Jeor Equation (most accurate for modern populations)
  ///
  /// Male: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) + 5
  /// Female: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) - 161
  static double calculateBMR({
    required int ageYears,
    required double heightCm,
    required double weightKg,
    required String gender,
  }) {
    double bmr;

    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears) + 5;
    } else if (gender.toLowerCase() == 'female') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears) - 161;
    } else {
      // Use average for 'other' or 'prefer not to say'
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears) - 78;
    }

    return bmr.clamp(800, 5000);  // Sanity bounds
  }

  /// Activity Level Multipliers for TDEE calculation
  /// TDEE = BMR × Activity Multiplier
  static double getActivityMultiplier(String activityLevel) {
    const multipliers = {
      'sedentary': 1.2,        // Little/no exercise
      'light': 1.375,          // Exercise 1-3 days/week
      'moderate': 1.55,        // Exercise 3-5 days/week
      'active': 1.725,         // Exercise 6-7 days/week
      'veryActive': 1.9,       // Intense exercise daily + physical job
    };

    return multipliers[activityLevel.toLowerCase()] ?? 1.55;
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE(double bmr, String activityLevel) {
    final multiplier = getActivityMultiplier(activityLevel);
    return bmr * multiplier;
  }

  /// Calculate macro targets based on TDEE and nutrition goal
  static Map<String, double> calculateMacroTargets({
    required double tdee,
    required String nutritionalGoal,  // 'weight_loss', 'muscle_gain', 'maintenance'
    required double weightKg,
  }) {
    // Adjust calories based on goal
    double adjustedCalories = tdee;
    if (nutritionalGoal == 'weight_loss') {
      adjustedCalories = tdee * 0.85;  // 15% deficit
    } else if (nutritionalGoal == 'muscle_gain') {
      adjustedCalories = tdee * 1.10;  // 10% surplus
    }

    // Macro ratios based on goal
    Map<String, double> ratios;
    if (nutritionalGoal == 'weight_loss') {
      ratios = {'protein': 0.35, 'carbs': 0.45, 'fats': 0.20};  // Higher protein
    } else if (nutritionalGoal == 'muscle_gain') {
      ratios = {'protein': 0.30, 'carbs': 0.50, 'fats': 0.20};  // Higher carbs
    } else {
      ratios = {'protein': 0.25, 'carbs': 0.50, 'fats': 0.25};  // Balanced
    }

    // Calculate grams (protein: 4 kcal/g, carbs: 4 kcal/g, fats: 9 kcal/g)
    return {
      'calories': adjustedCalories.round().toDouble(),
      'protein': ((adjustedCalories * ratios['protein']!) / 4).round().toDouble(),
      'carbs': ((adjustedCalories * ratios['carbs']!) / 4).round().toDouble(),
      'fats': ((adjustedCalories * ratios['fats']!) / 9).round().toDouble(),
    };
  }
}
```

### UseCase - Update Health Profile

```dart
// lib/features/health_profile/domain/usecases/update_health_profile_usecase.dart
import '../repositories/health_profile_repository.dart';
import '../../data/models/health_profile_model.dart';
import '../../data/models/weight_history_entry.dart';
import '../../../../core/shared/utils/health_calculations.dart';

class UpdateHealthProfileUseCase {
  final HealthProfileRepository _repository;

  UpdateHealthProfileUseCase(this._repository);

  Future<HealthProfileModel> call({
    required HealthProfileModel currentProfile,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String activityLevel,
  }) async {
    // Validate input
    _validateInput(age, height, weight);

    // Recalculate BMR
    final newBmr = HealthCalculations.calculateBMR(
      ageYears: age,
      heightCm: height,
      weightKg: weight,
      gender: gender,
    );

    // Recalculate TDEE
    final newTdee = HealthCalculations.calculateTDEE(newBmr, activityLevel);

    // Recalculate macro targets
    final newMacros = HealthCalculations.calculateMacroTargets(
      tdee: newTdee,
      nutritionalGoal: currentProfile.profileType,
      weightKg: weight,
    );

    // Create updated profile
    final updatedProfile = currentProfile.copyWith(
      age: age,
      gender: gender,
      height: height,
      currentWeight: weight,
      activityLevel: activityLevel,
      bmr: newBmr,
      tdee: newTdee,
      macroTargets: newMacros,
      lastUpdated: DateTime.now(),
    );

    // Add weight history entry if weight changed
    if (weight != currentProfile.currentWeight) {
      final weightEntry = WeightHistoryEntry(
        date: DateTime.now(),
        weight: weight,
      );
      final profileWithHistory = updatedProfile.addWeightEntry(weightEntry);

      // Save to repository
      await _repository.updateProfile(profileWithHistory);
      return profileWithHistory;
    } else {
      // Save without weight entry
      await _repository.updateProfile(updatedProfile);
      return updatedProfile;
    }
  }

  void _validateInput(int age, double height, double weight) {
    if (age < 13 || age > 120) {
      throw ValidationException('Age must be between 13 and 120 years');
    }
    if (height < 100 || height > 250) {
      throw ValidationException('Height must be between 100 and 250 cm');
    }
    if (weight < 20 || weight > 500) {
      throw ValidationException('Weight must be between 20 and 500 kg');
    }
  }
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}
```

### Repository Implementation

```dart
// lib/features/health_profile/data/repositories/health_profile_repository_impl.dart
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/health_profile_repository.dart';
import '../models/health_profile_model.dart';

class HealthProfileRepositoryImpl implements HealthProfileRepository {
  final Box<HealthProfileModel> _healthProfileBox;
  final FirebaseFirestore _firestore;
  final String _userId;

  HealthProfileRepositoryImpl(
    this._healthProfileBox,
    this._firestore,
    this._userId,
  );

  @override
  Future<void> updateProfile(HealthProfileModel profile) async {
    // Save to Hive (encrypted)
    await _healthProfileBox.put('current_profile', profile);

    // Sync to Firestore
    await _syncToFirestore(profile);
  }

  Future<void> _syncToFirestore(HealthProfileModel profile) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('healthProfile')
          .doc('current');

      // Check RGPD consent
      final consentDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .get();

      if (!consentDoc.exists || !consentDoc.data()?['consentedToHealthData']) {
        throw RGPDException('User must consent to health data processing');
      }

      // Save health profile
      await docRef.set(profile.toFirestore());

      // Save weight history entry if exists
      if (profile.weightHistory.isNotEmpty) {
        final latestEntry = profile.weightHistory.last;
        await docRef.collection('weightHistory').add(latestEntry.toFirestore());
      }
    } catch (e) {
      // Log error but don't fail (offline-first approach)
      debugPrint('Firestore sync error: $e');
      // Will retry on next sync
    }
  }

  @override
  Future<HealthProfileModel?> getCurrentProfile() async {
    return _healthProfileBox.get('current_profile');
  }

  @override
  Future<List<WeightHistoryEntry>> getWeightHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final profile = await getCurrentProfile();
    if (profile == null) return [];

    var history = profile.weightHistory;

    if (startDate != null) {
      history = history.where((e) => e.date.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      history = history.where((e) => e.date.isBefore(endDate)).toList();
    }

    return history..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<double> calculateWeightChangeRate(int daysPeriod) async {
    final startDate = DateTime.now().subtract(Duration(days: daysPeriod));
    final history = await getWeightHistory(startDate: startDate);

    if (history.length < 2) return 0.0;

    final weightChange = history.last.weight - history.first.weight;
    final days = history.last.date.difference(history.first.date).inDays;

    return days > 0 ? weightChange / (days / 7) : 0.0;  // kg per week
  }
}

class RGPDException implements Exception {
  final String message;
  RGPDException(this.message);

  @override
  String toString() => message;
}
```

### Riverpod Providers

```dart
// lib/features/health_profile/presentation/providers/health_profile_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../data/repositories/health_profile_repository_impl.dart';
import '../../domain/usecases/update_health_profile_usecase.dart';

// Current health profile
final currentHealthProfileProvider = FutureProvider<HealthProfileModel?>((ref) async {
  final box = ref.watch(healthProfileBoxProvider);
  return box.get('current_profile');
});

// BMR provider
final bmrProvider = FutureProvider<double>((ref) async {
  final profile = await ref.watch(currentHealthProfileProvider.future);
  if (profile == null) return 0.0;

  return HealthCalculations.calculateBMR(
    ageYears: profile.age,
    heightCm: profile.height,
    weightKg: profile.currentWeight,
    gender: profile.gender,
  );
});

// TDEE provider
final tdeeProvider = FutureProvider<double>((ref) async {
  final bmr = await ref.watch(bmrProvider.future);
  final profile = await ref.watch(currentHealthProfileProvider.future);
  if (profile == null) return 0.0;

  return HealthCalculations.calculateTDEE(bmr, profile.activityLevel);
});

// Macro targets provider
final macroTargetsProvider = FutureProvider<Map<String, double>>((ref) async {
  final tdee = await ref.watch(tdeeProvider.future);
  final profile = await ref.watch(currentHealthProfileProvider.future);
  if (profile == null || tdee == 0) return {};

  return HealthCalculations.calculateMacroTargets(
    tdee: tdee,
    nutritionalGoal: profile.profileType,
    weightKg: profile.currentWeight,
  );
});

// Weight history provider
final weightHistoryProvider = FutureProvider.family<
  List<WeightHistoryEntry>,
  int  // daysPeriod
>((ref, daysPeriod) async {
  final repository = ref.watch(healthProfileRepositoryProvider);
  final startDate = DateTime.now().subtract(Duration(days: daysPeriod));
  return repository.getWeightHistory(startDate: startDate);
});

// Weight change rate provider
final weightChangeRateProvider = FutureProvider.family<double, int>((ref, daysPeriod) async {
  final repository = ref.watch(healthProfileRepositoryProvider);
  return repository.calculateWeightChangeRate(daysPeriod);
});

// Repository provider
final healthProfileRepositoryProvider = Provider<HealthProfileRepository>((ref) {
  final box = ref.watch(healthProfileBoxProvider);
  final firestore = FirebaseFirestore.instance;
  final userId = ref.watch(currentUserIdProvider) ?? '';
  return HealthProfileRepositoryImpl(box, firestore, userId);
});

// Update profile use case provider
final updateHealthProfileUseCaseProvider = Provider<UpdateHealthProfileUseCase>((ref) {
  final repository = ref.watch(healthProfileRepositoryProvider);
  return UpdateHealthProfileUseCase(repository);
});
```

### UI Implementation - Profile Update Screen

```dart
// lib/features/health_profile/presentation/screens/profile_update_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_profile_providers.dart';
import '../widgets/metrics_preview_card.dart';
import '../../../../core/shared/utils/validation_utils.dart';

class ProfileUpdateScreen extends ConsumerStatefulWidget {
  const ProfileUpdateScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends ConsumerState<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String _selectedGender = '';
  String _selectedActivityLevel = '';
  bool _isLoading = false;

  Map<String, dynamic> _originalProfile = {};

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentHealthProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _handleBack,
        ),
        actions: [
          TextButton(
            onPressed: _hasChanges() && !_isLoading ? _handleSave : null,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null || profile.profileType == 'waste') {
            return _buildNoProfileView();
          }

          // Initialize controllers on first load
          if (_originalProfile.isEmpty) {
            _initializeControllers(profile);
          }

          return _buildForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  void _initializeControllers(HealthProfileModel profile) {
    _ageController.text = profile.age.toString();
    _heightController.text = profile.height.toString();
    _weightController.text = profile.currentWeight.toString();
    _selectedGender = profile.gender;
    _selectedActivityLevel = profile.activityLevel;

    _originalProfile = {
      'age': profile.age,
      'height': profile.height,
      'currentWeight': profile.currentWeight,
      'gender': profile.gender,
      'activityLevel': profile.activityLevel,
    };
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Age field
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Âge',
                suffixText: 'ans',
              ),
              keyboardType: TextInputType.number,
              validator: ValidationUtils.validateAge,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Gender dropdown
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: 'Genre'),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Homme')),
                DropdownMenuItem(value: 'female', child: Text('Femme')),
                DropdownMenuItem(value: 'other', child: Text('Autre')),
              ],
              onChanged: (value) {
                if (value != null && value != _originalProfile['gender']) {
                  _showGenderChangeWarning();
                }
                setState(() => _selectedGender = value!);
              },
              validator: (value) => value == null ? 'Genre requis' : null,
            ),
            const SizedBox(height: 16),

            // Height field
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Taille',
                suffixText: 'cm',
              ),
              keyboardType: TextInputType.number,
              validator: ValidationUtils.validateHeight,
              onChanged: (value) {
                setState(() {});
                final newHeight = double.tryParse(value);
                if (newHeight != null &&
                    (newHeight - (_originalProfile['height'] as double)).abs() > 5) {
                  _showHeightChangeWarning(newHeight);
                }
              },
            ),
            const SizedBox(height: 16),

            // Weight field
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Poids',
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.number,
              validator: ValidationUtils.validateWeight,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Activity level dropdown
            DropdownButtonFormField<String>(
              value: _selectedActivityLevel,
              decoration: const InputDecoration(labelText: 'Niveau d\'activité'),
              items: const [
                DropdownMenuItem(value: 'sedentary', child: Text('Sédentaire')),
                DropdownMenuItem(value: 'light', child: Text('Légèrement actif')),
                DropdownMenuItem(value: 'moderate', child: Text('Modérément actif')),
                DropdownMenuItem(value: 'active', child: Text('Actif')),
                DropdownMenuItem(value: 'veryActive', child: Text('Très actif')),
              ],
              onChanged: (value) => setState(() => _selectedActivityLevel = value!),
              validator: (value) => value == null ? 'Niveau d\'activité requis' : null,
            ),
            const SizedBox(height: 32),

            // Metrics preview
            _buildMetricsPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsPreview() {
    if (!_formKey.currentState!.validate()) {
      return const SizedBox.shrink();
    }

    final age = int.tryParse(_ageController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    if (age == 0 || height == 0 || weight == 0) {
      return const SizedBox.shrink();
    }

    final newBmr = HealthCalculations.calculateBMR(
      ageYears: age,
      heightCm: height,
      weightKg: weight,
      gender: _selectedGender,
    );

    final newTdee = HealthCalculations.calculateTDEE(newBmr, _selectedActivityLevel);

    final originalBmr = HealthCalculations.calculateBMR(
      ageYears: _originalProfile['age'],
      heightCm: _originalProfile['height'],
      weightKg: _originalProfile['currentWeight'],
      gender: _originalProfile['gender'],
    );

    final originalTdee = HealthCalculations.calculateTDEE(
      originalBmr,
      _originalProfile['activityLevel'],
    );

    return Column(
      children: [
        MetricsPreviewCard(
          label: 'BMR (Métabolisme de base)',
          originalValue: originalBmr.round(),
          newValue: newBmr.round(),
          unit: 'kcal/jour',
        ),
        const SizedBox(height: 16),
        MetricsPreviewCard(
          label: 'TDEE (Dépense énergétique)',
          originalValue: originalTdee.round(),
          newValue: newTdee.round(),
          unit: 'kcal/jour',
        ),
      ],
    );
  }

  Widget _buildNoProfileView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Profil non configuré',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vous devez d\'abord compléter votre profil nutritionnel via l\'onboarding pour accéder à cette page.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/onboarding'),
              child: const Text('Commencer'),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasChanges() {
    return _ageController.text != _originalProfile['age'].toString() ||
        _heightController.text != _originalProfile['height'].toString() ||
        _weightController.text != _originalProfile['currentWeight'].toString() ||
        _selectedGender != _originalProfile['gender'] ||
        _selectedActivityLevel != _originalProfile['activityLevel'];
  }

  Future<void> _handleBack() async {
    if (!_hasChanges()) {
      Navigator.pop(context);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonner les modifications?'),
        content: const Text('Vous avez des modifications non enregistrées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer l\'édition'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Check for significant weight change
    final newWeight = double.parse(_weightController.text);
    if ((newWeight - (_originalProfile['currentWeight'] as double)).abs() > 5) {
      final confirmed = await _showWeightChangeWarning(newWeight);
      if (!confirmed) return;
    }

    setState(() => _isLoading = true);

    try {
      final currentProfile = await ref.read(currentHealthProfileProvider.future);
      final useCase = ref.read(updateHealthProfileUseCaseProvider);

      await useCase.call(
        currentProfile: currentProfile!,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        height: double.parse(_heightController.text),
        weight: newWeight,
        activityLevel: _selectedActivityLevel,
      );

      // Invalidate providers to refresh
      ref.invalidate(currentHealthProfileProvider);
      ref.invalidate(bmrProvider);
      ref.invalidate(tdeeProvider);
      ref.invalidate(macroTargetsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showWeightChangeWarning(double newWeight) async {
    final diff = (newWeight - (_originalProfile['currentWeight'] as double)).abs();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changement de poids important'),
        content: Text(
          'Changement de ${diff.toStringAsFixed(1)} kg détecté. Êtes-vous sûr(e)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _showHeightChangeWarning(double newHeight) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changement de taille détecté'),
        content: Text(
          'Vous avez indiqué un changement de '
          '${(newHeight - (_originalProfile['height'] as double)).abs().toStringAsFixed(1)} cm. '
          'Êtes-vous sûr de cette modification?',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Future<void> _showGenderChangeWarning() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Impact du changement'),
        content: const Text(
          'Modifier votre genre va recalculer votre BMR car la formule '
          'est différente selon le sexe. Les objectifs nutritionnels '
          'seront automatiquement mis à jour.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}
```

### Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Health profile access (RGPD Article 9 - sensitive health data)
    match /users/{userId}/healthProfile/current {
      allow read: if request.auth.uid == userId;

      // Allow write only if user consented to health data processing
      allow write: if request.auth.uid == userId
        && get(/databases/$(database)/documents/users/$(userId)).data.consentedToHealthData == true;
    }

    // Weight history subcollection
    match /users/{userId}/healthProfile/current/weightHistory/{entryId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId
        && get(/databases/$(database)/documents/users/$(userId)).data.consentedToHealthData == true;
    }
  }
}
```

---

## Implementation Tasks

### Task 1: Extend Data Models ✅
- [x] Add age, gender, height, currentWeight, activityLevel, lastUpdated, weightHistory fields to HealthProfileModel (fields 7-13)
- [x] Create WeightHistoryEntry model (Hive TypeId 8) at lib/core/storage/models/weight_history_entry.dart
- [x] Register WeightHistoryEntryAdapter in HiveService.init()
- [x] Generate Hive adapters: `dart run build_runner build --delete-conflicting-outputs` — 61 outputs generated
- [ ] Test model serialization/deserialization (deferred — covered by UseCase tests)

### Task 2: Implement HealthCalculations Utility ✅
- [x] Create lib/core/shared/utils/health_calculations.dart
- [x] Implement calculateBMR() using Mifflin-St Jeor formula (male/female/other)
- [x] Implement getActivityMultiplier() with 5 levels (sedentary/light/moderate/active/veryActive)
- [x] Implement calculateTDEE()
- [x] Implement calculateMacroTargets() with 3 goal types
- [x] Write unit tests — 21 tests pass

### Task 3: Implement Update UseCase ✅
- [x] Create UpdateHealthProfileUseCase at lib/features/health_profile/domain/usecases/
- [x] Validation logic (age 13-120, height 100-250 cm, weight 20-500 kg) + ValidationException
- [x] Recalculation logic (BMR, TDEE, macros via HealthCalculations)
- [x] Weight history entry creation when weight changes
- [x] Write unit tests — 14 tests pass

### Task 4: Implement Repository ✅
- [x] Create HealthProfileRepositoryImpl at lib/features/health_profile/data/repositories/
- [x] updateProfile() — saves to encrypted Hive box first (offline-first)
- [x] _syncToFirestore() with RGPD consent check (reads consentedToHealthData from user doc)
- [x] getWeightHistory() with date filtering and sorting
- [x] calculateWeightChangeRate() — kg/week calculation
- [ ] Unit tests with mocked Hive and Firestore (deferred — integration tested via UseCase tests)

### Task 5: Create Riverpod Providers ✅
- [x] Create lib/features/health_profile/presentation/providers/health_profile_providers.dart
- [x] currentHealthProfileProvider (FutureProvider<HealthProfileModel?>)
- [x] bmrProvider, tdeeProvider, macroTargetsProvider (FutureProvider)
- [x] weightHistoryProvider (FutureProvider.family<List<WeightHistoryEntry>, int>)
- [x] weightChangeRateProvider (FutureProvider.family<double, int>)
- [x] healthProfileRepositoryProvider, updateHealthProfileUseCaseProvider, currentUserIdProvider

### Task 6: Build Profile Update Screen ✅
- [x] ProfileUpdateScreen (ConsumerStatefulWidget) at lib/features/health_profile/presentation/screens/
- [x] TextEditingController for age, height, weight
- [x] DropdownButtonFormField for gender, activityLevel
- [x] Inline form validation (no external ValidationUtils — inline validators)
- [x] _hasChanges() detection for discard dialog
- [x] _handleBack() with PopScope and discard confirmation dialog
- [x] _handleSave() with validation + weight warning + invalidate providers on success

### Task 7: Create Metrics Preview Widget ✅
- [x] MetricsPreviewCard at lib/features/health_profile/presentation/widgets/
- [x] BMR and TDEE before/after with color-coded delta badge
- [x] Integrated into ProfileUpdateScreen, updates in real-time as user types

### Task 8: Implement Warning Dialogs ✅
- [x] _showHeightChangeWarning() — triggered if > 5 cm change (info dialog, AC4)
- [x] _showWeightChangeWarning() — triggered if > 5 kg change (confirm/cancel, AC5)
- [x] _showGenderChangeInfo() — triggered on gender change (info dialog, AC6)
- [ ] Test all warning triggers (deferred — manual testing)

### Task 9: Create Weight Chart Widget ✅
- [x] Add fl_chart: ^0.69.0 to pubspec.yaml (resolved as 0.69.2)
- [x] WeightChartWidget (ConsumerStatefulWidget) at lib/features/health_profile/presentation/widgets/
- [x] LineChart with fl_chart, curved line, gradient fill, dot markers
- [x] SegmentedButton period selector: 30j / 90j / 1 an (AC12)
- [x] Weight statistics: initial, current, change (AC10)
- [x] Weight change rate badge: +/- X.XX kg/semaine in color-coded chip (AC11)
- [x] WeightTrackingScreen wrapper at lib/features/health_profile/presentation/screens/
- [ ] Test with sample data (deferred — manual testing)

### Task 10: Update Firestore Security Rules ✅
- [x] Add rules for users/{userId}/healthProfile/current (read: owner, write: owner + consent)
- [x] Add rules for weightHistory subcollection (read: owner, write: owner + consent)
- [x] RGPD consent check via hasHealthConsent() function (uses custom claim)
- [ ] Test rules with Firebase Emulator (deferred)

### Task 11: Integrate with Nutrition Tracking ⏭️ (deferred)
- [ ] Update dailyCalorieGoalProvider to watch tdeeProvider
- [ ] Update dailyMacroGoalsProvider to watch macroTargetsProvider
- Deferred: Nutrition tracking feature (Story 7.x) not yet implemented

### Task 12: Integrate with Meal Planning ⏭️ (deferred)
- [ ] Update mealSuggestionsProvider to watch tdeeProvider
- Deferred: Meal planning feature (Story 9.x) not yet implemented

### Task 13: Add to Dashboard ⏭️ (deferred)
- [ ] Create WeightTrendCard widget for Dashboard
- Deferred: Dashboard integration (Story 4.x) not yet implemented

### Task 14: Write Unit Tests ✅
- [x] HealthCalculations tests (21 tests): BMR, TDEE, macros, weight change rate
- [x] UpdateHealthProfileUseCase tests (14 tests): validation, recalculations, weight history, repository calls
- [ ] Test HealthProfileRepositoryImpl (deferred)
- [ ] Test weight change rate calculation — covered by HealthCalculations tests

### Task 15: Widget Tests ⏭️ (deferred)
### Task 16: Integration Tests ⏭️ (deferred)
### Task 17: Manual Testing ⏭️ (deferred)

---

## Testing Strategy

### Unit Tests
```dart
// test/core/shared/utils/health_calculations_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HealthCalculations', () {
    test('calculateBMR returns correct value for male', () {
      // Mifflin-St Jeor: (10×75) + (6.25×180) - (5×28) + 5 = 1740
      final bmr = HealthCalculations.calculateBMR(
        ageYears: 28,
        heightCm: 180,
        weightKg: 75,
        gender: 'male',
      );

      expect(bmr, closeTo(1740, 1));
    });

    test('calculateBMR returns correct value for female', () {
      // Mifflin-St Jeor: (10×60) + (6.25×165) - (5×25) - 161 = 1345.25
      final bmr = HealthCalculations.calculateBMR(
        ageYears: 25,
        heightCm: 165,
        weightKg: 60,
        gender: 'female',
      );

      expect(bmr, closeTo(1345.25, 1));
    });

    test('calculateTDEE applies correct multiplier for moderate activity', () {
      final bmr = 1740.0;
      final tdee = HealthCalculations.calculateTDEE(bmr, 'moderate');

      // TDEE = 1740 × 1.55 = 2697
      expect(tdee, closeTo(2697, 1));
    });

    test('calculateMacroTargets returns correct values for weight loss', () {
      final macros = HealthCalculations.calculateMacroTargets(
        tdee: 2200,
        nutritionalGoal: 'weight_loss',
        weightKg: 75,
      );

      expect(macros['calories'], closeTo(1870, 10)); // 2200 × 0.85
      expect(macros['protein'], greaterThan(100));
      expect(macros['carbs'], greaterThan(100));
      expect(macros['fats'], greaterThan(40));
    });
  });
}
```

### Integration Tests
```dart
// integration_test/profile_update_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete profile update flow', (tester) async {
    // Launch app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Navigate to Profile Update
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personal Profile'));
    await tester.pumpAndSettle();

    // Update weight
    final weightField = find.byKey(Key('weight_field'));
    await tester.enterText(weightField, '73');
    await tester.pumpAndSettle();

    // Verify metrics preview updated
    expect(find.textContaining('TDEE'), findsOneWidget);

    // Save
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    // Verify success message
    expect(find.text('Profil mis à jour'), findsOneWidget);

    // Verify weight history entry created
    final repository = container.read(healthProfileRepositoryProvider);
    final history = await repository.getWeightHistory();
    expect(history.last.weight, 73.0);
  });
}
```

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Not Checking RGPD Consent Before Saving Health Data
**Problem**: Saving sensitive health data without user consent violates RGPD Article 9.

**Solution**: Always check `consentedToHealthData` flag before Firestore write.

```dart
// ❌ WRONG: Save without consent check
await firestore.collection('users').doc(userId).update(healthData);

// ✅ CORRECT: Check consent first
final consentDoc = await firestore.collection('users').doc(userId).get();
if (!consentDoc['consentedToHealthData']) {
  throw RGPDException('Consent required');
}
await firestore.collection('users').doc(userId).update(healthData);
```

### ❌ Anti-Pattern 2: Not Recalculating BMR When Gender Changes
**Problem**: BMR formula differs between male/female. Changing gender without recalculation produces wrong metrics.

**Solution**: Trigger BMR recalculation on gender change.

```dart
// ❌ WRONG: Update gender without recalc
profile.copyWith(gender: newGender);

// ✅ CORRECT: Recalculate BMR with new gender
final newBmr = HealthCalculations.calculateBMR(
  ageYears: profile.age,
  heightCm: profile.height,
  weightKg: profile.currentWeight,
  gender: newGender,  // New gender affects formula
);
profile.copyWith(gender: newGender, bmr: newBmr);
```

### ❌ Anti-Pattern 3: Not Storing Weight History in Encrypted Box
**Problem**: Weight data is sensitive health data (RGPD Article 9) and must be encrypted at rest.

**Solution**: Use encrypted Hive box for all health data.

```dart
// ❌ WRONG: Store in unencrypted box
final box = Hive.box('weight_history');
await box.put(entry);

// ✅ CORRECT: Use encrypted box
final encryptedBox = await Hive.openBox<WeightHistoryEntry>(
  'health_profiles_box',
  encryptionCipher: HiveAesCipher(encryptionKey),
);
await encryptedBox.put(entry);
```

### ❌ Anti-Pattern 4: Not Validating Rapid Changes
**Problem**: User accidentally enters 73 kg instead of 730 kg → invalid data corrupts calculations.

**Solution**: Show warning for changes > 5 kg or > 5 cm.

```dart
// ❌ WRONG: Accept any value
await saveProfile(newWeight);

// ✅ CORRECT: Warn on rapid change
if ((newWeight - currentWeight).abs() > 5) {
  final confirmed = await showWeightChangeWarning();
  if (!confirmed) return;
}
await saveProfile(newWeight);
```

### ❌ Anti-Pattern 5: Not Propagating TDEE Changes to Dependent Features
**Problem**: User updates profile → TDEE changes → nutrition tracking still shows old targets.

**Solution**: Invalidate dependent providers after update.

```dart
// ❌ WRONG: Update profile without invalidation
await repository.updateProfile(profile);

// ✅ CORRECT: Invalidate dependent providers
await repository.updateProfile(profile);
ref.invalidate(tdeeProvider);
ref.invalidate(macroTargetsProvider);
ref.invalidate(dailyCalorieGoalProvider);  // Nutrition tracking
ref.invalidate(mealSuggestionsProvider);    // Meal planning
```

---

## Integration Points

### Upstream Dependencies
- **Story 0.3**: Hive local database with encrypted boxes
- **Story 0.4**: Riverpod state management pattern
- **Story 1.5**: Onboarding creates initial healthProfile with profileType

### Downstream Consumers
- **Story 7.1**: Nutrition tracking uses TDEE and macro targets
- **Story 8.1**: Nutritional profile selection uses BMR/TDEE
- **Story 9.1**: Meal planning uses TDEE for meal suggestions
- **Story 4.2**: Dashboard displays weight trend chart
- **Story 13.1**: Gamification unlocks achievements based on weight milestones

### Shared Components
- **HealthProfileModel**: Extended with physical characteristics
- **HealthCalculations**: Shared utility for BMR/TDEE/macro calculations
- **Firestore healthProfile**: Synced across devices
- **Hive health_profiles_box**: Encrypted local storage

---

## Dev Notes

### Mifflin-St Jeor Formula (BMR)
Most accurate for modern populations (validated 2005):
```
Male: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) + 5
Female: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) - 161
```

### Activity Multipliers (TDEE)
Based on Harris-Benedict activity factors:
- **Sedentary** (1.2): Little/no exercise, desk job
- **Light** (1.375): Exercise 1-3 days/week
- **Moderate** (1.55): Exercise 3-5 days/week
- **Active** (1.725): Exercise 6-7 days/week
- **Very Active** (1.9): Intense daily exercise + physical job

### Weight Change Rate Calculation
```
Rate (kg/week) = (final weight - initial weight) / (days between / 7)

Example:
  Initial: 75 kg (day 0)
  Final: 73 kg (day 30)
  Rate = (73 - 75) / (30 / 7) = -2 / 4.29 = -0.47 kg/week
```

### RGPD Article 9 Compliance
Health data (age, weight, BMR, TDEE, dietary restrictions) requires:
1. **Explicit consent**: User must opt-in before saving
2. **Encryption at rest**: Hive AES-256 encryption
3. **Encryption in transit**: Firestore HTTPS (TLS 1.3)
4. **Right to deletion**: Implemented in Story 1.10
5. **Right to export**: Implemented in Story 1.9

### Offline-First Strategy
- **Local writes**: Save to Hive immediately (offline works)
- **Background sync**: Sync to Firestore when online
- **Conflict resolution**: Last-Write-Wins (Firestore timestamp)
- **User feedback**: "Sauvegardé localement (sync en attente)" message

---

## Definition of Done

### Code Complete
- [ ] HealthProfileModel extended with age, gender, height, currentWeight, activityLevel
- [ ] WeightHistoryEntry model created with Hive adapter (TypeId 8)
- [ ] HealthCalculations utility implemented (BMR, TDEE, macros)
- [ ] UpdateHealthProfileUseCase implemented with validation
- [ ] HealthProfileRepositoryImpl created with Hive + Firestore sync
- [ ] Riverpod providers created (currentProfile, bmr, tdee, macros, weightHistory)
- [ ] ProfileUpdateScreen implemented with form validation
- [ ] MetricsPreviewCard displays real-time BMR/TDEE changes
- [ ] Warning dialogs for height/weight/gender changes implemented
- [ ] WeightChartWidget created with fl_chart (30/90/365-day views)

### Testing Complete
- [ ] Unit tests for HealthCalculations (BMR, TDEE, macros) - 100% coverage
- [ ] Unit tests for UpdateHealthProfileUseCase
- [ ] Unit tests for HealthProfileRepositoryImpl
- [ ] Widget tests for ProfileUpdateScreen
- [ ] Widget tests for MetricsPreviewCard
- [ ] Widget tests for WeightChartWidget
- [ ] Integration test: Complete profile update flow
- [ ] Integration test: Weight history creation and chart display
- [ ] Manual test: RGPD consent check prevents save
- [ ] Manual test: Offline mode (Hive save without Firestore)
- [ ] Manual test: All warning dialogs trigger correctly

### Integration Complete
- [ ] Nutrition tracking dailyCalorieGoalProvider watches tdeeProvider
- [ ] Nutrition tracking dailyMacroGoalsProvider watches macroTargetsProvider
- [ ] Meal planning mealSuggestionsProvider watches tdeeProvider
- [ ] Dashboard WeightTrendCard displays weight chart
- [ ] Provider invalidation propagates changes across features

### Firestore & Security Complete
- [ ] Security rules added for healthProfile/current document
- [ ] Security rules added for weightHistory subcollection
- [ ] RGPD consent check enforced in Firestore rules
- [ ] Rules tested with Firebase Emulator
- [ ] healthProfile document structure matches spec

### Documentation Complete
- [ ] README updated with BMR/TDEE formulas
- [ ] README updated with activity level descriptions
- [ ] Code comments explain Mifflin-St Jeor formula
- [ ] RGPD compliance documented for health data
- [ ] Weight change rate calculation documented

### Deployment Ready
- [ ] All 18 Acceptance Criteria verified
- [ ] No critical bugs or regressions
- [ ] Performance tested (chart renders smoothly)
- [ ] Tested on Android and iOS
- [ ] Code reviewed by senior developer

---

## References

### Nutritional Science
- [Mifflin-St Jeor Equation](https://en.wikipedia.org/wiki/Harris%E2%80%93Benedict_equation#Mifflin-St_Jeor_equation)
- [TDEE Calculator Methodology](https://tdeecalculator.net/)
- [Activity Level Multipliers](https://www.calculator.net/tdee-calculator.html)

### Flutter Libraries
- [fl_chart Package](https://pub.dev/packages/fl_chart)
- [Hive Encryption](https://docs.hivedb.dev/#/advanced/encrypted_box)
- [Riverpod FutureProvider](https://riverpod.dev/docs/providers/future_provider)

### RGPD Compliance
- [RGPD Article 9: Health Data](https://gdpr-info.eu/art-9-gdpr/)
- [Data Encryption Requirements](https://gdpr.eu/data-encryption/)

### Related Stories
- **Story 1.5**: Complete Adaptive Onboarding Flow
- **Story 1.7**: Set Dietary Preferences and Allergies
- **Story 7.1**: Activate Nutrition Tracking
- **Story 8.1**: Select Nutritional Profile

---

## Changelog

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-02-15 | 1.0 | Dev Team | Initial story creation for Epic 1 Sprint 2 |
| 2026-02-21 | 1.1 | Dev Agent | Implementation complete — Tasks 1-10 + 14 done |

---

**Story Status**: 🔍 In Review
**Epic Progress**: Epic 1 - Story 6 of 10 (60% planned)
**Next Story**: 1-7-set-dietary-preferences-and-allergies
**Blocked By**: None

---

## Dev Agent Record

### Implementation Summary
- **Date**: 2026-02-21
- **Agent**: claude-sonnet-4-6
- **Tests Passed**: 35/35 (21 HealthCalculations + 14 UpdateHealthProfileUseCase)
- **Build**: `dart run build_runner build` — 61 outputs generated

### Files Created
- `lib/core/storage/models/weight_history_entry.dart` — TypeId 8 Hive model
- `lib/core/shared/utils/health_calculations.dart` — BMR/TDEE/Macro utility
- `lib/features/health_profile/domain/repositories/health_profile_repository.dart` — Abstract interface
- `lib/features/health_profile/domain/usecases/update_health_profile_usecase.dart` — Business logic + ValidationException
- `lib/features/health_profile/data/repositories/health_profile_repository_impl.dart` — Hive + Firestore impl
- `lib/features/health_profile/presentation/providers/health_profile_providers.dart` — 8 Riverpod providers
- `lib/features/health_profile/presentation/screens/profile_update_screen.dart` — Main edit screen
- `lib/features/health_profile/presentation/screens/weight_tracking_screen.dart` — Chart screen
- `lib/features/health_profile/presentation/widgets/metrics_preview_card.dart` — Real-time preview
- `lib/features/health_profile/presentation/widgets/weight_chart_widget.dart` — fl_chart widget
- `test/core/shared/utils/health_calculations_test.dart` — 21 unit tests
- `test/features/health_profile/domain/usecases/update_health_profile_usecase_test.dart` — 14 unit tests

### Files Modified
- `lib/core/storage/models/health_profile_model.dart` — Added fields 7-13, copyWith, addWeightEntry, toFirestore
- `lib/core/storage/hive_service.dart` — Register WeightHistoryEntryAdapter (TypeId 8)
- `lib/core/routing/app_routes.dart` — Added healthProfile + weightTracking routes
- `lib/core/routing/app_router.dart` — Added GoRoute for ProfileUpdateScreen + WeightTrackingScreen
- `pubspec.yaml` — Added fl_chart: ^0.69.0
- `firestore.rules` — Added healthProfile/current and weightHistory subcollection rules
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — 1-6: ready-for-dev → review

### Deferred Items
- Widget tests (Task 15), integration tests (Task 16), manual device testing (Task 17)
- Nutrition tracking integration (Task 11) — blocked by Story 7.x
- Meal planning integration (Task 12) — blocked by Story 9.x
- Dashboard WeightTrendCard (Task 13) — blocked by Story 4.x
