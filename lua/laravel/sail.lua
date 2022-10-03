local log = require("laravel.dev").log
local utils = require("laravel.utils")
local runner = require("laravel.runner")
local notify = require("notify")

local sail = {}

function sail.run(cmd)
    local job_cmd = utils.get_sail_cmd(vim.split(cmd, " "))
	log.debug("sail.run(): running", job_cmd)
    runner.terminal(job_cmd)
end

function sail.exec(cmd)
    local job_cmd = utils.get_sail_cmd(vim.split(cmd, " "))
	log.debug("sail.run(): running", job_cmd)

    return runner.sync(job_cmd)
end

function sail.shell()
    runner.terminal({"vendor/bin/sail", "shell"})
end

function sail.up()
    runner.async({"vendor/bin/sail", "up", "-d"}, function (j, exit_code)
        if exit_code ~= 0 then
            log.error("sail.up(): stdout", j:result())
            log.error("sail.up(): stderr", j:result())
            notify.notify("Failed to run Sail up", "error", {title = "laravel.nvim"})

            return
        end
        notify.notify("Sail up complete", "info", {title = "Laravel.nvim"})
    end)
end

function sail.restart()
    runner.async({"vendor/bin/sail", "restart"}, function (j, exit_code)
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

function sail.down()
    runner.async({"vendor/bin/sail", "down"}, function (j, exit_code)
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
