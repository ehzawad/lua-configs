-- ~/.config/nvim/lua/plugins/terminal.lua
-- Terminal enhancements configuration
-- Author: ehzawad@gmail.com

local M = {}

-- Function to handle large file loading
M.load_large_file_async = function(filename, chunk_size)
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

return M
