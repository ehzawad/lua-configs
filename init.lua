-- ehzawad@gmail.com; email me to say hi or if there are any questions
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--------------------------------------------------------------------------------
-- Unified Terminal Detection
--------------------------------------------------------------------------------
local function detect_basic_terminal()
  local sysname = vim.loop.os_uname().sysname
  local is_basic = false

  if sysname == "Darwin" then
    local term_program = vim.env.TERM_PROGRAM or ""
    if term_program == "Apple_Terminal" then
      is_basic = true
    elseif term_program == "iTerm.app" then
      is_basic = false
    else
      is_basic = false
    end
  elseif sysname == "Linux" then
    local term = vim.env.TERM or ""
    local term_program = vim.env.TERM_PROGRAM or ""
    local xterm_version = vim.env.XTERM_VERSION or ""
    -- If running in a basic xterm-like terminal (e.g. default Ubuntu GNOME Terminal)
    if (term == "xterm" or term:match("^xterm%-")) and term_program == "" and xterm_version == "" then
      is_basic = true
    else
      is_basic = false
    end
  else
    is_basic = false
  end

  return is_basic
end

local basic_terminal = detect_basic_terminal()
vim.g.is_basic_terminal = basic_terminal and 1 or 0

--------------------------------------------------------------------------------
-- UI and Package Manager Setup
--------------------------------------------------------------------------------

-- Terminal UI settings for basic terminals
local terminal_ui = {
  icons = {
    cmd = "CMD",
    config = "CFG",
    event = "EVT",
    ft = "FT",
    init = "INIT",
    import = "IMP",
    keys = "KEYS",
    lazy = "LAZY",
    loaded = "●",
    not_loaded = "○",
    plugin = "PLUG",
    runtime = "RT",
    require = "REQ",
    source = "SRC",
    start = "START",
    task = "TASK",
    list = { "●", "→", "★", "‒" },
  },
  border = "single",
}

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
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

-- Add a notification system for better error/info messages
local has_notify, notify_module = pcall(require, "notify")
if not has_notify then
  -- Create a simplified notify replacement if nvim-notify isn't available
  notify_module = function(msg, level, opts)
    opts = opts or {}
    level = level or vim.log.levels.INFO
    
    -- Map log levels to symbols
    local symbols = {
      [vim.log.levels.ERROR] = basic_terminal and "ERROR" or "✘ ERROR",
      [vim.log.levels.WARN] = basic_terminal and "WARNING" or "⚠ WARNING",
      [vim.log.levels.INFO] = basic_terminal and "INFO" or "ℹ INFO",
      [vim.log.levels.DEBUG] = basic_terminal and "DEBUG" or "🔧 DEBUG",
      [vim.log.levels.TRACE] = basic_terminal and "TRACE" or "🔍 TRACE"
    }
    
    -- Format the message with title if provided
    local formatted_msg = msg
    if opts.title then
      formatted_msg = symbols[level] .. " " .. opts.title .. "\n" .. formatted_msg
    else
      formatted_msg = symbols[level] .. " " .. formatted_msg
    end
    
    -- Display the message using Vim's echo system
    if level == vim.log.levels.ERROR then
      vim.cmd('echohl ErrorMsg')
    elseif level == vim.log.levels.WARN then
      vim.cmd('echohl WarningMsg')
    else
      vim.cmd('echohl None')
    end
    
    -- Split message by newlines to properly display multiline
    for _, line in ipairs(vim.split(formatted_msg, "\n")) do
      if line ~= "" then
        vim.cmd(string.format('echom "%s"', line:gsub('"', '\\"')))
      end
    end
    vim.cmd('echohl None')
  end
end

-- Make notify globally available
vim.notify = notify_module

-- Create a startup message suppression system
local suppress_messages_until_time = vim.loop.now() + 1500 -- Suppress for ~1.5 seconds
local original_vim_notify = vim.notify
vim.notify = function(msg, level, opts)
  -- During startup, suppress non-critical messages
  if vim.loop.now() < suppress_messages_until_time and level < vim.log.levels.ERROR then
    return
  end
  return original_vim_notify(msg, level, opts)
end

-- Restore normal notifications after startup
vim.defer_fn(function()
  vim.notify = original_vim_notify
end, 1500)

