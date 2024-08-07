return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      path_display = { shorten = {
        len = 3,
        exclude = { 2, -1 },
      } },
    },
  },
}
