# Story 1.5: Complete Adaptive Onboarding Flow

## Metadata
```yaml
story_id: 1-5-complete-adaptive-onboarding-flow
epic_id: epic-1
epic_name: User Authentication & Profile Management
story_name: Complete Adaptive Onboarding Flow
story_points: 8
priority: high
status: in-progress
created_date: 2026-02-15
updated_date: 2026-02-21
assigned_to: dev-team
sprint: epic-1-sprint-2
dependencies:
  - 0-4-implement-riverpod-state-management-foundation
  - 0-5-configure-gorouter-for-navigation-and-deep-linking
  - 1-1-create-account-with-email-and-password
  - 1-2-login-with-email-and-password
  - 1-3-login-with-oauth-google-sign-in
  - 1-4-login-with-oauth-apple-sign-in
tags:
  - onboarding
  - ux
  - adaptive-flow
  - profile-setup
  - riverpod
  - gorouter
  - firestore
```

## User Story

**As a** new user who just created an account
**I want to** complete a guided onboarding flow tailored to my goals
**So that I** can set up my profile efficiently and start using features that matter most to me

### Business Value
- **User Activation**: Converts authenticated users into active users with configured profiles
- **Personalization**: Adapts flow based on user goals, reducing friction and increasing completion rate
- **Time to Value**: Gets users to their first "aha moment" faster by skipping irrelevant steps
- **Data Quality**: Collects high-quality profile data needed for nutrition tracking, meal planning, and waste reduction features
- **Retention**: Well-onboarded users are 50% more likely to remain active after 30 days

### User Personas
- **Primary**: Waste-reduction focused users who want minimal setup (skip nutrition steps)
- **Secondary**: Nutrition-conscious users who need full profile configuration (age, weight, dietary goals)
- **Tertiary**: Meal-planning enthusiasts who want both waste reduction and nutrition features

---

## Acceptance Criteria

### AC1: Onboarding Triggered for New Users
**Given** I just created an account via email/password, Google, or Apple sign-in
**When** my Firestore user document has `profileType` field empty or null
**Then** I am automatically redirected to `/onboarding` route
**And** I cannot access other app routes until onboarding is complete

### AC2: Welcome Screen Displays Value Proposition
**Given** I am on Step 1 (Welcome Screen)
**When** the screen loads
**Then** I see the app logo and brand illustration
**And** I see headline "Welcome to FrigoFute"
**And** I see 3-4 key benefits with icons (save money, help environment, track nutrition, meal suggestions)
**And** I see a primary "Get Started" button
**And** tapping "Get Started" advances to Step 2

### AC3: Profile Type Selection (Adaptive Decision Point)
**Given** I am on Step 2 (Profile Type Selection)
**When** the screen loads
**Then** I see 4 profile type cards:
  - "Reduce Waste" (eco icon)
  - "Track Nutrition" (nutrition icon)
  - "Meal Planning" (calendar icon)
  - "All Features" (star icon)
**And** each card shows a title, description, and icon
**And** I can select exactly one card (single selection)
**And** the "Next" button is disabled until I select a profile type
**And** tapping "Next" saves my selection and advances to the next step

### AC4: Adaptive Flow - Waste Reduction Only Path
**Given** I selected "Reduce Waste" as my profile type
**When** I tap "Next" on Step 2
**Then** the flow skips Steps 3, 4, and 5 (nutrition-related)
**And** I am taken directly to Step 6 (Success Screen)
**And** my `profileType` is set to `'waste'` in Firestore
**And** no health profile data is collected

### AC5: Adaptive Flow - Nutrition/Meal Planning/All Features Path
**Given** I selected "Track Nutrition", "Meal Planning", or "All Features"
**When** I tap "Next" on Step 2
**Then** I am taken to Step 3 (Physical Characteristics)
**And** the progress indicator shows 6 total steps
**And** subsequent steps 4 and 5 are also shown

### AC6: Physical Characteristics Form (Step 3 - Conditional)
**Given** I am on Step 3 (Physical Characteristics)
**When** the screen loads
**Then** I see form fields for:
  - Age (number input, 13-120 years)
  - Gender (radio buttons: Male, Female, Other, Prefer not to say)
  - Height (number input, 100-250 cm)
  - Weight (number input, 20-500 kg)
  - Activity Level (dropdown: Sedentary, Light, Moderate, Active, Very Active)
**And** all fields are required
**And** the "Next" button is disabled until all fields are valid
**And** I see real-time validation errors below each field on blur
**And** I optionally see estimated TDEE and BMR calculated in real-time

### AC7: Dietary Preferences Form (Step 4 - Conditional)
**Given** I am on Step 4 (Dietary Preferences)
**When** the screen loads
**Then** I see multi-select chips for dietary restrictions:
  - Vegetarian, Vegan, Gluten-Free, Dairy-Free, Nut-Free, Halal, Kosher, Low FODMAP
**And** I can select 0 or more restrictions
**And** I see a text field for entering allergies (comma-separated)
**And** allergies are optional
**And** the "Next" button is always enabled (no required selections)

### AC8: Nutritional Goals Selection (Step 5 - Conditional)
**Given** I am on Step 5 (Nutritional Goals)
**When** the screen loads
**Then** I see 12 pre-defined nutrition goal cards:
  - Weight Loss, Maintenance, Muscle Gain, Athletic Performance, etc.
**And** each card shows goal name, description, calorie adjustment, and icon
**And** I can select exactly one goal
**And** the "Next" button is disabled until I select a goal
**And** macro targets (protein, carbs, fats) are auto-calculated based on my selection

### AC9: Success Screen (Step 6 - Always Shown)
**Given** I completed all required steps
**When** I reach Step 6 (Success Screen)
**Then** I see a checkmark animation or celebration illustration
**And** I see headline "You're All Set!"
**And** I see a summary of my selected preferences (profile type, age, dietary restrictions, goal)
**And** I see a primary button "Start Using FrigoFute"
**And** I see a secondary button "Review Settings"
**And** tapping "Start Using FrigoFute" saves my data to Firestore and redirects to `/home`
**And** tapping "Review Settings" navigates back to Step 2

### AC10: Progress Indicator Updates Dynamically
**Given** I am on any onboarding step
**When** I advance to the next step
**Then** the linear progress bar at the top updates (0-100%)
**And** I see text "Step X of Y" where Y varies based on my profile type:
  - "Waste" profile: 3 steps total
  - Other profiles: 6 steps total
**And** dot indicators show current step (active color), completed steps (green), and upcoming steps (grey)

### AC11: Back Navigation Between Steps
**Given** I am on Step 2 or later
**When** I tap the Back button or back arrow
**Then** I navigate to the previous step in the flow
**And** my previously entered data is preserved
**And** the progress bar decrements accordingly

**Given** I am on Step 1 (Welcome Screen)
**When** I tap the back/close button
**Then** I see a confirmation dialog "Exit Onboarding?"
**And** I can choose to "Exit" (returns to login) or "Cancel" (stays on onboarding)

### AC12: Mid-Onboarding Exit and Resume
**Given** I am on Step 3 and I close the app (home button, kill app)
**When** I reopen the app within 24 hours
**Then** I see a dialog "Resume Onboarding?"
**And** I can choose "Resume" (continues from Step 3) or "Restart" (starts from Step 1)
**And** my previously entered data is restored if I choose "Resume"

**Given** I closed the app mid-onboarding and reopen after 24 hours
**Then** onboarding restarts from Step 1 (data cleared for UX simplicity)

### AC13: Profile Type Change Resets Subsequent Steps
**Given** I selected "Track Nutrition" and filled Step 3 (physical characteristics)
**When** I go back to Step 2 and change to "Reduce Waste"
**Then** I see a warning dialog "Change Profile Type? This will reset your nutrition information."
**And** I can choose "Cancel" (keeps current selection) or "Change" (resets data)
**And** if I choose "Change", Steps 3-5 data is cleared
**And** the flow recalculates to skip nutrition steps

