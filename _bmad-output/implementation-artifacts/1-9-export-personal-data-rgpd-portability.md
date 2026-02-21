# Story 1.9: Export Personal Data (RGPD Portability)

## METADATA

- **Story ID**: 1.9
- **Epic**: Epic 1 - User Authentication & Profile Management
- **Title**: Export Personal Data (RGPD Portability)
- **Story Points**: 5
- **Priority**: High (Legal Compliance)
- **Sprint**: TBD
- **Status**: ready-for-dev
- **Created**: 2026-02-15
- **Updated**: 2026-02-15
- **Tags**: #rgpd #gdpr #data-portability #compliance #privacy
- **Dependencies**:
  - Story 1.1 (Create Account)
  - Story 1.6 (Health Profile)
  - Story 1.7 (Dietary Preferences)
  - Story 1.8 (Multi-Device Sync)
  - Epic 2 (Inventory Management - for product data)

---

## USER STORY

**As a** FrigoFute user concerned about data privacy
**I want** to export all my personal data in a portable, machine-readable format
**So that** I can exercise my right to data portability (RGPD Article 20), transfer my data to another service, or keep a personal backup

### User Value Proposition

Under RGPD (GDPR) Article 20, users have the legal right to receive their personal data in a structured, commonly used, and machine-readable format. This empowers users to:

- **Portability**: Transfer their data to a competing service
- **Transparency**: See exactly what data FrigoFute stores about them
- **Backup**: Keep a personal copy of their data
- **Control**: Exercise ownership over their personal information

### Business Value

- **Legal Compliance**: RGPD Article 20 is mandatory for EU operations
- **User Trust**: Demonstrates transparency and respect for user privacy
- **Competitive Advantage**: Proactive privacy features differentiate FrigoFute
- **Avoid Penalties**: Non-compliance can result in fines up to €20M or 4% of global revenue

### Legal Context (RGPD Article 20)

**Scope**: Right applies when:
- Processing is based on consent (Article 6(1)(a)) or contract (Article 6(1)(b))
- Processing is carried out by automated means

**Requirements**:
- Provide data in structured, commonly used, machine-readable format
- Respond within **30 days** (can extend to 3 months for complex requests)
- Provide **free of charge** (no additional fees)
- Include only user-provided data and observed interactions (not derived/inferred data)

---

## ACCEPTANCE CRITERIA

### AC-1: Access Export Data Screen ✅

**Given** a user is logged in
**When** user navigates to Settings → Privacy → "Export My Data"
**Then**:
- Export data screen displays
- Screen shows RGPD Article 20 explanation
- Lists all data categories to be included
- Shows estimated export size (e.g., "Approximately 15 MB")

**Verification:**
- Navigate to Settings → Privacy
- Tap "Export My Data"
- Screen appears with legal text and data categories

---

### AC-2: Select Export Formats ✅

**Given** user is on Export Data screen
**When** user views format options
**Then** user can select:
- ☑ JSON (machine-readable, recommended)
- ☑ CSV (spreadsheet-compatible)
- ☐ PDF (human-readable report, optional)

**And** at least one format must be selected to proceed

**Verification:**
- Verify checkboxes for each format
- Deselect all → "Request Export" button disabled
- Select at least one → button enabled

---

### AC-3: View Data Categories Included ✅

**Given** user is on Export Data screen
**When** screen loads
**Then** user sees a clear list of what's included:
- ✓ User profile (email, name, photo)
- ✓ Health profile (weight, BMR, TDEE, dietary restrictions, allergies)
- ✓ All inventory products (1,247 items)
- ✓ Nutrition history (342 entries)
- ✓ Weight history (150 measurements)
- ✓ Settings and preferences
- ✓ Device registration data
- ✓ Recipes saved/created
- ✓ Meal plans
- ✓ Shopping lists

**Verification:**
- Checklist shows all data categories
- Item counts displayed dynamically (e.g., "1,247 products")

---

### AC-4: Confirm Export Request ✅

**Given** user has selected export formats
**When** user taps "Request Export"
**Then**:
- Confirmation dialog appears
- Dialog lists data categories and counts
- Shows security warning: "Do not share this file with others"
- Shows file retention: "Export will be available for 7 days"
- Buttons: "Cancel" / "Confirm Export"

**Verification:**
- Tap "Request Export"
- Dialog appears with summary
- "Confirm Export" starts process
- "Cancel" dismisses dialog

---

### AC-5: Export Progress Indicator ✅

**Given** user confirmed export request
**When** export is in progress
**Then**:
- Progress screen displays
- Shows percentage: "45%"
- Shows current step: "Processing inventory items (340/1,247)..."
- Shows estimated time remaining: "2 minutes 30 seconds"
- Provides "Cancel Export" button

**Verification:**
- Export starts within 2 seconds
- Progress updates every 500ms
- Can cancel mid-export
- Cancelled export cleans up partial files

---

### AC-6: Export Completion Success ✅

**Given** export completes successfully
**When** all data is packaged
**Then**:
- Success screen displays
- Shows file details:
  - Name: `frigofute_data_2026-02-15_143022.zip`
  - Size: 15.4 MB
  - Format: ZIP (JSON + CSV)
  - Created: 15/02/2026 14:30
  - Expires: 22/02/2026 14:30 (7 days)
- Action buttons:
  - "Download to Phone"
  - "Share File"
  - "Preview Data"
- Shows security notice: "This file contains your personal data. Delete after use."

**Verification:**
- Export completes within 5 minutes for 10,000+ items
- File saved to temp directory
- File is valid ZIP archive
- Can extract and read JSON/CSV

---

### AC-7: Download Export to Device ✅

**Given** export is complete
**When** user taps "Download to Phone"
**Then**:
- File saves to device Downloads folder
- Success toast: "Export saved to Downloads/frigofute_data_2026-02-15.zip"
- File manager app can open folder
- User can access file from Downloads

**Verification:**
- File appears in Downloads folder
- Filename matches pattern: `frigofute_data_YYYY-MM-DD_HHMMSS.zip`
- File is accessible via file manager

---

### AC-8: Share Export File ✅

**Given** export is complete
**When** user taps "Share File"
**Then**:
- Platform share sheet opens
- User can share via:
  - Email
  - Cloud storage (Google Drive, Dropbox, iCloud)
  - Messaging apps
  - Airdrop (iOS)
  - Nearby Share (Android)
- File shares with correct filename and MIME type

**Verification:**
- Share sheet appears
- Can email file as attachment
- Can upload to Google Drive
- Shared file is valid and complete

---

### AC-9: JSON Export Format Validation ✅

**Given** user selected JSON format
**When** export completes
**Then** JSON file contains:
- `export_metadata`: timestamp, userId, version, RGPD Article 20 flag
- `user_profile`: email, name, photo, creation date
- `health_profile`: weight, BMR, TDEE, macros, dietary restrictions, allergies
- `inventory`: array of all products with all fields
- `nutrition_history`: array of all nutrition entries
- `weight_history`: array of weight measurements
- `settings`: all app preferences
- `devices`: all registered devices
- `recipes`: saved/created recipes
- `meal_plans`: meal plans

**And** JSON is valid (can parse with `jsonDecode()`)
**And** JSON is pretty-printed for readability

**Verification:**
- Extract ZIP
- Open `frigofute_data_export.json`
- Verify valid JSON (no syntax errors)
- Verify all sections present
- Verify counts match database

---

### AC-10: CSV Export Format Validation ✅

**Given** user selected CSV format
**When** export completes
**Then** ZIP contains multiple CSV files:
- `inventory.csv`: All products
- `nutrition_history.csv`: All nutrition entries
- `weight_history.csv`: Weight measurements
- `settings.csv`: App preferences
- `devices.csv`: Registered devices

**And** each CSV has:
- Header row with column names
- Properly escaped values (quotes, commas)
- UTF-8 encoding for French characters

**Verification:**
- Extract ZIP
- Open each CSV in Excel/Sheets
- Verify headers match data
- Verify no corrupted characters (é, à, etc.)

---

### AC-11: Export Includes All User Data ✅

**Given** user has extensive data:
- 2,500 inventory products
- 1,200 nutrition entries
- 300 weight measurements
- 15 saved recipes
- 4 meal plans
- 3 devices

**When** export runs
**Then** all items are included in export:
- Verify count: 2,500 products in JSON inventory array
- Verify count: 1,200 entries in nutrition_history
- Verify count: 300 entries in weight_history
- Verify count: 15 recipes
- Verify count: 4 meal plans
- No data omitted

**Verification:**
- Check JSON array lengths
- Check CSV row counts (subtract 1 for header)
- Compare with Firestore/Hive counts

---

### AC-12: Export Excludes Derived/Inferred Data ✅

**Given** RGPD Article 20 scope
**When** export runs
**Then** excludes:
- ❌ Recipe recommendations (algorithmic)
- ❌ AI-generated meal plans (inferred)
- ❌ Predicted expiration dates (ML models)
- ❌ Waste reduction scores (calculated metrics)
- ❌ System-generated IDs (internal references)

