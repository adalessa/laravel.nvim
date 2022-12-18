local log = require("laravel.dev").log
local runners = require("laravel.runners")
local notify = require("notify")

local sail = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param callback function|nil
sail.run = function(cmd, runner, callback)
    table.insert(cmd, 1, "vendor/bin/sail")
    runner = runner or require("laravel.app").options.default_runner

    return runners[runner](cmd, callback)
end

sail.shell = function()
    sail.run({"shell"}, "terminal")
end

sail.up = function()
    sail.run({"up", "-d"}, "async", function(j, exit_code)
        if exit_code ~= 0 then
            log.error("sail.up(): stdout", j:result())
            log.error("sail.up(): stderr", j:result())
            notify.notify("Failed to run Sail up", "error", {title = "laravel.nvim"})

            return
        end
        notify.notify("Sail up complete", "info", {title = "Laravel.nvim"})
    end)
end

sail.ps = function ()
    sail.run({"ps"}, "async", function(j, exit_code)
        if exit_code ~= 0 then
            log.error("sail.up(): stdout", j:result())
            log.error("sail.up(): stderr", j:result())
            notify.notify("Failed to run Sail up", "error", {title = "laravel.nvim"})

            return
        end
        notify.notify(j:result(), "info", {title = "Laravel.nvim"})
    end)
end

sail.restart = function()
    sail.run({"restart"}, "async", function(j, exit_code)
        if exit_code ~= 0 then
            log.error("sail.restart(): stdout", j:result())
            log.error("sail.restart(): stderr", j:result())
            notify.notify("Failed to restart Sail", "error", {title = "laravel.nvim"})

            return
        end
        notify.notify("Sail restart complete", "info", {title = "Laravel.nvim"})
    end)
    notify.notify("Sail restart starting", "info", {title = "Laravel.nvim"})
end

sail.down = function()
    sail.run({"down"}, "async", function(j, exit_code)
        if exit_code ~= 0 then
            log.error("sail.down(): stdout", j:result())
            log.error("sail.down(): stderr", j:result())
            notify.notify("Failed to down Sail", "error", {title = "laravel.nvim"})

            return
        end
        notify.notify("Sail Down complete", "info", {title = "Laravel.nvim"})
    end)
end

return sail
