import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/shared/exceptions/app_exception.dart';

void main() {
  group('AppException Tests', () {
    group('NetworkException', () {
      test('should create with message and default code', () {
        const exception = NetworkException('Connection failed');

        expect(exception.message, 'Connection failed');
        expect(exception.code, 'NETWORK_ERROR');
        expect(exception.originalError, isNull);
      });

      test('should create with custom code', () {
        const exception = NetworkException('Timeout', 'TIMEOUT');

        expect(exception.message, 'Timeout');
        expect(exception.code, 'TIMEOUT');
      });

      test('should create with original error', () {
        final original = Exception('Original');
        final exception = NetworkException('Failed', 'NET_ERR', original);

        expect(exception.originalError, original);
      });

      test('should have correct toString', () {
        const exception = NetworkException('Connection lost', 'NET_ERR');

        expect(
          exception.toString(),
          'NetworkException: Connection lost (code: NET_ERR)',
        );
      });
    });

    group('APIException', () {
      test('should create with status code', () {
        const exception = APIException('Not found', 'NOT_FOUND', 404);

        expect(exception.message, 'Not found');
        expect(exception.code, 'NOT_FOUND');
        expect(exception.statusCode, 404);
      });

      test('should create without status code', () {
        const exception = APIException('Error');

        expect(exception.statusCode, isNull);
        expect(exception.code, 'API_ERROR');
      });

      test('should have correct toString with status', () {
        const exception = APIException('Server error', 'ERR_500', 500);

        expect(
          exception.toString(),
          'APIException: Server error (code: ERR_500, status: 500)',
        );
      });

      test('should have correct toString without status', () {
        const exception = APIException('Generic error', 'ERR');

        expect(
          exception.toString(),
          'APIException: Generic error (code: ERR, status: null)',
        );
      });
    });

    group('QuotaExceededException', () {
      test('should have fixed code and status', () {
        const exception = QuotaExceededException('Quota exceeded');

        expect(exception.message, 'Quota exceeded');
        expect(exception.code, 'QUOTA_EXCEEDED');
        expect(exception.statusCode, 429);
      });

      test('should have correct toString', () {
        const exception = QuotaExceededException('Too many requests');

        expect(
          exception.toString(),
          'QuotaExceededException: Too many requests',
        );
      });
    });

    group('ValidationException', () {
      test('should create without field errors', () {
        const exception = ValidationException('Invalid input');

        expect(exception.message, 'Invalid input');
        expect(exception.code, 'VALIDATION_FAILED');
        expect(exception.fieldErrors, isNull);
      });

      test('should create with field errors', () {
        final fieldErrors = {
          'email': 'Invalid email format',
          'password': 'Too short',
        };

        final exception = ValidationException('Form invalid', fieldErrors);

        expect(exception.fieldErrors, fieldErrors);
      });

      test('should have correct toString without fields', () {
        const exception = ValidationException('Invalid');

        expect(exception.toString(), 'ValidationException: Invalid');
      });

      test('should have correct toString with fields', () {
        const exception = ValidationException('Validation failed', {
          'name': 'Required',
          'age': 'Invalid',
        });

        expect(
          exception.toString(),
          'ValidationException: Validation failed (fields: name, age)',
        );
      });

      test('should handle empty field errors', () {
        const exception = ValidationException('Invalid', {});

        expect(exception.toString(), 'ValidationException: Invalid');
      });
    });

    group('StorageException', () {
      test('should create with default code', () {
        const exception = StorageException('Disk full');

        expect(exception.message, 'Disk full');
        expect(exception.code, 'STORAGE_ERROR');
      });

      test('should create with custom code', () {
        const exception = StorageException('Write failed', 'WRITE_ERR');

        expect(exception.code, 'WRITE_ERR');
      });

      test('should have correct toString', () {
        const exception = StorageException('Read failed', 'READ_ERR');

        expect(
          exception.toString(),
          'StorageException: Read failed (code: READ_ERR)',
        );
      });
    });

    group('AuthException', () {
      test('should create with default code', () {
        const exception = AuthException('Login failed');

        expect(exception.message, 'Login failed');
        expect(exception.code, 'AUTH_ERROR');
      });

      test('should create with custom code', () {
        const exception = AuthException('Token expired', 'TOKEN_EXPIRED');

        expect(exception.code, 'TOKEN_EXPIRED');
      });

      test('should have correct toString', () {
        const exception = AuthException('Unauthorized', 'UNAUTH');

        expect(
          exception.toString(),
          'AuthException: Unauthorized (code: UNAUTH)',
        );
      });
    });

    group('FeatureUnavailableException', () {
      test('should create with requiresPremium false by default', () {
        const exception = FeatureUnavailableException('Feature locked');

        expect(exception.message, 'Feature locked');
        expect(exception.code, 'FEATURE_UNAVAILABLE');
        expect(exception.requiresPremium, false);
      });

      test('should create with requiresPremium true', () {
        const exception = FeatureUnavailableException(
          'Premium only',
          requiresPremium: true,
        );

        expect(exception.requiresPremium, true);
      });

      test('should have correct toString', () {
        const exception = FeatureUnavailableException(
          'Premium feature',
          requiresPremium: true,
        );

        expect(
          exception.toString(),
          'FeatureUnavailableException: Premium feature (premium: true)',
        );
      });
    });

    group('OCRException', () {
      test('should create with engine', () {
        const exception = OCRException(
          'Scan failed',
          apiEngine: 'google_vision',
        );

        expect(exception.message, 'Scan failed');
        expect(exception.code, 'OCR_ERROR');
        expect(exception.apiEngine, 'google_vision');
      });

      test('should create without engine', () {
        const exception = OCRException('OCR error');

        expect(exception.apiEngine, isNull);
      });

      test('should create with status code', () {
        const exception = OCRException(
          'API error',
          apiEngine: 'ml_kit',
          statusCode: 500,
        );

        expect(exception.statusCode, 500);
      });

      test('should have correct toString', () {
        const exception = OCRException(
          'Recognition failed',
          apiEngine: 'google_vision',
        );

        expect(
          exception.toString(),
          'OCRException: Recognition failed (engine: google_vision, code: OCR_ERROR)',
        );
      });

      test('should inherit from APIException', () {
        const exception = OCRException('Error');

        expect(exception, isA<APIException>());
        expect(exception, isA<AppException>());
      });
    });

    group('SyncException', () {
      test('should create with phase', () {
        const exception = SyncException('Sync failed', SyncPhase.uploadLocal);

        expect(exception.message, 'Sync failed');
        expect(exception.code, 'SYNC_ERROR');
        expect(exception.phase, SyncPhase.uploadLocal);
      });

      test('should create without phase', () {
        const exception = SyncException('Sync error');

        expect(exception.phase, isNull);
      });

      test('should have correct toString', () {
        const exception = SyncException('Upload failed', SyncPhase.uploadLocal);

        expect(
          exception.toString(),
          'SyncException: Upload failed (phase: SyncPhase.uploadLocal)',
        );
      });

      test('should support all sync phases', () {
        expect(SyncPhase.values.length, 4);
        expect(SyncPhase.values, contains(SyncPhase.uploadLocal));
        expect(SyncPhase.values, contains(SyncPhase.downloadRemote));
        expect(SyncPhase.values, contains(SyncPhase.conflictResolution));
        expect(SyncPhase.values, contains(SyncPhase.syncLocal));
      });
    });

    group('Exception hierarchy', () {
      test('all exceptions should extend AppException', () {
        expect(const NetworkException(''), isA<AppException>());
        expect(const APIException(''), isA<AppException>());
        expect(const ValidationException(''), isA<AppException>());
        expect(const StorageException(''), isA<AppException>());
        expect(const AuthException(''), isA<AppException>());
        expect(const FeatureUnavailableException(''), isA<AppException>());
        expect(const OCRException(''), isA<AppException>());
        expect(const SyncException(''), isA<AppException>());
      });

      test('QuotaExceededException should extend APIException', () {
        const exception = QuotaExceededException('');

        expect(exception, isA<APIException>());
        expect(exception, isA<AppException>());
      });

      test('OCRException should extend APIException', () {
        const exception = OCRException('');

        expect(exception, isA<APIException>());
        expect(exception, isA<AppException>());
      });
    });
  });
}
