import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'subscription_model.dart';
import 'consent_model.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

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

/// User model for data layer (Firestore)
/// Story 1.1: Create Account with Email and Password
///
/// Represents user document structure in Firestore.
/// Collection: `users/{userId}`
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String userId,
    required String email,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    required bool emailVerified,
    required SubscriptionModel subscription,
    required ConsentModel consentGiven,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String profileType,
    // Story 1.3: Google Sign-In fields
    @Default('') String photoUrl, // Google profile picture URL
    @Default('email') String authProvider, // 'email', 'google', 'apple'
    @Default(false) bool accountDeleted,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
