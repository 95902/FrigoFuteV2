import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../monitoring/analytics_service.dart';

/// Paywall widget for premium features
/// Story 0.8: Configure Feature Flags via Firebase Remote Config
///
/// Displays when user tries to access premium feature without subscription
///
/// Example:
/// ```dart
/// PaywallWidget(
///   featureId: 'meal_planning',
///   featureName: 'Planning Repas IA',
/// )
/// ```
class PaywallWidget extends ConsumerStatefulWidget {
  final String featureId;
  final String featureName;

  const PaywallWidget({
    required this.featureId,
    required this.featureName,
    super.key,
  });

  @override
  ConsumerState<PaywallWidget> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends ConsumerState<PaywallWidget> {
  @override
  void initState() {
    super.initState();

    // Log analytics event when paywall is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(analyticsServiceProvider)
          .logPremiumFeatureAccessed(
            featureName: widget.featureId,
            hasAccess: false,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                '${widget.featureName} est une fonctionnalité Premium',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Débloquez toutes les fonctionnalités premium avec un essai gratuit de 7 jours.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Benefits list
              _buildBenefitsList(context),
              const SizedBox(height: 32),

              // CTA Button - Start Trial
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startTrial(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Essai Gratuit 7 Jours',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secondary Button - View Plans
              TextButton(
                onPressed: () => _viewPlans(context),
                child: const Text('Voir les Plans'),
              ),

              const SizedBox(height: 24),

              // Fine print
              Text(
                'Sans engagement. Annulez à tout moment.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BenefitItem(text: 'Planning repas IA personnalisé'),
        _BenefitItem(text: 'Coach nutrition intelligent'),
        _BenefitItem(text: 'Comparateur prix et optimisation'),
        _BenefitItem(text: 'Gamification et défis'),
        _BenefitItem(text: 'Partage famille et export PDF'),
        _BenefitItem(text: 'Suivi nutrition complet'),
        _BenefitItem(text: 'Liste courses optimisée'),
        _BenefitItem(text: 'Support prioritaire'),
      ],
    );
  }

  Future<void> _startTrial(BuildContext context) async {
    // TODO: Navigate to trial signup flow (Story 15.2)
    // For now, show snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription à l\'essai gratuit (à venir)'),
        ),
      );

      // Log analytics
      await ref
          .read(analyticsServiceProvider)
          .logEvent(
            name: 'trial_button_clicked',
            parameters: {'feature_id': widget.featureId, 'source': 'paywall'},
          );
    }
  }

  void _viewPlans(BuildContext context) {
    // TODO: Navigate to premium plans screen (Story 15.1)
    // For now, show snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Écran des plans premium (à venir)')),
      );
    }
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;

  const _BenefitItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
