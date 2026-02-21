import 'package:flutter/material.dart';

/// Dashboard Screen - Story 0.5 Placeholder
/// Full implementation: Epic 4
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Dashboard Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Story 0.5 Placeholder'),
            SizedBox(height: 8),
            Text('Full implementation: Epic 4'),
          ],
        ),
      ),
    );
  }
}