-- Set up global error handler for Lua errors
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  -- Special handling for Lua errors
  if level == vim.log.levels.ERROR and type(msg) == "string" then
    -- Check if this is a plugin error
    if msg:match("Error executing Lua") or msg:match("attempt to call a nil value") then
      -- Extract relevant parts of the error
      local plugin_name = msg:match("share/nvim/lazy/([^/]+)")
      local error_summary = msg:match("Error executing Lua callback: (.+)")
      
      if not error_summary then
        error_summary = msg:match("attempt to call a nil value") or "Plugin error"
      end
      
      -- Create a more user-friendly error message
      local friendly_msg = "Plugin error"
      if plugin_name then
        friendly_msg = "Plugin '" .. plugin_name .. "' error: " .. (error_summary or "initialization failed")
      end
      
      -- Add helpful suggestions
      friendly_msg = friendly_msg .. "\n\nTry these steps:\n" ..
                     "1. Update plugins with ':Lazy update'\n" ..
                     "2. Check if plugin's required dependencies are installed\n" ..
                     "3. Restart Neovim\n" ..
                     "4. If problem persists, check if plugin has GitHub issues"
      
      -- Call the original notify function with the simplified message
      return original_notify(friendly_msg, level, {
        title = "Plugin Error Detected",
        timeout = 10000, -- longer timeout for error messages
      })
    end
  end
  
  -- For all other notifications, proceed normally
  return original_notify(msg, level, opts)
end

-- Better command error handling
-- Create a wrapper for vim.api.nvim_create_user_command that includes error handling
local function create_user_command_with_error_handling(name, fn, opts)
  opts = opts or {}
  vim.api.nvim_create_user_command(name, function(command_opts)
    -- Capture any errors from command execution
    local status, result = pcall(function()
      return fn(command_opts)
    end)
    
    if not status then
      -- Format the error message to be more user friendly
      local error_msg = result
      if type(error_msg) == "string" then
        -- Clean up the error message
        error_msg = error_msg:gsub("^Vim%(.-%):", "Error:")
        error_msg = error_msg:gsub("E%d+:", "")
        error_msg = error_msg:gsub("\n%s*stack traceback:.*", "")
        error_msg = error_msg:gsub("%s+", " "):gsub("^%s+", "")
      else
        error_msg = "Unknown error occurred executing command: " .. name
      end
      
      -- Use a nicer notification format for the error
      vim.notify(error_msg, vim.log.levels.ERROR, {
        title = "Command Error: " .. name,
        icon = basic_terminal and "!" or "⚠️",
      })
    end
  end, opts)
end

-- Hook into command not found events for better error messages
vim.api.nvim_create_autocmd("CmdlineLeave", {
  callback = function()
    local cmdline = vim.fn.getcmdline()
    if vim.fn.getcmdtype() == ":" and vim.v.shell_error ~= 0 and cmdline:match("^%s*[a-zA-Z]") then
      -- This is a potential command not found error
      vim.schedule(function()
        local errmsg = vim.v.errmsg
        if errmsg:match("E492:") or errmsg:match("E492:") then
          local cmd_name = cmdline:match("^%s*(%S+)")
          if cmd_name then
            -- Provide a nicer error message for unknown commands
            vim.notify("Command not found: " .. cmd_name .. "\nCheck spelling or install the required plugin.", 
                      vim.log.levels.ERROR, {
                        title = "Unknown Command",
                        icon = basic_terminal and "?" or "❓",
                      })
          end
        end
      end)
    end
  end,
})

-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration
  'tpope/vim-repeat',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  
  -- Copilot.lua for API access (with suggestions disabled)
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
  
  -- CopilotChat.nvim for chat functionality
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

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovimßß
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      -- notification on the buffer that the LSP is attached to
      { 'j-hui/fidget.nvim',opts = {} },
    },
  },

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      -- nvim-cmp source for path
      'hrsh7th/cmp-path',
      -- nvim-cmp source for buffer words
      'hrsh7th/cmp-buffer',
      -- nvim-cmp source for vim's cmdline
      'hrsh7th/cmp-cmdline',
      -- Add lspkind for icons in completion menu
      'onsails/lspkind.nvim',
    },
  },

  {
    'stevearc/aerial.nvim',
    config = function()
      require('aerial').setup({
        -- Enable icons for various kinds, adapted for terminal type
        icons = basic_terminal and {
          Array = "Array", Boolean = "Bool", Class = "Class", Constant = "Const",
          Constructor = "Constr", Enum = "Enum", EnumMember = "EnumMem",
          Event = "Event", Field = "Field", File = "File", Function = "Func",
          Interface = "Iface", Key = "Key", Method = "Method", Module = "Module",
          Namespace = "NS", Null = "NULL", Number = "Num", Object = "Obj",
          Operator = "Op", Package = "Pkg", Property = "Prop", String = "Str",
          Struct = "Struct", TypeParameter = "TypeParam", Variable = "Var",
        } or {
          Array = "󰅪",
          Boolean = "⊨",
          Class = "󰌗",
          Constant = "󰏿",
          Constructor = "",
          Enum = "",
          EnumMember = "",
          Event = "",
          Field = "󰜢",
          File = "󰈙",
          Function = "󰊕",
          Interface = "",
          Key = "󰌋",
          Method = "󰆧",
          Module = "",
          Namespace = "󰌗",
          Null = "NULL",
          Number = "#",
          Object = "󰅩",
          Operator = "󰆕",
          Package = "󰏗",
          Property = "󰜢",
          String = "󰀬",
          Struct = "󰙅",
          TypeParameter = "󰊄",
          Variable = "󰀫",
        },
        show_guides = true,
      })
    end
  },

  -- Useful plugin to show you pending keybinds.
  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
          { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
    },
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = not basic_terminal,
        -- theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

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

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
-- vim.o.updatetime = 250
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