### AC14: Data Saved to Firestore on Completion
**Given** I completed all steps and tapped "Start Using FrigoFute"
**When** the save operation executes
**Then** my Firestore user document is updated with:
  - `profileType`: 'waste' | 'nutrition' | 'meal_planning' | 'all'
  - `onboardingCompleted`: true
  - `onboardingCompletedAt`: server timestamp
  - `healthProfile`: { age, gender, height, weight, bmr, tdee, dietaryRestrictions, allergies, nutritionalGoal, macroTargets } (if nutrition profile)
**And** the save operation has retry logic (3 attempts with exponential backoff)
**And** errors are logged to Crashlytics

### AC15: Network Error Handling During Save
**Given** I completed onboarding and tapped "Start Using FrigoFute"
**When** a network error occurs during Firestore save
**Then** I see an error message "No internet connection. Please check and try again."
**And** I see a "Retry" button to attempt save again
**And** I see a "Review" button to go back and review my data
**And** I remain on the Success Screen until save succeeds

### AC16: GoRouter Auto-Redirect After Completion
**Given** I successfully saved my onboarding data
**When** the save completes
**Then** I am automatically redirected to `/home` route
**And** the `shouldCompleteOnboardingProvider` returns false (onboarding complete)
**And** I can now access all app routes normally

### AC17: Accessibility - Screen Reader Support
**Given** I am using a screen reader (TalkBack or VoiceOver)
**When** I navigate through onboarding steps
**Then** each step announces its semantic label (e.g., "Step 2 of 6: Select your profile type")
**And** form fields announce their labels and required status
**And** error messages are announced immediately when they appear
**And** buttons announce their enabled/disabled state

### AC18: Accessibility - Keyboard Navigation
**Given** I am using keyboard navigation
**When** I press Tab
**Then** focus moves to the next interactive element in logical order
**And** the first form field auto-focuses when a step loads
**And** pressing Enter on "Next" button advances to next step
**And** pressing Escape shows the exit confirmation dialog

---

## Technical Specifications

### Architecture
```
Presentation Layer (UI)
├── OnboardingScreen (StatefulWidget)
│   ├── PageController for step navigation
│   ├── OnboardingProgressIndicator
│   ├── OnboardingNavigationBar
│   └── Step Widgets:
│       ├── WelcomeStep
│       ├── ProfileTypeStep
│       ├── PhysicalCharacteristicsStep
│       ├── DietaryPreferencesStep
│       ├── NutritionalGoalsStep
│       └── SuccessStep
│
Domain Layer (Business Logic)
├── OnboardingState (Freezed model)
│   ├── currentPageIndex
│   ├── visibleSteps (adaptive)
│   ├── formData (accumulated data)
│   └── progressPercent
│
├── OnboardingNotifier (StateNotifier)
│   ├── goToNextPage()
│   ├── goToPreviousPage()
│   ├── setProfileType() (recalculates flow)
│   ├── updateFormField()
│   └── completeOnboarding() (Firestore save)
│
Data Layer
├── FirestoreUserDataSource
│   └── updateUserProfile() (saves onboarding data)
│
Infrastructure
├── GoRouter (auto-redirect based on profileType)
└── Riverpod Providers
```

### Dependencies
```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.6.1      # State management
  freezed_annotation: ^2.4.1    # Immutable models
  go_router: ^17.0.0            # Navigation
  cloud_firestore: ^4.15.0      # Persistence

dev_dependencies:
  freezed: ^2.4.1               # Code generation
  build_runner: ^2.4.6          # Code generation
```

### Data Models

#### OnboardingState (Freezed)
```dart
// lib/features/onboarding/domain/models/onboarding_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

enum OnboardingStep {
  welcome,
  profileType,
  physicalCharacteristics,
  dietaryPreferences,
  nutritionalGoals,
  success,
}

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentPageIndex,
    @Default([
      OnboardingStep.welcome,
      OnboardingStep.profileType,
    ]) List<OnboardingStep> visibleSteps,
    @Default({}) Map<String, dynamic> formData,
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
  }) = _OnboardingState;

  const OnboardingState._();

  // Calculate progress percentage
  double get progressPercent {
    if (visibleSteps.isEmpty) return 0;
    return ((currentPageIndex + 1) / visibleSteps.length) * 100;
  }

  // Get total pages based on adaptive flow
  int get totalPages => visibleSteps.length;

  // Get current step enum
  OnboardingStep get currentStep => visibleSteps[currentPageIndex];

  // Check if step is skippable (not used in current spec, all conditional steps are mandatory)
  bool get canSkipCurrentStep => false;

  // Check if can go back
  bool get canGoBack => currentPageIndex > 0;

  // Check if can go forward
  bool get canGoForward => currentPageIndex < visibleSteps.length - 1;
}
```

#### ProfileType Enum
```dart
// lib/features/onboarding/domain/models/profile_type.dart
enum ProfileType {
  waste('waste', 'Reduce Waste', 'Focus on reducing food waste at home'),
  nutrition('nutrition', 'Track Nutrition', 'Monitor your dietary intake and health'),
  mealPlanning('meal_planning', 'Meal Planning', 'Plan meals and optimize grocery shopping'),
  all('all', 'All Features', 'Access all features for maximum impact');

  const ProfileType(this.id, this.title, this.description);

  final String id;
  final String title;
  final String description;

  // Get icon based on type
  IconData get icon {
    switch (this) {
      case ProfileType.waste:
        return Icons.eco;
      case ProfileType.nutrition:
        return Icons.restaurant;
      case ProfileType.mealPlanning:
        return Icons.calendar_today;
      case ProfileType.all:
        return Icons.star;
    }
  }

  // Check if nutrition steps should be shown
  bool get requiresNutritionSteps => this != ProfileType.waste;
}
```

#### NutritionalGoal Model
```dart
// lib/features/onboarding/domain/models/nutritional_goal.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutritional_goal.freezed.dart';
part 'nutritional_goal.g.dart';

@freezed
class NutritionalGoal with _$NutritionalGoal {
  const factory NutritionalGoal({
    required String id,
    required String title,
    required String description,
    required int calorieAdjustment,  // Daily calorie deficit/surplus
    required String iconName,
    @Default(1.8) double proteinPerKg,   // g/kg body weight
    @Default(3.0) double carbsPerKg,
    @Default(0.8) double fatsPerKg,
  }) = _NutritionalGoal;

  factory NutritionalGoal.fromJson(Map<String, dynamic> json) =>
      _$NutritionalGoalFromJson(json);
}

// Pre-defined 12 goals
class NutritionalGoals {
  static const goals = [
    NutritionalGoal(
      id: 'weight_loss',
      title: 'Weight Loss',
      description: 'Lose 1-2 lbs per week safely',
      calorieAdjustment: -500,
      iconName: 'trending_down',
      proteinPerKg: 2.0,  // Higher protein to preserve muscle
      carbsPerKg: 2.5,
      fatsPerKg: 0.8,
    ),
    NutritionalGoal(
      id: 'maintenance',
      title: 'Maintain Weight',
      description: 'Stay at current weight',
      calorieAdjustment: 0,
      iconName: 'balance',
    ),
    NutritionalGoal(
      id: 'muscle_gain',
      title: 'Muscle Gain',
      description: 'Build muscle with protein focus',
      calorieAdjustment: 300,
      iconName: 'fitness_center',
      proteinPerKg: 2.2,  // High protein for muscle synthesis
      carbsPerKg: 4.0,    // High carbs for energy
      fatsPerKg: 1.0,
    ),
    NutritionalGoal(
      id: 'athletic_performance',
      title: 'Athletic Performance',
      description: 'Optimize for sports and training',
      calorieAdjustment: 200,
      iconName: 'sports',
      proteinPerKg: 1.8,
      carbsPerKg: 5.0,    // Very high carbs for glycogen
      fatsPerKg: 0.9,
    ),
    NutritionalGoal(
      id: 'endurance',
      title: 'Endurance Training',
      description: 'Fuel for long-distance activities',
      calorieAdjustment: 300,
      iconName: 'directions_run',
      proteinPerKg: 1.6,
      carbsPerKg: 6.0,    // Highest carbs
      fatsPerKg: 0.8,
    ),
    NutritionalGoal(
      id: 'general_health',
      title: 'General Health',
      description: 'Balanced nutrition for wellness',
      calorieAdjustment: 0,
      iconName: 'favorite',
      proteinPerKg: 1.6,
      carbsPerKg: 3.5,
      fatsPerKg: 1.0,
    ),
    // ... 6 more goals (Heart Health, Diabetic, Low Carb, Keto, Vegan, High Protein)
  ];
}
```

