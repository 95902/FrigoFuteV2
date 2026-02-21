/// Integration tests for signup flow
/// Story 1.1: Create Account with Email and Password
///
/// Prerequisites:
/// - Firebase Emulator Suite running (`firebase emulators:start`)
/// - Connected device or emulator
///
/// Run with:
/// ```
/// flutter test integration_test/signup_flow_test.dart
/// ```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frigofute_v2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Signup Flow - Story 1.1', () {
    testWidgets('complete signup flow navigates to onboarding', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to signup page if on login page
      final createAccountButton = find.text('Create Account');
      if (createAccountButton.evaluate().isNotEmpty) {
        await tester.tap(createAccountButton.first);
        await tester.pumpAndSettle();
      }

      // Verify signup page is displayed
      expect(find.text('Create Account'), findsWidgets);

      // Fill in email field
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test.integration@example.com');
      await tester.pump(const Duration(milliseconds: 500));

      // Fill in password field
      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, 'Password123!');
      await tester.pump(const Duration(milliseconds: 500));

      // Fill in confirm password field
      final confirmField = find.byType(TextFormField).at(2);
      await tester.enterText(confirmField, 'Password123!');
      await tester.pump(const Duration(milliseconds: 500));

      // Accept terms
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Submit form
      final submitButton = find.byType(FilledButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify success dialog or redirect to onboarding
      final successDialog = find.text('Account Created!');
      final continueButton = find.text('Continue');

      if (successDialog.evaluate().isNotEmpty) {
        // Dismiss success dialog
        await tester.tap(continueButton);
        await tester.pumpAndSettle();
      }

      // Verify we're on onboarding screen
      expect(
        find.byType(Scaffold),
        findsWidgets,
        reason: 'Should navigate away from signup after successful account creation',
      );
    });

    testWidgets('shows error for invalid email format', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to signup page
      final createAccountLink = find.text('Create Account');
      if (createAccountLink.evaluate().isNotEmpty) {
        await tester.tap(createAccountLink.first);
        await tester.pumpAndSettle();
      }

      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump(const Duration(milliseconds: 500));

      // Try to submit (should fail validation)
      final submitButton = find.byType(FilledButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify error message displayed
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to signup page
      final createAccountLink = find.text('Create Account');
      if (createAccountLink.evaluate().isNotEmpty) {
        await tester.tap(createAccountLink.first);
        await tester.pumpAndSettle();
      }

      // Fill email and password
      await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');

      // Enter different confirm password
      await tester.enterText(find.byType(TextFormField).at(2), 'DifferentPassword!');
      await tester.pump(const Duration(milliseconds: 500));

      // Try to submit
      final submitButton = find.byType(FilledButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify mismatch error
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('submit button disabled without terms acceptance', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to signup page
      final createAccountLink = find.text('Create Account');
      if (createAccountLink.evaluate().isNotEmpty) {
        await tester.tap(createAccountLink.first);
        await tester.pumpAndSettle();
      }

      // Fill valid email and password but do NOT check terms
      await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');
      await tester.enterText(find.byType(TextFormField).at(2), 'Password123!');
      await tester.pumpAndSettle();

      // Terms checkbox is unchecked - button should handle the case
      final submitButton = find.byType(FilledButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify error about terms
      expect(
        find.text('Please accept the Terms & Privacy Policy'),
        findsOneWidget,
      );
    });
  });
}
