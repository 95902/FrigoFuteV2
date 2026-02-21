import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frigofute_v2/features/onboarding/domain/models/onboarding_state.dart';
import 'package:frigofute_v2/features/onboarding/presentation/providers/onboarding_notifier.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

OnboardingNotifier _buildNotifier({
  required FirebaseFirestore firestore,
  String userId = 'test-user',
  Future<void> Function(Duration)? delay,
}) {
  return OnboardingNotifier(firestore, userId, delay: delay);
}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();

    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
    when(() => mockDocRef.update(any())).thenAnswer((_) async {});
  });

  // ─── Initial State ─────────────────────────────────────────────────────────

  group('Initial state', () {
    test('starts at page 0 with 3 steps (waste profile)', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      expect(notifier.state.currentPageIndex, 0);
      expect(notifier.state.visibleSteps.length, 3);
      expect(notifier.state.visibleSteps.first, OnboardingStep.welcome);
      expect(notifier.state.visibleSteps.last, OnboardingStep.success);
    });

    test('formData starts empty', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      expect(notifier.state.formData, isEmpty);
    });

    test('isLoading starts false', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      expect(notifier.state.isLoading, isFalse);
    });
  });

  // ─── Navigation ───────────────────────────────────────────────────────────

  group('Navigation', () {
    test('goToNextPage increments currentPageIndex', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.goToNextPage();
      expect(notifier.state.currentPageIndex, 1);
    });

    test('goToNextPage does not exceed last page', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.jumpToPage(2); // last page of 3-step flow
      notifier.goToNextPage();
      expect(notifier.state.currentPageIndex, 2); // unchanged
    });

    test('goToPreviousPage decrements currentPageIndex', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.goToNextPage();
      notifier.goToPreviousPage();
      expect(notifier.state.currentPageIndex, 0);
    });

    test('goToPreviousPage does not go below 0', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.goToPreviousPage();
      expect(notifier.state.currentPageIndex, 0);
    });

    test('jumpToPage sets exact index', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.jumpToPage(2);
      expect(notifier.state.currentPageIndex, 2);
    });

    test('jumpToPage ignores out-of-range index', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.jumpToPage(99);
      expect(notifier.state.currentPageIndex, 0);
    });
  });

  // ─── Form Data ────────────────────────────────────────────────────────────

  group('updateFormField', () {
    test('stores value under given key', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.updateFormField('profileType', 'nutrition');
      expect(notifier.state.formData['profileType'], 'nutrition');
    });

    test('preserves existing keys when updating', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.updateFormField('a', 1);
      notifier.updateFormField('b', 2);
      expect(notifier.state.formData['a'], 1);
      expect(notifier.state.formData['b'], 2);
    });
  });

  // ─── Adaptive Flow ────────────────────────────────────────────────────────

  group('setProfileType', () {
    test('waste → 3 visible steps', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.setProfileType('waste');
      expect(notifier.state.visibleSteps.length, 3);
      expect(notifier.state.visibleSteps, [
        OnboardingStep.welcome,
        OnboardingStep.profileType,
        OnboardingStep.success,
      ]);
    });

    test('nutrition → 6 visible steps including nutrition steps', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.setProfileType('nutrition');
      expect(notifier.state.visibleSteps.length, 6);
      expect(notifier.state.visibleSteps.contains(OnboardingStep.physicalCharacteristics), isTrue);
      expect(notifier.state.visibleSteps.contains(OnboardingStep.dietaryPreferences), isTrue);
      expect(notifier.state.visibleSteps.contains(OnboardingStep.nutritionalGoals), isTrue);
    });

    test('meal_planning → 6 visible steps', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.setProfileType('meal_planning');
      expect(notifier.state.visibleSteps.length, 6);
    });

    test('switching from nutrition to waste clears nutrition data (AC13)', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.setProfileType('nutrition');
      notifier.updateFormField(
        'physicalCharacteristics',
        {'age': 30, 'gender': 'male', 'height': 175, 'weight': 70.0, 'activityLevel': 'moderate'},
      );
      notifier.updateFormField('dietaryPreferences', {'restrictions': <String>[]});
      notifier.updateFormField('nutritionalGoals', {'selectedGoal': 'muscle_gain'});

      // Switch back to waste
      notifier.setProfileType('waste');
      expect(notifier.state.formData.containsKey('physicalCharacteristics'), isFalse);
      expect(notifier.state.formData.containsKey('dietaryPreferences'), isFalse);
      expect(notifier.state.formData.containsKey('nutritionalGoals'), isFalse);
    });

    test('setProfileType saves profileType in formData', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.setProfileType('all');
      expect(notifier.state.formData['profileType'], 'all');
    });
  });

  // ─── BMR / TDEE Calculations ──────────────────────────────────────────────

  group('calculateBmr', () {
    test('male 30y 175cm 70kg ≈ 1724 kcal', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      final bmr = notifier.calculateBmr(
        age: 30,
        gender: 'male',
        height: 175,
        weight: 70.0,
      );
      // (10*70) + (6.25*175) - (5*30) + 5 = 700+1093.75-150+5 = 1648.75
      expect(bmr, closeTo(1648.75, 1.0));
    });

    test('female 25y 165cm 60kg', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      final bmr = notifier.calculateBmr(
        age: 25,
        gender: 'female',
        height: 165,
        weight: 60.0,
      );
      // (10*60) + (6.25*165) - (5*25) - 161 = 600+1031.25-125-161 = 1345.25
      expect(bmr, closeTo(1345.25, 1.0));
    });

    test('non-male gender uses female formula', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      final bmrOther = notifier.calculateBmr(age: 30, gender: 'other', height: 170, weight: 65.0);
      final bmrFemale = notifier.calculateBmr(age: 30, gender: 'female', height: 170, weight: 65.0);
      expect(bmrOther, closeTo(bmrFemale, 0.01));
    });
  });

  group('calculateTdee', () {
    test('sedentary multiplier = 1.2', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      final tdee = notifier.calculateTdee(1500.0, 'sedentary');
      expect(tdee, closeTo(1800.0, 0.01));
    });

    test('moderate multiplier = 1.55', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      final tdee = notifier.calculateTdee(1500.0, 'moderate');
      expect(tdee, closeTo(2325.0, 0.01));
    });

    test('unknown level defaults to moderate (1.55)', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      final tdee = notifier.calculateTdee(1000.0, 'unknown');
      expect(tdee, closeTo(1550.0, 0.01));
    });
  });

  group('calculateMacroTargets', () {
    test('maintenance goal returns calories = targetCalories', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      final macros = notifier.calculateMacroTargets(
        targetCalories: 2000.0,
        weight: 70.0,
        goalId: 'maintenance',
      );
      expect(macros['calories'], closeTo(2000.0, 0.01));
    });

    test('all macro keys present', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      final macros = notifier.calculateMacroTargets(
        targetCalories: 2500.0,
        weight: 80.0,
        goalId: 'muscle_gain',
      );
      expect(macros.containsKey('calories'), isTrue);
      expect(macros.containsKey('protein'), isTrue);
      expect(macros.containsKey('carbs'), isTrue);
      expect(macros.containsKey('fats'), isTrue);
    });

    test('macro calories sum approximately equals targetCalories', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      final target = 2200.0;
      final macros = notifier.calculateMacroTargets(
        targetCalories: target,
        weight: 75.0,
        goalId: 'general_health',
      );
      final totalFromMacros = (macros['protein']! * 4) +
          (macros['carbs']! * 4) +
          (macros['fats']! * 9);
      expect(totalFromMacros, closeTo(target, 5.0)); // tolerance 5 kcal
    });
  });

  // ─── completeOnboarding ───────────────────────────────────────────────────

  group('completeOnboarding', () {
    test('sets isLoading then clears it on success', () async {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.updateFormField('profileType', 'waste');

      await notifier.completeOnboarding();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, '');
    });

    test('calls Firestore update with correct fields', () async {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.updateFormField('profileType', 'waste');

      await notifier.completeOnboarding();

      verify(() => mockDocRef.update(any(
            that: predicate<Map<String, dynamic>>(
              (data) =>
                  data['profileType'] == 'waste' &&
                  data['onboardingCompleted'] == true,
            ),
          ))).called(1);
    });

    test('sets errorMessage on Firestore failure', () async {
      when(() => mockDocRef.update(any())).thenThrow(
        FirebaseException(plugin: 'firestore', message: 'Network error'),
      );

      final notifier = _buildNotifier(
        firestore: mockFirestore,
        delay: (_) async {}, // M4: skip real retry delays in tests
      );
      notifier.updateFormField('profileType', 'waste');

      await expectLater(
        notifier.completeOnboarding(),
        throwsA(isA<Exception>()),
      );

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNotEmpty);
    });
  });

  // ─── reset / clearError ───────────────────────────────────────────────────

  group('reset and clearError', () {
    test('reset returns to initial 3-step state', () {
      final notifier = _buildNotifier(firestore: mockFirestore);
      notifier.setProfileType('nutrition');
      notifier.goToNextPage();
      notifier.reset();

      expect(notifier.state.currentPageIndex, 0);
      expect(notifier.state.visibleSteps.length, 3);
      expect(notifier.state.formData, isEmpty);
    });

    test('clearError clears errorMessage', () async {
      when(() => mockDocRef.update(any())).thenThrow(
        FirebaseException(plugin: 'firestore', message: 'err'),
      );

      final notifier = _buildNotifier(
        firestore: mockFirestore,
        delay: (_) async {}, // M4: skip real retry delays in tests
      );
      notifier.updateFormField('profileType', 'waste');

      try {
        await notifier.completeOnboarding();
      } catch (_) {}

      expect(notifier.state.errorMessage, isNotEmpty);
      notifier.clearError();
      expect(notifier.state.errorMessage, '');
    });
  });
}
