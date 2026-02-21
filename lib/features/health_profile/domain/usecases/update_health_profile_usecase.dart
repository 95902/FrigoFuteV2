import '../../../../core/shared/utils/health_calculations.dart';
import '../../../../core/storage/models/health_profile_model.dart';
import '../../../../core/storage/models/weight_history_entry.dart';
import '../repositories/health_profile_repository.dart';

/// Validation exception for health profile input
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => message;
}

/// UpdateHealthProfileUseCase
///
/// Story 1.6: AC2, AC7, AC8
///
/// Validates input, recalculates BMR/TDEE/macros using Mifflin-St Jeor,
/// creates weight history entry if weight changed, then delegates to repository.
class UpdateHealthProfileUseCase {
  final HealthProfileRepository _repository;

  UpdateHealthProfileUseCase(this._repository);

  Future<HealthProfileModel> call({
    required HealthProfileModel currentProfile,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String activityLevel,
  }) async {
    _validateInput(age, height, weight);

    final newBmr = HealthCalculations.calculateBMR(
      ageYears: age,
      heightCm: height,
      weightKg: weight,
      gender: gender,
    );

    final newTdee = HealthCalculations.calculateTDEE(newBmr, activityLevel);

    final newMacros = HealthCalculations.calculateMacroTargets(
      tdee: newTdee,
      nutritionalGoal: currentProfile.profileType,
      weightKg: weight,
    );

    final updatedProfile = currentProfile.copyWith(
      age: age,
      gender: gender,
      height: height,
      currentWeight: weight,
      activityLevel: activityLevel,
      bmr: newBmr,
      tdee: newTdee,
      macroTargets: newMacros,
      lastUpdated: DateTime.now(),
    );

    if (weight != currentProfile.currentWeight) {
      final weightEntry = WeightHistoryEntry(
        date: DateTime.now(),
        weight: weight,
      );
      final profileWithHistory = updatedProfile.addWeightEntry(weightEntry);
      await _repository.updateProfile(profileWithHistory);
      return profileWithHistory;
    }

    await _repository.updateProfile(updatedProfile);
    return updatedProfile;
  }

  void _validateInput(int age, double height, double weight) {
    if (age < 13 || age > 120) {
      throw const ValidationException('L\'âge doit être entre 13 et 120 ans');
    }
    if (height < 100 || height > 250) {
      throw const ValidationException('La taille doit être entre 100 et 250 cm');
    }
    if (weight < 20 || weight > 500) {
      throw const ValidationException('Le poids doit être entre 20 et 500 kg');
    }
  }
}
