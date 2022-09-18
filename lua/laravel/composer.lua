local runner = require("laravel.runner")
local M = {}

local function run(cmd)
    if LaravelConfig.runtime.is_sail then
        cmd = LaravelConfig.runtime.artisan_cmd .. ' ' .. cmd
    end

    runner.terminal(vim.split(cmd, ' '))
end

function M.update(library)
    local cmd = "composer update"
    if library ~= nil then
        cmd = cmd .. ' ' .. library
    end
    run(cmd)
end

function M.install()
    run("composer install")
end

function M.require(library)
    local cmd = "composer require"
    if library ~= nil then
        cmd = cmd .. ' ' .. library
    end
    run(cmd)
end

function M.remove(library)
    local cmd = "composer remove"
    if library ~= nil then
        cmd = cmd .. ' ' .. library
    end
    run(cmd)
end

return M