**And** includes only:
- ✅ User-provided data (manual entries)
- ✅ Observed interactions (consumption history)
- ✅ User preferences (settings)

**Verification:**
- Review JSON structure
- Verify no ML model outputs included
- Verify only user-input data present

---

### AC-13: Export File Auto-Deletes After 7 Days ✅

**Given** export was created 7 days ago
**When** 7 days have elapsed since creation
**Then**:
- File is automatically deleted from device temp storage
- Background task removes file securely
- User receives notification (optional): "Your data export from 8 days ago has been securely deleted"

**Verification:**
- Create export
- Wait 7 days (or mock time)
- Verify file deleted
- Verify file not accessible

---

### AC-14: Security Warning Display ✅

**Given** export is complete
**When** user views completion screen
**Then** prominent security warning displays:
- ⚠️ Icon
- "Security Notice"
- "This file contains all your personal data. Do not share this file with others unless transferring to a trusted service."
- "Delete this file after use to protect your privacy."

**Verification:**
- Warning displays prominently
- Warning uses alert styling (orange/yellow)
- Warning includes icon

---

### AC-15: Audit Log for Export Requests ✅

**Given** RGPD compliance requirement
**When** user requests export
**Then**:
- Export request logged to Firestore `audit_logs` collection
- Log includes:
  - Timestamp
  - User ID
  - Formats requested (JSON, CSV, PDF)
  - IP address (if available)
  - User agent (app version)
- Export completion logged with file size

**Verification:**
- Check Firestore `audit_logs/{userId}` collection
- Verify entry created with timestamp
- Verify logs retained for 3 years (legal requirement)

---

### AC-16: Handle Export Errors Gracefully ✅

**Given** export encounters an error (network, storage, Firestore timeout)
**When** error occurs
**Then**:
- Error screen displays
- Shows user-friendly message: "Export failed. Please try again."
- Shows technical details (in debug mode only)
- Provides "Retry Export" button
- Logs error to Crashlytics
- Cleans up partial files

**Verification:**
- Simulate Firestore timeout
- Verify error screen appears
- Tap "Retry" → export restarts
- Verify no orphaned files left

---

### AC-17: Preview Data Before Download ✅

**Given** export is complete
**When** user taps "Preview Data"
**Then**:
- Preview screen displays
- Shows first 100 lines of JSON (formatted)
- Shows file structure summary:
  - "User Profile: 1 entry"
  - "Inventory: 1,247 products"
  - "Nutrition History: 342 entries"
- Provides "Download Full Export" button

**Verification:**
- Tap "Preview Data"
- JSON preview displays (read-only)
- Can scroll through preview
- "Download Full Export" navigates back

---

### AC-18: Multiple Export Requests Handling ✅

**Given** user already has an active export
**When** user requests another export
**Then**:
- Dialog appears: "You already have an export in progress. Cancel it?"
- Options: "View Progress" / "Cancel and Start New"
- If "Cancel and Start New":
  - Previous export cancelled
  - New export starts
- If "View Progress":
  - Navigate to existing progress screen

**Verification:**
- Start export
- Request another export while first is running
- Dialog appears
- Can cancel first and start second

---

### AC-19: Export Response Time (Legal SLA) ✅

**Given** RGPD requires response within 30 days
**When** user requests export
**Then**:
- Export generates within **5 minutes** for datasets < 10,000 items
- Export generates within **15 minutes** for datasets > 10,000 items
- If export exceeds 15 minutes:
  - Email sent to user with download link when ready
  - "Export in progress" notification

**Verification:**
- Test with 5,000 products: < 5 minutes
- Test with 15,000 products: < 15 minutes
- Verify email notification for long exports

---

### AC-20: README File in Export ✅

**Given** export is complete
**When** user opens ZIP file
**Then** ZIP contains `README.txt`:
- Export type: "GDPR Article 20 Data Portability Export"
- Export date
- User ID
- Security warning
- File descriptions:
  - `frigofute_data_export.json`: Complete structured data
  - `inventory.csv`: All inventory products
  - `nutrition_history.csv`: Nutrition tracking data
  - etc.
- Contact support info

**Verification:**
- Extract ZIP
- Open `README.txt`
- Verify all files described
- Verify user-friendly language

---

## TECHNICAL SPECIFICATIONS

### 1. Feature Structure

```
lib/
  features/
    data_export/                          # NEW FEATURE
      domain/
        entities/
          user_data_export.dart           # Aggregate all user data
          export_metadata.dart            # Export timestamp, version
          export_request.dart             # User request details
          export_result.dart              # Completed export info
          export_progress.dart            # Progress state
        repositories/
          data_export_repository.dart     # Repository contract
        usecases/
          collect_user_data_usecase.dart  # Aggregate data
          generate_json_export_usecase.dart
          generate_csv_export_usecase.dart
          create_export_archive_usecase.dart
          share_export_usecase.dart
      data/
        datasources/
          firestore_data_source.dart      # Query Firestore
          hive_data_source.dart           # Query Hive
        repositories/
          data_export_repository_impl.dart
        services/
          json_export_generator.dart      # Generate JSON
          csv_export_generator.dart       # Generate CSV
          export_archive_service.dart     # Create ZIP
          export_audit_service.dart       # Log requests
      presentation/
        providers/
          data_export_providers.dart      # Riverpod state
          export_progress_provider.dart
          export_result_provider.dart
        screens/
          export_data_screen.dart         # Main export screen
          export_progress_screen.dart     # Progress UI
          export_complete_screen.dart     # Success screen
          export_preview_screen.dart      # Preview JSON
        widgets/
          format_selector_widget.dart     # Checkboxes
          data_categories_list.dart       # What's included
          security_warning_card.dart      # Warning notice
```

### 2. Domain Entities

#### UserDataExport

```dart
// lib/features/data_export/domain/entities/user_data_export.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_data_export.freezed.dart';
part 'user_data_export.g.dart';

@freezed
class UserDataExport with _$UserDataExport {
  const factory UserDataExport({
    required ExportMetadata exportMetadata,
    required UserProfileData userProfile,
    HealthProfileData? healthProfile,
    required List<ProductData> inventory,
    required List<NutritionEntryData> nutritionHistory,
    required List<WeightMeasurement> weightHistory,
    required SettingsData settings,
    required List<DeviceData> devices,
    List<RecipeData>? recipes,
    List<MealPlanData>? mealPlans,
  }) = _UserDataExport;

  factory UserDataExport.fromJson(Map<String, dynamic> json) =>
      _$UserDataExportFromJson(json);
}

@freezed
class ExportMetadata with _$ExportMetadata {
  const factory ExportMetadata({
    required DateTime exportedAt,
    required String userId,
    @Default('1.0') String exportFormatVersion,
    @Default(true) bool gdprArticle20Compliant,
  }) = _ExportMetadata;

  factory ExportMetadata.fromJson(Map<String, dynamic> json) =>
      _$ExportMetadataFromJson(json);
}

// Data classes for each category
@freezed
class UserProfileData with _$UserProfileData {
  const factory UserProfileData({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
    required DateTime createdAt,
    DateTime? lastLoginAt,
  }) = _UserProfileData;

  factory UserProfileData.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDataFromJson(json);
}

@freezed
class HealthProfileData with _$HealthProfileData {
  const factory HealthProfileData({
    required String profileId,
    required String profileType,
    required double tdee,
    required double bmr,
    required MacroTargets macroTargets,
    required List<String> dietaryRestrictions,
    required List<AllergenData> allergies,
  }) = _HealthProfileData;

  factory HealthProfileData.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileDataFromJson(json);
}

@freezed
class ProductData with _$ProductData {
  const factory ProductData({
    required String productId,
    required String name,
    required String category,
    required DateTime expirationDate,
    required String storageLocation,
    required String status,
    required DateTime addedAt,
    String? barcode,
    String? photoUrl,
  }) = _ProductData;

  factory ProductData.fromJson(Map<String, dynamic> json) =>
      _$ProductDataFromJson(json);
}

@freezed
class NutritionEntryData with _$NutritionEntryData {
  const factory NutritionEntryData({
    required String entryId,
    required DateTime date,
    required String mealType,
    required double calories,
    required double proteins,
    required double carbs,
    required double fats,
    String? photoUrl,
  }) = _NutritionEntryData;

  factory NutritionEntryData.fromJson(Map<String, dynamic> json) =>
      _$NutritionEntryDataFromJson(json);
}

@freezed
class WeightMeasurement with _$WeightMeasurement {
  const factory WeightMeasurement({
    required DateTime date,
    required double weightKg,
    double? bodyFatPercentage,
    double? muscleMassKg,
  }) = _WeightMeasurement;

  factory WeightMeasurement.fromJson(Map<String, dynamic> json) =>
      _$WeightMeasurementFromJson(json);
}

@freezed
class DeviceData with _$DeviceData {
  const factory DeviceData({
    required String deviceId,
    required String deviceName,
    required String deviceType,
    required String osVersion,
    required String appVersion,
    required DateTime lastSeenAt,
  }) = _DeviceData;

  factory DeviceData.fromJson(Map<String, dynamic> json) =>
      _$DeviceDataFromJson(json);
}
```

