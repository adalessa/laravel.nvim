local runners = require("laravel.runners")

local composer = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param callback function|nil
composer.run = function(cmd, runner, callback)
	table.insert(cmd, 1, "composer")
	if require("laravel.app").environment.uses_sail then
		table.insert(cmd, 1, "vendor/bin/sail")
	end
	runner = runner or require("laravel.app").options.default_runner

	return runners[runner](cmd, callback)
end

return composer
