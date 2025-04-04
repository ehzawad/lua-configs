-- ~/.config/nvim/lua/utils/terminal.lua
-- Terminal detection and configuration utilities
-- Author: ehzawad@gmail.com

local M = {}

-- Detect if we're running in a basic terminal without advanced features
function M.detect_basic_terminal()
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
