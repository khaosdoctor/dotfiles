# Example: Handling Test Failures

## Scenario
Running tests that have failures and need debugging assistance.

## Command
```bash
/autotest
```

## Sample Test Output (Failed Tests)

```
 FAIL  src/api/__tests__/users.test.ts
  User API
    ✓ should create a new user (45ms)
    ✕ should validate email format (12ms)
    ✓ should hash passwords (23ms)
    ✕ should prevent duplicate emails (18ms)
    ✕ should require all fields (9ms)

  ● User API › should validate email format

    expect(received).rejects.toThrow()

    Received promise resolved instead of rejected
    Resolved to value: {id: 1, email: "invalid-email", name: "Test"}

      23 |   it('should validate email format', async () => {
      24 |     const invalidUser = { email: 'invalid-email', name: 'Test', password: 'pass123' };
    > 25 |     await expect(createUser(invalidUser)).rejects.toThrow('Invalid email');
         |           ^
      26 |   });

    at Object.<anonymous> (src/api/__tests__/users.test.ts:25:11)

  ● User API › should prevent duplicate emails

    TypeError: Cannot read property 'code' of undefined

      45 |     await createUser(userData);
      46 |     const duplicate = await createUser(userData);
    > 47 |     expect(duplicate.error.code).toBe('DUPLICATE_EMAIL');
         |                           ^
      48 |   });

    at Object.<anonymous> (src/api/__tests__/users.test.ts:47:27)

  ● User API › should require all fields

    AssertionError: expected 400 to equal 422

      67 |     const response = await request(app)
      68 |       .post('/api/users')
      69 |       .send({ email: 'test@example.com' });
    > 70 |     expect(response.status).toBe(422);
         |                             ^
      71 |   });

    at Object.<anonymous> (src/api/__tests__/users.test.ts:70:29)

Test Suites: 1 failed, 1 total
Tests:       3 failed, 2 passed, 5 total
Time:        2.341s
```

## Expected Output

```markdown
# Test Results

✗ Tests failed

## Summary
- Total: 5 tests
- Passed: 2
- Failed: 3
- Skipped: 0
- Duration: 2.34s
- Test Suite: src/api/__tests__/users.test.ts

## Test Framework Detected
- Framework: Jest
- Command used: `npm test`
- Configuration: jest.config.js

## Failures Analysis

### 1. should validate email format
**File**: src/api/__tests__/users.test.ts:25
**Status**: ❌ Failed

**Error**: Promise resolved instead of rejected
```typescript
await expect(createUser(invalidUser)).rejects.toThrow('Invalid email');
```

**What happened**:
- Test expected `createUser` to throw an error for invalid email
- Instead, the function successfully created a user with email "invalid-email"
- This means email validation is not working in the `createUser` function

**Root Cause**: Missing or incorrect email validation in the implementation

**Suggested Fix**:

Check src/services/user-service.ts or wherever `createUser` is defined:

```typescript
// Add email validation using Zod
import { z } from 'zod';

const emailSchema = z.string().email();

export async function createUser(userData: UserInput) {
  // Validate email format
  try {
    emailSchema.parse(userData.email);
  } catch (error) {
    throw new Error('Invalid email');
  }

  // Rest of the function...
}
```

Or use a comprehensive schema:
```typescript
const userInputSchema = z.object({
  email: z.string().email('Invalid email'),
  name: z.string().min(1),
  password: z.string().min(8)
});

export async function createUser(userData: UserInput) {
  const validated = userInputSchema.parse(userData);
  // Continue with validated data...
}
```

---

### 2. should prevent duplicate emails
**File**: src/api/__tests__/users.test.ts:47
**Status**: ❌ Failed

**Error**: TypeError: Cannot read property 'code' of undefined
```typescript
expect(duplicate.error.code).toBe('DUPLICATE_EMAIL');
```

**What happened**:
- Test tried to access `duplicate.error.code`
- But `duplicate.error` is undefined
- This could mean:
  1. `createUser` doesn't return an error object for duplicates
  2. It throws an exception instead of returning an error
  3. The duplicate check isn't implemented

**Suggested Fix**:

First, check how `createUser` handles duplicates. It should either:

**Option 1: Throw an exception**
```typescript
// In user-service.ts
export async function createUser(userData: UserInput) {
  // Check for existing email
  const existing = await db.select()
    .from(users)
    .where(eq(users.email, userData.email))
    .limit(1);

  if (existing.length > 0) {
    const error = new Error('Email already exists');
    error.code = 'DUPLICATE_EMAIL';
    throw error;
  }

  // Continue with creation...
}

// Update test to expect thrown error
it('should prevent duplicate emails', async () => {
  await createUser(userData);

  await expect(createUser(userData))
    .rejects
    .toThrow(expect.objectContaining({
      message: 'Email already exists',
      code: 'DUPLICATE_EMAIL'
    }));
});
```

**Option 2: Return error object**
```typescript
// In user-service.ts
export async function createUser(userData: UserInput): Promise<Result<User>> {
  const existing = await db.select()
    .from(users)
    .where(eq(users.email, userData.email))
    .limit(1);

  if (existing.length > 0) {
    return {
      success: false,
      error: { code: 'DUPLICATE_EMAIL', message: 'Email already exists' }
    };
  }

  // Continue with creation...
  return { success: true, data: newUser };
}

// Update test
it('should prevent duplicate emails', async () => {
  await createUser(userData);
  const result = await createUser(userData);

  expect(result.success).toBe(false);
  expect(result.error?.code).toBe('DUPLICATE_EMAIL');
});
```

---

### 3. should require all fields
**File**: src/api/__tests__/users.test.ts:70
**Status**: ❌ Failed

**Error**: Expected status 422, received 400
```typescript
expect(response.status).toBe(422);
// Actual: 400
```

**What happened**:
- Test expects HTTP status 422 (Unprocessable Entity) for validation errors
- API returned 400 (Bad Request) instead
- The validation is working, but using wrong status code

**Suggested Fix**:

This is a minor inconsistency. Choose one approach:

**Option 1: Update the test** (if 400 is acceptable)
```typescript
expect(response.status).toBe(400); // Bad Request is also valid for validation
```

**Option 2: Update the API** (if 422 is preferred)
```typescript
// In src/api/routes/users.ts
router.post('/users', async (req, res) => {
  try {
    const userData = userSchema.parse(req.body);
    const user = await createUser(userData);
    res.status(201).json(user);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(422).json({  // Use 422 for validation errors
        error: 'Validation failed',
        details: error.errors
      });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

**Rationale**:
- 400 = Bad Request (generic client error)
- 422 = Unprocessable Entity (specifically for validation errors)
- Both are acceptable, but 422 is more semantic for validation

---

## Recommended Actions

### Priority 1: Fix email validation (Critical)
1. Add Zod email validation in createUser function
2. Re-run tests to verify fix

### Priority 2: Implement duplicate email check (High)
1. Add database query to check existing emails
2. Decide on error handling pattern (throw vs return)
3. Update test to match implementation pattern
4. Re-run tests to verify

### Priority 3: Standardize status codes (Low)
1. Decide on validation error status code (400 vs 422)
2. Update either API or test to match
3. Document status code conventions in API docs

## Next Steps
```bash
# After fixing validation
/autotest src/api/__tests__/users.test.ts

# Run with coverage to see what's tested
/autotest --coverage

# Watch mode for iterative development
/autotest --watch
```

## Files to Check
1. src/services/user-service.ts - Main implementation
2. src/api/routes/users.ts - HTTP layer and status codes
3. src/validators/user.ts - Validation schemas
4. src/db/queries/users.ts - Database operations
```