-- Terminal handling for better resize behavior with iTerm2
local term_augroup = vim.api.nvim_create_augroup("TerminalHandling", { clear = true })
vim.api.nvim_create_autocmd({"VimResized"}, {
  group = term_augroup,
  callback = function()
    -- Force full redraw on terminal resize
    vim.cmd("redraw!")
  end,
})

-- Fix terminal size issues
vim.api.nvim_create_autocmd("TermOpen", {
  group = term_augroup,
  pattern = "*",
  callback = function()
    -- Disable line numbers and signcolumn in terminal buffers
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()` vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Load aerial extension for telescope if available
pcall(require('telescope').load_extension, 'aerial')

-- -- See `:help telescope.builtin` for more. Try to stick with official docs or vim internal help "ALMOST ALWAYS"

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  -- auto_install = false,
  auto_install = true,


  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<leader>cs',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  -- Use standard Neovim LSP mappings
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  clangd = {},
  -- gopls = {},
  pyright = {},  -- Python LSP enabled
  -- rust_analyzer = {},
  -- tsserver = {},
  -- Use typescript-language-server for Mason
  ["typescript-language-server"] = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

-- [[ Configure nvim-cmp ]]
local cmp = require 'cmp'

-- Define has_words_before function
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

-- Initialize lspkind
local lspkind = require('lspkind')

-- Set up symbol map based on terminal capability
local symbol_map = basic_terminal and {
  Text = "Text", Method = "Method", Function = "Func", Constructor = "Constr",
  Field = "Field", Variable = "Var", Class = "Class", Interface = "Iface",
  Module = "Module", Property = "Prop", Unit = "Unit", Value = "Value",
  Enum = "Enum", Keyword = "Keyword", Snippet = "Snippet", Color = "Color",
  File = "File", Reference = "Ref", Folder = "Folder", EnumMember = "EnumMem",
  Constant = "Const", Struct = "Struct", Event = "Event", Operator = "Op",
  TypeParameter = "TypeParam"
} or {
  Text = "󰉿",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰜢",
  Variable = "󰀫",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "󰑭",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "󰈇",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "󰙅",
  Event = "",
  Operator = "󰆕",
  TypeParameter = ""
}

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noselect',
  },
  preselect = cmp.PreselectMode.None,
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    
    ['<C-e>'] = cmp.mapping.abort(),
    -- No <C-y> mapping to preserve scrolling
    
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  -- LSP-only sources, no Copilot
  sources = {
    { name = 'nvim_lsp', priority = 1000 },  
    { name = 'buffer', priority = 800, min_length = 4 },
    { name = 'path', priority = 700, min_length = 4 },
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',  -- show symbol and text annotations
      maxwidth = 50,         -- prevent the popup from showing more than provided characters
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
      -- Symbol customization
      symbol_map = symbol_map
    })
  },
  sorting = {
    -- Prioritize sources with higher priority values
    priority_weight = 2.0,  -- Double the priority weight for more aggressive sorting
    comparators = {
      cmp.config.compare.priority,  -- Make priority the first comparator
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.exact,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  experimental = {
    ghost_text = false,  -- Disable ghost text to avoid conflicts
  },
  view = {
    entries = "custom"  -- Use a custom view for better visibility of source
  },
  window = {
    completion = {
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
      col_offset = -3,
      side_padding = 0,
    },
    documentation = {
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
    },
  },
}

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  completion = {
    completeopt = 'menu,menuone,noinsert,noselect',
    autocomplete = { cmp.TriggerEvent.TextChanged },
  },
  mapping = cmp.mapping.preset.cmdline({
    ['<C-n>'] = cmp.mapping(function()
      -- Directly use Vim's command history next functionality
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down>', true, false, true), 'n', true)
    end, { 'c' }),
    ['<C-p>'] = cmp.mapping(function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Up>', true, false, true), 'n', true)
    end, { 'c' }),
    ['<CR>'] = cmp.mapping.confirm({ 
      select = false, 
      behavior = cmp.ConfirmBehavior.Replace 
    }),
    ['<C-y>'] = cmp.mapping.confirm({ 
      select = true, 
      behavior = cmp.ConfirmBehavior.Replace 
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end),
  }),
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = ({
        cmdline = "[Command]",
        path = "[Path]",
        buffer = "[Buffer]",
      })[entry.source.name] or entry.source.name
      return vim_item
    end,
  },
  sources = cmp.config.sources({
    { name = 'path', option = { trailing_slash = true } }
  }, {
    { name = 'cmdline', keyword_length = 1, max_item_count = 15 }
  })
})

-- Add debug commands to check completion sources and LSP status
create_user_command_with_error_handling('CompletionSources', function()
  local sources = {}
  table.insert(sources, "Active completion sources:")
  for _, source in ipairs(cmp.get_config().sources) do
    table.insert(sources, string.format("- %s (priority: %s)", source.name, source.priority or "not set"))
  end
  
  vim.notify(table.concat(sources, "\n"), vim.log.levels.INFO, {
    title = "Completion Sources"
  })
end, {})

-- Debug command to check which LSPs are attached to current buffer
create_user_command_with_error_handling('LspStatus', function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  
  local message = {}
  if #clients == 0 then
    table.insert(message, "No LSP clients attached to this buffer.")
  else
    table.insert(message, "LSP clients:")
    for _, client in ipairs(clients) do
      table.insert(message, string.format("- %s", client.name))
    end
  end
  
  vim.notify(table.concat(message, "\n"), vim.log.levels.INFO, {
    title = "LSP Status"
  })
end, {})

-- Function to set colorscheme based on terminal type
function SetColorScheme()
  if basic_terminal then
    vim.cmd('colorscheme retrobox') -- Use a basic colorscheme for basic terminals
  else
    vim.cmd('colorscheme catppuccin-mocha')
  end
end

-- Call the function to set the colorscheme
SetColorScheme()

vim.cmd('set autoread')
vim.cmd('au SwapExists * let v:swapchoice = "e"')

-- restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
  pattern = "*",
  callback = function()
    -- check if mark `"` exists and if it's within the range of the buffer
    local mark = vim.fn.getpos('`"')
    local line_count = vim.api.nvim_buf_line_count(0)

    if mark[1] ~= -1 and mark[2] <= line_count then
      -- if mark `"` is valid, move the cursor to its position and scroll the window
      vim.api.nvim_exec('silent! normal! g`"zv', false)
    end
  end,
})

