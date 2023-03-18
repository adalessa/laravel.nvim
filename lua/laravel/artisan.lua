local utils = require("laravel.utils")
local runners = require("laravel.runners")

local artisan = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table | nil
artisan.run = function(cmd, runner, opts)
  local job_cmd = utils.get_artisan_cmd(cmd)
  runner = runner
    or require("laravel").app.options.commands_runner[cmd[1]]
    or require("laravel").app.options.default_runner

  return runners[runner](job_cmd, opts or {})
end

return artisan
