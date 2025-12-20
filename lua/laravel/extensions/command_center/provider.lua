---@type laravel.extensions.provider
local command_center_provider = {}

function command_center_provider.register(app)
  app:addCommand("laravel.commands.command_center", function()
    return {
      signature = "command_center",
      description = "Open Command Center",
      handle = function()
        app("laravel.extensions.command_center.command_center"):open()
      end,
    }
  end)
end

return command_center_provider