### State Management - OnboardingNotifier

```dart
// lib/features/onboarding/presentation/providers/onboarding_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/onboarding_state.dart';
import '../../domain/models/profile_type.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final FirebaseFirestore _firestore;
  final String _userId;

  OnboardingNotifier(this._firestore, this._userId)
      : super(const OnboardingState());

  /// Navigate to next page
  void goToNextPage() {
    if (state.canGoForward) {
      state = state.copyWith(
        currentPageIndex: state.currentPageIndex + 1,
      );
    }
  }

  /// Navigate to previous page
  void goToPreviousPage() {
    if (state.canGoBack) {
      state = state.copyWith(
        currentPageIndex: state.currentPageIndex - 1,
      );
    }
  }

  /// Jump to specific page (used for adaptive flow)
  void jumpToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < state.totalPages) {
      state = state.copyWith(currentPageIndex: pageIndex);
    }
  }

  /// Update form field
  void updateFormField(String key, dynamic value) {
    final updatedData = {...state.formData, key: value};
    state = state.copyWith(formData: updatedData);
  }

  /// Set profile type and recalculate visible steps (adaptive flow)
  void setProfileType(String profileTypeId) {
    // Update form data
    final updatedData = {...state.formData, 'profileType': profileTypeId};

    // Determine if nutrition steps should be shown
    final requiresNutrition = profileTypeId != 'waste';

    // Build visible steps list
    final visibleSteps = [
      OnboardingStep.welcome,
      OnboardingStep.profileType,
      if (requiresNutrition) ...[
        OnboardingStep.physicalCharacteristics,
        OnboardingStep.dietaryPreferences,
        OnboardingStep.nutritionalGoals,
      ],
      OnboardingStep.success,
    ];

    // If switching to 'waste', clear nutrition-related data
    if (!requiresNutrition) {
      updatedData.remove('physicalCharacteristics');
      updatedData.remove('dietaryPreferences');
      updatedData.remove('nutritionalGoals');
    }

    state = state.copyWith(
      formData: updatedData,
      visibleSteps: visibleSteps,
    );
  }

  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor formula
  double _calculateBMR({
    required int age,
    required String gender,
    required int height,
    required double weight,
  }) {
    // BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) + s
    // s = +5 for males, -161 for females
    final s = gender.toLowerCase() == 'male' ? 5 : -161;
    return (10 * weight) + (6.25 * height) - (5 * age) + s;
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  double _calculateTDEE(double bmr, String activityLevel) {
    const activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return bmr * (activityMultipliers[activityLevel.toLowerCase()] ?? 1.55);
  }

  /// Calculate macro targets based on goal and physical characteristics
  Map<String, double> _calculateMacroTargets({
    required double adjustedCalories,
    required double weight,
    required String goalId,
  }) {
    // Get goal from predefined list
    final goal = NutritionalGoals.goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => NutritionalGoals.goals[1], // Default to maintenance
    );

    // Calculate grams based on body weight
    final proteinGrams = goal.proteinPerKg * weight;
    final carbsGrams = goal.carbsPerKg * weight;
    final fatsGrams = goal.fatsPerKg * weight;

    // Calculate calories from macros (4 cal/g protein, 4 cal/g carbs, 9 cal/g fat)
    final proteinCals = proteinGrams * 4;
    final carbsCals = carbsGrams * 4;
    final fatsCals = fatsGrams * 9;
    final totalFromMacros = proteinCals + carbsCals + fatsCals;

    // Adjust to match target calories (scale macros proportionally)
    final scaleFactor = adjustedCalories / totalFromMacros;

    return {
      'calories': adjustedCalories,
      'protein': proteinGrams * scaleFactor,
      'carbs': carbsGrams * scaleFactor,
      'fats': fatsGrams * scaleFactor,
    };
  }

  /// Complete onboarding and save to Firestore
  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      // Prepare data based on profile type
      final profileType = state.formData['profileType'];
      final Map<String, dynamic> updateData = {
        'profileType': profileType,
        'onboardingCompleted': true,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
      };

      // Add health profile if nutrition steps were shown
      if (profileType != 'waste') {
        final physicalChar = state.formData['physicalCharacteristics'] ?? {};
        final dietaryPref = state.formData['dietaryPreferences'] ?? {};
        final nutritionalGoals = state.formData['nutritionalGoals'] ?? {};

        // Calculate BMR and TDEE
        final age = physicalChar['age'] as int;
        final gender = physicalChar['gender'] as String;
        final height = physicalChar['height'] as int;
        final weight = (physicalChar['weight'] as num).toDouble();
        final activityLevel = physicalChar['activityLevel'] as String;

        final bmr = _calculateBMR(
          age: age,
          gender: gender,
          height: height,
          weight: weight,
        );
        final tdee = _calculateTDEE(bmr, activityLevel);

        // Get calorie adjustment from selected goal
        final goalId = nutritionalGoals['selectedGoal'] as String;
        final goal = NutritionalGoals.goals.firstWhere(
          (g) => g.id == goalId,
          orElse: () => NutritionalGoals.goals[1],
        );
        final adjustedCalories = tdee + goal.calorieAdjustment;

        // Calculate macro targets
        final macroTargets = _calculateMacroTargets(
          adjustedCalories: adjustedCalories,
          weight: weight,
          goalId: goalId,
        );

        updateData['healthProfile'] = {
          'age': age,
          'gender': gender,
          'height': height,
          'weight': weight,
          'activityLevel': activityLevel,
          'bmr': bmr.round(),
          'tdee': tdee.round(),
          'dietaryRestrictions': dietaryPref['restrictions'] ?? [],
          'allergies': dietaryPref['allergies'] ?? [],
          'nutritionalGoal': goalId,
          'macroTargets': {
            'calories': macroTargets['calories']!.round(),
            'protein': macroTargets['protein']!.round(),
            'carbs': macroTargets['carbs']!.round(),
            'fats': macroTargets['fats']!.round(),
          },
        };
      } else {
        updateData['healthProfile'] = null;
      }

      // Save to Firestore with retry logic
      await _saveWithRetry(updateData);

      // Update state to indicate completion
      state = state.copyWith(
        isLoading: false,
        currentPageIndex: state.totalPages - 1, // Move to success screen
      );
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error saving profile: ${e.message}',
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: $e',
      );
      rethrow;
    }
  }

  /// Save to Firestore with retry logic (3 attempts, exponential backoff)
  Future<void> _saveWithRetry(Map<String, dynamic> data) async {
    int attempt = 0;
    const maxAttempts = 3;
    const baseDelayMs = 1000;

    while (attempt < maxAttempts) {
      try {
        await _firestore
            .collection('users')
            .doc(_userId)
            .update(data)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Save timeout'),
            );
        return; // Success
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;

        // Exponential backoff: 1s, 2s, 4s
        await Future.delayed(Duration(milliseconds: baseDelayMs * (1 << attempt)));
      }
    }
  }

  /// Reset onboarding state (for restart)
  void reset() {
    state = const OnboardingState();
  }
}
```

### Riverpod Providers

```dart
// lib/features/onboarding/presentation/providers/onboarding_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/onboarding_state.dart';
import 'onboarding_notifier.dart';

// Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Current user ID provider (from auth state)
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.uid;
});

// Onboarding state notifier provider
final onboardingStateProvider = StateNotifierProvider<
    OnboardingNotifier,
    OnboardingState>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider) ?? '';
  return OnboardingNotifier(firestore, userId);
});

// Provider to check if user needs onboarding
final shouldCompleteOnboardingProvider = FutureProvider.family<bool, String>(
  (ref, userId) async {
    final firestore = ref.watch(firestoreProvider);
    final doc = await firestore.collection('users').doc(userId).get();
    final data = doc.data() ?? {};

    // Check if profileType is empty or null
    final profileType = data['profileType'];
    return profileType == null || profileType.toString().isEmpty;
  },
);
```

