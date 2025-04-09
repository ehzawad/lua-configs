-- ~/.config/nvim/lua/plugins/completion.lua
-- Completion system configuration
-- Author: ehzawad@gmail.com

local basic_terminal = require('utils.terminal').basic_terminal

-- Define has_words_before function
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

-- Initialize nvim-cmp
local function setup_cmp()
  local cmp = require('cmp')
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
      ['<S-Tab>'] = cmp.mapping.select_next_item(),
      ['Esc'] = cmp.mapping.abort(),
      -- Control accept...here CR for lsp accept...and Tab for codeium accept
      ['<CR>'] = cmp.mapping.confirm { 
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,  -- Only select if explicitly navigated
      },
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
        function(entry1, entry2)
          local kind_priority = {
            [cmp.lsp.CompletionItemKind.Method]   = 1,
            [cmp.lsp.CompletionItemKind.Function] = 2,
            [cmp.lsp.CompletionItemKind.Property] = 3,
            -- Add other kinds as needed with your desired priorities
          }
          local kind1 = kind_priority[entry1:get_kind()] or 100
          local kind2 = kind_priority[entry2:get_kind()] or 100

          if kind1 < kind2 then
            return true
          elseif kind1 > kind2 then
            return false
          end
          -- Return nil to fall back to the next comparator when kinds are equal.
        end,
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
      ghost_text = false,  -- Disable ghost text to avoid conflicts with codeium suggestions
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
      -- Only trigger completion after 2 characters
      autocomplete = false,  -- Disable automatic triggering
    },
    mapping = cmp.mapping.preset.cmdline({
      ['<C-n>'] = cmp.mapping(function()
        if vim.fn.getcmdline():len() >= 2 then
          cmp.complete()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down>', true, false, true), 'n', true)
        end
      end, { 'c' }),
      ['<C-p>'] = cmp.mapping(function()
        if vim.fn.getcmdline():len() >= 2 then
          cmp.complete()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Up>', true, false, true), 'n', true)
        end
      end, { 'c' }),
      ['<Tab>'] = cmp.mapping(function()
        if vim.fn.getcmdline():len() >= 2 then
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', true)
        end
      end, { 'c' }),
      ['<CR>'] = cmp.mapping.confirm({ 
        select = false, 
        behavior = cmp.ConfirmBehavior.Replace 
      }),
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
      { name = 'cmdline', keyword_length = 2, max_item_count = 15 }
    })
  })
  
  -- Add a custom auto-triggering mechanism to cmdline
  vim.api.nvim_create_autocmd("CmdlineChanged", {
    callback = function()
      local cmdtype = vim.fn.getcmdtype()
      if cmdtype == ":" then
        local cmdline = vim.fn.getcmdline()
        -- Only trigger completion after 2 characters
        if cmdline:len() >= 2 and not cmp.visible() then
          cmp.complete()
        end
      end
    end
  })
end

-- Force paste mappings to always override cmp
local function setup_paste_overrides()
  -- Explicitly map clipboard operations in command mode to bypass cmp
  -- These will ensure paste operations always work even if cmp is active
  
  -- Helper function to execute a command with proper escaping
  local function force_paste(paste_cmd)
    return function()
      -- Close any active completion window
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok and cmp.visible() then
        cmp.close()
      end
      
      -- Execute the paste command
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(paste_cmd, true, false, true),
        'n', true
      )
    end
  end
  
  -- Force mapping for common paste operations
  vim.api.nvim_set_keymap('c', '<C-r>+', '', {
    noremap = true,
    callback = force_paste('<C-r>+')
  })
  
  vim.api.nvim_set_keymap('c', '<C-r>"', '', {
    noremap = true,
    callback = force_paste('<C-r>"')
  })
  
  vim.api.nvim_set_keymap('c', '<C-v>', '', {
    noremap = true, 
    callback = force_paste('<C-r>+')
  })
  
  vim.api.nvim_set_keymap('c', '<C-S-v>', '', {
    noremap = true,
    callback = force_paste('<C-r>+')
  })
  
  -- RightMouse is a common paste operation in GUI terminals
  vim.api.nvim_set_keymap('c', '<RightMouse>', '', {
    noremap = true,
    callback = force_paste('<C-r>+')
  })
end

-- Add debug commands to check completion sources
vim.api.nvim_create_user_command('CompletionSources', function()
  local cmp = require('cmp')
  local sources = {}
  table.insert(sources, "Active completion sources:")
  for _, source in ipairs(cmp.get_config().sources) do
    table.insert(sources, string.format("- %s (priority: %s)", source.name, source.priority or "not set"))
  end
  vim.notify(table.concat(sources, "\n"), vim.log.levels.INFO, {
    title = "Completion Sources"
  })
end, {})

-- Initialize completion and paste overrides
setup_cmp()
setup_paste_overrides()

return {}
