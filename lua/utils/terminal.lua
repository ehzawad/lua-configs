-- ~/.config/nvim/lua/utils/terminal.lua
-- Terminal detection and configuration utilities
-- Author: ehzawad@gmail.com

local M = {}

-- Detect if we're running in a basic terminal without advanced features
function M.detect_basic_terminal()
  -- DEBUG: Print the raw OS information
  local raw_sysname = vim.loop.os_uname().sysname
  -- print("Raw detected OS: " .. raw_sysname)

  -- Fix for potential incorrect OS detection
  local sysname = raw_sysname
  
  -- Check for macOS-specific indicators
  if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
    -- print("Mac detected via vim.fn.has")
    sysname = "Darwin"
  end
  
  -- Additional macOS check
  if vim.fn.executable('sw_vers') == 1 then
    -- print("Mac detected via sw_vers")
    sysname = "Darwin"
  end
  
  -- print("Final OS determination: " .. sysname)
  local is_basic = false

  if sysname == "Darwin" then
    local term_program = vim.env.TERM_PROGRAM or ""
    -- print("macOS detected with TERM_PROGRAM: " .. term_program)
    
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
    local colorterm = vim.env.COLORTERM or ""
    
    -- print("Linux detected with TERM: " .. term)
    
    if term == "xterm" and not term:match("256color") and 
       term_program == "" and xterm_version == "" and colorterm == "" then
      is_basic = true
    else
      is_basic = false
    end
  else
    -- print("Other OS detected: " .. sysname)
    is_basic = false
  end
  
  -- print("Terminal detected as: " .. (is_basic and "BASIC" or "ADVANCED"))
  return is_basic
end

-- Initialize variables
M.basic_terminal = M.detect_basic_terminal()
vim.g.is_basic_terminal = M.basic_terminal and 1 or 0

-- Terminal UI settings for basic terminals
M.terminal_ui = {
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

return M
