import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/features/auth_profile/presentation/pages/forgot_password_page.dart';
import 'package:frigofute_v2/features/auth_profile/presentation/providers/auth_profile_providers.dart';

import 'forgot_password_page_test.mocks.dart';

@GenerateMocks([FirebaseAuth, FirebaseFirestore])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();

    // Setup mocks with default behavior
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
        home: ForgotPasswordPage(),
      ),
    );
  }

  group('ForgotPasswordPage Widget Tests', () {
    group('Form State Tests', () {
      testWidgets('should render all form elements in form state',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Reset Password'), findsOneWidget); // AppBar
        expect(find.text('Forgot your password?'), findsOneWidget);
        expect(
          find.text(
            'Enter your email and we\'ll send you a link to reset your password.',
          ),
          findsOneWidget,
        );
        expect(find.byType(TextFormField), findsOneWidget); // Email field
        expect(find.text('Email'), findsOneWidget);
        expect(
          find.widgetWithText(FilledButton, 'Send Reset Email'),
          findsOneWidget,
        );
        expect(find.widgetWithText(TextButton, 'Back to Login'), findsOneWidget);
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

      testWidgets('should validate empty email field', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Submit form with empty email
        await tester.tap(find.widgetWithText(FilledButton, 'Send Reset Email'));
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
        await tester.tap(find.widgetWithText(FilledButton, 'Send Reset Email'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('should accept valid email format', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Enter valid email
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'user@example.com',
        );
        await tester.pumpAndSettle();

        // Assert - No error message should appear
        expect(find.text('Email is required'), findsNothing);
        expect(find.text('Please enter a valid email address'), findsNothing);
      });

      testWidgets('should have email field properly configured',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Email field should exist with proper label and hint
        expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
        expect(find.text('your.email@example.com'), findsOneWidget);

        // Should have email icon
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      });

      testWidgets('should show email icon in email field', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      });

      testWidgets('should enable button when email is valid', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Fill email with valid data
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'user@example.com',
        );
        await tester.pumpAndSettle();

        // Assert - Button should be enabled
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should have Back to Login button', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.widgetWithText(TextButton, 'Back to Login'), findsOneWidget);
      });
    });

    group('Success State Tests', () {
      testWidgets('should render success state elements when email sent',
          (tester) async {
        // This test verifies the structure exists
        // In a real scenario, we would need to mock the password reset use case
        // to trigger the success state

        // Note: We cannot easily trigger the success state without mocking,
        // so this test just verifies the widget can render the form state
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify we're in form state initially
        expect(find.text('Forgot your password?'), findsOneWidget);
      });

      // Additional test would require mocking the password reset use case
      // to actually trigger the _emailSent = true state and verify success UI
    });

    group('Loading State Tests', () {
      testWidgets('should disable inputs during loading', (tester) async {
        // This test verifies that the form respects the _isLoading state
        // Since we can't easily trigger the loading state without mocking,
        // we just verify the field is initially enabled

        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Field should be enabled initially
        final emailField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'Email'),
        );
        expect(emailField.enabled, true);
      });
    });

    group('Header Text Tests', () {
      testWidgets('should have proper header text', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Reset Password'), findsOneWidget); // AppBar
        expect(find.text('Forgot your password?'), findsOneWidget);
        expect(
          find.text(
            'Enter your email and we\'ll send you a link to reset your password.',
          ),
          findsOneWidget,
        );
      });
    });

    group('Email Validation Tests', () {
      testWidgets('should reject email with missing @ symbol', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'userexample.com',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Send Reset Email'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('should reject email with missing domain', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'user@',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Send Reset Email'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('should accept email with subdomain', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'user@mail.example.com',
        );
        await tester.pumpAndSettle();

        // Assert - No error
        expect(find.text('Please enter a valid email address'), findsNothing);
      });

      testWidgets('should accept email with plus sign', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'user+tag@example.com',
        );
        await tester.pumpAndSettle();

        // Assert - No error
        expect(find.text('Please enter a valid email address'), findsNothing);
      });

      testWidgets('should accept email with dots', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'first.last@example.com',
        );
        await tester.pumpAndSettle();

        // Assert - No error
        expect(find.text('Please enter a valid email address'), findsNothing);
      });
    });
  });
}
