import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/storage/hive_service.dart';
import '../../domain/models/nutritional_goal.dart';
import '../../domain/models/onboarding_state.dart';

/// Initial onboarding state — starts at Welcome + ProfileType steps
OnboardingState _initialState() => const OnboardingState(
      visibleSteps: [
        OnboardingStep.welcome,
        OnboardingStep.profileType,
        OnboardingStep.success,
      ],
      formData: {},
    );

/// StateNotifier for the onboarding flow
/// Story 1.5: Complete Adaptive Onboarding Flow
///
/// Manages:
/// - Adaptive step list based on `profileType` selection
/// - Form data accumulation across steps
/// - BMR/TDEE/macro calculations (Mifflin-St Jeor)
/// - Firestore save with 3-attempt exponential backoff
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final FirebaseFirestore _firestore;
  final String _userId;

  /// Injectable delay function — defaults to Future.delayed.
  /// Tests pass `(_) async {}` to skip real wait times (M4).
  final Future<void> Function(Duration) _delay;

  OnboardingNotifier(
    this._firestore,
    this._userId, {
    Future<void> Function(Duration)? delay,
  })  : _delay = delay ?? Future.delayed,
        super(_initialState());

  // ─── Progress Persistence (AC12) ─────────────────────────────────────────

  static const _progressKey = 'onboarding_state';
  static const _savedAtKey = 'saved_at';
  static const _expiryHours = 24;

  /// Persist current progress to Hive. No-ops if box not available (test env).
  void _saveProgress() {
    try {
      final box = Hive.box(HiveService.onboardingProgressBoxName);
      box.put(_progressKey, {
        'currentPageIndex': state.currentPageIndex,
        'visibleSteps': state.visibleSteps.map((s) => s.name).toList(),
        'formData': state.formData,
      });
      box.put(_savedAtKey, DateTime.now().toIso8601String());
    } catch (_) {
      // Hive not initialized — no-op (test environment or first init race)
    }
  }

  /// Delete saved progress (call on reset or after successful onboarding).
  static void clearSavedProgress() {
    try {
      final box = Hive.box(HiveService.onboardingProgressBoxName);
      box.delete(_progressKey);
      box.delete(_savedAtKey);
    } catch (_) {}
  }

  /// Returns saved progress if present and less than 24 hours old — AC12.
  static Map<String, dynamic>? getSavedProgress() {
    try {
      final box = Hive.box(HiveService.onboardingProgressBoxName);
      final savedAtStr = box.get(_savedAtKey) as String?;
      if (savedAtStr == null) return null;
      final savedAt = DateTime.tryParse(savedAtStr);
      if (savedAt == null) return null;
      if (DateTime.now().difference(savedAt).inHours >= _expiryHours) {
        box.delete(_progressKey);
        box.delete(_savedAtKey);
        return null;
      }
      return (box.get(_progressKey) as Map?)?.cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  /// Restore state from a saved progress map — called when user taps "Reprendre"
  void restoreFromSaved(Map<String, dynamic> saved) {
    final stepNames = (saved['visibleSteps'] as List? ?? []).cast<String>();
    final visibleSteps = stepNames
        .map(
          (name) => OnboardingStep.values.firstWhere(
            (s) => s.name == name,
            orElse: () => OnboardingStep.welcome,
          ),
        )
        .toList();

    if (visibleSteps.isEmpty) return;

    state = OnboardingState(
      currentPageIndex: (saved['currentPageIndex'] as int?) ?? 0,
      visibleSteps: visibleSteps,
      formData: Map<String, dynamic>.from((saved['formData'] as Map?) ?? {}),
    );
  }

  // ─── Navigation ──────────────────────────────────────────────────────────

  /// Advance to the next visible step
  void goToNextPage() {
    if (state.canGoForward) {
      state = state.copyWith(currentPageIndex: state.currentPageIndex + 1);
      _saveProgress();
    }
  }

  /// Go back to the previous visible step
  void goToPreviousPage() {
    if (state.canGoBack) {
      state = state.copyWith(currentPageIndex: state.currentPageIndex - 1);
    }
  }

  /// Jump to a specific page index (used for PageController sync)
  void jumpToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < state.totalPages) {
      state = state.copyWith(currentPageIndex: pageIndex);
    }
  }

  // ─── Form Data ────────────────────────────────────────────────────────────

  /// Update a single form data key (used by individual step widgets)
  void updateFormField(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(state.formData)..[key] = value;
    state = state.copyWith(formData: updated);
  }

  // ─── Adaptive Flow ────────────────────────────────────────────────────────

  /// Set profile type and recalculate the visible step list — AC4, AC5, AC13
  ///
  /// 'waste' → 3 steps (Welcome, ProfileType, Success)
  /// others  → 6 steps (adds Physical, Dietary, Goals)
  void setProfileType(String profileTypeId) {
    final requiresNutrition = profileTypeId != 'waste';

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

    // Clear nutrition data if switching to waste profile (AC13)
    final updatedFormData = Map<String, dynamic>.from(state.formData)
      ..['profileType'] = profileTypeId;

    if (!requiresNutrition) {
      updatedFormData
        ..remove('physicalCharacteristics')
        ..remove('dietaryPreferences')
        ..remove('nutritionalGoals');
    }

    state = state.copyWith(
      visibleSteps: visibleSteps,
      formData: updatedFormData,
    );
    _saveProgress();
  }

  // ─── Calculations ─────────────────────────────────────────────────────────

  /// Basal Metabolic Rate — Mifflin-St Jeor Equation — Dev Notes
  ///
  /// Male:   BMR = (10 × kg) + (6.25 × cm) - (5 × age) + 5
  /// Female: BMR = (10 × kg) + (6.25 × cm) - (5 × age) - 161
  double calculateBmr({
    required int age,
    required String gender,
    required int height,
    required double weight,
  }) {
    final s = gender.toLowerCase() == 'male' ? 5.0 : -161.0;
    return (10 * weight) + (6.25 * height) - (5 * age) + s;
  }

  /// Total Daily Energy Expenditure — activity multiplier table — Dev Notes
  double calculateTdee(double bmr, String activityLevel) {
    const multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return bmr * (multipliers[activityLevel.toLowerCase()] ?? 1.55);
  }

  /// Macro targets (g/day) scaled to match target calories — Dev Notes
  ///
  /// Anti-pattern avoided: macros are proportionally scaled to `targetCalories`
  /// to prevent sum mismatch (AC Anti-Pattern 6).
  Map<String, double> calculateMacroTargets({
    required double targetCalories,
    required double weight,
    required String goalId,
  }) {
    final goal = NutritionalGoals.findById(goalId);

    final proteinG = goal.proteinPerKg * weight;
    final carbsG = goal.carbsPerKg * weight;
    final fatsG = goal.fatsPerKg * weight;

    // Calories from macros: P×4 + C×4 + F×9
    final totalCals = (proteinG * 4) + (carbsG * 4) + (fatsG * 9);
    final scale = totalCals > 0 ? targetCalories / totalCals : 1.0;

    return {
      'calories': targetCalories,
      'protein': proteinG * scale,
      'carbs': carbsG * scale,
      'fats': fatsG * scale,
    };
  }

  // ─── Firestore Save ───────────────────────────────────────────────────────

  /// Save onboarding data to Firestore and complete the flow — AC14, AC15, AC16
  ///
  /// Retry logic: 3 attempts with exponential backoff (1s, 2s, 4s)
  Future<void> completeOnboarding() async {
    // M3: Guard against empty userId (unauthenticated race condition)
    if (_userId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Session expirée. Veuillez vous reconnecter.',
      );
      throw Exception('User not authenticated — cannot save onboarding data');
    }

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final profileType = state.formData['profileType'] as String? ?? 'waste';

      final Map<String, dynamic> updateData = {
        'profileType': profileType,
        'onboardingCompleted': true,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
      };

      if (profileType != 'waste') {
        final physChar =
            state.formData['physicalCharacteristics'] as Map<String, dynamic>? ?? {};
        final dietPref =
            state.formData['dietaryPreferences'] as Map<String, dynamic>? ?? {};
        final nutritGoals =
            state.formData['nutritionalGoals'] as Map<String, dynamic>? ?? {};

        final age = physChar['age'] as int? ?? 0;
        final gender = physChar['gender'] as String? ?? 'other';
        final height = physChar['height'] as int? ?? 170;
        final weight = (physChar['weight'] as num?)?.toDouble() ?? 70.0;
        final activityLevel = physChar['activityLevel'] as String? ?? 'moderate';

        final bmr = calculateBmr(
          age: age,
          gender: gender,
          height: height,
          weight: weight,
        );
        final tdee = calculateTdee(bmr, activityLevel);

        final goalId = nutritGoals['selectedGoal'] as String? ?? 'maintenance';
        final goal = NutritionalGoals.findById(goalId);
        final adjustedCalories = tdee + goal.calorieAdjustment;

        final macros = calculateMacroTargets(
          targetCalories: adjustedCalories,
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
          'dietaryRestrictions': dietPref['restrictions'] ?? <String>[],
          'allergies': dietPref['allergies'] ?? <String>[],
          'nutritionalGoal': goalId,
          'macroTargets': {
            'calories': macros['calories']!.round(),
            'protein': macros['protein']!.round(),
            'carbs': macros['carbs']!.round(),
            'fats': macros['fats']!.round(),
          },
        };
      } else {
        updateData['healthProfile'] = null;
      }

      await _saveWithRetry(updateData);

      clearSavedProgress();
      state = state.copyWith(isLoading: false);
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Connexion impossible. Vérifiez votre réseau et réessayez.',
      );
      throw Exception(e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur inattendue. Réessayez.',
      );
      rethrow;
    }
  }

  /// Retry save with exponential backoff: 1s, 2s, 4s — AC14
  Future<void> _saveWithRetry(Map<String, dynamic> data) async {
    const maxAttempts = 3;
    const delays = [1000, 2000, 4000];

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        await _firestore
            .collection('users')
            .doc(_userId)
            .update(data)
            .timeout(const Duration(seconds: 10));
        return; // Success
      } catch (e) {
        if (attempt >= maxAttempts - 1) rethrow;
        await _delay(Duration(milliseconds: delays[attempt]));
      }
    }
  }

  /// Reset to initial state (for "Recommencer" on resume dialog — AC12)
  void reset() {
    clearSavedProgress();
    state = _initialState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: '');
  }
}
