# Example: Tracing Execution Path

## Scenario
Understanding how a complex feature works by tracing the execution path from entry point to completion.

## Request
```
Trace the execution path for creating a new blog post from the API endpoint to database insertion
```

## Expected Output

```markdown
# Execution Trace: Blog Post Creation

Tracing the complete flow from HTTP request to database persistence.

## Entry Point
📍 **src/api/routes/posts.ts:34**
```typescript
router.post('/posts', authMiddleware, createPostHandler);
```

## Flow Diagram

```
HTTP POST /api/posts
    ↓
Auth Middleware
    ↓
Validation
    ↓
Business Logic
    ↓
Database Transaction
    ↓
Side Effects (Search Index, Cache)
    ↓
HTTP Response
```

## Detailed Execution Steps

### Step 1: Request Reception
📍 **src/api/routes/posts.ts:34**

```typescript
router.post('/posts', authMiddleware, createPostHandler);
```

**What happens**:
- Express receives POST request to `/api/posts`
- Request body contains: `{ title, content, tags, published }`
- Middleware chain begins execution

---

### Step 2: Authentication Middleware
📍 **src/middleware/auth.ts:12-45**

```typescript
export async function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await getUserById(decoded.userId);
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

**What happens**:
1. Extracts JWT token from Authorization header
2. Verifies token signature and expiration
3. Loads user data from database via `getUserById` (src/services/user-service.ts:89)
4. Attaches user object to `req.user`
5. Calls `next()` to continue to route handler

**Possible exit points**:
- ❌ No token → 401 Unauthorized
- ❌ Invalid token → 401 Unauthorized
- ✅ Valid token → Continue to Step 3

---

### Step 3: Route Handler - Input Validation
📍 **src/api/handlers/posts.ts:23-78**

```typescript
export async function createPostHandler(req, res) {
  try {
    // Validate input
    const postData = validatePostInput(req.body);
    // ...
  }
}
```

Calls → **src/validators/post.ts:15-42**

```typescript
import { z } from 'zod';

const postInputSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1),
  tags: z.array(z.string()).max(10).optional(),
  published: z.boolean().default(false)
});

export function validatePostInput(data: unknown) {
  return postInputSchema.parse(data);
}
```

**What happens**:
1. Uses Zod schema to validate request body
2. Checks title length (1-200 chars)
3. Checks content is not empty
4. Validates tags array (max 10 items)
5. Defaults `published` to false if not provided
6. Returns validated and typed data

**Possible exit points**:
- ❌ Validation fails → Throws ZodError → 400 Bad Request
- ✅ Validation passes → Continue to Step 4

---

### Step 4: Business Logic - Post Service
📍 **src/api/handlers/posts.ts:35** → **src/services/post-service.ts:67-124**

```typescript
const post = await postService.createPost({
  ...postData,
  authorId: req.user.id
});
```

Inside **src/services/post-service.ts:67**:

```typescript
export async function createPost(data: PostInput): Promise<Post> {
  // Generate slug from title
  const slug = slugify(data.title);

  // Check for duplicate slug
  const existing = await getPostBySlug(slug);
  if (existing) {
    throw new Error('Post with this title already exists');
  }

  // Sanitize content (XSS prevention)
  const sanitizedContent = sanitizeHtml(data.content);

  // Create post in database
  const post = await db.transaction(async (tx) => {
    // Insert post
    const [newPost] = await tx.insert(posts).values({
      title: data.title,
      slug,
      content: sanitizedContent,
      authorId: data.authorId,
      published: data.published,
      createdAt: new Date()
    }).returning();

    // Insert tags if provided
    if (data.tags?.length) {
      await tx.insert(postTags).values(
        data.tags.map(tag => ({
          postId: newPost.id,
          tag: tag.toLowerCase()
        }))
      );
    }

    return newPost;
  });

  return post;
}
```

**What happens**:
1. **Slug generation** (src/utils/slugify.ts:8)
   - Converts title to URL-friendly slug
   - "Hello World!" → "hello-world"

2. **Duplicate check** (src/db/queries/posts.ts:45)
   - Queries database for existing post with same slug
   - Throws error if found

3. **Content sanitization** (src/utils/sanitize.ts:12)
   - Removes dangerous HTML/JavaScript
   - Prevents XSS attacks

4. **Database transaction begins**
   - Ensures atomicity (all or nothing)

5. **Post insertion** (src/db/queries/posts.ts:89)
   - Inserts into `posts` table
   - Returns new post with generated ID

6. **Tag insertion** (src/db/queries/posts.ts:102)
   - Inserts tags into `post_tags` junction table
   - Normalized to lowercase
   - Only if tags provided

7. **Transaction commits**
   - Both insert queries succeed together

**Possible exit points**:
- ❌ Duplicate slug → Error → 409 Conflict
- ❌ Database error → Error → 500 Internal Server Error
- ✅ Success → Continue to Step 5

---

### Step 5: Side Effects - Async Operations
📍 **src/services/post-service.ts:108-115**

