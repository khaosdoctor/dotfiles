-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua>
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- auto formats Caddyfile after save if caddy is installed
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup("caddyfile_fmt"),
  pattern = { "Caddyfile", "Caddyfile.*" },
  callback = function()
    if vim.fn.executable("caddy") == 1 then
      local filepath = vim.fn.expand("%:p")
      vim.fn.jobstart({ "caddy", "fmt", "-w", filepath }, {
        detach = true,
        on_exit = function()
          vim.cmd("edit")
        end,
      })
      return
    end
    vim.notify("Caddy is not installed. Skipping format", vim.log.levels.INFO)
  end,
})

-- Set 2-space indentation for web development filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("web_indent"),
  pattern = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "json",
    "jsonc",
    "yaml",
    "yml",
    "html",
    "css",
    "scss",
    "less",
    "vue",
    "svelte",
    "astro",
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("markdown_keys"),
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>cT", "<cmd>Mtoc i<CR>", {
      buffer = 0,
      noremap = true,
      silent = true,
      desc = "Insert TOC at cursor position",
    })
  end,
})

-- Autocmd for breaking lines at column 80 in commit messages
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("gitcommit_wrap"),
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
    vim.opt_local.formatoptions:append("t")
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("md_trailing_ws"),
  pattern = "*.md",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- auto set i3config filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufFilePre", "BufRead" }, {
  group = augroup("i3config_ft"),
  pattern = { "*.i3config" },
  callback = function()
    vim.cmd("set filetype=i3config")
  end,
})
