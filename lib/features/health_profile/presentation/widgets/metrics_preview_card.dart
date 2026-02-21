import 'package:flutter/material.dart';

/// MetricsPreviewCard
///
/// Story 1.6: AC3 — Real-time metrics preview during profile edit.
///
/// Displays BMR and TDEE before/after with color-coded delta (+/-).
class MetricsPreviewCard extends StatelessWidget {
  final double originalBmr;
  final double newBmr;
  final double originalTdee;
  final double newTdee;

  const MetricsPreviewCard({
    super.key,
    required this.originalBmr,
    required this.newBmr,
    required this.originalTdee,
    required this.newTdee,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu des métriques',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'BMR',
              tooltip: 'Métabolisme de base',
              original: originalBmr,
              updated: newBmr,
            ),
            const SizedBox(height: 8),
            _MetricRow(
              label: 'TDEE',
              tooltip: 'Dépense énergétique totale',
              original: originalTdee,
              updated: newTdee,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String tooltip;
  final double original;
  final double updated;

  const _MetricRow({
    required this.label,
    required this.tooltip,
    required this.original,
    required this.updated,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final delta = updated - original;
    final isIncrease = delta > 0;
    final deltaColor = isIncrease ? Colors.orange : Colors.green;
    final deltaSign = isIncrease ? '+' : '';

    return Row(
      children: [
        Tooltip(
          message: tooltip,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Text(
          '${original.round()} kcal',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, size: 14),
        const SizedBox(width: 8),
        Text(
          '${updated.round()} kcal',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (delta.abs() > 0.5) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: deltaColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$deltaSign${delta.round()} kcal',
              style: textTheme.labelSmall?.copyWith(
                color: deltaColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
