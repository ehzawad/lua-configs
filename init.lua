-- ehzawad@gmail.com; email me to say hi or if there are any questions
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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

-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration
  'tpope/vim-repeat',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  'zbirenbaum/copilot.lua',

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

  { "catppuccin/nvim",         name = "catppuccin", priority = 1000 },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
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
    },
  },

  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
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
        icons_enabled = false,
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
  { 'numToStr/Comment.nvim',         opts = {} },

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

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

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

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,menuone,noselect'
-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

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
--
--
-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
--
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

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
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
  -- clangd = {},
  -- gopls = {},
  pyright = {},  -- Python LSP enabled
  -- rust_analyzer = {},
  -- tsserver = {},
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

-- Copilot configuration - simple setup that works with both modes
require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = "<M-l>",
      accept_word = "<M-w>",
      accept_line = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<M-]>",
    },
  },
  panel = { enabled = false },
  filetypes = {
    python = true,
    lua = true,
    ["*"] = true,
  },
})


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
  -- Flat list of sources with explicit priorities
  sources = {
    { name = 'nvim_lsp', priority = 1000 },  
    { name = 'buffer', priority = 800, min_length = 4 },
    { name = 'path', priority = 700, min_length = 4 },
    { name = 'copilot', priority = 100 },  -- Much lower priority for Copilot
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
  }
}

-- Create a state variable for the toggle
vim.g.copilot_mode = "lsp" -- "lsp" or "copilot"

-- Toggle function that completely disables LSP in Copilot mode
vim.api.nvim_create_user_command('Pilott', function()
  if vim.g.copilot_mode == "lsp" then
    -- Switch to Copilot-only mode - NO LSP SOURCES
    vim.g.copilot_mode = "copilot"
    
    -- Setup with ONLY Copilot and basic sources, NO LSP
    cmp.setup {
      sources = {
        { name = 'copilot', priority = 1000 },
        { name = 'buffer', priority = 300, min_length = 4 },
        { name = 'path', priority = 250, min_length = 4 },
      },
      -- Keep other settings the same
    }
    
    -- Make sure Copilot is enabled
    vim.cmd("Copilot enable")
    
    print("Copilot-only mode enabled (LSP suggestions disabled)")
  else
    -- Switch back to LSP-first mode with all sources
    vim.g.copilot_mode = "lsp"
    
    -- Setup with LSP having highest priority and all sources restored
    cmp.setup {
      sources = {
        { name = 'nvim_lsp', priority = 1000 },
        { name = 'buffer', priority = 800, min_length = 4 },
        { name = 'path', priority = 700, min_length = 4 },
        { name = 'copilot', priority = 100 },
      },
    }
    
    print("LSP-first mode enabled (all completion sources active)")
  end
end, {})

-- Add debug commands to check completion sources and LSP status
vim.api.nvim_create_user_command('CompletionSources', function()
  print("Active completion sources:")
  for _, source in ipairs(cmp.get_config().sources) do
    print(string.format("- %s (priority: %s)", source.name, source.priority or "not set"))
  end
end, {})

-- Debug command to check which LSPs are attached to current buffer
vim.api.nvim_create_user_command('LspStatus', function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to this buffer.")
  else
    print("LSP clients:")
    for _, client in ipairs(clients) do
      print(string.format("- %s", client.name))
    end
  end
end, {})

-- Function to set colorscheme
function SetColorScheme()
  vim.cmd('colorscheme catppuccin-mocha')
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


