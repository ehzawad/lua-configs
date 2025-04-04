-- ~/.config/nvim/lua/core/autocmds.lua
-- Core autocommands for Neovim
-- Author: ehzawad@gmail.com

local basic_terminal = require('utils.terminal').basic_terminal

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
    _G.virtual_text_enabled = false
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

-- Restore cursor position
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

-- Automatically create directories when saving a file
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*",
  callback = function()
    local required_dir = vim.fn.expand("%:h")
    if vim.fn.isdirectory(required_dir) == 0 then
      local msg = "Parent directory '" .. required_dir .. "' doesn't exist."
      local options = "&Create it\nor &Quit?"
      local choice = vim.fn.confirm(msg, options)
      
      if choice == 2 then -- Quit option
        vim.cmd('exit')
        return
      end
      
      local ok, err = pcall(function()
        vim.fn.mkdir(required_dir, "p")
      end)
      
      if not ok then
        local err_msg = "Can't create '" .. required_dir .. "'"
        local err_options = "&Quit\nor &Continue anyway?"
        local err_choice = vim.fn.confirm(err_msg, err_options)
        
        if err_choice == 1 then -- Quit option
          vim.cmd('exit')
        end
      end
    end
  end
})

-- Autocommand to reset highlights when colorscheme changes
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    -- Cursor line highlighting
    vim.api.nvim_set_hl(0, 'CursorLine', {
      bg = basic_terminal and "#1c1c1c" or "#262626",
      ctermbg = 233,
    })

    -- Cursor line number styling
    vim.api.nvim_set_hl(0, 'CursorLineNr', {
      fg = "#ffaf00",
      bg = basic_terminal and "#1c1c1c" or "#262626",
      ctermfg = 214,
      ctermbg = 233,
      bold = true,
    })

    -- Cursor itself
    vim.api.nvim_set_hl(0, 'Cursor', {
      reverse = true,
    })
    
    -- Visual selection highlighting
    vim.api.nvim_set_hl(0, 'Visual', {
      bg = basic_terminal and "#3a3a3a" or "#3a3a3a",
      ctermbg = 237,
    })
    
    -- Highlight parentheses
    vim.api.nvim_set_hl(0, 'MatchParen', { ctermbg = 'gray', bg = 'lightgray' })
  end
})
