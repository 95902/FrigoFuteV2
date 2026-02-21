import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/firestore_user_datasource.dart';
import 'package:frigofute_v2/features/auth_profile/data/models/user_model.dart';

import 'firestore_user_datasource_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late FirestoreUserDataSource dataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
  late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
  late MockCollectionReference<Map<String, dynamic>> mockConsentLogsCollection;
  late MockDocumentReference<Map<String, dynamic>> mockConsentLogDoc;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
    mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
    mockConsentLogsCollection = MockCollectionReference<Map<String, dynamic>>();
    mockConsentLogDoc = MockDocumentReference<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    dataSource = FirestoreUserDataSource(mockFirestore);
  });

  group('FirestoreUserDataSource', () {
    const testUserId = 'test-user-123';
    const testEmail = 'test@example.com';

    group('createUserDocument()', () {
      setUp(() {
        // Mock collection chain: firestore.collection('users')
        when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(mockUsersCollection.doc(any)).thenReturn(mockUserDoc);
        when(mockUserDoc.set(any)).thenAnswer((_) async => {});

        // Mock consent_logs subcollection
        when(mockUserDoc.collection('consent_logs'))
            .thenReturn(mockConsentLogsCollection);
        when(mockConsentLogsCollection.add(any))
            .thenAnswer((_) async => mockConsentLogDoc);
      });

      test('should create user document with correct data', () async {
        // Act
        await dataSource.createUserDocument(testUserId, testEmail);

        // Assert
        // Note: collection('users') is called twice:
        // 1. For user document creation
        // 2. For consent_logs subcollection creation
        verify(mockFirestore.collection('users')).called(2);
        verify(mockUsersCollection.doc(testUserId)).called(2);

        final captured =
            verify(mockUserDoc.set(captureAny)).captured.single as Map;

        expect(captured['userId'], testUserId);
        expect(captured['email'], testEmail);
        expect(captured['emailVerified'], false);
        expect(captured['subscription']['status'], 'free');
        expect(captured['subscription']['isPremium'], false);
        expect(captured['consentGiven']['termsOfService'], true);
        expect(captured['consentGiven']['privacyPolicy'], true);
        expect(captured['consentGiven']['healthData'], false);
        expect(captured['consentGiven']['analytics'], false);
      });

      test('should create consent audit log after user document', () async {
        // Act
        await dataSource.createUserDocument(testUserId, testEmail);

        // Assert
        verify(mockUserDoc.collection('consent_logs')).called(1);

        final captured =
            verify(mockConsentLogsCollection.add(captureAny)).captured.single
                as Map;

        expect(captured['action'], 'initial_signup');
        expect(captured['termsOfService'], true);
        expect(captured['privacyPolicy'], true);
        expect(captured['healthData'], false);
        expect(captured['analytics'], false);
        expect(captured['timestamp'], isA<FieldValue>());
      });
    });

    group('getUserDocument()', () {
      test('should return UserModel when document exists', () async {
        // Arrange
        final testData = {
          'userId': testUserId,
          'email': testEmail,
          'createdAt': Timestamp.now(),
          'emailVerified': false,
          'subscription': {
            'status': 'free',
            'startDate': Timestamp.now(),
            'isPremium': false,
          },
          'consentGiven': {
            'termsOfService': true,
            'privacyPolicy': true,
            'healthData': false,
            'analytics': false,
          },
          'firstName': '',
          'lastName': '',
          'profileType': '',
          'accountDeleted': false,
        };

        when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(mockUsersCollection.doc(testUserId)).thenReturn(mockUserDoc);
        when(mockUserDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.data()).thenReturn(testData);

        // Act
        final result = await dataSource.getUserDocument(testUserId);

        // Assert
        expect(result, isA<UserModel>());
        expect(result?.userId, testUserId);
        expect(result?.email, testEmail);
      });

      test('should return null when document does not exist', () async {
        // Arrange
        when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(mockUsersCollection.doc(testUserId)).thenReturn(mockUserDoc);
        when(mockUserDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(mockDocSnapshot.exists).thenReturn(false);

        // Act
        final result = await dataSource.getUserDocument(testUserId);

        // Assert
        expect(result, null);
      });
    });

    group('updateUserProfile()', () {
      setUp(() {
        when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(mockUsersCollection.doc(testUserId)).thenReturn(mockUserDoc);
        when(mockUserDoc.update(any)).thenAnswer((_) async => {});
      });

      test('should update only provided fields', () async {
        // Act
        await dataSource.updateUserProfile(
          testUserId,
          firstName: 'John',
          lastName: 'Doe',
        );

        // Assert
        final captured =
            verify(mockUserDoc.update(captureAny)).captured.single as Map;

        expect(captured['firstName'], 'John');
        expect(captured['lastName'], 'Doe');
        expect(captured.containsKey('profileType'), false);
      });

      test('should not call update when no fields are provided', () async {
        // Act
        await dataSource.updateUserProfile(testUserId);

        // Assert
        verifyNever(mockUserDoc.update(any));
      });

      test('should update profileType when provided', () async {
        // Act
        await dataSource.updateUserProfile(
          testUserId,
          profileType: 'Famille',
        );

        // Assert
        final captured =
            verify(mockUserDoc.update(captureAny)).captured.single as Map;

        expect(captured['profileType'], 'Famille');
        expect(captured.containsKey('firstName'), false);
        expect(captured.containsKey('lastName'), false);
      });
    });

    group('updateEmailVerificationStatus()', () {
      test('should update emailVerified field', () async {
        // Arrange
        when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(mockUsersCollection.doc(testUserId)).thenReturn(mockUserDoc);
        when(mockUserDoc.update(any)).thenAnswer((_) async => {});

        // Act
        await dataSource.updateEmailVerificationStatus(testUserId, true);

        // Assert
        final captured =
            verify(mockUserDoc.update(captureAny)).captured.single as Map;

        expect(captured['emailVerified'], true);
      });
    });
  });
}
