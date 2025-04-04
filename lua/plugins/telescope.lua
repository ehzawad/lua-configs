-- ~/.config/nvim/lua/plugins/telescope.lua
-- Telescope configuration
-- Author: ehzawad@gmail.com

-- Override the symbols picker to disable it
local status, telescope_builtin = pcall(require, "telescope.builtin")
if status then
  telescope_builtin.symbols = function()
    vim.notify("Symbols picker is disabled", vim.log.levels.INFO)
  end
end

-- Load aerial extension for telescope if available
pcall(require('telescope').load_extension, 'aerial')

return {}
