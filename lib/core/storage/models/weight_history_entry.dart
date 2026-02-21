import 'package:hive_ce/hive.dart';

part 'weight_history_entry.g.dart';

/// WeightHistoryEntry - Entrée d'historique de poids
///
/// Stocké dans: health_profiles_box (CHIFFRÉ AES-256)
/// Hive TypeId: 8
/// Story 1.6: AC8 - Weight history tracking
@HiveType(typeId: 8)
class WeightHistoryEntry {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double weight; // kg

  @HiveField(2)
  final double? bodyFatPercentage;

  @HiveField(3)
  final double? muscleMassKg;

  @HiveField(4)
  final String? notes;

  const WeightHistoryEntry({
    required this.date,
    required this.weight,
    this.bodyFatPercentage,
    this.muscleMassKg,
    this.notes,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      if (bodyFatPercentage != null) 'bodyFatPercentage': bodyFatPercentage,
      if (muscleMassKg != null) 'muscleMassKg': muscleMassKg,
      if (notes != null) 'notes': notes,
    };
  }

  factory WeightHistoryEntry.fromJson(Map<String, dynamic> json) {
    return WeightHistoryEntry(
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      bodyFatPercentage: json['bodyFatPercentage'] as double?,
      muscleMassKg: json['muscleMassKg'] as double?,
      notes: json['notes'] as String?,
    );
  }
}
