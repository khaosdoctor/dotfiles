return {
  { "Mofiqul/dracula.nvim" },
  {
    "catppuccin/nvim",
    opts = {
      flavour = "macchiato",
      highlight_overrides = {
        all = function(colors)
          return {
            CurSearch = { bg = colors.sky },
            IncSearch = { bg = colors.sky },
            CursorLineNr = { fg = colors.blue, style = { "bold" } },
            DashboardFooter = { fg = colors.overlay0 },
            TreesitterContextBottom = { style = {} },
            WinSeparator = { fg = colors.mauve, style = { "bold" } },
            ["@markup.italic"] = { fg = colors.blue, style = { "italic" } },
            ["@markup.strong"] = { fg = colors.blue, style = { "bold" } },
            Headline = { style = { "bold" } },
            Headline1 = { fg = colors.blue, style = { "bold" } },
            Headline2 = { fg = colors.pink, style = { "bold" } },
            Headline3 = { fg = colors.lavender, style = { "bold" } },
            Headline4 = { fg = colors.green, style = { "bold" } },
            Headline5 = { fg = colors.peach, style = { "bold" } },
            Headline6 = { fg = colors.flamingo, style = { "bold" } },
            rainbow1 = { fg = colors.blue, style = { "bold" } },
            rainbow2 = { fg = colors.pink, style = { "bold" } },
            rainbow3 = { fg = colors.lavender, style = { "bold" } },
            rainbow4 = { fg = colors.green, style = { "bold" } },
            rainbow5 = { fg = colors.peach, style = { "bold" } },
            rainbow6 = { fg = colors.flamingo, style = { "bold" } },
            NeoTreeCursorLine = { bg = colors.surface1 },
            NeoTreeNormal = { bg = colors.mantle },
          }
        end,
      },
      color_overrides = {
        macchiato = {
          rosewater = "#F5B8AB",
          flamingo = "#F29D9D",
          pink = "#FF8F40",
          mauve = "#AD7FFF",
          red = "#E66767",
          maroon = "#EB788B",
          peach = "#FAB770",
          yellow = "#FACA64",
          green = "#70CF67",
          teal = "#4CD4BD",
          sky = "#61BDFF",
          sapphire = "#4BA8FA",
          blue = "#00BFFF",
          lavender = "#00BBCC",
          text = "#ffffff",
          subtext1 = "#A3AAC2",
          subtext0 = "#8E94AB",
          overlay2 = "#7D8296",
          overlay1 = "#676B80",
          -- overlay0 = "#464957", -- comments
          overlay0 = "#757a92",
          surface2 = "#3A3D4A",
          -- surface1 = "#2F313D", -- line numbers, hovers, highlights
          surface1 = "#46495b",
          surface0 = "#1D1E29",
          base = "#030303",
          mantle = "#11111a",
          crust = "#191926",
        },
      },
      integrations = {
        neotree = true,
        telescope = {
          enabled = true,
          style = "nvchad",
        },
      },
    },
    name = "catppuccin",
    priority = 1000,
  },
  { "eldritch-theme/eldritch.nvim", lazy = false, priority = 1000, opts = {} },
  { "flazz/vim-colorschemes" },
  {
    "navarasu/onedark.nvim",
    config = function()
      require("onedark").setup({
        style = "light",
      })
    end,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
  },
  {
    "maxmx03/fluoromachine.nvim",
    lazy = false,
    priority = 1000,
    opts = { glow = false, theme = "fluoromachine", transparent = false },
  },
  {
    "shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
    config = function()
      local colors = require("ayu.colors")
      colors.generate(true)
      require("ayu").setup({
        mirage = true,
        terminal = true,
        overrides = {
          Visual = { bg = colors.accent, fg = colors.black }, -- Visual mode selections
          CursorLine = { bg = "#202020" }, -- cursor highlight for lines
          NeoTreeCursorLine = { bg = colors.accent, fg = colors.black }, -- neotree selection
          NonText = { fg = "#555555" }, -- Generic texts that are dimmed
          AlphaHeader = { fg = colors.accent }, -- dashboard
          AlphaButtons = { fg = colors.constant },
          InclineNormal = { bg = colors.accent, fg = colors.black }, -- top bar
          LineNr = { fg = colors.comment },
          WinSeparator = { fg = colors.accent, bg = "NONE" },
          CursorLineNr = { fg = colors.black, bg = colors.accent },
          ["@markup.italic"] = { fg = colors.entity, italic = true },
          ["@markup.strong"] = { fg = colors.error, bold = true },
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ayu-dark",
    },
  },
}
