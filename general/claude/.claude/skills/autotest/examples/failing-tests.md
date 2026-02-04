# Example: Failing Tests

## Scenario
Running tests on a TypeScript project with Jest where some tests fail.

## Command
```bash
/autotest
```

## Test Output
```
# Test Results

✗ Tests failed

## Summary
- Total: 18 tests
- Passed: 15
- Failed: 3
- Skipped: 0
- Duration: 3.21s

## Failures

### 1. User validation should reject invalid emails
**File**: src/validators/__tests__/user.test.ts:42
**Test**: describe > User validation > should reject invalid emails

**Error**:
```
AssertionError: expected true to be false

Expected: false
Received: true
```

**Test Code**:
```typescript
it('should reject invalid emails', () => {
  const result = validateEmail('not-an-email');
  expect(result.valid).toBe(false);  // Line 42
  expect(result.errors).toContain('Invalid email format');
});
```

**Actual Behavior**: The validation is incorrectly passing invalid emails

**Suggested Fix**:
Check the email regex in src/validators/user.ts. The pattern might be too permissive:

```typescript
// Current (likely incorrect):
const emailRegex = /.+@.+/;  // Too permissive

// Suggested:
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
```

**Location to fix**: src/validators/user.ts (validateEmail function)

---

### 2. API should return 404 for non-existent users
**File**: src/api/__tests__/users.test.ts:78
**Test**: describe > GET /users/:id > should return 404 for non-existent users

**Error**:
```
TypeError: Cannot read properties of undefined (reading 'status')

  at Object.<anonymous> (src/api/__tests__/users.test.ts:80:25)
```

**Test Code**:
```typescript
it('should return 404 for non-existent users', async () => {
  const response = await request(app).get('/users/999');
  expect(response.status).toBe(404);  // Line 80 - response is undefined
  expect(response.body.error).toBe('User not found');
});
```

**Failure Reason**: The API call is not returning a response object

**Suggested Fix**:
1. Check if the test server is properly initialized:
```typescript
beforeAll(async () => {
  await setupTestServer();
});
```

2. Verify the route handler exists in src/api/users.ts:
```typescript
app.get('/users/:id', async (req, res) => {
  const user = await getUserById(req.params.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json(user);
});
```

**Locations to check**:
- src/api/__tests__/users.test.ts:75-82 (test setup)
- src/api/users.ts (route implementation)

---

### 3. Password hashing should use proper salt rounds
**File**: src/auth/__tests__/password.test.ts:15
**Test**: describe > Password hashing > should use proper salt rounds

**Error**:
```
AssertionError: expected 10 to be 12

Expected: 12
Received: 10
```

**Test Code**:
```typescript
it('should use proper salt rounds', () => {
  const saltRounds = getSaltRounds();
  expect(saltRounds).toBe(12);  // Line 15
});
```

**Failure Reason**: The application is using 10 salt rounds instead of the expected 12

**Suggested Fix**:
Update the salt rounds configuration in src/auth/password.ts:

```typescript
// Current:
const SALT_ROUNDS = 10;

// Suggested (more secure):
const SALT_ROUNDS = 12;

// Or use environment variable with fallback:
const SALT_ROUNDS = parseInt(process.env.BCRYPT_ROUNDS || '12', 10);
```

**Note**: Higher salt rounds = more secure but slower. 12 is a good balance for 2024.

**Location to fix**: src/auth/password.ts:3

---

## Test Suites Status
✓ src/utils/__tests__/math.test.ts (8 tests)
✓ src/helpers/__tests__/format.test.ts (4 tests)
✗ src/validators/__tests__/user.test.ts (1 failed, 2 passed)
✗ src/api/__tests__/users.test.ts (1 failed, 2 passed)
✗ src/auth/__tests__/password.test.ts (1 failed, 0 passed)

## Detected Setup
- Framework: Jest
- Command used: `npm test`
- Configuration: jest.config.js

## Next Steps
1. Fix email validation regex in src/validators/user.ts
2. Check test server setup and route implementation in src/api/users.ts
3. Update salt rounds configuration in src/auth/password.ts
4. Run `/autotest` again to verify fixes

Would you like me to help fix any of these issues?
```
