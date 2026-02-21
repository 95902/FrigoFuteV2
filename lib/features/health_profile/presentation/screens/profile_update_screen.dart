import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/shared/utils/health_calculations.dart';
import '../../../../core/storage/models/health_profile_model.dart';
import '../providers/health_profile_providers.dart';
import '../widgets/metrics_preview_card.dart';

/// ProfileUpdateScreen
///
/// Story 1.6: AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC9, AC13, AC18
///
/// Allows users to update physical characteristics (age, gender, height,
/// weight, activity level) with real-time metrics preview and warning dialogs.
class ProfileUpdateScreen extends ConsumerStatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  ConsumerState<ProfileUpdateScreen> createState() =>
      _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends ConsumerState<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  String _selectedGender = 'other';
  String _selectedActivityLevel = 'moderate';
  bool _isLoading = false;
  bool _initialized = false;

  // Snapshot of original values for change detection and warnings
  int _originalAge = 0;
  double _originalHeight = 0;
  double _originalWeight = 0;
  String _originalGender = 'other';
  String _originalActivityLevel = 'moderate';

  // Throttle height warning to avoid re-triggering on every keystroke
  bool _heightWarningShown = false;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  void _initFromProfile(HealthProfileModel profile) {
    if (_initialized) return;
    _initialized = true;
    _ageController.text = profile.age > 0 ? profile.age.toString() : '';
    _heightController.text = profile.height > 0
        ? profile.height.toStringAsFixed(1)
        : '';
    _weightController.text = profile.currentWeight > 0
        ? profile.currentWeight.toStringAsFixed(1)
        : '';
    _selectedGender = profile.gender.isNotEmpty ? profile.gender : 'other';
    _selectedActivityLevel = profile.activityLevel.isNotEmpty
        ? profile.activityLevel
        : 'moderate';
    _originalAge = profile.age;
    _originalHeight = profile.height;
    _originalWeight = profile.currentWeight;
    _originalGender = profile.gender;
    _originalActivityLevel = profile.activityLevel;
  }

  // ─── Change detection ──────────────────────────────────────────────────────

  bool _hasChanges() {
    final age = int.tryParse(_ageController.text) ?? _originalAge;
    final height = double.tryParse(_heightController.text) ?? _originalHeight;
    final weight = double.tryParse(_weightController.text) ?? _originalWeight;
    return age != _originalAge ||
        height != _originalHeight ||
        weight != _originalWeight ||
        _selectedGender != _originalGender ||
        _selectedActivityLevel != _originalActivityLevel;
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  Future<void> _handleBack() async {
    if (!_hasChanges()) {
      if (mounted) context.pop();
      return;
    }
    final discard = await _showDiscardDialog();
    if (discard && mounted) context.pop();
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _handleSave(HealthProfileModel currentProfile) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final age = int.parse(_ageController.text);
    final height = double.parse(_heightController.text);
    final weight = double.parse(_weightController.text);

    // AC5: Weight change warning (> 5 kg difference)
    final weightDiff = (weight - _originalWeight).abs();
    if (_originalWeight > 0 && weightDiff > 5) {
      final confirmed = await _showWeightChangeWarning(weightDiff);
      if (!confirmed) return;
    }

    setState(() => _isLoading = true);
    try {
      final useCase = ref.read(updateHealthProfileUseCaseProvider);
      await useCase(
        currentProfile: currentProfile,
        age: age,
        gender: _selectedGender,
        height: height,
        weight: weight,
        activityLevel: _selectedActivityLevel,
      );

      ref.invalidate(currentHealthProfileProvider);
      ref.invalidate(bmrProvider);
      ref.invalidate(tdeeProvider);
      ref.invalidate(macroTargetsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentHealthProfileProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Modifier mon profil'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleBack,
          ),
        ),
        body: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return _buildNoProfileView();
            }
            if (profile.profileType == 'waste') {
              return _buildWasteProfileBlockedView();
            }
            _initFromProfile(profile);
            return _buildForm(profile);
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text('Erreur: $e')),
        ),
      ),
    );
  }

  // ─── AC13: Waste profile blocked ──────────────────────────────────────────

  Widget _buildWasteProfileBlockedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Profil non configuré',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Vous devez d\'abord compléter votre profil nutritionnel via l\'onboarding',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(AppRoutes.onboarding),
              child: const Text('Commencer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProfileView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text('Aucun profil trouvé'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(AppRoutes.onboarding),
              child: const Text('Créer mon profil'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Main form ────────────────────────────────────────────────────────────

  Widget _buildForm(HealthProfileModel profile) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Age
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Âge',
                suffixText: 'ans',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final age = int.tryParse(v ?? '');
                if (age == null) return 'Âge requis';
                if (age < 13 || age > 120) return 'Entre 13 et 120 ans';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Genre',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Homme')),
                DropdownMenuItem(value: 'female', child: Text('Femme')),
                DropdownMenuItem(value: 'other', child: Text('Autre / Non précisé')),
              ],
              onChanged: (value) async {
                if (value == null) return;
                // AC6: Show gender change info dialog
                if (value != _originalGender) {
                  await _showGenderChangeInfo();
                }
                setState(() => _selectedGender = value);
              },
              validator: (v) => v == null ? 'Genre requis' : null,
            ),
            const SizedBox(height: 16),

            // Height
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Taille',
                suffixText: 'cm',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                setState(() {});
                _checkHeightWarning(v);
              },
              validator: (v) {
                final h = double.tryParse(v ?? '');
                if (h == null) return 'Taille requise';
                if (h < 100 || h > 250) return 'Entre 100 et 250 cm';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Weight
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Poids',
                suffixText: 'kg',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final w = double.tryParse(v ?? '');
                if (w == null) return 'Poids requis';
                if (w < 20 || w > 500) return 'Entre 20 et 500 kg';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Activity Level
            DropdownButtonFormField<String>(
              value: _selectedActivityLevel,
              decoration: const InputDecoration(
                labelText: 'Niveau d\'activité',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'sedentary',
                  child: Text('Sédentaire (peu ou pas d\'exercice)'),
                ),
                DropdownMenuItem(
                  value: 'light',
                  child: Text('Légèrement actif (1-3 jours/semaine)'),
                ),
                DropdownMenuItem(
                  value: 'moderate',
                  child: Text('Modérément actif (3-5 jours/semaine)'),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Actif (6-7 jours/semaine)'),
                ),
                DropdownMenuItem(
                  value: 'veryActive',
                  child: Text('Très actif (intensif quotidien)'),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedActivityLevel = v);
              },
              validator: (v) => v == null ? 'Niveau d\'activité requis' : null,
            ),
            const SizedBox(height: 24),

            // AC3: Real-time metrics preview
            _buildMetricsPreview(profile),

            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _isLoading ? null : () => _handleSave(profile),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AC3: Metrics preview ─────────────────────────────────────────────────

  Widget _buildMetricsPreview(HealthProfileModel profile) {
    final age = int.tryParse(_ageController.text);
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (age == null || height == null || weight == null) {
      return const SizedBox.shrink();
    }
    if (age < 13 || age > 120 || height < 100 || weight < 20) {
      return const SizedBox.shrink();
    }

    final newBmr = HealthCalculations.calculateBMR(
      ageYears: age,
      heightCm: height,
      weightKg: weight,
      gender: _selectedGender,
    );
    final newTdee =
        HealthCalculations.calculateTDEE(newBmr, _selectedActivityLevel);

    final origBmr = profile.bmr > 0
        ? profile.bmr
        : HealthCalculations.calculateBMR(
            ageYears: _originalAge,
            heightCm: _originalHeight,
            weightKg: _originalWeight,
            gender: _originalGender,
          );
    final origTdee = profile.tdee > 0
        ? profile.tdee
        : HealthCalculations.calculateTDEE(origBmr, _originalActivityLevel);

    return MetricsPreviewCard(
      originalBmr: origBmr,
      newBmr: newBmr,
      originalTdee: origTdee,
      newTdee: newTdee,
    );
  }

  // ─── AC4: Height warning ──────────────────────────────────────────────────

  void _checkHeightWarning(String value) {
    if (_heightWarningShown) return;
    final newHeight = double.tryParse(value);
    if (newHeight == null || _originalHeight <= 0) return;
    if ((newHeight - _originalHeight).abs() > 5) {
      _heightWarningShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _showHeightChangeWarning(newHeight);
        // Reset so dialog can re-appear if user changes to a different large value
        _heightWarningShown = false;
      });
    }
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Abandonner les modifications?'),
            content: const Text(
              'Les modifications non enregistrées seront perdues.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Continuer l\'édition'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Abandonner'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showWeightChangeWarning(double diff) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Changement de poids important'),
            content: Text(
              'Changement de ${diff.toStringAsFixed(1)} kg détecté. '
              'Voulez-vous confirmer cette modification?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirmer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showHeightChangeWarning(double newHeight) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Changement de taille détecté'),
        content: Text(
          'Vous avez indiqué un changement de '
          '${(newHeight - _originalHeight).abs().toStringAsFixed(1)} cm. '
          'Êtes-vous sûr de cette modification?',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Future<void> _showGenderChangeInfo() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Impact du changement'),
        content: const Text(
          'Modifier votre genre va recalculer votre BMR car la formule '
          'est différente selon le sexe. Les objectifs nutritionnels '
          'seront automatiquement mis à jour.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}
