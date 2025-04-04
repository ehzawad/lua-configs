-- ~/.config/nvim/init.lua
-- Entry point for Neovim configuration
-- Author: ehzawad@gmail.com

-- Set leader key at the earliest opportunity
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load terminal detection utility first as it's used throughout
local terminal_utils = require('utils.terminal')

-- Load core Neovim configuration
require('core.options')
require('core.keymaps')
require('core.autocmds')
require('core.utils')

-- Add a timeout to make sure messages are visible
vim.defer_fn(function()
  vim.notify("Loading plugins from lua/plugins/init.lua...", vim.log.levels.INFO)
end, 100)

-- Load plugins (this will handle all plugin configuration)
require('plugins')

-- Add a small delay before setting colorscheme to ensure plugins are loaded
vim.defer_fn(function()
  -- Set colorscheme after plugins are loaded
  local basic_terminal = require('utils.terminal').basic_terminal
  if basic_terminal then
    pcall(vim.cmd, 'colorscheme retrobox') 
  else
    pcall(vim.cmd, 'colorscheme catppuccin-mocha')
  end
end, 200)

-- Force UI update after everything is loaded
vim.defer_fn(function()
  vim.cmd('redraw')
  vim.notify("Neovim configuration loaded successfully", vim.log.levels.INFO)
  
  -- Check how many plugins are loaded
  local lazy_ok, lazy = pcall(require, "lazy.stats")
  if lazy_ok then
    local stats = lazy.stats()
    vim.notify(string.format("Loaded %d/%d plugins", stats.loaded, stats.count), vim.log.levels.INFO)
  end
end, 500)
