import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../feature_flags/feature_flag_providers.dart';
import 'app_routes.dart';
import 'scaffold_with_bottom_nav.dart';
import 'screens/paywall_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/premium_feature_placeholder.dart';

// Story 1.2: Import new auth pages and providers
import '../../features/auth_profile/presentation/pages/login_page.dart';
import '../../features/auth_profile/presentation/pages/signup_page.dart';
import '../../features/auth_profile/presentation/pages/forgot_password_page.dart';
import '../../features/auth_profile/presentation/providers/auth_profile_providers.dart';

// Story 1.5: Full adaptive onboarding screen
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

// Story 1.6: Health profile screens
import '../../features/health_profile/presentation/screens/profile_update_screen.dart';
import '../../features/health_profile/presentation/screens/weight_tracking_screen.dart';

// Main tab screens
import '../../features/inventory/presentation/widgets/inventory_list_screen_example.dart';
import '../../features/inventory/presentation/screens/product_detail_screen.dart';
import '../../features/inventory/presentation/screens/add_product_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/metrics_screen.dart';
import '../../features/recipes/presentation/screens/recipes_list_screen.dart';
import '../../features/recipes/presentation/screens/recipe_detail_screen.dart';
import '../../features/recipes/presentation/screens/recipe_suggestions_screen.dart';

// Other free feature screens
import '../../features/ocr_scan/presentation/screens/ocr_scan_screen.dart';
import '../../features/ocr_scan/presentation/screens/scan_result_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/meal_planning/presentation/screens/meal_plan_details_screen.dart';

