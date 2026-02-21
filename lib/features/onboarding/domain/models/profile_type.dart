import 'package:flutter/material.dart';

/// Profile type enum for the adaptive onboarding flow
/// Story 1.5: Complete Adaptive Onboarding Flow — AC3, AC4, AC5
enum ProfileType {
  waste('waste', 'Reduce Waste', 'Focus on reducing food waste at home'),
  nutrition('nutrition', 'Track Nutrition', 'Monitor your dietary intake and health'),
  mealPlanning('meal_planning', 'Meal Planning', 'Plan meals and optimize grocery shopping'),
  all('all', 'All Features', 'Access all features for maximum impact');

  const ProfileType(this.id, this.title, this.description);

  final String id;
  final String title;
  final String description;

  /// Get icon based on profile type
  IconData get icon {
    switch (this) {
      case ProfileType.waste:
        return Icons.eco;
      case ProfileType.nutrition:
        return Icons.restaurant;
      case ProfileType.mealPlanning:
        return Icons.calendar_today;
      case ProfileType.all:
        return Icons.star;
    }
  }

  /// Whether this profile type requires nutrition steps (AC4, AC5)
  bool get requiresNutritionSteps => this != ProfileType.waste;

  /// Get ProfileType from id string
  static ProfileType fromId(String id) {
    return ProfileType.values.firstWhere(
      (p) => p.id == id,
      orElse: () => ProfileType.waste,
    );
  }
}
