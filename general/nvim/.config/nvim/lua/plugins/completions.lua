return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    local nhc = require("nvim-highlight-colors")
    opts.keymap = opts.keymap or {}

    -- remap selection to C-j to match telescope
    opts.keymap["<C-j>"] = { "select_next", "fallback" }
    opts.keymap["<C-k>"] = { "select_prev", "fallback" }
    opts.keymap["<C-d>"] = { "scroll_documentation_down", "fallback" }
    opts.keymap["<C-u>"] = { "scroll_documentation_up", "fallback" }
    opts.keymap["<Tab>"] = { "select_and_accept", "fallback" }

    -- Add enabled function to check global toggle state
    -- This function is called by blink.cmp before showing completions
    -- By returning false, we prevent completions from appearing at all
    opts.enabled = function()
      -- vim.g.blink_cmp_enabled is our global toggle state
      -- nil or true = enabled, false = disabled
      -- We explicitly check for false to default to enabled
      if vim.g.blink_cmp_enabled == false then
        return false -- Completions are disabled
      end
      return true -- Completions are enabled (default)
    end

    -- Integration with nvim-highlight-colors
    opts.completion.menu.draw.components = opts.completion.menu.draw.components or {}
    opts.completion.menu.draw.components.kind_icon = opts.completion.menu.draw.components.kind_icon or {}
    local components = opts.completion.menu.draw.components

    components.kind_icon.text = function(ctx)
      -- default kind icon
      local icon = ctx.kind_icon
      -- if LSP source, check for color derived from documentation
      if ctx.item.source_name == "LSP" then
        local color_item = nhc.format(ctx.item.documentation, { kind = ctx.kind })
        if color_item and color_item.abbr ~= "" then
          icon = color_item.abbr
        end
      end
      return icon .. ctx.icon_gap
    end

    components.kind_icon.highlight = function(ctx)
      -- if LSP source, check for color derived from documentation
      if ctx.item.source_name == "LSP" then
        local color_item = nhc.format(ctx.item.documentation, { kind = ctx.kind })
        if color_item and color_item.abbr_hl_group then
          return color_item.abbr_hl_group
        end
      end
      -- default highlight group
      return "BlinkCmpKind" .. ctx.kind
    end

    return opts
  end,
  keys = {
    {
      "<leader>uB",
      function()
        -- Toggle completions on/off
        -- This works by flipping a global variable that the enabled function checks
        local cmp = require("blink.cmp")

        -- Initialize the toggle state if it doesn't exist yet
        -- Default to enabled (true)
        if vim.g.blink_cmp_enabled == nil then
          vim.g.blink_cmp_enabled = true
        end

        -- Flip the toggle state
        vim.g.blink_cmp_enabled = not vim.g.blink_cmp_enabled

        if vim.g.blink_cmp_enabled then
          -- Completions are now enabled
          -- Call reload() to re-trigger completion in the current context
          cmp.reload()
          vim.notify("Completions enabled", vim.log.levels.INFO, { title = "Blink" })
        else
          -- Completions are now disabled
          -- Call hide() to immediately close any open completion menu
          -- The enabled function above will prevent new menus from opening
          cmp.hide()
          vim.notify("Completions disabled", vim.log.levels.INFO, { title = "Blink" })
        end
      end,

      mode = { "n" }, -- DO NOT SET THIS TO WORK ON INSERT MODE, this will cause a massive delay on the <leader> key (which is space)
      desc = "Toggle Completions",
    },
  },
}
