# Tests

Mirror structure of `lib/` directory for unit and widget tests.

## Structure

- **core/** - Tests for core infrastructure
- **features/** - Tests for feature modules (mirror lib/features/)
- **integration_test/** - End-to-end integration tests
- **test_helpers/** - Shared mocks, factories, test utilities

## Testing Strategy

### Unit Tests
- Domain layer: Test all usecases with mocked repositories
- Data layer: Test repositories, models, datasources
- Target: **75%+ code coverage**

### Widget Tests
- Presentation layer: Test screens and widgets in isolation
- Use `mocktail` for mocking Riverpod providers

### Integration Tests
- E2E user flows (login, add product, scan receipt, etc.)
- Use `integration_test` package

## Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test/
```

## Quality Gates (CI/CD)

- ✅ All tests must pass
- ✅ Code coverage ≥ 75%
- ✅ No linting errors (`flutter analyze`)
