import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/auth_profile/presentation/widgets/google_sign_in_button.dart';

void main() {
  group('GoogleSignInButton Widget Tests', () {
    testWidgets('should render button with Google icon and text',
        (tester) async {
      // Arrange
      bool wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
    });

    testWidgets('should have correct button dimensions', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(onPressed: () {}),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(double.infinity));
      expect(sizedBox.height, equals(56)); // Material Design 3: 56dp min
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      bool wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should show loading spinner when isLoading=true',
        (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Signing in...'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsNothing);
    });

    testWidgets('should disable button when isLoading=true', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull); // Button should be disabled
    });

    testWidgets('should not call onPressed when loading', (tester) async {
      // Arrange
      bool wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () => wasPressed = true,
              isLoading: true,
            ),
          ),
        ),
      );

      // Try to tap the disabled button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Changed from pumpAndSettle() - no animations to settle

      // Assert
      expect(wasPressed, isFalse); // Should not be called
    });

    testWidgets('should have white background and correct styling',
        (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(onPressed: () {}),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;

      expect(
        style.backgroundColor?.resolve({}),
        equals(Colors.white),
      );
      expect(
        style.foregroundColor?.resolve({}),
        equals(Colors.black87),
      );
    });

    testWidgets('should have proper spacing between icon and text',
        (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(onPressed: () {}),
          ),
        ),
      );

      // Assert — L1: scope Row search to GoogleSignInButton to avoid
      // StateError when multiple Row widgets exist in the widget tree
      final row = tester.widget<Row>(
        find.descendant(
          of: find.byType(GoogleSignInButton),
          matching: find.byType(Row),
        ),
      );
      final children = row.children;

      // Should have: Icon, SizedBox(spacing), Text
      expect(children.length, greaterThanOrEqualTo(3));

      // Find SizedBox between icon and text
      final sizedBoxes = children.whereType<SizedBox>();
      expect(sizedBoxes.any((box) => box.width == 12), isTrue);
    });

    testWidgets('should maintain state transition from loading to idle',
        (tester) async {
      // Arrange
      bool isLoading = true;

      // Act - Initial loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return GoogleSignInButton(
                  onPressed: () {
                    setState(() => isLoading = false);
                  },
                  isLoading: isLoading,
                );
              },
            ),
          ),
        ),
      );

      // Assert initial state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Signing in...'), findsOneWidget);

      // Simulate loading completion by rebuilding with isLoading=false
      isLoading = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {},
              isLoading: isLoading,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert final state
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
    });
  });
}
