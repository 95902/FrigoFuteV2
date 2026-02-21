import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/shared/utils/health_calculations.dart';
import '../../../../core/storage/models/health_profile_model.dart';
import '../../../../core/storage/models/weight_history_entry.dart';
import '../../domain/repositories/health_profile_repository.dart';

/// RGPD exception — thrown when user has not consented to health data processing
class RGPDException implements Exception {
  final String message;
  const RGPDException(this.message);

  @override
  String toString() => message;
}

/// HealthProfileRepositoryImpl
///
/// Story 1.6: AC7, AC8, AC14, AC17
///
/// Strategy:
///   1. Save to encrypted Hive box immediately (offline-first)
///   2. Sync to Firestore (best-effort, swallows errors on failure)
class HealthProfileRepositoryImpl implements HealthProfileRepository {
  static const String _profileKey = 'current_profile';

  final Box<HealthProfileModel> _box;
  final FirebaseFirestore _firestore;
  final String _userId;

  HealthProfileRepositoryImpl(this._box, this._firestore, this._userId);

  // ─── Read ─────────────────────────────────────────────────────────────────

  @override
  Future<HealthProfileModel?> getCurrentProfile() async {
    return _box.get(_profileKey);
  }

  @override
  Future<List<WeightHistoryEntry>> getWeightHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final profile = await getCurrentProfile();
    if (profile == null) return [];

    var history = profile.weightHistory;

    if (startDate != null) {
      history = history
          .where((e) => e.date.isAfter(startDate) || e.date.isAtSameMomentAs(startDate))
          .toList();
    }
    if (endDate != null) {
      history = history
          .where((e) => e.date.isBefore(endDate) || e.date.isAtSameMomentAs(endDate))
          .toList();
    }

    return history..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<double> calculateWeightChangeRate(int daysPeriod) async {
    final startDate = DateTime.now().subtract(Duration(days: daysPeriod));
    final history = await getWeightHistory(startDate: startDate);

    final pairs = history
        .map((e) => (date: e.date, weight: e.weight))
        .toList();

    return HealthCalculations.calculateWeightChangeRate(pairs);
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  @override
  Future<void> updateProfile(HealthProfileModel profile) async {
    // 1. Save to Hive (encrypted, immediate)
    await _box.put(_profileKey, profile);

    // 2. Sync to Firestore (best-effort)
    await _syncToFirestore(profile);
  }

  Future<void> _syncToFirestore(HealthProfileModel profile) async {
    if (_userId.isEmpty) return;

    try {
      // AC14: Check RGPD consent before writing health data
      final userDoc = await _firestore.collection('users').doc(_userId).get();

      if (!userDoc.exists) return;
      final consentedToHealthData =
          userDoc.data()?['consentedToHealthData'] as bool? ?? false;

      if (!consentedToHealthData) {
        throw const RGPDException(
          'Vous devez consentir au traitement des données de santé',
        );
      }

      final healthProfileDocRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('healthProfile')
          .doc('current');

      await healthProfileDocRef.set({
        ...profile.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Sync latest weight history entry if it exists
      if (profile.weightHistory.isNotEmpty) {
        final latestEntry = profile.weightHistory.last;
        await healthProfileDocRef
            .collection('weightHistory')
            .add(latestEntry.toFirestore());
      }
    } on RGPDException {
      rethrow;
    } catch (e) {
      // Offline-first: swallow sync errors, data is already in Hive
      if (kDebugMode) {
        debugPrint('HealthProfileRepository: Firestore sync error: $e');
      }
    }
  }
}
