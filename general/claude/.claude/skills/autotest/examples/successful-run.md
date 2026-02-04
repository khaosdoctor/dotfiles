# Example: Successful Test Run

## Scenario
Running tests on a Node.js project with Vitest where all tests pass.

## Command
```bash
/autotest
```

## Project Structure
```
project/
├── package.json
├── vitest.config.ts
├── src/
│   ├── utils/
│   │   ├── math.ts
│   │   └── __tests__/
│   │       └── math.test.ts
│   └── api/
│       ├── users.ts
│       └── __tests__/
│           └── users.test.ts
```

## package.json
```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  },
  "devDependencies": {
    "vitest": "^1.0.0",
    "@vitest/coverage-v8": "^1.0.0"
  }
}
```

## Test Output
```
# Test Results

✓ All tests passed!

## Summary
- Total: 24 tests
- Passed: 24
- Failed: 0
- Skipped: 0
- Duration: 1.82s

## Test Suites
✓ src/utils/__tests__/math.test.ts (12 tests)
✓ src/api/__tests__/users.test.ts (12 tests)

## Coverage
- Statements: 92.5%
- Branches: 88.3%
- Functions: 95.0%
- Lines: 92.8%

Files with coverage below 90%:
- src/api/users.ts: 87.5% - Missing coverage for error handling paths

## Detected Setup
- Framework: Vitest
- Command used: `npm test`
- Configuration: vitest.config.ts
- Coverage tool: @vitest/coverage-v8

Great job! All tests are passing. Consider adding tests for the error handling paths in users.ts to improve coverage.
```
