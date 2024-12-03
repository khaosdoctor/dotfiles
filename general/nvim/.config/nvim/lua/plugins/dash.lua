return {
  "mrjones2014/dash.nvim",
  keys = {
    { "<leader>fd", "<cmd>Dash<cr>", desc = "Search documentation in Dash" },
    { "<leader>fD", "<cmd>DashWord<cr>", desc = "Search word under the cursor with Dash" },
  },
  build = "make install",
  opts = {
    dash_app_path = "/Applications/Setapp/Dash.app",
    debounce = 500,
    file_type_keywords = {
      dashboard = false,
      packer = false,
      fzf = false,
      javascript = { "javascript", "nodejs" },
      typescript = { "typescript", "javascript", "nodejs" },
      deno = { "deno", "typescript", "javascript", "nodejs" },
    },
  },
}
