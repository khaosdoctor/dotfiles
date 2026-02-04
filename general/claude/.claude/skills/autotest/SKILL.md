---
disable-model-invocation: true
user-invocable: true
allowed-tools:
  # Note: Read, Glob, Grep are ALWAYS implicitly allowed (global guideline)
  - Bash:
      - npm test
      - npm run
      - yarn test
      - pnpm test
      - bun test
      - cargo test
      - cargo nextest
      - go test
      - pytest
      - python -m pytest
      - python -m unittest
      - make test
      - rake test
      - bundle exec rspec
      - phpunit
      - composer test
      - jest
      - vitest
      - deno test
      - mix test
---

# Autotest Skill

Smart test runner with automatic framework detection and intelligent execution.

## Purpose

Automatically detect the test framework and run tests using project-defined scripts or commands. Provides detailed output with failures, suggestions for fixes, and coverage information when available.

## When to Use

- During development to verify changes
- Before committing code
- After refactoring
- When implementing new features
- To verify bug fixes
- Before creating pull requests

## Supported Test Frameworks

### JavaScript/TypeScript
- Jest
- Vitest
- Mocha
- Ava
- Tape
- Node:test (built-in)
- Deno test

### Python
- pytest
- unittest
- nose2
- doctest

### Rust
- cargo test
- cargo nextest

### Go
- go test
- go test with various flags

### Ruby
- RSpec
- Minitest
- Test::Unit

### PHP
- PHPUnit
- Pest
- Codeception

### Elixir
- ExUnit (mix test)

### Other
- Any test command defined in project scripts

## Detection Strategy

1. **Check for project scripts first** (highest priority):
   - `package.json` scripts: `test`, `test:unit`, `test:integration`, `test:e2e`
   - `Makefile` targets: `test`, `test-unit`, `test-integration`
   - `Justfile` commands
   - `composer.json` scripts
   - `Cargo.toml` test configuration

2. **Detect test framework from dependencies**:
   - JavaScript: Check `package.json` for jest, vitest, mocha, etc.
   - Python: Check for `pytest.ini`, `setup.py`, `pyproject.toml`
   - Rust: Check for `Cargo.toml` and test directory structure
   - Go: Check for `*_test.go` files
   - Ruby: Check for `Gemfile` with rspec, minitest
   - PHP: Check for `phpunit.xml`, `composer.json`

3. **Fall back to standard commands**:
   - Use framework-specific commands if detected
   - Provide helpful error if no test framework found

## Execution Steps

1. **Detect Project Structure**:
   - Read project configuration files
   - Identify test framework
   - Check for custom test scripts

2. **Determine Test Command**:
   - Use project script if available (e.g., `npm test`)
   - Fall back to direct framework command
   - Apply any user-specified filters or patterns

3. **Run Tests**:
   - Execute test command with appropriate flags
   - Capture stdout and stderr
   - Parse output for failures and coverage

4. **Analyze Results**:
   - Count total tests, passed, failed, skipped
   - Extract failure details with file:line references
   - Collect coverage information if available
   - Identify patterns in failures

5. **Provide Feedback**:
   - Summary of test results
   - Detailed failure information
   - Suggestions for fixing failures
   - Coverage gaps if applicable
   - Next steps

## Command Options

Support common test execution patterns:
- Run all tests (default)
- Run specific test file(s)
- Run tests matching pattern
- Watch mode (if supported)
- Coverage mode (if supported)
- Verbose output
- Bail on first failure

Examples:
```bash
/autotest                          # Run all tests
/autotest src/utils.test.ts        # Run specific file
/autotest --pattern="user.*"       # Run tests matching pattern
/autotest --watch                  # Watch mode
/autotest --coverage               # With coverage
```

## Output Format

### Success Case
```markdown
# Test Results

✓ All tests passed!

## Summary
- Total: 42 tests
- Passed: 42
- Failed: 0
- Skipped: 0
- Duration: 2.34s

## Coverage (if available)
- Statements: 85.2%
- Branches: 78.9%
- Functions: 90.1%
- Lines: 85.7%

Files with low coverage (<80%):
- src/utils/parser.ts: 65.3%
- src/api/legacy.ts: 45.2%
```

### Failure Case
```markdown
# Test Results

✗ Tests failed

## Summary
- Total: 42 tests
- Passed: 39
- Failed: 3
- Skipped: 0
- Duration: 2.56s

## Failures

### 1. User authentication should validate email format
**File**: src/auth/__tests__/validation.test.ts:23
**Error**: AssertionError: expected false to be true

**Test Code**:
```typescript
expect(isValidEmail('invalid-email')).toBe(true);
```

**Failure Reason**: The email 'invalid-email' doesn't match the regex pattern

**Suggested Fix**:
The test expects an invalid email to pass validation. This should likely be:
```typescript
expect(isValidEmail('invalid-email')).toBe(false);
```

Or if testing valid email:
```typescript
expect(isValidEmail('user@example.com')).toBe(true);
```

---

### 2. API endpoint should handle 404 errors
**File**: src/api/__tests__/endpoints.test.ts:45
**Error**: TypeError: Cannot read property 'status' of undefined

**Failure Reason**: The API response is undefined, likely the mock isn't set up correctly

**Suggested Fix**:
Ensure the mock is configured before the test:
```typescript
beforeEach(() => {
  mockApi.get.mockResolvedValue({ status: 404, data: null });
});
```

---

## Next Steps
1. Fix the test assertion in validation.test.ts:23
2. Check mock setup in endpoints.test.ts:45
3. Re-run tests after fixes
```

## Framework-Specific Notes

### Jest/Vitest
- Support for `.only`, `.skip`, `.todo`
- Watch mode available
- Coverage via `--coverage` flag
- Snapshot testing support

### pytest
- Use `-v` for verbose output
- Support for markers (`-m`)
- Coverage via `pytest-cov`
- Parametrized tests

### cargo test
- Parallel execution by default
- Filter by test name
- `--nocapture` for print output
- Documentation tests included

### Go test
- Use `-v` for verbose
- `-run` for pattern matching
- `-cover` for coverage
- Table-driven tests common

## Important Notes

- Always use project-defined scripts when available
- Never modify test files without permission
- Provide actionable suggestions for failures
- Include file:line references for all failures
- Consider suggesting additional test cases for edge cases
- If tests require setup (database, services), mention it
- Respect test configuration in project files

## Safety Guidelines

- Never modify test files without explicit user permission
- Never skip or disable tests without asking
- Never run tests with `--force` or similar flags that ignore errors
- Always use project's test command if defined
- Report all failures honestly, don't hide or minimize issues
