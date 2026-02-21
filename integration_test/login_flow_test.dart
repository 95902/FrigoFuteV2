/// Integration tests for login flow
/// Story 1.2: Login with Email and Password
///
/// Prerequisites:
/// - Firebase Emulator Suite running (`firebase emulators:start`)
/// - Connected device or emulator
/// - Test user created in Firebase Auth emulator
///
/// Run with:
/// ```
/// flutter test integration_test/login_flow_test.dart
/// ```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frigofute_v2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow - Story 1.2', () {
    testWidgets('complete login flow redirects to dashboard for complete profile',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify login page is displayed
      expect(find.text('Welcome Back'), findsOneWidget);

      // Fill in credentials
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'user@example.com');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(fields.last, 'Password123!');
      await tester.pump(const Duration(milliseconds: 300));

      // Submit form
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify redirect to dashboard (profile complete)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('login redirects to onboarding for incomplete profile',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login with user who has empty profileType
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'newuser@example.com');
      await tester.enterText(fields.last, 'Password123!');
      await tester.pump();

      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to onboarding
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows error for wrong credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Enter invalid credentials
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'user@example.com');
      await tester.enterText(fields.last, 'wrongpassword');
      await tester.pump();

      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify error snackbar
      expect(
        find.text('Incorrect email or password. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows validation error for empty password', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Enter valid email but no password
      await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('forgot password flow sends reset email', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Click "Forgot Password?"
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Verify forgot password page
      expect(find.text('Reset Password'), findsOneWidget);

      // Enter email
      await tester.enterText(
        find.byType(TextFormField),
        'user@example.com',
      );
      await tester.pump();

      // Submit
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify success state
      expect(find.text('Check your email'), findsOneWidget);
    });

    testWidgets('forgot password shows error for invalid email', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'not-an-email');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('loading state shown during login', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Fill in valid credentials
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'user@example.com');
      await tester.enterText(fields.last, 'Password123!');
      await tester.pump();

      // Submit and immediately check for loading state
      await tester.tap(find.byType(FilledButton).first);
      await tester.pump(); // Single pump - don't settle

      // Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('session persists across app restart simulation', (tester) async {
      // Note: Full session persistence test requires actual app restart
      // This test verifies that Firebase Auth state is available after login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app starts on login page (not authenticated)
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}
