return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = false,
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      rust = { "rustfmt" },
      markdown = { "prettierd" },
      sh = { "shfmt" },
      lua = { "stylua" },
      python = { "ruff" },
      go = { "gofmt" },
    },
  },
}