vim.cmd[[autocmd InsertEnter * :set tabstop=2 shiftwidth=2 expandtab]]

-- Shift text in visual mode1
vim.cmd([[
  let s:save_cpo = &cpo
  set cpo&vim

  let s:pv_active = 1

  function! PV_On ()
      let s:pv_active = 1
  endfunction

  function! PV_Off ()
      let s:pv_active = 0
  endfunction

  function PV_Toggle ()
      let s:pv_active = !s:pv_active
  endfunction

  " When shifting, retain selection over multiple shifts...
  silent! xmap     <unique><silent><expr>  >  <SID>ShiftKeepingSelection(">")
  silent! xmap     <unique><silent><expr>  <  <SID>ShiftKeepingSelection("<")

  " Allow selection to persist through an undo...
  silent! xnoremap <unique><silent>        u      <ESC>ugv
  silent! xnoremap <unique><silent>        <C-R>  <ESC><C-R>gv

  function! s:ShiftKeepingSelection(cmd)
      set nosmartindent

      " No-op if plugin not active, or tab expansions are off...
      if !s:pv_active || !&expandtab
          return a:cmd . ":set smartindent\<CR>"

      " Visual and Visual Line modes...
      elseif mode() =~ '[vV]'
          return a:cmd . ":set smartindent\<CR>gv"

      " Visual block mode...
      else
          " Work out the adjustment for the way we're shifting...
          let b:_pv_shift_motion
          \   = &shiftwidth . (a:cmd == '>' ?  "\<RIGHT>" : "\<LEFT>")

          " Return instructions to implement the shift and reset selection...
          return a:cmd . ":set smartindent\<CR>uM"
      endif
  endfunction

  let &cpo = s:save_cpo
]])

