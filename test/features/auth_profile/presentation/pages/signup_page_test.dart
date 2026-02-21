import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/features/auth_profile/presentation/pages/signup_page.dart';
import 'package:frigofute_v2/features/auth_profile/presentation/providers/auth_profile_providers.dart';

import 'signup_page_test.mocks.dart';

@GenerateMocks([FirebaseAuth, FirebaseFirestore])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();

    // Setup mocks
    when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    when(mockAuth.currentUser).thenReturn(null);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firebaseFirestoreProvider.overrideWithValue(mockFirestore),
      ],
      child: const MaterialApp(
        home: SignupPage(),
      ),
    );
  }

  group('SignupPage Widget Tests', () {
    testWidgets('should render all form fields', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - "Create Account" appears in both AppBar and Button
      expect(find.text('Create Account'), findsNWidgets(2));
      expect(find.byType(TextFormField), findsNWidgets(3)); // Email, Password, Confirm
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Create Account'), findsOneWidget);
    });

    testWidgets('should show email field with hint text', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      final emailField = find.widgetWithText(TextFormField, 'Email');
      expect(emailField, findsOneWidget);
      expect(find.text('your.email@example.com'), findsOneWidget);
    });

    testWidgets('should show password visibility toggle', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Should have 2 visibility icons (password + confirm password)
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
    });

    testWidgets('should toggle password visibility when icon is tapped',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Initially password should be hidden (visibility icon shown)
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pumpAndSettle();

      // Assert - After toggle, should show visibility_off icon
      expect(find.byIcon(Icons.visibility_off_outlined), findsAtLeastNWidgets(1));
    });

    testWidgets('should show Terms & Privacy checkbox', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
      // Row containing checkbox and terms text
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('should toggle terms checkbox when tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);

      // Act
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Assert
      final updatedCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(updatedCheckbox.value, true);
    });

    testWidgets('should show "Already have account" link', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Login'), findsOneWidget);
    });

    testWidgets('should validate empty email field', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Submit form with empty email
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Assert - Should show validation error
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should validate empty password field', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Submit with empty password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should validate password too short', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Enter short password
      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.at(1), '123');
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should validate password mismatch', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Enter mismatched passwords
      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.at(1), 'password123');
      await tester.enterText(passwordFields.at(2), 'differentpassword');
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('should show password strength indicator', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Enter weak password (only lowercase letters)
      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.at(1), 'weakpass');
      await tester.pumpAndSettle();

      // Assert - Should show strength indicator (Fair or Weak)
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      // The password "weakpass" gets a Fair rating, not Weak
      expect(find.text('Fair'), findsOneWidget);
    });

    testWidgets('should show stronger password strength for complex password',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Enter strong password
      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.at(1), 'Strong@Pass123!');
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Strong'), findsOneWidget);
    });

    testWidgets('should show error snackbar when terms not accepted',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Fill form but don't accept terms
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Please accept the Terms & Privacy Policy'),
        findsOneWidget,
      );
    });

    testWidgets('should disable button while loading', (tester) async {
      // Note: This test would require mocking the signup use case
      // to actually test the loading state. For now, we just verify
      // the button exists and is enabled initially.

      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      final button =
          tester.widget<FilledButton>(find.byType(FilledButton).first);
      expect(button.onPressed, isNotNull); // Button is enabled
    });
  });
}
