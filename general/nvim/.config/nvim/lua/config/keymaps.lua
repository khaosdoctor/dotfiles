-- Keym automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set(
  "n",
  "<leader>sx",
  require("telescope.builtin").resume,
  { noremap = true, silent = true, desc = "Resume telescope search" }
)

-- Move blocks of text (linux)
vim.keymap.set("v", "<A-j>", "<cmd>m '>+1<cr>gv=gv", { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set("v", "<A-k>", "<cmd>m '<-2<cr>gv=gv", { noremap = true, silent = true, desc = "Move line up" })
vim.keymap.set("n", "<A-j>", ":m '.+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m '.-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })

-- Move blocks of text (mac)
-- https://stackoverflow.com/questions/7501092/can-i-map-alt-key-in-vim)
vim.keymap.set("v", "˚", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move line up" })
vim.keymap.set("v", "∆", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set("n", "∆", ":m '.+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set("n", "˚", ":m '.-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })

-- switch tabs
vim.keymap.set("n", "<F8>", "gt", { noremap = true, silent = true, desc = "Switch to next tab" })
vim.keymap.set("n", "<F7>", "gT", { noremap = true, silent = true, desc = "Switch to previous tab" })

-- duplicate line down
vim.keymap.set("n", "<C-S-d>", "yyp", { noremap = true, silent = true, desc = "Duplicate line down" })

-- buffer navigation
-- next
vim.keymap.set("n", "gn", "<cmd>bn<cr>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<tab><tab>", "<cmd>bn<cr>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<tab>n", "<cmd>bn<cr>", { noremap = true, silent = true, desc = "Next buffer" })
-- previous
vim.keymap.set("n", "<S-tab>", "<cmd>bp<cr>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "gp", "<cmd>bN<cr>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<tab>p", "<cmd>bp<cr>", { noremap = true, silent = true, desc = "Previous buffer" })
-- delete/close
vim.keymap.set("n", "<tab>d", "<leader>bd", { noremap = true, silent = true, desc = "Delete buffer" })
vim.keymap.set("n", "<tab>q", "<leader>bd", { noremap = true, silent = true, desc = "Delete buffer" })
vim.keymap.set("n", "<tab>w", "<leader>bd", { noremap = true, silent = true, desc = "Delete buffer" })
-- find
vim.keymap.set("n", "<tab>f", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true, desc = "Find buffer" })

-- Highlights for cursor column
vim.cmd.set("cursorcolumn")
vim.cmd("highlight CursorColumn ctermbg=Blue")
vim.cmd("highlight CursorColumn ctermfg=Black")

-- cmd P
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true, desc = "Find files" })

-- toggle terminal
local wk = require("which-key")
wk.add({
  { "<leader>t", group = "Terminals" },
  {
    "<leader>tt",
    function()
      TermNumber = (TermNumber or 0) + 1
      local term = require("toggleterm")
      term.toggle(TermNumber)
    end,
    desc = "New toggle terminal",
  },
  { "<leader>ts", "<cmd>:TermSelect<cr>", desc = "Find open terminals" },
  { "<leader>tf", "<cmd>:TermSelect<cr>", desc = "Find open terminals" },
  { "<leader>tr", "<cmd>exe v:count1 . 'ToggleTermSetName'<cr>", desc = "Rename open terminals" },
  {
    "<leader>th",
    "<cmd>exe v:count1 . 'ToggleTerm'<cr>",
    desc = "Toggle docked terminal (prefix number before command)",
  },
  { "<C-.>", "<cmd>:ToggleTerm<cr>", group = "Terminals", desc = "Toggle docked terminal", mode = { "n", "t" } },
})

wk.add({
  { "<leader>D", group = "Database" },
  { "<leader>DD", "<cmd>DBUI<cr>", desc = "Toggle DBUI" },
  { "<leader>Dx", "<cmd>call <SNR>79_method('execute_query')<cr>", desc = "Run Query" },
})

-- delete a mark using delmark
wk.add({
  { "<leader>dm", "<cmd>exe 'delmark ' . nr2char(getchar())<cr>", desc = "Delete a mark <markname>" },
})

wk.add({
  { "<leader>o", "o<esc>", desc = "New line below in normal mode" },
  { "<leader>O", "O<esc>", desc = "New line above in normal mode" },
})
