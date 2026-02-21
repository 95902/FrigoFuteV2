import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/network/models/network_info.dart';
import 'package:frigofute_v2/core/network/network_monitor_service.dart';
import 'package:frigofute_v2/core/shared/widgets/organisms/offline_banner.dart';

/// Widget tests for OfflineBanner
/// Story 0.9 Phase 9: Testing
///
/// Tests offline banner visibility based on network status
void main() {
  group('OfflineBanner Widget', () {
    testWidgets('should display banner when offline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            networkMonitorProvider.overrideWith(
              (ref) => Stream.value(
                NetworkInfo(
                  isConnected: false,
                  type: NetworkType.none,
                  lastChangedAt: DateTime.now(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
        ),
      );

      await tester.pump();

      // Should display MaterialBanner
      expect(find.byType(MaterialBanner), findsOneWidget);

      // Should have cloud_off icon
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Should have offline message
      expect(
        find.text(
          'Vous êtes hors ligne. Vos modifications seront synchronisées automatiquement dès la reconnexion.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should hide banner when online', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            networkMonitorProvider.overrideWith(
              (ref) => Stream.value(
                NetworkInfo(
                  isConnected: true,
                  type: NetworkType.wifi,
                  lastChangedAt: DateTime.now(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
        ),
      );

      await tester.pump();

      // Should not display MaterialBanner (hidden with SizedBox.shrink)
      expect(find.byType(MaterialBanner), findsNothing);

      // Should display empty SizedBox
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should hide banner when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            networkMonitorProvider.overrideWith(
              (ref) => const Stream<NetworkInfo>.empty(),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
        ),
      );

      // Should display nothing while loading
      expect(find.byType(MaterialBanner), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should hide banner on error', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            networkMonitorProvider.overrideWith(
              (ref) => Stream<NetworkInfo>.error(Exception('Test error')),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
        ),
      );

      await tester.pump();

      // Should hide banner on error
      expect(find.byType(MaterialBanner), findsNothing);
    });

    testWidgets('should have orange background color when displayed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            networkMonitorProvider.overrideWith(
              (ref) => Stream.value(NetworkInfo.disconnected()),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
        ),
      );

      await tester.pump();

      final materialBanner = tester.widget<MaterialBanner>(
        find.byType(MaterialBanner),
      );
      expect(materialBanner.backgroundColor, Colors.orange.shade100);
    });

    testWidgets('should have OK button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            networkMonitorProvider.overrideWith(
              (ref) => Stream.value(NetworkInfo.disconnected()),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
        ),
      );

      await tester.pump();

      // Should have OK button
      expect(find.text('OK'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should update when network status changes', (
      WidgetTester tester,
    ) async {
      // Create a stream controller to simulate network changes
      final networkController = StreamController<NetworkInfo>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            networkMonitorProvider.overrideWith(
              (ref) => networkController.stream,
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
        ),
      );

      // Initially offline
      networkController.add(NetworkInfo.disconnected());
      await tester.pump();

      expect(find.byType(MaterialBanner), findsOneWidget);

      // Go online
      networkController.add(
        NetworkInfo(
          isConnected: true,
          type: NetworkType.wifi,
          lastChangedAt: DateTime.now(),
        ),
      );
      await tester.pump();

      expect(find.byType(MaterialBanner), findsNothing);

      // Cleanup
      networkController.close();
    });
  });
}
