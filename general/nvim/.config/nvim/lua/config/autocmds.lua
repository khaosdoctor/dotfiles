-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua>
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- TEMPORARY: auto copy files to the google drive folder after save
-- because it has a huge delay in the save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "/home/khaosdoctor/Documents/Packt/*" },
  callback = function()
    local local_file = vim.fn.expand("%:p")
    local google_drive_path = "/home/khaosdoctor/mnt/Google Drive/Projetos/Livro Packt/Offline Chapters/"
      .. vim.fn.fnamemodify(local_file, ":t")

    vim.fn.jobstart({ "cp", local_file, google_drive_path }, {
      detach = true,
      on_exit = function()
        vim.notify("File copied to Google Drive", vim.log.levels.INFO)
      end,
    })
  end,
})

-- auto formats Caddyfile after save if caddy is installed
vim.api.nvim_create_autocmd("BufWritePost", {
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

-- auto set markdown filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufFilePre", "BufRead" }, {
  pattern = { "*.md" },
  callback = function()
    -- set markdown file type
    vim.cmd("set filetype=markdown")

    -- add local command to insert TOC
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
