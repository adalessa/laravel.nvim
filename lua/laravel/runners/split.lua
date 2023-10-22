local Split = require "nui.split"
local event = require("nui.utils.autocmd").event
local buffer_run = require "laravel.runners.buffer"

--- Runs in a buffers as a job
---@param cmd table
---@param opts table
---@return table, boolean
return function(cmd, opts)
  local split = Split(vim.tbl_extend("force", {
    relative = "editor",
    position = "right",
    size = "33%",
  }, opts.split or {}))

  split:mount()

  split:on(event.BufLeave, function()
    split:unmount()
  end)

  local result, ok = buffer_run(cmd, vim.tbl_extend("force", opts, { bufnr = split.bufnr }))
  if not ok then
    split:unmount()
  end
  vim.cmd "startinsert"

  return result, ok
end
