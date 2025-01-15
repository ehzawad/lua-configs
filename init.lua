-- ehzawad@gmail.com; email me to say hi or if there are any questions
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  -- surround delimiters
  'tpope/vim-surround',
  -- repeat delimiters
  'tpope/vim-repeat',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  'zbirenbaum/copilot.lua',

  {
    'f-person/git-blame.nvim',
    config = function()
      vim.g.gitblame_enabled = 1
      vim.g.gitblame_message_template = '  <author> • <date> • <summary>'
      vim.g.gitblame_date_format = '%r'
      vim.g.gitblame_highlight_group = 'Comment'
    end
  },
  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  { "catppuccin/nvim",         name = "catppuccin", priority = 1000 },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

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

  {

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
      scope_incremental = '<c-s>',
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
  -- pyright = {},
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

-- Setup neovim lua configuration
require('neodev').setup()

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
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),

    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-y>'] = cmp.mapping.confirm({select = true}),

    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    {name = 'copilot'},
    {name = 'nvim_lsp'},
    {name = 'luasnip'},
    {name = 'buffer', min_length = 4},
    {name = 'path', min_length = 4},
  },
}

require("copilot").setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})


local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end
cmp.setup({
  mapping = {
    ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end),
  },
})

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

  " Hit <RETURN> to escape visual mode...
  silent! xnoremap <unique><silent>        <CR>   <ESC>

  " Hit ZZ to quit from within visual mode...
  silent! xnoremap <unique><silent>        ZZ     <ESC>ZZ

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

-- Terminal stuff
vim.cmd([[ command! Term :botright sp | term ]])
vim.cmd([[ command! Termvsp :vertical sp | term ]])

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

-- https://github.com/f-person/git-blame.nvim
vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text

local git_blame = require('gitblame')

require('lualine').setup({
  sections = {
    lualine_c = {
      { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available }
    }
  }
})


