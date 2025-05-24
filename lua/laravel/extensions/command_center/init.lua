---@class laravel.extension.command_center: laravel.providers.provider
local command_center_provider = {}

function command_center_provider:register(app)
  app:command("command_center", function()
    app("laravel.extensions.command_center.command_center"):open()
  end)
end

function command_center_provider:boot(app)
end

return command_center_provider
