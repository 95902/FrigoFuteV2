import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

/// Onboarding step enumeration for the adaptive flow
/// Story 1.5: Complete Adaptive Onboarding Flow
enum OnboardingStep {
  welcome,
  profileType,
  physicalCharacteristics,
  dietaryPreferences,
  nutritionalGoals,
  success,
}

/// Immutable state for the onboarding flow — Story 1.5
///
/// - `currentPageIndex`: index into `visibleSteps`
/// - `visibleSteps`: adaptive list (3 steps for 'waste', 6 for others)
/// - `formData`: accumulated form data keyed by step name
/// - `isLoading`: true while saving to Firestore
/// - `errorMessage`: non-empty on Firestore save error
@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentPageIndex,
    required List<OnboardingStep> visibleSteps,
    required Map<String, dynamic> formData,
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
  }) = _OnboardingState;

  /// Private constructor needed for custom getters in Freezed v3
  const OnboardingState._();

  /// Progress as a fraction 0.0–1.0
  double get progressPercent {
    if (visibleSteps.isEmpty) return 0.0;
    return (currentPageIndex + 1) / visibleSteps.length;
  }

  /// Total number of visible steps (adaptive: 3 or 6)
  int get totalPages => visibleSteps.length;

  /// The current step enum value
  OnboardingStep get currentStep =>
      visibleSteps.isNotEmpty ? visibleSteps[currentPageIndex] : OnboardingStep.welcome;

  /// Whether back navigation is available
  bool get canGoBack => currentPageIndex > 0;

  /// Whether forward navigation is available
  bool get canGoForward => currentPageIndex < visibleSteps.length - 1;
}
