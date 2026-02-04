# Example: Test Files Are Excluded from Complexity Checks

## Scenario
Reviewing changes that include both source code with issues and test files with complex setup.

## Command
```bash
/autoreview
```

## Sample Code Being Reviewed

### Source File with Issues
```typescript
// src/api/users.ts
export function processUser(user: any, options: any) {
  if (user.type === 'admin') {
    if (options.includePermissions) {
      if (user.permissions) {
        if (options.format === 'json') {
          if (user.metadata) {
            // Deep nesting - should be flagged
            return { ...user, formatted: true };
          }
        }
      }
    }
  }
  return user;
}
```

### Test File with Complex Setup
```typescript
// src/api/__tests__/users.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { processUser } from '../users';

describe('User Processing', () => {
  let mockUser: any;
  let mockOptions: any;

  beforeEach(() => {
    // Complex test setup - this is fine in tests
    mockUser = {
      id: 1,
      name: 'Test User',
      type: 'admin',
      permissions: ['read', 'write', 'delete'],
      metadata: { created: '2024-01-01' }
    };

    mockOptions = {
      includePermissions: true,
      format: 'json',
      includeMetadata: true
    };
  });

  it('should process admin user with all options', () => {
    const result = processUser(mockUser, mockOptions);

    // Multiple nested assertions - this is acceptable in tests
    if (result.type === 'admin') {
      if (result.permissions) {
        if (result.metadata) {
          if (result.formatted) {
            expect(result.formatted).toBe(true);
            expect(result.permissions).toContain('read');
          }
        }
      }
    }
  });

  it('should handle edge case with null permissions', () => {
    mockUser.permissions = null;

    // Complex conditional logic in test - this is fine
    const result = processUser(mockUser, mockOptions);

    if (mockOptions.includePermissions) {
      if (!result.permissions) {
        if (result.type === 'admin') {
          expect(result.permissions).toBeNull();
        }
      }
    }
  });

  // Many more nested test cases...
  describe('nested describe blocks', () => {
    describe('deeply nested', () => {
      describe('even deeper', () => {
        // This level of nesting is acceptable in tests
        it('should work', () => {
          expect(true).toBe(true);
        });
      });
    });
  });
});
```

## Expected Output

```markdown
# Code Review Report

## Summary
- Total Issues: 1
- Critical: 0
- High: 0
- Medium: 1
- Low: 0

## Medium Priority Issues

### 1. High Cyclomatic Complexity in src/api/users.ts:3
**Severity**: Medium
**Description**: Function has deeply nested conditionals (5 levels) making it hard to test and maintain

**Current Code**:
```typescript
export function processUser(user: any, options: any) {
  if (user.type === 'admin') {
    if (options.includePermissions) {
      if (user.permissions) {
        if (options.format === 'json') {
          if (user.metadata) {
            return { ...user, formatted: true };
          }
        }
      }
    }
  }
  return user;
}
```

**Suggested Fix**:
```typescript
export function processUser(user: User, options: ProcessOptions): ProcessedUser {
  if (!shouldProcessUser(user, options)) {
    return user;
  }

  return formatUser(user, options);
}

function shouldProcessUser(user: User, options: ProcessOptions): boolean {
  return user.type === 'admin'
    && options.includePermissions
    && user.permissions
    && options.format === 'json'
    && user.metadata;
}

function formatUser(user: User, options: ProcessOptions): ProcessedUser {
  return { ...user, formatted: true };
}
```

**Rationale**: Extract nested logic into helper functions with clear responsibilities. Use early returns to reduce nesting.

---

## Test Files Reviewed (No Issues)
The following test files were reviewed but **excluded from complexity checks** as they are test files:
- `src/api/__tests__/users.test.ts` - Complex test setup and nested assertions are acceptable in tests

## Notes
- Test files can have complex setup, nested describes, and multiple conditional assertions
- Complexity metrics (cyclomatic complexity, nesting depth, function length) are NOT enforced on test files
- Test files are identified by common patterns:
  - Files in `__tests__/`, `test/`, `tests/` directories
  - Files ending with `.test.ts`, `.test.js`, `.spec.ts`, `.spec.js`
  - Files in directories named `e2e/`, `integration/`, `unit/`

## Recommendations
- Continue using descriptive test names
- Keep source code complexity low to make testing easier
- Consider using test helpers to reduce duplication in test setup
```