#### ExportRequest

```dart
// lib/features/data_export/domain/entities/export_request.dart

@freezed
class ExportRequest with _$ExportRequest {
  const factory ExportRequest({
    required String userId,
    required Set<String> selectedFormats, // {'json', 'csv', 'pdf'}
    required DateTime requestedAt,
  }) = _ExportRequest;
}
```

#### ExportProgress

```dart
// lib/features/data_export/domain/entities/export_progress.dart

@freezed
class ExportProgress with _$ExportProgress {
  const factory ExportProgress({
    required double percentage,          // 0-100
    required int itemsProcessed,
    required int totalItems,
    required String currentStep,
    DateTime? estimatedCompletion,
  }) = _ExportProgress;
}
```

#### ExportResult

```dart
// lib/features/data_export/domain/entities/export_result.dart

@freezed
class ExportResult with _$ExportResult {
  const factory ExportResult({
    required String filePath,
    required int fileSizeBytes,
    required DateTime completedAt,
    required DateTime expiresAt,         // completedAt + 7 days
    required List<String> formats,
  }) = _ExportResult;
}
```

### 3. Data Collection Service

```dart
// lib/features/data_export/data/services/data_collection_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class DataCollectionService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DataCollectionService(this._auth, this._firestore);

  /// Collect all user data from all sources
  Future<UserDataExport> collectAllUserData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw UnAuthenticatedException();

    // Collect data in parallel
    final results = await Future.wait([
      _collectUserProfile(userId),
      _collectHealthProfile(userId),
      _collectInventory(userId),
      _collectNutritionHistory(userId),
      _collectWeightHistory(userId),
      _collectSettings(userId),
      _collectDevices(userId),
      _collectRecipes(userId),
      _collectMealPlans(userId),
    ]);

    return UserDataExport(
      exportMetadata: ExportMetadata(
        exportedAt: DateTime.now(),
        userId: userId,
      ),
      userProfile: results[0] as UserProfileData,
      healthProfile: results[1] as HealthProfileData?,
      inventory: results[2] as List<ProductData>,
      nutritionHistory: results[3] as List<NutritionEntryData>,
      weightHistory: results[4] as List<WeightMeasurement>,
      settings: results[5] as SettingsData,
      devices: results[6] as List<DeviceData>,
      recipes: results[7] as List<RecipeData>?,
      mealPlans: results[8] as List<MealPlanData>?,
    );
  }

  Future<UserProfileData> _collectUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('User profile not found');

    final data = doc.data()!;
    return UserProfileData(
      userId: userId,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  Future<HealthProfileData?> _collectHealthProfile(String userId) async {
    try {
      // From Hive (encrypted)
      final box = Hive.box<HealthProfileModel>('health_profiles_box');
      final profile = box.get('active_profile');
      if (profile == null) return null;

      return HealthProfileData(
        profileId: profile.id,
        profileType: profile.profileType,
        tdee: profile.tdee,
        bmr: profile.bmr,
        macroTargets: MacroTargets(
          proteinsPercent: profile.macroTargets.proteinsPercent,
          carbsPercent: profile.macroTargets.carbsPercent,
          fatsPercent: profile.macroTargets.fatsPercent,
        ),
        dietaryRestrictions: profile.dietaryRestrictions,
        allergies: profile.allergies
            .map((a) => AllergenData(
                  name: a.name,
                  severity: a.severity.toString(),
                  offCode: a.offCode,
                ))
            .toList(),
      );
    } catch (e) {
      debugPrint('Error collecting health profile: $e');
      return null;
    }
  }

  Future<List<ProductData>> _collectInventory(String userId) async {
    final List<ProductData> allProducts = [];
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('inventory');

    // Paginate for large datasets
    DocumentSnapshot? lastDoc;
    const pageSize = 100;

    while (true) {
      Query pagedQuery = query.limit(pageSize);
      if (lastDoc != null) {
        pagedQuery = pagedQuery.startAfterDocument(lastDoc);
      }

      final snapshot = await pagedQuery.get();
      if (snapshot.docs.isEmpty) break;

      allProducts.addAll(
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ProductData(
            productId: doc.id,
            name: data['name'] as String,
            category: data['category'] as String,
            expirationDate: (data['expirationDate'] as Timestamp).toDate(),
            storageLocation: data['storageLocation'] as String,
            status: data['status'] as String,
            addedAt: (data['addedAt'] as Timestamp).toDate(),
            barcode: data['barcode'] as String?,
            photoUrl: data['photoUrl'] as String?,
          );
        }),
      );

      lastDoc = snapshot.docs.last;
      if (snapshot.docs.length < pageSize) break;
    }

    return allProducts;
  }

  Future<List<NutritionEntryData>> _collectNutritionHistory(
    String userId,
  ) async {
    // From Hive (encrypted)
    final box = Hive.box<NutritionDataModel>('nutrition_box');
    final entries = box.values.toList();

    return entries
        .map((e) => NutritionEntryData(
              entryId: e.id,
              date: e.date,
              mealType: e.mealType,
              calories: e.calories,
              proteins: e.proteins,
              carbs: e.carbs,
              fats: e.fats,
              photoUrl: e.photoUrl,
            ))
        .toList();
  }

  Future<List<WeightMeasurement>> _collectWeightHistory(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_profiles')
        .doc('active')
        .get();

    if (!doc.exists) return [];

    final data = doc.data()!;
    final weightHistory = data['weightHistory'] as List<dynamic>? ?? [];

    return weightHistory
        .map((w) => WeightMeasurement(
              date: (w['date'] as Timestamp).toDate(),
              weightKg: (w['weight'] as num).toDouble(),
              bodyFatPercentage: w['bodyFatPercentage'] as double?,
              muscleMassKg: w['muscleMassKg'] as double?,
            ))
        .toList();
  }

  Future<SettingsData> _collectSettings(String userId) async {
    final box = Hive.box('settings_box');
    return SettingsData(
      theme: box.get('theme') as String? ?? 'light',
      locale: box.get('locale') as String? ?? 'fr',
      notificationsEnabled: box.get('notifications_enabled') as bool? ?? true,
      dlcAlertDelayDays: box.get('dlc_alert_delay') as int? ?? 2,
      ddmAlertDelayDays: box.get('ddm_alert_delay') as int? ?? 5,
      analyticsEnabled: box.get('analytics_enabled') as bool? ?? false,
    );
  }

  Future<List<DeviceData>> _collectDevices(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          return DeviceData(
            deviceId: doc.id,
            deviceName: data['deviceName'] as String,
            deviceType: data['deviceType'] as String,
            osVersion: data['osVersion'] as String,
            appVersion: data['appVersion'] as String,
            lastSeenAt: (data['lastSeenAt'] as Timestamp).toDate(),
          );
        })
        .toList();
  }

  Future<List<RecipeData>?> _collectRecipes(String userId) async {
    // TODO: Implement when recipes feature exists (Epic 6)
    return null;
  }

  Future<List<MealPlanData>?> _collectMealPlans(String userId) async {
    // TODO: Implement when meal plans feature exists (Epic 9)
    return null;
  }
}
```

### 4. JSON Export Generator

