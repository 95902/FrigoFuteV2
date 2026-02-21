import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data_sync/models/sync_status.dart';
import '../../../data_sync/sync_providers.dart';

/// Sync status indicator widget for app bar
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Displays a colored circle badge indicating sync status:
/// - Green: All data synced
/// - Orange: Syncing in progress
/// - Gray: Offline mode
/// - Red: Sync error
///
/// Phase 4: Full sync status with SyncService integration.
///
/// Example:
/// ```dart
/// AppBar(
///   title: Text('Inventory'),
///   actions: const [
///     Padding(
///       padding: EdgeInsets.only(right: 16.0),
///       child: Center(child: SyncStatusIndicator()),
///     ),
///   ],
/// )
/// ```
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusProvider);

    return syncStatusAsync.when(
      data: (status) {

        final color = _getColorForStatus(status);
        final icon = _getIconForStatus(status);
        final tooltip = _getTooltipForStatus(status);

        return Tooltip(
          message: tooltip,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 8, color: Colors.white),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => Tooltip(
        message: 'Erreur de surveillance réseau',
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error, size: 8, color: Colors.white),
        ),
      ),
    );
  }

  Color _getColorForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.orange;
      case SyncStatus.offline:
        return Colors.grey;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  IconData _getIconForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icons.check;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.offline:
        return Icons.cloud_off;
      case SyncStatus.error:
        return Icons.error;
    }
  }

  String _getTooltipForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Toutes vos données sont synchronisées';
      case SyncStatus.syncing:
        return 'Synchronisation en cours...';
      case SyncStatus.offline:
        return 'Hors ligne - Les modifications seront synchronisées à la reconnexion';
      case SyncStatus.error:
        return 'Erreur de synchronisation';
    }
  }
}
