import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/datasources/apple_signin_datasource.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_user_datasource.dart';
import '../../data/datasources/google_signin_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_apple_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/password_reset_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';

// ============================================================================
// FIREBASE INSTANCES - Story 1.1
// ============================================================================

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firestore instance provider
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ============================================================================
// DATA SOURCES - Story 1.1
// ============================================================================

/// Firebase Auth data source provider
/// Story 1.1: Create Account with Email and Password
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthDataSource(auth);
});

/// Firestore User data source provider
/// Story 1.1: Create Account with Email and Password
final firestoreUserDataSourceProvider =
    Provider<FirestoreUserDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreUserDataSource(firestore);
});

/// Google Sign-In instance provider
/// Story 1.3: Login with OAuth (Google Sign-In)
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: [
      'openid',
      'email',
      'profile',
    ],
  );
});

/// Google Sign-In data source provider
/// Story 1.3: Login with OAuth (Google Sign-In)
final googleSignInDataSourceProvider = Provider<GoogleSignInDataSource>((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return GoogleSignInDataSource(googleSignIn, auth);
});

/// Apple Sign-In data source provider
/// Story 1.4: Login with OAuth Apple Sign-In
final appleSignInDataSourceProvider = Provider<AppleSignInDataSource>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AppleSignInDataSource(auth);
});

// ============================================================================
// REPOSITORY - Story 1.1
// ============================================================================

/// Auth repository provider
/// Story 1.1: Create Account with Email and Password
/// Story 1.3: Extended for Google Sign-In
///
/// Coordinates Firebase Auth, Firestore, and Google Sign-In operations.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authDataSource = ref.watch(firebaseAuthDataSourceProvider);
  final firestoreDataSource = ref.watch(firestoreUserDataSourceProvider);
  final googleSignInDataSource = ref.watch(googleSignInDataSourceProvider);
  final appleSignInDataSource = ref.watch(appleSignInDataSourceProvider);
  return AuthRepositoryImpl(
    authDataSource,
    firestoreDataSource,
    googleSignInDataSource,
    appleSignInDataSource,
  );
});

// ============================================================================
// USE CASES - Story 1.1
// ============================================================================

/// Signup use case provider
/// Story 1.1: Create Account with Email and Password
///
/// Validates input and creates new user account.
final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignupUseCase(repository);
});

/// Login use case provider
/// Story 1.2: Login with Email and Password
///
/// Validates input, authenticates user, checks account deletion status.
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Password reset use case provider
/// Story 1.2: Login with Email and Password
///
/// Sends password reset email via Firebase Auth.
final passwordResetUseCaseProvider = Provider<PasswordResetUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return PasswordResetUseCase(repository);
});

/// Login with Google use case provider
/// Story 1.3: Login with OAuth (Google Sign-In)
///
/// Handles Google OAuth2 authentication flow.
final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithGoogleUseCase(repository);
});

/// Login with Apple use case provider
/// Story 1.4: Login with OAuth Apple Sign-In
///
/// Handles Apple OAuth2 authentication flow (iOS only).
final loginWithAppleUseCaseProvider = Provider<LoginWithAppleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithAppleUseCase(repository);
});

// ============================================================================
// AUTH STATE - Story 1.1
// ============================================================================

/// Authentication state stream provider
/// Story 1.1: Create Account with Email and Password
///
/// Emits UserEntity? whenever auth state changes:
/// - User signs up → emits UserEntity
/// - User signs out → emits null
/// - Email verification changes → emits updated UserEntity
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// Current authenticated user provider
/// Story 1.1: Create Account with Email and Password
///
/// Returns the currently signed-in user, or null.
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

/// Is user authenticated provider
/// Story 1.1: Create Account with Email and Password
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value != null;
});

// ============================================================================
// LEGACY PROVIDERS - Story 0.4 Placeholder (to be migrated)
// ============================================================================

/// Provider pour le profil utilisateur complet
final userProfileProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

/// Provider pour l'état du onboarding (complété ou non)
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

/// Provider pour les caractéristiques physiques
final physicalCharacteristicsProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

/// Provider pour les préférences alimentaires
final dietaryPreferencesProvider = StateProvider<List<String>>((ref) => []);

/// Provider pour les allergies
final allergiesProvider = StateProvider<List<String>>((ref) => []);
