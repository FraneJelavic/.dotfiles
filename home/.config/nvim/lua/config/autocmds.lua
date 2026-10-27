-- Autocmds are loaded on the VeryLazy event, after LazyVim's defaults.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Remove a default autocmd with `vim.api.nvim_del_augroup_by_name("lazyvim_<name>")`.

-- Groovy / Jenkinsfile buffer settings and quick finders
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "groovy", "Jenkinsfile" },
  group = vim.api.nvim_create_augroup("user_groovy", { clear = true }),
  callback = function(event)
    vim.bo[event.buf].commentstring = "// %s"
    vim.bo[event.buf].shiftwidth = 4
    vim.bo[event.buf].tabstop = 4
    vim.bo[event.buf].expandtab = true

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
    end
    map("<leader>jf", "/\\vvoid [a-zA-Z_]+\\(<CR>", "[J]enkinsfile: Find [F]unction")
    map("<leader>js", "/\\vstage\\(<CR>", "[J]enkinsfile: Find [S]tage")
    map("<leader>jd", "/\\vdef [a-zA-Z_]+\\(<CR>", "[J]enkinsfile: Find [D]efinition")
  end,
})
