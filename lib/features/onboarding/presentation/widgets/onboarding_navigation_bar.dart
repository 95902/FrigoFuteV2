import 'package:flutter/material.dart';

/// Bottom navigation bar for the onboarding flow
/// Story 1.5 — AC11: Back Navigation, AC10: Next button enabled state
class OnboardingNavigationBar extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool isNextEnabled;
  final bool showBack;
  final String nextLabel;

  const OnboardingNavigationBar({
    super.key,
    this.onNext,
    this.onBack,
    this.isNextEnabled = true,
    this.showBack = true,
    this.nextLabel = 'Suivant',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Back button
            if (showBack)
              Semantics(
                label: 'Étape précédente',
                button: true,
                child: TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),

            const Spacer(),

            // Next / Complete button
            Semantics(
              label: isNextEnabled ? nextLabel : '$nextLabel (désactivé)',
              button: true,
              child: FilledButton(
                onPressed: isNextEnabled ? onNext : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(nextLabel),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
