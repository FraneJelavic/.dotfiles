-- Keymaps are loaded on VeryLazy, after LazyVim's defaults.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- On macOS, `clipboard=unnamedplus` does not reliably forward operator yanks,
-- so send normal/visual yanks to the system clipboard explicitly.
vim.keymap.set({ "n", "x" }, "y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "Y", '"+Y', { desc = "Yank line to system clipboard" })
