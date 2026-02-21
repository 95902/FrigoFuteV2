import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/data_sync/conflict_resolver.dart';

/// Unit tests for ConflictResolver
/// Story 0.9 Phase 9: Testing
///
/// Tests Last-Write-Wins conflict resolution strategy
void main() {
  group('ConflictResolver', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = ConflictResolver();
    });

    group('resolveConflict()', () {
      test('should resolve conflict using Last-Write-Wins (remote newer)',
          () async {
        final localData = {
          'id': '1',
          'name': 'Local Version',
          'updatedAt': DateTime(2026, 2, 15, 10, 0).toIso8601String(),
        };

        final remoteData = {
          'id': '1',
          'name': 'Remote Version',
          'updatedAt':
              DateTime(2026, 2, 15, 10, 5).toIso8601String(), // 5 min later
        };

        final result = await resolver.resolveConflict(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result['name'], 'Remote Version'); // Remote should win
        expect(result['updatedAt'], remoteData['updatedAt']);
      });

      test('should resolve conflict using Last-Write-Wins (local newer)',
          () async {
        final localData = {
          'id': '1',
          'name': 'Local Version',
          'updatedAt': DateTime(2026, 2, 15, 10, 10).toIso8601String(),
        };

        final remoteData = {
          'id': '1',
          'name': 'Remote Version',
          'updatedAt': DateTime(2026, 2, 15, 10, 5).toIso8601String(),
        };

        final result = await resolver.resolveConflict(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result['name'], 'Local Version'); // Local should win
        expect(result['updatedAt'], localData['updatedAt']);
      });

      test('should handle Timestamp objects from Firestore', () async {
        final localData = {
          'id': '1',
          'name': 'Local',
          'updatedAt': Timestamp.fromDate(DateTime(2026, 2, 15, 10, 0)),
        };

        final remoteData = {
          'id': '1',
          'name': 'Remote',
          'updatedAt': Timestamp.fromDate(DateTime(2026, 2, 15, 10, 5)),
        };

        final result = await resolver.resolveConflict(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result['name'], 'Remote');
      });

      test('should handle DateTime objects', () async {
        final localData = {
          'id': '1',
          'name': 'Local',
          'updatedAt': DateTime(2026, 2, 15, 10, 10),
        };

        final remoteData = {
          'id': '1',
          'name': 'Remote',
          'updatedAt': DateTime(2026, 2, 15, 10, 5),
        };

        final result = await resolver.resolveConflict(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result['name'], 'Local'); // Local is newer
      });
    });

    group('incrementVersion()', () {
      test('should increment version from 0 to 1', () {
        final data = {
          'id': '1',
          'name': 'Test Product',
        };

        final result = resolver.incrementVersion(data);

        expect(result['version'], 1);
        expect(result['updatedAt'], isA<FieldValue>());
        expect(result['id'], '1');
        expect(result['name'], 'Test Product');
      });

      test('should increment version from 3 to 4', () {
        final data = {
          'id': '1',
          'name': 'Test Product',
          'version': 3,
        };

        final result = resolver.incrementVersion(data);

        expect(result['version'], 4);
        expect(result['updatedAt'], isA<FieldValue>());
      });

      test('should preserve all existing fields', () {
        final data = {
          'id': '1',
          'name': 'Test',
          'category': 'dairy',
          'quantity': 2,
          'version': 1,
        };

        final result = resolver.incrementVersion(data);

        expect(result['version'], 2);
        expect(result['id'], '1');
        expect(result['name'], 'Test');
        expect(result['category'], 'dairy');
        expect(result['quantity'], 2);
      });
    });

    group('hasVersionConflict()', () {
      test('should detect conflict when local version is behind', () {
        final hasConflict = resolver.hasVersionConflict(
          localVersion: 2,
          remoteVersion: 3,
        );

        expect(hasConflict, true);
      });

      test('should not detect conflict when versions are equal', () {
        final hasConflict = resolver.hasVersionConflict(
          localVersion: 3,
          remoteVersion: 3,
        );

        expect(hasConflict, false);
      });

      test('should not detect conflict when local version is ahead', () {
        final hasConflict = resolver.hasVersionConflict(
          localVersion: 4,
          remoteVersion: 3,
        );

        expect(hasConflict, false);
      });
    });
  });
}
