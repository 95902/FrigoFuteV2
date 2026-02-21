import 'package:flutter/material.dart';

/// Recipe Suggestions Screen
/// Story 0.5: Nested route /recipes/suggestions
class RecipeSuggestionsScreen extends StatelessWidget {
  const RecipeSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions de Recettes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Suggestions Basées sur Inventaire',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Placeholder - Full implementation in Epic 6',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