vim.cmd([[
" Speed up viewport scrolling
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" Magically build interim directories if necessary
" thanks to  Author: Damian Conway
function! AskQuit (msg, options, quit_option)
  if confirm(a:msg, a:options) == a:quit_option
    exit
  endif
endfunction

function! EnsureDirExists ()
  let required_dir = expand("%:h")
  if !isdirectory(required_dir)
    call AskQuit("Parent directory '" . required_dir . "' doesn't exist.",
          \       "&Create it\nor &Quit?", 2)

    try
      call mkdir( required_dir, 'p' )
    catch
      call AskQuit("Can't create '" . required_dir . "'",
            \            "&Quit\nor &Continue anyway?", 1)
    endtry
  endif
endfunction

augroup AutoMkdir
  autocmd!
  autocmd  BufNewFile  *  :call EnsureDirExists()
augroup END


" python class

" " Damian Conway's  Blink function
nnoremap <silent> n n:call HLNext(0.1)<cr>
nnoremap <silent> N N:call HLNext(0.1)<cr>

function! HLNext (blinktime)
  let target_pat = '\c\%#'.@/
  let ring = matchadd('ErrorMsg', target_pat, 101)
  redraw
  exec 'sleep ' . float2nr(a:blinktime * 2000) . 'm'
  call matchdelete(ring)
  redraw
endfunction

" make the command mode less annoying
" Emacs(readline) binding is here
" start of line
cnoremap <C-A>     <Home>
" back one character
cnoremap <C-B>     <Left>
" delete character under cursor
cnoremap <C-D>     <Del>
" end of line
cnoremap <C-E>     <End>
" forward one character
cnoremap <C-F>     <Right>
" recall newer command-line
cnoremap <C-N>     <Down>
" recall previous (older) command-line
cnoremap <C-P>     <Up>

" back one word
inoremap <expr> <C-B> getline('.')=~'^\s*$'&&col('.')>strlen(getline('.'))?"0\<Lt>C-D>\<Lt>Esc>kJs":"\<Lt>Left>"
" delete character under cursor
inoremap <expr> <C-D> col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"
" end of line
" forward one character
inoremap <expr> <C-F> col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"


" common type-mistakes
" prese space btw
ab teh the


" Highlight Matched Parenthesis
hi MatchParen ctermbg=gray guibg=lightgray

" Better JUMP upwards and downwards
inoremap <C-k> <C-g>k
" remember, I have remapped <C-j> VIM's default Behavior
inoremap <C-j> <C-g>j

nnoremap  Y "+Y
nnoremap  y "+yy
xnoremap  Y "+Y
xnoremap  y "+y


function! HighlightAllOfWord(...)
  if exists("a:1")
    au CursorMoved * silent! exe printf('match Search /\<%s\>/', expand('<cword>'))
  endif
  if a:0 < 1
    match none /\<%s\>/
  endif
endfunction
command! -nargs=? HighlightAllOfWord  call HighlightAllOfWord(<f-args>)

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv


" STEAL FROM reactJS creator MACVIM box
function! s:VSplitIntoNextTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() < tab_nr
    close!
    if l:tab_nr == tabpagenr('$')
      tabnext
    endif
    vsp
  else
    close!
    tabnew
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc


function! s:VSplitIntoPrevTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() != 1
    close!
    if l:tab_nr == tabpagenr('$')
      tabprev
    endif
    vsp
  else
    close!
    exe "0tabnew"
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc
command! VSplitIntoPrevTab call s:VSplitIntoPrevTab()
command! VSplitIntoNextTab call s:VSplitIntoNextTab()
]])


local vim = vim

function load_large_file_async(filename, chunk_size)
  chunk_size = chunk_size or 8192  -- default chunk size
  
  local cmd = string.format("dd if=%s bs=%d", filename, chunk_size)

  -- Handler for each chunk of data
  local on_data = function(_, data, _)
    -- Process each chunk of data here
    -- For example, you can append it to a buffer
  end

  -- Handler for the end of the job
  local on_exit = function(_, exit_code, _)
    if exit_code == 0 then
      print("File loaded successfully")
    else
      print("Error loading file")
    end
  end

  -- Create an asynchronous job to read the file in chunks
  vim.fn.jobstart(cmd, {
    on_stdout = on_data,
    on_stderr = on_data,
    on_exit = on_exit,
  })
end

-- Extremely minimal terminal configuration
-- No autocmds, no complex options, just basic commands that work

-- Horizontal terminal
create_user_command_with_error_handling('Termhorizontal', function(opts)
  local size = opts.args ~= "" and opts.args or "15"
  vim.cmd(size .. "split")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, {nargs = "?"})

