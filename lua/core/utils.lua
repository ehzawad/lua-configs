-- ~/.config/nvim/lua/core/utils.lua
-- Core utility functions
-- Author: ehzawad@gmail.com

local basic_terminal = require('utils.terminal').basic_terminal
local M = {}

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

-- Create a wrapper for vim.api.nvim_create_user_command that includes error handling
M.create_user_command_with_error_handling = function(name, fn, opts)
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

-- Function to detect mapping conflicts in the same mode
M.mapping_conflicts = {}

M.mapping_conflicts.find_same_mode_conflicts = function()
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
M.mapping_conflicts.display_conflicts = function()
  local conflicts = M.mapping_conflicts.find_same_mode_conflicts()
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

-- Register custom commands
local function register_custom_commands()
  -- Command to toggle cursor line
  M.create_user_command_with_error_handling('ToggleCursor', function()
    vim.o.cursorline = not vim.o.cursorline
    print(vim.o.cursorline and "Cursor highlight enabled" or "Cursor highlight disabled")
  end, {})

  -- Command to toggle both virtual text and sign column indicators
  _G.virtual_text_enabled = false
  M.create_user_command_with_error_handling('Togglediagnostics', function()
    _G.virtual_text_enabled = not _G.virtual_text_enabled
    
    if _G.virtual_text_enabled then
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

  -- Command to find mapping conflicts
  M.create_user_command_with_error_handling('FindMappingConflicts', function()
    M.mapping_conflicts.display_conflicts()
  end, {
    desc = "Find conflicting key mappings in the same mode"
  })

  -- Define the toggle folding function
  M.create_user_command_with_error_handling('ToggleFolding', function()
    if vim.wo.foldmethod == 'manual' then
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      print("Folding enabled with Treesitter")
    else
      vim.wo.foldmethod = 'manual'
      print("Folding disabled")
    end
  end, {})

  -- Add this as a custom command
  M.create_user_command_with_error_handling('ClearBufferArtifacts', function()
    -- Clear completion state
    pcall(function() vim.fn['codeium#Clear']() end)
    -- Clear nvim-cmp state
    pcall(function() require('cmp').close() end)
    -- Clear LSP hover windows
    pcall(vim.lsp.buf.clear_references)
    -- Close all floating windows
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= "" then
        vim.api.nvim_win_close(win, false)
      end
    end
    -- Force complete redraw
    vim.cmd('mode')  -- Show and clear current mode
    vim.cmd('redraw!')  -- Force a complete redraw
    print("Buffer artifacts cleared")
  end, {desc = "Clear completion artifacts from buffer"})

  -- Terminal commands
  -- Horizontal terminal
  M.create_user_command_with_error_handling('Termhorizontal', function(opts)
    local size = opts.args ~= "" and opts.args or "15"
    vim.cmd(size .. "split")
    vim.cmd("terminal")
    vim.cmd("startinsert")
  end, {nargs = "?"})

  -- Vertical terminal
  M.create_user_command_with_error_handling('Termvertical', function(opts)
    local size = opts.args ~= "" and opts.args or "80"
    vim.cmd(size .. "vsplit")
    vim.cmd("terminal")
    vim.cmd("startinsert")
  end, {nargs = "?"})

  -- Tab terminal
  M.create_user_command_with_error_handling('Termnew', function()
    vim.cmd("tabnew")
    vim.cmd("terminal")
    vim.cmd("startinsert")
  end, {})

  -- Floating terminal
  M.create_user_command_with_error_handling('Termfloat', function()
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
  M.create_user_command_with_error_handling('Term', function(opts)
    vim.cmd("Termhorizontal " .. opts.args)
  end, {nargs = "?"})

  -- VSplit into tab commands
  M.create_user_command_with_error_handling('VSplitIntoPrevTab', function()
    -- Check if there's only one window
    if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 then
      return
    end
    -- Prepare new window
    local tab_nr = vim.fn.tabpagenr('$')
    local cur_buf = vim.fn.bufnr('%')
    if vim.fn.tabpagenr() ~= 1 then
      vim.cmd('close!')
      if tab_nr == vim.fn.tabpagenr('$') then
        vim.cmd('tabprev')
      end
      vim.cmd('vsp')
    else
      vim.cmd('close!')
      vim.cmd('0tabnew')
    end
    -- Open current buffer in new window
    vim.cmd('b' .. cur_buf)
  end, {})
  
  M.create_user_command_with_error_handling('VSplitIntoNextTab', function()
    -- Check if there's only one window
    if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 then
      return
    end
    -- Prepare new window
    local tab_nr = vim.fn.tabpagenr('$')
    local cur_buf = vim.fn.bufnr('%')
    if vim.fn.tabpagenr() < tab_nr then
      vim.cmd('close!')
      if tab_nr == vim.fn.tabpagenr('$') then
        vim.cmd('tabnext')
      end
      vim.cmd('vsp')
    else
      vim.cmd('close!')
      vim.cmd('tabnew')
    end
    -- Open current buffer in new window
    vim.cmd('b' .. cur_buf)
  end, {})
  
  -- Word highlight function
  _G.word_highlight_active = false
  local function highlight_all_of_word(word)
    if word then
      -- Enable highlighting with the given word
      _G.word_highlight_active = true
      local pattern = [[\<]] .. vim.fn.expand('<cword>') .. [[\>]]
      vim.fn.matchadd('Search', pattern)
      -- Create autocmd to update the highlight when cursor moves
      vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
          if _G.word_highlight_active then
            vim.fn.clearmatches()
            local pattern = [[\<]] .. vim.fn.expand('<cword>') .. [[\>]]
            vim.fn.matchadd('Search', pattern)
          end
        end
      })
    else
      -- Disable highlighting
      _G.word_highlight_active = false
      vim.fn.clearmatches()
    end
  end

  M.create_user_command_with_error_handling('HighlightAllOfWord', function(opts)
    if opts.args ~= "" then
      highlight_all_of_word(opts.args)
    else
      highlight_all_of_word(nil)
    end
  end, { nargs = '?' })
end

-- Register all custom commands
register_custom_commands()

-- Configure clipboard
M.setup_clipboard = function()
  -- Use both PRIMARY (middle-click) and CLIPBOARD (Ctrl+C/Ctrl+V)
  vim.opt.clipboard = "unnamed,unnamedplus"

  -- Only set up the OSC52 clipboard for SSH connections
  if vim.env.SSH_CONNECTION or vim.env.SSH_TTY or vim.env.SSH_CLIENT then
    local function vim_paste()
      local content = vim.fn.getreg('"')
      return vim.split(content, "\n")
    end

    -- Check if OSC52 module is available (handle different Neovim versions)
    local osc52_module_ok, osc52_module = pcall(require, "vim.ui.clipboard.osc52")
    if not osc52_module_ok then
      osc52_module_ok, osc52_module = pcall(require, "vim.clipboard.osc52")
    end

    if osc52_module_ok then
      vim.g.clipboard = {
        name = "OSC 52",
        copy = {
          ["+"] = osc52_module.copy("+"),
          ["*"] = osc52_module.copy("*"),
        },
        paste = {
          ["+"] = vim_paste,
          ["*"] = vim_paste,
        },
      }
    end
  end
end

-- Initialize clipboard
M.setup_clipboard()

-- Function to disable mouse in cmdline mode
M.disable_mouse_in_cmdline = function()
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function()
      vim.o.mouse = ""
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
      vim.o.mouse = "a"
    end,
  })
end

-- Initialize cmdline mouse control
M.disable_mouse_in_cmdline()

return M