```dart
// lib/features/data_export/data/services/json_export_generator.dart

import 'dart:convert';

class JsonExportGenerator {
  /// Generate complete JSON export
  String generateJsonExport(UserDataExport data) {
    final json = {
      'export_metadata': {
        'exported_at': data.exportMetadata.exportedAt.toIso8601String(),
        'data_subject_user_id': data.exportMetadata.userId,
        'export_format_version': data.exportMetadata.exportFormatVersion,
        'gdpr_article_20': data.exportMetadata.gdprArticle20Compliant,
      },
      'user_profile': _userProfileToJson(data.userProfile),
      if (data.healthProfile != null)
        'health_profile': _healthProfileToJson(data.healthProfile!),
      'inventory': data.inventory.map((p) => _productToJson(p)).toList(),
      'nutrition_history':
          data.nutritionHistory.map((n) => _nutritionToJson(n)).toList(),
      'weight_history':
          data.weightHistory.map((w) => _weightToJson(w)).toList(),
      'settings': _settingsToJson(data.settings),
      'devices': data.devices.map((d) => _deviceToJson(d)).toList(),
      if (data.recipes != null && data.recipes!.isNotEmpty)
        'recipes': data.recipes!.map((r) => _recipeToJson(r)).toList(),
      if (data.mealPlans != null && data.mealPlans!.isNotEmpty)
        'meal_plans': data.mealPlans!.map((m) => _mealPlanToJson(m)).toList(),
    };

    // Pretty-print for human readability
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  Map<String, dynamic> _userProfileToJson(UserProfileData profile) {
    return {
      'user_id': profile.userId,
      'email': profile.email,
      'display_name': profile.displayName,
      'photo_url': profile.photoUrl,
      'created_at': profile.createdAt.toIso8601String(),
      'last_login_at': profile.lastLoginAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _healthProfileToJson(HealthProfileData profile) {
    return {
      'profile_id': profile.profileId,
      'profile_type': profile.profileType,
      'tdee': profile.tdee,
      'bmr': profile.bmr,
      'macro_targets': {
        'proteins_percent': profile.macroTargets.proteinsPercent,
        'carbs_percent': profile.macroTargets.carbsPercent,
        'fats_percent': profile.macroTargets.fatsPercent,
      },
      'dietary_restrictions': profile.dietaryRestrictions,
      'allergies': profile.allergies
          .map((a) => {
                'name': a.name,
                'severity': a.severity,
                'off_code': a.offCode,
              })
          .toList(),
    };
  }

  Map<String, dynamic> _productToJson(ProductData product) {
    return {
      'product_id': product.productId,
      'name': product.name,
      'category': product.category,
      'expiration_date': product.expirationDate.toIso8601String(),
      'storage_location': product.storageLocation,
      'status': product.status,
      'added_at': product.addedAt.toIso8601String(),
      'barcode': product.barcode,
      'photo_url': product.photoUrl,
    };
  }

  Map<String, dynamic> _nutritionToJson(NutritionEntryData entry) {
    return {
      'entry_id': entry.entryId,
      'date': entry.date.toIso8601String(),
      'meal_type': entry.mealType,
      'calories': entry.calories,
      'proteins': entry.proteins,
      'carbs': entry.carbs,
      'fats': entry.fats,
      'photo_url': entry.photoUrl,
    };
  }

  Map<String, dynamic> _weightToJson(WeightMeasurement weight) {
    return {
      'date': weight.date.toIso8601String(),
      'weight_kg': weight.weightKg,
      'body_fat_percentage': weight.bodyFatPercentage,
      'muscle_mass_kg': weight.muscleMassKg,
    };
  }

  Map<String, dynamic> _settingsToJson(SettingsData settings) {
    return {
      'theme': settings.theme,
      'locale': settings.locale,
      'notifications_enabled': settings.notificationsEnabled,
      'dlc_alert_delay_days': settings.dlcAlertDelayDays,
      'ddm_alert_delay_days': settings.ddmAlertDelayDays,
      'analytics_enabled': settings.analyticsEnabled,
    };
  }

  Map<String, dynamic> _deviceToJson(DeviceData device) {
    return {
      'device_id': device.deviceId,
      'device_name': device.deviceName,
      'device_type': device.deviceType,
      'os_version': device.osVersion,
      'app_version': device.appVersion,
      'last_seen_at': device.lastSeenAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _recipeToJson(RecipeData recipe) {
    // TODO: Implement when recipes exist
    return {};
  }

  Map<String, dynamic> _mealPlanToJson(MealPlanData mealPlan) {
    // TODO: Implement when meal plans exist
    return {};
  }
}
```

### 5. CSV Export Generator

```dart
// lib/features/data_export/data/services/csv_export_generator.dart

import 'package:csv/csv.dart';

class CsvExportGenerator {
  /// Generate multiple CSV files
  Map<String, String> generateCsvExports(UserDataExport data) {
    final csvFiles = <String, String>{};

    csvFiles['inventory.csv'] = _generateInventoryCsv(data.inventory);
    csvFiles['nutrition_history.csv'] =
        _generateNutritionCsv(data.nutritionHistory);
    csvFiles['weight_history.csv'] =
        _generateWeightHistoryCsv(data.weightHistory);
    csvFiles['settings.csv'] = _generateSettingsCsv(data.settings);
    csvFiles['devices.csv'] = _generateDevicesCsv(data.devices);

    return csvFiles;
  }

  String _generateInventoryCsv(List<ProductData> products) {
    final List<List<dynamic>> csvData = [
      // Header row
      [
        'Product ID',
        'Name',
        'Category',
        'Expiration Date',
        'Storage Location',
        'Status',
        'Added At',
        'Barcode',
        'Photo URL',
      ],
      // Data rows
      ...products.map((p) => [
            p.productId,
            p.name,
            p.category,
            p.expirationDate.toIso8601String(),
            p.storageLocation,
            p.status,
            p.addedAt.toIso8601String(),
            p.barcode ?? '',
            p.photoUrl ?? '',
          ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  String _generateNutritionCsv(List<NutritionEntryData> entries) {
    final List<List<dynamic>> csvData = [
      [
        'Date',
        'Meal Type',
        'Calories',
        'Protein (g)',
        'Carbs (g)',
        'Fats (g)',
        'Photo URL',
      ],
      ...entries.map((e) => [
            e.date.toIso8601String(),
            e.mealType,
            e.calories,
            e.proteins,
            e.carbs,
            e.fats,
            e.photoUrl ?? '',
          ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  String _generateWeightHistoryCsv(List<WeightMeasurement> measurements) {
    final List<List<dynamic>> csvData = [
      [
        'Date',
        'Weight (kg)',
        'Body Fat %',
        'Muscle Mass (kg)',
      ],
      ...measurements.map((w) => [
            w.date.toIso8601String(),
            w.weightKg,
            w.bodyFatPercentage ?? '',
            w.muscleMassKg ?? '',
          ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  String _generateSettingsCsv(SettingsData settings) {
    final List<List<dynamic>> csvData = [
      ['Setting', 'Value'],
      ['Theme', settings.theme],
      ['Locale', settings.locale],
      ['Notifications Enabled', settings.notificationsEnabled],
      ['DLC Alert Delay (days)', settings.dlcAlertDelayDays],
      ['DDM Alert Delay (days)', settings.ddmAlertDelayDays],
      ['Analytics Enabled', settings.analyticsEnabled],
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  String _generateDevicesCsv(List<DeviceData> devices) {
    final List<List<dynamic>> csvData = [
      [
        'Device ID',
        'Device Name',
        'Device Type',
        'OS Version',
        'App Version',
        'Last Seen',
      ],
      ...devices.map((d) => [
            d.deviceId,
            d.deviceName,
            d.deviceType,
            d.osVersion,
            d.appVersion,
            d.lastSeenAt.toIso8601String(),
          ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }
}
```

### 6. Export Archive Service

```dart
// lib/features/data_export/data/services/export_archive_service.dart

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportArchiveService {
  /// Create ZIP archive with all export files
  Future<ExportResult> createExportArchive(
    UserDataExport data,
    Set<String> selectedFormats,
  ) async {
    final archive = Archive();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .substring(0, 19); // YYYY-MM-DDTHH-MM-SS

    // Add JSON export
    if (selectedFormats.contains('json')) {
      final jsonContent = JsonExportGenerator().generateJsonExport(data);
      archive.addFile(
        ArchiveFile(
          'frigofute_data_export.json',
          jsonContent.codeUnits.length,
          jsonContent.codeUnits,
        ),
      );
    }

    // Add CSV exports
    if (selectedFormats.contains('csv')) {
      final csvFiles = CsvExportGenerator().generateCsvExports(data);
      csvFiles.forEach((filename, content) {
        archive.addFile(
          ArchiveFile(
            filename,
            content.codeUnits.length,
            content.codeUnits,
          ),
        );
      });
    }

    // Add README.txt
    final readme = _generateReadme(data, selectedFormats);
    archive.addFile(
      ArchiveFile(
        'README.txt',
        readme.codeUnits.length,
        readme.codeUnits,
      ),
    );

    // Write ZIP to temporary directory
    final tempDir = await getTemporaryDirectory();
    final zipFilename = 'frigofute_data_$timestamp.zip';
    final zipFile = File('${tempDir.path}/$zipFilename');
    await zipFile.writeAsBytes(ZipEncoder().encode(archive)!);

    return ExportResult(
      filePath: zipFile.path,
      fileSizeBytes: await zipFile.length(),
      completedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      formats: selectedFormats.toList(),
    );
  }

  String _generateReadme(UserDataExport data, Set<String> formats) {
    return '''
FrigoFute Data Export
=====================

Export Type: GDPR Article 20 - Right to Data Portability
Export Date: ${data.exportMetadata.exportedAt.toIso8601String()}
User ID: ${data.exportMetadata.userId}

⚠️ SECURITY WARNING ⚠️
This archive contains all your personal data from FrigoFute.
Do not share this file with others unless you are transferring
your data to a trusted service. Delete this file after use.

FILE DESCRIPTIONS:
------------------

${formats.contains('json') ? '''
frigofute_data_export.json
  Complete structured export in JSON format.
  Machine-readable, can be imported into other systems.
  Contains all data categories below.
''' : ''}

${formats.contains('csv') ? '''
inventory.csv
  All your inventory products in spreadsheet format.
  Open with Excel, Google Sheets, or Numbers.

nutrition_history.csv
  Your nutrition tracking history.

weight_history.csv
  Your weight measurements over time.

settings.csv
  Your app settings and preferences.

devices.csv
  Devices registered to your account.
''' : ''}

DATA CATEGORIES INCLUDED:
-------------------------
✓ User Profile: Email, name, profile photo
✓ Health Profile: Weight, BMR, TDEE, dietary restrictions, allergies
✓ Inventory: ${data.inventory.length} products
✓ Nutrition History: ${data.nutritionHistory.length} entries
✓ Weight History: ${data.weightHistory.length} measurements
✓ Settings: Theme, locale, notification preferences
✓ Devices: ${data.devices.length} registered devices

LEGAL NOTICE:
-------------
This export was generated in compliance with GDPR Article 20
(Right to Data Portability). The data is provided in a structured,
commonly used, and machine-readable format.

SUPPORT:
--------
If you have questions about this export, please contact:
support@frigofute.com

Retain Period: This file will be automatically deleted after 7 days.

Generated by FrigoFute v1.0.0
''';
  }

  /// Share export file via platform share
  Future<void> shareExport(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'FrigoFute Data Export',
      text: 'My personal data export from FrigoFute (GDPR Article 20)',
    );
  }

  /// Download export to device Downloads folder
  Future<String> downloadExport(String filePath) async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Downloads directory not available');
    }

    final filename = filePath.split(Platform.pathSeparator).last;
    final destPath = '${downloadsDir.path}/$filename';

    await File(filePath).copy(destPath);
    return destPath;
  }
}
```

