local Job = require "plenary.job"
local utils = require "laravel.utils"

--- Runs and returns the command immediately
---@param cmd table
---@return table, boolean
return function(cmd)
  if type(cmd) ~= "table" then
    utils.notify("runners.sync", {
      msg = "cmd has to be a table",
      level = "ERROR",
    })
    return {
      out = {},
      exit_code = 1,
      err = { "cmd is not a table" },
    }, false
  end

  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({
    command = command,
    args = cmd,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):sync()

  return {
    out = stdout,
    exit_code = ret,
    err = stderr,
  }, true
end
