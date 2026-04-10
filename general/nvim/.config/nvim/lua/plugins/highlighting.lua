return {
  { "isobit/vim-caddyfile" },
  {
    "brenoprata10/nvim-highlight-colors",
    opts = {
      render = "background",
      enable_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_ansi = true,
      enable_hsl_without_function = true,
      enable_var_usage = true,
      enable_named_colors = true,
      enable_tailwind = true,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "prisma" })
    end,
  },
}
