# Core Layer - Transversal Components

This directory contains shared infrastructure and utilities used across all features.

## Structure

- **auth/** - Authentication infrastructure (Firebase Auth wrapper)
- **data_sync/** - Offline-first synchronization (Hive ↔ Firestore)
- **networking/** - HTTP client configuration (Dio + retry interceptors)
- **storage/** - Local storage abstraction (Hive boxes)
- **feature_flags/** - Remote config & feature toggles (Firebase Remote Config)
- **monitoring/** - Crash reporting & analytics (Crashlytics, Analytics)
- **compliance/** - RGPD compliance utilities (consent, data export)
- **routing/** - App-wide navigation (GoRouter configuration - Story 0.5)
- **theme/** - Design system & theming (Material 3 colors, typography)
- **shared/** - Common utilities, extensions, widgets, exceptions

## Principles

- Core components are **feature-agnostic**
- Features depend on core, but core **never** depends on features
- Use dependency injection (Riverpod providers) for configuration
