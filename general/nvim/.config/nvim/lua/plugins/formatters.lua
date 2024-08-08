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
      bash = { "shfmt" },
      shell = { "shfmt" },
      lua = { "stylua" },
      python = { "ruff" },
      go = { "gofmt" },
    },
  },
}
