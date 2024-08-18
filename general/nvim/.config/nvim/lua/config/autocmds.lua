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
    vim.cmd("set filetype=markdown")
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

-- select the whole buffer and soft wrap to these parameters on reading
vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = { "*.md" },
  callback = function()
    vim.cmd("normal ggVGgwwgg")
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
