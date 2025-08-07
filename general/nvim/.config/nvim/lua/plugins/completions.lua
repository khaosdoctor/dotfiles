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
}
