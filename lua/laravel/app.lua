local cache = require("laravel.cache_manager")
local artisan = require("laravel.artisan")
local laravel_command = require("laravel.command")
local log = require("laravel.dev").log

---@class laravel.app
---@field options laravel.config
---@field environment laravel.environment
--
local app = {
    options = {},
    environment = {},
}

app.commands = function()
    return cache.get("commands", function()
        local stdout, ret, stderr = artisan.run({ "list", "--format=json" }, "sync")

        if ret == 1 then
            log.error("artisan.commands(): stdout", stdout)
            log.error("artisan.commands(): stderr", stderr)
            return {}
        end

        return laravel_command.from_json(stdout)
    end)
end

app.routes = function()
    return cache.get("routes", function()
        local stdout, ret, stderr = artisan.run({ "route:list", "--json" }, "sync")

        if ret == 1 then
            log.error("artisan.routes(): stdout", stdout)
            log.error("artisan.routes(): stderr", stderr)
            return {}
        end

        return vim.fn.json_decode(stdout)
    end)
end

app.load_commands = function()
    cache.forget("commands")
    artisan.run({ "list", "--format=json" }, "async", function(j, exit_code)
        if exit_code == 1 then
            return
        end
        cache.put("commands", laravel_command.from_json(j:result()))
    end)
end

app.load_routes = function()
    cache.forget("routes")
    artisan.run({ "route:list", "--json" }, "async", function(j, exit_code)
        if exit_code == 1 then
            return
        end
        cache.put("routes", vim.fn.json_decode(j:result()))
    end)
end


return app
