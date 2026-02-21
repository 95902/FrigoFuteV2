import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/app_routes.dart';
import '../../../domain/models/nutritional_goal.dart';
import '../../../domain/models/profile_type.dart';
import '../../providers/onboarding_providers.dart';

/// Step 6: Success Screen — AC9
///
/// Animated checkmark, profile summary, nutrition summary (if applicable),
/// error and loading states. The "Commencer" CTA is in OnboardingNavigationBar.
class SuccessStep extends ConsumerWidget {
  const SuccessStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    final formData = state.formData;
    final profileTypeId = formData['profileType'] as String? ?? 'waste';
    final profileType = ProfileType.fromId(profileTypeId);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Animated checkmark
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 68,
                  color: Colors.green,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Headline
          Semantics(
            header: true,
            child: Text(
              'Vous êtes prêt !',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Votre profil a été configuré avec succès',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Profile type summary
          _SummaryCard(
            icon: profileType.icon,
            title: 'Profil sélectionné',
            value: profileType.title,
            subtitle: profileType.description,
          ),

          if (profileType.requiresNutritionSteps) ...[
            const SizedBox(height: 12),
            _NutritionSummaryCard(formData: formData),
          ],

          // AC9: "Review Settings" secondary button — navigates back to Step 2 (ProfileType)
          if (state.errorMessage.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ref.read(onboardingStateProvider.notifier).jumpToPage(1);
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Review Settings'),
              ),
            ),
          ],

          // Error state — AC15: Retry + Review buttons
          if (state.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // AC15: "Review" button — go back to Step 2 (ProfileType)
                        TextButton(
                          onPressed: () {
                            ref.read(onboardingStateProvider.notifier)
                              ..clearError()
                              ..jumpToPage(1);
                          },
                          child: const Text('Review'),
                        ),
                        const SizedBox(width: 8),
                        // AC15: "Retry" button — retry Firestore save + navigate on success
                        FilledButton.icon(
                          onPressed: () async {
                            ref
                                .read(onboardingStateProvider.notifier)
                                .clearError();
                            try {
                              await ref
                                  .read(onboardingStateProvider.notifier)
                                  .completeOnboarding();
                              if (context.mounted) {
                                context.go(AppRoutes.dashboard);
                              }
                            } catch (_) {
                              // Error displayed via state.errorMessage
                            }
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Loading indicator
          if (state.isLoading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            Text(
              'Enregistrement en cours…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 28),
        title: Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Nutrition Summary Card ────────────────────────────────────────────────────

class _NutritionSummaryCard extends StatelessWidget {
  final Map<String, dynamic> formData;

  const _NutritionSummaryCard({required this.formData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final physChar =
        formData['physicalCharacteristics'] as Map<String, dynamic>? ?? {};
    final nutritGoals =
        formData['nutritionalGoals'] as Map<String, dynamic>? ?? {};

    final goalId = nutritGoals['selectedGoal'] as String? ?? 'maintenance';
    final goal = NutritionalGoals.findById(goalId);

    final age = physChar['age'];
    final weight = physChar['weight'];
    final height = physChar['height'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Profil nutritionnel',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Goal
            _InfoRow(
              label: 'Objectif',
              value: goal.title,
            ),

            // Physical data (if available)
            if (age != null) _InfoRow(label: 'Âge', value: '$age ans'),
            if (weight != null) _InfoRow(label: 'Poids', value: '$weight kg'),
            if (height != null)
              _InfoRow(label: 'Taille', value: '$height cm'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
