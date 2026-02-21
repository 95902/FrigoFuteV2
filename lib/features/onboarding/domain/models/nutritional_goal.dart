/// Pre-defined nutritional goal model
/// Story 1.5: Complete Adaptive Onboarding Flow — AC8
///
/// Plain Dart class (not Freezed) to support const constructor for static list.
class NutritionalGoal {
  final String id;
  final String title;
  final String description;

  /// Daily calorie adjustment relative to TDEE (negative = deficit, positive = surplus)
  final int calorieAdjustment;

  final String iconName;

  /// Grams of protein per kg of body weight
  final double proteinPerKg;

  /// Grams of carbs per kg of body weight
  final double carbsPerKg;

  /// Grams of fat per kg of body weight
  final double fatsPerKg;

  const NutritionalGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.calorieAdjustment,
    required this.iconName,
    this.proteinPerKg = 1.8,
    this.carbsPerKg = 3.0,
    this.fatsPerKg = 0.8,
  });
}

/// Pre-defined 12 nutritional goals — AC8
class NutritionalGoals {
  static const List<NutritionalGoal> goals = [
    NutritionalGoal(
      id: 'weight_loss',
      title: 'Weight Loss',
      description: 'Lose 0.5–1 kg per week safely',
      calorieAdjustment: -500,
      iconName: 'trending_down',
      proteinPerKg: 2.0,
      carbsPerKg: 2.5,
      fatsPerKg: 0.8,
    ),
    NutritionalGoal(
      id: 'maintenance',
      title: 'Maintain Weight',
      description: 'Stay at current weight with balanced nutrition',
      calorieAdjustment: 0,
      iconName: 'balance',
      proteinPerKg: 1.6,
      carbsPerKg: 3.5,
      fatsPerKg: 1.0,
    ),
    NutritionalGoal(
      id: 'muscle_gain',
      title: 'Muscle Gain',
      description: 'Build muscle with protein focus and calorie surplus',
      calorieAdjustment: 300,
      iconName: 'fitness_center',
      proteinPerKg: 2.2,
      carbsPerKg: 4.0,
      fatsPerKg: 1.0,
    ),
    NutritionalGoal(
      id: 'athletic_performance',
      title: 'Athletic Performance',
      description: 'Optimize nutrition for sports and training',
      calorieAdjustment: 200,
      iconName: 'sports',
      proteinPerKg: 1.8,
      carbsPerKg: 5.0,
      fatsPerKg: 0.9,
    ),
    NutritionalGoal(
      id: 'endurance',
      title: 'Endurance Training',
      description: 'Fuel for long-distance and cardio activities',
      calorieAdjustment: 300,
      iconName: 'directions_run',
      proteinPerKg: 1.6,
      carbsPerKg: 6.0,
      fatsPerKg: 0.8,
    ),
    NutritionalGoal(
      id: 'general_health',
      title: 'General Health',
      description: 'Balanced nutrition for overall wellness',
      calorieAdjustment: 0,
      iconName: 'favorite',
      proteinPerKg: 1.6,
      carbsPerKg: 3.5,
      fatsPerKg: 1.0,
    ),
    NutritionalGoal(
      id: 'heart_health',
      title: 'Heart Health',
      description: 'Mediterranean-style diet for cardiovascular health',
      calorieAdjustment: 0,
      iconName: 'monitor_heart',
      proteinPerKg: 1.4,
      carbsPerKg: 3.5,
      fatsPerKg: 1.2,
    ),
    NutritionalGoal(
      id: 'diabetic',
      title: 'Blood Sugar Control',
      description: 'Low glycemic index diet for blood sugar management',
      calorieAdjustment: -200,
      iconName: 'medical_information',
      proteinPerKg: 1.8,
      carbsPerKg: 2.0,
      fatsPerKg: 1.0,
    ),
    NutritionalGoal(
      id: 'low_carb',
      title: 'Low Carb',
      description: 'Reduce carbohydrates for metabolic health',
      calorieAdjustment: -100,
      iconName: 'no_food',
      proteinPerKg: 2.0,
      carbsPerKg: 1.0,
      fatsPerKg: 1.5,
    ),
    NutritionalGoal(
      id: 'keto',
      title: 'Ketogenic',
      description: 'Very low carb, high fat diet for ketosis',
      calorieAdjustment: 0,
      iconName: 'local_fire_department',
      proteinPerKg: 1.8,
      carbsPerKg: 0.3,
      fatsPerKg: 2.5,
    ),
    NutritionalGoal(
      id: 'vegan',
      title: 'Plant-Based',
      description: 'Complete nutrition from plant sources only',
      calorieAdjustment: 0,
      iconName: 'energy_savings_leaf',
      proteinPerKg: 1.8,
      carbsPerKg: 4.0,
      fatsPerKg: 0.9,
    ),
    NutritionalGoal(
      id: 'high_protein',
      title: 'High Protein',
      description: 'Maximum protein for muscle preservation and satiety',
      calorieAdjustment: 0,
      iconName: 'egg',
      proteinPerKg: 2.5,
      carbsPerKg: 2.5,
      fatsPerKg: 0.8,
    ),
  ];

  /// Find goal by ID
  static NutritionalGoal findById(String id) {
    return goals.firstWhere(
      (g) => g.id == id,
      orElse: () => goals[1], // Default to maintenance
    );
  }
}
