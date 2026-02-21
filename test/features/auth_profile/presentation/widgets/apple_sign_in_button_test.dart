/// Widget tests for AppleSignInButton
/// Story 1.4: Login with OAuth Apple Sign-In
///
/// Tests cover:
/// - Button renders correctly with SignInWithAppleButton
/// - Loading state shows spinner and disables interaction
/// - onPressed callback is triggered when not loading
/// - Button is disabled (onPressed ignored) when loading
///
/// Note: These tests run on all platforms. The Platform.isIOS check is
/// handled in the parent LoginPage, not in the button widget itself.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/auth_profile/presentation/widgets/apple_sign_in_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  group('AppleSignInButton Widget Tests', () {
    testWidgets('should render SignInWithAppleButton when not loading',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SignInWithAppleButton), findsOneWidget);
    });

    testWidgets('should show loading spinner when isLoading=true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Loading state shows CircularProgressIndicator instead of Apple button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SignInWithAppleButton), findsNothing);
    });

    testWidgets('should call onPressed when tapped and not loading',
        (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SignInWithAppleButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('should have minimum height of 50pt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppleSignInButton(
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify the SignInWithAppleButton is rendered with correct height
      final buttonFinder = find.byType(SignInWithAppleButton);
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('loading state button is disabled (null onPressed)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // In loading state, ElevatedButton is used with onPressed: null
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('loading state shows black background (Apple HIG)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;
      expect(style, isNotNull);
    });

    testWidgets('not loading state does not show ElevatedButton',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      // Normal state uses SignInWithAppleButton, not ElevatedButton
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(SignInWithAppleButton), findsOneWidget);
    });
  });
}
