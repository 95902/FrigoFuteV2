import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frigofute_v2/core/data_sync/sync_providers.dart';
import 'package:frigofute_v2/core/data_sync/conflict_resolver.dart';
import 'package:frigofute_v2/core/data_sync/sync_retry_manager.dart';

void main() {
  group('Sync Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('conflictResolverProvider', () {
      test('should provide ConflictResolver instance', () {
        final resolver = container.read(conflictResolverProvider);
        expect(resolver, isA<ConflictResolver>());
      });

      test('should provide same instance on multiple reads', () {
        final resolver1 = container.read(conflictResolverProvider);
        final resolver2 = container.read(conflictResolverProvider);
        expect(identical(resolver1, resolver2), isTrue);
      });

      test('should not throw on initialization', () {
        expect(
          () => container.read(conflictResolverProvider),
          returnsNormally,
        );
      });
    });

    group('syncRetryManagerProvider', () {
      test('should provide SyncRetryManager instance', () {
        final manager = container.read(syncRetryManagerProvider);
        expect(manager, isA<SyncRetryManager>());
      });

      test('should provide same instance on multiple reads', () {
        final manager1 = container.read(syncRetryManagerProvider);
        final manager2 = container.read(syncRetryManagerProvider);
        expect(identical(manager1, manager2), isTrue);
      });

      test('should not throw on initialization', () {
        expect(
          () => container.read(syncRetryManagerProvider),
          returnsNormally,
        );
      });

      test('should calculate backoff correctly', () {
        final manager = container.read(syncRetryManagerProvider);

        // First retry: 1s
        final backoff0 = manager.calculateBackoff(0);
        expect(backoff0.inSeconds, 1);

        // Second retry: 2s
        final backoff1 = manager.calculateBackoff(1);
        expect(backoff1.inSeconds, 2);

        // Third retry: 4s
        final backoff2 = manager.calculateBackoff(2);
        expect(backoff2.inSeconds, 4);
      });

      test('should respect max backoff limit', () {
        final manager = container.read(syncRetryManagerProvider);

        // After many retries, should cap at max (32s)
        final backoff10 = manager.calculateBackoff(10);
        expect(backoff10.inSeconds, lessThanOrEqualTo(32));
      });
    });

    group('Provider Container Lifecycle', () {
      test('should create fresh container each time', () {
        final container1 = ProviderContainer();
        final container2 = ProviderContainer();

        expect(container1 != container2, isTrue);

        container1.dispose();
        container2.dispose();
      });

      test('should dispose container without errors', () {
        final testContainer = ProviderContainer();
        expect(() => testContainer.dispose(), returnsNormally);
      });

      test('should handle multiple disposals gracefully', () {
        final testContainer = ProviderContainer();
        testContainer.dispose();
        expect(() => testContainer.dispose(), returnsNormally);
      });
    });

    group('Provider Interactions', () {
      test('all sync providers should be accessible', () {
        expect(() => container.read(conflictResolverProvider), returnsNormally);
        expect(() => container.read(syncRetryManagerProvider), returnsNormally);
      });

      test('providers should not throw on initial read', () {
        expect(() {
          container.read(conflictResolverProvider);
          container.read(syncRetryManagerProvider);
        }, returnsNormally);
      });

      test('should work with fresh containers', () {
        for (var i = 0; i < 5; i++) {
          final testContainer = ProviderContainer();
          final resolver = testContainer.read(conflictResolverProvider);
          final manager = testContainer.read(syncRetryManagerProvider);

          expect(resolver, isA<ConflictResolver>());
          expect(manager, isA<SyncRetryManager>());

          testContainer.dispose();
        }
      });
    });

    group('Error Handling', () {
      test('should handle provider errors gracefully', () {
        expect(
          () => ProviderContainer(),
          returnsNormally,
        );
      });

      test('should survive multiple container creations', () {
        for (var i = 0; i < 10; i++) {
          final testContainer = ProviderContainer();
          expect(testContainer.read(conflictResolverProvider), isA<ConflictResolver>());
          expect(testContainer.read(syncRetryManagerProvider), isA<SyncRetryManager>());
          testContainer.dispose();
        }
      });
    });
  });
}
