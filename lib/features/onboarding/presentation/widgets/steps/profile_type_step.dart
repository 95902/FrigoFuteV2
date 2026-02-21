import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/profile_type.dart';
import '../../providers/onboarding_providers.dart';

/// Step 2: Profile Type Selection — AC3, AC13
///
/// 4 profile type cards (single-select). Next button disabled until selection.
/// Switching from nutrition back to waste shows confirmation dialog (AC13).
class ProfileTypeStep extends ConsumerWidget {
  const ProfileTypeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(
      onboardingStateProvider.select((s) => s.formData),
    );
    final selectedId = formData['profileType'] as String?;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Quel est votre objectif principal ?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez pour personnaliser votre expérience',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          ...ProfileType.values.map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProfileTypeCard(
                  type: type,
                  isSelected: selectedId == type.id,
                  onTap: () => _onTypeTap(context, ref, type, selectedId),
                ),
              )),
        ],
      ),
    );
  }

  void _onTypeTap(
    BuildContext context,
    WidgetRef ref,
    ProfileType newType,
    String? currentId,
  ) {
    final notifier = ref.read(onboardingStateProvider.notifier);

    // If switching from a nutrition profile to a non-nutrition one → confirm (AC13)
    final wasNutrition = currentId != null &&
        currentId != 'waste' &&
        newType == ProfileType.waste;

    if (wasNutrition) {
      _showChangeConfirmation(context, ref, newType);
    } else {
      notifier.setProfileType(newType.id);
    }
  }

  void _showChangeConfirmation(
    BuildContext context,
    WidgetRef ref,
    ProfileType newType,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Changer de profil ?'),
        content: Text(
          'Passer à "${newType.title}" effacera vos informations nutritionnelles. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(onboardingStateProvider.notifier).setProfileType(newType.id);
            },
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }
}

/// Profile type card widget — AC3
class ProfileTypeCard extends StatelessWidget {
  final ProfileType type;
  final bool isSelected;
  final VoidCallback onTap;

  const ProfileTypeCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${type.title}: ${type.description}',
      child: Card(
        elevation: isSelected ? 6 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? primary : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primary.withValues(alpha: 0.12)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type.icon,
                    size: 28,
                    color: isSelected ? primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? primary : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        type.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Icon(Icons.check_circle, color: primary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
