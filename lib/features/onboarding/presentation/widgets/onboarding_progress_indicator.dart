import 'package:flutter/material.dart';

/// Linear progress bar + dot indicators for the onboarding flow
/// Story 1.5 — AC10: Progress Indicator Updates Dynamically
class OnboardingProgressIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalPages > 0 ? (currentPage + 1) / totalPages : 0.0;

    return Semantics(
      label: 'Étape ${currentPage + 1} sur $totalPages',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step text
            Text(
              'Étape ${currentPage + 1} sur $totalPages',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Linear progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (index) {
                final isActive = index == currentPage;
                final isCompleted = index < currentPage;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isCompleted
                          ? Colors.green
                          : isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
