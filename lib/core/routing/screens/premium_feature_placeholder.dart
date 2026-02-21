import 'package:flutter/material.dart';

/// Generic Premium Feature Placeholder Screen
/// Used for all premium features in Story 0.5
class PremiumFeaturePlaceholder extends StatelessWidget {
  final String featureName;
  final IconData icon;
  final String epic;

  const PremiumFeaturePlaceholder({
    required this.featureName,
    required this.icon,
    required this.epic,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Colors.amber),
            onPressed: () {},
            tooltip: 'Premium Feature',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              featureName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.workspace_premium, size: 16, color: Colors.amber),
                SizedBox(width: 4),
                Text('PREMIUM', style: TextStyle(color: Colors.amber)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Story 0.5 Placeholder'),
            const SizedBox(height: 8),
            Text('Full implementation: $epic'),
          ],
        ),
      ),
    );
  }
}

// Specific premium screens

class NutritionTrackingScreen extends StatelessWidget {
  const NutritionTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumFeaturePlaceholder(
      featureName: 'Suivi Nutrition',
      icon: Icons.restaurant_menu,
      epic: 'Epic 7',
    );
  }
}

class NutritionProfilesScreen extends StatelessWidget {
  const NutritionProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumFeaturePlaceholder(
      featureName: 'Profils Nutritionnels',
      icon: Icons.person,
      epic: 'Epic 8',
    );
  }
}

class MealPlanningScreen extends StatelessWidget {
  const MealPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumFeaturePlaceholder(
      featureName: 'Planification Repas',
      icon: Icons.calendar_today,
      epic: 'Epic 9',
    );
  }
}

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumFeaturePlaceholder(
      featureName: 'Coach IA',
      icon: Icons.smart_toy,
      epic: 'Epic 11',
    );
  }
}

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumFeaturePlaceholder(
      featureName: 'Achievements',
      icon: Icons.emoji_events,
      epic: 'Epic 13',
    );
  }
}

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumFeaturePlaceholder(
      featureName: 'Liste de Courses',
      icon: Icons.shopping_cart,
      epic: 'Epic 10',
    );
  }
}

class FamilySharingScreen extends StatelessWidget {
  const FamilySharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumFeaturePlaceholder(
      featureName: 'Partage Famille',
      icon: Icons.family_restroom,
      epic: 'Epic 14',
    );
  }
}

class PriceComparatorScreen extends StatelessWidget {
  const PriceComparatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumFeaturePlaceholder(
      featureName: 'Comparateur Prix',
      icon: Icons.compare_arrows,
      epic: 'Epic 12',
    );
  }
}
