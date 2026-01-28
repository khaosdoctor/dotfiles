return {
  -- Configure copilot to avoid duplicates with blink.cmp
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        -- Disable inline suggestions to avoid duplicates with blink-copilot
        -- All copilot suggestions will appear in the completion menu only
        enabled = false,
        auto_trigger = false,
      },
    },
  },
}
