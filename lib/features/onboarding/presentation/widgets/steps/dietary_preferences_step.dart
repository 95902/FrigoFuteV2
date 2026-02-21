import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/onboarding_providers.dart';

/// Step 4: Dietary Preferences — AC7 (conditional, nutrition profiles only)
///
/// Multi-select chips for dietary restrictions + free text for allergies.
/// All fields optional. Next always enabled.
class DietaryPreferencesStep extends ConsumerStatefulWidget {
  const DietaryPreferencesStep({super.key});

  @override
  ConsumerState<DietaryPreferencesStep> createState() =>
      _DietaryPreferencesStepState();
}

class _DietaryPreferencesStepState
    extends ConsumerState<DietaryPreferencesStep> {
  final _allergiesController = TextEditingController();
  Set<String> _selectedRestrictions = {};

  static const _restrictions = [
    ('vegetarian', 'Végétarien', Icons.eco),
    ('vegan', 'Vegan', Icons.spa),
    ('gluten_free', 'Sans gluten', Icons.grain),
    ('dairy_free', 'Sans lactose', Icons.no_drinks),
    ('nut_free', 'Sans noix', Icons.park),
    ('halal', 'Halal', Icons.mosque),
    ('kosher', 'Casher', Icons.stars),
    ('low_fodmap', 'Low FODMAP', Icons.medical_services),
  ];

  @override
  void initState() {
    super.initState();
    final formData = ref.read(onboardingStateProvider).formData;
    final pref = formData['dietaryPreferences'] as Map<String, dynamic>? ?? {};
    final restrictions = (pref['restrictions'] as List?)?.cast<String>() ?? [];
    _selectedRestrictions = Set.from(restrictions);
    _allergiesController.text = (pref['allergies'] as List?)?.join(', ') ?? '';
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    super.dispose();
  }

  void _save() {
    final allergiesText = _allergiesController.text.trim();
    final allergies = allergiesText.isEmpty
        ? <String>[]
        : allergiesText.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    ref.read(onboardingStateProvider.notifier).updateFormField(
          'dietaryPreferences',
          {
            'restrictions': _selectedRestrictions.toList(),
            'allergies': allergies,
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Préférences alimentaires',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez vos restrictions (optionnel)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Dietary restriction chips
          Text(
            'Régimes alimentaires',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _restrictions.map((r) {
              final (id, label, icon) = r;
              final selected = _selectedRestrictions.contains(id);

              return Semantics(
                label: '$label, ${selected ? 'sélectionné' : 'non sélectionné'}',
                button: true,
                child: FilterChip(
                  label: Text(label),
                  avatar: Icon(icon, size: 16),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedRestrictions.add(id);
                      } else {
                        _selectedRestrictions.remove(id);
                      }
                    });
                    _save();
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Allergies field
          Text(
            'Allergies (optionnel)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _allergiesController,
            decoration: const InputDecoration(
              hintText: 'ex: arachides, fruits de mer, œufs',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.warning_amber),
              helperText: 'Séparez les allergies par des virgules',
            ),
            maxLines: 2,
            onChanged: (_) => _save(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
