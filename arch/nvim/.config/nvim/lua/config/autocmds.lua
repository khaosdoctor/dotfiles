-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua>
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- auto set markdown filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufFilePre", "BufRead" }, {
  pattern = { '*.md'},
  callback = function()
    vim.cmd("set filetype=markdown")
  end,
})

-- auto set i3config filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufFilePre", "BufRead" }, {
  pattern = { '*.i3config'},
  callback = function()
    vim.cmd("set filetype=i3config")
  end,
})
