return {
  "folke/snacks.nvim",
  opts = {
    notifier = {
      top_down = false,
      render = "fancy",
    },
  },
  keys = {
    { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (Root Dir)" },
    { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (Root Dir)" },
    { "<leader>fF", LazyVim.pick("files", { root = true }), desc = "Find Files (Root Dir)" },
  },
}
