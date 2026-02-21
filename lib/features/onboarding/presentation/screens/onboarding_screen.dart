import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../domain/models/onboarding_state.dart';
import '../providers/onboarding_notifier.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/onboarding_navigation_bar.dart';
import '../widgets/onboarding_progress_indicator.dart';
import '../widgets/steps/dietary_preferences_step.dart';
import '../widgets/steps/nutritional_goals_step.dart';
import '../widgets/steps/physical_characteristics_step.dart';
import '../widgets/steps/profile_type_step.dart';
import '../widgets/steps/success_step.dart';
import '../widgets/steps/welcome_step.dart';

/// Main onboarding screen orchestrating the adaptive multi-step flow
/// Story 1.5: Complete Adaptive Onboarding Flow — AC1–AC16
///
/// - PageController synced with OnboardingState.currentPageIndex
/// - NeverScrollableScrollPhysics (navigation only via buttons)
/// - Exit confirmation dialog (AC12)
/// - completeOnboarding() handler with Firestore save + dashboard redirect
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  /// Map from step enum to widget — constructed once
  static final Map<OnboardingStep, Widget> _stepWidgets = {
    OnboardingStep.welcome: const WelcomeStep(),
    OnboardingStep.profileType: const ProfileTypeStep(),
    OnboardingStep.physicalCharacteristics:
        const PhysicalCharacteristicsStep(),
    OnboardingStep.dietaryPreferences: const DietaryPreferencesStep(),
    OnboardingStep.nutritionalGoals: const NutritionalGoalsStep(),
    OnboardingStep.success: const SuccessStep(),
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkResume());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ─── Resume Onboarding (AC12) ─────────────────────────────────────────────

  /// Check for saved onboarding progress and show resume dialog — AC12
  void _checkResume() {
    final saved = OnboardingNotifier.getSavedProgress();
    if (saved == null || !mounted) return;

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Reprendre la configuration ?'),
        content: const Text(
          'Vous aviez commencé à configurer votre profil. '
          'Souhaitez-vous reprendre là où vous vous étiez arrêté ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Recommencer'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reprendre'),
          ),
        ],
      ),
    ).then((resume) {
      if (!mounted) return;
      if (resume == true) {
        ref.read(onboardingStateProvider.notifier).restoreFromSaved(saved);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final pageIndex = (saved['currentPageIndex'] as int?) ?? 0;
          if (_pageController.hasClients && pageIndex > 0) {
            _pageController.jumpToPage(pageIndex);
          }
        });
      } else {
        OnboardingNotifier.clearSavedProgress();
      }
    });
  }

  // ─── Next-Button Enabled Logic ─────────────────────────────────────────────

  bool _isNextEnabled(OnboardingState state) {
    if (state.isLoading) return false;

    switch (state.currentStep) {
      case OnboardingStep.welcome:
        return true;

      case OnboardingStep.profileType:
        return (state.formData['profileType'] as String?)?.isNotEmpty == true;

      case OnboardingStep.physicalCharacteristics:
        final p = state.formData['physicalCharacteristics'] as Map<String, dynamic>?;
        if (p == null) return false;
        final age = p['age'] as int? ?? 0;
        final gender = p['gender'] as String? ?? '';
        final height = p['height'] as int? ?? 0;
        final weight = (p['weight'] as num?)?.toDouble() ?? 0.0;
        final activity = p['activityLevel'] as String? ?? '';
        return age >= 13 &&
            gender.isNotEmpty &&
            height >= 100 &&
            weight >= 20 &&
            activity.isNotEmpty;

      case OnboardingStep.dietaryPreferences:
        return true; // AC7: all fields optional

      case OnboardingStep.nutritionalGoals:
        final n = state.formData['nutritionalGoals'] as Map<String, dynamic>?;
        return (n?['selectedGoal'] as String?)?.isNotEmpty == true;

      case OnboardingStep.success:
        return !state.isLoading;
    }
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _completeOnboarding() async {
    try {
      await ref.read(onboardingStateProvider.notifier).completeOnboarding();
    } catch (_) {
      // Error reflected in state.errorMessage — displayed by SuccessStep
    }
    if (!mounted) return;

    final state = ref.read(onboardingStateProvider);
    if (state.errorMessage.isEmpty) {
      context.go(AppRoutes.dashboard);
    }
    // On error: stay on success step, errorMessage shown by SuccessStep widget
  }

  void _showExitDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quitter la configuration ?'),
        content: const Text(
          'Votre progression sera perdue. Vous devrez reconfigurer votre profil à votre prochaine connexion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Rester'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.login);
            },
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingStateProvider);

    // Sync PageController when state changes (e.g. setProfileType recalculates steps)
    ref.listen<int>(
      onboardingStateProvider.select((s) => s.currentPageIndex),
      (previous, next) {
        if (_pageController.hasClients) {
          final currentPage = _pageController.page?.round() ?? 0;
          if (currentPage != next) {
            _pageController.animateToPage(
              next,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
            );
          }
        }
      },
    );

    final isOnSuccess = state.currentStep == OnboardingStep.success;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (state.canGoBack) {
          ref.read(onboardingStateProvider.notifier).goToPreviousPage();
        } else {
          _showExitDialog();
        }
      },
      child: Scaffold(
        // Progress indicator replaces AppBar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: SafeArea(
            child: OnboardingProgressIndicator(
              currentPage: state.currentPageIndex,
              totalPages: state.totalPages,
            ),
          ),
        ),

        // Page content — NeverScrollableScrollPhysics so only buttons navigate
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            // Sync notifier when user somehow changes pages (defensive)
            ref.read(onboardingStateProvider.notifier).jumpToPage(index);
          },
          children: state.visibleSteps.map((step) {
            return _stepWidgets[step] ?? const SizedBox.shrink();
          }).toList(),
        ),

        // Bottom navigation bar
        bottomNavigationBar: OnboardingNavigationBar(
          showBack: state.canGoBack,
          onBack: () {
            ref.read(onboardingStateProvider.notifier).goToPreviousPage();
          },
          isNextEnabled: _isNextEnabled(state),
          nextLabel: isOnSuccess ? 'Commencer FrigoFute' : 'Suivant',
          onNext: isOnSuccess
              ? _completeOnboarding
              : () {
                  ref.read(onboardingStateProvider.notifier).goToNextPage();
                },
        ),
      ),
    );
  }
}
