import 'package:hive_ce/hive.dart';

import 'weight_history_entry.dart';

part 'health_profile_model.g.dart';

/// HealthProfileModel - Modèle complet pour profils santé
///
/// Stocké dans: health_profiles_box (CHIFFRÉ AES-256)
/// Hive TypeId: 5
/// Story 0.3: Initial model
/// Story 1.6: Extended with physical characteristics + weight history
@HiveType(typeId: 5)
class HealthProfileModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String profileType;

  @HiveField(2)
  final double tdee;

  @HiveField(3)
  final double bmr;

  @HiveField(4)
  final Map<String, dynamic> macroTargets;

  @HiveField(5)
  final List<String> dietaryRestrictions;

  @HiveField(6)
  final List<String> allergies;

  // Physical characteristics (Story 1.6)
  @HiveField(7)
  final int age;

  @HiveField(8)
  final String gender; // 'male', 'female', 'other'

  @HiveField(9)
  final double height; // cm

  @HiveField(10)
  final double currentWeight; // kg

  @HiveField(11)
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'veryActive'

  @HiveField(12)
  final DateTime lastUpdated;

  @HiveField(13)
  final List<WeightHistoryEntry> weightHistory;

  HealthProfileModel({
    required this.id,
    required this.profileType,
    required this.tdee,
    required this.bmr,
    required this.macroTargets,
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.age = 0,
    this.gender = 'other',
    this.height = 0,
    this.currentWeight = 0,
    this.activityLevel = 'moderate',
    DateTime? lastUpdated,
    this.weightHistory = const [],
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  HealthProfileModel copyWith({
    String? id,
    String? profileType,
    double? tdee,
    double? bmr,
    Map<String, dynamic>? macroTargets,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    int? age,
    String? gender,
    double? height,
    double? currentWeight,
    String? activityLevel,
    DateTime? lastUpdated,
    List<WeightHistoryEntry>? weightHistory,
  }) {
    return HealthProfileModel(
      id: id ?? this.id,
      profileType: profileType ?? this.profileType,
      tdee: tdee ?? this.tdee,
      bmr: bmr ?? this.bmr,
      macroTargets: macroTargets ?? this.macroTargets,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      activityLevel: activityLevel ?? this.activityLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      weightHistory: weightHistory ?? this.weightHistory,
    );
  }

  /// Add a new weight entry and update currentWeight
  HealthProfileModel addWeightEntry(WeightHistoryEntry entry) {
    return copyWith(
      currentWeight: entry.weight,
      lastUpdated: DateTime.now(),
      weightHistory: [...weightHistory, entry],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'profileType': profileType,
        'tdee': tdee,
        'bmr': bmr,
        'macroTargets': macroTargets,
        'dietaryRestrictions': dietaryRestrictions,
        'allergies': allergies,
        'age': age,
        'gender': gender,
        'height': height,
        'currentWeight': currentWeight,
        'activityLevel': activityLevel,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  Map<String, dynamic> toFirestore() => {
        'profileType': profileType,
        'tdee': tdee,
        'bmr': bmr,
        'macroTargets': macroTargets,
        'dietaryRestrictions': dietaryRestrictions,
        'allergies': allergies,
        'age': age,
        'gender': gender,
        'height': height,
        'currentWeight': currentWeight,
        'activityLevel': activityLevel,
      };

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) =>
      HealthProfileModel(
        id: json['id'] as String,
        profileType: json['profileType'] as String,
        tdee: (json['tdee'] as num).toDouble(),
        bmr: (json['bmr'] as num).toDouble(),
        macroTargets: Map<String, dynamic>.from(json['macroTargets'] as Map),
        dietaryRestrictions: json['dietaryRestrictions'] != null
            ? List<String>.from(json['dietaryRestrictions'] as List)
            : const [],
        allergies: json['allergies'] != null
            ? List<String>.from(json['allergies'] as List)
            : const [],
        age: json['age'] as int? ?? 0,
        gender: json['gender'] as String? ?? 'other',
        height: (json['height'] as num?)?.toDouble() ?? 0,
        currentWeight: (json['currentWeight'] as num?)?.toDouble() ?? 0,
        activityLevel: json['activityLevel'] as String? ?? 'moderate',
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'] as String)
            : null,
      );
}
