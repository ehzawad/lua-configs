-- ~/.config/nvim/lua/plugins/init.lua
-- Plugin manager setup and plugin list
-- Author: ehzawad@gmail.com

local terminal_utils = require('utils.terminal')
local basic_terminal = terminal_utils.basic_terminal
local terminal_ui = terminal_utils.terminal_ui

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.notify("Installing lazy.nvim...", vim.log.levels.INFO)
  vim.fn.system {
    'git', 'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim UI for basic terminals
if basic_terminal then
  vim.g.lazy_ui = terminal_ui
end

-- Debug: Add notification that we're loading plugins
vim.notify("Loading plugins...", vim.log.levels.INFO)

-- NOTE: Here is where you install your plugins.
-- Use a direct return to ensure everything is loaded correctly
return require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration
  { 'tpope/vim-repeat' },
  -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-sleuth' },
  
  -- AI assistance
  {
    'Exafunction/codeium.vim',
    event = 'BufEnter',
    config = function ()
      -- I kept the default mapping of it
      vim.keymap.set('i', '<C-d>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-f>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-b>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
      vim.keymap.set('i', '<Tab>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-k>', function() return vim.fn['codeium#AcceptNextWord']() end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-l>', function() return vim.fn['codeium#AcceptNextLine']() end, { expr = true, silent = true })
    end
  },
  
  -- Function signatures
  {
    'ray-x/lsp_signature.nvim',
    config = function()
      require('lsp_signature').setup({
        bind = true,                     -- mandatory for border config
        handler_opts = {
          border = "rounded",            -- use a rounded border for the floating window
        },
        floating_window = true,          -- enable the floating signature window
        hint_enable = true,              -- enable inline hints for parameters
        hi_parameter = "Search",         -- highlight the active parameter
      })
    end
  },
  
  -- Copilot setup with API access
  {
    'zbirenbaum/copilot.lua',
    config = function()
      require("copilot").setup({
        -- Disable all suggestions and features, but keep API access for CopilotChat
        suggestion = { enabled = false },
        panel = { enabled = false },
        filetypes = {
          -- Disabled for all filetypes
          ["*"] = false,
        }
      })
    end
  },
  
  -- CopilotChat integration
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" }, -- Required for curl, log and async functions
    },
    build = "make tiktoken",
    opts = {
      -- Default configuration for CopilotChat
      model = "claude-3.7-sonnet-thought",
      model_fallbacks = {
        "claude-3.7-sonnet-thought",
        "claude-3.7-sonnet",
      },
      window = {
        layout = "vertical", -- 'vertical' | 'horizontal' | 'float'
        width = 0.5, -- Width of the chat window
      },
      prompts = {
        Explain = {
          prompt = "Explain what this code does in detail.",
        },
        Review = {
          prompt = "Review the code and provide specific improvements.",
        },
        Tests = {
          prompt = "Generate comprehensive unit tests for this code.",
        },
        Fix = {
          prompt = "Identify and fix issues with this code.",
        },
      },
    },
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      require('plugins.lsp')
    end,
  },

  -- Colorscheme
  { 
    "catppuccin/nvim", 
    name = "catppuccin", 
    priority = 1000 
  },
  
  -- Oil.nvim file explorer
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
      require('plugins.oil')
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind.nvim',
    },
    config = function()
      require('plugins.completion')
    end,
  },

  -- Aerial code outline
  {
    'stevearc/aerial.nvim',
    config = function()
      require('plugins.aerial')
    end,
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('plugins.git')
    end,
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('plugins.ui').setup_lualine()
    end,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Comment plugin
  { 'numToStr/Comment.nvim', opts = {} },

  -- Telescope
  { 
    'nvim-telescope/telescope.nvim', 
    branch = '0.1.x', 
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('plugins.telescope')
    end,
  },

  -- Telescope fuzzy finder native extension
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function()
      require('plugins.treesitter')
    end,
  },
}, {
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  install = {
    -- install missing plugins on startup
    missing = true,
    -- try to load one of these colorschemes when starting an installation during startup
    colorscheme = { "catppuccin" },
  },
  ui = {
    -- Lazy's UI border style
    border = "rounded",
  },
  change_detection = {
    -- automatically check for config file changes and reload
    enabled = true,
    notify = true, -- Show notification when changes are found
  },
})
