return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = "cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app && npm i",
  lazy = true,
  config = function()
    vim.g.mkdp_browser = "vivaldi-stable"
  end,
}
