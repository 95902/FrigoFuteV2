import 'package:flutter/material.dart';

/// Meal Plan Details Screen
/// Story 0.5: Nested route /meal-planning/details/:planId (PREMIUM)
class MealPlanDetailsScreen extends StatelessWidget {
  final String planId;

  const MealPlanDetailsScreen({
    required this.planId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Plan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Plan ID: $planId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Chip(
              label: Text('PREMIUM'),
              backgroundColor: Colors.amber,
            ),
            const SizedBox(height: 8),
            Text(
              'Placeholder - Full implementation in Epic 9',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