-- Vertical terminal
create_user_command_with_error_handling('Termvertical', function(opts)
  local size = opts.args ~= "" and opts.args or "80"
  vim.cmd(size .. "vsplit")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, {nargs = "?"})

-- Tab terminal
create_user_command_with_error_handling('Termnew', function()
  vim.cmd("tabnew")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, {})

-- Floating terminal
create_user_command_with_error_handling('Termfloat', function()
  -- Calculate dimensions
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Create empty buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Create window
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded"
  }
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  
  -- Open terminal in buffer
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, {})

-- Alias Term to horizontal split
create_user_command_with_error_handling('Term', function(opts)
  vim.cmd("Termhorizontal " .. opts.args)
end, {nargs = "?"})

-- Simple terminal mode mappings (without autocmd)
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l')

-- Configure Oil with icons based on terminal capability
require("oil").setup({
  -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
  -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
  default_file_explorer = true,
  -- Id is automatically added at the beginning, and name at the end
  -- See :help oil-columns
  columns = {
    "icon",
    -- "permissions",
    -- "size",
    -- "mtime",
  },
  -- Buffer-local options to use for oil buffers
  buf_options = {
    buflisted = false,
    bufhidden = "hide",
  },
  -- Window-local options to use for oil buffers
  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = "nvic",
  },
  -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
  delete_to_trash = false,
  -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
  skip_confirm_for_simple_edits = false,
  -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
  -- (:help prompt_save_on_select_new_entry)
  prompt_save_on_select_new_entry = true,
  -- Oil will automatically delete hidden buffers after this delay
  -- You can set the delay to false to disable cleanup entirely
  -- Note that the cleanup process only starts when none of the oil buffers are currently displayed
  cleanup_delay_ms = 2000,
  -- View options for the file explorer
  view_options = {
    -- Show files and directories that start with "."
    show_hidden = false,
  },
})

-- Store the diagnostic state (modern approach)

-- Command to toggle both virtual text and sign column indicators
local virtual_text_enabled = false
create_user_command_with_error_handling('Togglediagnostics', function()
  virtual_text_enabled = not virtual_text_enabled
  
  if virtual_text_enabled then
    -- Enable both virtual text and sign column
    vim.diagnostic.config({
      virtual_text = {
        spacing = 4,
        prefix = basic_terminal and "*" or "■", -- Use a custom prefix based on terminal type
        format = function(diagnostic)
          -- Format message to be more concise
          local message = diagnostic.message
          if #message > 50 then
            message = message:sub(1, 47) .. "..."
          end
          return message
        end,
      },
      signs = {
        priority = 20,
        text = {
          [vim.diagnostic.severity.ERROR] = 'E',
          [vim.diagnostic.severity.WARN] = 'W',
          [vim.diagnostic.severity.INFO] = 'I',
          [vim.diagnostic.severity.HINT] = 'H',
        },
      }
    })
    
    -- Make sure sign column is visible
    vim.opt.signcolumn = "yes"
    print("Diagnostic indicators enabled (virtual text and sign column)")
  else
    -- Disable both virtual text and sign column
    vim.diagnostic.config({
      virtual_text = false,
      signs = false  -- Disable diagnostic signs completely
    })
    
    -- Check if we can hide the sign column (only if no other features need it)
    local hide_sign_column = true
    
    -- Keep sign column if git signs or other features are active
    -- Use proper Lua syntax for accessing Vim functions
    if vim.fn.exists('*gitsigns#get_hunks') == 1 then
      -- Use square bracket notation for functions with special characters
      local hunks = vim.fn['gitsigns#get_hunks']()
      if hunks and #hunks > 0 then
        hide_sign_column = false
      end
    end
    
    -- Try using the Lua API directly if available
    local gs_ok, gs = pcall(require, 'gitsigns')
    if gs_ok and gs.get_hunks and gs.get_hunks() then
      hide_sign_column = false
    end
    
    -- Set sign column based on our decision
    if hide_sign_column then
      vim.opt.signcolumn = "no"
    end
    
    print("Diagnostic indicators disabled (virtual text and sign column)")
  end
end, {})

