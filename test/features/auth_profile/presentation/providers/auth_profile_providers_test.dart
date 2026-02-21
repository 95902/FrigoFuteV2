import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/firebase_auth_datasource.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/firestore_user_datasource.dart';
import 'package:frigofute_v2/features/auth_profile/data/repositories/auth_repository_impl.dart';
import 'package:frigofute_v2/features/auth_profile/domain/repositories/auth_repository.dart';
import 'package:frigofute_v2/features/auth_profile/domain/usecases/signup_usecase.dart';
import 'package:frigofute_v2/features/auth_profile/presentation/providers/auth_profile_providers.dart';

import 'auth_profile_providers_test.mocks.dart';

@GenerateMocks([FirebaseAuth, FirebaseFirestore])
void main() {
  group('Auth Profile Providers', () {
    late ProviderContainer container;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();

      // Setup mocks with default behavior
      when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));
      when(mockAuth.currentUser).thenReturn(null);

      container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
          firebaseFirestoreProvider.overrideWithValue(mockFirestore),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Firebase Instances', () {
      test('firebaseAuthProvider should provide mocked FirebaseAuth', () {
        // Act
        final auth = container.read(firebaseAuthProvider);

        // Assert
        expect(auth, mockAuth);
      });

      test('firebaseFirestoreProvider should provide mocked Firestore', () {
        // Act
        final firestore = container.read(firebaseFirestoreProvider);

        // Assert
        expect(firestore, mockFirestore);
      });
    });

    group('Data Sources', () {
      test('firebaseAuthDataSourceProvider should create FirebaseAuthDataSource',
          () {
        // Act
        final dataSource = container.read(firebaseAuthDataSourceProvider);

        // Assert
        expect(dataSource, isA<FirebaseAuthDataSource>());
      });

      test(
          'firestoreUserDataSourceProvider should create FirestoreUserDataSource',
          () {
        // Act
        final dataSource = container.read(firestoreUserDataSourceProvider);

        // Assert
        expect(dataSource, isA<FirestoreUserDataSource>());
      });

      test('data sources should be singleton (same instance)', () {
        // Act
        final dataSource1 = container.read(firebaseAuthDataSourceProvider);
        final dataSource2 = container.read(firebaseAuthDataSourceProvider);

        // Assert
        expect(identical(dataSource1, dataSource2), true);
      });
    });

    group('Repository', () {
      test('authRepositoryProvider should create AuthRepositoryImpl', () {
        // Act
        final repository = container.read(authRepositoryProvider);

        // Assert
        expect(repository, isA<AuthRepository>());
        expect(repository, isA<AuthRepositoryImpl>());
      });

      test('repository should be singleton (same instance)', () {
        // Act
        final repository1 = container.read(authRepositoryProvider);
        final repository2 = container.read(authRepositoryProvider);

        // Assert
        expect(identical(repository1, repository2), true);
      });
    });

    group('Use Cases', () {
      test('signupUseCaseProvider should create SignupUseCase', () {
        // Act
        final useCase = container.read(signupUseCaseProvider);

        // Assert
        expect(useCase, isA<SignupUseCase>());
      });

      test('use case should be singleton (same instance)', () {
        // Act
        final useCase1 = container.read(signupUseCaseProvider);
        final useCase2 = container.read(signupUseCaseProvider);

        // Assert
        expect(identical(useCase1, useCase2), true);
      });
    });

    group('Auth State', () {
      test('isAuthenticatedProvider should return false when not authenticated',
          () {
        // Act
        final isAuthenticated = container.read(isAuthenticatedProvider);

        // Assert
        expect(isAuthenticated, false);
      });
    });

    group('Provider Dependencies', () {
      test('authRepositoryProvider should depend on data source providers', () {
        // This test verifies the dependency chain is correctly set up
        // by reading the repository and checking it was created

        // Act
        final repository = container.read(authRepositoryProvider);

        // Assert - If this doesn't throw, dependencies are correctly injected
        expect(repository, isNotNull);
      });

      test('signupUseCaseProvider should depend on authRepositoryProvider', () {
        // Act
        final useCase = container.read(signupUseCaseProvider);

        // Assert
        expect(useCase, isNotNull);
      });
    });

    group('Legacy Providers', () {
      test('userProfileProvider should provide null by default', () {
        // Act
        final userProfile = container.read(userProfileProvider);

        // Assert
        expect(userProfile, null);
      });

      test('onboardingCompletedProvider should provide false by default', () {
        // Act
        final completed = container.read(onboardingCompletedProvider);

        // Assert
        expect(completed, false);
      });

      test('physicalCharacteristicsProvider should provide null by default',
          () {
        // Act
        final characteristics =
            container.read(physicalCharacteristicsProvider);

        // Assert
        expect(characteristics, null);
      });

      test('dietaryPreferencesProvider should provide empty list by default',
          () {
        // Act
        final preferences = container.read(dietaryPreferencesProvider);

        // Assert
        expect(preferences, isEmpty);
      });

      test('allergiesProvider should provide empty list by default', () {
        // Act
        final allergies = container.read(allergiesProvider);

        // Assert
        expect(allergies, isEmpty);
      });
    });

    group('Provider State Management', () {
      test('userProfileProvider should allow state updates', () {
        // Arrange
        final testProfile = {'name': 'Test User', 'age': 30};

        // Act
        container.read(userProfileProvider.notifier).state = testProfile;
        final result = container.read(userProfileProvider);

        // Assert
        expect(result, testProfile);
      });

      test('onboardingCompletedProvider should allow state updates', () {
        // Act
        container.read(onboardingCompletedProvider.notifier).state = true;
        final result = container.read(onboardingCompletedProvider);

        // Assert
        expect(result, true);
      });

      test('dietaryPreferencesProvider should allow adding preferences', () {
        // Arrange
        final preferences = ['vegetarian', 'gluten-free'];

        // Act
        container.read(dietaryPreferencesProvider.notifier).state =
            preferences;
        final result = container.read(dietaryPreferencesProvider);

        // Assert
        expect(result, preferences);
      });
    });
  });
}
