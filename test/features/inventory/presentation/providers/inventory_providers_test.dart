import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frigofute_v2/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:frigofute_v2/core/data_sync/sync_providers.dart';

void main() {
  group('StateProvider Tests - Story 0.4', () {
    // Note: Tests qui ne nécessitent pas Hive
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('selectedProductIdProvider starts as null', () {
      final selectedId = container.read(selectedProductIdProvider);
      expect(selectedId, isNull);
    });

    test('selectedProductIdProvider can be updated', () {
      container.read(selectedProductIdProvider.notifier).state = 'product-123';
      final selectedId = container.read(selectedProductIdProvider);
      expect(selectedId, 'product-123');
    });

    test('isSyncingProvider returns false by default', () {
      final isSyncing = container.read(isSyncingProvider);
      expect(isSyncing, isFalse);
    });

    test('isOfflineProvider returns false by default', () {
      final isOffline = container.read(isOfflineProvider);
      expect(isOffline, isFalse);
    });

    test('isOnlineProvider returns true by default', () {
      final isOnline = container.read(isOnlineProvider);
      expect(isOnline, isTrue);
    });
  });

  // Note: Tests des providers qui dépendent de Hive nécessiteraient
  // un mock complet de HiveService et des boxes Hive.
  // Ces tests sont reportés à une story technique future.
}
