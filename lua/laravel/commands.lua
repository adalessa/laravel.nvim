local log = require("laravel.dev").log
local application = require "laravel.application"
local laravel_command = require "laravel.command"
local utils = require "laravel.utils"

local container_key = "artisan_commands"

return {
  clean = function()
    application.container.unset(container_key)
  end,

  list = function()
    if not application.ready() then
      utils.notify(
        "Commands List",
        { level = "ERROR", msg = "The application is not ready for current working directory" }
      )
      return nil
    end

    local commands = application.container.get(container_key)
    if commands then
      return commands
    end
    -- return the commands
    local result, ok = application.run("artisan", { "list", "--format=json" }, { runner = "sync" })
    if not ok then
      return nil
    end

    if result.exit_code == 1 then
      log.error("app.commands(): stdout", result.out)
      log.error("app.commands(): stderr", result.err)
      return nil
    end

    commands = laravel_command.from_json(result.out)

    if #commands > 0 then
      application.container.set(container_key, commands)
    end

    return commands
  end,

  load = function()
    application.run("artisan", { "list", "--format=json" }, {
      runner = "async",
      callback = function(j, exit_code)
        if exit_code == 1 then
          application.container.unset(container_key)
        end
        local commands = laravel_command.from_json(j:result())
        if #commands > 0 then
          application.container.set(container_key, commands)
        end
      end,
    })
  end,
}