local function python_symbols(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Only process Python files
  local file_extension = vim.fn.expand('%:e')
  if file_extension ~= 'py' and file_extension ~= 'pyc' then
    return
  end
  
  -- Get parser and tree
  local parser = vim.treesitter.get_parser(bufnr, 'python')
  local tree = parser:parse()[1]
  local root = tree:root()
  
  -- Collect all symbols
  local symbols = {}
  
  -- Simple query for basic symbols
  local query = vim.treesitter.query.parse('python', [[
    (class_definition name: (identifier) @class)
    (function_definition name: (identifier) @function)
    (decorator (identifier) @decorator)
    (assignment left: (identifier) @variable)
  ]])
  
  -- Get parent context
  local function get_context(node)
    local result = "Global"
    local parent = node:parent()
    while parent do
      if parent:type() == "class_definition" then
        for i = 0, parent:named_child_count() - 1 do
          local child = parent:named_child(i)
          if child:type() == "identifier" then
            result = "Class: " .. vim.treesitter.get_node_text(child, bufnr)
            break
          end
        end
      end
      parent = parent:parent()
    end
    return result
  end
  
  -- Capture nodes
  local start_row, _, end_row, _ = root:range()
  for id, node in query:iter_captures(root, bufnr, start_row, end_row) do
    local name = vim.treesitter.get_node_text(node, bufnr)
    local row, col = node:start()
    local type_name = query.captures[id]
    local context = get_context(node)
    
    -- Add prefix to decorators
    if type_name == "decorator" then
      name = "@" .. name
    end
    
    table.insert(symbols, {
      name = name,
      row = row,
      col = col,
      type = type_name,
      context = context
    })
  end
  
  -- Sort symbols
  table.sort(symbols, function(a, b)
    if a.type ~= b.type then
      if a.type == "class" then return true end
      if b.type == "class" then return false end
      if a.type == "decorator" then return true end
      if b.type == "decorator" then return false end
      if a.type == "function" then return true end
      if b.type == "function" then return false end
      return false
    else
      return a.row < b.row
    end
  end)
  
  -- Prepare display list
  local display_symbols = {}
  for _, symbol in ipairs(symbols) do
    table.insert(display_symbols, {
      value = symbol,
      display = symbol.name .. " [" .. symbol.context .. "] (" .. symbol.type .. ")",
      ordinal = symbol.name,
      lnum = symbol.row + 1,
      col = symbol.col + 1
    })
  end
  
  -- Display in Telescope
  require('telescope.pickers').new(opts, {
    prompt_title = 'Python Symbols',
    finder = require('telescope.finders').new_table({
      results = display_symbols,
      entry_maker = function(entry)
        return entry
      end
    }),
    sorter = require('telescope.config').values.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.api.nvim_win_set_cursor(0, {selection.lnum, selection.col - 1})
        vim.cmd("normal! zz")
      end)
      return true
    end
  }):find()
end

vim.api.nvim_create_user_command('PythonSymbols', function()
  python_symbols()
end, {})



local function capture_python_node(node_type, innermost_only)
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Only process Python files
  local file_extension = vim.fn.expand('%:e')
  if file_extension ~= 'py' and file_extension ~= 'pyc' then
    vim.notify("Not a Python file", vim.log.levels.WARN)
    return
  end
  
  -- Get current cursor position
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1 -- Convert to 0-indexed
  
  -- Get parser and tree
  local parser = vim.treesitter.get_parser(bufnr, 'python')
  local tree = parser:parse()[1]
  local root = tree:root()
  
  -- Target node types
  local target_type
  if node_type == "class" then
    target_type = "class_definition"
  else
    target_type = "function_definition"
  end
  
  -- Find the smallest node at cursor position
  local node_at_cursor = root:named_descendant_for_range(cursor_row, cursor_col, cursor_row, cursor_col)
  if not node_at_cursor then
    vim.notify("No node found at cursor position", vim.log.levels.WARN)
    return
  end
  
  -- Collect all nodes of the target type from cursor to root
  local target_nodes = {}
  local current_node = node_at_cursor
  
  while current_node do
    if current_node:type() == target_type then
      table.insert(target_nodes, current_node)
    end
    current_node = current_node:parent()
  end
  
  if #target_nodes == 0 then
    vim.notify("No " .. node_type .. " found at or containing cursor position", vim.log.levels.WARN)
    return
  end
  
  -- Select the appropriate node based on the innermost_only flag
  local target_node
  if innermost_only then
    -- Take the innermost (first found from cursor)
    target_node = target_nodes[1]
  else
    -- Take the outermost (last found going up to root)
    target_node = target_nodes[#target_nodes]
  end
  
  -- Get node range
  local start_row, start_col, end_row, end_col = target_node:range()
  
  -- Convert to 1-indexed for Vim and select in visual mode
  vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, {end_row + 1, end_col})