-- python symbolic representation
local function python_symbols(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local file_extension = vim.fn.expand('%:e')
  if file_extension ~= 'py' and file_extension ~= 'pyc' then
    return
  end
  local parser = vim.treesitter.get_parser(bufnr, 'python')
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = vim.treesitter.query.parse('python', [[
    (class_definition name: (identifier) @class)
    (function_definition name: (identifier) @function)
    (decorator) @decorator
    (assignment left: (identifier) @variable)
    (import_from_statement name: (dotted_name) @import)
    (import_statement name: (dotted_name) @import)
    (parameter name: (identifier) @parameter)
  ]])
  local symbols = {classes = {}, functions = {}, variables = {}, decorators = {}, imports = {}, parameters = {}}
  local positions = {}
  local function get_scope(node)
    local scope = {}
    local parent = node:parent()
    while parent do
      local parent_type = parent:type()
      if parent_type == "class_definition" then
        table.insert(scope, 1, "Class: " .. vim.treesitter.get_node_text(parent:field("name")[1], bufnr))
      elseif parent_type == "function_definition" then
        table.insert(scope, 1, "Function: " .. vim.treesitter.get_node_text(parent:field("name")[1], bufnr))
      end
      parent = parent:parent()
    end
    if #scope == 0 then
      return "Global"
    else
      return table.concat(scope, " > ")
    end
  end
  local start_row, start_col, end_row, end_col = root:range()
  for id, node in query:iter_captures(root, bufnr, start_row, end_row) do
    local name = vim.treesitter.get_node_text(node, bufnr)
    local row, col = node:start()
    local node_type = query.captures[id]  -- Capture name
    local scope = get_scope(node)
    local entry = {
      value = name,
      display = string.format("%s [%s]", name, scope),
      ordinal = name,
      loc = {row, col},
      kind = node_type
    }
    if node_type == "class" then
      table.insert(symbols.classes, entry)
    elseif node_type == "function" then
      table.insert(symbols.functions, entry)
    elseif node_type == "variable" then
      table.insert(symbols.variables, entry)
    elseif node_type == "decorator" then
      table.insert(symbols.decorators, entry)
    elseif node_type == "import" then
      table.insert(symbols.imports, entry)
    elseif node_type == "parameter" then
      table.insert(symbols.parameters, entry)
    end
  end
  local flattened_symbols = {}
  for _, class in ipairs(symbols.classes) do
    table.insert(flattened_symbols, class)
  end
  for _, decorator in ipairs(symbols.decorators) do
    table.insert(flattened_symbols, decorator)
  end
  for _, func in ipairs(symbols.functions) do
    table.insert(flattened_symbols, func)
  end
  for _, variable in ipairs(symbols.variables) do
    table.insert(flattened_symbols, variable)
  end
  for _, import in ipairs(symbols.imports) do
    table.insert(flattened_symbols, import)
  end
  for _, param in ipairs(symbols.parameters) do
    table.insert(flattened_symbols, param)
  end
  require('telescope.pickers').new(opts, {
    prompt_title = 'Python Symbols',
    finder = require('telescope.finders').new_table {
      results = flattened_symbols,
      entry_maker = function(entry)
        return entry
      end
    },
    sorter = require('telescope.config').values.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      local function goto_location()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.api.nvim_win_set_cursor(0, {selection.loc[1] + 1, selection.loc[2]})
        vim.cmd("normal! zz")
      end
      map('i', '<CR>', goto_location)
      map('n', '<CR>', goto_location)
      return true
    end
  }):find()
end

vim.api.nvim_create_user_command('PythonSymbols', function()
  python_symbols()
end, {})
--
local function find_python_class_boundaries()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    
    -- Find class start (searching backwards from cursor)
    local class_start = cursor_line
    while class_start > 0 do
        local line = lines[class_start]
        -- Match class definition at start of line (ignoring whitespace)
        -- but not in comments
        if line:match("^%s*class%s+%w+") and not line:match("^%s*#") then
            break
        end
        class_start = class_start - 1
    end
    
    if class_start == 0 then
        return nil, nil
    end
    
    -- Find class end 
    local class_end = class_start
    local base_indent = #(lines[class_start]:match("^%s*") or "")
    
    for i = class_start + 1, #lines do
        local line = lines[i]
        -- Skip empty lines and comments
        if line:match("^%s*$") or line:match("^%s*#") then
            class_end = i
            goto continue
        end
        
        -- Check for next class definition
        if line:match("^%s*class%s+%w+") then
            local indent = #(line:match("^%s*") or "")
            if indent <= base_indent then
                class_end = i - 1
                break
            end
        end
        
        -- Check indentation level
        local indent = #(line:match("^%s*") or "")
        if not line:match("^%s*$") and indent <= base_indent and not line:match("^%s*#") then
            class_end = i - 1
            break
        end
        
        class_end = i
        ::continue::
    end
    
    return class_start, class_end
end

-- Create the keymap
vim.keymap.set('n', '<leader>vc', function()
    local start_line, end_line = find_python_class_boundaries()
    if not start_line then
        vim.notify("No Python class found at cursor position", vim.log.levels.WARN)
        return
    end
    
    -- Move to start line and enter Visual line mode
    vim.cmd(string.format("normal! %dGV%dG", start_line, end_line))
    
    -- Notify user about the correct delete command
    vim.notify("Class selected. Press 'd' to delete or 'ESC' to cancel", vim.log.levels.INFO)
end, {
    desc = "Visually select Python class under cursor",
    buffer = true
})
-- Optional: Add a direct delete mapping if you want both options
vim.keymap.set('n', '<leader>dc', function()
    local start_line, end_line = find_python_class_boundaries()
    if not start_line then
        vim.notify("No Python class found at cursor position", vim.log.levels.WARN)
        return
    end
    
    -- Delete the class
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {})
    
    -- Position cursor at the deletion point
    vim.api.nvim_win_set_cursor(0, {start_line, 0})
    
    vim.notify("Python class deleted", vim.log.levels.INFO)
end, {
    desc = "Delete Python class under cursor",
    buffer = true
})
