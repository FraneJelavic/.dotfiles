-- golangci-lint v2 refuses to run when a project still has a legacy (v1)
-- `.golangci.*` config, so lint those projects with `--no-config` instead.
-- Ported from the previous kickstart setup, using LazyVim's `condition`
-- extension to route Go buffers to the right linter.

local is_v2 ---@type boolean?

local function golangci_is_v2()
  if is_v2 == nil then
    is_v2 = vim.fn.system({ "golangci-lint", "version" }):match("version v?2") ~= nil
  end
  return is_v2
end

---@param filename string
---@return boolean
local function has_legacy_config(filename)
  local config = vim.fs
    .find({ ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" }, {
      path = vim.fs.dirname(filename),
      upward = true,
    })[1]
  if not config then
    return false
  end
  for _, line in ipairs(vim.fn.readfile(config)) do
    if line:match([[^%s*version:%s*["']?2["']?%s*$]]) then
      return false
    end
  end
  return true
end

local function needs_legacy_shim(ctx)
  return golangci_is_v2() and has_legacy_config(ctx.filename)
end

return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      local shim = vim.deepcopy(require("lint.linters.golangcilint"))
      -- `--no-config` must come before the file argument
      table.insert(shim.args, 2, "--no-config")
      shim.condition = needs_legacy_shim

      opts.linters = opts.linters or {}
      opts.linters.golangcilint = vim.tbl_deep_extend("force", opts.linters.golangcilint or {}, {
        condition = function(ctx)
          return not needs_legacy_shim(ctx)
        end,
      })
      opts.linters.golangcilint_legacy = shim
      opts.linters_by_ft = vim.tbl_deep_extend("force", opts.linters_by_ft or {}, {
        go = { "golangcilint", "golangcilint_legacy" },
      })
      return opts
    end,
  },
}
