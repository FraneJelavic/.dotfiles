return {
  -- Install the Groovy parser (Jenkinsfiles use the groovy filetype)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "groovy" } },
  },
}
