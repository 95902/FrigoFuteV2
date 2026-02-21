import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/network_info.dart';

/// Network monitoring service provider
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Monitors network connectivity changes and provides real-time updates.
/// Automatically triggers sync operations when network becomes available.
///
/// Example:
/// ```dart
/// final networkStream = ref.watch(networkMonitorProvider);
/// networkStream.when(
///   data: (info) => Text('Connected: ${info.isConnected}'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
/// ```
final networkMonitorProvider = StreamProvider<NetworkInfo>((ref) {
  final service = NetworkMonitorService();
  ref.onDispose(() => service.dispose());
  return service.networkStream;
});

/// Convenience provider for boolean connectivity check
///
/// Example:
/// ```dart
/// final isConnected = ref.watch(isNetworkConnectedProvider);
/// if (isConnected) {
///   // Trigger sync
/// }
/// ```
final isNetworkConnectedProvider = Provider<bool>((ref) {
  final networkState = ref.watch(networkMonitorProvider);
  return networkState.maybeWhen(
    data: (info) => info.isConnected,
    orElse: () => false,
  );
});

/// Network connectivity monitoring service
///
/// Monitors network status using connectivity_plus package.
/// Emits NetworkInfo updates whenever connectivity changes.
class NetworkMonitorService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkInfo> _controller =
      StreamController<NetworkInfo>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Stream of network connectivity changes
  Stream<NetworkInfo> get networkStream => _controller.stream;

  /// Current network info (cached)
  NetworkInfo? _currentInfo;

  /// Get current network info (synchronous)
  NetworkInfo? get currentInfo => _currentInfo;

  NetworkMonitorService() {
    _initialize();
  }

  /// Initialize network monitoring
  Future<void> _initialize() async {
    // Initial connectivity check
    try {
      final results = await _connectivity.checkConnectivity();
      final info = _mapToNetworkInfo(results);
      _currentInfo = info;
      _controller.add(info);

      if (kDebugMode) {
        debugPrint(
            '✅ Network Monitor initialized: ${info.isConnected ? "Online (${info.type.name})" : "Offline"}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Network Monitor initial check failed: $e');
      }
      _currentInfo = NetworkInfo.unknown();
      _controller.add(_currentInfo!);
    }

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final info = _mapToNetworkInfo(results);
        _currentInfo = info;
        _controller.add(info);

        if (kDebugMode) {
          debugPrint(
              '🔄 Network status changed: ${info.isConnected ? "Online (${info.type.name})" : "Offline"}');
        }
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('⚠️ Network Monitor error: $error');
        }
      },
    );
  }

  /// Map ConnectivityResult to NetworkInfo
  NetworkInfo _mapToNetworkInfo(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkInfo(
        isConnected: false,
        type: NetworkType.none,
        lastChangedAt: DateTime.now(),
      );
    }

    // Prioritize network types: WiFi > Ethernet > Mobile
    NetworkType type = NetworkType.mobile;
    if (results.contains(ConnectivityResult.wifi)) {
      type = NetworkType.wifi;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      type = NetworkType.ethernet;
    }

    return NetworkInfo(
      isConnected: true,
      type: type,
      lastChangedAt: DateTime.now(),
    );
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
