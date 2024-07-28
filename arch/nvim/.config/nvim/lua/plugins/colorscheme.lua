return {
  { "Mofiqul/dracula.nvim" },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "eldritch-theme/eldritch.nvim", lazy = false, priority = 1000, opts = {} },
  {
    "maxmx03/fluoromachine.nvim",
    lazy = false,
    priority = 1000,
    opts = { glow = false, theme = "fluoromachine", transparent = false },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "eldritch",
    },
  },
}