/// GoRouter Provider
/// Configured with route guards (auth + premium) and deep linking support
///
/// IMPORTANT: Router rebuilds when authStateProvider or isPremiumProvider change
/// This ensures guards are re-evaluated on login/logout/subscription changes
final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch providers to rebuild router when auth/premium state changes
  ref.watch(authStateProvider);
  ref.watch(isPremiumProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,

    // Global redirect for route guards
    // Story 1.2: Enhanced redirect logic with profile completion check
    // NOTE: Read providers directly here to get current values on each navigation
    redirect: (BuildContext context, GoRouterState state) async {
      final location = state.matchedLocation;

      // Check authentication first
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );

      // Allow public routes without auth
      if (AppRoutes.isPublicRoute(location)) {
        // If already authenticated and trying to access login/register, redirect based on profile
        if (isAuthenticated && (location == AppRoutes.login || location == AppRoutes.register)) {
          try {
            // Get user profile to check completion
            final userProfile = await ref.read(currentUserProvider.future);
            if (userProfile != null) {
              // Profile incomplete → redirect to onboarding
              if (userProfile.profileType.isEmpty) {
                return AppRoutes.onboarding;
              }
              // Profile complete → redirect to dashboard
              return AppRoutes.dashboard;
            }
          } catch (e) {
            // Error fetching profile, allow access to login
            return null;
          }
        }
        return null;
      }

      // Redirect to login if not authenticated
      if (!isAuthenticated) {
        return AppRoutes.login;
      }

      // NOTE: Profile completion routing is handled by login_page.dart after
      // successful authentication (reads Firestore profileType from LoginUseCase
      // result). The redirect here avoids using currentUserProvider because it
      // returns UserEntity.fromFirebaseUser() which has no Firestore profileType,
      // which would cause all authenticated users to always redirect to onboarding.

      // Check premium access for premium routes
      if (AppRoutes.isPremiumRoute(location)) {
        final isPremium = ref.read(isPremiumProvider);
        if (!isPremium) {
          return AppRoutes.paywall;
        }
      }

      // No redirect needed
      return null;
    },

    routes: [
      // ========================================================================
      // AUTH ROUTES (Public) - Story 1.2
      // ========================================================================
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const SignupPage(),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ========================================================================
      // SHELL ROUTE (Bottom Navigation)
      // ========================================================================
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNav(child: child);
        },
        routes: [
          // Inventory Tab
          GoRoute(
            path: AppRoutes.inventory,
            name: 'inventory',
            builder: (context, state) => const InventoryListScreenExample(),
            routes: [
              // Nested: Product Detail
              GoRoute(
                path: 'detail/:productId',
                name: 'inventory-detail',
                builder: (context, state) {
                  final productId = state.pathParameters['productId']!;
                  return ProductDetailScreen(productId: productId);
                },
              ),
              // Nested: Add Product
              GoRoute(
                path: 'add',
                name: 'inventory-add',
                builder: (context, state) => const AddProductScreen(),
              ),
            ],
          ),

          // Dashboard Tab
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
            routes: [
              // Nested: Metrics
              GoRoute(
                path: 'metrics',
                name: 'dashboard-metrics',
                builder: (context, state) => const MetricsScreen(),
              ),
            ],
          ),

          // Recipes Tab
          GoRoute(
            path: AppRoutes.recipes,
            name: 'recipes',
            builder: (context, state) => const RecipesListScreen(),
            routes: [
              // Nested: Recipe Detail
              GoRoute(
                path: 'detail/:recipeId',
                name: 'recipe-detail',
                builder: (context, state) {
                  final recipeId = state.pathParameters['recipeId']!;
                  return RecipeDetailScreen(recipeId: recipeId);
                },
              ),
              // Nested: Recipe Suggestions
              GoRoute(
                path: 'suggestions',
                name: 'recipe-suggestions',
                builder: (context, state) => const RecipeSuggestionsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ========================================================================
      // FREE FEATURES (Outside bottom nav)
      // ========================================================================
      GoRoute(
        path: AppRoutes.ocrScan,
        name: 'ocr-scan',
        builder: (context, state) => const OcrScanScreen(),
        routes: [
          // Nested: Scan Result
          GoRoute(
            path: 'result/:scanId',
            name: 'scan-result',
            builder: (context, state) {
              final scanId = state.pathParameters['scanId']!;
              return ScanResultScreen(scanId: scanId);
            },
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // ========================================================================
      // PREMIUM FEATURES
      // ========================================================================
      GoRoute(
        path: AppRoutes.nutritionTracking,
        name: 'nutrition-tracking',
        builder: (context, state) => const NutritionTrackingScreen(),
      ),

      GoRoute(
        path: AppRoutes.nutritionProfiles,
        name: 'nutrition-profiles',
        builder: (context, state) => const NutritionProfilesScreen(),
      ),

      GoRoute(
        path: AppRoutes.mealPlanning,
        name: 'meal-planning',
        builder: (context, state) => const MealPlanningScreen(),
        routes: [
          // Nested: Meal Plan Details
          GoRoute(
            path: 'details/:planId',
            name: 'meal-plan-details',
            builder: (context, state) {
              final planId = state.pathParameters['planId']!;
              return MealPlanDetailsScreen(planId: planId);
            },
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.aiCoach,
        name: 'ai-coach',
        builder: (context, state) => const AiCoachScreen(),
      ),

      GoRoute(
        path: AppRoutes.gamification,
        name: 'gamification',
        builder: (context, state) => const GamificationScreen(),
      ),

      GoRoute(
        path: AppRoutes.shoppingList,
        name: 'shopping-list',
        builder: (context, state) => const ShoppingListScreen(),
      ),

      GoRoute(
        path: AppRoutes.familySharing,
        name: 'family-sharing',
        builder: (context, state) => const FamilySharingScreen(),
      ),

      GoRoute(
        path: AppRoutes.priceComparator,
        name: 'price-comparator',
        builder: (context, state) => const PriceComparatorScreen(),
      ),

      // ========================================================================
      // PROFILE ROUTES (Story 1.6)
      // ========================================================================
      GoRoute(
        path: AppRoutes.healthProfile,
        name: 'health-profile',
        builder: (context, state) => const ProfileUpdateScreen(),
        routes: [
          GoRoute(
            path: 'weight-tracking',
            name: 'weight-tracking',
            builder: (context, state) => const WeightTrackingScreen(),
          ),
        ],
      ),

      // ========================================================================
      // SPECIAL ROUTES
      // ========================================================================
      GoRoute(
        path: AppRoutes.paywall,
        name: 'paywall',
        builder: (context, state) => const PaywallScreen(),
      ),

      GoRoute(
        path: AppRoutes.notFound,
        name: 'not-found',
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],

    // Error builder for broken deep links
    errorBuilder: (context, state) => NotFoundScreen(
      message: 'Route not found: ${state.matchedLocation}',
    ),
  );
});
