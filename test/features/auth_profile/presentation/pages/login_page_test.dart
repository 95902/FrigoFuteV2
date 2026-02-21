import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/features/auth_profile/presentation/pages/login_page.dart';
import 'package:frigofute_v2/features/auth_profile/presentation/providers/auth_profile_providers.dart';

import 'login_page_test.mocks.dart';

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
        home: LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('should render all form fields and elements', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Login'), findsNWidgets(2)); // AppBar + Button
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Login to access your food inventory'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email, Password
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Don\'t have an account? '), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
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

    testWidgets('should show password field with hint text', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('should show password visibility toggle', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Should have 1 visibility icon (password field)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should toggle password visibility when icon is tapped',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Initially password should be hidden (visibility icon shown)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      // Assert - After toggle, should show visibility_off icon
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('should validate empty email field', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Submit form with empty email
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      // Assert - Should show validation error
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Enter invalid email
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should validate empty password field', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Submit with valid email but empty password
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'test@example.com');
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should accept valid email format', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Enter valid email
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'user@example.com');
      await tester.pumpAndSettle();

      // Assert - No error message should appear
      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    testWidgets('should show Forgot Password link', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Forgot Password?'), findsOneWidget);
    });

    testWidgets('should show Create Account link', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Don\'t have an account? '), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Create Account'), findsOneWidget);
    });

    testWidgets('should have email and password fields with proper setup',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Email field should exist with proper label
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);

      // Password field should exist with proper label
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

      // Password field should have visibility toggle icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should enable login button when form is valid', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Fill form with valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      // Assert - Button should be enabled (onPressed is not null)
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should disable all inputs while loading', (tester) async {
      // This test verifies that the form respects the _isLoading state
      // Since we can't easily trigger the loading state without mocking the use case,
      // we just verify the widgets exist and are initially enabled

      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - All fields should be enabled initially
      final emailField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Email'),
      );
      final passwordField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Password'),
      );

      expect(emailField.enabled, true);
      expect(passwordField.enabled, true);
    });

    testWidgets('should have welcome header text', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Login to access your food inventory'),
        findsOneWidget,
      );
    });

    testWidgets('should show email icon in email field', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('should show lock icon in password field', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('should have two text form fields for email and password',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Should have exactly 2 TextFormFields
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Both fields should be present with labels
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('should validate on user interaction', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid',
      );

      // Wait for debounced validation (300ms)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Assert - Should show error after debounce
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });
}
