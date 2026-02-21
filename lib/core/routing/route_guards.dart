import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import '../feature_flags/feature_flag_providers.dart';
import 'app_routes.dart';

/// Authentication guard
/// Checks if user is authenticated before allowing access to protected routes
class AuthGuard {
  final Ref ref;

  AuthGuard(this.ref);

  /// Check if user is authenticated
  bool isAuthenticated() {
    final authState = ref.read(authStateProvider);
    return authState.value != null;
  }

  /// Redirect to login if not authenticated (except for public routes)
  String? checkAuth(String requestedRoute) {
    // Allow access to public routes
    if (AppRoutes.isPublicRoute(requestedRoute)) {
      return null;
    }

    // Redirect to login if not authenticated
    if (!isAuthenticated()) {
      return AppRoutes.login;
    }

    return null;
  }
}

/// Premium feature guard
/// Checks if user has premium subscription before allowing access to premium features
class PremiumGuard {
  final Ref ref;

  PremiumGuard(this.ref);

  /// Check if user has premium subscription
  bool isPremium() {
    return ref.read(isPremiumProvider);
  }

  /// Redirect to paywall if accessing premium route without subscription
  String? checkPremium(String requestedRoute) {
    // Check if route requires premium
    if (AppRoutes.isPremiumRoute(requestedRoute)) {
      // Redirect to paywall if not premium
      if (!isPremium()) {
        return AppRoutes.paywall;
      }
    }

    return null;
  }
}

/// Combined guard logic
/// Used by GoRouter redirect callback
class RouteGuards {
  final AuthGuard authGuard;
  final PremiumGuard premiumGuard;

  RouteGuards(Ref ref)
      : authGuard = AuthGuard(ref),
        premiumGuard = PremiumGuard(ref);

  /// Combined guard check (auth first, then premium)
  String? checkAccess(String requestedRoute) {
    // 1. Check authentication
    final authRedirect = authGuard.checkAuth(requestedRoute);
    if (authRedirect != null) {
      return authRedirect;
    }

    // 2. Check premium access
    final premiumRedirect = premiumGuard.checkPremium(requestedRoute);
    if (premiumRedirect != null) {
      return premiumRedirect;
    }

    // No redirect needed
    return null;
  }
}
