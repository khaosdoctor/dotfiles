return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = { position = "right" },
    filesystem = {
      bind_to_cwd = false,
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignore = true,
        show_hidden_count = true,
        always_show = {
          ".gitconfig",
          ".gitignore",
          "node_modules",
        },
        never_show = {
          ".DS_Store",
          "thumbs.db",
          ".git",
          ".DS_Store",
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
    default_component_configs = {
      git_status = {
        symbols = {
          added = "✚",
          modified = "",
          deleted = "✖",
          renamed = "󰁕",
          untracked = "",
          ignored = "󰯒",
          unstaged = "󱔴",
          staged = "󱔲",
          conflict = "",
        },
      },
    },
  },
  keys = {
    {
      "<leader>e",
      "<cmd>Neotree toggle<CR>",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
      end,
      desc = "Open NeoTree",
    },
  },
}
