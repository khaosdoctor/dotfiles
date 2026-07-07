#!/usr/bin/env bash
set -euo pipefail
export PATH="/home/khaosdoctor/.local/share/mise/installs/node/latest/bin:/usr/bin:/bin:${PATH:-}"

exec npx -y mcp-remote@0.1.38 https://cloud.lsantos.me/mcp \
    --header "CF-Access-Client-Id: $(op read 'op://Private/Coolify MCP/CF ID')" \
    --header "CF-Access-Client-Secret: $(op read 'op://Private/Coolify MCP/CF Secret')" \
    --header "Authorization: Bearer $(op read 'op://Private/Coolify MCP/password')"