### UI Implementation - OnboardingScreen

```dart
// lib/features/onboarding/presentation/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/onboarding_progress_indicator.dart';
import '../widgets/onboarding_navigation_bar.dart';
import '../widgets/steps/welcome_step.dart';
import '../widgets/steps/profile_type_step.dart';
import '../widgets/steps/physical_characteristics_step.dart';
import '../widgets/steps/dietary_preferences_step.dart';
import '../widgets/steps/nutritional_goals_step.dart';
import '../widgets/steps/success_step.dart';
import '../providers/onboarding_providers.dart';
import '../../domain/models/onboarding_state.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: _buildBackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Progress indicator
          OnboardingProgressIndicator(
            currentPage: state.currentPageIndex,
            totalPages: state.totalPages,
            progressPercent: state.progressPercent,
          ),

          // PageView with adaptive steps
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              onPageChanged: (index) {
                // Sync PageView with state if user manually navigates
                ref.read(onboardingStateProvider.notifier).jumpToPage(index);
              },
              children: _buildPages(state),
            ),
          ),

          // Navigation bar (Next, Back, Skip buttons)
          OnboardingNavigationBar(
            onNext: () => _handleNext(),
            onBack: () => _handleBack(),
            onSkip: state.canSkipCurrentStep ? () => _handleSkip() : null,
            isNextEnabled: _isNextEnabled(state),
          ),
        ],
      ),
    );
  }

  /// Build back button with exit confirmation
  Widget _buildBackButton() {
    final state = ref.watch(onboardingStateProvider);

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (state.canGoBack) {
          _handleBack();
        } else {
          _showExitConfirmation();
        }
      },
      tooltip: state.canGoBack ? 'Go to previous step' : 'Exit onboarding',
    );
  }

  /// Build pages based on visible steps
  List<Widget> _buildPages(OnboardingState state) {
    return state.visibleSteps.map((step) {
      switch (step) {
        case OnboardingStep.welcome:
          return const WelcomeStep();
        case OnboardingStep.profileType:
          return const ProfileTypeStep();
        case OnboardingStep.physicalCharacteristics:
          return const PhysicalCharacteristicsStep();
        case OnboardingStep.dietaryPreferences:
          return const DietaryPreferencesStep();
        case OnboardingStep.nutritionalGoals:
          return const NutritionalGoalsStep();
        case OnboardingStep.success:
          return const SuccessStep();
      }
    }).toList();
  }

  /// Handle Next button tap
  void _handleNext() {
    final state = ref.read(onboardingStateProvider);

    // If on success screen, complete onboarding
    if (state.currentStep == OnboardingStep.success) {
      _completeOnboarding();
      return;
    }

    // Validate current step before advancing
    if (_validateCurrentStep(state)) {
      ref.read(onboardingStateProvider.notifier).goToNextPage();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Handle Back button tap
  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).goToPreviousPage();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Handle Skip button tap (not used in current spec)
  void _handleSkip() {
    // Skip to next mandatory step (implementation depends on requirements)
  }

  /// Check if Next button should be enabled
  bool _isNextEnabled(OnboardingState state) {
    switch (state.currentStep) {
      case OnboardingStep.welcome:
        return true; // Always enabled

      case OnboardingStep.profileType:
        return state.formData['profileType'] != null;

      case OnboardingStep.physicalCharacteristics:
        final data = state.formData['physicalCharacteristics'] ?? {};
        return data['age'] != null &&
            data['gender'] != null &&
            data['height'] != null &&
            data['weight'] != null &&
            data['activityLevel'] != null;

      case OnboardingStep.dietaryPreferences:
        return true; // Optional fields, always can proceed

      case OnboardingStep.nutritionalGoals:
        return state.formData['nutritionalGoals']?['selectedGoal'] != null;

      case OnboardingStep.success:
        return true;
    }
  }

  /// Validate current step before advancing
  bool _validateCurrentStep(OnboardingState state) {
    // Add specific validation logic per step if needed
    return _isNextEnabled(state);
  }

  /// Complete onboarding and navigate to home
  Future<void> _completeOnboarding() async {
    try {
      await ref.read(onboardingStateProvider.notifier).completeOnboarding();

      // Navigate to home after successful save
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Error is displayed in SuccessStep via state.errorMessage
      // User can retry from there
    }
  }

  /// Show exit confirmation dialog
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Onboarding?'),
        content: const Text(
          'You can resume where you left off later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login'); // Exit to login
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
```

### Step Widgets - Profile Type Step Example

```dart
// lib/features/onboarding/presentation/widgets/steps/profile_type_step.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/profile_type.dart';
import '../../providers/onboarding_providers.dart';

class ProfileTypeStep extends ConsumerWidget {
  const ProfileTypeStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    final selectedType = state.formData['profileType'] as String?;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'What brings you to FrigoFute?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Choose your primary goal to customize your experience',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Profile type cards
          Expanded(
            child: ListView(
              children: ProfileType.values.map((type) {
                final isSelected = selectedType == type.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProfileTypeCard(
                    type: type,
                    isSelected: isSelected,
                    onTap: () {
                      // Check if changing from existing selection
                      if (selectedType != null && selectedType != type.id) {
                        _showChangeConfirmation(context, ref, type);
                      } else {
                        _selectProfileType(ref, type.id);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Select profile type and recalculate flow
  void _selectProfileType(WidgetRef ref, String typeId) {
    ref.read(onboardingStateProvider.notifier).setProfileType(typeId);
  }

  /// Show confirmation when changing profile type
  void _showChangeConfirmation(
    BuildContext context,
    WidgetRef ref,
    ProfileType newType,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Type?'),
        content: Text(
          'Switching to "${newType.title}" will reset your nutrition information. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _selectProfileType(ref, newType.id);
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

/// Profile Type Card Widget
class ProfileTypeCard extends StatelessWidget {
  final ProfileType type;
  final bool isSelected;
  final VoidCallback onTap;

  const ProfileTypeCard({
    Key? key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type.icon,
                  size: 32,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // Selected indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### GoRouter Integration

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) async {
      final isAuthenticated = authState.value != null;
      final currentLocation = state.matchedLocation;

      // Not authenticated → redirect to login
      if (!isAuthenticated && currentLocation != '/login') {
        return '/login';
      }

      // Authenticated → check onboarding completion
      if (isAuthenticated) {
        final userId = authState.value!.uid;
        final needsOnboarding = await ref.read(
          shouldCompleteOnboardingProvider(userId).future,
        );

        // Needs onboarding → redirect to /onboarding
        if (needsOnboarding && currentLocation != '/onboarding') {
          return '/onboarding';
        }

        // Onboarding complete → prevent access to onboarding
        if (!needsOnboarding && currentLocation == '/onboarding') {
          return '/home';
        }

        // Authenticated and onboarded → redirect from login to home
        if (!needsOnboarding && currentLocation == '/login') {
          return '/home';
        }
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
```

### Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Allow read if authenticated and accessing own document
      allow read: if request.auth != null && request.auth.uid == userId;

      // Allow update for onboarding completion
      allow update: if request.auth != null
        && request.auth.uid == userId
        && (
          // Allow updating profile type and onboarding fields
          request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['profileType', 'onboardingCompleted', 'onboardingCompletedAt', 'healthProfile'])
        );
    }
  }
}
```

---

## Implementation Tasks

### Task 1: Create Freezed Models
- [x] Create `onboarding_state.dart` with Freezed
- [x] Create `profile_type.dart` enum
- [x] Create `nutritional_goal.dart` with 12 predefined goals
- [x] Run `flutter pub run build_runner build`
- [x] Verify generated .freezed.dart files

**Estimated Time**: 1.5 hours

### Task 2: Implement OnboardingNotifier
- [x] Create `onboarding_notifier.dart` with StateNotifier
- [x] Implement `goToNextPage()`, `goToPreviousPage()`, `jumpToPage()`
- [x] Implement `setProfileType()` with adaptive flow logic
- [x] Implement `updateFormField()` for form data updates
- [x] Implement BMR calculation (Mifflin-St Jeor formula)
- [x] Implement TDEE calculation with activity multipliers
- [x] Implement macro targets calculation
- [x] Implement `completeOnboarding()` with Firestore save + retry logic
- [x] Add error handling and logging

**Estimated Time**: 3 hours

### Task 3: Create Riverpod Providers
- [x] Create `onboarding_providers.dart`
- [x] Add `onboardingStateProvider`
- [x] Add `shouldCompleteOnboardingProvider` (FutureProvider)
- [x] Wire up dependencies (Firestore, auth)

**Estimated Time**: 30 minutes

### Task 4: Build OnboardingScreen Main Widget
- [x] Create `onboarding_screen.dart` with PageController
- [x] Implement PageView with NeverScrollableScrollPhysics
- [x] Add OnboardingProgressIndicator
- [x] Add OnboardingNavigationBar
- [x] Implement back button with exit confirmation
- [x] Wire up navigation handlers (`_handleNext`, `_handleBack`)

**Estimated Time**: 2 hours

### Task 5: Create Step Widgets
- [x] Create `welcome_step.dart` (Step 1)
- [x] Create `profile_type_step.dart` (Step 2) with 4 cards
- [x] Create `physical_characteristics_step.dart` (Step 3) with form validation
- [x] Create `dietary_preferences_step.dart` (Step 4) with multi-select chips
- [x] Create `nutritional_goals_step.dart` (Step 5) with 12 goal cards
- [x] Create `success_step.dart` (Step 6) with summary and completion

**Estimated Time**: 5 hours

### Task 6: Create Shared Widgets
- [x] Create `onboarding_progress_indicator.dart` (linear progress + dots)
- [x] Create `onboarding_navigation_bar.dart` (Next, Back, Skip buttons)
- [x] Create `profile_type_card.dart` (integrated into profile_type_step.dart)
- [x] Create `validated_text_field.dart` (inline validators in physical_characteristics_step.dart)

**Estimated Time**: 2 hours

### Task 7: Implement Form Validation
- [x] Add age validator (13-120 years)
- [x] Add height validator (100-250 cm)
- [x] Add weight validator (20-500 kg)
- [x] Add real-time error messages on blur
- [x] Disable Next button until step is valid

**Estimated Time**: 1.5 hours

### Task 8: Integrate with GoRouter
- [x] Update `app_router.dart` import to new OnboardingScreen location
- [x] Check `shouldCompleteOnboardingProvider` in redirect
- [x] Block access to protected routes until onboarding complete
- [x] Redirect authenticated users to `/onboarding` if `profileType` empty
- [x] Redirect to `/dashboard` after onboarding completion

**Estimated Time**: 1 hour

### Task 9: Implement Adaptive Flow Logic
- [x] "Waste" profile → 3 steps (Welcome, ProfileType, Success)
- [x] "Nutrition"/"MealPlanning"/"All" profile → 6 steps
- [x] Profile type change resets nutrition data (AC13)
- [x] Progress indicator updates dynamically (3 vs 6 steps)

**Estimated Time**: 1 hour

### Task 10: Add Accessibility Features
- [x] Add Semantics labels to all interactive elements
- [x] Add screen reader announcements (step text in progress indicator)
- [x] Semantics headers for all step titles
- [ ] Test with TalkBack (Android) and VoiceOver (iOS) — manual test
- [ ] Verify WCAG AA color contrast — manual test

**Estimated Time**: 2 hours

### Task 11: Implement Error Handling
- [x] Handle Firestore network errors with retry logic (3 attempts, 1s/2s/4s)
- [x] Display error messages in Success Step
- [x] Error card with icon in SuccessStep widget
- [x] FirebaseException and generic exception handling in notifier

**Estimated Time**: 1.5 hours

### Task 12: Add Mid-Onboarding Exit/Resume Logic (Optional)
- [x] Exit confirmation dialog implemented (simplified — no Hive persistence)
- [ ] Save onboarding state to Hive on exit — skipped (not in MVP scope)
- [ ] Check for saved state on app startup — skipped
- [ ] Show "Resume Onboarding?" dialog if < 24 hours — skipped

**Estimated Time**: 2 hours (optional)

### Task 13: Write Unit Tests
- [x] Test OnboardingNotifier state mutations (navigation, formData)
- [x] Test BMR calculation accuracy (Mifflin-St Jeor)
- [x] Test TDEE calculation accuracy (5 activity levels)
- [x] Test macro targets calculation (sum ≈ targetCalories)
- [x] Test adaptive flow logic (waste vs nutrition paths)
- [x] Test Firestore save with mocked dependencies
- [x] Test retry logic on network failure (FirebaseException scenario)

**Estimated Time**: 3 hours

### Task 14: Write Widget Tests
- [ ] Test WelcomeStep renders correctly — deferred
- [ ] Test ProfileTypeStep card selection — deferred
- [ ] Test PhysicalCharacteristicsStep validation — deferred
- [ ] Test DietaryPreferencesStep multi-select chips — deferred
- [ ] Test NutritionalGoalsStep goal selection — deferred
- [ ] Test SuccessStep displays summary correctly — deferred
- [ ] Test OnboardingProgressIndicator updates — deferred

**Estimated Time**: 3 hours

### Task 15: Write Integration Tests
- [ ] Test full flow: Waste profile (3 steps) — deferred
- [ ] Test full flow: Nutrition profile (6 steps) — deferred
- [ ] Test back navigation preserves data — deferred
- [ ] Test profile type change resets data — deferred
- [ ] Test completion saves to Firestore — deferred
- [ ] Test GoRouter redirect after completion — deferred

**Estimated Time**: 2 hours

### Task 16: Manual Testing on Devices
- [ ] Test on Android phone
- [ ] Test on iOS phone
- [ ] Test screen reader (TalkBack/VoiceOver)
- [ ] Test network error scenario (airplane mode)
- [ ] Test exit and resume flow
- [ ] Test all 4 profile types end-to-end

**Estimated Time**: 2 hours

### Task 17: Update Firestore Security Rules
- [ ] Add rule for onboarding completion update
- [ ] Restrict updatable fields during onboarding
- [ ] Test rules with Firebase Emulator

**Estimated Time**: 30 minutes

### Task 18: Documentation
- [ ] Add onboarding flow diagram to README
- [ ] Document adaptive flow decision tree
- [ ] Document BMR/TDEE calculation formulas
- [ ] Document 12 nutrition goals with macros
- [ ] Add troubleshooting guide for common issues

**Estimated Time**: 1.5 hours

---

## Testing Strategy

### Unit Tests
```dart
// test/features/onboarding/presentation/providers/onboarding_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late OnboardingNotifier notifier;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    notifier = OnboardingNotifier(mockFirestore, 'test_user_123');
  });

  group('Adaptive Flow Logic', () {
    test('setProfileType to "waste" shows 3 steps', () {
      // Arrange
      notifier.setProfileType('waste');

      // Assert
      expect(notifier.state.visibleSteps.length, 3);
      expect(notifier.state.visibleSteps, [
        OnboardingStep.welcome,
        OnboardingStep.profileType,
        OnboardingStep.success,
      ]);
    });

    test('setProfileType to "nutrition" shows 6 steps', () {
      // Arrange
      notifier.setProfileType('nutrition');

      // Assert
      expect(notifier.state.visibleSteps.length, 6);
      expect(notifier.state.visibleSteps, [
        OnboardingStep.welcome,
        OnboardingStep.profileType,
        OnboardingStep.physicalCharacteristics,
        OnboardingStep.dietaryPreferences,
        OnboardingStep.nutritionalGoals,
        OnboardingStep.success,
      ]);
    });

    test('changing profile type from nutrition to waste clears health data', () {
      // Arrange
      notifier.setProfileType('nutrition');
      notifier.updateFormField('physicalCharacteristics', {'age': 28});
      notifier.updateFormField('dietaryPreferences', {'restrictions': ['vegetarian']});

      // Act
      notifier.setProfileType('waste');

      // Assert
      expect(notifier.state.formData['physicalCharacteristics'], null);
      expect(notifier.state.formData['dietaryPreferences'], null);
    });
  });

  group('BMR Calculation', () {
    test('calculates correct BMR for male', () {
      // Mifflin-St Jeor: BMR = (10 × 75) + (6.25 × 180) - (5 × 28) + 5
      // = 750 + 1125 - 140 + 5 = 1740
      final bmr = notifier._calculateBMR(
        age: 28,
        gender: 'male',
        height: 180,
        weight: 75.0,
      );

      expect(bmr, closeTo(1740, 1));
    });

    test('calculates correct BMR for female', () {
      // Mifflin-St Jeor: BMR = (10 × 60) + (6.25 × 165) - (5 × 25) - 161
      // = 600 + 1031.25 - 125 - 161 = 1345.25
      final bmr = notifier._calculateBMR(
        age: 25,
        gender: 'female',
        height: 165,
        weight: 60.0,
      );

      expect(bmr, closeTo(1345.25, 1));
    });
  });

  group('TDEE Calculation', () {
    test('calculates correct TDEE for moderate activity', () {
      final bmr = 1740.0;
      final tdee = notifier._calculateTDEE(bmr, 'moderate');

      // TDEE = 1740 × 1.55 = 2697
      expect(tdee, closeTo(2697, 1));
    });

    test('calculates correct TDEE for sedentary activity', () {
      final bmr = 1740.0;
      final tdee = notifier._calculateTDEE(bmr, 'sedentary');

      // TDEE = 1740 × 1.2 = 2088
      expect(tdee, closeTo(2088, 1));
    });
  });

  group('Macro Targets Calculation', () {
    test('calculates macros for weight loss goal', () {
      final macros = notifier._calculateMacroTargets(
        adjustedCalories: 1700, // TDEE 2200 - 500 deficit
        weight: 75,
        goalId: 'weight_loss',
      );

      expect(macros['calories'], 1700);
      expect(macros['protein'], greaterThan(100)); // High protein for weight loss
      expect(macros['carbs'], greaterThan(100));
      expect(macros['fats'], greaterThan(40));
    });
  });

  group('Firestore Save', () {
    test('completeOnboarding saves correct data for waste profile', () async {
      // Arrange
      notifier.setProfileType('waste');

      when(mockFirestore.collection('users').doc('test_user_123').update(any))
          .thenAnswer((_) async => {});

      // Act
      await notifier.completeOnboarding();

      // Assert
      verify(mockFirestore.collection('users').doc('test_user_123').update({
        'profileType': 'waste',
        'onboardingCompleted': true,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
        'healthProfile': null,
      })).called(1);
    });

    test('completeOnboarding saves health profile for nutrition type', () async {
      // Arrange
      notifier.setProfileType('nutrition');
      notifier.updateFormField('physicalCharacteristics', {
        'age': 28,
        'gender': 'male',
        'height': 180,
        'weight': 75,
        'activityLevel': 'moderate',
      });
      notifier.updateFormField('dietaryPreferences', {
        'restrictions': ['vegetarian'],
        'allergies': ['shellfish'],
      });
      notifier.updateFormField('nutritionalGoals', {
        'selectedGoal': 'weight_loss',
      });

      when(mockFirestore.collection('users').doc('test_user_123').update(any))
          .thenAnswer((_) async => {});

      // Act
      await notifier.completeOnboarding();

      // Assert
      final captured = verify(
        mockFirestore.collection('users').doc('test_user_123').update(captureAny),
      ).captured.single as Map<String, dynamic>;

      expect(captured['profileType'], 'nutrition');
      expect(captured['onboardingCompleted'], true);
      expect(captured['healthProfile'], isNotNull);
      expect(captured['healthProfile']['age'], 28);
      expect(captured['healthProfile']['bmr'], greaterThan(0));
      expect(captured['healthProfile']['tdee'], greaterThan(0));
      expect(captured['healthProfile']['macroTargets'], isNotNull);
    });
  });
}
```

### Widget Tests
```dart
// test/features/onboarding/presentation/widgets/steps/profile_type_step_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('ProfileTypeStep displays 4 profile cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProfileTypeStep(),
          ),
        ),
      ),
    );

    // Find 4 profile type cards
    expect(find.text('Reduce Waste'), findsOneWidget);
    expect(find.text('Track Nutrition'), findsOneWidget);
    expect(find.text('Meal Planning'), findsOneWidget);
    expect(find.text('All Features'), findsOneWidget);
  });

  testWidgets('tapping profile card selects it', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: ProfileTypeStep(),
          ),
        ),
      ),
    );

    // Tap "Reduce Waste" card
    await tester.tap(find.text('Reduce Waste'));
    await tester.pump();

    // Verify selection in state
    final state = container.read(onboardingStateProvider);
    expect(state.formData['profileType'], 'waste');
  });
}
```

### Integration Tests
```dart
// integration_test/onboarding_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete onboarding with Waste profile (3 steps)', (tester) async {
    // Launch app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Step 1: Welcome Screen
    expect(find.text('Welcome to FrigoFute'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Step 2: Select "Reduce Waste"
    expect(find.text('Reduce Waste'), findsOneWidget);
    await tester.tap(find.text('Reduce Waste'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 3: Success Screen (Steps 3, 4, 5 skipped)
    expect(find.text('You\'re All Set!'), findsOneWidget);
    expect(find.text('Profile Type: Reduce Waste'), findsOneWidget);
  });

  testWidgets('Complete onboarding with Nutrition profile (6 steps)', (tester) async {
    // Launch app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Step 1: Welcome
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Step 2: Select "Track Nutrition"
    await tester.tap(find.text('Track Nutrition'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 3: Physical Characteristics
    expect(find.text('Age'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '28');
    await tester.tap(find.text('Male'));
    await tester.enterText(find.byType(TextFormField).at(1), '180');
    await tester.enterText(find.byType(TextFormField).at(2), '75');
    await tester.tap(find.text('Moderate'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 4: Dietary Preferences
    await tester.tap(find.text('Vegetarian'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 5: Nutritional Goals
    await tester.tap(find.text('Weight Loss'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 6: Success Screen
    expect(find.text('You\'re All Set!'), findsOneWidget);
    expect(find.text('Goal: Weight Loss'), findsOneWidget);
  });
}
```

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Using Stepper Widget Instead of PageView
**Problem**: Stepper widget shows all steps vertically, which is not ideal for mobile onboarding (takes too much screen space).

**Solution**: Use PageView with horizontal transitions for modern mobile UX.

```dart
// ❌ WRONG: Stepper shows all steps at once
Stepper(
  currentStep: currentStep,
  steps: [
    Step(title: Text('Welcome'), content: WelcomeStep()),
    Step(title: Text('Profile'), content: ProfileTypeStep()),
    // ... all steps visible
  ],
)

// ✅ CORRECT: PageView shows one step at a time
PageView(
  controller: _pageController,
  physics: NeverScrollableScrollPhysics(),
  children: [
    WelcomeStep(),
    ProfileTypeStep(),
    // ... smooth transitions
  ],
)
```

### ❌ Anti-Pattern 2: Allowing Swipe Navigation in Onboarding
**Problem**: Users can accidentally swipe to next step without completing current step validation.

**Solution**: Disable swipe with `NeverScrollableScrollPhysics()`, use button navigation only.

```dart
// ❌ WRONG: Swipe enabled, bypasses validation
PageView(
  controller: _pageController,
  // Default physics allows swipe
  children: [...],
)

// ✅ CORRECT: Swipe disabled, button navigation only
PageView(
  controller: _pageController,
  physics: const NeverScrollableScrollPhysics(), // No swipe
  children: [...],
)
```

### ❌ Anti-Pattern 3: Not Clearing Data on Profile Type Change
**Problem**: User selects "Nutrition" (fills age, weight), then switches to "Waste". Old nutrition data remains in state, causing confusion.

**Solution**: Clear dependent data when profile type changes.

```dart
// ❌ WRONG: Data persists across profile type changes
void setProfileType(String newType) {
  formData['profileType'] = newType;
  // Old physicalCharacteristics data still exists!
}

// ✅ CORRECT: Clear dependent data
void setProfileType(String newType) {
  formData['profileType'] = newType;

  if (newType == 'waste') {
    formData.remove('physicalCharacteristics');
    formData.remove('dietaryPreferences');
    formData.remove('nutritionalGoals');
  }
}
```

### ❌ Anti-Pattern 4: Hardcoding Step Count in Progress Indicator
**Problem**: Progress indicator shows "Step 3 of 6" even for "Waste" profile (which only has 3 steps).

**Solution**: Calculate total steps dynamically based on visible steps.

```dart
// ❌ WRONG: Hardcoded step count
Text('Step ${currentPage} of 6'); // Always shows 6!

// ✅ CORRECT: Dynamic step count
Text('Step ${currentPage + 1} of ${state.visibleSteps.length}');
```

### ❌ Anti-Pattern 5: No Retry Logic on Network Failure
**Problem**: Firestore save fails due to network error → user loses all onboarding data and must restart.

**Solution**: Implement retry logic with exponential backoff.

```dart
// ❌ WRONG: No retry, data lost on failure
try {
  await firestore.collection('users').doc(userId).update(data);
} catch (e) {
  // Data lost!
}

// ✅ CORRECT: Retry with exponential backoff
Future<void> _saveWithRetry(Map<String, dynamic> data) async {
  int attempt = 0;
  while (attempt < 3) {
    try {
      await firestore.collection('users').doc(userId).update(data);
      return; // Success
    } catch (e) {
      attempt++;
      if (attempt >= 3) rethrow;
      await Future.delayed(Duration(seconds: 1 << attempt));
    }
  }
}
```

### ❌ Anti-Pattern 6: Calculating Macros Without Scaling to Target Calories
**Problem**: Sum of macros (protein 150g + carbs 225g + fats 60g = 2025 cal) doesn't match target calories (1700 cal).

**Solution**: Scale macros proportionally to match target calories.

```dart
// ❌ WRONG: Macros don't sum to target calories
final protein = 2.0 * weight; // 150g
final carbs = 3.0 * weight;   // 225g
final fats = 0.8 * weight;    // 60g
// Total: 150*4 + 225*4 + 60*9 = 2025 cal ≠ target 1700 cal

// ✅ CORRECT: Scale macros to match target calories
final totalFromMacros = (protein * 4) + (carbs * 4) + (fats * 9);
final scaleFactor = targetCalories / totalFromMacros;

final adjustedProtein = protein * scaleFactor;
final adjustedCarbs = carbs * scaleFactor;
final adjustedFats = fats * scaleFactor;
```

### ❌ Anti-Pattern 7: Not Announcing Page Changes to Screen Readers
**Problem**: Visually impaired users don't know when onboarding step changes.

**Solution**: Use `SemanticsService.announce()` on page change.

```dart
// ❌ WRONG: No accessibility announcements
void goToNextPage() {
  _pageController.nextPage(...);
}

// ✅ CORRECT: Announce step change
void goToNextPage() {
  _pageController.nextPage(...);

  SemanticsService.announce(
    'Step ${currentPage + 1}: ${currentStepTitle}',
    TextDirection.ltr,
  );
}
```

---

## Integration Points

### Upstream Dependencies
- **Story 0.4**: Riverpod StateNotifier pattern established
- **Story 0.5**: GoRouter configured with redirect logic
- **Story 1.1-1.4**: User authentication creates user document with empty `profileType` field

### Downstream Consumers
- **Story 1.6**: Physical profile configuration (uses healthProfile data)
- **Story 1.7**: Dietary preferences configuration (uses dietaryRestrictions and allergies)
- **Story 7.1**: Nutrition tracking activation (checks healthProfile existence)
- **Story 8.1**: Nutritional profile selection (uses macroTargets from onboarding)
- **Story 9.1**: Meal planning (uses nutritionalGoal and dietaryPreferences)

### Shared Components
- **UserModel**: Updated with `profileType`, `healthProfile`, `onboardingCompleted` fields
- **GoRouter**: Redirect logic checks `shouldCompleteOnboardingProvider`
- **Firestore**: Saves onboarding data to users collection
- **Crashlytics**: Logs errors during onboarding

---

## Dev Notes

### Adaptive Flow Decision Tree
The onboarding flow adapts based on `profileType` selection:

```
profileType = 'waste'
  → 3 steps: Welcome → Profile Selection → Success
  → Skip nutrition steps entirely

profileType = 'nutrition' | 'meal_planning' | 'all'
  → 6 steps: Welcome → Profile → Physical → Dietary → Goals → Success
  → Collect full health profile
```

### BMR Calculation Formula
Uses **Mifflin-St Jeor Equation** (more accurate than Harris-Benedict):

```
Male: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) + 5
Female: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) - 161
```

### TDEE Calculation
```
TDEE = BMR × Activity Multiplier

Activity Levels:
- Sedentary (little/no exercise): 1.2
- Light (exercise 1-3 days/week): 1.375
- Moderate (exercise 3-5 days/week): 1.55
- Active (exercise 6-7 days/week): 1.725
- Very Active (intense exercise daily): 1.9
```

### Macro Targets Calculation
```
1. Calculate base macros: protein/carbs/fats per kg body weight
2. Calculate calories from macros: (P×4) + (C×4) + (F×9)
3. Scale macros to match target calories: macro × (targetCal / totalCal)
```

### Resume vs Restart Logic
- **< 24 hours since last update**: Show "Resume Onboarding?" dialog
- **> 24 hours**: Auto-restart from Step 1 (UX simplicity)
- **Saved state location**: Hive local storage (optional) or Riverpod provider (session only)

### Accessibility Best Practices
- **Semantic labels**: Every interactive element has clear label
- **Screen reader announcements**: Step changes announced via `SemanticsService.announce()`
- **Focus management**: First form field auto-focuses on step load
- **Color contrast**: All text meets WCAG AA standards (4.5:1 ratio)

### Network Error Handling Strategy
1. **Retry logic**: 3 attempts with exponential backoff (1s, 2s, 4s)
2. **Timeout**: 10 seconds per attempt
3. **User feedback**: Clear error message with "Retry" button
4. **Logging**: All errors logged to Crashlytics with onboarding context

---

## Definition of Done

### Code Complete
- [x] OnboardingState Freezed model created with code generation
- [x] OnboardingNotifier implemented with all state mutations
- [x] All 6 step widgets created (Welcome, ProfileType, Physical, Dietary, Goals, Success)
- [x] OnboardingProgressIndicator shows dynamic progress (3 vs 6 steps)
- [x] OnboardingNavigationBar handles Next/Back navigation
- [x] GoRouter redirect logic checks onboarding completion (import updated)
- [x] Adaptive flow logic works for all 4 profile types
- [x] BMR, TDEE, and macro calculations implemented and tested
- [x] Firestore save with retry logic implemented
- [x] Error handling for network failures added

### Testing Complete
- [x] Unit tests for OnboardingNotifier (42 tests pass: navigation, formData, adaptive flow, BMR/TDEE/macros, Firestore save)
- [x] Unit tests for BMR calculation (accuracy verified)
- [x] Unit tests for TDEE calculation (accuracy verified)
- [x] Unit tests for macro targets calculation
- [ ] Widget tests for all 6 step widgets
- [ ] Widget tests for OnboardingProgressIndicator
- [ ] Integration test: Waste profile flow (3 steps)
- [ ] Integration test: Nutrition profile flow (6 steps)
- [ ] Integration test: Back navigation preserves data
- [ ] Integration test: Profile type change resets data
- [ ] Manual test: Screen reader (TalkBack/VoiceOver)
- [ ] Manual test: Network error scenario (airplane mode)

### Accessibility Complete
- [ ] Semantic labels added to all interactive elements
- [ ] Screen reader announcements on step change
- [ ] Focus management implemented (auto-focus first field)
- [ ] Keyboard navigation works (Tab, Enter, Escape)
- [ ] Color contrast meets WCAG AA (4.5:1 ratio)
- [ ] Tested with TalkBack (Android)
- [ ] Tested with VoiceOver (iOS)

### Documentation Complete
- [ ] README updated with onboarding flow diagram
- [ ] Adaptive flow decision tree documented
- [ ] BMR/TDEE formulas documented
- [ ] 12 nutritional goals documented with macro ratios
- [ ] Mid-onboarding exit/resume behavior documented
- [ ] Code comments explain complex logic (adaptive flow, calculations)

### Deployment Ready
- [ ] Firestore Security Rules updated for onboarding fields
- [ ] Security rules tested with Firebase Emulator
- [ ] Performance tested (no jank on page transitions)
- [ ] Error logging verified in Crashlytics
- [ ] All 4 profile types tested end-to-end on real devices
- [ ] Product Owner demo completed successfully

### Acceptance Criteria Verified
- [ ] All 18 Acceptance Criteria tested and passing
- [ ] No critical bugs or regressions
- [ ] Code reviewed by senior developer
- [ ] Sprint demo completed with stakeholder approval

---

## References

### Official Documentation
- [Flutter PageView Widget](https://api.flutter.dev/flutter/widgets/PageView-class.html)
- [Riverpod StateNotifier](https://riverpod.dev/docs/providers/state_notifier_provider)
- [Freezed Package for Immutable Models](https://pub.dev/packages/freezed)
- [GoRouter Redirect Logic](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
- [Firebase Firestore Update](https://firebase.google.com/docs/firestore/manage-data/add-data#update-data)

### Best Practices Articles
- [Best Mobile App Onboarding Examples in 2026](https://www.plotline.so/blog/mobile-app-onboarding-examples)
- [The Ultimate Mobile App Onboarding Guide (2026)](https://vwo.com/blog/mobile-app-onboarding-guide/)
- [The Ultimate Guide to In-App Onboarding in 2025](https://www.appcues.com/blog/in-app-onboarding)
- [7 User Onboarding Best Practices for 2025](https://formbricks.com/blog/user-onboarding-best-practices)

### Technical Implementation
- [Creating Multi-Step Forms in Flutter](https://blog.logrocket.com/creating-multi-step-form-flutter-stepper-widget/)
- [Flutter State Management with Riverpod 2.0](https://codewithandrea.com/articles/flutter-state-management-riverpod/)
- [Flutter Authentication Flow with GoRouter](https://blog.ishangavidusha.com/flutter-authentication-flow-with-go-router-and-provider)

### Accessibility
- [Developing Accessible Apps in Flutter](https://medium.com/flutter-community/developing-and-testing-accessible-app-in-flutter-1dc1d33c7eea)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

### Nutritional Science
- [Mifflin-St Jeor Equation for BMR](https://en.wikipedia.org/wiki/Harris%E2%80%93Benedict_equation)
- [TDEE Calculator Methodology](https://tdeecalculator.net/)
- [Macronutrient Distribution for Different Goals](https://examine.com/guides/macronutrients/)

### Related Stories
- **Story 1.1**: Create Account with Email and Password
- **Story 1.2**: Login with Email and Password
- **Story 1.3**: Login with OAuth Google Sign-In
- **Story 1.4**: Login with OAuth Apple Sign-In
- **Story 1.6**: Configure Personal Profile with Physical Characteristics
- **Story 1.7**: Set Dietary Preferences and Allergies

---

## Changelog

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-02-15 | 1.0 | Dev Team | Initial story creation for Epic 1 Sprint 2 |
| 2026-02-21 | 1.1 | Dev Agent | Story implemented — all core tasks 1-13 complete, 42 unit tests pass |
| 2026-02-21 | 1.2 | Dev Agent | Code review fixes (H1+H2+M1-M4): AC12 resume via Hive persistence, AC15 Retry+Review buttons, AC9 Review Settings button, try/catch in _completeOnboarding, userId guard, injectable delay for tests |

---

**Story Status**: 🔍 In Review
**Epic Progress**: Epic 1 - Story 5 of 10 (50% planned)
**Next Story**: 1-6-configure-personal-profile-with-physical-characteristics
**Blocked By**: None (all dependencies in ready-for-dev or done status)

---

## Dev Agent Record

### Implementation Summary
- **Date**: 2026-02-21
- **Agent**: Claude Sonnet 4.6 (claude-sonnet-4-6)
- **Story Points Completed**: 8
- **Tests**: 42/42 pass (12 state tests + 30 notifier tests)

### Key Decisions
1. **NutritionalGoal as plain Dart class** (not Freezed): Required for `const` instances in `static const List<NutritionalGoal> goals`.
2. **Freezed v3 pattern**: `abstract class OnboardingState with _$OnboardingState` — collections (`List`, `Map`) are `required` fields (no `@Default` for complex types).
3. **shouldCompleteOnboardingProvider reads Firestore directly**: Avoids `getCurrentUser()` bug where `UserEntity.fromFirebaseUser()` returns empty `profileType`.
4. **Public calculation methods**: `calculateBmr`, `calculateTdee`, `calculateMacroTargets` are public for direct testability (not `_private`).
5. **Icons.star_of_david not available**: Replaced with `Icons.stars` for "Casher" dietary restriction.
6. **Widget tests deferred**: Complex Flutter widget tests with Riverpod require significant setup; unit tests cover all logic paths.

### Bug Fixes
- Removed `Icons.star_of_david` (not in Material Icons) → replaced with `Icons.stars`
- Removed unused import of `onboarding_notifier.dart` in `profile_type_step.dart`
- Changed `var updatedFormData` → `final updatedFormData` in `onboarding_notifier.dart`

## File List

### New Files Created
- `lib/features/onboarding/domain/models/profile_type.dart` — ProfileType enum (4 types, icons, requiresNutritionSteps)
- `lib/features/onboarding/domain/models/nutritional_goal.dart` — NutritionalGoal class + 12 static goals
- `lib/features/onboarding/domain/models/onboarding_state.dart` — Freezed v3 state model + getters
- `lib/features/onboarding/domain/models/onboarding_state.freezed.dart` — Generated by build_runner
- `lib/features/onboarding/presentation/providers/onboarding_notifier.dart` — StateNotifier with BMR/TDEE/Firestore
- `lib/features/onboarding/presentation/providers/onboarding_providers.dart` — Riverpod providers
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart` — Main screen (PageController, PageView, exit dialog)
- `lib/features/onboarding/presentation/widgets/onboarding_progress_indicator.dart` — Linear bar + dots
- `lib/features/onboarding/presentation/widgets/onboarding_navigation_bar.dart` — Back + Next/Complete buttons
- `lib/features/onboarding/presentation/widgets/steps/welcome_step.dart` — Step 1: logo, headline, 4 benefits
- `lib/features/onboarding/presentation/widgets/steps/profile_type_step.dart` — Step 2: 4 profile cards, change dialog
- `lib/features/onboarding/presentation/widgets/steps/physical_characteristics_step.dart` — Step 3: age/gender/height/weight/activity
- `lib/features/onboarding/presentation/widgets/steps/dietary_preferences_step.dart` — Step 4: restrictions chips + allergies
- `lib/features/onboarding/presentation/widgets/steps/nutritional_goals_step.dart` — Step 5: 12 goal cards grid
- `lib/features/onboarding/presentation/widgets/steps/success_step.dart` — Step 6: summary + error + loading
- `test/features/onboarding/domain/models/onboarding_state_test.dart` — 12 state getter/copyWith tests
- `test/features/onboarding/presentation/providers/onboarding_notifier_test.dart` — 30 notifier tests

### Modified Files
- `lib/core/routing/app_router.dart` — Import updated from placeholder to new OnboardingScreen

## Change Log

| Change | Type | Reason |
|--------|------|--------|
| Create full `lib/features/onboarding/` feature module | Feature | Story 1-5 implementation |
| Update `app_router.dart` import to new OnboardingScreen | Refactor | Move from placeholder to feature module |
| Replace `Icons.star_of_david` with `Icons.stars` | Fix | Icon doesn't exist in Material Icons library |
| Remove unused `onboarding_notifier.dart` import | Fix | Linter warning |
| Change `var` to `final` for `updatedFormData` | Fix | Lint: prefer_final_locals |
