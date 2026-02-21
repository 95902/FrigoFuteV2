import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

// Import models - TypeAdapters are auto-generated in .g.dart files by hive_generator
import 'models/product_model.dart';
import 'models/recipe_model.dart';
import 'models/settings_model.dart';
import 'models/product_cache_model.dart';
import 'models/nutrition_data_model.dart';
import 'models/health_profile_model.dart';
import 'models/weight_history_entry.dart';

// Import sync models from data_sync module (Story 0.9)
import '../data_sync/models/sync_queue_item.dart';
import '../data_sync/models/sync_queue_item.adapter.dart';

/// Service de gestion Hive pour l'application
/// Story 0.3: Offline-first local storage
class HiveService {
  // Box names constants
  static const String inventoryBoxName = 'inventory_box';
  static const String recipesBoxName = 'recipes_box';
  static const String settingsBoxName = 'settings_box';
  static const String productsCacheBoxName = 'products_cache_box';
  static const String nutritionDataBoxName = 'nutrition_data_box';
  static const String healthProfilesBoxName = 'health_profiles_box';
  static const String syncQueueBoxName = 'sync_queue_box';
  static const String deadLetterQueueBoxName = 'dead_letter_queue_box';
  static const String onboardingProgressBoxName = 'onboarding_progress';

  /// Initialize Hive and open all boxes
  /// Must be called after Firebase.initializeApp()
  static Future<void> init() async {
    // 1. Initialize Hive for Flutter
    await Hive.initFlutter();

    // 2. Register ALL TypeAdapters BEFORE opening boxes
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProductModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecipeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(ProductCacheModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(NutritionDataModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(HealthProfileModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(SyncQueueItemAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(WeightHistoryEntryAdapter());
    }

    // 3. Open non-encrypted boxes (performance)
    await Hive.openBox<ProductModel>(inventoryBoxName);
    await Hive.openBox<RecipeModel>(recipesBoxName);
    await Hive.openBox<SettingsModel>(settingsBoxName);
    await Hive.openBox<ProductCacheModel>(productsCacheBoxName);

    // 4. Open encrypted boxes for health data (RGPD compliance)
    final encryptionKey = await _getOrCreateEncryptionKey();
    await Hive.openBox<NutritionDataModel>(
      nutritionDataBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    await Hive.openBox<HealthProfileModel>(
      healthProfilesBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    // 5. Open sync queue boxes (unencrypted for performance)
    await Hive.openBox<SyncQueueItem>(syncQueueBoxName);
    await Hive.openBox<SyncQueueItem>(deadLetterQueueBoxName);

    // 6. Open onboarding progress box (unencrypted, transient data)
    await Hive.openBox(onboardingProgressBoxName);
  }

  // Secure storage for encryption keys
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _encryptionKeyName = 'hive_encryption_key';

  /// Get or create AES-256 encryption key
  ///
  /// Story 0.10: Secure encryption key management
  ///
  /// Key storage:
  /// - iOS: Keychain (secure enclave)
  /// - Android: KeyStore (hardware-backed if available)
  ///
  /// Key derivation:
  /// - Derived from Firebase Auth UID using SHA-256
  /// - 256-bit key for AES-256 encryption
  /// - Stored in device secure storage for reuse
  static Future<List<int>> _getOrCreateEncryptionKey() async {
    // 1. Check if key already exists in secure storage
    final existingKey = await _secureStorage.read(key: _encryptionKeyName);

    if (existingKey != null) {
      if (kDebugMode) {
        debugPrint('✓ Encryption key loaded from secure storage');
      }
      return base64Decode(existingKey);
    }

    // 2. Generate new key from Firebase Auth UID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Fallback to dev key if no user authenticated (development only)
      if (kDebugMode) {
        debugPrint('⚠️ No authenticated user - using dev encryption key');
      }
      return List<int>.generate(32, (i) => i * 7 % 256);
    }

    // 3. Derive 256-bit key from UID using SHA-256
    final uidBytes = utf8.encode(user.uid);
    final digest = sha256.convert(uidBytes);
    final encryptionKey = Uint8List.fromList(digest.bytes);

    // 4. Store in secure storage for future use
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64Encode(encryptionKey),
    );

    if (kDebugMode) {
      debugPrint('✓ Encryption key generated and stored securely');
      debugPrint(
        '  - Derived from Firebase Auth UID: ${user.uid.substring(0, 8)}...',
      );
      debugPrint('  - Key length: 256 bits (AES-256)');
      debugPrint(
        '  - Storage: ${defaultTargetPlatform == TargetPlatform.iOS ? "iOS Keychain" : "Android KeyStore"}',
      );
    }

    return encryptionKey;
  }

  /// Delete encryption key (called during account deletion)
  ///
  /// Story 0.10: RGPD right to be forgotten
  ///
  /// This will make all encrypted Hive boxes unreadable.
  /// Must be called BEFORE deleting Hive data.
  static Future<void> deleteEncryptionKey() async {
    await _secureStorage.delete(key: _encryptionKeyName);
    if (kDebugMode) {
      debugPrint('✓ Encryption key deleted from secure storage');
    }
  }

  /// Close all boxes (cleanup)
  static Future<void> closeAll() async {
    await Hive.close();
  }

  /// Clear all data (RGPD right to be forgotten)
  ///
  /// Story 0.10: Complete data deletion including encryption key
  static Future<void> deleteAll() async {
    // 1. Delete encryption key first (makes encrypted boxes unreadable)
    await deleteEncryptionKey();

    // 2. Delete all Hive data from disk
    await Hive.deleteFromDisk();

    if (kDebugMode) {
      debugPrint('✓ All Hive data and encryption keys deleted');
    }
  }

  /// Debug: Print box stats
  static void printStats() {
    if (kDebugMode) {
      debugPrint('=== Hive Stats ===');
      debugPrint(
        'Inventory: ${Hive.box<ProductModel>(inventoryBoxName).length} items',
      );
      debugPrint(
        'Recipes: ${Hive.box<RecipeModel>(recipesBoxName).length} items',
      );
      debugPrint(
        'Settings: ${Hive.box<SettingsModel>(settingsBoxName).length} items',
      );
      debugPrint(
        'Products Cache: ${Hive.box<ProductCacheModel>(productsCacheBoxName).length} items',
      );
      debugPrint(
        'Nutrition Data: ${Hive.box<NutritionDataModel>(nutritionDataBoxName).length} items',
      );
      debugPrint(
        'Health Profiles: ${Hive.box<HealthProfileModel>(healthProfilesBoxName).length} items',
      );
      debugPrint(
        'Sync Queue: ${Hive.box<SyncQueueItem>(syncQueueBoxName).length} items',
      );
      debugPrint(
        'Dead-Letter Queue: ${Hive.box<SyncQueueItem>(deadLetterQueueBoxName).length} items',
      );
      debugPrint('==================');
    }
  }
}
