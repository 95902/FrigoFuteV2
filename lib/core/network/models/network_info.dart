import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_info.freezed.dart';

/// Network connectivity information
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Represents current network connectivity state.
/// Used for triggering sync operations when network becomes available.
///
/// Example:
/// ```dart
/// final info = NetworkInfo(
///   isConnected: true,
///   type: NetworkType.wifi,
///   lastChangedAt: DateTime.now(),
/// );
/// ```
@freezed
abstract class NetworkInfo with _$NetworkInfo {
  const factory NetworkInfo({
    required bool isConnected,
    required NetworkType type,
    required DateTime lastChangedAt,
  }) = _NetworkInfo;

  /// Factory for disconnected state
  factory NetworkInfo.disconnected() => NetworkInfo(
    isConnected: false,
    type: NetworkType.none,
    lastChangedAt: DateTime.now(),
  );

  /// Factory for initial/unknown state
  factory NetworkInfo.unknown() => NetworkInfo(
    isConnected: false,
    type: NetworkType.none,
    lastChangedAt: DateTime.now(),
  );
}

/// Network connection type
enum NetworkType {
  /// WiFi connection
  wifi,

  /// Mobile data (3G, 4G, 5G)
  mobile,

  /// Ethernet connection (desktop)
  ethernet,

  /// No network connection
  none,
}