end

-- Register commands
vim.api.nvim_create_user_command('PythonCaptureInnerFunction', function()
  capture_python_node("function", true)
end, {})

vim.api.nvim_create_user_command('PythonCaptureInnerClass', function()
  capture_python_node("class", true)
end, {})

vim.api.nvim_create_user_command('PythonCaptureOuterFunction', function()
  capture_python_node("function", false)
end, {})

vim.api.nvim_create_user_command('PythonCaptureOuterClass', function()
  capture_python_node("class", false)
end, {})

-- Create key mappings for normal mode
vim.api.nvim_set_keymap('n', '<leader>vif', ':PythonCaptureInnerFunction<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>vic', ':PythonCaptureInnerClass<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>vof', ':PythonCaptureOuterFunction<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>voc', ':PythonCaptureOuterClass<CR>', { noremap = true, silent = true })

-- Extremely minimal terminal configuration
-- No autocmds, no complex options, just basic commands that work

-- Horizontal terminal
vim.api.nvim_create_user_command('Termhorizontal', function(opts)
  local size = opts.args ~= "" and opts.args or "15"
  vim.cmd(size .. "split")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, {nargs = "?"})

-- Vertical terminal
vim.api.nvim_create_user_command('Termvertical', function(opts)
  local size = opts.args ~= "" and opts.args or "80"
  vim.cmd(size .. "vsplit")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, {nargs = "?"})

-- Tab terminal
vim.api.nvim_create_user_command('Termnew', function()
  vim.cmd("tabnew")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, {})

