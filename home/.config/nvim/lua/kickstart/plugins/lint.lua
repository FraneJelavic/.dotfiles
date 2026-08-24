return {
  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        go = { 'golangcilint' },
      }

      local golangci_v2 = vim.fn.system({ 'golangci-lint', 'version' }):match 'version v?2' ~= nil
      local function support_legacy_golangci_config(linter)
        if linter.name ~= 'golangcilint' or not golangci_v2 then
          return linter
        end

        local buffer_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
        local config = vim.fs.find({ '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json' }, {
          path = buffer_dir,
          upward = true,
        })[1]

        if not config then
          return linter
        end

        for _, line in ipairs(vim.fn.readfile(config)) do
          if line:match [[^%s*version:%s*["']?2["']?%s*$]] then
            return linter
          end
        end

        table.insert(linter.args, 2, '--no-config')
        vim.notify_once 'golangci-lint v2 ignored a legacy project config. Run `golangci-lint migrate` to update it.'
        return linter
      end

      local function try_lint()
        lint.try_lint(nil, {
          ignore_errors = true,
          wrap_linter = support_legacy_golangci_config,
        })
      end

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            try_lint()
          end
        end,
      })

      vim.keymap.set('n', '<leader>ll', try_lint, { desc = '[L]int current file' })
    end,
  },
}
