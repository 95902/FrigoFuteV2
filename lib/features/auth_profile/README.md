# Auth & Profile Feature ✅ FREE

Authentification Firebase et gestion du profil utilisateur avec conformité RGPD.

## Fonctionnalités (Epic 1)

- ✅ Création compte (email/password)
- ✅ Login (email/password)
- ✅ OAuth Google Sign-In
- ✅ OAuth Apple Sign-In
- ✅ Onboarding adaptatif
- ✅ Configuration profil (caractéristiques physiques)
- ✅ Préférences alimentaires & allergies
- ✅ Sync multi-devices
- ✅ Export données (RGPD portabilité)
- ✅ Suppression compte définitive

## Architecture

```
auth_profile/
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   └── user_profile.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── login_with_email.dart
│       ├── login_with_google.dart
│       ├── create_account.dart
│       └── update_profile.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── user_profile_model.dart
│   ├── datasources/
│   │   ├── firebase_auth_datasource.dart
│   │   └── profile_remote_datasource.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       └── profile_repository_impl.dart
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart
    │   └── profile_provider.dart
    ├── screens/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   ├── onboarding_screen.dart
    │   └── profile_screen.dart
    └── widgets/
        ├── oauth_buttons.dart
        └── profile_form.dart
```

## Firebase Auth Flow

1. User login → Firebase Auth
2. Get user token → Firestore profile fetch
3. Store session → Hive local cache
4. Sync profile changes → Firestore + other devices

## RGPD Compliance

- Double opt-in for health data
- Granular consent settings
- Data export in JSON format
- Right to be forgotten (30-day retention)

## Stories

Implemented in stories: 1.1 - 1.10
