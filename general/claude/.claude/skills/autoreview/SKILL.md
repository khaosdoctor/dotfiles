---
disable-model-invocation: false
user-invocable: true
allowed-tools:
  # Note: Read, Glob, Grep are ALWAYS implicitly allowed (global guideline)
  - Bash:
      - npm audit
      - npm run
      - yarn audit
      - pnpm audit
      - cargo audit
      - pip-audit
      - bundle audit
      - go list
      - git diff
      - git status
---

# Autoreview Skill

Comprehensive pre-commit code quality and security review.

## Purpose

Perform thorough analysis of code changes before commits or pull requests, checking for security vulnerabilities, code quality issues, best practices violations, and potential bugs.

## When to Use

- Before creating pull requests
- After implementing new features
- During code cleanup or refactoring
- When reviewing security-sensitive changes
- Before major releases

## Review Categories

### 1. Security Analysis

**OWASP Top 10 Vulnerabilities**:
- SQL Injection (parameterized queries, ORM usage)
- XSS (Cross-Site Scripting) - input sanitization, output encoding
- CSRF (Cross-Site Request Forgery) - token validation
- Authentication issues (password storage, session management)
- Authorization flaws (access control, privilege escalation)
- Security misconfiguration (default credentials, debug mode)
- Sensitive data exposure (hardcoded secrets, API keys)
- Insecure deserialization
- Using components with known vulnerabilities
- Insufficient logging and monitoring

**Common Security Issues**:
- Hardcoded credentials, API keys, tokens
- Unsafe function usage (eval, exec, system calls)
- Path traversal vulnerabilities
- Command injection risks
- Insecure random number generation
- Missing input validation
- Insecure cryptographic practices
- Missing rate limiting
- Insufficient error handling revealing sensitive info

### 2. Code Quality

**IMPORTANT: Test files are EXCLUDED from complexity and code quality checks.**

Test files are identified by:
- Files in `__tests__/`, `test/`, `tests/` directories
- Files ending with `.test.ts`, `.test.js`, `.spec.ts`, `.spec.js`, `.test.tsx`, `.spec.tsx`
- Files in directories named `e2e/`, `integration/`, `unit/`

**Complexity** (NOT checked in test files):
- High cyclomatic complexity (nested loops, many branches)
- Long functions/methods (>50 lines)
- Deep nesting levels (>3-4 levels)
- Large classes (>500 lines)

**Code Smells**:
- Code duplication (DRY violations)
- Dead code (unused functions, variables)
- Magic numbers and strings
- Poor naming conventions
- Inconsistent formatting
- Missing error handling
- Resource leaks (unclosed files, connections)
- Race conditions and concurrency issues

**Best Practices**:
- SOLID principles adherence
- Separation of concerns
- Single responsibility
- Proper abstraction levels
- Consistent error handling patterns
- Appropriate use of design patterns

### 3. Performance Concerns

- N+1 query problems
- Unnecessary loops or iterations
- Inefficient algorithms (O(n²) where O(n) possible)
- Memory leaks (event listeners, timers, references)
- Blocking operations on main thread
- Large bundle sizes
- Missing caching opportunities
- Inefficient database indexes

### 4. Testing & Coverage

- Missing test cases for new features
- Untested error paths
- Missing edge case tests
- Low test coverage for critical paths
- Missing integration tests
- Flaky test patterns

### 5. Documentation

- Missing function/method documentation
- Unclear variable names
- Complex logic without comments
- Outdated documentation
- Missing API documentation
- Unclear error messages

## Technology Preferences

### Validation Libraries
- **Prefer**: Zod
- **Avoid**: Joi, Yup

### ORMs and Query Builders
- **Prefer**: Drizzle ORM, Mikro-ORM
- **Avoid**: Prisma, TypeORM

When suggesting fixes, always use the preferred technologies.

## Execution Steps

1. **Detect Project Type**:
   - Check for `package.json` (Node.js/JavaScript)
   - Check for `Cargo.toml` (Rust)
   - Check for `go.mod` (Go)
   - Check for `requirements.txt` or `pyproject.toml` (Python)
   - Check for `Gemfile` (Ruby)
   - Check for `composer.json` (PHP)

2. **Run Security Scanners** (if available):
   - npm: `npm audit` or `npm run security` if defined
   - Rust: `cargo audit`
   - Python: `pip-audit` or `safety check`
   - Ruby: `bundle audit`
   - Go: Check `go.sum` for known vulnerabilities

3. **Analyze Changed Files**:
   - Run `git diff` to see changes
   - Focus on modified and new files
   - **Identify and exclude test files** from complexity checks

4. **Review Code Patterns**:
   - Search for dangerous functions (eval, exec, etc.)
   - Check for hardcoded secrets (API keys, passwords)
   - Analyze SQL queries for injection risks
   - Check user input handling
   - Review authentication/authorization logic

5. **Check Code Quality** (excluding test files):
   - Measure function lengths
   - Identify code duplication
   - Check naming conventions
   - Review error handling patterns

6. **Generate Report**:
   - Categorize findings by severity (Critical, High, Medium, Low)
   - Include file:line references for each issue
   - Provide specific code examples
   - Suggest concrete fixes with code snippets using preferred technologies
   - Prioritize issues
   - Note which test files were reviewed but excluded from complexity checks

## Report Format

```markdown
# Code Review Report

## Summary
- Total Issues: X
- Critical: X
- High: X
- Medium: X
- Low: X

## Critical Issues

### 1. [Issue Type] in file.ts:42
**Severity**: Critical
**Description**: Brief description of the issue

**Current Code**:
```language
// problematic code
```

**Suggested Fix**:
```language
// fixed code using preferred technologies
```

**Rationale**: Why this is a problem and why the fix works

---

## High Priority Issues
[Same format as above]

## Medium Priority Issues
[Same format as above]

## Low Priority Issues
[Same format as above]

## Test Files Reviewed (No Complexity Issues)
List test files that were reviewed but excluded from complexity checks

## Recommendations
- General suggestions for improving code quality
- Long-term improvements to consider
```

## Important Notes

- This skill uses AI reasoning for comprehensive analysis
- NEVER apply fixes automatically - always suggest and ask for permission
- Focus on actionable feedback with specific file:line references
- Prioritize security issues over style issues
- Be thorough but pragmatic - focus on real risks
- Include code examples in suggestions using preferred technologies (Zod, Drizzle, Mikro-ORM)
- Consider project context and conventions
- **Exclude test files from complexity and code quality checks**
- If no issues found, provide positive confirmation

## Safety Guidelines

- Never modify files without explicit user permission
- Never run destructive commands
- Never push to remote repositories
- Only use read-only analysis tools
- Always provide clear rationale for findings
