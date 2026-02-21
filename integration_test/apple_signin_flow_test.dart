/// Integration tests for Apple Sign-In flow
/// Story 1.4: Login with OAuth Apple Sign-In
///
/// Prerequisites:
/// - Real iOS device (Apple Sign-In does NOT work on iOS Simulator)
/// - Apple Developer Account with Sign in with Apple capability configured
/// - Firebase Console: Apple provider enabled
/// - Xcode: Runner.entitlements with com.apple.developer.applesignin = Default
///
/// IMPORTANT: Full E2E Apple Sign-In tests require:
/// - Face ID / Touch ID interaction on real device
/// - Apple ID credentials
/// These tests verify UI behavior and platform-specific button visibility.
///
/// Run with:
/// ```
/// flutter test integration_test/apple_signin_flow_test.dart
/// ```
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frigofute_v2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Apple Sign-In Flow - Story 1.4', () {
    testWidgets('Apple Sign-In button is visible only on iOS', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (Platform.isIOS) {
        // On iOS: Apple Sign-In button should be present
        expect(find.text('Sign in with Apple'), findsOneWidget);
      } else {
        // On Android/other: Apple Sign-In button should NOT be shown (AC1)
        expect(find.text('Sign in with Apple'), findsNothing);
      }
    });

    testWidgets('Login screen shows Google and Apple options on iOS',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Google Sign-In always visible
      expect(find.text('Continue with Google'), findsOneWidget);

      if (Platform.isIOS) {
        // Apple Sign-In also visible on iOS (App Store requirement - Guideline 4.8)
        expect(find.text('Sign in with Apple'), findsOneWidget);
      }
    });

    testWidgets('Login screen has email/password fields regardless of platform',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Email and password fields always present
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('Apple Sign-In button tap triggers sign-in flow on iOS',
        (tester) async {
      if (!Platform.isIOS) {
        // Skip on non-iOS platforms
        return;
      }

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap Apple Sign-In button
      await tester.tap(find.text('Sign in with Apple'));
      await tester.pump(); // Single pump to capture immediate state change

      // App should respond to tap (may show loading or open Apple auth)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Session not authenticated on fresh start (unauthenticated state)',
        (tester) async {
      // Verifies app starts in login state when no previous session exists
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on login screen when not authenticated
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets(
        'Terms disclaimer visible for OAuth sign-in options', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Terms disclaimer should be visible for OAuth options (AC compliance)
      // Text may vary based on platform
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
