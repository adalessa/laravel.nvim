local cache = require "laravel.cache_manager"
local artisan = require "laravel.artisan"
local laravel_command = require "laravel.command"
local laravel_route = require "laravel.route"
local log = require("laravel.dev").log
local utils = require "laravel.utils"
local runners = require "laravel.runners"

---@param options laravel.config
---@return laravel.app | nil
return function(options)
  local env = require("laravel.environment").load(options)
  if not env.is_laravel_project or not env.environment then
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

  local function exec(cmd_type, cmd, runner, opts)
    opts = opts or {}
    if type(cmd) == "table" then
      cmd = table.concat(cmd, " ")
    end
    if cmd_type then
      cmd = env.environment:build_cmd(cmd_type, cmd)
    end
    if cmd then
      cmd = vim.split(cmd, " ")

      runner = runner or app.options.default_runner

      return runners[runner](cmd, opts), true
    end
    return {}, false
  end

  app.run = function(cmd_type, cmd, runner, opts)
    if not env.environment then
      require("laravel.utils").notify("artisan.run", { msg = "Environment is not found", level = "ERROR" })
    end
    local is_running = exec(nil, env.environment:is_running(), "sync")
    if is_running then
      return exec(cmd_type, cmd, runner, opts)
    end
    if not opts.silent then
      require("laravel.utils").notify("artisan.run", { msg = "Environment is not running", level = "ERROR" })
    end
    return {}, false
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
