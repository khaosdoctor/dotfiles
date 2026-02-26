return {
  "mfussenegger/nvim-lint",
  event = "LazyFile",
  opts = function(_, opts)
    opts.linters_by_ft = opts.linters_by_ft or {}
    opts.linters_by_ft.fish = { "fish" }
    opts.linters_by_ft.rust = { "bacon" }
    opts.linters_by_ft.protobuf = { "buf" }
    opts.linters_by_ft.javascript = { "biome", "eslint" }
    opts.linters_by_ft.typescript = { "biome", "eslint" }
    opts.linters_by_ft.lua = { "luacheck" }
    opts.linters_by_ft.yaml = { "yamllint" }
    opts.linters_by_ft.json = { "jsonlint" }
    opts.linters_by_ft.c = { "cpplint" }
    opts.linters_by_ft.cpp = { "cpplint" }

    -- Custom biome linter: nvim-lint's built-in ("biomejs") parses plain-text output
    -- with fragile regex, only catches errors (misses warnings/infos), and has no
    -- severity mapping. This replaces it with a JSON reporter parser that handles
    -- all severity levels and both old (span/byte-offset) and new (start/end line+col)
    -- biome output formats.
    opts.linters = opts.linters or {}
    local lint = require("lint")

    opts.linters.biome = {
      cmd = "biome",
      stdin = false,
      args = {
        "lint",
        "--reporter=json",
      },
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diagnostics = {}
        local ok, decoded = pcall(vim.json.decode, output)
        if not ok or not decoded or not decoded.diagnostics then
          return diagnostics
        end

        local severity_map = {
          error = vim.diagnostic.severity.ERROR,
          warning = vim.diagnostic.severity.WARN,
          information = vim.diagnostic.severity.INFO,
          hint = vim.diagnostic.severity.HINT,
        }

        for _, diag in ipairs(decoded.diagnostics) do
          local loc = diag.location
          if loc then
            local lnum, col, end_lnum, end_col
            if loc.start then
              -- New biome format: location.start/end with line/column (1-indexed)
              lnum = (loc.start.line or 1) - 1
              col = (loc.start.column or 1) - 1
              end_lnum = loc["end"] and (loc["end"].line or 1) - 1 or lnum
              end_col = loc["end"] and (loc["end"].column or 1) - 1 or col
            elseif loc.span then
              -- Old biome format: location.span with byte offsets (line unknown, use 0)
              lnum = 0
              col = loc.span.start or 0
              end_lnum = 0
              end_col = loc.span["end"] or col
            else
              -- No position info; still surface the diagnostic at top of file
              lnum, col, end_lnum, end_col = 0, 0, 0, 0
            end

            table.insert(diagnostics, {
              lnum = lnum,
              col = col,
              end_lnum = end_lnum,
              end_col = end_col,
              severity = severity_map[diag.severity] or vim.diagnostic.severity.WARN,
              message = diag.description or diag.message or "Biome lint error",
              source = "biome",
            })
          end
        end

        return diagnostics
      end,
      condition = function(ctx)
        -- Check for local biome first (node_modules/.bin)
        local local_biome = vim.fn.findfile("node_modules/.bin/biome", ".;")
        if local_biome ~= "" then
          return true
        end
        -- Check for global biome
        return vim.fn.executable("biome") == 1
      end,
    }

    -- Extend the eslint linter with custom condition
    if lint.linters.eslint then
      opts.linters.eslint = vim.tbl_extend("force", lint.linters.eslint, {
        condition = function(ctx)
          -- Only use eslint if biome is not available
          local local_biome = vim.fn.findfile("node_modules/.bin/biome", ".;")
          if local_biome ~= "" then
            return false
          end
          if vim.fn.executable("biome") == 1 then
            return false
          end

          -- Check for local eslint
          local local_eslint = vim.fn.findfile("node_modules/.bin/eslint", ".;")
          if local_eslint ~= "" then
            return true
          end
          -- Check for global eslint
          return vim.fn.executable("eslint") == 1
        end,
      })
    end

    return opts
  end,
}
