import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frigofute_v2/core/storage/models/health_profile_model.dart';
import 'package:frigofute_v2/core/storage/models/weight_history_entry.dart';
import 'package:frigofute_v2/features/health_profile/domain/repositories/health_profile_repository.dart';
import 'package:frigofute_v2/features/health_profile/domain/usecases/update_health_profile_usecase.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────

class MockHealthProfileRepository extends Mock
    implements HealthProfileRepository {}

// ─── Helpers ──────────────────────────────────────────────────────────────────

HealthProfileModel _baseProfile({
  double weight = 70.0,
  String profileType = 'maintenance',
}) =>
    HealthProfileModel(
      id: 'test',
      profileType: profileType,
      tdee: 2200,
      bmr: 1650,
      macroTargets: const {},
      age: 30,
      gender: 'male',
      height: 175,
      currentWeight: weight,
      activityLevel: 'moderate',
    );

void main() {
  late MockHealthProfileRepository mockRepo;
  late UpdateHealthProfileUseCase useCase;

  setUp(() {
    mockRepo = MockHealthProfileRepository();
    useCase = UpdateHealthProfileUseCase(mockRepo);
    registerFallbackValue(_baseProfile());
    when(() => mockRepo.updateProfile(any())).thenAnswer((_) async {});
  });

  // ─── Validation ───────────────────────────────────────────────────────────

  group('Validation', () {
    test('throws ValidationException for age < 13', () async {
      expect(
        () => useCase(
          currentProfile: _baseProfile(),
          age: 10,
          gender: 'male',
          height: 175,
          weight: 70,
          activityLevel: 'moderate',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException for age > 120', () async {
      expect(
        () => useCase(
          currentProfile: _baseProfile(),
          age: 130,
          gender: 'male',
          height: 175,
          weight: 70,
          activityLevel: 'moderate',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException for height < 100', () async {
      expect(
        () => useCase(
          currentProfile: _baseProfile(),
          age: 30,
          gender: 'male',
          height: 90,
          weight: 70,
          activityLevel: 'moderate',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException for height > 250', () async {
      expect(
        () => useCase(
          currentProfile: _baseProfile(),
          age: 30,
          gender: 'male',
          height: 260,
          weight: 70,
          activityLevel: 'moderate',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException for weight < 20', () async {
      expect(
        () => useCase(
          currentProfile: _baseProfile(),
          age: 30,
          gender: 'male',
          height: 175,
          weight: 15,
          activityLevel: 'moderate',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException for weight > 500', () async {
      expect(
        () => useCase(
          currentProfile: _baseProfile(),
          age: 30,
          gender: 'male',
          height: 175,
          weight: 600,
          activityLevel: 'moderate',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('boundary values (13y, 100cm, 20kg) are valid', () async {
      final result = await useCase(
        currentProfile: _baseProfile(weight: 20),
        age: 13,
        gender: 'female',
        height: 100,
        weight: 20,
        activityLevel: 'sedentary',
      );
      expect(result.age, 13);
      expect(result.height, 100);
      expect(result.currentWeight, 20);
    });
  });

  // ─── Recalculations ───────────────────────────────────────────────────────

  group('Recalculations', () {
    test('updates bmr, tdee, macroTargets in returned profile', () async {
      final result = await useCase(
        currentProfile: _baseProfile(),
        age: 30,
        gender: 'male',
        height: 175,
        weight: 70,
        activityLevel: 'moderate',
      );
      expect(result.bmr, greaterThan(0));
      expect(result.tdee, greaterThan(result.bmr));
      expect(result.macroTargets, isNotEmpty);
    });

    test('different activity levels yield different TDEE', () async {
      final sedentary = await useCase(
        currentProfile: _baseProfile(),
        age: 30,
        gender: 'male',
        height: 175,
        weight: 70,
        activityLevel: 'sedentary',
      );
      final active = await useCase(
        currentProfile: _baseProfile(),
        age: 30,
        gender: 'male',
        height: 175,
        weight: 70,
        activityLevel: 'active',
      );
      expect(active.tdee, greaterThan(sedentary.tdee));
    });
  });

  // ─── Weight history ───────────────────────────────────────────────────────

  group('Weight history entry', () {
    test('creates entry when weight changes', () async {
      final result = await useCase(
        currentProfile: _baseProfile(weight: 70.0),
        age: 30,
        gender: 'male',
        height: 175,
        weight: 72.0, // changed from 70
        activityLevel: 'moderate',
      );
      expect(result.weightHistory, hasLength(1));
      expect(result.weightHistory.first.weight, 72.0);
    });

    test('does not create entry when weight unchanged', () async {
      final result = await useCase(
        currentProfile: _baseProfile(weight: 70.0),
        age: 30,
        gender: 'male',
        height: 175,
        weight: 70.0, // same weight
        activityLevel: 'moderate',
      );
      expect(result.weightHistory, isEmpty);
    });

    test('weight history entry has today\'s date', () async {
      final before = DateTime.now();
      final result = await useCase(
        currentProfile: _baseProfile(weight: 70.0),
        age: 30,
        gender: 'male',
        height: 175,
        weight: 68.0,
        activityLevel: 'moderate',
      );
      final after = DateTime.now();
      final entryDate = result.weightHistory.first.date;
      expect(entryDate.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(entryDate.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  // ─── Repository calls ─────────────────────────────────────────────────────

  group('Repository interaction', () {
    test('calls repository.updateProfile exactly once', () async {
      await useCase(
        currentProfile: _baseProfile(),
        age: 30,
        gender: 'male',
        height: 175,
        weight: 70,
        activityLevel: 'moderate',
      );
      verify(() => mockRepo.updateProfile(any())).called(1);
    });

    test('updates currentWeight in saved profile', () async {
      HealthProfileModel? saved;
      when(() => mockRepo.updateProfile(any())).thenAnswer((inv) async {
        saved = inv.positionalArguments[0] as HealthProfileModel;
      });

      await useCase(
        currentProfile: _baseProfile(weight: 70),
        age: 30,
        gender: 'male',
        height: 175,
        weight: 73,
        activityLevel: 'moderate',
      );
      expect(saved?.currentWeight, 73);
    });
  });
}
