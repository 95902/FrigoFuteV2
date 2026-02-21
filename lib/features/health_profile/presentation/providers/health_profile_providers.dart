import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/utils/health_calculations.dart';
import '../../../../core/storage/models/health_profile_model.dart';
import '../../../../core/storage/models/weight_history_entry.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../data/repositories/health_profile_repository_impl.dart';
import '../../domain/repositories/health_profile_repository.dart';
import '../../domain/usecases/update_health_profile_usecase.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

/// Current Firebase Auth UID (null if not authenticated)
final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

/// HealthProfileRepository provider
final healthProfileRepositoryProvider = Provider<HealthProfileRepository>((ref) {
  final box = ref.watch(healthProfilesBoxProvider);
  final userId = ref.watch(currentUserIdProvider) ?? '';
  return HealthProfileRepositoryImpl(box, FirebaseFirestore.instance, userId);
});

/// UpdateHealthProfileUseCase provider
final updateHealthProfileUseCaseProvider =
    Provider<UpdateHealthProfileUseCase>((ref) {
  final repository = ref.watch(healthProfileRepositoryProvider);
  return UpdateHealthProfileUseCase(repository);
});

// ─── Profile Data ─────────────────────────────────────────────────────────────

/// Current health profile (from encrypted Hive box)
///
/// Invalidate after save to refresh UI: ref.invalidate(currentHealthProfileProvider)
final currentHealthProfileProvider =
    FutureProvider<HealthProfileModel?>((ref) async {
  final repository = ref.watch(healthProfileRepositoryProvider);
  return repository.getCurrentProfile();
});

// ─── Calculated Metrics ───────────────────────────────────────────────────────

/// Calculated BMR from current profile
final bmrProvider = FutureProvider<double>((ref) async {
  final profile = await ref.watch(currentHealthProfileProvider.future);
  if (profile == null || profile.age == 0) return 0.0;
  return HealthCalculations.calculateBMR(
    ageYears: profile.age,
    heightCm: profile.height,
    weightKg: profile.currentWeight,
    gender: profile.gender,
  );
});

/// Calculated TDEE from current profile
final tdeeProvider = FutureProvider<double>((ref) async {
  final bmr = await ref.watch(bmrProvider.future);
  final profile = await ref.watch(currentHealthProfileProvider.future);
  if (profile == null || bmr == 0) return 0.0;
  return HealthCalculations.calculateTDEE(bmr, profile.activityLevel);
});

/// Calculated macro targets from current profile
final macroTargetsProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final tdee = await ref.watch(tdeeProvider.future);
  final profile = await ref.watch(currentHealthProfileProvider.future);
  if (profile == null || tdee == 0) return {};
  return HealthCalculations.calculateMacroTargets(
    tdee: tdee,
    nutritionalGoal: profile.profileType,
    weightKg: profile.currentWeight,
  );
});

// ─── Weight History ───────────────────────────────────────────────────────────

/// Weight history for a given period in days (30, 90, 365)
final weightHistoryProvider =
    FutureProvider.family<List<WeightHistoryEntry>, int>((ref, daysPeriod) async {
  final repository = ref.watch(healthProfileRepositoryProvider);
  final startDate = DateTime.now().subtract(Duration(days: daysPeriod));
  return repository.getWeightHistory(startDate: startDate);
});

/// Weekly weight change rate for a given period in days
final weightChangeRateProvider =
    FutureProvider.family<double, int>((ref, daysPeriod) async {
  final repository = ref.watch(healthProfileRepositoryProvider);
  return repository.calculateWeightChangeRate(daysPeriod);
});
