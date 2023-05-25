local Job = require "plenary.job"
local utils = require "laravel.utils"

--- Runs and returns the command inmediately
---@param cmd table
---@param opts table
---@return table, boolean
return function(cmd, opts)
  opts = opts or {}
  if type(cmd) ~= "table" then
    utils.notify("runner.async", {
      msg = "cmd has to be a table",
      level = "ERROR",
    })
    return { err = { "cmd is not a table" } }, false
  end

  if type(opts.callback) ~= "function" then
    utils.notify("runner.async", {
      msg = "callback not pass",
      level = "ERROR",
    })
    return { err = { "callback is not a function" } }, false
  end

  local command = table.remove(cmd, 1)
  local stderr = {}
  Job:new({
    command = command,
    args = cmd,
    on_exit = vim.schedule_wrap(opts.callback),
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):start()

  return {}, true
end
