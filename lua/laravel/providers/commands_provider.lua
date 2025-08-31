local nio = require("nio")
---@class laravel.providers.commands_provider : laravel.providers.provider
local commands_provider = { name = "laravel.providers.user_command_provider" }

---@param app laravel.core.app
function commands_provider:register(app)
  vim
    .iter({
      require("laravel.commands.artisan"),
      require("laravel.commands.composer"),
      require("laravel.commands.flush_cache"),
      require("laravel.commands.gf"),
      require("laravel.commands.make"),
      require("laravel.commands.related"),
      require("laravel.commands.resources"),
      require("laravel.commands.routes"),
      require("laravel.commands.user_commands"),
      require("laravel.commands.view_finder"),
    })
    :each(function(command)
      app:addCommand(command)
    end)

  app:bindIf("laravel.commands", function()
    return app:makeByTag("laravel.command")
  end)
end

---@param app laravel.core.app
function commands_provider:boot(app)
  Laravel.commands = {
    run = nio.create(function(command, args)
      local cmd = vim.iter(app:make("laravel.commands")):find(function(cmd)
        return vim.startswith(cmd.signature, vim.split(command, " ")[1])
      end)
      if not cmd then
        error("Command not found: " .. command)
      end

      cmd:handle(args)
    end, 2),
  }
end

return commands_provider
