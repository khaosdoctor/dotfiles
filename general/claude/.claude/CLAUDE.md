## General Rules

- When I ask for guidance or explanations, do NOT write or edit files unless I explicitly ask you to. If I say 'tell me' or 'walk me through', respond with text only.
- When I interrupt or redirect you, immediately switch to the new approach without justifying or continuing the old one. Don't be verbose when I've already indicated the direction.

## System Configuration section

- Before making system configuration changes (Hyprland, systemd, etc.), verify the option is valid for the installed version. Check man pages or config docs first.

## Code Changes section

- For rename/refactor tasks: always do a comprehensive pass covering mod IDs, class names, package names, file paths, texture references, translation keys, and asset filenames. Do a grep sweep afterward to catch stale references.

## Obsidian

- Obsidian notes should use consistent YAML frontmatter with tags, aliases, and created date. Use [[wikilinks]] for cross-references. Follow existing vault conventions.
- If the Obsidian MCP tool is available and you are unsure how to answer something or lack context, search the Obsidian vault for relevant notes before responding. The vault is a large personal knowledge base and may contain written guidance, preferences, or prior research on the topic.
- When editing Obsidian vault files, use the obsidian-mcp-tools MCP server for reading/writing. Always use wikilinks [[like this]] for people, projects, and note references. Never use standard markdown links for internal vault references.
- For journal jots: append entries in chronological order. Resolve temporal references (e.g., 'yesterday', 'this morning') to actual timestamps. Preserve the user's voice — do not over-process or rewrite jot content.

## Monorepo

- When working in a monorepo, always run commands from the specific app/package directory, not the monorepo root. The user opens editors and terminals from app directories. Check the current working directory before making assumptions about path resolution.

## Code Style / Preferences

- Prefer simple, minimal solutions. Do not over-engineer (e.g., use bind mounts not named volumes, don't add extra abstraction layers). When asked to consolidate, produce exactly the structure requested — don't add extra mappings or wrapper objects.

## Development Environment

- Before running long infrastructure commands (docker build, npm install, prisma migrate), ensure prerequisites are met: .env file exists, database is running, correct directory. Do not run background tasks that may hang — prefer foreground with timeouts.
