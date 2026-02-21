import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/subscription_model.dart';
import '../models/consent_model.dart';

/// Firestore User data source
/// Story 1.1: Create Account with Email and Password
///
/// Handles Firestore operations for user documents.
class FirestoreUserDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserDataSource(this._firestore);

  /// Creates a new user document in Firestore.
  ///
  /// Collection: `users/{userId}`
  ///
  /// Default values:
  /// - subscription: `free` tier
  /// - consentGiven: Terms & Privacy accepted (required for signup)
  /// - emailVerified: `false` (updated when user verifies email)
  ///
  /// Also creates a consent audit log for RGPD compliance.
  Future<void> createUserDocument(String userId, String email) async {
    final now = DateTime.now();

    final userDoc = UserModel(
      userId: userId,
      email: email,
      createdAt: now,
      emailVerified: false,
      subscription: SubscriptionModel(
        status: 'free',
        startDate: now,
        isPremium: false,
      ),
      consentGiven: const ConsentModel(
        termsOfService: true,
        privacyPolicy: true,
        healthData: false,
        analytics: false,
      ),
      firstName: '',
      lastName: '',
      profileType: '',
      accountDeleted: false,
    );

    // Use server timestamp for createdAt to avoid client clock skew
    final userJson = userDoc.toJson();
    userJson['createdAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(userId).set(userJson);

    // Create consent audit log (RGPD compliance)
    await _createConsentLog(userId, 'initial_signup');
  }

  /// Creates a consent audit log (RGPD compliance).
  ///
  /// Collection: `users/{userId}/consent_logs/{logId}`
  ///
  /// Logs user consent actions for RGPD Article 7 compliance:
  /// - `initial_signup`: User accepted terms during account creation
  /// - `consent_updated`: User changed consent preferences
  /// - `account_deleted`: User requested account deletion
  ///
  /// These logs are immutable and must be kept for audit purposes.
  Future<void> _createConsentLog(String userId, String action) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('consent_logs')
        .add({
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
      'termsOfService': true,
      'privacyPolicy': true,
      'healthData': false,
      'analytics': false,
    });
  }

  /// Retrieves a user document from Firestore.
  ///
  /// Returns `null` if the user document doesn't exist.
  Future<UserModel?> getUserDocument(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromJson(doc.data()!);
  }

  // Story 1.3: Login with OAuth (Google Sign-In)

  /// Creates Firestore user document from Google profile data.
  ///
  /// Called on first-time Google Sign-In.
  /// Parses Google displayName into firstName/lastName.
  /// Email is already verified by Google.
  Future<UserModel> createUserDocumentFromGoogle({
    required String userId,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    final now = DateTime.now();

    // Parse displayName into firstName and lastName
    final nameParts = displayName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final userDoc = UserModel(
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      photoUrl: photoUrl ?? '',
      createdAt: now,
      emailVerified: true, // Google verifies email
      authProvider: 'google', // Track auth method
      subscription: SubscriptionModel(
        status: 'free',
        startDate: now,
        isPremium: false,
      ),
      consentGiven: const ConsentModel(
        termsOfService: true,
        privacyPolicy: true,
        healthData: false,
        analytics: false,
      ),
      profileType: '', // To be filled during onboarding
      accountDeleted: false,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .set(userDoc.toJson());

    // Create consent audit log
    await _createConsentLog(userId, 'google_signin');

    return userDoc;
  }

  // Story 1.4: Login with OAuth Apple Sign-In

  /// Creates Firestore user document from Apple Sign-In data.
  ///
  /// IMPORTANT:
  /// - Apple only provides firstName/lastName on FIRST sign-in
  /// - Subsequent sign-ins return null for name — Firestore retains existing name
  /// - Apple does NOT provide a profile photo (photoUrl always empty)
  /// - Email may be Apple private relay (xyz@privaterelay.appleid.com)
  Future<UserModel> createUserDocumentFromApple({
    required String userId,
    required String email,
    String firstName = '',
    String lastName = '',
  }) async {
    final now = DateTime.now();

    final userDoc = UserModel(
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      photoUrl: '', // Apple does NOT provide profile photos
      createdAt: now,
      emailVerified: true, // Apple pre-verifies emails
      authProvider: 'apple',
      subscription: SubscriptionModel(
        status: 'free',
        startDate: now,
        isPremium: false,
      ),
      consentGiven: const ConsentModel(
        termsOfService: true,
        privacyPolicy: true,
        healthData: false,
        analytics: false,
      ),
      profileType: '', // Empty → triggers onboarding
      accountDeleted: false,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .set(userDoc.toJson());

    // Create consent audit log
    await _createConsentLog(userId, 'apple_signin');

    return userDoc;
  }

  // Story 1.2: Login with Email and Password

  /// Gets user document by ID (throws if not found).
  ///
  /// Used during login to fetch user profile and check account status.
  ///
  /// Throws [Exception] if user document doesn't exist.
  Future<UserModel> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw Exception('User document not found for userId: $userId');
    }

    return UserModel.fromJson(doc.data()!);
  }

  /// Updates user profile fields.
  ///
  /// Used for Story 1.6: Configure Personal Profile
  Future<void> updateUserProfile(
    String userId, {
    String? firstName,
    String? lastName,
    String? profileType,
  }) async {
    final updates = <String, dynamic>{};

    if (firstName != null) updates['firstName'] = firstName;
    if (lastName != null) updates['lastName'] = lastName;
    if (profileType != null) updates['profileType'] = profileType;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(userId).update(updates);
    }
  }

  /// Updates email verification status.
  ///
  /// Called when Firebase Auth detects email verification.
  Future<void> updateEmailVerificationStatus(
    String userId,
    bool emailVerified,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'emailVerified': emailVerified,
    });
  }
}
