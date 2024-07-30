return {
  "b0o/incline.nvim",
  event = "BufReadPre",
  keys = {
    {
      "<leader>uI",
      function()
        require("incline").toggle()
      end,
      desc = "Toggle Incline",
    },
  },
  config = function()
    require("incline").setup({
      highlight = {
        groups = {
          InclineNormal = { default = true, group = "lualine_a_normal" },
          InclineNormalNC = { default = true, group = "Comment" },
        },
      },
      window = { margin = { vertical = 0, horizontal = 1 } },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        local icon, color = require("nvim-web-devicons").get_icon_color(filename)
        return { { icon, guifg = color }, { icon and " " or "" }, { filename } }
      end,
    })
  end,
}
