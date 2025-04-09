-- ~/.config/nvim/lua/core/options.lua
-- Core Neovim options and settings
-- Author: ehzawad@gmail.com

local basic_terminal = require('utils.terminal').basic_terminal

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.inccommand = "split"

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.timeoutlen = 1000

-- Improve terminal resizing behavior
vim.o.ttimeout = true
vim.o.ttimeoutlen = 10
vim.o.lazyredraw = false -- Disable lazyredraw to improve resizing performance

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,menuone,noselect'

-- Set termguicolors based on terminal capability
if basic_terminal then
  vim.o.termguicolors = false
else
  vim.o.termguicolors = true
end

-- Default cursor line settings
vim.opt.cursorline = false
vim.opt.cursorlineopt = "line"  -- Highlight both line and line number

-- Tab settings
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end
})

-- Cursor shape configuration (compatible with Terminal.app, iTerm2, and Ubuntu Terminal)
if not basic_terminal then
  vim.opt.guicursor = 
    "n-v-c:block," ..   -- Normal mode: block cursor
    "i-ci-ve:ver25," ..  -- Insert mode: vertical bar
    "r-cr-o:hor20"       -- Replace mode: horizontal bar
end

-- Cursor blinking (subtle, not too distracting)
vim.opt.guicursor:append("a:blinkwait175-blinkon200-blinkoff150")

-- Set swap behavior
vim.cmd('set autoread')
vim.cmd('au SwapExists * let v:swapchoice = "e"')

-- Don't have `o` add a comment
vim.opt.formatoptions:remove "o"