-- Floating terminal
vim.api.nvim_create_user_command('Termfloat', function()
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
vim.api.nvim_create_user_command('Term', function(opts)
  vim.cmd("Termhorizontal " .. opts.args)
end, {nargs = "?"})

-- Simple terminal mode mappings (without autocmd)
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l')

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
  lsp_file_methods = {
    -- Enable or disable LSP file operations
    enabled = true,
    -- Time to wait for LSP file operations to complete before skipping
    timeout_ms = 1000,
    -- Set to true to autosave buffers that are updated with LSP willRenameFiles
    -- Set to "unmodified" to only save unmodified buffers
    autosave_changes = false,
  },
  -- Constrain the cursor to the editable parts of the oil buffer
  -- Set to `false` to disable, or "name" to keep it on the file names
  constrain_cursor = "editable",
  -- Set to true to watch the filesystem for changes and reload oil
  watch_for_changes = false,
  -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
  -- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
  -- Additionally, if it is a string that matches "actions.<name>",
  -- it will use the mapping at require("oil.actions").<name>
  -- Set to `false` to remove a keymap
  -- See :help oil-actions for a list of all available actions
  keymaps = {
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = { "actions.close", mode = "n" },
    ["<C-l>"] = "actions.refresh",
    ["-"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
    ["gs"] = { "actions.change_sort", mode = "n" },
    ["gx"] = "actions.open_external",
    ["g."] = { "actions.toggle_hidden", mode = "n" },
    ["g\\"] = { "actions.toggle_trash", mode = "n" },
  },
  -- Set to false to disable all of the above keymaps
  use_default_keymaps = true,
  view_options = {
    -- Show files and directories that start with "."
    show_hidden = false,
    -- This function defines what is considered a "hidden" file
    is_hidden_file = function(name, bufnr)
      local m = name:match("^%.")
      return m ~= nil
    end,
    -- This function defines what will never be shown, even when `show_hidden` is set
    is_always_hidden = function(name, bufnr)
      return false
    end,
    -- Sort file names with numbers in a more intuitive order for humans.
    -- Can be "fast", true, or false. "fast" will turn it off for large directories.
    natural_order = "fast",
    -- Sort file and directory names case insensitive
    case_insensitive = false,
    sort = {
      -- sort order can be "asc" or "desc"
      -- see :help oil-columns to see which columns are sortable
      { "type", "asc" },
      { "name", "asc" },
    },
    -- Customize the highlight group for the file name
    highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
      return nil
    end,
  },
  -- Extra arguments to pass to SCP when moving/copying files over SSH
  extra_scp_args = {},
  -- EXPERIMENTAL support for performing file operations with git
  git = {
    -- Return true to automatically git add/mv/rm files
    add = function(path)
      return false
    end,
    mv = function(src_path, dest_path)
      return false
    end,
    rm = function(path)
      return false
    end,
  },
  -- Configuration for the floating window in oil.open_float
  float = {
    -- Padding around the floating window
    padding = 2,
    -- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    max_width = 0,
    max_height = 0,
    border = "rounded",
    win_options = {
      winblend = 0,
    },
    -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
    get_win_title = nil,
    -- preview_split: Split direction: "auto", "left", "right", "above", "below".
    preview_split = "auto",
    -- This is the config that will be passed to nvim_open_win.
    -- Change values here to customize the layout
    override = function(conf)
      return conf
    end,
  },
  -- Configuration for the file preview window
  preview_win = {
    -- Whether the preview window is automatically updated when the cursor is moved
    update_on_cursor_moved = true,
    -- How to open the preview window "load"|"scratch"|"fast_scratch"
    preview_method = "fast_scratch",
    -- A function that returns true to disable preview on a file e.g. to avoid lag
    disable_preview = function(filename)
      return false
    end,
    -- Window-local options to use for preview window buffers
    win_options = {},
  },
  -- Configuration for the floating action confirmation window
  confirmation = {
    -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a single value or a list of mixed integer/float types.
    -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
    max_width = 0.9,
    -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
    min_width = { 40, 0.4 },
    -- optionally define an integer/float for the exact width of the preview window
    width = nil,
    -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_height and max_height can be a single value or a list of mixed integer/float types.
    -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
    max_height = 0.9,
    -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
    min_height = { 5, 0.1 },
    -- optionally define an integer/float for the exact height of the preview window
    height = nil,
    border = "rounded",
    win_options = {
      winblend = 0,
    },
  },
  -- Configuration for the floating progress window
  progress = {
    max_width = 0.9,
    min_width = { 40, 0.4 },
    width = nil,
    max_height = { 10, 0.9 },
    min_height = { 5, 0.1 },
    height = nil,
    border = "rounded",
    minimized_border = "none",
    win_options = {
      winblend = 0,
    },
  },
  -- Configuration for the floating SSH window
  ssh = {
    border = "rounded",
  },
  -- Configuration for the floating keymaps help window
  keymaps_help = {
    border = "rounded",
  },
})



-- Store the diagnostic state (modern approach)

-- Command to toggle both virtual text and sign column indicators
vim.api.nvim_create_user_command('Togglediagnostics', function()
  virtual_text_enabled = not virtual_text_enabled
  
  if virtual_text_enabled then
    -- Enable both virtual text and sign column
    vim.diagnostic.config({
      virtual_text = {
        spacing = 4,
        prefix = "■", -- Use a custom prefix
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
    for _, namespace in ipairs(vim.diagnostic.get_namespaces()) do
      vim.diagnostic.reset(namespace)
    end
    
    -- Set our state variable to match
    virtual_text_enabled = false
    
    -- Hide sign column if it's safe to do so
    local hide_sign_column = true
    
    -- Check for git signs before hiding
    local gs_ok, gs = pcall(require, 'gitsigns')
    if gs_ok and gs.get_hunks then
      local hunks = gs.get_hunks()
      if hunks and #hunks > 0 then
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
vim.api.nvim_create_user_command('FindMappingConflicts', function()
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

-- Set foldmethod to 'expr' and foldexpr to the Lua PythonCaptureOuterFunction

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
vim.api.nvim_create_user_command('ToggleFolding', toggle_folding, {})
