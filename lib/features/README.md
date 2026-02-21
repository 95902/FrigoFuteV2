# Features Layer - Business Modules

This directory contains the 14 business feature modules following Feature-First architecture.

## Architecture

Each feature follows **Clean Architecture** with 3 layers:

```
feature_name/
├── domain/          # Business logic (pure Dart)
│   ├── entities/    # Business objects
│   ├── repositories/ # Abstract contracts
│   └── usecases/    # Business operations
├── data/            # Data implementation
│   ├── models/      # Data transfer objects (JSON serialization)
│   ├── datasources/ # API clients, local storage
│   └── repositories/ # Repository implementations
└── presentation/    # UI layer
    ├── providers/   # Riverpod state management
    ├── screens/     # Page-level widgets
    └── widgets/     # Feature-specific components
```

## Module List

### Free Tier (6 modules)
1. **inventory** - Inventory CRUD management
2. **ocr_scan** - OCR receipt scanning + barcode
3. **notifications** - Expiration alerts (DLC/DDM)
4. **dashboard** - Metrics & impact dashboard
5. **auth_profile** - Firebase auth + user profile
6. **recipes** - Recipe discovery & suggestions

### Premium Tier (8 modules) 💎
7. **nutrition_tracking** - Daily food logging
8. **nutrition_profiles** - 12 nutritional profiles
9. **meal_planning** - AI meal planner (Gemini)
10. **ai_coach** - AI nutrition coach
11. **gamification** - Achievements, streaks, leaderboard
12. **shopping_list** - Smart shopping lists
13. **family_sharing** - Family sharing & PDF export
14. **price_comparator** - Multi-store price comparison

## Communication Rules

- Features are **isolated** - no direct imports between features
- Inter-feature communication via:
  - Riverpod providers (shared state)
  - GoRouter navigation (deep links)
  - Event bus (if needed for decoupling)
