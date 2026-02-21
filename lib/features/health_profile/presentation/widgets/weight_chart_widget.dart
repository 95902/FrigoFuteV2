import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/storage/models/weight_history_entry.dart';
import '../providers/health_profile_providers.dart';

/// WeightChartWidget
///
/// Story 1.6: AC10, AC11, AC12 — Weight tracking chart with period selector.
///
/// Shows line chart with 30/90/365-day toggle, statistics, and weekly change rate.
class WeightChartWidget extends ConsumerStatefulWidget {
  const WeightChartWidget({super.key});

  @override
  ConsumerState<WeightChartWidget> createState() => _WeightChartWidgetState();
}

class _WeightChartWidgetState extends ConsumerState<WeightChartWidget> {
  int _selectedDays = 30;

  static const _periods = [
    (label: '30 j', days: 30),
    (label: '90 j', days: 90),
    (label: '1 an', days: 365),
  ];

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(weightHistoryProvider(_selectedDays));
    final rateAsync = ref.watch(weightChangeRateProvider(_selectedDays));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PeriodSelector(
          selectedDays: _selectedDays,
          periods: _periods,
          onSelect: (days) => setState(() => _selectedDays = days),
        ),
        const SizedBox(height: 16),
        historyAsync.when(
          data: (history) => _buildChart(context, history),
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Erreur: $e'),
        ),
        const SizedBox(height: 16),
        historyAsync.when(
          data: (history) => _buildStats(context, history),
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        rateAsync.when(
          data: (rate) => _buildRateBadge(context, rate),
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, List<WeightHistoryEntry> history) {
    if (history.length < 2) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez au moins 2 pesées\npour afficher le graphique',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final weights = history.map((e) => e.weight).toList();
    final minY = (weights.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
    final maxY = (weights.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();

    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: colorScheme.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                show: history.length <= 10,
                getDotPainter: (spot, pct, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: colorScheme.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: colorScheme.primary.withAlpha(25),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colorScheme.outlineVariant,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (val, _) => Text(
                  '${val.round()}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: _bottomInterval(history.length),
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= history.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    DateFormat('dd/MM').format(history[idx].date),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _bottomInterval(int count) {
    if (count <= 5) return 1;
    if (count <= 10) return 2;
    if (count <= 30) return 5;
    return 10;
  }

  Widget _buildStats(BuildContext context, List<WeightHistoryEntry> history) {
    if (history.isEmpty) return const SizedBox.shrink();

    final first = history.first.weight;
    final last = history.last.weight;
    final diff = last - first;
    final sign = diff >= 0 ? '+' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          label: 'Poids initial',
          value: '${first.toStringAsFixed(1)} kg',
        ),
        _StatItem(
          label: 'Poids actuel',
          value: '${last.toStringAsFixed(1)} kg',
        ),
        _StatItem(
          label: 'Changement',
          value: '$sign${diff.toStringAsFixed(1)} kg',
          valueColor: diff < 0 ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRateBadge(BuildContext context, double rateKgPerWeek) {
    if (rateKgPerWeek == 0) return const SizedBox.shrink();

    final isLoss = rateKgPerWeek < 0;
    final color = isLoss ? Colors.green : Colors.orange;
    final sign = rateKgPerWeek >= 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        'Tendance: $sign${rateKgPerWeek.toStringAsFixed(2)} kg/semaine',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int selectedDays;
  final List<({String label, int days})> periods;
  final void Function(int) onSelect;

  const _PeriodSelector({
    required this.selectedDays,
    required this.periods,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SegmentedButton<int>(
      segments: periods
          .map((p) => ButtonSegment(value: p.days, label: Text(p.label)))
          .toList(),
      selected: {selectedDays},
      onSelectionChanged: (s) => onSelect(s.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: colorScheme.primaryContainer,
        selectedForegroundColor: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
