import 'package:flutter/material.dart';

/// Onboarding Screen - Story 0.5 Placeholder
/// Full implementation: Epic 1 - Story 1.5
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenue')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.waving_hand, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Onboarding Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Story 0.5 Placeholder'),
            SizedBox(height: 8),
            Text('Full implementation: Story 1.5'),
          ],
        ),
      ),
    );
  }
}
