local buffer_utils = require("laravel.utils.buffer")

local M = {}

function M.whenValid(callback)
  return function(ev)
    if not buffer_utils.is_valid_buffer(ev.buf) then
      return
    end

    local cwd = vim.uv.cwd()
    if vim.startswith(ev.file, cwd .. "/vendor") then
      return
    end

    return callback(ev)
  end
end

return M
