import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options_dev.dart';
import 'core/storage/hive_service.dart';
import 'core/feature_flags/remote_config_service.dart';
import 'core/routing/app_router.dart';

/// FrigoFute V2 - Application anti-gaspillage alimentaire intelligente
///
/// Architecture: Feature-First + Clean Architecture
/// State Management: Riverpod 2.6+
/// Routing: GoRouter (à configurer dans story 0.5)
void main() async {
  // 1. TOUJOURS EN PREMIER - Initialiser les bindings Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load environment variables (optionnel pour Story 0.2)
  try {
    await dotenv.load(fileName: '.env.dev');
  } catch (e) {
    // .env.dev pas encore configuré - continuez sans (OK pour Story 0.2)
    debugPrint('Warning: .env.dev not found - continuing without it');
  }

  // 3. Initialiser Firebase (AVANT tous les autres services)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Si Firebase échoue (ex: platform non supporté), continuer sans
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('⚠️ Continuing without Firebase - UI only mode');
    // Note: En production, Firebase doit être configuré pour toutes les plateformes
  }

  // 4. Configurer Crashlytics - Capturer les erreurs Flutter
  try {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Capturer les erreurs asynchrones
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('⚠️ Crashlytics not available: $e');
  }

  // 5. Story 0.3: Initialiser Hive (APRÈS Firebase pour encryption key)
  final stopwatch = Stopwatch()..start();
  try {
    await HiveService.init();
    stopwatch.stop();
    if (kDebugMode) {
      debugPrint('✅ Hive initialized in ${stopwatch.elapsedMilliseconds}ms');
      if (stopwatch.elapsedMilliseconds > 500) {
        debugPrint('⚠️ WARNING: Hive init exceeded 500ms target');
      }
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Hive initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue without Hive - app will work but without offline storage
  }

  // 6. Story 0.8: Initialize Remote Config (feature flags)
  try {
    await RemoteConfigService().initialize().timeout(
      const Duration(seconds: 5),
    );
    if (kDebugMode) {
      debugPrint('✅ Remote Config initialized');
    }
  } catch (e) {
    debugPrint('⚠️ Remote Config initialization failed: $e');
    // Continue with default values - don't block app startup
  }

  // 7. Lancer l'application avec Riverpod
  runApp(
    // Wrap app with ProviderScope for Riverpod state management
    const ProviderScope(
      child: FrigoFuteApp(),
    ),
  );
}

/// Root application widget
/// Story 0.5: Now uses GoRouter for navigation
class FrigoFuteApp extends ConsumerWidget {
  const FrigoFuteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'FrigoFute V2',
      debugShowCheckedModeBanner: false,

      // GoRouter configuration (Story 0.5)
      routerConfig: goRouter,

      // Material 3 theme configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Green - anti-waste theme
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // Dark theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
    );
  }
}
