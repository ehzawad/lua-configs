-- ~/.config/nvim/lua/core/keymaps.lua
-- Core keymappings for Neovim
-- Author: ehzawad@gmail.com

-- Leader key is space (defined at the very beginning of init)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Terminal mode mappings
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l')

-- Search highlight blink
local function hl_next(blinktime)
  local target_pat = '\\c\\%#' .. vim.fn.getreg('/')
  local ring = vim.fn.matchadd('ErrorMsg', target_pat, 101)
  vim.cmd('redraw')
  vim.cmd('sleep ' .. math.floor(blinktime * 2000) .. 'm')
  pcall(vim.fn.matchdelete, ring)
  vim.cmd('redraw')
end

vim.keymap.set('n', 'n', function()
  vim.cmd('normal! n')
  hl_next(0.1)
end, { silent = true })

vim.keymap.set('n', 'N', function() 
  vim.cmd('normal! N')
  hl_next(0.1)
end, { silent = true })

-- Command mode Emacs-style shortcuts
vim.keymap.set('c', '<C-a>', '<Home>', { silent = true })
vim.keymap.set('c', '<C-b>', '<Left>', { silent = true })
vim.keymap.set('c', '<C-d>', '<Del>', { silent = true })
vim.keymap.set('c', '<C-e>', '<End>', { silent = true })
vim.keymap.set('c', '<C-f>', '<Right>', { silent = true })
vim.keymap.set('c', '<C-n>', '<Down>', { silent = true })
vim.keymap.set('c', '<C-p>', '<Up>', { silent = true })

-- Speed up viewport scrolling
vim.keymap.set('n', '<C-e>', '9<C-e>', { silent = true })
vim.keymap.set('n', '<C-y>', '9<C-y>', { silent = true })

-- Minimal Visual Mode Enhancements
-- Basic indent - works forever to the right, preserves selection
vim.keymap.set('x', '>', '>gv', { silent = true })

-- Basic outdent - stops at left boundary, preserves selection
vim.keymap.set('x', '<', function()
  -- Get the shiftwidth value (how many spaces per indent level)
  local shiftwidth = vim.fn.shiftwidth()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  -- Check each line in selection
  for line_num = start_line, end_line do
    local line = vim.api.nvim_buf_get_lines(0, line_num-1, line_num, false)[1]
    -- Skip empty lines
    if line:match("%S") then
      -- Find position of first non-whitespace character
      local first_char_pos = line:find("%S")
      -- If any line would be pushed past the wall by an outdent
      if first_char_pos and first_char_pos <= shiftwidth then
        -- We've hit the wall - can't outdent further
        return 'gv'
      end
    end
  end
  -- Safe to outdent
  return '<gv'
end, { expr = true, silent = true })

-- Move selection down, stop at bottom
vim.keymap.set('x', 'J', function()
  -- Check if we're at the end of the buffer
  local line_count = vim.api.nvim_buf_line_count(0)
  local _, end_line = unpack(vim.fn.getpos("'>"))
  if end_line >= line_count then
    return 'gv'
  end
  return ":m '>+1<CR>gv"
end, { expr = true, silent = true })

-- Move selection up, stop at top
vim.keymap.set('x', 'K', function()
  -- Check if we're at the beginning of the buffer
  local _, start_line = unpack(vim.fn.getpos("'<"))
  if start_line <= 1 then
    return 'gv'
  end
  return ":m '<-2<CR>gv"
end, { expr = true, silent = true })

-- Preserve selection after undo/redo
vim.keymap.set('x', 'u', '<Esc>ugv', { silent = true })
vim.keymap.set('x', '<C-r>', '<Esc><C-r>gv', { silent = true })

-- Telescope key mappings
local status_ok, builtin = pcall(require, 'telescope.builtin')
if status_ok then
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
end


