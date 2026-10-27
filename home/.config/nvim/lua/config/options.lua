-- Options are loaded before lazy.nvim startup.
-- LazyVim's defaults are applied first, then this file overrides them.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Keep <space> as the leader (LazyVim defaults the local leader to `\`)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Use telescope as the picker and neo-tree as the explorer instead of the
-- LazyVim defaults (snacks). Must be set before lazy.nvim starts, otherwise
-- LazyVim auto-imports the snacks extras first.
vim.g.lazyvim_picker = "telescope"
vim.g.lazyvim_explorer = "neo-tree"

local opt = vim.opt

-- Prefer 4-space indentation over LazyVim's 2-space default
opt.tabstop = 4
opt.shiftwidth = 4

-- Personal preferences on top of LazyVim's defaults
opt.scrolloff = 10
opt.breakindent = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
