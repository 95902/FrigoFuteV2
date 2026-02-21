import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/auth_profile/data/models/user_model.dart';
import 'package:frigofute_v2/features/auth_profile/data/models/subscription_model.dart';
import 'package:frigofute_v2/features/auth_profile/data/models/consent_model.dart';

/// Unit tests for UserModel serialization
/// Story 1.1: Create Account with Email and Password
void main() {
  group('UserModel', () {
    final testDate = DateTime(2026, 2, 20);
    final testModel = UserModel(
      userId: 'test-uid-123',
      email: 'test@example.com',
      createdAt: testDate,
      emailVerified: false,
      subscription: SubscriptionModel(
        status: 'free',
        startDate: testDate,
        isPremium: false,
      ),
      consentGiven: const ConsentModel(
        termsOfService: true,
        privacyPolicy: true,
        healthData: false,
        analytics: false,
      ),
      firstName: 'Test',
      lastName: 'User',
      profileType: 'Famille',
      accountDeleted: false,
    );

    group('toJson()', () {
      test('should serialize UserModel to JSON correctly', () {
        final json = testModel.toJson();

        expect(json['userId'], 'test-uid-123');
        expect(json['email'], 'test@example.com');
        expect(json['emailVerified'], false);
        expect(json['firstName'], 'Test');
        expect(json['lastName'], 'User');
        expect(json['profileType'], 'Famille');
        expect(json['accountDeleted'], false);

        // Check nested objects
        expect(json['subscription'], isA<Map>());
        expect(json['subscription']['status'], 'free');
        expect(json['subscription']['isPremium'], false);

        expect(json['consentGiven'], isA<Map>());
        expect(json['consentGiven']['termsOfService'], true);
        expect(json['consentGiven']['privacyPolicy'], true);
        expect(json['consentGiven']['healthData'], false);
      });

      test('should convert DateTime to Firestore Timestamp', () {
        final json = testModel.toJson();

        expect(json['createdAt'], isA<Timestamp>());
        final timestamp = json['createdAt'] as Timestamp;
        expect(timestamp.toDate().year, 2026);
        expect(timestamp.toDate().month, 2);
        expect(timestamp.toDate().day, 20);
      });
    });

    group('fromJson()', () {
      test('should deserialize JSON to UserModel correctly', () {
        final json = {
          'userId': 'test-uid-456',
          'email': 'user@example.fr',
          'createdAt': Timestamp.fromDate(testDate),
          'emailVerified': true,
          'subscription': {
            'status': 'premium',
            'startDate': Timestamp.fromDate(testDate),
            'isPremium': true,
          },
          'consentGiven': {
            'termsOfService': true,
            'privacyPolicy': true,
            'healthData': true,
            'analytics': true,
          },
          'firstName': 'Sophie',
          'lastName': 'Martin',
          'profileType': 'Sportif',
          'accountDeleted': false,
        };

        final model = UserModel.fromJson(json);

        expect(model.userId, 'test-uid-456');
        expect(model.email, 'user@example.fr');
        expect(model.emailVerified, true);
        expect(model.firstName, 'Sophie');
        expect(model.lastName, 'Martin');
        expect(model.profileType, 'Sportif');
        expect(model.accountDeleted, false);

        expect(model.subscription.status, 'premium');
        expect(model.subscription.isPremium, true);

        expect(model.consentGiven.termsOfService, true);
        expect(model.consentGiven.healthData, true);
      });

      test('should handle missing optional fields with defaults', () {
        final json = {
          'userId': 'test-uid-789',
          'email': 'minimal@example.com',
          'createdAt': Timestamp.fromDate(testDate),
          'emailVerified': false,
          'subscription': {
            'status': 'free',
            'startDate': Timestamp.fromDate(testDate),
          },
          'consentGiven': {
            'termsOfService': true,
            'privacyPolicy': true,
          },
        };

        final model = UserModel.fromJson(json);

        expect(model.firstName, ''); // Default value
        expect(model.lastName, ''); // Default value
        expect(model.profileType, ''); // Default value
        expect(model.accountDeleted, false); // Default value
        expect(model.subscription.isPremium, false); // Default
        expect(model.consentGiven.healthData, false); // Default
        expect(model.consentGiven.analytics, false); // Default
      });
    });

    group('Timestamp conversion', () {
      test('should handle Timestamp in fromJson', () {
        final timestamp = Timestamp.fromDate(testDate);
        final json = {
          'userId': 'test-uid',
          'email': 'test@example.com',
          'createdAt': timestamp,
          'emailVerified': false,
          'subscription': {
            'status': 'free',
            'startDate': timestamp,
          },
          'consentGiven': {
            'termsOfService': true,
            'privacyPolicy': true,
          },
        };

        final model = UserModel.fromJson(json);

        expect(model.createdAt.year, testDate.year);
        expect(model.createdAt.month, testDate.month);
        expect(model.createdAt.day, testDate.day);
      });

      test('should handle milliseconds int in fromJson', () {
        final json = {
          'userId': 'test-uid',
          'email': 'test@example.com',
          'createdAt': testDate.millisecondsSinceEpoch,
          'emailVerified': false,
          'subscription': {
            'status': 'free',
            'startDate': testDate.millisecondsSinceEpoch,
          },
          'consentGiven': {
            'termsOfService': true,
            'privacyPolicy': true,
          },
        };

        final model = UserModel.fromJson(json);

        expect(model.createdAt.year, testDate.year);
      });

      test('should handle ISO string in fromJson', () {
        final json = {
          'userId': 'test-uid',
          'email': 'test@example.com',
          'createdAt': testDate.toIso8601String(),
          'emailVerified': false,
          'subscription': {
            'status': 'free',
            'startDate': testDate.toIso8601String(),
          },
          'consentGiven': {
            'termsOfService': true,
            'privacyPolicy': true,
          },
        };

        final model = UserModel.fromJson(json);

        expect(model.createdAt.year, testDate.year);
      });
    });
  });
}
