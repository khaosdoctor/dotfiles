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
        always_show = {
          ".gitconfig",
          ".gitignore",
        },
        never_show = {
          ".DS_Store",
          "thumbs.db",
        },
      },
      find_args = function(cmd, path, search_term, args)
        if cmd ~= "fd" then
          return args
        end
        -- Searches in hidden files
        table.insert(args, "--hidden")
        -- exclude .git and node_modules
        table.insert(args, "--exclude")
        table.insert(args, ".git")
        table.insert(args, "--exclude")
        table.insert(args, "node_modules")

        return args
      end,
    },
    follow_current_file = { enabled = true },
  },
}
