import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/nutritional_goal.dart';
import '../../providers/onboarding_providers.dart';

/// Step 5: Nutritional Goals — AC8 (conditional, nutrition profiles only)
///
/// 12 pre-defined goal cards (single-select). Next disabled until selection.
class NutritionalGoalsStep extends ConsumerWidget {
  const NutritionalGoalsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(
      onboardingStateProvider.select((s) => s.formData),
    );
    final selectedGoal =
        (formData['nutritionalGoals'] as Map<String, dynamic>?)?['selectedGoal']
            as String?;
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Votre objectif nutritionnel',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sélectionnez un objectif pour calculer vos besoins caloriques',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: NutritionalGoals.goals.length,
            itemBuilder: (context, index) {
              final goal = NutritionalGoals.goals[index];
              final isSelected = selectedGoal == goal.id;

              return _GoalCard(
                goal: goal,
                isSelected: isSelected,
                onTap: () {
                  ref.read(onboardingStateProvider.notifier).updateFormField(
                        'nutritionalGoals',
                        {'selectedGoal': goal.id},
                      );
                },
              );
            },
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final NutritionalGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final calorieText = goal.calorieAdjustment == 0
        ? 'Neutre'
        : goal.calorieAdjustment > 0
            ? '+${goal.calorieAdjustment} kcal'
            : '${goal.calorieAdjustment} kcal';

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${goal.title}: ${goal.description}',
      child: Card(
        elevation: isSelected ? 6 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isSelected ? primary : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconForName(goal.iconName),
                  size: 32,
                  color: isSelected ? primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  goal.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? primary : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  calorieText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? primary.withValues(alpha: 0.8)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(Icons.check_circle, color: primary, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForName(String name) {
    const map = <String, IconData>{
      'trending_down': Icons.trending_down,
      'balance': Icons.balance,
      'fitness_center': Icons.fitness_center,
      'sports': Icons.sports,
      'directions_run': Icons.directions_run,
      'favorite': Icons.favorite,
      'monitor_heart': Icons.monitor_heart,
      'medical_information': Icons.medical_information,
      'no_food': Icons.no_food,
      'local_fire_department': Icons.local_fire_department,
      'energy_savings_leaf': Icons.energy_savings_leaf,
      'egg': Icons.egg,
    };
    return map[name] ?? Icons.star;
  }
}
