---
disable-model-invocation: false
user-invocable: false
allowed-tools:
  # Note: Read, Glob, Grep are ALWAYS implicitly allowed (global guideline)
  - Bash:
      - tree
      - find
      - wc
      - cloc
      - git log
      - git blame
---

# Explain Skill

Deep code analysis and explanation for understanding complex codebases, algorithms, and architectural patterns.

## Purpose

Provide comprehensive explanations of code functionality, trace execution paths across files, document architectural decisions, and help developers understand complex systems.

## When to Use

- Onboarding new team members to a codebase
- Understanding legacy or undocumented code
- Debugging complex issues by tracing execution flow
- Learning how a feature is implemented
- Documenting architectural patterns
- Understanding dependencies between components
- Analyzing algorithm complexity
- Code review and knowledge sharing

## Capabilities

### 1. Execution Path Tracing
- Follow function calls across multiple files
- Trace data flow through the application
- Identify entry and exit points
- Map request/response cycles
- Show call hierarchies and sequences

### 2. Algorithm Explanation
- Explain algorithm logic step-by-step
- Analyze time and space complexity
- Identify optimization opportunities
- Compare with alternative approaches
- Explain data structure choices

### 3. Architecture Documentation
- Describe high-level system architecture
- Explain design patterns used
- Document component relationships
- Identify architectural layers
- Map dependencies between modules

### 4. Code Analysis
- Explain complex conditional logic
- Document side effects and state changes
- Identify external dependencies
- Trace error handling paths
- Explain asynchronous flows

### 5. Dependency Mapping
- Show how components depend on each other
- Identify circular dependencies
- Map import/export relationships
- Find unused code
- Visualize module structure

## Usage Patterns

### Explain a specific function
```
Explain how the `authenticateUser` function works
```

### Trace execution path
```
Trace the execution path from HTTP request to database query in the user creation endpoint
```

### Understand architecture
```
Explain the architecture of the authentication system
```

### Analyze algorithm
```
Explain the search algorithm in src/utils/search.ts and its complexity
```

### Document feature
```
Explain how the payment processing feature works end-to-end
```

## Output Format

### Function Explanation
```markdown
# Function: authenticateUser

**Location**: src/auth/authenticate.ts:42-89
**Purpose**: Validates user credentials and creates a session

## Signature
```typescript
async function authenticateUser(
  email: string,
  password: string
): Promise<SessionToken>
```

## Execution Flow

1. **Input Validation** (lines 44-48)
   - Validates email format using Zod schema
   - Checks password length requirements
   - Throws `ValidationError` if invalid

2. **User Lookup** (lines 50-54)
   - Queries database for user by email
   - Uses Drizzle ORM with prepared statement
   - Returns early with `UserNotFoundError` if no match

3. **Password Verification** (lines 56-60)
   - Compares provided password with stored hash
   - Uses bcrypt.compare with constant-time comparison
   - Throws `InvalidCredentialsError` on mismatch

4. **Session Creation** (lines 62-75)
   - Generates cryptographically secure session token
   - Stores session in Redis with 24h TTL
   - Updates user's last_login timestamp
   - Returns SessionToken object

5. **Error Handling** (lines 77-88)
   - Catches database errors → `DatabaseError`
   - Catches Redis errors → `SessionCreationError`
   - Logs all errors with correlation ID
   - Never exposes internal details to client

## Dependencies

**Direct imports**:
- `@/db/schema` (User model)
- `bcrypt` (password hashing)
- `@/cache/redis` (session storage)
- `zod` (validation)

**External services**:
- PostgreSQL database (via Drizzle)
- Redis cache (session store)

## Side Effects
- Database write: Updates `users.last_login`
- Cache write: Creates session in Redis
- Logging: Writes to application logs

## Security Considerations
- Uses parameterized queries (SQL injection prevention)
- Constant-time password comparison (timing attack prevention)
- Cryptographically secure token generation
- No sensitive data in error messages
- Rate limiting should be applied at API layer

## Error Paths
```typescript
throw new ValidationError()        // Invalid input
throw new UserNotFoundError()      // User doesn't exist
throw new InvalidCredentialsError() // Wrong password
throw new DatabaseError()          // DB connection issues
throw new SessionCreationError()   // Redis issues
```

## Example Usage
```typescript
try {
  const session = await authenticateUser(
    'user@example.com',
    'password123'
  );
  console.log('Authenticated:', session.token);
} catch (error) {
  if (error instanceof InvalidCredentialsError) {
    // Handle wrong credentials
  }
}
```

## Complexity Analysis
- Time: O(1) - Database indexed lookups, hash comparison
- Space: O(1) - Fixed size session token
- Network: 2 calls (DB + Redis)

## Potential Improvements
1. Consider adding 2FA support
2. Implement account lockout after failed attempts
3. Add session refresh token mechanism
4. Log suspicious login patterns
```