-- Create an autocmd to disable diagnostics on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Disable virtual text
    vim.diagnostic.config({ virtual_text = false, signs = false })
    
    -- Clear any existing diagnostics
    pcall(function()
      for _, namespace in ipairs(vim.diagnostic.get_namespaces()) do
        vim.diagnostic.reset(namespace)
      end
    end)
    
    -- Set our state variable to match
    virtual_text_enabled = false
    
    -- Hide sign column if it's safe to do so
    local hide_sign_column = true
    
    -- Check for git signs before hiding
    local gs_ok, gs = pcall(require, 'gitsigns')
    if gs_ok and gs.get_hunks then
      -- More robust handling of get_hunks
      local hunks_ok, hunks = pcall(function() 
        return gs.get_hunks() 
      end)
      
      if hunks_ok and hunks and type(hunks) == "table" and #hunks > 0 then
        hide_sign_column = false
      end
    end
    
    -- Only hide sign column if safe
    if hide_sign_column then
      vim.opt.signcolumn = "no"
    end
  end,
  group = vim.api.nvim_create_augroup("DisableDiagnosticsOnStartup", { clear = true }),
  desc = "Disable diagnostics when Neovim starts",
})

-- Neovim 0.10 compatible mapping conflict detector
-- Focuses on detecting conflicts within the same mode

local mapping_conflicts = {}

-- Function to find conflicting key mappings in the same mode
function mapping_conflicts.find_same_mode_conflicts()
  -- Modes to check
  local modes = {
    n = "Normal",
    i = "Insert", 
    v = "Visual",
    x = "Visual Block",
    s = "Select",
    t = "Terminal"
  }
  
  local all_mappings = {}
  local conflicts = {}
  
  -- Get all mappings for each mode
  for mode_char, mode_name in pairs(modes) do
    all_mappings[mode_char] = {}
    
    -- Get mappings using vim.api
    local ok, mappings = pcall(vim.api.nvim_get_keymap, mode_char)
    if not ok then
      vim.notify("Error getting keymaps for mode " .. mode_name, vim.log.levels.ERROR)
      goto continue
    end
    
    -- Process each mapping
    for _, map in ipairs(mappings) do
      local lhs = map.lhs  -- The key combination
      
      -- Skip special keys like mouse actions if needed
      if string.match(lhs, "^<.*mouse") then
        goto skip_mapping
      end
      
      local rhs = map.rhs or "[Lua function]"
      if map.callback ~= nil then
        rhs = "[Lua callback]"
      end
      local buffer = map.buffer and tonumber(map.buffer) or "global"
      -- Store mapping details
      if not all_mappings[mode_char][lhs] then
        all_mappings[mode_char][lhs] = {}
      end
      -- Try to get the source file
      local source = "Unknown"
      if vim.fn.has("nvim-0.9") == 1 then
        if map.desc and map.desc:match("defined at") then
          source = map.desc:match("defined at (.+)")
        else
          -- Try the verbose map command approach for older versions
          local ok, output = pcall(vim.fn.execute, mode_char .. "map " .. vim.fn.escape(lhs, '\\'))
          if ok then
            local src_match = output:match("Last set from (.+)")
            if src_match then
              source = src_match
            end
          end
        end
      end
      table.insert(all_mappings[mode_char][lhs], {
        rhs = rhs,
        buffer = buffer,
        source = source,
        mode = mode_name,
        noremap = map.noremap == 1,
        silent = map.silent == 1,
        expr = map.expr == 1,
        desc = map.desc or ""
      })
      -- Check if we have a conflict in this mode (multiple mappings for same key)
      if #all_mappings[mode_char][lhs] > 1 then
        if not conflicts[mode_char] then 
          conflicts[mode_char] = {} 
        end
        conflicts[mode_char][lhs] = all_mappings[mode_char][lhs]
      end
      
      ::skip_mapping::
    end
    
    ::continue::
  end
  
  -- Format same-mode conflicts
  local results = {}
  
  for mode_char, mode_conflicts in pairs(conflicts) do
    for lhs, details in pairs(mode_conflicts) do
      table.insert(results, {
        key = lhs,
        mode = modes[mode_char],
        mode_char = mode_char,
        mappings = details
      })
    end
  end
  -- Sort results by mode then key for better readability
  table.sort(results, function(a, b)
    if a.mode == b.mode then
      return a.key < b.key
    end
    return a.mode < b.mode
  end)
  return results
end

