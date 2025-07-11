-- Keym automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

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

-- alt delete
--for mac (see options.lua)
vim.keymap.set("n", "<M-BS>", "hdiw", { noremap = true, silent = true, desc = "Delete word" })
-- for linux
vim.keymap.set("n", "<A-BS>", "hdiw", { noremap = true, silent = true, desc = "Delete word" })

-- Resize split windows with alt+shift+arrow
vim.keymap.set({ "n", "v", "i", "t" }, "<A-S-Left>", "<C-W>>")
vim.keymap.set({ "n", "v", "i", "t" }, "<A-S-Right>", "<C-W><")
vim.keymap.set({ "n", "v", "i", "t" }, "<A-S-Up>", "<C-W>+")
vim.keymap.set({ "n", "v", "i", "t" }, "<A-S-Down>", "<C-W>-")

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
      Snacks.terminal(
        nil,
        { interactive = true, win = { position = "float", border = "rounded" }, auto_close = true, auto_insert = true }
      )
    end,
    desc = "New floating terminal",
  },
})

wk.add({
  {
    "<leader>uB",
    function()
      local blink = require("blink.cmp.config")
      local blinkVarName = "blink_enabled"

      -- This overrides the default enabled function to add a toggle
      blink.enabled = function(checkOnly)
        -- if checkOnly is not passed then we assume true
        -- because blink will call blink.enabled() to check the status
        checkOnly = checkOnly == nil and true or checkOnly

        if not checkOnly then
          local currentStatus
          -- pcall is to check for errors since nvim_buf_get_var will throw if the var is not found
          if pcall(vim.api.nvim_buf_get_var, 0, blinkVarName) then
            -- if there's no error pcall returns true and we can call the function again
            currentStatus = vim.api.nvim_buf_get_var(0, blinkVarName)
          else
            -- otherwise we just start it as true
            currentStatus = true
          end

          -- then we invert the value
          vim.api.nvim_buf_set_var(0, blinkVarName, not currentStatus)

          -- show a notification
          local valueString = vim.api.nvim_buf_get_var(0, blinkVarName) and "enabled" or "disabled"
          require("snacks.notify")(
            "Blink completions are now " .. valueString,
            { level = "info", title = "Completions toggled" }
          )
        end

        -- in the end we just return the currend status
        return vim.api.nvim_buf_get_var(0, blinkVarName)
      end

      -- since this is done in the keymaps file, we need to call the function again
      -- I could add this to another file in the plugins directory but then I'd need to
      -- recofigure blink and I'm really not into it, this is enough
      blink.enabled(false)
    end,
    mode = "n",
    desc = "Toggle completions",
  },
})

wk.add({
  { "<leader>cp", group = "Copilot" },
  { "<leader>cpt", "<cmd>Copilot toggle<cr>", desc = "Toggle Copilot" },
  { "<leader>cpe", "<cmd>Copilot enable<cr>", desc = "Enable Copilot" },
  { "<leader>cpd", "<cmd>Copilot disable<cr>", desc = "Disable Copilot" },
  { "<leader>cps", "<cmd>Copilot status<cr>", desc = "Copilot status" },
})

wk.add({
  { "<leader>D", group = "Database" },
  { "<leader>DD", "<cmd>DBUI<cr>", desc = "Toggle DBUI" },
  { "<leader>Dx", "<cmd>call <SNR>79_method('execute_query')<cr>", desc = "Run Query" },
})

wk.add({
  { "<leader>cn", group = "Minimap" },
})

wk.add({
  { "<leader>fC", group = "Copy" },
  { "<leader>fCr", "<cmd>:let @+ = expand('%')<cr>", desc = "Copy relative file path to clipboard" },
  { "<leader>fCc", "<cmd>:let @+ = expand('%:p')<cr>", desc = "Copy file path to clipboard" },
  { "<leader>fCd", "<cmd>:let @+ = expand('%:p:h')<cr>", desc = "Copy file directory to clipboard" },
  { "<leader>fCn", "<cmd>:let @+ = expand('%:t')<cr>", desc = "Copy file name to clipboard" },
  { "<leader>fCN", "<cmd>:let @+ = expand('%:t:r')<cr>", desc = "Copy file name without extension to clipboard" },
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
