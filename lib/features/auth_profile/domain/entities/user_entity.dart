import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

part 'user_entity.freezed.dart';

/// User entity for domain layer
/// Story 1.1 & 1.2: User Authentication
///
/// Represents authenticated user in the domain layer.
/// Combines Firebase Auth data + Firestore profile data.
/// Independent of Firebase/Firestore implementation details.
@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String uid,
    required String email,
    required bool emailVerified,
    DateTime? createdAt,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String profileType,
    // Story 1.3: Google Sign-In fields
    @Default('') String photoUrl,
    @Default('email') String authProvider,
  }) = _UserEntity;

  const UserEntity._();

  /// Creates UserEntity from Firebase User (Auth only, no Firestore data)
  ///
  /// Used after authentication to convert Firebase's User object
  /// to our domain entity with basic auth fields only.
  /// Profile fields (firstName, lastName, profileType) will be empty.
  factory UserEntity.fromFirebaseUser(auth.User user) {
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      emailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
    );
  }
}
