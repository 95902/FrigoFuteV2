import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/data_sync/models/sync_status.dart';
import 'package:frigofute_v2/core/data_sync/sync_providers.dart';
import 'package:frigofute_v2/core/shared/widgets/organisms/sync_status_indicator.dart';

/// Widget tests for SyncStatusIndicator
/// Story 0.9 Phase 9: Testing
///
/// Tests all sync status states and UI rendering
void main() {
  group('SyncStatusIndicator Widget', () {
    testWidgets('should display green indicator when status is synced',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith(
              (ref) => Stream.value(SyncStatus.synced),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncStatusIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should display a container (the colored circle)
      expect(find.byType(Container), findsWidgets);

      // Should have green color decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusIndicator),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        (container.decoration as BoxDecoration?)?.color,
        Colors.green,
      );
    });

    testWidgets('should display orange indicator when status is syncing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith(
              (ref) => Stream.value(SyncStatus.syncing),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncStatusIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusIndicator),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        (container.decoration as BoxDecoration?)?.color,
        Colors.orange,
      );
    });

    testWidgets('should display gray indicator when status is offline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith(
              (ref) => Stream.value(SyncStatus.offline),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncStatusIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusIndicator),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        (container.decoration as BoxDecoration?)?.color,
        Colors.grey,
      );
    });

    testWidgets('should display red indicator when status is error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith(
              (ref) => Stream.value(SyncStatus.error),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncStatusIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusIndicator),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        (container.decoration as BoxDecoration?)?.color,
        Colors.red,
      );
    });

    testWidgets('should display loading indicator when stream is loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith(
              (ref) => const Stream<SyncStatus>.empty(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncStatusIndicator(),
            ),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have tooltip with correct message for synced status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith(
              (ref) => Stream.value(SyncStatus.synced),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncStatusIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      final tooltip = find.byType(Tooltip);
      expect(tooltip, findsOneWidget);

      final tooltipWidget = tester.widget<Tooltip>(tooltip);
      expect(
        tooltipWidget.message,
        'Toutes vos données sont synchronisées',
      );
    });

    testWidgets(
        'should have tooltip with correct message for offline status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith(
              (ref) => Stream.value(SyncStatus.offline),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncStatusIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      final tooltipWidget = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(
        tooltipWidget.message,
        'Hors ligne - Les modifications seront synchronisées à la reconnexion',
      );
    });
  });
}
