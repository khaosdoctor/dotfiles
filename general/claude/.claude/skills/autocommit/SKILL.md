---
disable-model-invocation: true
allowed-tools:
  - Bash:
      - git status
      - git diff
      - git diff --staged
      - git log
      - git add
      - git add -p
      - git commit
      - git branch
      - git show
  - Read
  - Glob
  - Grep
---

# Autocommit Skill

Create git commits following strict conventional commit standards with granular change separation.

## Commit Guidelines

### Format Standards
- Use conventional commits format: `type(scope): description`
- Commit title MUST be less than 80 characters
- Commit message body MUST NOT exceed 280 characters total
- NEVER add co-authors (do not include "Co-Authored-By" lines)

### Conventional Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring without changing behavior
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependency updates, config changes
- `ci`: CI/CD configuration changes
- `build`: Build system or external dependency changes
- `revert`: Reverting previous commits

### Scopes
- For multi-project repositories, ALWAYS include a scope: `feat(api): add user endpoint`
- For single-project repos, scope is optional but recommended for clarity
- Scope should indicate the component, module, or area affected

### Commit Strategy

1. **Analyze Changes**: Run git status and git diff to understand all changes

2. **Detect Project Tools**: Look for:
   - `package.json` (npm/yarn/pnpm scripts: test, lint, format)
   - `Makefile` (make targets: test, lint, fmt)
   - `Magefile.go` (mage targets)
   - `Rakefile` (rake tasks)
   - `justfile` (just commands)
   - `pyproject.toml` or `setup.py` (python projects)
   - `Cargo.toml` (cargo commands)
   - `go.mod` (go commands)
   - Use these project-specific commands instead of running tools directly

3. **Categorize Changes**: Group changes by:
   - Linting/formatting changes (ALWAYS separate)
   - Feature additions
   - Bug fixes
   - Documentation
   - Configuration
   - Tests
   - Refactoring

4. **Granularity Rules**:
   - Split commits by logical change type
   - Never mix different types of changes in one commit
   - Use `git add -p` (hunks) to stage partial files when needed
   - Group related changes together (e.g., a feature + its tests can be one commit)
   - ALWAYS separate linting changes into their own commit

5. **Testing**: If repository has tests:
   - Use project scripts (npm test, make test, cargo test, etc.)
   - Run tests before each commit
   - Only commit if tests pass
   - If tests fail, fix issues before committing

6. **Linting**:
   - Use project scripts (npm run lint, make lint, cargo fmt, etc.)
   - If linting produces changes, commit them FIRST in a separate commit
   - Use commit type `style(scope): apply linting fixes`

7. **Safety**:
   - NEVER push to remote
   - NEVER force push
   - NEVER use --no-verify flag
   - NEVER run destructive git commands

## Execution Steps

1. Run `git status` to see all changes
2. Run `git diff` to understand changes in detail
3. Detect project structure (check for package.json, Makefile, etc.)
4. Check for linting scripts and run them using project commands
5. If linting changes exist, stage and commit them separately
6. Detect test scripts and run tests using project commands
7. Categorize remaining changes into logical groups
8. For each group:
   - Stage relevant files (use `git add -p` for partial changes if needed)
   - Write commit message following format rules
   - Verify message length constraints
   - Commit changes
9. Run `git status` after all commits to verify

## Example Commits

```
feat(api): add user authentication endpoint

Implement JWT-based authentication with refresh tokens.
Includes middleware for protected routes.
```

```
fix(database): resolve connection pool leak

Fixed unclosed connections in query handler that caused
memory growth over time.
```

```
style(frontend): apply prettier formatting
```

```
test(auth): add integration tests for login flow
```

## Notes
- Be thorough but efficient
- Prioritize clarity in commit messages
- Keep the commit history clean and meaningful
- Each commit should represent a single, complete change
- Always use project-defined scripts when available
