import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/storage/models/health_profile_model.dart';

void main() {
  group('HealthProfileModel Tests', () {
    late HealthProfileModel testProfile;
    late Map<String, dynamic> testMacros;

    setUp(() {
      testMacros = {'proteins': 150.0, 'carbs': 200.0, 'fats': 60.0};

      testProfile = HealthProfileModel(
        id: '123',
        profileType: 'muscle_gain',
        tdee: 2800.0,
        bmr: 1850.0,
        macroTargets: testMacros,
        dietaryRestrictions: ['vegetarian', 'lactose-free'],
        allergies: ['peanuts', 'shellfish'],
      );
    });

    group('Constructor', () {
      test('should create profile with all fields', () {
        expect(testProfile.id, '123');
        expect(testProfile.profileType, 'muscle_gain');
        expect(testProfile.tdee, 2800.0);
        expect(testProfile.bmr, 1850.0);
        expect(testProfile.macroTargets['proteins'], 150.0);
        expect(testProfile.dietaryRestrictions.length, 2);
        expect(testProfile.allergies.length, 2);
      });

      test('should create profile with empty lists by default', () {
        final profile = HealthProfileModel(
          id: '1',
          profileType: 'maintenance',
          tdee: 2200.0,
          bmr: 1650.0,
          macroTargets: {'proteins': 100.0},
        );

        expect(profile.dietaryRestrictions, isEmpty);
        expect(profile.allergies, isEmpty);
      });

      test('should support different profile types', () {
        final weightLoss = HealthProfileModel(
          id: '1',
          profileType: 'weight_loss',
          tdee: 1800.0,
          bmr: 1500.0,
          macroTargets: {},
        );

        final performance = HealthProfileModel(
          id: '2',
          profileType: 'performance',
          tdee: 3500.0,
          bmr: 2000.0,
          macroTargets: {},
        );

        expect(weightLoss.profileType, 'weight_loss');
        expect(performance.profileType, 'performance');
      });

      test('should handle empty macro targets', () {
        final profile = HealthProfileModel(
          id: '1',
          profileType: 'maintenance',
          tdee: 2000.0,
          bmr: 1600.0,
          macroTargets: {},
        );

        expect(profile.macroTargets, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert to JSON with all fields', () {
        final json = testProfile.toJson();

        expect(json['id'], '123');
        expect(json['profileType'], 'muscle_gain');
        expect(json['tdee'], 2800.0);
        expect(json['bmr'], 1850.0);
        expect(
          (json['macroTargets'] as Map<String, dynamic>)['proteins'],
          150.0,
        );
        expect(json['dietaryRestrictions'], ['vegetarian', 'lactose-free']);
        expect(json['allergies'], ['peanuts', 'shellfish']);
      });

      test('should convert to JSON with empty lists', () {
        final profile = HealthProfileModel(
          id: '1',
          profileType: 'maintenance',
          tdee: 2200.0,
          bmr: 1650.0,
          macroTargets: {'proteins': 100.0},
        );

        final json = profile.toJson();

        expect(json['dietaryRestrictions'], isEmpty);
        expect(json['allergies'], isEmpty);
      });

      test('should preserve macro target structure', () {
        final macros = {
          'proteins': 120.0,
          'carbs': 250.0,
          'fats': 70.0,
          'fiber': 30.0,
        };

        final profile = HealthProfileModel(
          id: '1',
          profileType: 'custom',
          tdee: 2500.0,
          bmr: 1700.0,
          macroTargets: macros,
        );

        final json = profile.toJson();

        final macroTargets = json['macroTargets'] as Map<String, dynamic>;
        expect(macroTargets['proteins'], 120.0);
        expect(macroTargets['carbs'], 250.0);
        expect(macroTargets['fats'], 70.0);
        expect(macroTargets['fiber'], 30.0);
      });
    });

    group('fromJson', () {
      test('should create from JSON with all fields', () {
        final json = {
          'id': '123',
          'profileType': 'muscle_gain',
          'tdee': 2800.0,
          'bmr': 1850.0,
          'macroTargets': {'proteins': 150.0, 'carbs': 200.0, 'fats': 60.0},
          'dietaryRestrictions': ['vegetarian', 'lactose-free'],
          'allergies': ['peanuts', 'shellfish'],
        };

        final profile = HealthProfileModel.fromJson(json);

        expect(profile.id, '123');
        expect(profile.profileType, 'muscle_gain');
        expect(profile.tdee, 2800.0);
        expect(profile.bmr, 1850.0);
        expect(profile.macroTargets['proteins'], 150.0);
        expect(profile.dietaryRestrictions, ['vegetarian', 'lactose-free']);
        expect(profile.allergies, ['peanuts', 'shellfish']);
      });

      test('should create from JSON with null lists', () {
        final json = {
          'id': '1',
          'profileType': 'maintenance',
          'tdee': 2200.0,
          'bmr': 1650.0,
          'macroTargets': {'proteins': 100.0},
          'dietaryRestrictions': null,
          'allergies': null,
        };

        final profile = HealthProfileModel.fromJson(json);

        expect(profile.dietaryRestrictions, isEmpty);
        expect(profile.allergies, isEmpty);
      });

      test('should handle integer values for double fields', () {
        final json = {
          'id': '1',
          'profileType': 'weight_loss',
          'tdee': 1800, // int instead of double
          'bmr': 1500, // int instead of double
          'macroTargets': {
            'proteins': 100, // int instead of double
            'carbs': 150,
            'fats': 50,
          },
        };

        final profile = HealthProfileModel.fromJson(json);

        expect(profile.tdee, 1800.0);
        expect(profile.bmr, 1500.0);
        expect(profile.macroTargets['proteins'], 100);
      });

      test('should preserve macro target Map structure', () {
        final json = {
          'id': '1',
          'profileType': 'custom',
          'tdee': 2400.0,
          'bmr': 1700.0,
          'macroTargets': {
            'proteins': 130.0,
            'carbs': 220.0,
            'fats': 65.0,
            'custom_field': 'value',
          },
        };

        final profile = HealthProfileModel.fromJson(json);

        expect(profile.macroTargets['custom_field'], 'value');
        expect(profile.macroTargets.keys.length, 4);
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('should preserve all data in roundtrip', () {
        final json = testProfile.toJson();
        final restored = HealthProfileModel.fromJson(json);

        expect(restored.id, testProfile.id);
        expect(restored.profileType, testProfile.profileType);
        expect(restored.tdee, testProfile.tdee);
        expect(restored.bmr, testProfile.bmr);
        expect(restored.macroTargets, testProfile.macroTargets);
        expect(restored.dietaryRestrictions, testProfile.dietaryRestrictions);
        expect(restored.allergies, testProfile.allergies);
      });

      test('should preserve list order in roundtrip', () {
        final profile = HealthProfileModel(
          id: '1',
          profileType: 'custom',
          tdee: 2500.0,
          bmr: 1700.0,
          macroTargets: {},
          dietaryRestrictions: ['vegan', 'gluten-free', 'organic'],
          allergies: ['nuts', 'dairy', 'soy'],
        );

        final json = profile.toJson();
        final restored = HealthProfileModel.fromJson(json);

        expect(restored.dietaryRestrictions[0], 'vegan');
        expect(restored.dietaryRestrictions[1], 'gluten-free');
        expect(restored.allergies[0], 'nuts');
        expect(restored.allergies[2], 'soy');
      });

      test('should handle multiple roundtrips', () {
        var json = testProfile.toJson();

        for (var i = 0; i < 5; i++) {
          final profile = HealthProfileModel.fromJson(json);
          json = profile.toJson();
        }

        final finalProfile = HealthProfileModel.fromJson(json);
        expect(finalProfile.tdee, testProfile.tdee);
        expect(finalProfile.bmr, testProfile.bmr);
      });
    });

    group('Metabolic calculations', () {
      test('should have TDEE greater than BMR', () {
        expect(testProfile.tdee, greaterThan(testProfile.bmr));
      });

      test('should support sedentary profile (TDEE = BMR * 1.2)', () {
        const bmr = 1600.0;
        final profile = HealthProfileModel(
          id: '1',
          profileType: 'sedentary',
          tdee: bmr * 1.2,
          bmr: bmr,
          macroTargets: {},
        );

        expect(profile.tdee, closeTo(1920.0, 0.1));
      });

      test('should support athlete profile (TDEE = BMR * 1.9)', () {
        const bmr = 1800.0;
        final profile = HealthProfileModel(
          id: '1',
          profileType: 'athlete',
          tdee: bmr * 1.9,
          bmr: bmr,
          macroTargets: {},
        );

        expect(profile.tdee, closeTo(3420.0, 0.1));
      });

      test('should calculate caloric surplus for muscle gain', () {
        const maintenance = 2500.0;
        const surplus = 300.0;

        final profile = HealthProfileModel(
          id: '1',
          profileType: 'muscle_gain',
          tdee: maintenance + surplus,
          bmr: 1800.0,
          macroTargets: {},
        );

        expect(profile.tdee - 2500, 300);
      });

      test('should calculate caloric deficit for weight loss', () {
        const maintenance = 2200.0;
        const deficit = 500.0;

        final profile = HealthProfileModel(
          id: '1',
          profileType: 'weight_loss',
          tdee: maintenance - deficit,
          bmr: 1650.0,
          macroTargets: {},
        );

        expect(2200 - profile.tdee, 500);
      });
    });

    group('Edge cases', () {
      test('should handle very high TDEE values', () {
        final profile = HealthProfileModel(
          id: '1',
          profileType: 'extreme_athlete',
          tdee: 6000.0,
          bmr: 2500.0,
          macroTargets: {},
        );

        expect(profile.tdee, 6000.0);
      });

      test('should handle empty dietary restrictions and allergies', () {
        final profile = HealthProfileModel(
          id: '1',
          profileType: 'omnivore',
          tdee: 2300.0,
          bmr: 1700.0,
          macroTargets: {},
          dietaryRestrictions: [],
          allergies: [],
        );

        expect(profile.dietaryRestrictions, isEmpty);
        expect(profile.allergies, isEmpty);
      });

      test('should handle many dietary restrictions', () {
        final restrictions = [
          'vegan',
          'gluten-free',
          'soy-free',
          'nut-free',
          'organic',
          'non-gmo',
        ];

        final profile = HealthProfileModel(
          id: '1',
          profileType: 'restricted',
          tdee: 2000.0,
          bmr: 1600.0,
          macroTargets: {},
          dietaryRestrictions: restrictions,
        );

        expect(profile.dietaryRestrictions.length, 6);
      });

      test('should handle complex macro targets', () {
        final macros = {
          'proteins_g': 150.0,
          'carbs_g': 200.0,
          'fats_g': 70.0,
          'fiber_g': 35.0,
          'sugar_g': 50.0,
          'sodium_mg': 2300.0,
        };

        final profile = HealthProfileModel(
          id: '1',
          profileType: 'detailed',
          tdee: 2600.0,
          bmr: 1750.0,
          macroTargets: macros,
        );

        expect(profile.macroTargets.keys.length, 6);
      });
    });
  });
}