### 7. Export Audit Service

```dart
// lib/features/data_export/data/services/export_audit_service.dart

class ExportAuditService {
  final FirebaseFirestore _firestore;

  ExportAuditService(this._firestore);

  /// Log export request (GDPR requirement)
  Future<void> logExportRequest({
    required String userId,
    required DateTime timestamp,
    required Set<String> formats,
  }) async {
    await _firestore
        .collection('audit_logs')
        .doc(userId)
        .collection('data_exports')
        .add({
      'event': 'export_requested',
      'timestamp': FieldValue.serverTimestamp(),
      'formats': formats.toList(),
      'user_agent': 'app/1.0.0',
    });

    debugPrint('Export request logged for user $userId');
  }

  /// Log export completion
  Future<void> logExportCompletion({
    required String userId,
    required String filePath,
    required int fileSizeBytes,
    required DateTime completedAt,
  }) async {
    await _firestore
        .collection('audit_logs')
        .doc(userId)
        .collection('data_exports')
        .add({
      'event': 'export_completed',
      'timestamp': FieldValue.serverTimestamp(),
      'completed_at': completedAt.toIso8601String(),
      'file_size_bytes': fileSizeBytes,
    });

    debugPrint('Export completion logged for user $userId');
  }
}
```

### 8. Riverpod Providers

```dart
// lib/features/data_export/presentation/providers/data_export_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Services
final dataCollectionServiceProvider = Provider<DataCollectionService>((ref) {
  return DataCollectionService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

final jsonExportGeneratorProvider = Provider<JsonExportGenerator>((ref) {
  return JsonExportGenerator();
});

final csvExportGeneratorProvider = Provider<CsvExportGenerator>((ref) {
  return CsvExportGenerator();
});

final exportArchiveServiceProvider = Provider<ExportArchiveService>((ref) {
  return ExportArchiveService();
});

final exportAuditServiceProvider = Provider<ExportAuditService>((ref) {
  return ExportAuditService(FirebaseFirestore.instance);
});

// State
final selectedExportFormatsProvider = StateProvider<Set<String>>((ref) {
  return {'json', 'csv'}; // Default selection
});

final exportProgressProvider = StateProvider<ExportProgress?>((ref) => null);

final exportResultProvider = StateProvider<ExportResult?>((ref) => null);

final isExportingProvider = StateProvider<bool>((ref) => false);

// Use case
final exportDataUsecaseProvider = Provider<ExportDataUsecase>((ref) {
  return ExportDataUsecase(
    dataCollectionService: ref.watch(dataCollectionServiceProvider),
    jsonGenerator: ref.watch(jsonExportGeneratorProvider),
    csvGenerator: ref.watch(csvExportGeneratorProvider),
    archiveService: ref.watch(exportArchiveServiceProvider),
    auditService: ref.watch(exportAuditServiceProvider),
  );
});
```

### 9. Export Use Case

```dart
// lib/features/data_export/domain/usecases/export_data_usecase.dart

class ExportDataUsecase {
  final DataCollectionService dataCollectionService;
  final JsonExportGenerator jsonGenerator;
  final CsvExportGenerator csvGenerator;
  final ExportArchiveService archiveService;
  final ExportAuditService auditService;

  ExportDataUsecase({
    required this.dataCollectionService,
    required this.jsonGenerator,
    required this.csvGenerator,
    required this.archiveService,
    required this.auditService,
  });

  /// Execute export workflow
  Future<ExportResult> call({
    required ExportRequest request,
    required void Function(ExportProgress) onProgress,
  }) async {
    try {
      // 1. Log request
      await auditService.logExportRequest(
        userId: request.userId,
        timestamp: request.requestedAt,
        formats: request.selectedFormats,
      );

      // 2. Collect all user data
      onProgress(ExportProgress(
        percentage: 10,
        itemsProcessed: 0,
        totalItems: 0,
        currentStep: 'Collecting user data...',
      ));

      final userData = await dataCollectionService.collectAllUserData();

      // 3. Generate exports
      onProgress(ExportProgress(
        percentage: 50,
        itemsProcessed: userData.inventory.length,
        totalItems: userData.inventory.length +
            userData.nutritionHistory.length +
            userData.weightHistory.length,
        currentStep: 'Generating export files...',
      ));

      // 4. Create archive
      onProgress(ExportProgress(
        percentage: 80,
        itemsProcessed: 0,
        totalItems: 0,
        currentStep: 'Creating archive...',
      ));

      final result = await archiveService.createExportArchive(
        userData,
        request.selectedFormats,
      );

      // 5. Log completion
      await auditService.logExportCompletion(
        userId: request.userId,
        filePath: result.filePath,
        fileSizeBytes: result.fileSizeBytes,
        completedAt: result.completedAt,
      );

      // 6. Schedule auto-delete after 7 days
      _scheduleAutoDelete(result.filePath, result.expiresAt);

      onProgress(ExportProgress(
        percentage: 100,
        itemsProcessed: 0,
        totalItems: 0,
        currentStep: 'Export complete!',
      ));

      return result;
    } catch (e) {
      debugPrint('Export failed: $e');
      rethrow;
    }
  }

  void _scheduleAutoDelete(String filePath, DateTime expiresAt) {
    // TODO: Implement background task to delete file after 7 days
    // Use WorkManager (Android) or BackgroundTasks (iOS)
  }
}
```

### 10. UI Screens

#### Export Data Screen

```dart
// lib/features/data_export/presentation/screens/export_data_screen.dart

class ExportDataScreen extends ConsumerWidget {
  const ExportDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFormats = ref.watch(selectedExportFormatsProvider);
    final isExporting = ref.watch(isExportingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export My Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RGPD Article 20 explanation
            _buildLegalNotice(),
            const SizedBox(height: 24),

            // Data categories
            _buildDataCategoriesSection(ref),
            const SizedBox(height: 24),

            // Format selector
            _buildFormatSelector(ref, selectedFormats),
            const SizedBox(height: 24),

            // Security warning
            _buildSecurityWarning(),
            const SizedBox(height: 32),

            // Request Export button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedFormats.isEmpty || isExporting
                    ? null
                    : () => _requestExport(context, ref),
                child: isExporting
                    ? const CircularProgressIndicator()
                    : const Text('Request Export'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalNotice() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'RGPD Article 20 - Data Portability',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'You have the right to receive your personal data in a '
              'structured, commonly used, and machine-readable format. '
              'This export will include all data you have provided to FrigoFute.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCategoriesSection(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Categories Included',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildDataCategoryTile('User Profile', 'Email, name, profile photo'),
        _buildDataCategoryTile(
          'Health Profile',
          'Weight, BMR, TDEE, dietary restrictions, allergies',
        ),
        _buildDataCategoryTile('Inventory', '1,247 products'),
        _buildDataCategoryTile('Nutrition History', '342 entries'),
        _buildDataCategoryTile('Weight History', '150 measurements'),
        _buildDataCategoryTile('Settings', 'Theme, locale, preferences'),
        _buildDataCategoryTile('Devices', '3 registered devices'),
      ],
    );
  }

  Widget _buildDataCategoryTile(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
    );
  }

  Widget _buildFormatSelector(WidgetRef ref, Set<String> selectedFormats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Format',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: selectedFormats.contains('json'),
          onChanged: (selected) {
            if (selected == true) {
              ref.read(selectedExportFormatsProvider.notifier).state = {
                ...selectedFormats,
                'json'
              };
            } else {
              ref.read(selectedExportFormatsProvider.notifier).state =
                  selectedFormats.where((f) => f != 'json').toSet();
            }
          },
          title: const Text('JSON (Machine-Readable)'),
          subtitle: const Text('Complete structured data for system import'),
          secondary: const Icon(Icons.data_object),
        ),
        CheckboxListTile(
          value: selectedFormats.contains('csv'),
          onChanged: (selected) {
            if (selected == true) {
              ref.read(selectedExportFormatsProvider.notifier).state = {
                ...selectedFormats,
                'csv'
              };
            } else {
              ref.read(selectedExportFormatsProvider.notifier).state =
                  selectedFormats.where((f) => f != 'csv').toSet();
            }
          },
          title: const Text('CSV (Spreadsheet)'),
          subtitle: const Text('Tabular data for Excel, Google Sheets'),
          secondary: const Icon(Icons.table_chart),
        ),
      ],
    );
  }

  Widget _buildSecurityWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Notice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your export will contain all your personal data. '
                  'Do not share this file with others. '
                  'It will be automatically deleted after 7 days.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestExport(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Export'),
        content: const Text(
          'This will create an archive containing all your personal data. '
          'The export may take a few minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Navigate to progress screen
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ExportProgressScreen(),
        ),
      );
    }

    // Start export
    ref.read(isExportingProvider.notifier).state = true;

    try {
      final usecase = ref.read(exportDataUsecaseProvider);
      final result = await usecase.call(
        request: ExportRequest(
          userId: FirebaseAuth.instance.currentUser!.uid,
          selectedFormats: ref.read(selectedExportFormatsProvider),
          requestedAt: DateTime.now(),
        ),
        onProgress: (progress) {
          ref.read(exportProgressProvider.notifier).state = progress;
        },
      );

      ref.read(exportResultProvider.notifier).state = result;
      ref.read(isExportingProvider.notifier).state = false;

      // Navigate to complete screen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ExportCompleteScreen(),
          ),
        );
      }
    } catch (e) {
      ref.read(isExportingProvider.notifier).state = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}
```

