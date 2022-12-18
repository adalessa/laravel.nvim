local utils = require("laravel.utils")
local runners = require("laravel.runners")

local artisan = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param callback function|nil
artisan.run = function(cmd, runner, callback)
    local job_cmd = utils.get_artisan_cmd(cmd)
    runner = runner
        or
        require("laravel.app").options.artisan_command_runner[cmd[1]]
        or
        require("laravel.app").options.default_runner

    return runners[runner](job_cmd, callback)
end

return artisan
