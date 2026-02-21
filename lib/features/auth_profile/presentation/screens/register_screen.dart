import 'package:flutter/material.dart';

/// Register Screen - Story 0.5 Placeholder
/// Full implementation: Epic 1 - Story 1.1
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Register Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Story 0.5 Placeholder'),
            SizedBox(height: 8),
            Text('Full implementation: Story 1.1'),
          ],
        ),
      ),
    );
  }
}
