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

    -- Create custom biome linter (not built-in to nvim-lint)
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

        for _, diag in ipairs(decoded.diagnostics) do
          if diag.location then
            table.insert(diagnostics, {
              lnum = (diag.location.span.start or 0) - 1,
              col = 0,
              end_lnum = (diag.location.span["end"] or 0) - 1,
              end_col = 0,
              severity = vim.diagnostic.severity.WARN,
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
