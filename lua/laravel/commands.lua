local log = require("laravel.dev").log
local application = require "laravel.application"
local laravel_command = require "laravel.command"

local container_key = "artisan_commands"

return {
  clean = function()
    application.container.unset(container_key)
  end,
  list = function()
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

    application.container.set(container_key, commands)

    return commands
  end,
  load = function()
    application.run("artisan", { "list", "--format=json" }, {
      runner = "async",
      callback = function(j, exit_code)
        if exit_code == 1 then
          return
        end
        application.container.set(container_key, laravel_command.from_json(j:result()))
      end,
    })
  end,
}
