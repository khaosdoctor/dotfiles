return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.keymap = opts.keymap or {}
    -- remap selection to C-j to match telescope
    opts.keymap["<C-j>"] = { "select_next", "fallback" }
    opts.keymap["<C-k>"] = { "select_prev", "fallback" }
    opts.keymap["<C-d>"] = { "scroll_documentation_down", "fallback" }
    opts.keymap["<C-u>"] = { "scroll_documentation_up", "fallback" }
    opts.keymap["<Tab>"] = { "select_and_accept", "fallback" }
    return opts
  end,
}
