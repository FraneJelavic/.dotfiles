-- Headless checks for the Neovim setup.
-- Run with:
--   NVIM_APPNAME=nvim-lazyvim nvim --headless "+Lazy! load all" "+luafile tests/setup_spec.lua" +qa

local failures = {}

-- Keymaps and some plugin keymaps are loaded on VeryLazy
vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })

local function check(name, condition, detail)
  if condition then
    print("PASS: " .. name)
    return
  end
  failures[#failures + 1] = name .. (detail and ": " .. detail or "")
  print("FAIL: " .. failures[#failures])
end

local function has_plugin(name)
  local ok, config = pcall(require, "lazy.core.config")
  return ok and config.plugins[name] ~= nil
end

local function has_tool(name)
  return vim.fn.executable(name) == 1
end

-- LazyVim wiring
local LazyVim = require("lazyvim.util")
check("Go extra is enabled", LazyVim.has_extra("lang.go"))
check("Copilot native extra is enabled", LazyVim.has_extra("ai.copilot-native"))
check("Telescope extra is enabled", LazyVim.has_extra("editor.telescope"))
check("Neo-tree extra is enabled", LazyVim.has_extra("editor.neo-tree"))

-- Go tooling
check("gopls is installed", has_tool("gopls"))
check("golangci-lint is installed", has_tool("golangci-lint"))
check("goimports is installed", has_tool("goimports"))
check("gofumpt is installed", has_tool("gofumpt"))
check("tree-sitter CLI is installed", has_tool("tree-sitter"))
check("copilot-language-server is installed", has_tool("copilot-language-server"))

local lazy_ok, lazy_config = pcall(require, "lazy.core.config")
local conform_spec = lazy_ok and lazy_config.plugins["conform.nvim"] or nil
check("conform.nvim is registered", conform_spec ~= nil)

local conform_ok, conform = pcall(require, "conform")
local go_formatters = conform_ok and conform.formatters_by_ft.go or nil
check(
  "Go files use goimports and gofumpt",
  type(go_formatters) == "table" and go_formatters[1] == "goimports" and go_formatters[2] == "gofumpt"
)

local parser_ok = pcall(vim.treesitter.language.add, "go")
check("Go Treesitter parser is available", parser_ok)

-- Linting, including the golangci-lint v2 legacy-config shim
check("nvim-lint is registered with lazy.nvim", has_plugin("nvim-lint"))
local lint_ok, lint = pcall(require, "lint")
local go_linters = lint_ok and lint.linters_by_ft.go or nil
check("golangci-lint is enabled for Go buffers", type(go_linters) == "table" and vim.tbl_contains(go_linters, "golangcilint"))
check("golangci-lint legacy shim is present", lint_ok and lint.linters.golangcilint_legacy ~= nil)
check(
  "legacy shim passes --no-config",
  lint_ok and lint.linters.golangcilint_legacy and vim.tbl_contains(lint.linters.golangcilint_legacy.args, "--no-config")
)

-- Explorer and keymaps
check("Neo-tree is registered with lazy.nvim", has_plugin("neo-tree.nvim"))
local explorer_map = vim.fn.maparg("<leader>e", "n", false, true)
check("Space e toggles the project explorer", type(explorer_map) == "table" and explorer_map.desc ~= nil)

local yank_map = vim.fn.maparg("y", "n", false, true)
check("Yank uses the system clipboard", type(yank_map) == "table" and yank_map.rhs == '"+y')

-- Copilot (native LSP, not github/copilot.vim)
check("github/copilot.vim is not installed", not has_plugin("copilot.vim"))
check("Copilot LSP is configured", vim.lsp.config.copilot ~= nil)
check("AI completions use inline suggestions", vim.g.ai_cmp == false)

-- Options
check("Leader is space", vim.g.mapleader == " ")
check("Indent is 4 spaces", vim.o.tabstop == 4 and vim.o.shiftwidth == 4)

if #failures > 0 then
  print(("%d check(s) failed:\n- %s"):format(#failures, table.concat(failures, "\n- ")))
  vim.cmd("cq")
end
print("All setup checks passed")
