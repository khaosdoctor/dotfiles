-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- -- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = true
-- Auto wrap
vim.opt.wrap = true
-- Attempt to fix indent
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smarttab = true

-- Highlights for cursor column
vim.cmd.set("cursorcolumn")
vim.cmd("highlight CursorColumn ctermbg=Blue")
vim.cmd("highlight CursorColumn ctermfg=Black")

-- Vim does not recognize the alt key in Mac
-- https://stackoverflow.com/questions/7501092/can-i-map-alt-key-in-vim
-- So we have to use the response from stty -icanon; cat (press alt + key)
-- to get the correct key code, then we can map it to something else
-- NOTE: ^[ is the escape character \e in vim
vim.cmd("set <M-BS>=\\e?") -- in this example alt+backspace is ESC+? which is mapped to <M-BS>
