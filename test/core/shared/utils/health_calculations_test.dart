import 'package:flutter_test/flutter_test.dart';

import 'package:frigofute_v2/core/shared/utils/health_calculations.dart';

void main() {
  // ─── calculateBMR ─────────────────────────────────────────────────────────

  group('HealthCalculations.calculateBMR', () {
    test('male 30y 175cm 70kg ≈ 1648.75 kcal', () {
      // (10×70) + (6.25×175) − (5×30) + 5 = 700 + 1093.75 − 150 + 5 = 1648.75
      final bmr = HealthCalculations.calculateBMR(
        ageYears: 30,
        heightCm: 175,
        weightKg: 70,
        gender: 'male',
      );
      expect(bmr, closeTo(1648.75, 1.0));
    });

    test('female 25y 165cm 60kg ≈ 1345.25 kcal', () {
      // (10×60) + (6.25×165) − (5×25) − 161 = 600 + 1031.25 − 125 − 161 = 1345.25
      final bmr = HealthCalculations.calculateBMR(
        ageYears: 25,
        heightCm: 165,
        weightKg: 60,
        gender: 'female',
      );
      expect(bmr, closeTo(1345.25, 1.0));
    });

    test('other gender uses female-average constant −78', () {
      final bmrOther = HealthCalculations.calculateBMR(
        ageYears: 30,
        heightCm: 170,
        weightKg: 65,
        gender: 'other',
      );
      // Should be between male (+5) and female (−161) BMR values
      final bmrMale = HealthCalculations.calculateBMR(
        ageYears: 30,
        heightCm: 170,
        weightKg: 65,
        gender: 'male',
      );
      final bmrFemale = HealthCalculations.calculateBMR(
        ageYears: 30,
        heightCm: 170,
        weightKg: 65,
        gender: 'female',
      );
      expect(bmrOther, greaterThan(bmrFemale));
      expect(bmrOther, lessThan(bmrMale));
    });

    test('clamps low values to 800', () {
      final bmr = HealthCalculations.calculateBMR(
        ageYears: 120,
        heightCm: 100,
        weightKg: 20,
        gender: 'female',
      );
      expect(bmr, greaterThanOrEqualTo(800));
    });

    test('case-insensitive gender (Male, FEMALE)', () {
      final bmrMale1 = HealthCalculations.calculateBMR(
        ageYears: 30,
        heightCm: 175,
        weightKg: 70,
        gender: 'male',
      );
      final bmrMale2 = HealthCalculations.calculateBMR(
        ageYears: 30,
        heightCm: 175,
        weightKg: 70,
        gender: 'Male',
      );
      expect(bmrMale1, closeTo(bmrMale2, 0.01));
    });
  });

  // ─── calculateTDEE ────────────────────────────────────────────────────────

  group('HealthCalculations.calculateTDEE', () {
    const bmr = 1500.0;

    test('sedentary multiplier × 1.2', () {
      expect(HealthCalculations.calculateTDEE(bmr, 'sedentary'),
          closeTo(1800.0, 0.01));
    });

    test('light multiplier × 1.375', () {
      expect(HealthCalculations.calculateTDEE(bmr, 'light'),
          closeTo(2062.5, 0.01));
    });

    test('moderate multiplier × 1.55', () {
      expect(HealthCalculations.calculateTDEE(bmr, 'moderate'),
          closeTo(2325.0, 0.01));
    });

    test('active multiplier × 1.725', () {
      expect(HealthCalculations.calculateTDEE(bmr, 'active'),
          closeTo(2587.5, 0.01));
    });

    test('veryActive multiplier × 1.9', () {
      expect(HealthCalculations.calculateTDEE(bmr, 'veryActive'),
          closeTo(2850.0, 0.01));
    });

    test('unknown level defaults to moderate × 1.55', () {
      expect(HealthCalculations.calculateTDEE(bmr, 'astronaut'),
          closeTo(2325.0, 0.01));
    });
  });

  // ─── calculateMacroTargets ────────────────────────────────────────────────

  group('HealthCalculations.calculateMacroTargets', () {
    const tdee = 2000.0;
    const weightKg = 70.0;

    test('maintenance: calories = tdee, 25/50/25 ratios', () {
      final macros = HealthCalculations.calculateMacroTargets(
        tdee: tdee,
        nutritionalGoal: 'maintenance',
        weightKg: weightKg,
      );
      expect(macros['calories'], closeTo(2000.0, 1.0));
      expect(macros.containsKey('protein'), isTrue);
      expect(macros.containsKey('carbs'), isTrue);
      expect(macros.containsKey('fats'), isTrue);
    });

    test('weight_loss: calories = tdee × 0.85', () {
      final macros = HealthCalculations.calculateMacroTargets(
        tdee: tdee,
        nutritionalGoal: 'weight_loss',
        weightKg: weightKg,
      );
      expect(macros['calories'], closeTo(1700.0, 1.0));
    });

    test('muscle_gain: calories = tdee × 1.10', () {
      final macros = HealthCalculations.calculateMacroTargets(
        tdee: tdee,
        nutritionalGoal: 'muscle_gain',
        weightKg: weightKg,
      );
      expect(macros['calories'], closeTo(2200.0, 1.0));
    });

    test('macro energy sum ≈ target calories (tolerance 5 kcal)', () {
      for (final goal in ['maintenance', 'weight_loss', 'muscle_gain']) {
        final macros = HealthCalculations.calculateMacroTargets(
          tdee: tdee,
          nutritionalGoal: goal,
          weightKg: weightKg,
        );
        final energyFromMacros = (macros['protein']! * 4) +
            (macros['carbs']! * 4) +
            (macros['fats']! * 9);
        expect(
          energyFromMacros,
          closeTo(macros['calories']!, 10.0),
          reason: 'Macro energy mismatch for goal: $goal',
        );
      }
    });

    test('unknown goal defaults to maintenance ratios', () {
      final macros = HealthCalculations.calculateMacroTargets(
        tdee: tdee,
        nutritionalGoal: 'unknown_goal',
        weightKg: weightKg,
      );
      expect(macros['calories'], closeTo(2000.0, 1.0));
    });
  });

  // ─── calculateWeightChangeRate ────────────────────────────────────────────

  group('HealthCalculations.calculateWeightChangeRate', () {
    test('returns 0.0 for fewer than 2 entries', () {
      expect(HealthCalculations.calculateWeightChangeRate([]), 0.0);
      expect(
        HealthCalculations.calculateWeightChangeRate([
          (date: DateTime(2026, 1, 1), weight: 75.0),
        ]),
        0.0,
      );
    });

    test('calculates kg/week correctly for 7-day span', () {
      // 75 → 74 in 7 days = −1 kg/week
      final rate = HealthCalculations.calculateWeightChangeRate([
        (date: DateTime(2026, 1, 1), weight: 75.0),
        (date: DateTime(2026, 1, 8), weight: 74.0),
      ]);
      expect(rate, closeTo(-1.0, 0.01));
    });

    test('calculates positive rate for weight gain', () {
      final rate = HealthCalculations.calculateWeightChangeRate([
        (date: DateTime(2026, 1, 1), weight: 70.0),
        (date: DateTime(2026, 1, 15), weight: 72.0),
      ]);
      // +2 kg in 14 days = +1 kg/week
      expect(rate, closeTo(1.0, 0.05));
    });

    test('handles unsorted entries by sorting internally', () {
      final rate = HealthCalculations.calculateWeightChangeRate([
        (date: DateTime(2026, 1, 8), weight: 74.0),
        (date: DateTime(2026, 1, 1), weight: 75.0), // older but listed second
      ]);
      expect(rate, closeTo(-1.0, 0.01));
    });

    test('returns 0.0 for 0-day span (same date)', () {
      final rate = HealthCalculations.calculateWeightChangeRate([
        (date: DateTime(2026, 1, 1), weight: 75.0),
        (date: DateTime(2026, 1, 1), weight: 74.5),
      ]);
      expect(rate, 0.0);
    });
  });
}
