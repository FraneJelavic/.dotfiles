-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '<leader>e', '<cmd>Neotree toggle left filesystem reveal<CR>', desc = 'Explorer: toggle project tree' },
    { '\\', '<cmd>Neotree focus left filesystem reveal<CR>', desc = 'Explorer: reveal current file' },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      window = {
        position = 'left',
        width = 35,
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
