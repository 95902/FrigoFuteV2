/// HealthCalculations - Utilitaire de calculs nutritionnels
///
/// Story 1.6: Configure Personal Profile with Physical Characteristics
///
/// Implements Mifflin-St Jeor equations for BMR/TDEE calculations.
/// These are validated clinical formulas, not medical advice.
class HealthCalculations {
  HealthCalculations._();

  // ─── BMR ──────────────────────────────────────────────────────────────────

  /// Calculate BMR using Mifflin-St Jeor Equation (most accurate for modern populations)
  ///
  /// Male:   BMR = (10 × weight kg) + (6.25 × height cm) - (5 × age) + 5
  /// Female: BMR = (10 × weight kg) + (6.25 × height cm) - (5 × age) - 161
  /// Other:  Uses average constant -78 (midpoint between +5 and -161)
  ///
  /// Returns value clamped between 800 and 5000 kcal/day (sanity bounds).
  static double calculateBMR({
    required int ageYears,
    required double heightCm,
    required double weightKg,
    required String gender,
  }) {
    final double s;
    switch (gender.toLowerCase()) {
      case 'male':
        s = 5.0;
      case 'female':
        s = -161.0;
      default:
        s = -78.0; // average for 'other' / 'prefer_not_to_say'
    }
    final bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears) + s;
    return bmr.clamp(800, 5000);
  }

  // ─── TDEE ─────────────────────────────────────────────────────────────────

  /// Activity level multipliers for TDEE = BMR × multiplier
  static const Map<String, double> _activityMultipliers = {
    'sedentary': 1.2,    // Little or no exercise
    'light': 1.375,      // 1-3 days/week
    'moderate': 1.55,    // 3-5 days/week
    'active': 1.725,     // 6-7 days/week
    'veryactive': 1.9,   // Intense exercise + physical job
  };

  static double getActivityMultiplier(String activityLevel) {
    return _activityMultipliers[activityLevel.toLowerCase()] ?? 1.55;
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE(double bmr, String activityLevel) {
    return bmr * getActivityMultiplier(activityLevel);
  }

  // ─── Macro Targets ────────────────────────────────────────────────────────

  /// Calculate macro targets (g/day) from TDEE and nutritional goal.
  ///
  /// Macro ratios:
  ///   weight_loss:   protein 35%, carbs 45%, fats 20%  (−15% calorie deficit)
  ///   muscle_gain:   protein 30%, carbs 50%, fats 20%  (+10% calorie surplus)
  ///   default:       protein 25%, carbs 50%, fats 25%  (maintenance)
  ///
  /// Caloric values: protein 4 kcal/g, carbs 4 kcal/g, fats 9 kcal/g
  static Map<String, double> calculateMacroTargets({
    required double tdee,
    required String nutritionalGoal,
    required double weightKg,
  }) {
    final double adjustedCalories;
    final Map<String, double> ratios;

    switch (nutritionalGoal) {
      case 'weight_loss':
        adjustedCalories = tdee * 0.85;
        ratios = {'protein': 0.35, 'carbs': 0.45, 'fats': 0.20};
      case 'muscle_gain':
        adjustedCalories = tdee * 1.10;
        ratios = {'protein': 0.30, 'carbs': 0.50, 'fats': 0.20};
      default:
        adjustedCalories = tdee;
        ratios = {'protein': 0.25, 'carbs': 0.50, 'fats': 0.25};
    }

    return {
      'calories': adjustedCalories.roundToDouble(),
      'protein': ((adjustedCalories * ratios['protein']!) / 4).roundToDouble(),
      'carbs': ((adjustedCalories * ratios['carbs']!) / 4).roundToDouble(),
      'fats': ((adjustedCalories * ratios['fats']!) / 9).roundToDouble(),
    };
  }

  // ─── Weight Change Rate ────────────────────────────────────────────────────

  /// Calculate weekly weight change rate from a list of (date, weight) pairs.
  ///
  /// Returns kg/week. Positive = weight gain, negative = weight loss.
  /// Returns 0.0 if fewer than 2 entries or span < 1 day.
  static double calculateWeightChangeRate(
    List<({DateTime date, double weight})> history,
  ) {
    if (history.length < 2) return 0.0;

    final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
    final weightChange = sorted.last.weight - sorted.first.weight;
    final days = sorted.last.date.difference(sorted.first.date).inDays;

    if (days < 1) return 0.0;
    return weightChange / (days / 7);
  }
}
