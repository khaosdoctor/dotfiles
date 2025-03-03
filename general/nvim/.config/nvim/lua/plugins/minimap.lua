return {
  "Isrothy/neominimap.nvim",
  lazy = false,
  keys = {
    -- Global Minimap Controls
    { "<leader>cnm", "<cmd>Neominimap toggle<cr>", desc = "Toggle global minimap" },
    { "<leader>cno", "<cmd>Neominimap on<cr>", desc = "Enable global minimap" },
    { "<leader>cnc", "<cmd>Neominimap off<cr>", desc = "Disable global minimap" },
    { "<leader>cnr", "<cmd>Neominimap refresh<cr>", desc = "Refresh global minimap" },

    -- Window-Specific Minimap Controls
    { "<leader>cnwt", "<cmd>Neominimap winToggle<cr>", desc = "Toggle minimap for current window" },
    { "<leader>cnwr", "<cmd>Neominimap winRefresh<cr>", desc = "Refresh minimap for current window" },
    { "<leader>cnwo", "<cmd>Neominimap winOn<cr>", desc = "Enable minimap for current window" },
    { "<leader>cnwc", "<cmd>Neominimap winOff<cr>", desc = "Disable minimap for current window" },

    -- Tab-Specific Minimap Controls
    { "<leader>cntt", "<cmd>Neominimap tabToggle<cr>", desc = "Toggle minimap for current tab" },
    { "<leader>cntr", "<cmd>Neominimap tabRefresh<cr>", desc = "Refresh minimap for current tab" },
    { "<leader>cnto", "<cmd>Neominimap tabOn<cr>", desc = "Enable minimap for current tab" },
    { "<leader>cntc", "<cmd>Neominimap tabOff<cr>", desc = "Disable minimap for current tab" },

    -- Buffer-Specific Minimap Controls
    { "<leader>cnbt", "<cmd>Neominimap bufToggle<cr>", desc = "Toggle minimap for current buffer" },
    { "<leader>cnbr", "<cmd>Neominimap bufRefresh<cr>", desc = "Refresh minimap for current buffer" },
    { "<leader>cnbo", "<cmd>Neominimap bufOn<cr>", desc = "Enable minimap for current buffer" },
    { "<leader>cnbc", "<cmd>Neominimap bufOff<cr>", desc = "Disable minimap for current buffer" },

    ---Focus Controls
    { "<leader>cnf", "<cmd>Neominimap focus<cr>", desc = "Focus on minimap" },
    { "<leader>cnu", "<cmd>Neominimap unfocus<cr>", desc = "Unfocus minimap" },
    { "<leader>cns", "<cmd>Neominimap toggleFocus<cr>", desc = "Switch focus on minimap" },
  },
  init = function()
    -- The following options are recommended when layout == "float"
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 26 -- Set a large value

    --- Put your configuration here
    ---@type Neominimap.UserConfig
    -- https://github.com/Isrothy/neominimap.nvim#configuration
    vim.g.neominimap = {
      auto_enable = true,
      layout = "float",
      delay = 500,
      diagnostic = {
        enabled = false,
      },
      click = {
        enabled = true,
        auto_switch_focus = true,
      },
      split = {
        fix_width = true,
        close_if_last_window = true,
      },
      float = {
        max_minimap_height = 100,
        margin = {
          right = 1,
          top = 1,
          bottom = 1,
        },
      },
    }
  end,
}
