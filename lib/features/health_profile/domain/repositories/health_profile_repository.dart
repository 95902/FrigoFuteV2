import '../../../../core/storage/models/health_profile_model.dart';
import '../../../../core/storage/models/weight_history_entry.dart';

/// Abstract repository interface for health profile operations
/// Story 1.6: Configure Personal Profile with Physical Characteristics
abstract class HealthProfileRepository {
  /// Get the current user's health profile from local cache
  Future<HealthProfileModel?> getCurrentProfile();

  /// Save updated profile to Hive and sync to Firestore
  Future<void> updateProfile(HealthProfileModel profile);

  /// Get weight history entries filtered by date range
  Future<List<WeightHistoryEntry>> getWeightHistory({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Calculate kg/week weight change rate over the given period
  Future<double> calculateWeightChangeRate(int daysPeriod);
}