### Execution Path Trace
```markdown
# Execution Path: User Registration

Tracing from HTTP request → Database insertion

## Entry Point
**File**: src/api/routes/users.ts:23
**Handler**: POST /api/users

## Execution Steps

### 1. Request Reception
📍 src/api/routes/users.ts:23
```typescript
router.post('/users', async (req, res) => {
```
- Receives HTTP POST request
- Express middleware applied: [auth, validation, rateLimit]

↓

### 2. Input Validation
📍 src/api/routes/users.ts:24-28
```typescript
const userData = validateUserInput(req.body);
```
Calls → src/validators/user.ts:15

📍 src/validators/user.ts:15-42
- Uses Zod schema for validation
- Checks: email format, password strength, name length
- Sanitizes input to prevent XSS

↓

### 3. Business Logic
📍 src/services/user-service.ts:89
```typescript
const user = await createUser(userData);
```

📍 src/services/user-service.ts:89-124
- Checks if email already exists (line 92)
- Hashes password with bcrypt (line 98)
- Generates verification token (line 102)
- Prepares user object (line 107)

↓

### 4. Database Insertion
📍 src/services/user-service.ts:112
```typescript
const newUser = await db.insert(users).values(userData);
```

Calls → src/db/queries/users.ts:34

📍 src/db/queries/users.ts:34-45
- Uses Drizzle ORM prepared statement
- Transaction wraps insertion + audit log
- Returns user object with generated ID

↓

### 5. Side Effects
**Email Service** (line 118)
📍 src/services/email-service.ts:67
- Sends verification email asynchronously
- Uses job queue (doesn't block response)

**Audit Log** (line 119)
📍 src/services/audit-service.ts:23
- Records user creation event
- Includes IP, timestamp, user agent

↓

### 6. Response
📍 src/api/routes/users.ts:29
```typescript
res.status(201).json({ user, message: 'Created' });
```
- Returns 201 Created status
- Sends sanitized user object (no password)
- Includes verification instructions

## Data Flow

```
HTTP Request
  ↓ (body)
Validation
  ↓ (sanitized UserInput)
Business Logic
  ↓ (User object + hashed password)
Database
  ↓ (User with ID)
Side Effects (Email, Audit)
  ↓ (sanitized User)
HTTP Response
```

## Error Handling Points

1. **Validation failure** → 400 Bad Request
2. **Duplicate email** → 409 Conflict
3. **Database error** → 500 Internal Server Error
4. **Email service failure** → Logged but doesn't fail request

## Files Involved
1. src/api/routes/users.ts (entry point)
2. src/validators/user.ts (validation)
3. src/services/user-service.ts (business logic)
4. src/db/queries/users.ts (database)
5. src/services/email-service.ts (side effect)
6. src/services/audit-service.ts (logging)

## Performance Characteristics
- **Average response time**: ~150ms
- **Database queries**: 2 (check + insert)
- **Blocking operations**: Validation, hashing, DB writes
- **Non-blocking**: Email sending (queued)

## Security Measures
✓ Input validation (Zod)
✓ SQL injection prevention (parameterized queries)
✓ XSS prevention (input sanitization)
✓ Password hashing (bcrypt)
✓ Rate limiting (middleware)
✓ Audit logging
```

### Architecture Explanation
```markdown
# Architecture: Authentication System

## Overview
The authentication system follows a layered architecture with clear separation of concerns.

## Layer Structure

```
┌─────────────────────────────────────┐
│         API Layer                    │
│  (HTTP routes, middleware)          │
│  src/api/routes/auth.ts             │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│      Service Layer                   │
│  (Business logic, orchestration)    │
│  src/services/auth-service.ts       │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│       Data Layer                     │
│  (Database queries, caching)        │
│  src/db/queries/                    │
└─────────────────────────────────────┘
```

## Components

### 1. API Routes
**Location**: src/api/routes/auth.ts

**Responsibilities**:
- HTTP request/response handling
- Route definitions
- Middleware application
- Input/output formatting

**Key endpoints**:
- POST /auth/login
- POST /auth/logout
- POST /auth/refresh
- GET /auth/me

### 2. Authentication Service
**Location**: src/services/auth-service.ts

**Responsibilities**:
- Credential validation
- Token generation/verification
- Session management
- Business rules enforcement

**Key functions**:
- `authenticateUser()`
- `refreshToken()`
- `validateSession()`
- `revokeSession()`

### 3. Data Access
**Location**: src/db/queries/auth.ts

**Responsibilities**:
- Database queries
- Session storage (Redis)
- User lookup
- Transaction management

### 4. Middleware
**Location**: src/api/middleware/auth.ts

**Responsibilities**:
- Request authentication
- Token extraction
- Permission checking
- Rate limiting

## Design Patterns

### 1. Repository Pattern
- Abstracts data access behind interface
- Located in src/db/repositories/
- Allows easy testing with mocks

### 2. Dependency Injection
- Services receive dependencies via constructor
- Configured in src/di/container.ts
- Improves testability and flexibility

### 3. Strategy Pattern
- Multiple authentication strategies supported
- JWT tokens, OAuth, API keys
- Selected based on request type

## Data Flow

### Login Request
```
Client → API Route → Auth Middleware → Service → Repository → Database
                                                             → Redis
         ← Response ← Session Token ← ← ← ← ← ← ←
```

### Authenticated Request
```
Client → API Route → Auth Middleware
                      ├→ Validate Token (Redis)
                      └→ Load User (Cache/DB)
         → Protected Route Handler
         ← Response
```

## Security Layers

1. **Transport**: HTTPS only
2. **Rate Limiting**: Per IP and per user
3. **Input Validation**: Zod schemas
4. **Authentication**: JWT tokens with short TTL
5. **Authorization**: Role-based access control
6. **Audit**: All auth events logged
7. **Session**: Secure cookies, httpOnly, sameSite

## Dependencies

**External**:
- bcrypt (password hashing)
- jsonwebtoken (JWT handling)
- Redis (session storage)
- PostgreSQL (user data)

**Internal**:
- @/db/schema (data models)
- @/utils/crypto (token generation)
- @/config (configuration)

## Configuration
**Location**: src/config/auth.ts

```typescript
{
  jwtSecret: process.env.JWT_SECRET,
  tokenExpiry: '15m',
  refreshExpiry: '7d',
  saltRounds: 12,
  maxLoginAttempts: 5,
  lockoutDuration: '15m'
}
```

## Testing Strategy

### Unit Tests
- Service functions (isolated)
- Middleware logic
- Token generation/validation

### Integration Tests
- Full auth flow
- Database interactions
- Redis session management

### E2E Tests
- Login/logout flows
- Token refresh
- Permission checking

## Known Limitations
1. Single Redis instance (no failover)
2. Sessions not distributed across regions
3. No 2FA support yet

## Future Improvements
1. Add OAuth provider support
2. Implement 2FA/MFA
3. Add session analytics
4. Redis cluster for HA
5. Distributed session management
```

## Important Notes

- This skill uses AI reasoning for comprehensive analysis
- Always trace code paths with file:line references
- NEVER modify code or create documentation files without permission
- Provide only explanations and suggested documentation content
- Consider security implications in explanations
- Explain both "what" and "why" when analyzing code
- Include complexity analysis where relevant
- Suggest improvements but don't apply them

## Safety Guidelines

- Never modify files without explicit user permission
- Never create documentation files without asking
- Provide explanations as text output only
- Focus on understanding, not changing code
- Always include file:line references for traceability
