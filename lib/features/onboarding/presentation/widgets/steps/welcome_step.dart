import 'package:flutter/material.dart';

/// Step 1: Welcome Screen — AC2
///
/// Shows app logo, headline, 4 key benefits, and "Get Started" button.
/// The Get Started button is handled by the parent OnboardingScreen via onNext.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // App logo / illustration
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.kitchen,
                size: 52,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Headline
          Semantics(
            header: true,
            child: Text(
              'Bienvenue sur FrigoFute',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Gérez votre alimentation intelligemment et réduisez le gaspillage',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Benefits list
          ..._benefits.map((b) => _BenefitRow(benefit: b)),
        ],
      ),
    );
  }
}

const _benefits = [
  _Benefit(
    icon: Icons.savings,
    title: 'Économisez de l\'argent',
    description: 'Réduisez vos dépenses alimentaires jusqu\'à 30%',
    color: Colors.green,
  ),
  _Benefit(
    icon: Icons.eco,
    title: 'Aidez la planète',
    description: 'Diminuez votre empreinte carbone alimentaire',
    color: Colors.teal,
  ),
  _Benefit(
    icon: Icons.monitor_weight,
    title: 'Suivez votre nutrition',
    description: 'Atteignez vos objectifs santé personnalisés',
    color: Colors.orange,
  ),
  _Benefit(
    icon: Icons.restaurant_menu,
    title: 'Suggestions de recettes',
    description: 'Cuisinez avec ce que vous avez déjà',
    color: Colors.purple,
  ),
];

class _Benefit {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _Benefit({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _BenefitRow extends StatelessWidget {
  final _Benefit benefit;

  const _BenefitRow({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: benefit.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(benefit.icon, color: benefit.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  benefit.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
