return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = { position = "right" },
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignore = true,
        show_hidden_count = true,
        hide_by_name = {
          ".git",
          ".DS_Store",
          "thumbs.db",
        },
      },
    },
  },
}
