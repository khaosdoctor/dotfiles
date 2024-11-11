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
vim.keymap.set("n", "<tab>d", "<cmd>bd<cr>", { noremap = true, silent = true, desc = "Delete buffer" })
vim.keymap.set("n", "<tab>q", "<cmd>bd<cr>", { noremap = true, silent = true, desc = "Delete buffer" })
vim.keymap.set("n", "<tab>w", "<cmd>bd<cr>", { noremap = true, silent = true, desc = "Delete buffer" })
-- find
vim.keymap.set("n", "<tab>f", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true, desc = "Find buffer" })

-- alt delete
--for mac (see options.lua)
vim.keymap.set("n", "<M-BS>", "hdiw", { noremap = true, silent = true, desc = "Delete word" })
-- for linux
vim.keymap.set("n", "<A-BS>", "hdiw", { noremap = true, silent = true, desc = "Delete word" })

-- cmd P
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true, desc = "Find files" })

-- DO NOT REMOVE
local wk = require("which-key")

-- NVIM terminal
wk.add({
  { "<leader>t", group = "Terminals" },
  {
    "<C-.>",
    function()
      Snacks.terminal(nil)
    end,
    desc = "New docked terminal",
    mode = "n",
  },
  {
    "<C-.>",
    "<cmd>close<cr>",
    mode = "t",
    desc = "Toggle terminal",
  },
  {
    "<C-/>",
    function()
      Snacks.terminal("tmux")
    end,
    desc = "New floating terminal",
  },
  {
    "<leader>tt",
    function()
      Snacks.terminal(nil)
    end,
    desc = "New docked terminal",
  },
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

wk.add({
  { "<leader>bD", "<cmd>BufferLineCloseOthers<cr><cmd>bd<cr>", desc = "Close all buffers" },
  { "<leader>bn", "<cmd>ene<cr>", desc = "Open new buffer" },
})
