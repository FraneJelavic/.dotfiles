local failures = {}

local function check(name, condition, detail)
  if condition then
    print('PASS: ' .. name)
    return
  end

  failures[#failures + 1] = name .. (detail and ': ' .. detail or '')
  print('FAIL: ' .. failures[#failures])
end

local function has_plugin(name)
  local ok, config = pcall(require, 'lazy.core.config')
  return ok and config.plugins[name] ~= nil
end

local function has_tool(name)
  return vim.fn.executable(name) == 1
end

check('gopls is installed', has_tool 'gopls')
check('golangci-lint is installed', has_tool 'golangci-lint')
check('goimports is installed', has_tool 'goimports')
check('gofumpt is installed', has_tool 'gofumpt')

local lazy_ok, lazy_config = pcall(require, 'lazy.core.config')
local conform_spec = lazy_ok and lazy_config.plugins['conform.nvim'] or nil
local conform_opts = conform_spec and conform_spec.opts or nil
local go_formatters = type(conform_opts) == 'table' and conform_opts.formatters_by_ft.go or nil
check('Go files use goimports and gofumpt', type(go_formatters) == 'table' and go_formatters[1] == 'goimports' and go_formatters[2] == 'gofumpt')

local parser_ok = pcall(vim.treesitter.language.add, 'go')
check('Go Treesitter parser is available', parser_ok)

check('nvim-lint is registered with lazy.nvim', has_plugin 'nvim-lint')
local lint_ok, lint = pcall(require, 'lint')
local go_linters = lint_ok and lint.linters_by_ft.go or nil
check('golangci-lint is enabled for Go buffers', type(go_linters) == 'table' and vim.tbl_contains(go_linters, 'golangcilint'))

check('Neo-tree is registered with lazy.nvim', has_plugin 'neo-tree.nvim')
local explorer_map = vim.fn.maparg('<leader>e', 'n', false, true)
check('Space e toggles the project explorer', type(explorer_map) == 'table' and explorer_map.desc == 'Explorer: toggle project tree')

check('Copilot command is available', vim.fn.exists ':Copilot' == 2)
local tab_map = vim.fn.maparg('<Tab>', 'i', false, true)
check(
  'Tab explicitly accepts Copilot suggestions',
  type(tab_map) == 'table'
    and tab_map.desc == 'Copilot: accept suggestion'
    and type(tab_map.rhs) == 'string'
    and tab_map.rhs:find('copilot#Accept', 1, true) ~= nil
)

if #failures > 0 then
  print(('%d Go setup check(s) failed:\n- %s'):format(#failures, table.concat(failures, '\n- ')))
  vim.cmd 'cquit 1'
end

print 'All Go setup checks passed'
vim.cmd 'quitall'
