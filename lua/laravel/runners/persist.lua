local buffer = require "laravel.runners.buffer"

--- Runs in a buffers as a job
---@param cmd table
---@param opts table
---@return table
return function(cmd, opts)
  opts = opts or {}
  opts.listed = true
  opts.buf_name = vim.fn.join(cmd, " ")

  return buffer(cmd, opts)
end
