import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

/// Converts Firestore Timestamp to DateTime
DateTime _timestampFromJson(dynamic timestamp) {
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  }
  if (timestamp is int) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  if (timestamp is String) {
    return DateTime.parse(timestamp);
  }
  return DateTime.now();
}

/// Converts DateTime to Firestore Timestamp
dynamic _timestampToJson(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}

/// Converts nullable Firestore Timestamp to nullable DateTime
DateTime? _timestampFromJsonNullable(dynamic timestamp) {
  if (timestamp == null) return null;
  return _timestampFromJson(timestamp);
}

/// Converts nullable DateTime to nullable Firestore Timestamp
dynamic _timestampToJsonNullable(DateTime? dateTime) {
  if (dateTime == null) return null;
  return _timestampToJson(dateTime);
}

/// Subscription model for user subscription status
/// Story 1.1: Create Account with Email and Password
///
/// Tracks user's subscription tier (free or premium)
@freezed
abstract class SubscriptionModel with _$SubscriptionModel {
  const SubscriptionModel._();

  const factory SubscriptionModel({
    required String status,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime startDate,
    @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
    DateTime? trialEndDate,
    @Default(false) bool isPremium,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}
