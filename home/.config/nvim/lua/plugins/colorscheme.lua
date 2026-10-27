return {
  -- Use Catppuccin Mocha instead of LazyVim's default tokyonight
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
  {
    "catppuccin/nvim",
    opts = {
      flavour = "mocha",
      transparent_background = false,
    },
  },
}
