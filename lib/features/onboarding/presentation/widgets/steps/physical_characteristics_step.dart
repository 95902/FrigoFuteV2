import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/onboarding_providers.dart';

/// Step 3: Physical Characteristics — AC6 (conditional, nutrition profiles only)
///
/// Fields: Age, Gender, Height, Weight, Activity Level
/// All required. Next disabled until all valid.
class PhysicalCharacteristicsStep extends ConsumerStatefulWidget {
  const PhysicalCharacteristicsStep({super.key});

  @override
  ConsumerState<PhysicalCharacteristicsStep> createState() =>
      _PhysicalCharacteristicsStepState();
}

class _PhysicalCharacteristicsStepState
    extends ConsumerState<PhysicalCharacteristicsStep> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _gender;
  String? _activityLevel;

  final _activityOptions = const [
    ('sedentary', 'Sédentaire (peu ou pas d\'exercice)'),
    ('light', 'Léger (1–3 jours/semaine)'),
    ('moderate', 'Modéré (3–5 jours/semaine)'),
    ('active', 'Actif (6–7 jours/semaine)'),
    ('very_active', 'Très actif (entraînement intensif)'),
  ];

  @override
  void initState() {
    super.initState();
    // Restore previously entered values
    final formData = ref.read(onboardingStateProvider).formData;
    final physChar = formData['physicalCharacteristics'] as Map<String, dynamic>? ?? {};
    if (physChar['age'] != null) {
      _ageController.text = physChar['age'].toString();
    }
    if (physChar['height'] != null) {
      _heightController.text = physChar['height'].toString();
    }
    if (physChar['weight'] != null) {
      _weightController.text = physChar['weight'].toString();
    }
    _gender = physChar['gender'] as String?;
    _activityLevel = physChar['activityLevel'] as String?;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    final data = {
      'age': int.tryParse(_ageController.text) ?? 0,
      'gender': _gender ?? '',
      'height': int.tryParse(_heightController.text) ?? 0,
      'weight': double.tryParse(_weightController.text) ?? 0.0,
      'activityLevel': _activityLevel ?? '',
    };
    ref.read(onboardingStateProvider.notifier).updateFormField(
          'physicalCharacteristics',
          data,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Vos caractéristiques physiques',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour calculer vos besoins nutritionnels personnalisés',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Age
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Âge *',
                hintText: '25',
                suffixText: 'ans',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
              validator: (v) {
                final age = int.tryParse(v ?? '');
                if (age == null || age < 13 || age > 120) {
                  return 'Âge invalide (13–120 ans)';
                }
                return null;
              },
              onChanged: (_) => _save(),
            ),
            const SizedBox(height: 16),

            // Gender
            Semantics(
              label: 'Genre',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Genre *',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final (value, label) in const [
                        ('male', 'Homme'),
                        ('female', 'Femme'),
                        ('other', 'Autre'),
                        ('prefer_not', 'Non précisé'),
                      ])
                        ChoiceChip(
                          label: Text(label),
                          selected: _gender == value,
                          onSelected: (_) {
                            setState(() => _gender = value);
                            _save();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Height
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Taille *',
                hintText: '170',
                suffixText: 'cm',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
              validator: (v) {
                final h = int.tryParse(v ?? '');
                if (h == null || h < 100 || h > 250) {
                  return 'Taille invalide (100–250 cm)';
                }
                return null;
              },
              onChanged: (_) => _save(),
            ),
            const SizedBox(height: 16),

            // Weight
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Poids *',
                hintText: '70',
                suffixText: 'kg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              validator: (v) {
                final w = double.tryParse(v?.replaceAll(',', '.') ?? '');
                if (w == null || w < 20 || w > 500) {
                  return 'Poids invalide (20–500 kg)';
                }
                return null;
              },
              onChanged: (_) => _save(),
            ),
            const SizedBox(height: 16),

            // Activity Level
            DropdownButtonFormField<String>(
              value: _activityLevel,
              decoration: const InputDecoration(
                labelText: 'Niveau d\'activité *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_run),
              ),
              items: _activityOptions
                  .map((opt) => DropdownMenuItem(
                        value: opt.$1,
                        child: Text(opt.$2, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() => _activityLevel = v);
                _save();
              },
              validator: (v) =>
                  v == null ? 'Sélectionnez votre niveau d\'activité' : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
