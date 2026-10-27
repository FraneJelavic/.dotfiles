-- The `ai.copilot-native` extra configures the `copilot` language server but
-- relies on mason-lspconfig to install it, which is skipped in headless mode.
-- Install it through Mason's own `ensure_installed` instead, like the Go extra.
return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "copilot-language-server" } },
  },
}
