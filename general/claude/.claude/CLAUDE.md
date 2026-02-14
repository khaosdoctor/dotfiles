## General Rules

- When I ask for guidance or explanations, do NOT write or edit files unless I explicitly ask you to. If I say 'tell me' or 'walk me through', respond with text only.
- When I interrupt or redirect you, immediately switch to the new approach without justifying or continuing the old one. Don't be verbose when I've already indicated the direction.

## System Configuration section

- Before making system configuration changes (Hyprland, systemd, etc.), verify the option is valid for the installed version. Check man pages or config docs first.

## Code Changes section

- For rename/refactor tasks: always do a comprehensive pass covering mod IDs, class names, package names, file paths, texture references, translation keys, and asset filenames. Do a grep sweep afterward to catch stale references.

## Obsidian 

- Obsidian notes should use consistent YAML frontmatter with tags, aliases, and created date. Use [[wikilinks]] for cross-references. Follow existing vault conventions.
