return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = false,
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
        markdown = { "prettierd" },
        javascript = { "biome", "prettierd", "prettier" },
        typescript = { "biome", "prettierd", "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        shell = { "shfmt" },
        lua = { "stylua" },
        python = { "ruff" },
        go = { "gofmt" },
      },
      formatters = {
        biome = {
          condition = function(self, ctx)
            -- Check for local biome first (node_modules/.bin)
            local local_biome = vim.fn.findfile("node_modules/.bin/biome", ".;")
            if local_biome ~= "" then
              return true
            end
            -- Check for global biome
            return vim.fn.executable("biome") == 1
          end,
        },
        prettierd = {
          condition = function(self, ctx)
            -- Only use prettierd if biome is not available
            local local_biome = vim.fn.findfile("node_modules/.bin/biome", ".;")
            if local_biome ~= "" then
              return false
            end
            if vim.fn.executable("biome") == 1 then
              return false
            end

            -- Check for local prettier (prettierd uses prettier)
            local local_prettier = vim.fn.findfile("node_modules/.bin/prettier", ".;")
            if local_prettier ~= "" then
              return true
            end
            -- Check for global prettierd
            return vim.fn.executable("prettierd") == 1
          end,
        },
        prettier = {
          condition = function(self, ctx)
            -- Only use prettier if biome and prettierd are not available
            local local_biome = vim.fn.findfile("node_modules/.bin/biome", ".;")
            if local_biome ~= "" then
              return false
            end
            if vim.fn.executable("biome") == 1 then
              return false
            end
            if vim.fn.executable("prettierd") == 1 then
              return false
            end

            -- Check for local prettier
            local local_prettier = vim.fn.findfile("node_modules/.bin/prettier", ".;")
            if local_prettier ~= "" then
              return true
            end
            -- Check for global prettier
            return vim.fn.executable("prettier") == 1
          end,
        },
      },
    },
  },
}
