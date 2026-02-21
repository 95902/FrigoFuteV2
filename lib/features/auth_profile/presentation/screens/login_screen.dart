import 'package:flutter/material.dart';

/// Login Screen - Story 0.5 Placeholder
/// Full implementation: Epic 1 - Story 1.2
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Login Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Story 0.5 Placeholder'),
            SizedBox(height: 8),
            Text('Full implementation: Story 1.2'),
          ],
        ),
      ),
    );
  }
}