-- Function to display conflicts in a friendly format
function mapping_conflicts.display_conflicts()
  local conflicts = mapping_conflicts.find_same_mode_conflicts()
  -- Clear the command line
  vim.cmd("echo ''")
  if #conflicts > 0 then
    vim.notify("Found " .. #conflicts .. " key mapping conflicts", vim.log.levels.INFO)
    print("====== SAME MODE KEY MAPPING CONFLICTS ======")
    local current_mode = nil
    for _, conflict in ipairs(conflicts) do
      -- Print mode header if we're in a new mode
      if current_mode ~= conflict.mode then
        current_mode = conflict.mode
        print("\n=== " .. current_mode .. " Mode ===")
      end
      print(string.format("\nKey: %s has %d different mappings:", 
        vim.inspect(conflict.key), #conflict.mappings))
      for i, mapping in ipairs(conflict.mappings) do
        print(string.format("  %d. Maps to: %s", i, vim.inspect(mapping.rhs)))
        print(string.format("     Source: %s", mapping.source))
        print(string.format("     Buffer: %s", tostring(mapping.buffer)))
        local flags = {}
        if mapping.noremap then table.insert(flags, "noremap") end
        if mapping.silent then table.insert(flags, "silent") end
        if mapping.expr then table.insert(flags, "expr") end
        if mapping.desc and mapping.desc ~= "" then
          print(string.format("     Description: %s", mapping.desc))
        end
        if #flags > 0 then
          print(string.format("     Flags: %s", table.concat(flags, ", ")))
        end
      end
    end
  else
    vim.notify("No mapping conflicts found within the same mode", vim.log.levels.INFO)
  end
  return conflicts
end

-- Create a user command to run the function
create_user_command_with_error_handling('FindMappingConflicts', function()
  mapping_conflicts.display_conflicts()
end, {
  desc = "Find conflicting key mappings in the same mode"
})

-- Using Lua functions
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- Treesitter folding with Lua
-- Later make a function to manage this, like wrap it inside a lua functions

-- Set global default foldmethod to 'manual'
vim.o.foldmethod = 'manual'

-- Define the toggle function
local function toggle_folding()
  if vim.wo.foldmethod == 'manual' then
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    print("Folding enabled with Treesitter")
  else
    vim.wo.foldmethod = 'manual'
    print("Folding disabled")
  end
end

-- Optionally, create a user command to call the function
create_user_command_with_error_handling('ToggleFolding', toggle_folding, {})

-- Detect OS and configure clipboard
local function setup_clipboard()
  local system = vim.loop.os_uname().sysname
  
  if system == "Darwin" then
    -- macOS - native clipboard should work automatically
    vim.opt.clipboard = "unnamedplus"
    return
  end
  
  -- For Linux, check if we're in SSH
  local is_ssh = (vim.env.SSH_TTY ~= nil or vim.env.SSH_CLIENT ~= nil or vim.env.SSH_CONNECTION ~= nil)
  
  if is_ssh then
    -- Configure OSC52 for SSH sessions
    vim.g.clipboard = 'osc52'
  else
    -- Check for X11 or Wayland
    if vim.env.DISPLAY or vim.env.WAYLAND_DISPLAY then
      -- GUI environment, let Neovim auto-detect (xclip, etc.)
      vim.g.clipboard = nil
    else
      -- TTY environment, use OSC52
      vim.g.clipboard = 'osc52'
    end
  end
  
  -- Use clipboard for all operations
  vim.opt.clipboard = "unnamedplus"
end
setup_clipboard()


-- Override the symbols picker to disable it
-- For telescope
local status, telescope_builtin = pcall(require, "telescope.builtin")
if status then
  telescope_builtin.symbols = function()
    vim.notify("Symbols picker is disabled", vim.log.levels.INFO)
  end
end


-- Default cursor line settings
vim.opt.cursorline = false
vim.opt.cursorlineopt = "line"  -- Highlight both line and line number

-- Cursor appearance configuration
local function setup_cursor_highlight()
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

-- Set up cursor highlighting
setup_cursor_highlight()

-- Cursor shape configuration (compatible with Terminal.app, iTerm2, and Ubuntu Terminal)
if not basic_terminal then
  vim.opt.guicursor = 
    "n-v-c:block," ..   -- Normal mode: block cursor
    "i-ci-ve:ver25," ..  -- Insert mode: vertical bar
    "r-cr-o:hor20"       -- Replace mode: horizontal bar
end

-- Cursor blinking (subtle, not too distracting)
vim.opt.guicursor:append("a:blinkwait175-blinkon200-blinkoff150")

-- Toggle cursor line command
create_user_command_with_error_handling('ToggleCursor', function()
  vim.o.cursorline = not vim.o.cursorline
  print(vim.o.cursorline and "Cursor highlight enabled" or "Cursor highlight disabled")
end, {})

-- Autocommand to reset highlights when colorscheme changes
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = setup_cursor_highlight
})

vim.api.nvim_set_hl(0, 'Visual', {
  bg = basic_terminal and "#3a3a3a" or "#3a3a3a",
  ctermbg = 237,  -- Higher contrast background for better visibility
})
