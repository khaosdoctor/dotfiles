-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua>
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- auto set markdown filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufFilePre", "BufRead" }, {
  pattern = { "*.md" },
  callback = function()
    -- set markdown file type
    vim.cmd("set filetype=markdown")

    -- add local command to insert TOC
    local wk = require("which-key")
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<leader>cT",
      "<cmd>Mtoc i<CR>",
      { noremap = true, silent = true, desc = "Insert TOC at cursor" }
    )
    wk.add({
      {
        "<leader>cT",
        "<cmd>Mtoc i<CR>",
        desc = "Insert TOC at cursor position",
        mode = "n",
        noremap = true,
        buffer = 0,
      },
    })
  end,
})

-- Autocmd for breaking lines at column 80 in commit messages
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    -- Enable text wrapping
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80" -- Highlight column 80
    vim.opt_local.formatoptions:append("t") -- Enable auto-formatting of text
  end,
})

-- Auto set markdown to break at 80 chars and highlight the 80th column
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = { "*.md" },
  callback = function()
    vim.opt.colorcolumn = "80"
    vim.opt.textwidth = 80
  end,
})

-- On leaving markdown files, reset the colorcolumn and textwidth
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
  pattern = { "*.md" },
  callback = function()
    vim.opt.colorcolumn = "120"
    -- disabled textwidth
    vim.opt.textwidth = 0
  end,
})

-- auto set i3config filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufFilePre", "BufRead" }, {
  pattern = { "*.i3config" },
  callback = function()
    vim.cmd("set filetype=i3config")
  end,
})
