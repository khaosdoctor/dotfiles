# Example: Security Issues Review

## Scenario
Reviewing a Node.js API endpoint with multiple security vulnerabilities.

## Command
```bash
/autoreview
```

## Sample Code Being Reviewed

```javascript
// src/api/users.js
const express = require('express');
const router = express.Router();
const db = require('../db');

const API_KEY = 'sk_live_12345abcdef'; // Hardcoded API key

router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  // SQL Injection vulnerability
  const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
  const user = await db.query(query);

  if (user) {
    // Sensitive data exposure
    res.json({
      success: true,
      user: user,
      apiKey: API_KEY
    });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

router.get('/search', (req, res) => {
  const searchTerm = req.query.q;

  // XSS vulnerability - no sanitization
  res.send(`<h1>Results for: ${searchTerm}</h1>`);
});

module.exports = router;
```

## Expected Output

```markdown
# Code Review Report

## Summary
- Total Issues: 4
- Critical: 3
- High: 1
- Medium: 0
- Low: 0

## Critical Issues

### 1. SQL Injection in src/api/users.js:11
**Severity**: Critical
**Description**: Direct string concatenation in SQL query allows SQL injection attacks

**Current Code**:
```javascript
const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
const user = await db.query(query);
```

**Suggested Fix**:
```javascript
const query = 'SELECT * FROM users WHERE username = ? AND password = ?';
const user = await db.query(query, [username, password]);
// Or use an ORM like Drizzle or Mikro-ORM with parameterized queries
```

**Rationale**: Attacker can input `' OR '1'='1` to bypass authentication. Always use parameterized queries.

---

### 2. Hardcoded API Key in src/api/users.js:6
**Severity**: Critical
**Description**: API key hardcoded in source code and exposed in response

**Current Code**:
```javascript
const API_KEY = 'sk_live_12345abcdef';
// ... later ...
res.json({ apiKey: API_KEY });
```

**Suggested Fix**:
```javascript
// Use environment variables
const API_KEY = process.env.API_KEY;
// Never expose keys in responses
res.json({
  success: true,
  user: { id: user.id, username: user.username }
});
```

**Rationale**: Hardcoded secrets in code can be exposed via version control. API keys should never be sent to clients.

---

### 3. XSS Vulnerability in src/api/users.js:28
**Severity**: Critical
**Description**: User input directly embedded in HTML without sanitization

**Current Code**:
```javascript
res.send(`<h1>Results for: ${searchTerm}</h1>`);
```

**Suggested Fix**:
```javascript
const escapeHtml = (str) => {
  return str.replace(/[&<>"']/g, (char) => {
    const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
    return map[char];
  });
};
res.send(`<h1>Results for: ${escapeHtml(searchTerm)}</h1>`);
// Or better: use a template engine with auto-escaping
```

**Rationale**: Attacker can inject `<script>alert('XSS')</script>` to execute malicious JavaScript.

---

## High Priority Issues

### 4. Sensitive Data Exposure in src/api/users.js:17
**Severity**: High
**Description**: Full user object including password hash returned to client

**Current Code**:
```javascript
res.json({
  success: true,
  user: user  // Contains all fields including password
});
```

**Suggested Fix**:
```javascript
res.json({
  success: true,
  user: {
    id: user.id,
    username: user.username,
    email: user.email
    // Never include password, even if hashed
  }
});
```

**Rationale**: Exposing password hashes makes brute-force attacks easier. Only return necessary fields.

---

## Recommendations
- Implement input validation using Zod
- Use an ORM (Drizzle, Mikro-ORM) to prevent SQL injection by default
- Add rate limiting to prevent brute-force attacks
- Implement CSRF protection
- Use helmet middleware for security headers
- Add logging for security events
- Consider using JWT tokens instead of exposing sensitive data
```
