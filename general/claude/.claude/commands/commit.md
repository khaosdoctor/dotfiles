---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Create a new git commit
---
# Create a Git Commit

## Overview
Automate the creation of well-structured commits by analyzing code changes and following established conventions.

## Process

### 1. Analyze Code Changes
- **Review the git diff** to understand the scope and nature of changes
- **Identify affected components/packages** in the codebase
- **Assess the impact** (breaking changes, new features, bug fixes, etc.)
- **Categorize changes** by functionality or package for logical grouping

### 2. Create Structured Commits
- **Use conventional commit format**: `type(scope): description`
  - **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
  - **Scope**: package name (for monorepos) or component/module affected.
  - **Description**: concise one line summary in imperative mood. Do not add any message about the use of AI to generate the commit's message

- **For monorepos**: 
  - Separate commits by package when changes span multiple packages
  - Use package name as scope: `feat(workflow): add new step validation`
  - Include context in commit body if needed for complex changes

- **Multi-commit strategy**: Group related changes logically
  - Separate by functionality, not just by file
  - Each commit should be a coherent, testable unit
  - Avoid mixing refactoring with feature changes

## Best Practices
- **Keep commits atomic**: Each commit should represent one logical change
- **Write for reviewers**: Assume they need context about the changes
- **Be specific**: Avoid vague descriptions like "fix bugs" or "update code"
- **Reference issues**: Link to tickets, requirements, or discussions when relevant

## Example Outputs

feat(workflow): implement parallel step execution
fix(api): resolve race condition in task processing  
docs(application): update component usage examples
