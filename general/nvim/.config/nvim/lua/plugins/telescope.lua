return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      path_display = { shorten = {
        len = 5,
        exclude = { 2, -1 },
      } },
    },
  },
  keys = {
    { "<leader>ff", LazyVim.pick("files"), { root = true }, desc = "Find files (from root)" },
    { "<leader>fF", LazyVim.pick("files"), { root = false }, desc = "Find files (cwd)" },
  },
}