```typescript
// Update search index (non-blocking)
searchService.indexPost(post).catch(console.error);

// Clear cache (non-blocking)
cacheService.invalidate(`posts:*`).catch(console.error);

// Notify subscribers (non-blocking)
if (post.published) {
  notificationService.notifyNewPost(post).catch(console.error);
}
```

**What happens** (async, doesn't block response):

1. **Search indexing** → **src/services/search-service.ts:34**
   - Adds post to Elasticsearch/search index
   - Enables full-text search
   - Happens in background

2. **Cache invalidation** → **src/services/cache-service.ts:67**
   - Clears Redis cache for post lists
   - Ensures fresh data on next request

3. **Notifications** (if published) → **src/services/notification-service.ts:89**
   - Sends email to subscribers
   - Creates in-app notifications
   - Queued via job system (Redis/Bull)

**Note**: These operations don't affect the HTTP response. Errors are logged but don't fail the request.

---

### Step 6: Response
📍 **src/api/handlers/posts.ts:42**

```typescript
res.status(201).json({
  success: true,
  post: {
    id: post.id,
    title: post.title,
    slug: post.slug,
    published: post.published,
    createdAt: post.createdAt,
    author: {
      id: req.user.id,
      name: req.user.name
    }
  }
});
```

**What happens**:
- Returns HTTP 201 Created
- Sends sanitized post data (no sensitive fields)
- Includes author information
- Client receives confirmation

---

## Data Transformations

### Input (HTTP Request Body)
```json
{
  "title": "Hello World!",
  "content": "<p>This is my first post</p>",
  "tags": ["Welcome", "Intro"],
  "published": true
}
```

### After Validation
```typescript
{
  title: "Hello World!",
  content: "<p>This is my first post</p>",
  tags: ["Welcome", "Intro"],
  published: true
}
```

### After Processing
```typescript
{
  title: "Hello World!",
  slug: "hello-world",
  content: "<p>This is my first post</p>", // sanitized
  authorId: 42,
  published: true,
  tags: ["welcome", "intro"] // lowercase
}
```

### Database Record
```sql
-- posts table
id: 123
title: "Hello World!"
slug: "hello-world"
content: "<p>This is my first post</p>"
author_id: 42
published: true
created_at: "2024-01-15T10:30:00Z"

-- post_tags table
post_id: 123, tag: "welcome"
post_id: 123, tag: "intro"
```

### HTTP Response
```json
{
  "success": true,
  "post": {
    "id": 123,
    "title": "Hello World!",
    "slug": "hello-world",
    "published": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "author": {
      "id": 42,
      "name": "John Doe"
    }
  }
}
```

---

## Files Involved

1. **src/api/routes/posts.ts** - Route definition
2. **src/middleware/auth.ts** - Authentication
3. **src/api/handlers/posts.ts** - Request handler
4. **src/validators/post.ts** - Input validation
5. **src/services/post-service.ts** - Business logic
6. **src/utils/slugify.ts** - Slug generation
7. **src/utils/sanitize.ts** - HTML sanitization
8. **src/db/queries/posts.ts** - Database operations
9. **src/services/search-service.ts** - Search indexing
10. **src/services/cache-service.ts** - Cache management
11. **src/services/notification-service.ts** - Notifications

---

## External Dependencies

- **PostgreSQL** - Main database storage
- **Redis** - Caching and job queue
- **Elasticsearch** (optional) - Full-text search
- **Email service** (optional) - Notification delivery

---

## Performance Characteristics

- **Average response time**: ~150-250ms
- **Database queries**: 3 (user lookup, slug check, post insert + tags)
- **Transaction**: Yes (ensures data consistency)
- **Blocking operations**: Validation, database writes
- **Non-blocking**: Search indexing, cache updates, notifications

---

## Security Measures

✓ Authentication required (JWT)
✓ Input validation (Zod)
✓ XSS prevention (content sanitization)
✓ SQL injection prevention (Drizzle ORM with parameterized queries)
✓ Database transactions (data consistency)
✓ Error handling (doesn't expose internals)

---

## Error Handling

### Client Errors (4xx)
- **401**: No token or invalid token → auth middleware
- **400**: Invalid input → validation
- **409**: Duplicate slug → business logic

### Server Errors (5xx)
- **500**: Database errors, unexpected exceptions

### Error Response Format
```json
{
  "error": "User-friendly message",
  "details": {} // Only in development
}
```

---

## Testing Recommendations

### Unit Tests
```typescript
// Test slug generation
describe('slugify', () => {
  it('should convert title to slug', () => {
    expect(slugify('Hello World!')).toBe('hello-world');
  });
});

// Test validation
describe('validatePostInput', () => {
  it('should reject empty title', () => {
    expect(() => validatePostInput({ title: '' }))
      .toThrow();
  });
});
```

### Integration Tests
```typescript
describe('POST /api/posts', () => {
  it('should create post with valid data', async () => {
    const response = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${token}`)
      .send(validPostData);

    expect(response.status).toBe(201);
    expect(response.body.post.id).toBeDefined();
  });
});
```
```
