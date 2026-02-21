/// Route path constants for GoRouter
/// Story 0.5: Navigation and Deep Linking
///
/// Pattern: kebab-case for paths
class AppRoutes {
  // ============================================================================
  // AUTH ROUTES (Public)
  // ============================================================================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String onboarding = '/auth/onboarding';

  // ============================================================================
  // MAIN TABS (ShellRoute with Bottom Navigation)
  // ============================================================================
  static const String inventory = '/inventory';
  static const String dashboard = '/dashboard';
  static const String recipes = '/recipes';

  // ============================================================================
  // FREE FEATURES
  // ============================================================================
  static const String ocrScan = '/ocr-scan';
  static const String notifications = '/notifications';

  // ============================================================================
  // PREMIUM FEATURES
  // ============================================================================
  static const String nutritionTracking = '/nutrition-tracking';
  static const String nutritionProfiles = '/nutrition-profiles';
  static const String mealPlanning = '/meal-planning';
  static const String aiCoach = '/ai-coach';
  static const String gamification = '/gamification';
  static const String shoppingList = '/shopping-list';
  static const String familySharing = '/family-sharing';
  static const String priceComparator = '/price-comparator';

  // ============================================================================
  // PROFILE ROUTES (Story 1.6)
  // ============================================================================
  static const String healthProfile = '/health-profile';
  static const String weightTracking = '/health-profile/weight-tracking';

  // ============================================================================
  // LEGAL ROUTES (Story 1.1, Epic 16)
  // ============================================================================
  static const String termsOfService = '/legal/terms';
  static const String privacyPolicy = '/legal/privacy';

  // ============================================================================
  // SPECIAL ROUTES
  // ============================================================================
  static const String paywall = '/paywall';
  static const String notFound = '/404';
  static const String splash = '/splash';

  /// Check if route requires premium subscription
  static bool isPremiumRoute(String location) {
    const premiumRoutes = [
      nutritionTracking,
      nutritionProfiles,
      mealPlanning,
      aiCoach,
      gamification,
      shoppingList,
      familySharing,
      priceComparator,
    ];
    return premiumRoutes.any((route) => location.startsWith(route));
  }

  /// Check if route is public (no auth required)
  static bool isPublicRoute(String location) {
    return location.startsWith('/auth') ||
           location == splash ||
           location == notFound;
  }
}
