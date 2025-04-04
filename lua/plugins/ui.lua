-- ~/.config/nvim/lua/plugins/ui.lua
-- UI components configuration
-- Author: ehzawad@gmail.com

local basic_terminal = require('utils.terminal').basic_terminal

local M = {}

-- Set up lualine statusline
function M.setup_lualine()
  require('lualine').setup({
    options = {
      icons_enabled = not basic_terminal,
      component_separators = '|',
      section_separators = '',
    },
  })
end

-- Set up cursor highlighting
function M.setup_cursor_highlight()
  -- Soft, elegant cursor line highlighting
  vim.api.nvim_set_hl(0, 'CursorLine', {
    bg = basic_terminal and "#1c1c1c" or "#262626",  -- Slightly lighter background for better visibility
    ctermbg = 233,
    -- Remove underline to make it cleaner
    -- Use a subtle background instead of harsh underlining
  })

  -- Cursor line number styling
  vim.api.nvim_set_hl(0, 'CursorLineNr', {
    fg = "#ffaf00",  -- Warm yellow, more pleasing than pure yellow
    bg = basic_terminal and "#1c1c1c" or "#262626",
    ctermfg = 214,   -- Corresponding terminal color
    ctermbg = 233,
    bold = true,
  })

  -- Cursor itself - make it stand out subtly
  vim.api.nvim_set_hl(0, 'Cursor', {
    reverse = true,
    -- Avoid blinking in terminal to prevent potential display issues
  })
  
  -- Improve visual selection highlighting for retrobox colorscheme
  vim.api.nvim_set_hl(0, 'Visual', {
    bg = basic_terminal and "#3a3a3a" or "#3a3a3a",
    ctermbg = 237,  -- Higher contrast background for better visibility
  })
end

-- Initialize UI components
M.setup_cursor_highlight()

return M
