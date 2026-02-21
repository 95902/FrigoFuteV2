import 'package:cloud_firestore/cloud_firestore.dart';

/// Last-Write-Wins (LWW) conflict resolution strategy
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Resolves conflicts between local and remote document versions.
/// The server timestamp (updatedAt) is the authoritative source.
/// Whichever version has the latest timestamp wins the conflict.
///
/// Example:
/// ```dart
/// final resolver = ConflictResolver();
/// final winner = await resolver.resolveConflict(
///   localData: {'name': 'Milk', 'updatedAt': '2026-02-15T10:00:00Z'},
///   remoteData: {'name': 'Milk 2L', 'updatedAt': '2026-02-15T10:05:00Z'},
/// );
/// // Returns remoteData because it has a later timestamp
/// ```
class ConflictResolver {
  /// Resolves conflict between local and remote document versions
  ///
  /// Returns the winning version (the one with the latest updatedAt timestamp).
  Future<Map<String, dynamic>> resolveConflict({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) async {
    final localUpdatedAt = _parseTimestamp(localData['updatedAt']);
    final remoteUpdatedAt = _parseTimestamp(remoteData['updatedAt']);

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      // Server version is newer → use remote (will be written to Hive)
      return remoteData;
    } else {
      // Local version is newer → keep local (will be pushed to Firestore)
      return localData;
    }
  }

  /// Parse timestamp from various formats (Timestamp, String, DateTime)
  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      throw ArgumentError('Invalid timestamp format: $timestamp');
    }
  }

  /// Increments version field for optimistic concurrency control
  ///
  /// Example:
  /// ```dart
  /// final updatedData = resolver.incrementVersion(data);
  /// // version: 1 → 2, updatedAt: server timestamp
  /// ```
  Map<String, dynamic> incrementVersion(Map<String, dynamic> data) {
    final currentVersion = data['version'] as int? ?? 0;
    return {
      ...data,
      'version': currentVersion + 1,
      'updatedAt': FieldValue.serverTimestamp(), // Server-generated timestamp
    };
  }

  /// Check if two versions conflict based on version number
  ///
  /// Returns true if local version is behind remote version.
  bool hasVersionConflict({
    required int localVersion,
    required int remoteVersion,
  }) {
    return localVersion < remoteVersion;
  }
}
