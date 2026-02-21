import 'package:flutter/material.dart';

/// Recipes List Screen - Story 0.5 Placeholder
/// Full implementation: Epic 6
class RecipesListScreen extends StatelessWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recettes')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Recipes Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Story 0.5 Placeholder'),
            SizedBox(height: 8),
            Text('Full implementation: Epic 6'),
          ],
        ),
      ),
    );
  }
}
