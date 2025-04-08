-- ~/.config/nvim/lua/plugins/ui.lua
-- UI components configuration
-- Author: ehzawad@gmail.com

local basic_terminal = require('utils.terminal').basic_terminal

local M = {}

-- Set up lualine statusline
function M.setup_lualine()
  -- Detect OS for proper file format icons
  local sysname = vim.loop.os_uname().sysname
  local is_mac = sysname == "Darwin"

  require('lualine').setup({
    options = {
      icons_enabled = not basic_terminal,
      component_separators = '|',
      section_separators = '',
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {'filename'},
      lualine_x = {
        -- Custom fileformat with OS-specific icons
        {
          'fileformat',
          symbols = {
            unix = 'unix',
            dos = 'dos',
          }
        },
        'encoding', 
        'filetype'
      },
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {'filename'},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {}
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
