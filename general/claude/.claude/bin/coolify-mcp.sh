#!/usr/bin/env bash
set -euo pipefail
export PATH="/home/khaosdoctor/.local/share/mise/installs/node/latest/bin:/usr/bin:/bin:${PATH:-}"

# Secrets go in env vars, not argv: argv is world-readable via ps, environ is owner-only.
# mcp-remote expands ${VAR} in header values itself, so the placeholders stay single-quoted.
COOLIFY_CF_ID=$(op read 'op://Private/Coolify MCP/CF ID')
COOLIFY_CF_SECRET=$(op read 'op://Private/Coolify MCP/CF Secret')
COOLIFY_TOKEN=$(op read 'op://Private/Claude Neumann Coolify MCP Token/password')
export COOLIFY_CF_ID COOLIFY_CF_SECRET COOLIFY_TOKEN

exec npx -y mcp-remote@0.1.38 https://cloud.lsantos.me/mcp \
    --header 'CF-Access-Client-Id: ${COOLIFY_CF_ID}' \
    --header 'CF-Access-Client-Secret: ${COOLIFY_CF_SECRET}' \
    --header 'Authorization: Bearer ${COOLIFY_TOKEN}'
