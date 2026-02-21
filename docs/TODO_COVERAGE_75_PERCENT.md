# TODO: Achieve 75% Test Coverage

## Current Status
- **Current Coverage:** 14.12% (136/963 lines)
- **Target Coverage:** 75% (722/963 lines)
- **Gap:** 586 lines need test coverage
- **Tests Passing:** 67/67 ✅

## Coverage Breakdown Plan

### Phase 1: Core Storage Tests (+15% coverage, ~145 lines)

**Priority: HIGH** - Fundamental infrastructure

**Files to Test:**
1. `lib/core/storage/hive_service.dart`
   - Test init() method
   - Test box initialization
   - Test adapter registration
   - Test error handling

2. `lib/core/storage/type_adapters/*.dart` (7 adapters)
   - Test read() method for each adapter
   - Test write() method for each adapter
   - Test typeId uniqueness

**Test Files to Create:**
```
test/core/storage/
├── hive_service_test.dart (20 tests)
└── type_adapters/
    ├── product_adapter_test.dart (10 tests)
    ├── recipe_adapter_test.dart (10 tests)
    ├── shopping_item_adapter_test.dart (10 tests)
    ├── nutrition_log_adapter_test.dart (10 tests)
    ├── health_profile_adapter_test.dart (10 tests)
    ├── achievement_adapter_test.dart (10 tests)
    └── sync_metadata_adapter_test.dart (10 tests)
```

**Estimated Tests:** 90 tests
**Estimated Coverage Gain:** +15%

### Phase 2: Core Data Sync Tests (+10% coverage, ~96 lines)

**Priority: MEDIUM** - Important for offline-first

**Files to Test:**
1. `lib/core/data_sync/sync_service.dart`
   - Test network monitoring
   - Test sync status stream
   - Test connection change handling

**Test Files to Create:**
```
test/core/data_sync/
└── sync_service_test.dart (25 tests)
```

**Estimated Tests:** 25 tests
**Estimated Coverage Gain:** +10%

### Phase 3: Feature Provider Tests (+20% coverage, ~193 lines)

**Priority: HIGH** - Core business logic

**Files to Test:**
1. `lib/features/inventory/presentation/providers/inventory_providers.dart`
   - Already has 5 basic tests
   - Add InventoryNotifier tests (addProduct, deleteProduct, etc.)
   - Test optimistic UI with rollback

2. `lib/features/inventory/domain/usecases/*.dart`
   - Test all use cases

3. `lib/features/inventory/data/repositories/*.dart`
   - Test repository implementations

**Test Files to Create/Expand:**
```
test/features/inventory/
├── domain/
│   ├── usecases/
│   │   ├── add_product_usecase_test.dart (✅ exists - 4 tests)
│   │   ├── delete_product_usecase_test.dart (15 tests)
│   │   ├── update_product_usecase_test.dart (15 tests)
│   │   └── get_products_usecase_test.dart (10 tests)
│   └── entities/
│       └── product_test.dart (10 tests)
├── data/
│   └── repositories/
│       └── inventory_repository_test.dart (20 tests)
└── presentation/
    └── providers/
        └── inventory_providers_test.dart (expand to 30 tests)
```

**Estimated Tests:** 100 tests
**Estimated Coverage Gain:** +20%

### Phase 4: Widget & Integration Tests (+20% coverage, ~193 lines)

**Priority: MEDIUM** - User-facing validation

**Files to Test:**
1. Routing widgets
2. Main app initialization
3. Screen widgets

**Test Files to Create:**
```
test/core/routing/
└── scaffold_with_bottom_nav_test.dart (15 widget tests)

test/features/inventory/
└── presentation/
    └── widgets/
        └── inventory_list_screen_example_test.dart (20 widget tests)

test/integration/
├── auth_flow_test.dart (15 tests)
└── navigation_flow_test.dart (15 tests)
```

**Estimated Tests:** 65 tests
**Estimated Coverage Gain:** +20%

### Phase 5: Remaining Coverage (+10% coverage)

**Priority: LOW** - Edge cases and utilities

- Error handling paths
- Edge cases in existing files
- Utility functions
- Constants validation

## Implementation Order

### Sprint 1 (Immediate)
1. ✅ Phase 1 - Storage Tests
2. Run coverage: `flutter test --coverage && dart run tool/check_coverage.dart coverage/lcov.info 30`
3. Expected: ~30% coverage

### Sprint 2
1. ✅ Phase 3 - Feature Provider Tests
2. Run coverage: `flutter test --coverage && dart run tool/check_coverage.dart coverage/lcov.info 50`
3. Expected: ~50% coverage

### Sprint 3
1. ✅ Phase 2 - Data Sync Tests
2. ✅ Phase 4 - Widget/Integration Tests
3. Run coverage: `flutter test --coverage && dart run tool/check_coverage.dart coverage/lcov.info 75`
4. Expected: ~75% coverage ✅

### Sprint 4 (Polish)
1. ✅ Phase 5 - Remaining Coverage
2. Aim for 80%+ coverage
3. Document any intentionally untested code

## Quick Wins (Do First)

These files are simple to test and will boost coverage quickly:

1. **FeatureConfig** - ✅ Already done (21 tests)
2. **AppRoutes** - ✅ Already done (26 tests)
3. **Product entity** - Simple data class, easy to test
4. **TypeAdapters** - Repetitive but straightforward

## Testing Strategy

### Unit Tests (70% of coverage)
- Test individual classes in isolation
- Mock dependencies
- Fast execution
- Example: `hive_service_test.dart`

### Widget Tests (20% of coverage)
- Test UI components
- User interactions
- Visual regression
- Example: `scaffold_with_bottom_nav_test.dart`

### Integration Tests (10% of coverage)
- Test complete user flows
- End-to-end scenarios
- Example: `auth_flow_test.dart`

## Tools & Commands

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Check Coverage Threshold
```bash
dart run tool/check_coverage.dart coverage/lcov.info 75
```

### Generate HTML Coverage Report
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
start coverage/html/index.html  # Windows
```

### Run Specific Test File
```bash
flutter test test/core/storage/hive_service_test.dart
```

### Run Tests in Watch Mode
```bash
flutter test --watch
```

## Success Criteria

- [ ] Coverage ≥ 75% (722+ lines covered)
- [ ] All tests passing (no flaky tests)
- [ ] Coverage report reviewed (no critical gaps)
- [ ] CI/CD pipeline enforces 75% threshold

## Notes

- Some files are generated (*.g.dart, *.freezed.dart) and excluded from coverage
- Firebase plugin code is not testable (platform channels)
- Focus on business logic, not boilerplate
- Widget tests can be time-consuming - prioritize critical screens

## References

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Code Coverage Guide](https://docs.flutter.dev/testing/code-coverage)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)
