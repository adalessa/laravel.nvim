local cache = require "laravel.cache_manager"
local artisan = require "laravel.artisan"
local laravel_command = require "laravel.command"
local laravel_route = require "laravel.route"
local log = require("laravel.dev").log
local utils = require "laravel.utils"

---@param options laravel.config
---@return laravel.app | nil
return function(options)
  local env = require("laravel.environment").load()
  if not env.is_laravel_project then
    return nil
  end

  local storage = {}

  ---@class laravel.app
  ---@field options laravel.config
  ---@field environment laravel.environment
  local app = {
    options = options,
    environment = env,
  }

  --- Gets the application command
  ---@return nil|LaravelCommand[]
  app.commands = function()
    return cache.get("commands", function()
      local result, ok = artisan.run({ "list", "--format=json" }, "sync")
      if not ok then
        return nil
      end

      if result.exit_code == 1 then
        log.error("app.commands(): stdout", result.out)
        log.error("app.commands(): stderr", result.err)
        return nil
      end

      return laravel_command.from_json(result.out)
    end)
  end

  --- Gets the application routes
  ---@return nil|LaravelRoute[]
  app.routes = function()
    return cache.get("routes", function()
      local result, ok = artisan.run({ "route:list", "--json" }, "sync")

      if not ok then
        return nil
      end

      if result.exit_code == 1 then
        log.error("app.routes(): stdout", result.out)
        log.error("app.routes(): stderr", result.err)
        return nil
      end

      return laravel_route.from_json(result.out)
    end)
  end

  app.load_commands = function()
    cache.forget "commands"
    artisan.run({ "list", "--format=json" }, "async", {
      callback = function(j, exit_code)
        if exit_code == 1 then
          return
        end
        cache.put("commands", laravel_command.from_json(j:result()))
      end,
      silent = true,
    })
  end

  app.load_routes = function()
    cache.forget "routes"
    artisan.run({ "route:list", "--json" }, "async", {
      callback = function(j, exit_code)
        if exit_code == 1 then
          return
        end
        cache.put("routes", laravel_route.from_json(j:result()))
      end,
      silent = true,
    })
  end

  --- Checks if should use sail, and if it is running
  ---@param uses function|nil
  ---@param not_uses function|nil
  ---@param silent boolean
  ---@return boolean
  app.if_uses_sail = function(uses, not_uses, silent)
    if not app.environment.uses_sail then
      if not_uses ~= nil then
        not_uses()
      end
      return true
    end

    if require("laravel.sail").is_running() then
      if uses ~= nil then
        uses()
      end
      return true
    end

    if not silent then
      require("laravel.utils").notify("artisan.run", { msg = "Sail is not running", level = "ERROR" })
    end
    return false
  end

  --- stores a value related to the app execution
  ---@param key string
  app.get = function(key)
    return storage[key]
  end

  app.set = function(key, value)
    storage[key] = value
    return value
  end

  app.sendToTinker = function()
    local lines = utils.get_visual_selection()
    if nil == app.get "tinker" then
      require("laravel.artisan").run({ "tinker" }, "terminal", { focus = false })
      if nil == app.get "tinker" then
        utils.notify("Send To Tinker", { msg = "Tinker terminal id not found and could create it", level = "ERROR" })
        return
      end
    end

    for _, line in ipairs(lines) do
      vim.api.nvim_chan_send(app.get "tinker", line .. "\n")
    end
  end

  return app
end
