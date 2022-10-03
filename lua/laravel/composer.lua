local runner = require("laravel.runner")
local M = {}

---run a command in the terminal
---@param cmd string
local function run(cmd)
    if Laravel.properties.uses_sail then
        cmd =  'vendor/bin/sail ' .. cmd
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
