/// Sync status for UI indicators
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Represents the current state of sync operations.
/// Used to display sync indicators in the app bar.
enum SyncStatus {
  /// All data synced successfully (green indicator)
  synced,

  /// Currently syncing data to Firestore (orange indicator)
  syncing,

  /// No network connection, offline mode (gray indicator)
  offline,

  /// Sync error occurred (red indicator)
  error,
}
