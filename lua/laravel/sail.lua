local runners = require("laravel.runners")

local sail = {}

-- FIX: change callback to be a property in opts and take opts and pass to the runner

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param callback function|nil
sail.run = function(cmd, runner, callback)
	table.insert(cmd, 1, "vendor/bin/sail")
	runner = runner or require("laravel.app").options.default_runner

	return runners[runner](cmd, callback)
end

return sail
