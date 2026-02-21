import 'package:flutter/material.dart';

import '../widgets/weight_chart_widget.dart';

/// WeightTrackingScreen
///
/// Story 1.6: AC10, AC11, AC12 — Full weight tracking view with chart.
class WeightTrackingScreen extends StatelessWidget {
  const WeightTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi du poids'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: WeightChartWidget(),
      ),
    );
  }
}
