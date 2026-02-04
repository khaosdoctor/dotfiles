# Example: Running Specific Tests

## Scenario
Running only specific test files or patterns instead of the entire test suite.

## Commands

### Run specific file
```bash
/autotest src/api/__tests__/users.test.ts
```

### Run tests matching pattern
```bash
/autotest --pattern="authentication"
```

### Run with coverage
```bash
/autotest --coverage
```

## Example 1: Specific File

### Command
```bash
/autotest src/utils/__tests__/math.test.ts
```

### Output
```
# Test Results - Specific File

✓ Tests passed

## Summary
- Total: 8 tests
- Passed: 8
- Failed: 0
- Skipped: 0
- Duration: 0.45s

## Test File
✓ src/utils/__tests__/math.test.ts (8 tests)
  ✓ add() should sum two numbers
  ✓ add() should handle negative numbers
  ✓ subtract() should subtract two numbers
  ✓ multiply() should multiply two numbers
  ✓ divide() should divide two numbers
  ✓ divide() should throw on division by zero
  ✓ modulo() should return remainder
  ✓ modulo() should handle negative numbers

## Detected Setup
- Framework: Vitest
- Command used: `npm test src/utils/__tests__/math.test.ts`

All tests in this file are passing!
```

## Example 2: Pattern Matching

### Command
```bash
/autotest --pattern="user.*validation"
```

### Output
```
# Test Results - Pattern Match

✓ Tests passed

## Summary
- Total: 12 tests
- Passed: 12
- Failed: 0
- Skipped: 0
- Duration: 1.23s

## Matched Test Suites
✓ src/validators/__tests__/user.test.ts (7 tests)
  ✓ user validation should validate required fields
  ✓ user validation should reject invalid emails
  ✓ user validation should enforce password requirements
  ✓ user validation should validate phone numbers
  ✓ user validation should handle optional fields
  ✓ user validation should reject SQL injection attempts
  ✓ user validation should sanitize input

✓ src/models/__tests__/user.test.ts (5 tests)
  ✓ user model validation should enforce schema
  ✓ user model validation should validate email uniqueness
  ✓ user model validation should hash passwords
  ✓ user model validation should set timestamps
  ✓ user model validation should handle updates

## Detected Setup
- Framework: Jest
- Command used: `npm test -- --testNamePattern="user.*validation"`
- Pattern: "user.*validation"

All validation tests are passing!
```

## Example 3: With Coverage

### Command
```bash
/autotest --coverage
```

### Output
```
# Test Results - With Coverage

✓ All tests passed!

## Summary
- Total: 42 tests
- Passed: 42
- Failed: 0
- Skipped: 0
- Duration: 3.67s

## Coverage Report

### Overall Coverage
- Statements: 85.2% (732/859)
- Branches: 78.9% (234/297)
- Functions: 90.1% (145/161)
- Lines: 85.7% (710/828)

### Files Below 80% Coverage

#### src/api/legacy.ts - 45.2%
**Uncovered Lines**: 23-45, 67-89, 102-125
**Suggestion**: This legacy code has low coverage. Consider:
1. Adding tests for the uncovered paths
2. Refactoring to simplify testing
3. If deprecated, plan for removal

#### src/utils/parser.ts - 65.3%
**Uncovered Branches**: Error handling paths (lines 34, 56, 78)
**Suggestion**: Add test cases for:
```typescript
// Test error cases
it('should handle malformed input', () => {
  expect(() => parse('invalid')).toThrow('Parse error');
});

it('should handle empty input', () => {
  expect(parse('')).toEqual([]);
});
```

#### src/integrations/external-api.ts - 72.1%
**Uncovered Lines**: Network error handlers (lines 89-102)
**Suggestion**: Mock network failures to test error paths:
```typescript
it('should handle network errors', async () => {
  mockApi.get.mockRejectedValue(new Error('Network error'));
  await expect(fetchData()).rejects.toThrow('Network error');
});
```

### Well-Covered Files (>95%)
✓ src/utils/math.ts - 100%
✓ src/validators/email.ts - 98.2%
✓ src/models/user.ts - 96.5%
✓ src/api/users.ts - 95.8%

## Detected Setup
- Framework: Vitest
- Command used: `npm test -- --coverage`
- Coverage tool: @vitest/coverage-v8

## Recommendations
1. Focus on improving coverage for legacy.ts and parser.ts
2. Add tests for error handling paths in external-api.ts
3. Current coverage is good but can be improved with edge case testing
```

## Framework-Specific Patterns

### Jest
```bash
/autotest --pattern="User"           # -t "User"
/autotest src/api/**/*.test.ts       # File glob
/autotest --watch                    # --watch
```

### pytest
```bash
/autotest tests/test_users.py       # Specific file
/autotest --pattern="test_user_"    # -k "test_user_"
/autotest --coverage                # --cov
```

### cargo test
```bash
/autotest user_tests                # Test name filter
/autotest --pattern="integration"   # Pattern matching
```

### go test
```bash
/autotest ./pkg/users/...           # Package path
/autotest --pattern="TestUser"      # -run TestUser
/autotest --coverage                # -cover
```