#### Export Progress Screen

```dart
// lib/features/data_export/presentation/screens/export_progress_screen.dart

class ExportProgressScreen extends ConsumerWidget {
  const ExportProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(exportProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export in Progress'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: (progress?.percentage ?? 0) / 100,
              ),
              const SizedBox(height: 24),
              Text(
                '${progress?.percentage.toInt() ?? 0}%',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                progress?.currentStep ?? 'Preparing export...',
                textAlign: TextAlign.center,
              ),
              if (progress != null && progress.totalItems > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Items: ${progress.itemsProcessed}/${progress.totalItems}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Export Complete Screen

```dart
// lib/features/data_export/presentation/screens/export_complete_screen.dart

class ExportCompleteScreen extends ConsumerWidget {
  const ExportCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(exportResultProvider);

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No export result available')),
      );
    }

    final filename = result.filePath.split(Platform.pathSeparator).last;
    final fileSizeMB = (result.fileSizeBytes / 1024 / 1024).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Complete'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Export Completed Successfully',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // File info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Filename', filename),
                    _buildInfoRow('Size', '$fileSizeMB MB'),
                    _buildInfoRow(
                      'Format',
                      result.formats.join(', ').toUpperCase(),
                    ),
                    _buildInfoRow(
                      'Created',
                      DateFormat('dd/MM/yyyy HH:mm').format(result.completedAt),
                    ),
                    _buildInfoRow(
                      'Expires',
                      DateFormat('dd/MM/yyyy HH:mm').format(result.expiresAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Security notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This file contains your personal data. '
                      'Delete after use to protect your privacy. '
                      'File will be automatically deleted on ${DateFormat('dd/MM/yyyy').format(result.expiresAt)}.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadExport(context, ref, result.filePath),
                icon: const Icon(Icons.download),
                label: const Text('Download to Phone'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _shareExport(context, ref, result.filePath),
                icon: const Icon(Icons.share),
                label: const Text('Share File'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _previewExport(context, result.filePath),
                icon: const Icon(Icons.preview),
                label: const Text('Preview Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _downloadExport(
    BuildContext context,
    WidgetRef ref,
    String filePath,
  ) async {
    try {
      final archiveService = ref.read(exportArchiveServiceProvider);
      final destPath = await archiveService.downloadExport(filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export saved to Downloads')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _shareExport(
    BuildContext context,
    WidgetRef ref,
    String filePath,
  ) async {
    try {
      final archiveService = ref.read(exportArchiveServiceProvider);
      await archiveService.shareExport(filePath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  Future<void> _previewExport(BuildContext context, String filePath) async {
    // TODO: Implement preview screen
  }
}
```

---

## IMPLEMENTATION TASKS

### Task 1: Create Feature Structure ✅
**Estimated Time**: 1 hour

- [ ] Create `lib/features/data_export/` directory
- [ ] Create subdirectories: `domain/`, `data/`, `presentation/`
- [ ] Create entity files with Freezed annotations
- [ ] Run `flutter pub run build_runner build`

**Files to Create:**
- `lib/features/data_export/domain/entities/user_data_export.dart`
- `lib/features/data_export/domain/entities/export_request.dart`
- `lib/features/data_export/domain/entities/export_progress.dart`
- `lib/features/data_export/domain/entities/export_result.dart`

**Testing:**
- Verify Freezed code generation succeeds
- Verify entities compile without errors

---

### Task 2: Install Required Packages ✅
**Estimated Time**: 30 minutes

- [ ] Add `csv: ^6.0.0` to pubspec.yaml
- [ ] Add `archive: ^4.0.0` to pubspec.yaml
- [ ] Add `share_plus: ^9.0.0` (if not already installed)
- [ ] Run `flutter pub get`
- [ ] Verify package imports work

**Files to Modify:**
- `pubspec.yaml`

**Testing:**
- Import packages in a test file
- Verify no conflicts

---

### Task 3: Implement DataCollectionService ✅
**Estimated Time**: 8 hours

- [ ] Create `DataCollectionService` class
- [ ] Implement `collectAllUserData()` method
- [ ] Implement `_collectUserProfile()` from Firestore
- [ ] Implement `_collectHealthProfile()` from Hive
- [ ] Implement `_collectInventory()` with pagination
- [ ] Implement `_collectNutritionHistory()` from Hive
- [ ] Implement `_collectWeightHistory()` from Firestore
- [ ] Implement `_collectSettings()` from Hive
- [ ] Implement `_collectDevices()` from Firestore
- [ ] Add placeholders for recipes and meal plans
- [ ] Handle errors gracefully

**Files to Create:**
- `lib/features/data_export/data/services/data_collection_service.dart`

**Testing:**
- Test with real user data
- Test pagination with 2000+ products
- Test when health profile is missing
- Test when nutrition history is empty

---

### Task 4: Implement JSON Export Generator ✅
**Estimated Time**: 4 hours

- [ ] Create `JsonExportGenerator` class
- [ ] Implement `generateJsonExport()` method
- [ ] Convert all entities to JSON
- [ ] Use `JsonEncoder.withIndent()` for pretty-printing
- [ ] Validate JSON structure
- [ ] Handle null values correctly

**Files to Create:**
- `lib/features/data_export/data/services/json_export_generator.dart`

**Testing:**
- Generate JSON for sample data
- Verify JSON is valid (parse with `jsonDecode()`)
- Verify all fields present
- Verify UTF-8 encoding for French characters

---

### Task 5: Implement CSV Export Generator ✅
**Estimated Time**: 4 hours

- [ ] Create `CsvExportGenerator` class
- [ ] Implement `generateCsvExports()` method
- [ ] Generate `inventory.csv`
- [ ] Generate `nutrition_history.csv`
- [ ] Generate `weight_history.csv`
- [ ] Generate `settings.csv`
- [ ] Generate `devices.csv`
- [ ] Use `ListToCsvConverter` from `csv` package
- [ ] Handle special characters (quotes, commas)

**Files to Create:**
- `lib/features/data_export/data/services/csv_export_generator.dart`

**Testing:**
- Generate CSVs for sample data
- Open in Excel/Sheets
- Verify headers match data
- Verify no corrupted characters

---

### Task 6: Implement Export Archive Service ✅
**Estimated Time**: 5 hours

- [ ] Create `ExportArchiveService` class
- [ ] Implement `createExportArchive()` method
- [ ] Create ZIP archive using `archive` package
- [ ] Add JSON file to archive
- [ ] Add CSV files to archive
- [ ] Generate README.txt
- [ ] Write ZIP to temp directory
- [ ] Implement `shareExport()` using `share_plus`
- [ ] Implement `downloadExport()` to Downloads folder

**Files to Create:**
- `lib/features/data_export/data/services/export_archive_service.dart`

**Testing:**
- Create archive with sample data
- Verify ZIP is valid
- Extract and verify contents
- Test share functionality
- Test download to Downloads

---

### Task 7: Implement Export Audit Service ✅
**Estimated Time**: 2 hours

- [ ] Create `ExportAuditService` class
- [ ] Implement `logExportRequest()` method
- [ ] Implement `logExportCompletion()` method
- [ ] Write logs to Firestore `audit_logs` collection
- [ ] Include timestamp, formats, file size

**Files to Create:**
- `lib/features/data_export/data/services/export_audit_service.dart`

**Testing:**
- Trigger export request
- Verify log created in Firestore
- Verify log completion after export

---

### Task 8: Implement Export Use Case ✅
**Estimated Time**: 4 hours

- [ ] Create `ExportDataUsecase` class
- [ ] Orchestrate full export workflow
- [ ] Call data collection service
- [ ] Call export generators
- [ ] Call archive service
- [ ] Call audit service
- [ ] Emit progress updates via callback
- [ ] Handle errors and cleanup

**Files to Create:**
- `lib/features/data_export/domain/usecases/export_data_usecase.dart`

**Testing:**
- Test full export workflow
- Verify progress updates
- Test error handling
- Verify cleanup on failure

---

### Task 9: Create Riverpod Providers ✅
**Estimated Time**: 2 hours

- [ ] Create service providers
- [ ] Create state providers for selected formats
- [ ] Create state provider for export progress
- [ ] Create state provider for export result
- [ ] Create use case provider

**Files to Create:**
- `lib/features/data_export/presentation/providers/data_export_providers.dart`

**Testing:**
- Verify providers instantiate correctly
- Test state updates

---

### Task 10: Build Export Data Screen UI ✅
**Estimated Time**: 6 hours

- [ ] Create `ExportDataScreen`
- [ ] Add RGPD Article 20 legal notice
- [ ] Display data categories list
- [ ] Build format selector (JSON, CSV checkboxes)
- [ ] Add security warning card
- [ ] Add "Request Export" button
- [ ] Implement confirmation dialog
- [ ] Navigate to Settings → Privacy

**Files to Create:**
- `lib/features/data_export/presentation/screens/export_data_screen.dart`

**Testing:**
- Navigate to screen
- Select/deselect formats
- Verify button disabled when no format selected
- Tap "Request Export" → confirmation dialog

---

### Task 11: Build Export Progress Screen UI ✅
**Estimated Time**: 3 hours

- [ ] Create `ExportProgressScreen`
- [ ] Display circular progress indicator
- [ ] Show percentage
- [ ] Show current step text
- [ ] Show items processed count
- [ ] Update progress from provider

**Files to Create:**
- `lib/features/data_export/presentation/screens/export_progress_screen.dart`

**Testing:**
- Mock progress updates
- Verify UI updates correctly
- Verify percentage displays

---

### Task 12: Build Export Complete Screen UI ✅
**Estimated Time**: 5 hours

- [ ] Create `ExportCompleteScreen`
- [ ] Display success icon
- [ ] Show file details (name, size, format, created, expires)
- [ ] Add security warning
- [ ] Add "Download to Phone" button
- [ ] Add "Share File" button
- [ ] Add "Preview Data" button
- [ ] Implement download action
- [ ] Implement share action

**Files to Create:**
- `lib/features/data_export/presentation/screens/export_complete_screen.dart`

**Testing:**
- Navigate to complete screen
- Verify file details display
- Tap "Download" → file saves to Downloads
- Tap "Share" → share sheet appears

---

### Task 13: Implement Auto-Delete After 7 Days ✅
**Estimated Time**: 4 hours

- [ ] Create background task service
- [ ] Schedule file deletion 7 days after creation
- [ ] Use WorkManager (Android) or BackgroundTasks (iOS)
- [ ] Securely delete file (overwrite then delete)
- [ ] Optional: Notify user of deletion

**Files to Create:**
- `lib/core/services/file_cleanup_service.dart`

**Testing:**
- Create export
- Mock time advance 7 days
- Verify file deleted
- Verify file not accessible

---

### Task 14: Add Navigation from Settings ✅
**Estimated Time**: 1 hour

- [ ] Add "Export My Data" option to Settings → Privacy screen
- [ ] Navigate to `ExportDataScreen` on tap
- [ ] Add icon (download or file export icon)

**Files to Modify:**
- `lib/features/settings/presentation/screens/privacy_settings_screen.dart`

**Testing:**
- Navigate to Settings → Privacy
- Verify "Export My Data" option appears
- Tap → navigates to export screen

---

### Task 15: Write Unit Tests for DataCollectionService ✅
**Estimated Time**: 4 hours

- [ ] Test `collectAllUserData()` with mock data
- [ ] Test pagination for large inventory
- [ ] Test when health profile is missing
- [ ] Test when nutrition history is empty
- [ ] Mock Firestore and Hive

**Files to Create:**
- `test/features/data_export/data/services/data_collection_service_test.dart`

**Target Coverage**: 85%

---

### Task 16: Write Unit Tests for Export Generators ✅
**Estimated Time**: 3 hours

- [ ] Test JSON export structure
- [ ] Test CSV exports (all files)
- [ ] Test UTF-8 encoding
- [ ] Test null value handling

**Files to Create:**
- `test/features/data_export/data/services/json_export_generator_test.dart`
- `test/features/data_export/data/services/csv_export_generator_test.dart`

**Target Coverage**: 90%

---

### Task 17: Write Unit Tests for Archive Service ✅
**Estimated Time**: 3 hours

- [ ] Test ZIP creation
- [ ] Test README generation
- [ ] Test share functionality
- [ ] Test download functionality
- [ ] Mock file system

**Files to Create:**
- `test/features/data_export/data/services/export_archive_service_test.dart`

**Target Coverage**: 85%

---

### Task 18: Write Integration Tests ✅
**Estimated Time**: 4 hours

- [ ] Test full export workflow end-to-end
- [ ] Test with real Firestore emulator
- [ ] Test with large datasets (1000+ products)
- [ ] Test export completion
- [ ] Verify ZIP validity

**Files to Create:**
- `integration_test/data_export_test.dart`

**Target**: 5-8 test scenarios

---

### Task 19: Write Widget Tests for UI ✅
**Estimated Time**: 3 hours

- [ ] Test ExportDataScreen
- [ ] Test format selector
- [ ] Test ExportProgressScreen
- [ ] Test ExportCompleteScreen
- [ ] Mock providers

**Files to Create:**
- `test/features/data_export/presentation/screens/export_data_screen_test.dart`

**Target Coverage**: 80%

---

### Task 20: Manual Testing & QA ✅
**Estimated Time**: 4 hours

- [ ] Test on real device
- [ ] Export with 2000+ products
- [ ] Verify all data categories included
- [ ] Open exported JSON in text editor
- [ ] Open exported CSVs in Excel
- [ ] Test share to Google Drive
- [ ] Test download to Downloads
- [ ] Verify file expires after 7 days

**Testing Checklist**:
- ✅ All data categories included
- ✅ JSON is valid
- ✅ CSV opens in Excel
- ✅ French characters display correctly
- ✅ Share works
- ✅ Download works

---

**Total Estimated Time**: 70-80 hours (~2 weeks for 1 developer)

---

## TESTING STRATEGY

### Unit Tests (Target: 85% Coverage)

```dart
// test/features/data_export/data/services/json_export_generator_test.dart

void main() {
  late JsonExportGenerator generator;

  setUp(() {
    generator = JsonExportGenerator();
  });

  group('JSON Export Generation', () {
    test('should generate valid JSON', () {
      // Arrange
      final data = _createMockUserDataExport();

      // Act
      final json = generator.generateJsonExport(data);
      final decoded = jsonDecode(json);

      // Assert
      expect(decoded, isA<Map<String, dynamic>>());
      expect(decoded['export_metadata'], isNotNull);
      expect(decoded['user_profile'], isNotNull);
      expect(decoded['inventory'], isList);
    });

    test('should include all data categories', () {
      final data = _createMockUserDataExport();
      final json = generator.generateJsonExport(data);
      final decoded = jsonDecode(json);

      expect(decoded.containsKey('export_metadata'), true);
      expect(decoded.containsKey('user_profile'), true);
      expect(decoded.containsKey('health_profile'), true);
      expect(decoded.containsKey('inventory'), true);
      expect(decoded.containsKey('nutrition_history'), true);
      expect(decoded.containsKey('settings'), true);
      expect(decoded.containsKey('devices'), true);
    });

    test('should handle null health profile', () {
      final data = _createMockUserDataExport(healthProfile: null);
      final json = generator.generateJsonExport(data);
      final decoded = jsonDecode(json);

      expect(decoded.containsKey('health_profile'), false);
    });
  });
}

UserDataExport _createMockUserDataExport({HealthProfileData? healthProfile}) {
  return UserDataExport(
    exportMetadata: ExportMetadata(
      exportedAt: DateTime(2026, 2, 15),
      userId: 'test-user',
    ),
    userProfile: UserProfileData(
      userId: 'test-user',
      email: 'test@example.com',
      createdAt: DateTime(2025, 1, 1),
    ),
    healthProfile: healthProfile,
    inventory: [
      ProductData(
        productId: 'prod1',
        name: 'Test Product',
        category: 'Dairy',
        expirationDate: DateTime(2026, 3, 1),
        storageLocation: 'fridge',
        status: 'fresh',
        addedAt: DateTime(2026, 2, 10),
      ),
    ],
    nutritionHistory: [],
    weightHistory: [],
    settings: SettingsData(
      theme: 'light',
      locale: 'fr',
      notificationsEnabled: true,
      dlcAlertDelayDays: 2,
      ddmAlertDelayDays: 5,
      analyticsEnabled: false,
    ),
    devices: [],
  );
}
```

### Integration Tests

```dart
// integration_test/data_export_test.dart

void main() {
  testWidgets('Full export workflow', (tester) async {
    await tester.pumpWidget(MyApp());

    // Login
    await loginAsTestUser();

    // Navigate to Settings → Privacy → Export Data
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export My Data'));
    await tester.pumpAndSettle();

    // Select formats
    expect(find.text('Export Format'), findsOneWidget);
    await tester.tap(find.text('JSON (Machine-Readable)'));
    await tester.pumpAndSettle();

    // Request export
    await tester.tap(find.text('Request Export'));
    await tester.pumpAndSettle();

    // Confirm
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    // Wait for export to complete (max 5 minutes)
    await tester.pumpAndSettle(Duration(minutes: 5));

    // Verify completion screen
    expect(find.text('Export Completed Successfully'), findsOneWidget);

    // Verify file exists
    final result = /* get export result from provider */;
    final file = File(result.filePath);
    expect(await file.exists(), true);

    // Verify ZIP is valid
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    expect(archive.files, isNotEmpty);
  });
}
```

### Manual Testing Checklist

- [ ] Export with 0 products (empty inventory)
- [ ] Export with 5,000+ products (large dataset)
- [ ] Export with 1,000+ nutrition entries
- [ ] Export with no health profile
- [ ] Export with full health profile + allergies
- [ ] Open JSON in VS Code → verify valid
- [ ] Open CSVs in Excel → verify columns
- [ ] Test French characters: é, à, ç, ê
- [ ] Share to Gmail → verify attachment
- [ ] Share to Google Drive → verify upload
- [ ] Download to Downloads → verify file appears
- [ ] Wait 7 days → verify auto-delete
- [ ] Cancel export mid-progress → verify cleanup

---

## ANTI-PATTERNS TO AVOID

### ❌ Anti-Pattern 1: Including Derived/Inferred Data

**Problem**: RGPD Article 20 only covers user-provided data, not algorithmic outputs.

**Solution**: Exclude AI-generated meal plans, recipe recommendations, predicted expiration dates, waste scores.

---

### ❌ Anti-Pattern 2: Blocking UI During Export

**Problem**: Large exports (10,000+ items) freeze the UI.

**Solution**: Use background isolate or async processing with progress updates.

---

### ❌ Anti-Pattern 3: Not Paginating Firestore Queries

**Problem**: Fetching 10,000+ documents in one query causes timeout.

**Solution**: Paginate with `limit()` and `startAfterDocument()`.

---

### ❌ Anti-Pattern 4: Storing Exports Indefinitely

**Problem**: RGPD requires data minimization - don't retain exports longer than necessary.

**Solution**: Auto-delete after 7 days.

---

### ❌ Anti-Pattern 5: Not Validating JSON/CSV Output

**Problem**: Corrupted exports frustrate users and violate RGPD.

**Solution**: Validate JSON with `jsonDecode()`, test CSVs in Excel.

---

### ❌ Anti-Pattern 6: Omitting Security Warnings

**Problem**: Users may accidentally share sensitive data.

**Solution**: Prominent security warnings on export screens.

---

## INTEGRATION POINTS

### 1. Authentication Module
- User must be logged in to export data
- User ID from Firebase Auth

### 2. Inventory Module (Epic 2)
- Export all products from Firestore `inventory` collection

### 3. Health Profile Module (Epic 1)
- Export encrypted health data from Hive

### 4. Settings Module
- Add "Export My Data" option to Privacy settings
- Export app preferences

### 5. Multi-Device Sync (Story 1.8)
- Export device registration data

### 6. Nutrition Tracking (Epic 7)
- Export nutrition history from Hive

---

## DEV NOTES

### 1. Firestore Indexes Required

```json
{
  "indexes": [
    {
      "collectionGroup": "inventory",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "addedAt", "order": "DESCENDING"}
      ]
    }
  ]
}
```

### 2. Export File Size Estimation

- Average product: ~500 bytes JSON
- 1,000 products: ~500 KB
- 10,000 products: ~5 MB
- With images (URLs only): add 100 bytes per image
- ZIP compression: ~30-40% reduction

### 3. RGPD Compliance Notes

- Article 20 applies when processing is based on consent or contract
- Must respond within 30 days (our target: instant)
- Must provide free of charge
- Excludes inferred/derived data (AI predictions, calculations)
- User can request direct transmission to another controller

### 4. Testing with Firebase Emulator

```bash
firebase emulators:start --only firestore,auth
```

Connect app:

```dart
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

---

## DEFINITION OF DONE

### Code Complete ✅

- [ ] All 20 implementation tasks completed
- [ ] Code passes `flutter analyze` with no errors
- [ ] Code formatted with `flutter format .`
- [ ] All TODO comments resolved
- [ ] Freezed code generation complete

### Testing Complete ✅

- [ ] Unit tests written (85% coverage)
- [ ] Integration tests written (5-8 scenarios)
- [ ] Widget tests written (80% coverage)
- [ ] Manual testing on real device
- [ ] Export validated with Excel (CSVs)
- [ ] Export validated with JSON viewer
- [ ] All 20 acceptance criteria verified

### Documentation Complete ✅

- [ ] Developer documentation written
- [ ] README.txt generated in export
- [ ] Code comments added
- [ ] API documentation complete

### Legal Compliance ✅

- [ ] RGPD Article 20 requirements met
- [ ] Export includes all user-provided data
- [ ] Export excludes derived/inferred data
- [ ] Audit logs implemented
- [ ] Auto-delete after 7 days
- [ ] Security warnings displayed

### Performance Verified ✅

- [ ] Export completes < 5 minutes for 10,000+ items
- [ ] No UI blocking during export
- [ ] Progress updates smooth
- [ ] ZIP file size reasonable

### User Acceptance ✅

- [ ] Product Owner approval
- [ ] Beta testers feedback positive
- [ ] No critical bugs reported
- [ ] UX flows intuitive

---

## REFERENCES

### Legal Documentation

1. **RGPD Article 20 - Right to Data Portability**
   - https://gdpr-info.eu/art-20-gdpr/
   - https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/individual-rights/right-to-data-portability/

2. **CNIL (France) Guidance on Data Portability**
   - https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre3#Article20

### Technical Documentation

3. **Flutter Packages**
   - csv package: https://pub.dev/packages/csv
   - archive package: https://pub.dev/packages/archive
   - share_plus package: https://pub.dev/packages/share_plus
   - path_provider package: https://pub.dev/packages/path_provider

4. **Firestore Documentation**
   - Query pagination: https://firebase.google.com/docs/firestore/query-data/query-cursors
   - Export/Import: https://firebase.google.com/docs/firestore/manage-data/export-import

### Related Stories

- **Story 1.6**: Configure Personal Profile (health data to export)
- **Story 1.7**: Set Dietary Preferences and Allergies (allergen data to export)
- **Story 1.8**: Multi-Device Sync (device data to export)
- **Story 1.10**: Delete Account (related privacy feature)

### Dependencies

```yaml
dependencies:
  csv: ^6.0.0
  archive: ^4.0.0
  share_plus: ^9.0.0
  path_provider: ^2.1.0
```

---

## STORY CARD SUMMARY

**Story 1.9: Export Personal Data (RGPD Portability)**

**Epic**: User Authentication & Profile Management
**Points**: 5
**Priority**: High (Legal Compliance)

**Summary**: Implement RGPD Article 20 compliant data export feature allowing users to download all their personal data in JSON and CSV formats. Export includes user profile, health data, inventory, nutrition history, settings, and devices. File auto-deletes after 7 days. Audit logs track all export requests.

**Key Features**:
- Export in JSON (machine-readable) and CSV (spreadsheet) formats
- ZIP archive with all export files
- Comprehensive data collection from Firestore + Hive
- Progress indicator during export
- Download to phone or share via email/cloud
- Security warnings and auto-delete after 7 days
- Audit logging for compliance

**Success Metrics**:
- Export completes < 5 minutes for 10,000+ items
- 100% data inclusion (all categories)
- Zero user complaints about missing data
- Legal compliance verified

**Risks**:
- Large exports may timeout
- File size may be too large for email
- User may share export insecurely

**Estimated Development Time**: 2 weeks (1 developer)

---

**End of Story 1.9**
