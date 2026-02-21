import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/storage/models/settings_model.dart';

void main() {
  group('SettingsModel Tests', () {
    group('Constructor', () {
      test('should create settings with default values', () {
        final settings = SettingsModel();

        expect(settings.theme, 'light');
        expect(settings.locale, 'fr');
        expect(settings.notificationsEnabled, true);
        expect(settings.dlcAlertDelay, 2);
        expect(settings.ddmAlertDelay, 5);
        expect(settings.analyticsEnabled, false);
      });

      test('should create settings with custom values', () {
        final settings = SettingsModel(
          theme: 'dark',
          locale: 'en',
          notificationsEnabled: false,
          dlcAlertDelay: 3,
          ddmAlertDelay: 7,
          analyticsEnabled: true,
        );

        expect(settings.theme, 'dark');
        expect(settings.locale, 'en');
        expect(settings.notificationsEnabled, false);
        expect(settings.dlcAlertDelay, 3);
        expect(settings.ddmAlertDelay, 7);
        expect(settings.analyticsEnabled, true);
      });

      test('should support partial custom values', () {
        final settings = SettingsModel(
          theme: 'dark',
          locale: 'en',
        );

        expect(settings.theme, 'dark');
        expect(settings.locale, 'en');
        expect(settings.notificationsEnabled, true); // default
        expect(settings.dlcAlertDelay, 2); // default
      });
    });

    group('toJson', () {
      test('should convert settings to JSON with default values', () {
        final settings = SettingsModel();
        final json = settings.toJson();

        expect(json['theme'], 'light');
        expect(json['locale'], 'fr');
        expect(json['notificationsEnabled'], true);
        expect(json['dlcAlertDelay'], 2);
        expect(json['ddmAlertDelay'], 5);
        expect(json['analyticsEnabled'], false);
      });

      test('should convert settings to JSON with custom values', () {
        final settings = SettingsModel(
          theme: 'dark',
          locale: 'en',
          notificationsEnabled: false,
          dlcAlertDelay: 1,
          ddmAlertDelay: 10,
          analyticsEnabled: true,
        );
        final json = settings.toJson();

        expect(json['theme'], 'dark');
        expect(json['locale'], 'en');
        expect(json['notificationsEnabled'], false);
        expect(json['dlcAlertDelay'], 1);
        expect(json['ddmAlertDelay'], 10);
        expect(json['analyticsEnabled'], true);
      });

      test('should include all fields in JSON', () {
        final settings = SettingsModel();
        final json = settings.toJson();

        expect(json.keys.length, 6);
        expect(json.containsKey('theme'), true);
        expect(json.containsKey('locale'), true);
        expect(json.containsKey('notificationsEnabled'), true);
        expect(json.containsKey('dlcAlertDelay'), true);
        expect(json.containsKey('ddmAlertDelay'), true);
        expect(json.containsKey('analyticsEnabled'), true);
      });
    });

    group('fromJson', () {
      test('should create settings from JSON with all fields', () {
        final json = {
          'theme': 'dark',
          'locale': 'en',
          'notificationsEnabled': false,
          'dlcAlertDelay': 3,
          'ddmAlertDelay': 7,
          'analyticsEnabled': true,
        };

        final settings = SettingsModel.fromJson(json);

        expect(settings.theme, 'dark');
        expect(settings.locale, 'en');
        expect(settings.notificationsEnabled, false);
        expect(settings.dlcAlertDelay, 3);
        expect(settings.ddmAlertDelay, 7);
        expect(settings.analyticsEnabled, true);
      });

      test('should use default values when JSON is empty', () {
        final json = <String, dynamic>{};
        final settings = SettingsModel.fromJson(json);

        expect(settings.theme, 'light');
        expect(settings.locale, 'fr');
        expect(settings.notificationsEnabled, true);
        expect(settings.dlcAlertDelay, 2);
        expect(settings.ddmAlertDelay, 5);
        expect(settings.analyticsEnabled, false);
      });

      test('should use default values when fields are null', () {
        final json = {
          'theme': null,
          'locale': null,
          'notificationsEnabled': null,
          'dlcAlertDelay': null,
          'ddmAlertDelay': null,
          'analyticsEnabled': null,
        };

        final settings = SettingsModel.fromJson(json);

        expect(settings.theme, 'light');
        expect(settings.locale, 'fr');
        expect(settings.notificationsEnabled, true);
        expect(settings.dlcAlertDelay, 2);
        expect(settings.ddmAlertDelay, 5);
        expect(settings.analyticsEnabled, false);
      });

      test('should handle partial JSON data', () {
        final json = {
          'theme': 'dark',
          'locale': 'en',
        };

        final settings = SettingsModel.fromJson(json);

        expect(settings.theme, 'dark');
        expect(settings.locale, 'en');
        expect(settings.notificationsEnabled, true); // default
        expect(settings.dlcAlertDelay, 2); // default
        expect(settings.ddmAlertDelay, 5); // default
        expect(settings.analyticsEnabled, false); // default
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('should preserve default values in roundtrip', () {
        final settings = SettingsModel();
        final json = settings.toJson();
        final restored = SettingsModel.fromJson(json);

        expect(restored.theme, settings.theme);
        expect(restored.locale, settings.locale);
        expect(restored.notificationsEnabled, settings.notificationsEnabled);
        expect(restored.dlcAlertDelay, settings.dlcAlertDelay);
        expect(restored.ddmAlertDelay, settings.ddmAlertDelay);
        expect(restored.analyticsEnabled, settings.analyticsEnabled);
      });

      test('should preserve custom values in roundtrip', () {
        final settings = SettingsModel(
          theme: 'dark',
          locale: 'es',
          notificationsEnabled: false,
          dlcAlertDelay: 1,
          ddmAlertDelay: 10,
          analyticsEnabled: true,
        );

        final json = settings.toJson();
        final restored = SettingsModel.fromJson(json);

        expect(restored.theme, settings.theme);
        expect(restored.locale, settings.locale);
        expect(restored.notificationsEnabled, settings.notificationsEnabled);
        expect(restored.dlcAlertDelay, settings.dlcAlertDelay);
        expect(restored.ddmAlertDelay, settings.ddmAlertDelay);
        expect(restored.analyticsEnabled, settings.analyticsEnabled);
      });

      test('should handle multiple roundtrips', () {
        final settings = SettingsModel(theme: 'dark', locale: 'de');
        var json = settings.toJson();

        for (var i = 0; i < 5; i++) {
          final restored = SettingsModel.fromJson(json);
          json = restored.toJson();
        }

        final finalSettings = SettingsModel.fromJson(json);
        expect(finalSettings.theme, 'dark');
        expect(finalSettings.locale, 'de');
      });
    });

    group('Alert delays validation', () {
      test('should support zero alert delay', () {
        final settings = SettingsModel(
          dlcAlertDelay: 0,
          ddmAlertDelay: 0,
        );

        expect(settings.dlcAlertDelay, 0);
        expect(settings.ddmAlertDelay, 0);
      });

      test('should support large alert delay values', () {
        final settings = SettingsModel(
          dlcAlertDelay: 30,
          ddmAlertDelay: 60,
        );

        expect(settings.dlcAlertDelay, 30);
        expect(settings.ddmAlertDelay, 60);
      });

      test('should handle negative values (if allowed)', () {
        final settings = SettingsModel(
          dlcAlertDelay: -1,
          ddmAlertDelay: -5,
        );

        expect(settings.dlcAlertDelay, -1);
        expect(settings.ddmAlertDelay, -5);
      });
    });

    group('Theme and locale values', () {
      test('should support different theme values', () {
        final lightSettings = SettingsModel(theme: 'light');
        final darkSettings = SettingsModel(theme: 'dark');
        final systemSettings = SettingsModel(theme: 'system');

        expect(lightSettings.theme, 'light');
        expect(darkSettings.theme, 'dark');
        expect(systemSettings.theme, 'system');
      });

      test('should support different locale values', () {
        final frSettings = SettingsModel(locale: 'fr');
        final enSettings = SettingsModel(locale: 'en');
        final esSettings = SettingsModel(locale: 'es');
        final deSettings = SettingsModel(locale: 'de');

        expect(frSettings.locale, 'fr');
        expect(enSettings.locale, 'en');
        expect(esSettings.locale, 'es');
        expect(deSettings.locale, 'de');
      });

      test('should handle empty string values', () {
        final settings = SettingsModel(
          theme: '',
          locale: '',
        );

        expect(settings.theme, '');
        expect(settings.locale, '');
      });
    });
  });
}
