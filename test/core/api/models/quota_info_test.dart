import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/api/models/quota_info.dart';

void main() {
  group('QuotaInfo', () {
    group('Constructor', () {
      test('should create QuotaInfo with all fields', () {
        final now = DateTime.now();
        final quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 500,
          lastRequest: now,
          lastDailyReset: now,
          lastMonthlyReset: now,
          isPremium: true,
          dailyLimit: 100,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.apiName, equals('gemini'));
        expect(quotaInfo.todayCount, equals(50));
        expect(quotaInfo.monthlyCount, equals(500));
        expect(quotaInfo.lastRequest, equals(now));
        expect(quotaInfo.lastDailyReset, equals(now));
        expect(quotaInfo.lastMonthlyReset, equals(now));
        expect(quotaInfo.isPremium, isTrue);
        expect(quotaInfo.dailyLimit, equals(100));
        expect(quotaInfo.monthlyLimit, equals(1000));
      });

      test('should create QuotaInfo with minimal fields', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 0,
          monthlyCount: 0,
        );

        expect(quotaInfo.apiName, equals('gemini'));
        expect(quotaInfo.todayCount, equals(0));
        expect(quotaInfo.monthlyCount, equals(0));
        expect(quotaInfo.lastRequest, isNull);
        expect(quotaInfo.lastDailyReset, isNull);
        expect(quotaInfo.lastMonthlyReset, isNull);
        expect(quotaInfo.isPremium, isFalse);
        expect(quotaInfo.dailyLimit, isNull);
        expect(quotaInfo.monthlyLimit, isNull);
      });
    });

    group('getRemainingDailyQuota()', () {
      test('should return remaining quota for free user', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 30,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.getRemainingDailyQuota(), equals(70));
      });

      test('should return 0 when quota exhausted', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 100,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.getRemainingDailyQuota(), equals(0));
      });

      test('should return 0 when quota exceeded', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 150,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.getRemainingDailyQuota(), equals(0));
      });

      test('should return null for premium user', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 500,
          monthlyCount: 0,
          isPremium: true,
          dailyLimit: 100,
        );

        expect(quotaInfo.getRemainingDailyQuota(), isNull);
      });

      test('should return null when no daily limit set', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 0,
        );

        expect(quotaInfo.getRemainingDailyQuota(), isNull);
      });
    });

    group('getRemainingMonthlyQuota()', () {
      test('should return remaining monthly quota for free user', () {
        const quotaInfo = QuotaInfo(
          apiName: 'google_vision',
          todayCount: 0,
          monthlyCount: 300,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.getRemainingMonthlyQuota(), equals(700));
      });

      test('should return 0 when monthly quota exhausted', () {
        const quotaInfo = QuotaInfo(
          apiName: 'google_vision',
          todayCount: 0,
          monthlyCount: 1000,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.getRemainingMonthlyQuota(), equals(0));
      });

      test('should return null for premium user', () {
        const quotaInfo = QuotaInfo(
          apiName: 'google_vision',
          todayCount: 0,
          monthlyCount: 1500,
          isPremium: true,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.getRemainingMonthlyQuota(), isNull);
      });

      test('should return null when no monthly limit set', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 0,
          monthlyCount: 500,
        );

        expect(quotaInfo.getRemainingMonthlyQuota(), isNull);
      });
    });

    group('isDailyQuotaExhausted()', () {
      test('should return true when daily quota exhausted', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 100,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.isDailyQuotaExhausted(), isTrue);
      });

      test('should return true when daily quota exceeded', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 150,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.isDailyQuotaExhausted(), isTrue);
      });

      test('should return false when quota available', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.isDailyQuotaExhausted(), isFalse);
      });

      test('should return false for premium user', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 200,
          monthlyCount: 0,
          isPremium: true,
          dailyLimit: 100,
        );

        expect(quotaInfo.isDailyQuotaExhausted(), isFalse);
      });

      test('should return false when no daily limit set', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 200,
          monthlyCount: 0,
        );

        expect(quotaInfo.isDailyQuotaExhausted(), isFalse);
      });
    });

    group('isMonthlyQuotaExhausted()', () {
      test('should return true when monthly quota exhausted', () {
        const quotaInfo = QuotaInfo(
          apiName: 'google_vision',
          todayCount: 0,
          monthlyCount: 1000,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.isMonthlyQuotaExhausted(), isTrue);
      });

      test('should return false when quota available', () {
        const quotaInfo = QuotaInfo(
          apiName: 'google_vision',
          todayCount: 0,
          monthlyCount: 500,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.isMonthlyQuotaExhausted(), isFalse);
      });

      test('should return false for premium user', () {
        const quotaInfo = QuotaInfo(
          apiName: 'google_vision',
          todayCount: 0,
          monthlyCount: 1500,
          isPremium: true,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.isMonthlyQuotaExhausted(), isFalse);
      });
    });

    group('getDailyUsagePercentage()', () {
      test('should calculate daily usage percentage correctly', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.getDailyUsagePercentage(), equals(50));
      });

      test('should return 100 when quota exhausted', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 100,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.getDailyUsagePercentage(), equals(100));
      });

      test('should cap at 100 when quota exceeded', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 150,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.getDailyUsagePercentage(), equals(100));
      });

      test('should return 0 when no usage', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 0,
          monthlyCount: 0,
          dailyLimit: 100,
        );

        expect(quotaInfo.getDailyUsagePercentage(), equals(0));
      });

      test('should return null when no daily limit', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 0,
        );

        expect(quotaInfo.getDailyUsagePercentage(), isNull);
      });

      test('should handle edge case with 0 daily limit', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 0,
          monthlyCount: 0,
          dailyLimit: 0,
        );

        expect(quotaInfo.getDailyUsagePercentage(), isNull);
      });
    });

    group('getMonthlyUsagePercentage()', () {
      test('should calculate monthly usage percentage correctly', () {
        const quotaInfo = QuotaInfo(
          apiName: 'google_vision',
          todayCount: 0,
          monthlyCount: 800,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.getMonthlyUsagePercentage(), equals(80));
      });

      test('should return 100 when quota exhausted', () {
        const quotaInfo = QuotaInfo(
          apiName: 'google_vision',
          todayCount: 0,
          monthlyCount: 1000,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.getMonthlyUsagePercentage(), equals(100));
      });

      test('should cap at 100 when quota exceeded', () {
        const quotaInfo = QuotaInfo(
          apiName: 'google_vision',
          todayCount: 0,
          monthlyCount: 1500,
          monthlyLimit: 1000,
        );

        expect(quotaInfo.getMonthlyUsagePercentage(), equals(100));
      });

      test('should return null when no monthly limit', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 0,
          monthlyCount: 500,
        );

        expect(quotaInfo.getMonthlyUsagePercentage(), isNull);
      });
    });

    group('copyWith()', () {
      test('should create a copy with updated fields', () {
        const original = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 500,
          dailyLimit: 100,
        );

        final copy = original.copyWith(todayCount: 60, isPremium: true);

        expect(copy.apiName, equals('gemini'));
        expect(copy.todayCount, equals(60));
        expect(copy.monthlyCount, equals(500));
        expect(copy.isPremium, isTrue);
        expect(copy.dailyLimit, equals(100));
      });

      test('should preserve original when no fields updated', () {
        const original = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 500,
        );

        final copy = original.copyWith();

        expect(copy.apiName, equals(original.apiName));
        expect(copy.todayCount, equals(original.todayCount));
        expect(copy.monthlyCount, equals(original.monthlyCount));
      });
    });

    group('toFirestore() and fromFirestore()', () {
      test('should convert to Firestore format correctly', () {
        final now = DateTime.now();
        final quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 500,
          lastRequest: now,
          lastDailyReset: now,
          lastMonthlyReset: now,
          isPremium: true,
        );

        final firestoreData = quotaInfo.toFirestore();

        expect(firestoreData['today_count'], equals(50));
        expect(firestoreData['monthly_count'], equals(500));
        expect(firestoreData['is_premium'], isTrue);
        expect(firestoreData['last_request'], isA<Timestamp>());
        expect(firestoreData['last_daily_reset'], isA<Timestamp>());
        expect(firestoreData['last_monthly_reset'], isA<Timestamp>());
      });

      test('should omit null timestamps in toFirestore()', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 0,
          monthlyCount: 0,
        );

        final firestoreData = quotaInfo.toFirestore();

        expect(firestoreData.containsKey('last_request'), isFalse);
        expect(firestoreData.containsKey('last_daily_reset'), isFalse);
        expect(firestoreData.containsKey('last_monthly_reset'), isFalse);
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        const quota1 = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 500,
          dailyLimit: 100,
        );

        const quota2 = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 500,
          dailyLimit: 100,
        );

        expect(quota1, equals(quota2));
        expect(quota1.hashCode, equals(quota2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const quota1 = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 500,
        );

        const quota2 = QuotaInfo(
          apiName: 'gemini',
          todayCount: 60,
          monthlyCount: 500,
        );

        expect(quota1, isNot(equals(quota2)));
      });
    });

    group('toString()', () {
      test('should return readable string representation', () {
        const quotaInfo = QuotaInfo(
          apiName: 'gemini',
          todayCount: 50,
          monthlyCount: 500,
          isPremium: false,
          dailyLimit: 100,
          monthlyLimit: 1000,
        );

        final string = quotaInfo.toString();

        expect(string, contains('gemini'));
        expect(string, contains('50'));
        expect(string, contains('500'));
        expect(string, contains('false'));
        expect(string, contains('100'));
        expect(string, contains('1000'));
      });
    });
  });
}
