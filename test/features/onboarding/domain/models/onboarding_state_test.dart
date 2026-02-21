import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  const _threeSteps = [
    OnboardingStep.welcome,
    OnboardingStep.profileType,
    OnboardingStep.success,
  ];

  const _sixSteps = [
    OnboardingStep.welcome,
    OnboardingStep.profileType,
    OnboardingStep.physicalCharacteristics,
    OnboardingStep.dietaryPreferences,
    OnboardingStep.nutritionalGoals,
    OnboardingStep.success,
  ];

  group('OnboardingState getters', () {
    test('progressPercent returns 1/n for first page', () {
      final state = OnboardingState(
        currentPageIndex: 0,
        visibleSteps: _threeSteps,
        formData: const {},
      );
      expect(state.progressPercent, closeTo(1 / 3, 0.001));
    });

    test('progressPercent returns 1.0 on last page', () {
      final state = OnboardingState(
        currentPageIndex: 2,
        visibleSteps: _threeSteps,
        formData: const {},
      );
      expect(state.progressPercent, closeTo(1.0, 0.001));
    });

    test('progressPercent returns 0.0 for empty steps', () {
      final state = OnboardingState(
        currentPageIndex: 0,
        visibleSteps: const [],
        formData: const {},
      );
      expect(state.progressPercent, 0.0);
    });

    test('totalPages returns visibleSteps.length', () {
      final state3 = OnboardingState(
        visibleSteps: _threeSteps,
        formData: const {},
      );
      final state6 = OnboardingState(
        visibleSteps: _sixSteps,
        formData: const {},
      );
      expect(state3.totalPages, 3);
      expect(state6.totalPages, 6);
    });

    test('currentStep returns correct step for index', () {
      final state = OnboardingState(
        currentPageIndex: 1,
        visibleSteps: _threeSteps,
        formData: const {},
      );
      expect(state.currentStep, OnboardingStep.profileType);
    });

    test('currentStep falls back to welcome for empty steps', () {
      final state = OnboardingState(
        currentPageIndex: 0,
        visibleSteps: const [],
        formData: const {},
      );
      expect(state.currentStep, OnboardingStep.welcome);
    });

    test('canGoBack is false on first page', () {
      final state = OnboardingState(
        currentPageIndex: 0,
        visibleSteps: _threeSteps,
        formData: const {},
      );
      expect(state.canGoBack, isFalse);
    });

    test('canGoBack is true on page > 0', () {
      final state = OnboardingState(
        currentPageIndex: 1,
        visibleSteps: _threeSteps,
        formData: const {},
      );
      expect(state.canGoBack, isTrue);
    });

    test('canGoForward is false on last page', () {
      final state = OnboardingState(
        currentPageIndex: 2,
        visibleSteps: _threeSteps,
        formData: const {},
      );
      expect(state.canGoForward, isFalse);
    });

    test('canGoForward is true when not on last page', () {
      final state = OnboardingState(
        currentPageIndex: 0,
        visibleSteps: _threeSteps,
        formData: const {},
      );
      expect(state.canGoForward, isTrue);
    });
  });

  group('OnboardingState copyWith', () {
    test('copyWith updates currentPageIndex only', () {
      final original = OnboardingState(
        currentPageIndex: 0,
        visibleSteps: _threeSteps,
        formData: const {},
      );
      final updated = original.copyWith(currentPageIndex: 1);
      expect(updated.currentPageIndex, 1);
      expect(updated.visibleSteps, _threeSteps);
    });

    test('copyWith preserves isLoading and errorMessage defaults', () {
      final state = OnboardingState(
        visibleSteps: _threeSteps,
        formData: const {},
      );
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, '');
    });
  });
}
