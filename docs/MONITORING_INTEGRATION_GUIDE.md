# Monitoring Integration Guide
**Story 0.7: Crash Reporting and Performance Monitoring**

This guide shows how to integrate Firebase Crashlytics, Performance Monitoring, and Analytics throughout the FrigoFute application.

## Table of Contents

1. [Services Overview](#services-overview)
2. [Error Handling Patterns](#error-handling-patterns)
3. [Performance Tracking](#performance-tracking)
4. [Analytics Events](#analytics-events)
5. [Repository Layer Integration](#repository-layer-integration)
6. [Use Case Layer Integration](#use-case-layer-integration)
7. [Presentation Layer Integration](#presentation-layer-integration)
8. [Testing Monitoring Services](#testing-monitoring-services)

---

## Services Overview

### Available Services

```dart
// lib/core/monitoring/

crashlyticsServiceProvider    // Error reporting
performanceMonitoringProvider  // Performance traces
analyticsServiceProvider       // Business events
errorLoggerProvider            // Unified error logging
```

### Service Responsibilities

| Service | Purpose | When to Use |
|---------|---------|-------------|
| **CrashlyticsService** | Report crashes and errors | When catching exceptions |
| **PerformanceMonitoringService** | Track operation duration | API calls, sync, OCR scans |
| **AnalyticsService** | Track business events | User actions, conversions |
| **ErrorLoggerService** | Unified error handling | Primary error logging interface |

---

## Error Handling Patterns

### 1. Basic Error Logging

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frigofute_v2/core/monitoring/error_logger_service.dart';

class SomeNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  SomeNotifier(this._errorLogger) : super(const AsyncValue.loading());

  final ErrorLoggerService _errorLogger;

  Future<void> loadProducts() async {
    try {
      final products = await _productRepository.getProducts();
      state = AsyncValue.data(products);
    } catch (e, st) {
      // Log error with context
      await _errorLogger.logError(
        e,
        st,
        context: {'operation': 'load_products'},
        fatal: false,
      );

      state = AsyncValue.error(e, st);
    }
  }
}
```

### 2. Categorized Error Logging

Use specialized loggers for better categorization:

```dart
// Network errors
try {
  final response = await http.get(uri);
} catch (e, st) {
  await errorLogger.logNetworkError(
    e, st,
    endpoint: '/api/products',
    statusCode: 500,
    method: 'GET',
  );
}

// Storage errors
try {
  await hiveBox.put(key, value);
} catch (e, st) {
  await errorLogger.logStorageError(
    e, st,
    operation: 'put',
    storageType: 'hive',
  );
}

// OCR errors
try {
  final result = await ocrEngine.scan(image);
} catch (e, st) {
  await errorLogger.logOCRError(
    e, st,
    engine: 'google_vision',
    imageSizeKb: 250,
  );
}
```

### 3. Using AppException Hierarchy

```dart
import 'package:frigofute_v2/core/shared/exceptions/app_exception.dart';

class ProductRepository {
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      return _parseProducts(response.data);
    } on DioException catch (e, st) {
      // Convert DioException to AppException
      if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(
          'Connection timeout while fetching products',
          'NETWORK_TIMEOUT',
          e,
        );
      } else if (e.response?.statusCode == 429) {
        throw QuotaExceededException(
          'API quota exceeded - please try again later',
        );
      } else if (e.response != null) {
        throw APIException(
          'Failed to fetch products',
          'API_ERROR',
          e.response!.statusCode,
          e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching products',
          'NETWORK_ERROR',
          e,
        );
      }
    }
  }
}
```

### 4. Either Pattern (Recommended for Repositories)

```dart
import 'package:dartz/dartz.dart';
import 'package:frigofute_v2/core/shared/exceptions/app_exception.dart';

class ProductRepository {
  final ErrorLoggerService _errorLogger;

  Future<Either<AppException, List<Product>>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      final products = _parseProducts(response.data);
      return Right(products);
    } on AppException catch (e, st) {
      // Already an AppException - log and return
      await _errorLogger.logError(e, st, context: {'repo': 'product'});
      return Left(e);
    } catch (e, st) {
      // Unknown error - wrap and log
      final exception = NetworkException('Unexpected error', 'UNKNOWN', e);
      await _errorLogger.logError(exception, st, context: {'repo': 'product'});
      return Left(exception);
    }
  }
}

// Usage in use case:
class GetProductsUseCase {
  Future<Either<AppException, List<Product>>> execute() async {
    final result = await _repository.getProducts();

    return result.fold(
      (error) => Left(error), // Propagate error
      (products) => Right(products), // Success
    );
  }
}

// Usage in notifier:
class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  Future<void> loadProducts() async {
    state = const AsyncValue.loading();

    final result = await _getProductsUseCase.execute();

    result.fold(
      (error) {
        // Error already logged in repository
        state = AsyncValue.error(error, StackTrace.current);
      },
      (products) {
        state = AsyncValue.data(products);
      },
    );
  }
}
```

---

## Performance Tracking

### 1. Trace API Calls

```dart
class ProductRepository {
  final PerformanceMonitoringService _performance;

  Future<List<Product>> getProducts() async {
    return await _performance.traceAPICall(
      'api_get_products',
      () async {
        final response = await _dio.get('/products');
        return _parseProducts(response.data);
      },
      attributes: {
        'endpoint': '/products',
        'method': 'GET',
      },
    );
  }
}
```

### 2. Trace OCR Operations

```dart
class OCRService {
  final PerformanceMonitoringService _performance;

  Future<OCRResult> scanReceipt(File image) async {
    final imageSizeKb = await image.length() ~/ 1024;

    return await _performance.traceOCRScan(
      engine: 'google_vision',
      imageSizeKb: imageSizeKb,
      operation: () async {
        return await _googleVisionAPI.processImage(image);
      },
    );
  }
}
```

### 3. Trace Data Sync

```dart
class SyncService {
  final PerformanceMonitoringService _performance;

  Future<void> syncToCloud() async {
    final localChanges = await _getLocalChanges();

    await _performance.traceSyncOperation(
      phase: 'upload_local',
      itemCount: localChanges.length,
      operation: () async {
        await _uploadChanges(localChanges);
      },
    );
  }
}
```

### 4. Custom Traces

```dart
class ImageProcessingService {
  final PerformanceMonitoringService _performance;

  Future<File> compressImage(File image) async {
    return await _performance.traceOperation(
      'image_compression',
      () async {
        final compressed = await _compressor.compress(image);
        return compressed;
      },
      metrics: {
        'original_size_kb': await image.length() ~/ 1024,
        'compressed_size_kb': await compressed.length() ~/ 1024,
      },
      attributes: {
        'compression_quality': '85',
      },
    );
  }
}
```

---

## Analytics Events

### 1. Business Events (Story 0.7 - 7 Key Events)

```dart
// Event 1: Product Added
await analytics.logProductAdded(
  method: 'barcode', // 'manual', 'barcode', 'ocr'
  category: 'dairy',
  storageLocation: 'fridge',
);

// Event 2: OCR Scan
await analytics.logOCRScan(
  engine: 'google_vision',
  success: true,
  confidence: 95,
  itemsDetected: 12,
);

// Event 3: Recipe Viewed
await analytics.logRecipeViewed(
  recipeId: 'recipe_123',
  source: 'expiring_soon', // 'search', 'expiring_soon', 'favorites'
  dietaryTags: ['vegetarian', 'gluten_free'],
);

// Event 4: Meal Plan Generated
await analytics.logMealPlanGenerated(
  profileType: 'muscle_gain',
  durationDays: 7,
  recipesGenerated: 21,
);

// Event 5: Premium Feature Accessed
await analytics.logPremiumFeatureAccessed(
  featureName: 'nutrition_tracking',
  hasAccess: false, // Conversion funnel tracking
);

// Event 6: Food Waste Prevented
await analytics.logFoodWastePrevented(
  category: 'vegetables',
  estimatedValueEur: 3.50,
  estimatedWeightKg: 0.5,
);

// Event 7: Sync Completed
await analytics.logSyncCompleted(
  phase: 'upload',
  success: true,
  itemsSynced: 15,
  durationMs: 1250,
);
```

### 2. Predefined Firebase Events

```dart
// User lifecycle
await analytics.logSignUp(method: 'google');
await analytics.logLogin(method: 'email');
await analytics.logAppOpen();

// Onboarding
await analytics.logTutorialBegin();
await analytics.logTutorialComplete();

// Engagement
await analytics.logSearch(searchTerm: 'pasta recipes');
await analytics.logShare(
  contentType: 'recipe',
  itemId: 'recipe_123',
  method: 'whatsapp',
);
```

### 3. User Properties (for Segmentation)

```dart
// Set once during profile setup
await analytics.setUserProperty(
  name: 'user_tier',
  value: 'premium',
);

await analytics.setUserProperty(
  name: 'dietary_preference',
  value: 'vegetarian',
);

await analytics.setUserProperty(
  name: 'nutrition_tracking_enabled',
  value: 'true',
);

// Clear on logout
await analytics.clearUserId();
```

---

## Repository Layer Integration

**Full example with all monitoring integrated:**

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    dio: ref.watch(dioProvider),
    errorLogger: ref.watch(errorLoggerProvider),
    performance: ref.watch(performanceMonitoringProvider),
  );
});

class ProductRepository {
  final Dio _dio;
  final ErrorLoggerService _errorLogger;
  final PerformanceMonitoringService _performance;

  ProductRepository({
    required Dio dio,
    required ErrorLoggerService errorLogger,
    required PerformanceMonitoringService performance,
  })  : _dio = dio,
        _errorLogger = errorLogger,
        _performance = performance;

  Future<Either<AppException, List<Product>>> getProducts() async {
    return await _performance.traceAPICall(
      'api_get_products',
      () async {
        try {
          final response = await _dio.get('/products');
          final products = _parseProducts(response.data);
          return Right(products);
        } on DioException catch (e, st) {
          final exception = _handleDioException(e);
          await _errorLogger.logNetworkError(
            exception,
            st,
            endpoint: '/products',
            statusCode: e.response?.statusCode,
            method: 'GET',
          );
          return Left(exception);
        } catch (e, st) {
          final exception = NetworkException('Unexpected error', 'UNKNOWN', e);
          await _errorLogger.logError(exception, st);
          return Left(exception);
        }
      },
      attributes: {'endpoint': '/products', 'method': 'GET'},
    );
  }

  AppException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return NetworkException('Connection timeout', 'NETWORK_TIMEOUT', e);
    } else if (e.response?.statusCode == 429) {
      return QuotaExceededException('API quota exceeded');
    } else if (e.response != null) {
      return APIException(
        'API error',
        'API_ERROR',
        e.response!.statusCode,
        e,
      );
    } else {
      return NetworkException('Network error', 'NETWORK_ERROR', e);
    }
  }

  List<Product> _parseProducts(dynamic data) {
    // ... parsing logic
  }
}
```

---

## Use Case Layer Integration

```dart
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(
    repository: ref.watch(productRepositoryProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});

class GetProductsUseCase {
  final ProductRepository _repository;
  final AnalyticsService _analytics;

  GetProductsUseCase({
    required ProductRepository repository,
    required AnalyticsService analytics,
  })  : _repository = repository,
        _analytics = analytics;

  Future<Either<AppException, List<Product>>> execute() async {
    final result = await _repository.getProducts();

    // Log analytics on success
    result.fold(
      (error) {
        // Error already logged in repository
      },
      (products) {
        // Success - could log custom event
        // (optional, depends on business requirements)
      },
    );

    return result;
  }
}
```

---

## Presentation Layer Integration

### 1. Provider Setup with Error Logging

```dart
final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductNotifier(
    getProductsUseCase: ref.watch(getProductsUseCaseProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductNotifier({
    required GetProductsUseCase getProductsUseCase,
    required AnalyticsService analytics,
  })  : _getProductsUseCase = getProductsUseCase,
        _analytics = analytics,
        super(const AsyncValue.loading());

  final GetProductsUseCase _getProductsUseCase;
  final AnalyticsService _analytics;

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();

    final result = await _getProductsUseCase.execute();

    result.fold(
      (error) {
        // Error already logged - just update state
        state = AsyncValue.error(error, StackTrace.current);
      },
      (products) {
        state = AsyncValue.data(products);
      },
    );
  }

  Future<void> addProduct(Product product, String method) async {
    // Optimistic update
    final previousState = state;
    state.whenData((products) {
      state = AsyncValue.data([...products, product]);
    });

    final result = await _addProductUseCase.execute(product);

    await result.fold(
      (error) async {
        // Rollback on error
        state = previousState;
      },
      (addedProduct) async {
        // Log analytics event
        await _analytics.logProductAdded(
          method: method,
          category: addedProduct.category,
          storageLocation: addedProduct.storageLocation,
        );
      },
    );
  }
}
```

### 2. UI Error Handling

```dart
class ProductListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productNotifierProvider);

    return Scaffold(
      body: productsAsync.when(
        data: (products) => ProductList(products: products),
        loading: () => const CircularProgressIndicator(),
        error: (error, st) {
          // Display user-friendly error message
          final message = _getErrorMessage(error);
          return ErrorView(
            message: message,
            onRetry: () => ref.refresh(productNotifierProvider),
          );
        },
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is NetworkException) {
      return 'Problème de connexion. Vérifiez votre connexion internet.';
    } else if (error is QuotaExceededException) {
      return 'Limite atteinte. Veuillez réessayer plus tard.';
    } else if (error is APIException) {
      return 'Erreur serveur. Veuillez réessayer.';
    } else {
      return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}
```

### 3. Breadcrumb Logging for Context

```dart
class OCRScanScreen extends ConsumerWidget {
  Future<void> _scanReceipt(WidgetRef ref) async {
    final errorLogger = ref.read(errorLoggerProvider);

    // Log breadcrumbs for debugging
    await errorLogger.logInfo('User opened OCR scanner');

    final image = await _pickImage();
    await errorLogger.logInfo('Image selected: ${image.path}');

    await errorLogger.logInfo('Starting image compression');
    final compressed = await _compressImage(image);

    await errorLogger.logInfo('Sending to OCR engine');
    final result = await _scanWithOCR(compressed);

    await errorLogger.logInfo('OCR scan completed successfully');
  }
}
```

---

## Testing Monitoring Services

### 1. Unit Test with Mocked Services

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockErrorLogger extends Mock implements ErrorLoggerService {}
class MockPerformance extends Mock implements PerformanceMonitoringService {}
class MockAnalytics extends Mock implements AnalyticsService {}

void main() {
  group('ProductRepository', () {
    late MockErrorLogger mockErrorLogger;
    late MockPerformance mockPerformance;
    late ProductRepository repository;

    setUp(() {
      mockErrorLogger = MockErrorLogger();
      mockPerformance = MockPerformance();
      repository = ProductRepository(
        dio: mockDio,
        errorLogger: mockErrorLogger,
        performance: mockPerformance,
      );

      // Setup traceAPICall to execute the operation
      when(() => mockPerformance.traceAPICall<Either<AppException, List<Product>>>(
        any(),
        any(),
        attributes: any(named: 'attributes'),
      )).thenAnswer((invocation) async {
        final operation = invocation.positionalArguments[1]
            as Future<Either<AppException, List<Product>>> Function();
        return await operation();
      });
    });

    test('logs error when API call fails', () async {
      // Arrange
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/products'),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act
      final result = await repository.getProducts();

      // Assert
      expect(result.isLeft(), true);
      verify(() => mockErrorLogger.logNetworkError(
        any(),
        any(),
        endpoint: '/products',
        statusCode: null,
        method: 'GET',
      )).called(1);
    });
  });
}
```

### 2. Integration Test with Real Services

```dart
void main() {
  testWidgets('Integration test with monitoring', (tester) async {
    await Firebase.initializeApp();

    final container = ProviderContainer(
      overrides: [
        // Use real services in integration tests
        // They will log to Firebase (use test project)
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProductListScreen()),
      ),
    );

    // Trigger action that should log analytics
    await tester.tap(find.byType(AddProductButton));
    await tester.pumpAndSettle();

    // Analytics event should be logged to Firebase
    // (verify in Firebase Console)
  });
}
```

---

## Summary

### Key Principles

1. **Use ErrorLoggerService** as the primary error logging interface
2. **Log errors at the repository layer** - don't re-log in use cases/notifiers
3. **Use AppException hierarchy** for type-safe error handling
4. **Trace critical operations** (API calls, OCR, sync) with PerformanceMonitoringService
5. **Log business events** at the point of user action (usually notifier layer)
6. **Add breadcrumbs** before critical operations for debugging context
7. **Test with mocked services** to avoid polluting production data

### Checklist for New Features

- [ ] Define custom AppException types if needed
- [ ] Add error logging in repository layer
- [ ] Add performance traces for slow operations (>500ms)
- [ ] Add analytics events for user actions
- [ ] Add breadcrumbs before critical operations
- [ ] Test with mocked monitoring services
- [ ] Verify events in Firebase Console (staging environment)

---

**Next Steps:**
- Review [Firebase Crashlytics Console](https://console.firebase.google.com/project/_/crashlytics)
- Review [Firebase Performance Console](https://console.firebase.google.com/project/_/performance)
- Review [Firebase Analytics Console](https://console.firebase.google.com/project/_/analytics)
- Configure alert rules in Crashlytics
- Create custom dashboards in Analytics
