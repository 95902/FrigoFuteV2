import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../network/network_monitor_service.dart';

/// Offline banner widget
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Displays a material banner when the device is offline.
/// Automatically hides when network connectivity is restored.
///
/// Example:
/// ```dart
/// Column(
///   children: [
///     const OfflineBanner(),
///     Expanded(child: body),
///   ],
/// )
/// ```
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkInfoAsync = ref.watch(networkMonitorProvider);

    return networkInfoAsync.when(
      data: (networkInfo) {
        if (networkInfo.isConnected) {
          return const SizedBox.shrink(); // Hide banner when online
        }

        return MaterialBanner(
          backgroundColor: Colors.orange.shade100,
          leading: const Icon(Icons.cloud_off, color: Colors.orange),
          content: const Text(
            'Vous êtes hors ligne. Vos modifications seront synchronisées automatiquement dès la reconnexion.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
