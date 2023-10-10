local Popup = require "nui.popup"
local event = require("nui.utils.autocmd").event
local buffer_run = require "laravel.runners.buffer"

--- Runs in a buffers as a job
---@param cmd table
---@param opts table
---@return table, boolean
return function(cmd, opts)
  local popup = Popup(vim.tbl_extend("force", {
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
    },
    position = {
      row = "20%",
      col = "50%",
    },
    size = {
      width = "28%",
      height = "35%",
    },
  }, opts.popup or {}))

  popup:mount()

  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  local result, ok = buffer_run(cmd, vim.tbl_extend("force", opts, { bufnr = popup.bufnr }))
  if not ok then
    popup:unmount()
  end
  vim.cmd "startinsert"

  return result, ok
end
