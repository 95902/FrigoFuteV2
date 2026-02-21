import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/feature_flags/feature_config.dart';

void main() {
  group('FeatureConfig Tests', () {
    group('Constructor', () {
      test('creates config with premium status', () {
        const config = FeatureConfig(isPremium: true);
        expect(config.isPremium, isTrue);
      });

      test('creates config with non-premium status', () {
        const config = FeatureConfig(isPremium: false);
        expect(config.isPremium, isFalse);
      });

      test('creates config with custom features map', () {
        const config = FeatureConfig(
          isPremium: false,
          features: {
            'testFeature': true,
            'anotherFeature': false,
          },
        );

        expect(config.features['testFeature'], isTrue);
        expect(config.features['anotherFeature'], isFalse);
      });

      test('creates config with default empty features when none provided', () {
        const config = FeatureConfig(isPremium: false);
        expect(config.features, isEmpty);
      });
    });

    group('isFeatureEnabled', () {
      test('returns true for enabled feature', () {
        const config = FeatureConfig(
          isPremium: false,
          features: {'testFeature': true},
        );

        expect(config.isFeatureEnabled('testFeature'), isTrue);
      });

      test('returns false for disabled feature', () {
        const config = FeatureConfig(
          isPremium: false,
          features: {'testFeature': false},
        );

        expect(config.isFeatureEnabled('testFeature'), isFalse);
      });

      test('returns false for non-existent feature', () {
        const config = FeatureConfig(
          isPremium: false,
          features: {},
        );

        expect(config.isFeatureEnabled('nonExistent'), isFalse);
      });
    });

    group('fromRemoteConfig factory', () {
      test('creates config from remote config placeholder', () {
        final config = FeatureConfig.fromRemoteConfig({});

        expect(config, isA<FeatureConfig>());
        expect(config.isPremium, isFalse);
        expect(config.features, isNotEmpty);
      });

      test('has OCR scanning enabled in placeholder', () {
        final config = FeatureConfig.fromRemoteConfig({});

        expect(config.isFeatureEnabled('ocr_scanning'), isTrue);
      });

      test('has nutrition tracking enabled in placeholder', () {
        final config = FeatureConfig.fromRemoteConfig({});

        expect(config.isFeatureEnabled('nutrition_tracking'), isTrue);
      });

      test('has AI coach disabled in placeholder (premium)', () {
        final config = FeatureConfig.fromRemoteConfig({});

        expect(config.isFeatureEnabled('ai_coach'), isFalse);
      });

      test('has price comparison disabled in placeholder (premium)', () {
        final config = FeatureConfig.fromRemoteConfig({});

        expect(config.isFeatureEnabled('price_comparison'), isFalse);
      });
    });

    group('defaults factory', () {
      test('creates default free configuration', () {
        final config = FeatureConfig.defaults();

        expect(config.isPremium, isFalse);
        expect(config.features, isNotEmpty);
      });

      test('has inventory enabled by default', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('inventory'), isTrue);
      });

      test('has recipes enabled by default', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('recipes'), isTrue);
      });

      test('has notifications enabled by default', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('notifications'), isTrue);
      });

      test('has dashboard enabled by default', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('dashboard'), isTrue);
      });

      test('has OCR scanning enabled by default', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('ocr_scanning'), isTrue);
      });

      test('has nutrition tracking enabled by default', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('nutrition_tracking'), isTrue);
      });

      test('has gamification enabled by default', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('gamification'), isTrue);
      });

      test('has meal planning disabled by default (premium)', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('meal_planning'), isFalse);
      });

      test('has AI coach disabled by default (premium)', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('ai_coach'), isFalse);
      });

      test('has price comparison disabled by default (premium)', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('price_comparison'), isFalse);
      });
    });

    group('Feature Flag Consistency', () {
      test('defaults factory has consistent free/premium split', () {
        final config = FeatureConfig.defaults();

        // Free features should be enabled
        expect(config.isFeatureEnabled('inventory'), isTrue);
        expect(config.isFeatureEnabled('recipes'), isTrue);
        expect(config.isFeatureEnabled('dashboard'), isTrue);
        expect(config.isFeatureEnabled('ocr_scanning'), isTrue);
        expect(config.isFeatureEnabled('notifications'), isTrue);

        // Premium features should be disabled in free tier
        expect(config.isFeatureEnabled('meal_planning'), isFalse);
        expect(config.isFeatureEnabled('ai_coach'), isFalse);
        expect(config.isFeatureEnabled('price_comparison'), isFalse);
      });

      test('unknown features default to disabled', () {
        final config = FeatureConfig.defaults();

        expect(config.isFeatureEnabled('unknown_feature_xyz'), isFalse);
        expect(config.isFeatureEnabled(''), isFalse);
      });
    });
  });
}
