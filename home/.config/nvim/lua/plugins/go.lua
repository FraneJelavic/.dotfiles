return {
  -- Extra gopls analyses on top of the `lang.go` extra defaults
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                nilness = true,
                shadow = true,
                unusedparams = true,
                unusedwrite = true,
              },
              usePlaceholders = true,
            },
          },
        },
      },
    },
  },
}
