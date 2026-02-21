import 'package:hive_ce/hive.dart';

part 'settings_model.g.dart';

/// SettingsModel - Modèle simple pour préférences
///
/// Stocké dans: settings_box (non-chiffré)
/// Hive TypeId: 3
@HiveType(typeId: 3)
class SettingsModel {
  @HiveField(0)
  final String theme;

  @HiveField(1)
  final String locale;

  @HiveField(2)
  final bool notificationsEnabled;

  @HiveField(3)
  final int dlcAlertDelay;

  @HiveField(4)
  final int ddmAlertDelay;

  @HiveField(5)
  final bool analyticsEnabled;

  SettingsModel({
    this.theme = 'light',
    this.locale = 'fr',
    this.notificationsEnabled = true,
    this.dlcAlertDelay = 2,
    this.ddmAlertDelay = 5,
    this.analyticsEnabled = false,
  });

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'locale': locale,
        'notificationsEnabled': notificationsEnabled,
        'dlcAlertDelay': dlcAlertDelay,
        'ddmAlertDelay': ddmAlertDelay,
        'analyticsEnabled': analyticsEnabled,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        theme: json['theme'] as String? ?? 'light',
        locale: json['locale'] as String? ?? 'fr',
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        dlcAlertDelay: json['dlcAlertDelay'] as int? ?? 2,
        ddmAlertDelay: json['ddmAlertDelay'] as int? ?? 5,
        analyticsEnabled: json['analyticsEnabled'] as bool? ?? false,
      );
}
